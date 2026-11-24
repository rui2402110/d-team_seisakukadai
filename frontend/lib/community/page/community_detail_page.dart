import 'package:flutter/material.dart';

import '../../component/navbar.dart';
import '../../core/kakko_theme.dart';
import '../repository/community_repository.dart';

/// コミュニティ詳細画面
/// デモ版 community-detail.html / 画面設計書「コミュニティ詳細」シート準拠の見た目。
/// - ヘッダーはカードではなく直置き（下罫線付き）: アイコン/タイトル+オープンバッジ/メタ/ホスト行/説明/アクション
/// - 未参加: オレンジ「参加する」ボタン
/// - 参加済み: 「お気に入り」トグル + 「コミュニティを脱退する」 + ヒント文
/// - その下に「コミュニティタイムライン」（現状は投稿API未実装のため空状態）
class CommunityDetailPage extends StatefulWidget {
  /// 表示するコミュニティのID
  final int communityId;

  const CommunityDetailPage({super.key, required this.communityId});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  final _repo = CommunityRepository();

  late final Future<Map<String, dynamic>> _detailFuture;

  // 参加/お気に入り状態（現状は画面ローカル。後でAPI接続する）
  bool _joined = false;
  bool _fav = false;

  @override
  void initState() {
    super.initState();
    // UC-25: initState でコミュニティ詳細の取得を開始する
    _detailFuture = _repo.getCommunityDetail(widget.communityId);
  }

  // デモ版のトースト相当
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

  // メンバー数（参加時は+1表示。デモの memberCount に相当）
  int _memberCount(Map<String, dynamic> data) {
    final base = (data['member_count'] as num?)?.toInt() ?? 0;
    return _joined ? base + 1 : base;
  }

  void _join(Map<String, dynamic> data) {
    setState(() => _joined = true);
    _toast('「${data['name']}」に参加しました');
  }

  void _leave(Map<String, dynamic> data) {
    setState(() {
      _joined = false;
      _fav = false;
    });
    _toast('「${data['name']}」を脱退しました');
  }

  void _toggleFav() {
    setState(() => _fav = !_fav);
    _toast(_fav ? 'お気に入りに追加しました。タイムラインにタブが表示されます' : 'お気に入りを解除しました');
  }

