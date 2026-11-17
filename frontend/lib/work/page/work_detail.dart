import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../component/navbar.dart';
import '../../core/kakko_theme.dart';
import '../repository/work_repository.dart';

class WorkDetailPage extends StatefulWidget {
  // 作品一覧画面から受け取る作品情報
  final Map<String, dynamic> work;

  const WorkDetailPage({
    super.key,
    required this.work,
  });

  @override
  State<WorkDetailPage> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  // 基本の色は core/kakko_theme.dart を使う。
  // 区切り線の色だけ、この画面専用
  static const Color line = Color(0xFF49382A);

  // Djangoから取得する作品情報
  Map<String, dynamic>? _detailData;

  // API通信
  late Future<Map<String, dynamic>> _detailFuture;

  // いいね・フォロー状態
  bool isLiked = false;
  bool isFollowing = false;

  // いいね数
  int likeCount = 0;

  // コメント入力欄
  final TextEditingController _commentController =
      TextEditingController();

  // コメントのサンプルデータ
  final List<Map<String, String>> comments = [
    {
      'name': 'りく',
      'time': '2時間前',
      'text': 'このシーン、伏線でしたね…！鳥肌立ちました。',
      'initial': 'り',
    },
    {
      'name': 'ゆき',
      'time': '3分前',
      'text': '何度読み返しても泣ける。',
      'initial': 'ゆ',
    },
  ];

  @override
  void initState() {
    super.initState();

    // 画面表示時にDjangoから作品情報を取得
    _detailFuture = _loadWorkDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Djangoから作品詳細を取得
  // (ログイン確認・IDトークン取得・通信は WorkRepository の中で行う)
  Future<Map<String, dynamic>> _loadWorkDetail() async {
    // 一覧画面から作品IDを取得
    final workId = widget.work['id'] ?? widget.work['pk'];

    if (workId == null) {
      throw ApiException('作品IDがありません');
    }

    final data = await WorkRepository().getWorkDetail(workId);

    // いいね数を取得
    likeCount = (data['likecount'] as num?)?.toInt() ?? 0;

    // 取得したデータを保存
    _detailData = data;

    return data;
  }

  // Djangoから取得したfields
  Map<String, dynamic> get _fields {
    final fields = _detailData?['fields'];

    if (fields is Map) {
      return Map<String, dynamic>.from(fields);
    }

    return widget.work;
  }

  // 作品タイトル
  String get title =>
      _fields['title']?.toString() ?? 'タイトルなし';

  // 投稿者
  String get author =>
      _fields['user']?.toString() ??
      _fields['user_name']?.toString() ??
      '投稿者';

  // 作品説明
  String get detail =>
      _fields['work_detail']?.toString() ?? '';

  // 作品タイプ
  int get workType =>
      (_fields['work_type'] as num?)?.toInt() ??
      int.tryParse(_fields['work_type']?.toString() ?? '') ??
      0;

  // ジャンル名
  String get genre {
    switch (workType) {
      case 1:
        return '小説';
      case 2:
        return '画像';
      case 3:
        return '動画';
      default:
        return '作品';
    }
  }

  // 作品本文・画像・動画情報
  dynamic get mainContent => _detailData?['Main'];

  // 関連作品
  List<Map<String, dynamic>> get relatedWorks {
    final data = _detailData?['relation'];

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // いいねボタン
  // ※現在は画面内だけの変更。Djangoへの保存処理は未接続。
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  // フォローボタン
  // ※現在は画面内だけの変更。Djangoへの保存処理は未接続。
  void toggleFollow() {
    setState(() {
      isFollowing = !isFollowing;
    });
  }

  // コメント投稿
  // ※現在は画面内だけの変更。Djangoへの保存処理は未接続。
  void addComment() {
    final text = _commentController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      comments.insert(0, {
        'name': 'あなた',
        'time': 'たった今',
        'text': text,
        'initial': 'あ',
      });

      _commentController.clear();
    });

    FocusScope.of(context).unfocus();
  }

