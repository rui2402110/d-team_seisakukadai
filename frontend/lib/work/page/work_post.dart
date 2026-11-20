import 'package:flutter/material.dart';
 
import 'package:image_picker/image_picker.dart';
 
import '../repository/work_post_repository.dart';
import '../repository/work_repository.dart';
import 'work_post_done.dart';
 
class WorkPostPage extends StatefulWidget {
  const WorkPostPage({super.key});
 
  @override
  State<WorkPostPage> createState() => _WorkPostPageState();
}
 
class _WorkPostPageState extends State<WorkPostPage> {
  // カラー設定
  static const Color bgColor = Color(0xFF2D2016);
  static const Color cardColor = Color(0xFF3A2A1B);
  static const Color orangeColor = Color(0xFFE9782B);
  static const Color mainTextColor = Color(0xFFE9D9C6);
  static const Color subTextColor = Color(0xFFB5A18A);
  static const Color lineColor = Color(0xFF49382A);
 
  // Repository
  final WorkRepository _workRepository = WorkRepository();
 
  // 入力コントローラー
  final TextEditingController _titleController =
      TextEditingController();
  final TextEditingController _bodyController =
      TextEditingController();
  final TextEditingController _detailController =
      TextEditingController();
 
  // 作品種類 1:文字 2:画像 3:動画
  int _workType = 1;
 
  // 選択したファイル名（画面表示用）
  String? _fileName;
 
  // 選択したファイル本体(画像は最大20枚、動画は1本)
  List<XFile> _files = [];
 
  final ImagePicker _picker = ImagePicker();
  final WorkPostRepository _postRepository = WorkPostRepository();
 
  // 投稿処理中(二重送信を防ぐ)
  bool _posting = false;
 
  // Djangoから取得した全作品
  List<Map<String, dynamic>> _allWorks = [];
 
  // 選択した関連作品ID
  final List<int> _relatedWorkIds = [];
 
  // 作品一覧読み込み状態
  bool _isLoadingWorks = false;
 
