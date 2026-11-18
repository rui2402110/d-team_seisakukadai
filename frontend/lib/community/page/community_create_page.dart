import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../component/navbar.dart';

/// コミュニティ作成画面。
///
/// onCreate は Django API への保存処理を接続するためのコールバックです。
/// 未指定の場合は入力内容がサーバーに保存されません。
class CommunityCreatePage extends StatefulWidget {
  const CommunityCreatePage({super.key, this.onCreate});

  final Future<void> Function({
    required String name,
    required String target,
    required String detail,
    Uint8List? iconBytes,
    String? iconFileName,
  })? onCreate;

  @override
  State<CommunityCreatePage> createState() => _CommunityCreatePageState();
}

class _CommunityCreatePageState extends State<CommunityCreatePage> {
  static const Color _background = Color(0xFF2B2017);
  static const Color _inputBackground = Color(0xFF382C22);
  static const Color _border = Color(0xFF514235);
  static const Color _muted = Color(0xFFBDA78D);
  static const Color _accent = Color(0xFFE9842B);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _detailController = TextEditingController();
  final _imagePicker = ImagePicker();

  Uint8List? _iconBytes;
  String? _iconFileName;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _iconBytes = bytes;
        _iconFileName = image.name;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('画像を選択できませんでした: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _saving) return;

    if (widget.onCreate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('画面は完成していますが、Djangoへの作成APIはまだ接続されていません。'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onCreate!(
        name: _nameController.text.trim(),
        target: _targetController.text.trim(),
        detail: _detailController.text.trim(),
        iconBytes: _iconBytes,
        iconFileName: _iconFileName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('コミュニティを作成しました')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('コミュニティを作成できませんでした: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(String hint, {bool multiline = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _muted, fontSize: 16),
      filled: true,
      fillColor: _inputBackground,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: multiline ? 19 : 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _fieldLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Navbar(
      selectedIndex: NavIndex.community,
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1340),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('コミュニティ'),
                        style: TextButton.styleFrom(foregroundColor: _muted),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'コミュニティ作成',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        '好きな作品のコミュニティをつくろう',
                        style: TextStyle(color: _muted, fontSize: 16),
                      ),
                      const SizedBox(height: 34),
                      _fieldLabel('コミュニティ名'),
                      TextFormField(
                        controller: _nameController,
                        maxLength: 50,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('例：灰と星屑 感想部').copyWith(
                          counterStyle: const TextStyle(color: _muted),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'コミュニティ名を入力してください'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _fieldLabel('対象作品'),
                      TextFormField(
                        controller: _targetController,
                        maxLength: 100,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('例：灰と星屑').copyWith(
                          counterStyle: const TextStyle(color: _muted),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _fieldLabel('コミュニティ概要'),
                      TextFormField(
                        controller: _detailController,
                        maxLines: 5,
                        minLines: 5,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration(
                          'どんなコミュニティか、簡単に紹介しましょう',
                          multiline: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'URL(https://...)を書くと、コミュニティ詳細画面などでリンクとして利用できます。',
                        style: TextStyle(color: _muted, fontSize: 13),
                      ),
                      const SizedBox(height: 30),
                      _fieldLabel('アイコン設定'),
                      Row(
                        children: [
                          Container(
                            width: 98,
                            height: 98,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFC66A37), Color(0xFF523028)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: _iconBytes != null
                                ? Image.memory(_iconBytes!, fit: BoxFit.cover)
                                : const Icon(Icons.star_border, color: Colors.white, size: 45),
                          ),
                          const SizedBox(width: 24),
                          OutlinedButton(
                            onPressed: _saving ? null : _selectImage,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: _border),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                            child: const Text('画像を選ぶ'),
                          ),
                          if (_iconBytes != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: '画像を取り消す',
                              onPressed: _saving
                                  ? null
                                  : () => setState(() {
                                        _iconBytes = null;
                                        _iconFileName = null;
                                      }),
                              icon: const Icon(Icons.close, color: _muted),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'コミュニティのアイコンにする画像を選んでください。未設定の場合は仮のアイコンが表示されます。',
                        style: TextStyle(color: _muted, fontSize: 13),
                      ),
                      const SizedBox(height: 38),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: _border),
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                            ),
                            child: const Text('キャンセル'),
                          ),
                          const SizedBox(width: 14),
                          ElevatedButton(
                            onPressed: _saving ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    'コミュニティを作成',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