  /// "← コミュニティ" breadcrumb（デモの .breadcrumb）
  Widget _breadcrumb() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, size: 16, color: KakkoColors.muted),
        label: const Text(
          'コミュニティ',
          style: TextStyle(
            color: KakkoColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: KakkoColors.muted,
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  /// 「オープン」バッジ（デモの .badge.badge-open: accent-soft地 + accent文字）
  Widget _openBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 3),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0x2EE07B2E), // rgba(224,123,46,0.18)
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'オープン',
        style: TextStyle(
          color: KakkoColors.accent,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// コミュニティアイコン（56px角丸16。画像がなければデフォルトの星グラデ）
  Widget _communityIcon(String iconUrl) {
    final base = BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFE2833C), Color(0xFF7A3A2C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    );
    if (iconUrl.isNotEmpty) {
      return Container(
        width: 56,
        height: 56,
        clipBehavior: Clip.antiAlias,
        decoration: base.copyWith(
          image: DecorationImage(
            image: NetworkImage(iconUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container(
      width: 56,
      height: 56,
      decoration: base,
      alignment: Alignment.center,
      child: const Icon(Icons.star, color: KakkoColors.paperText, size: 26),
    );
  }

  /// ホスト行（デモの .host-row）
  Widget _hostRow(String hostName, String? iconUrl) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: KakkoColors.inkLine),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'ホスト',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.04,
              color: KakkoColors.muted,
            ),
          ),
        ),
        const SizedBox(width: 9),
        CircleAvatar(
          radius: 20,
          backgroundImage: iconUrl != null ? NetworkImage(iconUrl!) : null,
        ),
        const SizedBox(width: 6),
        Text(
          hostName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: KakkoColors.paperText,
          ),
        ),
      ],
    );
  }

  /// 参加ボタン（デモの .join-btn: accent塗りつぶしピル）
  Widget _joinButton(Map<String, dynamic> data) {
    return ElevatedButton(
      onPressed: () => _join(data),
      style: ElevatedButton.styleFrom(
        backgroundColor: KakkoColors.accent,
        foregroundColor: KakkoColors.ink,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      child: const Text('参加する'),
    );
  }

  /// お気に入りトグル（デモの .fav-toggle。active時はaccent-soft地+accent文字）
  Widget _favToggle() {
    final active = _fav;
    return OutlinedButton.icon(
      onPressed: _toggleFav,
      icon: Icon(
        active ? Icons.star : Icons.star_outline,
        size: 15,
        color: active ? KakkoColors.accent : KakkoColors.paperText,
      ),
      label: Text(
        active ? 'お気に入り済み' : 'お気に入り',
        style: TextStyle(
          color: active ? KakkoColors.accent : KakkoColors.paperText,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? const Color(0x2EE07B2E) : null,
        side: BorderSide(
          color: active ? Colors.transparent : KakkoColors.inkLine,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// 脱退ボタン（デモの .leave-btn: アウトライン・muted文字）
  Widget _leaveButton(Map<String, dynamic> data) {
    return OutlinedButton(
      onPressed: () => _leave(data),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: KakkoColors.inkLine),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Text(
        'コミュニティを脱退する',
        style: TextStyle(
          color: KakkoColors.muted,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// ヘッダー（デモの .community-header: 直置き＋下罫線）
  Widget _header(Map<String, dynamic> data) {
    final name = data['name']?.toString() ?? '';
    final target = data['target']?.toString() ?? '';
    final detail = data['detail']?.toString() ?? '';
    final iconUrl = data['icon_url']?.toString() ?? '';
    final createdAt = data['created_at']?.toString() ?? '';
    final host = (data['host'] as Map?)?.cast<String, dynamic>();
    final hostName = host?['name']?.toString() ?? '';
    final hostUrl = host?['icon_url']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 26),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: KakkoColors.inkLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // アイコン
          _communityIcon(iconUrl),
          const SizedBox(height: 14),
          // タイトル + オープンバッジ
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: KakkoColors.paperText,
                ),
              ),
              _openBadge(),
            ],
          ),
          const SizedBox(height: 6),
          // メタ: 『作品』 ・ 人数 ・ 作成日
          Text(
            '『$target』 ・ ${_memberCount(data)}人 ・ $createdAt 作成',
            style: TextStyle(fontSize: 13, color: KakkoColors.muted),
          ),
          const SizedBox(height: 12),
          // ホスト行
          _hostRow(hostName, hostUrl),
          const SizedBox(height: 14),
          // 説明文
          if (detail.isNotEmpty) ...[
            Text(
              detail,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.7,
                color: KakkoColors.paperText,
              ),
            ),
            const SizedBox(height: 18),
          ],
          // アクション
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _joined
                ? [
                    _favToggle(),
                    _leaveButton(data),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'お気に入りにすると、タイムライン画面にこのコミュニティのタブが表示されます。',
                          style: TextStyle(
                            fontSize: 12,
                            color: KakkoColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ]
                : [_joinButton(data)],
          ),
        ],
      ),
    );
  }

  /// 「コミュニティタイムライン」見出し（デモの .result-heading.section-heading）
  Widget _timelineHeading() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 2),
      child: Text(
        'コミュニティタイムライン',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.05,
          color: KakkoColors.muted,
        ),
      ),
    );
  }

  /// タイムライン空状態（デモの .detail-empty。現状は投稿API未実装）
  Widget _timelineEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
      child: Center(
        child: Text(
          'まだ投稿がありません',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.7,
            color: KakkoColors.muted,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navbar(
      selectedIndex: NavIndex.community,
      child: Scaffold(
        backgroundColor: KakkoColors.ink, // ダーク背景（他ページと統一）
        body: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _detailFuture,
            builder: (context, snapshot) {
              // 読み込み中
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(color: KakkoColors.accent),
                );
              }
              // エラー（UC-25: 見つからない場合の表示）
              if (snapshot.hasError) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(22, 6, 22, 60),
                  children: [
                    _breadcrumb(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 10,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'コミュニティが見つかりませんでした。',
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.7,
                                color: KakkoColors.muted,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'コミュニティ一覧へ戻る',
                                style: TextStyle(
                                  color: KakkoColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              final data = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 60),
                children: [
                  _breadcrumb(),
                  _header(data),
                  _timelineHeading(),
                  _timelineEmpty(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