  // 画面表示
  @override
  Widget build(BuildContext context) {
    return Navbar(
      selectedIndex: NavIndex.work,
      child: Scaffold(
      backgroundColor: KakkoColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _detailFuture,
                builder: (context, snapshot) {
                  // 読み込み中
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: KakkoColors.accent,
                      ),
                    );
                  }

                  // エラー
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: KakkoColors.accent,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '作品情報の取得に失敗しました。\n'
                              '${snapshot.error}',
                              style: const TextStyle(
                                color: KakkoColors.paperText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _detailFuture = _loadWorkDetail();
                                });
                              },
                              child: const Text('再読み込み'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // 取得成功
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildWorkInfo(),

                        const SizedBox(height: 24),

                        _buildWorkContent(),

                        const SizedBox(height: 32),

                        _buildRelatedWorks(),

                        const SizedBox(height: 32),

                        _buildComments(),

                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }

  // ヘッダー
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back,
              color: KakkoColors.muted,
              size: 17,
            ),
            SizedBox(width: 5),
            Text(
              '作品',
              style: TextStyle(
                color: KakkoColors.muted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 作品情報
  Widget _buildWorkInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 作品アイコン
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [
                KakkoColors.accent,
                Color(0xFF713A2C),
              ],
            ),
          ),
          child: const Icon(
            Icons.star_border,
            color: KakkoColors.paperText,
            size: 30,
          ),
        ),

        const SizedBox(height: 18),

        // タイトル・ジャンル
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: KakkoColors.paperText,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            _genreLabel(genre),
          ],
        ),

        const SizedBox(height: 14),

        // 投稿者・フォロー
        Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: KakkoColors.accent,
              child: Icon(
                Icons.person,
                color: KakkoColors.ink,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Text(
                author,
                style: const TextStyle(
                  color: KakkoColors.paperText,
                  fontSize: 14,
                ),
              ),
            ),

            OutlinedButton(
              onPressed: toggleFollow,
              style: OutlinedButton.styleFrom(
                foregroundColor: KakkoColors.paperText,
                side: const BorderSide(color: line),
                shape: const StadiumBorder(),
              ),
              child: Text(
                isFollowing ? 'フォロー中' : 'フォロー',
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 投稿日
        Text(
          '投稿日: ${_fields['created_at'] ?? '不明'}',
          style: const TextStyle(
            color: KakkoColors.muted,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 16),

        // いいねボタン
        OutlinedButton.icon(
          onPressed: toggleLike,
          icon: Icon(
            isLiked
                ? Icons.favorite
                : Icons.favorite_border,
            color: isLiked ? KakkoColors.accent : KakkoColors.paperText,
            size: 17,
          ),
          label: Text(
            likeCount.toString(),
            style: const TextStyle(
              color: KakkoColors.paperText,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: KakkoColors.inkSoft,
            side: const BorderSide(color: line),
            shape: const StadiumBorder(),
          ),
        ),

        const SizedBox(height: 20),
        const Divider(color: line),
      ],
    );
  }

  // ジャンル表示
  Widget _genreLabel(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: KakkoColors.inkSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: KakkoColors.muted,
          fontSize: 11,
        ),
      ),
    );
  }

  // 作品本文
  Widget _buildWorkContent() {
    final content = mainContent;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '作品内容',
            style: TextStyle(
              color: KakkoColors.muted,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // 作品説明
          if (detail.isNotEmpty)
            Text(
              detail,
              style: const TextStyle(
                color: KakkoColors.paperText,
                fontSize: 15,
                height: 2.1,
              ),
            ),

          if (detail.isEmpty)
            const Text(
              '作品説明は登録されていません。',
              style: TextStyle(
                color: KakkoColors.muted,
                fontSize: 14,
              ),
            ),

          const SizedBox(height: 16),

          // 文字作品
          if (workType == 1)
            Text(
              content?.toString().isNotEmpty == true
                  ? content.toString()
                  : '本文はまだ登録されていません。',
              style: const TextStyle(
                color: KakkoColors.paperText,
                fontSize: 15,
                height: 2.1,
              ),
            ),

          // 画像作品
          if (workType == 2)
            _buildImages(content),

          // 動画作品
          if (workType == 3)
            _buildMovie(content),
        ],
      ),
    );
  }

  // 画像作品の表示
  // workDetailView は Main に1件分の値(URL文字列)を返す。
  // リスト([{main: URL}, ...] や [URL, ...])で返ってきても表示できるようにしている
  Widget _buildImages(dynamic content) {
    final List<String> urls = [];

    if (content is List) {
      for (final item in content) {
        final url = item is Map
            ? item['main']?.toString()
            : item?.toString();
        if (url != null && url.isNotEmpty) urls.add(url);
      }
    } else if (content is Map) {
      final url = content['main']?.toString();
      if (url != null && url.isNotEmpty) urls.add(url);
    } else if (content != null && content.toString().isNotEmpty) {
      urls.add(content.toString());
    }

    if (urls.isEmpty) {
      return const Text(
        '画像は登録されていません。',
        style: TextStyle(color: KakkoColors.muted),
      );
    }

    return Column(
      children: urls.map<Widget>((imageUrl) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '画像を表示できません。',
                    style: TextStyle(color: KakkoColors.muted),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  // 動画作品の表示
  Widget _buildMovie(dynamic content) {
    final movieUrl = content?.toString() ?? '';

    if (movieUrl.isEmpty) {
      return const Text(
        '動画は登録されていません。',
        style: TextStyle(color: KakkoColors.muted),
      );
    }

    // URLを表示するところまで対応。
    // 実際の動画再生には動画プレイヤーの追加が必要。
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KakkoColors.inkSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SelectableText(
        movieUrl,
        style: const TextStyle(
          color: KakkoColors.paperText,
          fontSize: 13,
        ),
      ),
    );
  }

  // 関連作品
  Widget _buildRelatedWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '関連作品',
          style: TextStyle(
            color: KakkoColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        if (relatedWorks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '関連作品はありません。',
              style: TextStyle(color: KakkoColors.muted),
            ),
          ),

        ...relatedWorks.map((work) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: line),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: KakkoColors.inkSoft,
                  ),
                  child: const Icon(
                    Icons.star_border,
                    color: KakkoColors.paperText,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        work['title']?.toString() ??
                            'タイトルなし',
                        style: const TextStyle(
                          color: KakkoColors.paperText,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        work['user']?.toString() ?? '投稿者',
                        style: const TextStyle(
                          color: KakkoColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // コメント欄
  // ※コメントは現在Djangoとは接続していません。
  Widget _buildComments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'コメント',
          style: TextStyle(
            color: KakkoColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        // コメント入力欄
        Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: KakkoColors.accent,
              child: Text(
                'あ',
                style: TextStyle(color: KakkoColors.ink),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: _commentController,
                style: const TextStyle(
                  color: KakkoColors.paperText,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '感想を書く',
                  hintStyle: const TextStyle(color: KakkoColors.muted),
                  filled: true,
                  fillColor: KakkoColors.inkSoft,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: KakkoColors.accent),
                  ),
                ),
                onSubmitted: (_) => addComment(),
              ),
            ),

            const SizedBox(width: 10),

            ElevatedButton(
              onPressed: addComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: KakkoColors.accent,
                foregroundColor: KakkoColors.ink,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
              ),
              child: const Text('送信'),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // コメント一覧
        ...comments.map((comment) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: line),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      comment['name'] == 'りく'
                          ? const Color(0xFF7794C4)
                          : KakkoColors.accent,
                  child: Text(
                    comment['initial'] ?? '',
                    style: const TextStyle(
                      color: KakkoColors.ink,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment['name'] ?? '',
                            style: const TextStyle(
                              color: KakkoColors.paperText,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            comment['time'] ?? '',
                            style: const TextStyle(
                              color: KakkoColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      Text(
                        comment['text'] ?? '',
                        style: const TextStyle(
                          color: KakkoColors.paperText,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
