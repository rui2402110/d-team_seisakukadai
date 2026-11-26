import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/page/auth_gate.dart';
import '../../auth/repository/auth_repository.dart';
import '../../component/navbar.dart';
import '../../core/kakko_theme.dart';
import '../repository/mute_word.dart';

// デモ版 settings.css の danger 赤 (#e07b7b) に相当する色
const Color _danger = Color(0xFFE07B7B);

/// 設定画面（デモ版 settings.html の見た目を再現）
/// - ミュートワードセクション（追加/一覧/インライン編集/削除）
/// - ユーザー設定セクション（パスワード変更モーダル/ログアウト）
/// - パスワード変更モーダル
class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  // ミュートワード（UC-17: shared_preferences にユーザーID単位で保存）
  final _muteRepo = MuteWordRepository();
  List<String> _muteWords = [];
  bool _muteLoaded = false;
  final _muteController = TextEditingController();

  // 一覧のインライン編集状態（編集中のindex。nullなら非編集）
  int? _editingIndex;
  final _editController = TextEditingController();

  // 認証まわり（ログアウトで使用）
  final _authRepository = AuthRepository();

  /// ミュートワードをユーザーID単位で保存するためのID（未ログイン時は 'local'）
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'local';

  @override
  void initState() {
    super.initState();
    _loadMuteWords();
  }

  @override
  void dispose() {
    _muteController.dispose();
    _editController.dispose();
    super.dispose();
  }

  Future<void> _loadMuteWords() async {
    final words = await _muteRepo.getAll(_userId);
    if (!mounted) return;
    setState(() {
      _muteWords = words;
      _muteLoaded = true;
    });
  }

  // デモ版のトースト相当（画面下部にふわっと出る）
  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: KakkoColors.paperText),
        ),
        backgroundColor: KakkoColors.inkSoft,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: KakkoColors.inkLine),
        ),
        duration: const Duration(milliseconds: 2200),
        margin: const EdgeInsets.only(bottom: 28),
      ),
    );
  }

  // ---- ミュートワード操作（UC-17: repository経由で保存） ----
  Future<void> _addMuteWord() async {
    final word = _muteController.text.trim();
    if (word.isEmpty) return;
    final ok = await _muteRepo.add(_userId, word);
    if (!mounted) return;
    if (!ok) {
      // UC-17: 重複登録の場合
      _toast('すでに登録されています');
      return;
    }
    _muteController.clear();
    await _loadMuteWords();
  }

  Future<void> _removeMuteWord(int index) async {
    await _muteRepo.remove(_userId, index);
    if (!mounted) return;
    setState(() {
      if (_editingIndex == index) {
        _editingIndex = null;
      } else if (_editingIndex != null && _editingIndex! > index) {
        _editingIndex = _editingIndex! - 1;
      }
    });
    await _loadMuteWords();
  }

  void _startEdit(int index) {
    setState(() {
      _editingIndex = index;
      _editController.text = _muteWords[index];
    });
  }

  Future<void> _commitEdit(int index) async {
    final v = _editController.text.trim();
    if (v.isNotEmpty) {
      final ok = await _muteRepo.update(_userId, index, v);
      if (!mounted) return;
      if (!ok) {
        // UC-17: 重複する単語への更新の場合
        _toast('すでに登録されています');
      }
    }
    // 空の場合は更新せず編集を終了する（デモ版と同じ）
    if (!mounted) return;
    setState(() => _editingIndex = null);
    await _loadMuteWords();
  }

  // ---- ログアウト ----
  /// ログアウト（確認ダイアログ → Firebaseサインアウト → 認証入口(AuthGate)へ）
  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xB3140E09),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: KakkoColors.inkSoft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: KakkoColors.inkLine),
          ),
          title: const Text(
            'ログアウトしますか？',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: KakkoColors.paperText,
            ),
          ),
          content: const Text(
            'このアカウントからログアウトします。',
            style: TextStyle(fontSize: 13, color: KakkoColors.muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'キャンセル',
                style: TextStyle(color: KakkoColors.muted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'ログアウト',
                style: TextStyle(color: _danger, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
    if (ok != true) return;

    try {
      await _authRepository.logout();
    } catch (_) {
      if (!mounted) return;
      _toast('ログアウトに失敗しました。もう一度お試しください');
      return;
    }
    if (!mounted) return;
    // 認証の入口へ戻る（画面スタックをすべて破棄する）
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  // ---- パスワード変更モーダル ----
  Future<void> _showPasswordDialog() async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    await showDialog<void>(
      context: context,
      barrierColor: const Color(0xB3140E09), // rgba(20,14,9,0.7)
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: KakkoColors.inkSoft,
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: KakkoColors.inkLine),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ヘッダー（タイトル + ✕）
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'パスワードを設定する',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: KakkoColors.paperText,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0x14F3E6D2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 15,
                            color: KakkoColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _pwField('現在のパスワード', current),
                  _pwField('新しいパスワード', next),
                  _pwField(
                    '新しいパスワード(確認)',
                    confirm,
                    onSubmitted: (_) =>
                        _submitPassword(dialogContext, current, next, confirm),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () =>
                        _submitPassword(dialogContext, current, next, confirm),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KakkoColors.accent,
                      foregroundColor: KakkoColors.ink,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                        horizontal: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('パスワードを更新する'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    current.dispose();
    next.dispose();
    confirm.dispose();
  }

  // デモ版 settings.js の更新処理相当（見た目のみ。サーバー送信なし）
  void _submitPassword(
    BuildContext dialogContext,
    TextEditingController current,
    TextEditingController next,
    TextEditingController confirm,
  ) {
    if (current.text.isEmpty || next.text.isEmpty || confirm.text.isEmpty) {
      _toast('すべての項目を入力してください');
      return;
    }
    if (next.text != confirm.text) {
      _toast('新しいパスワードが一致しません');
      return;
    }
    Navigator.of(dialogContext).pop();
    current.clear();
    next.clear();
    confirm.clear();
    _toast('パスワードを更新しました（デモ）');
  }

  Widget _pwField(
    String label,
    TextEditingController controller, {
    void Function(String)? onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: KakkoColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: true,
            style: const TextStyle(fontSize: 14, color: KakkoColors.paperText),
            cursorColor: KakkoColors.accent,
            decoration: _filledInputDecoration(hint: '••••••••', radius: 10),
            onSubmitted: onSubmitted,
          ),
        ],
      ),
    );
  }

  // ---- 装飾の部品 ----
  OutlineInputBorder _outline(double radius, {Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color ?? KakkoColors.inkLine, width: width),
    );
  }

  InputDecoration _filledInputDecoration({
    required String hint,
    double radius = 999,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: KakkoColors.muted, fontSize: 14),
      filled: true,
      fillColor: KakkoColors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      counterText: '',
      border: _outline(radius),
      enabledBorder: _outline(radius),
      focusedBorder: _outline(radius, color: KakkoColors.accent, width: 2),
    );
  }

  /// セクションカード（デモの .settings-section）
  Widget _sectionCard({
    required String title,
    required String desc,
    required Widget body,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: KakkoColors.inkSoft,
        border: Border.all(color: KakkoColors.inkLine),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ヘッダー（下罫線付き）
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: KakkoColors.inkLine)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: KakkoColors.paperText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.6,
                    color: KakkoColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: body,
          ),
        ],
      ),
    );
  }

  /// ミュートワードセクション
  Widget _muteSection() {
    return _sectionCard(
      title: 'ミュートワード',
      desc: '登録した単語を含む投稿をタイムラインやコミュニティで目立たなくします。ここでの変更はタイムライン・コミュニティ詳細画面にもすぐに反映されます。',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 追加行（入力 + 追加ボタン）
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _muteController,
                  maxLength: 40,
                  style: const TextStyle(
                    fontSize: 14,
                    color: KakkoColors.paperText,
                  ),
                  cursorColor: KakkoColors.accent,
                  decoration: _filledInputDecoration(hint: 'ミュートしたい単語を入力'),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _addMuteWord(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _muteController.text.trim().isEmpty
                    ? null
                    : _addMuteWord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KakkoColors.accent,
                  foregroundColor: KakkoColors.ink,
                  disabledBackgroundColor: KakkoColors.accentDisabled,
                  disabledForegroundColor: KakkoColors.ink,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('追加'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 一覧 or 空メッセージ（読み込み完了後のみ空表示を出す）
          if (_muteLoaded && _muteWords.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  '登録されているミュートワードはありません',
                  style: TextStyle(fontSize: 13, color: KakkoColors.muted),
                ),
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < _muteWords.length; i++) ...[
                  _muteItem(i),
                  if (i != _muteWords.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
        ],
      ),
    );
  }

  /// ミュートワードの1項目（編集中は入力欄に差し替わる）
  Widget _muteItem(int index) {
    final editing = _editingIndex == index;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x0AF3E6D2), // rgba(243,230,210,0.04)
        border: Border.all(color: KakkoColors.inkLine),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: editing
                ? TextField(
                    controller: _editController,
                    autofocus: true,
                    maxLength: 40,
                    style: const TextStyle(
                      fontSize: 14,
                      color: KakkoColors.paperText,
                    ),
                    cursorColor: KakkoColors.accent,
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0x14F3E6D2),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      border: _outline(8, color: KakkoColors.accent),
                      enabledBorder: _outline(8, color: KakkoColors.accent),
                      focusedBorder: _outline(8, color: KakkoColors.accent),
                    ),
                    onSubmitted: (_) => _commitEdit(index),
                  )
                : Text(
                    _muteWords[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: KakkoColors.paperText,
                    ),
                  ),
          ),
          // 編集/確定 + 削除ボタン
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(editing ? Icons.check : Icons.edit_outlined),
                iconSize: 15,
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                padding: EdgeInsets.zero,
                color: editing ? KakkoColors.accent : KakkoColors.muted,
                hoverColor: const Color(0x14F3E6D2),
                onPressed: () =>
                    editing ? _commitEdit(index) : _startEdit(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                iconSize: 15,
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                padding: EdgeInsets.zero,
                color: KakkoColors.muted,
                hoverColor: const Color(0x23E07B7B),
                onPressed: () => _removeMuteWord(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ユーザー設定セクション
  Widget _userSection() {
    return _sectionCard(
      title: 'ユーザー設定',
      desc: 'アカウントに関する設定です。',
      body: Column(
        children: [
          _settingsRow(
            icon: Icons.lock_outline,
            title: 'パスワードを設定する',
            sub: 'ログイン用のパスワードを変更します',
            onTap: _showPasswordDialog,
          ),
          _settingsRow(
            icon: Icons.logout,
            title: 'ログアウト',
            sub: 'このアカウントからログアウトします',
            danger: true,
            isLast: true,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  /// 設定の1行（デモの .settings-row）
  Widget _settingsRow({
    required IconData icon,
    required String title,
    required String sub,
    required VoidCallback onTap,
    bool danger = false,
    bool isLast = false,
  }) {
    final iconBg = danger ? const Color(0x23E07B7B) : KakkoColors.fieldFill;
    final iconColor = danger ? _danger : KakkoColors.paperText;
    final titleColor = danger ? _danger : KakkoColors.paperText;
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
        decoration: isLast
            ? null
            : const BoxDecoration(
                border: Border(bottom: BorderSide(color: KakkoColors.inkLine)),
              ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(fontSize: 12, color: KakkoColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 14, color: KakkoColors.muted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ナビ付きの枠に、この画面の中身を渡す
    return Navbar(
      selectedIndex: NavIndex.setting,
      // ダーク背景（他ページと統一）
      child: Scaffold(
        backgroundColor: KakkoColors.ink,
        body: LayoutBuilder(
          builder: (context, constraints) {
            // デモ版: 980px以上の広い画面では中身を中央寄せ(max-width 640px)
            final wide = constraints.maxWidth >= 980;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: wide ? 640 : double.infinity,
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 60),
                  children: [
                    _muteSection(),
                    const SizedBox(height: 28),
                    _userSection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