  @override
  void initState() {
    super.initState();
    _loadAllWorks();
  }
 
  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _detailController.dispose();
    super.dispose();
  }
 
  // メッセージ表示
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: cardColor,
      ),
    );
  }
 
  // Djangoから全作品を取得
  Future<void> _loadAllWorks() async {
    setState(() {
      _isLoadingWorks = true;
    });
 
    try {
      final works = await _workRepository.getAllWorks();
 
      if (!mounted) return;
 
      setState(() {
        _allWorks = works;
        _isLoadingWorks = false;
      });
    } catch (e) {
      if (!mounted) return;
 
      setState(() {
        _isLoadingWorks = false;
      });
 
      _showMessage('作品一覧の取得に失敗しました：$e');
    }
  }
 
  // ファイル選択(画像は複数、動画は1本。動画は長さ・サイズ・形式をここでチェック)
  Future<void> _selectFile() async {
    try {
      if (_workType == 2) {
        final images = await _picker.pickMultiImage();
        if (images.isEmpty) return;
        if (images.length > 20) {
          _showMessage('画像は20枚までです');
          return;
        }
        for (final img in images) {
          if (contentTypeOf(img.name) == null ||
              contentTypeOf(img.name) == 'video/mp4') {
            _showMessage('画像は jpg / png のみ投稿できます');
            return;
          }
        }
        setState(() {
          _files = images;
          _fileName = '${images.length}枚の画像を選択中';
        });
      } else if (_workType == 3) {
        final video = await _picker.pickVideo(source: ImageSource.gallery);
        if (video == null) return;
        final error = await checkVideo(video); // 形式・サイズ・長さ
        if (error != null) {
          _showMessage(error);
          return;
        }
        setState(() {
          _files = [video];
          _fileName = video.name;
        });
      }
    } catch (e) {
      _showMessage('ファイルを選択できませんでした：$e');
    }
  }
 
  // 関連作品追加
  void _addRelatedWork() {
    if (_isLoadingWorks) {
      _showMessage('作品一覧を読み込み中です');
      return;
    }
 
    if (_allWorks.isEmpty) {
      _showMessage('追加できる作品がありません');
      return;
    }
 
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              backgroundColor: cardColor,
              title: const Text(
                '関連作品を追加',
                style: TextStyle(color: mainTextColor),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allWorks.length,
                  itemBuilder: (context, index) {
                    final work = _allWorks[index];
 
                    final int? workId =
                        int.tryParse(work['id'].toString());
 
                    final String title =
                        work['title']?.toString() ?? 'タイトルなし';
 
                    if (workId == null) {
                      return const SizedBox.shrink();
                    }
 
                    final bool selected =
                        _relatedWorkIds.contains(workId);
 
                    return CheckboxListTile(
                      title: Text(
                        title,
                        style: const TextStyle(
                          color: mainTextColor,
                        ),
                      ),
                      value: selected,
                      activeColor: orangeColor,
                      checkColor: bgColor,
                      onChanged: (value) {
                        dialogSetState(() {
                          if (value == true) {
                            if (!_relatedWorkIds.contains(workId)) {
                              _relatedWorkIds.add(workId);
                            }
                          } else {
                            _relatedWorkIds.remove(workId);
                          }
                        });
 
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    '閉じる',
                    style: TextStyle(color: orangeColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
 
  // 本文編集用ツール
  void _insertFormat(String format) {
    final selection = _bodyController.selection;
    final text = _bodyController.text;
 
    if (!selection.isValid) return;
 
    final start = selection.start;
    final end = selection.end;
 
    final selectedText = text.substring(start, end);
 
    String replacement;
 
    switch (format) {
      case 'bold':
        replacement = '**$selectedText**';
        break;
      case 'italic':
        replacement = '*$selectedText*';
        break;
      case 'heading':
        replacement = '## $selectedText';
        break;
      case 'link':
        replacement = '[$selectedText](URL)';
        break;
      default:
        return;
    }
 
    _bodyController.value = TextEditingValue(
      text: text.replaceRange(start, end, replacement),
      selection: TextSelection.collapsed(
        offset: start + replacement.length,
      ),
    );
  }
 
  // 投稿ボタン
  Future<void> _postWork() async {
    if (_posting) return;
 
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage('タイトルを入力してください');
      return;
    }
    if (_workType == 1 && _bodyController.text.trim().isEmpty) {
      _showMessage('本文を入力してください');
      return;
    }
    if (_workType != 1 && _files.isEmpty) {
      _showMessage('ファイルを選択してください');
      return;
    }
 
    setState(() => _posting = true);
    try {
      final detail = _detailController.text.trim();
 
      if (_workType == 1) {
        // 文字作品: S3は使わず、本文をそのまま登録する
        await _postRepository.createWork(
          title: title,
          workType: 1,
          workDetail: detail,
          text: _bodyController.text,
          relationIds: _relatedWorkIds,  
        );
      } else {
        // 画像・動画: ① 署名付きURL取得 → ② S3へ送信 → ③ 登録
        final contentTypes = _files.map((f) => contentTypeOf(f.name)!).toList();
 
        final uploads = await _postRepository.getUploadUrls(
          _workType,
          contentTypes,
        );
 
        final keys = <String>[];
        for (var i = 0; i < _files.length; i++) {
          final bytes = await _files[i].readAsBytes();
          // await _postRepository.putToS3(
          //   uploads[i]['upload_url'] as String,
          //   uploads[i]['content_type'] as String,
          //   bytes,
          // );
          keys.add(uploads[i]['key'] as String);
        }
 
        await _postRepository.createWork(
          title: title,
          workType: _workType,
          workDetail: detail,
          keys: keys,
          relationIds: _relatedWorkIds,
        );
      }
 
      if (!mounted) return;
      // 完了画面へ(投稿画面は履歴から外す)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WorkPostDonePage()),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('投稿できませんでした：$e');
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 戻るボタン
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: subTextColor,
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '作品',
                      style: TextStyle(
                        color: subTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
 
              const SizedBox(height: 24),
 
              const Text(
                '作品投稿',
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
 
              const SizedBox(height: 6),
 
              const Text(
                '文字・画像・動画の作品をアップロードできます',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 13,
                ),
              ),
 
              const SizedBox(height: 24),
 
              // 上部メニュー
              Row(
                children: [
                  _menuButton(
                    Icons.add,
                    '作品投稿',
                    true,
                    () {},
                  ),
                  const SizedBox(width: 10),
                  _menuButton(
                    Icons.grid_view,
                    'マイ作品',
                    false,
                    () {
                      _showMessage('マイ作品画面は別途実装します');
                    },
                  ),
                ],
              ),
 
              const SizedBox(height: 14),
 
              // タイトル入力
              _sectionTitle('タイトル'),
 
              const SizedBox(height: 8),
 
              _textField(
                controller: _titleController,
                hint: '例：灰と星屑',
                maxLines: 1,
              ),
 
              const SizedBox(height: 20),
 
              // 作品の種類
              _sectionTitle('作品の種類'),
 
              const SizedBox(height: 8),
 
              _typeCard(
                type: 1,
                title: '小説・ブログ',
                description: 'HTMLベースのエディタで文章を書けます',
                icon: Icons.article_outlined,
              ),
 
              const SizedBox(height: 8),
 
              _typeCard(
                type: 2,
                title: '漫画・イラスト',
                description: '画像ファイルをアップロードします',
                icon: Icons.image_outlined,
              ),
 
              const SizedBox(height: 8),
 
              _typeCard(
                type: 3,
                title: '動画',
                description: '動画ファイルをアップロードします',
                icon: Icons.videocam_outlined,
              ),
 
              const SizedBox(height: 20),
 
              // 作品種類ごとの入力欄
              if (_workType == 1) ...[
                _sectionTitle('本文'),
 
                const SizedBox(height: 8),
 
                Row(
                  children: [
                    _editorButton(
                      'B',
                      () => _insertFormat('bold'),
                      bold: true,
                    ),
                    const SizedBox(width: 6),
                    _editorButton(
                      'I',
                      () => _insertFormat('italic'),
                      italic: true,
                    ),
                    const SizedBox(width: 6),
                    _editorButton(
                      '見出し',
                      () => _insertFormat('heading'),
                    ),
                    const SizedBox(width: 6),
                    _editorButton(
                      'リンク',
                      () => _insertFormat('link'),
                    ),
                  ],
                ),
 
                const SizedBox(height: 8),
 
                _textField(
                  controller: _bodyController,
                  hint: '本文を入力してください...（ブログのように書いても構いません）',
                  maxLines: 12,
                ),
              ],
 
              if (_workType == 2 || _workType == 3) ...[
                _sectionTitle(
                  _workType == 2 ? '画像ファイル' : '動画ファイル',
                ),
 
                const SizedBox(height: 8),
 
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border.all(color: lineColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _workType == 2
                            ? Icons.image_outlined
                            : Icons.video_library_outlined,
                        color: orangeColor,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _fileName ?? 'ファイルを選択してください',
                        style: const TextStyle(
                          color: mainTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _selectFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('ファイルを選択'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: orangeColor,
                          side: const BorderSide(
                            color: orangeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
 
              const SizedBox(height: 20),
 
              // 概要
              _sectionTitle('概要'),
 
              const SizedBox(height: 8),
 
              _textField(
                controller: _detailController,
                hint: '作品の概要を書きましょう',
                maxLines: 4,
              ),
 
              const SizedBox(height: 24),
 
              // 関連作品
              _sectionTitle('関連作品'),
 
              const SizedBox(height: 8),
 
              OutlinedButton.icon(
                onPressed: _addRelatedWork,
                icon: const Icon(
                  Icons.menu,
                  size: 16,
                ),
                label: const Text('作品を引用して追加'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: mainTextColor,
                  backgroundColor: cardColor,
                  side: const BorderSide(color: lineColor),
                  shape: const StadiumBorder(),
                ),
              ),
 
              if (_isLoadingWorks) ...[
                const SizedBox(height: 12),
                const Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: orangeColor,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '作品一覧を読み込み中...',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
 
              if (_relatedWorkIds.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _relatedWorkIds.map((workId) {
                    final work = _allWorks.firstWhere(
                      (work) =>
                          int.tryParse(work['id'].toString()) ==
                          workId,
                    );
 
                    final title =
                        work['title']?.toString() ?? 'タイトルなし';
 
                    return Chip(
                      label: Text(
                        title,
                        style: const TextStyle(
                          color: mainTextColor,
                        ),
                      ),
                      backgroundColor: cardColor,
                      deleteIconColor: subTextColor,
                      onDeleted: () {
                        setState(() {
                          _relatedWorkIds.remove(workId);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
 
              const SizedBox(height: 24),
 
              // 投稿ボタン
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _posting ? null : _postWork,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF75421F),
                    foregroundColor: bgColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _posting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          '作品を投稿する',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
 
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
 
  // セクションタイトル
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: mainTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }
 
  // テキスト入力欄
  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: mainTextColor,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: subTextColor,
          fontSize: 13,
        ),
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: lineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: orangeColor),
        ),
      ),
    );
  }
 
  // メニューボタン
  Widget _menuButton(
    IconData icon,
    String title,
    bool selected,
    VoidCallback onTap,
  ) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(title),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? bgColor : mainTextColor,
        backgroundColor: selected ? orangeColor : cardColor,
        side: BorderSide(
          color: selected ? orangeColor : lineColor,
        ),
        shape: const StadiumBorder(),
      ),
    );
  }
 
  // 作品種類選択カード
  Widget _typeCard({
    required int type,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final bool selected = _workType == type;
 
    return GestureDetector(
      onTap: () {
        setState(() {
          _workType = type;
          _fileName = null;
          _files = [];
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4A2F1B)
              : bgColor,
          border: Border.all(
            color: selected ? orangeColor : lineColor,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            Radio<int>(
              value: type,
              groupValue: _workType,
              activeColor: orangeColor,
              onChanged: (value) {
                setState(() {
                  _workType = value!;
                  _fileName = null;
          _files = [];
                });
              },
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: mainTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  // 本文編集ボタン
  Widget _editorButton(
    String title,
    VoidCallback onTap, {
    bool bold = false,
    bool italic = false,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(36, 34),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        foregroundColor: mainTextColor,
        backgroundColor: cardColor,
        side: const BorderSide(color: lineColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}