import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  // デモ画面に合わせた色
  static const Color bg = Color(0xFF2D2016);
  static const Color card = Color(0xFF3A2A1B);
  static const Color orange = Color(0xFFE9782B);
  static const Color mainText = Color(0xFFE9D9C6);
  static const Color subText = Color(0xFFB5A18A);
  static const Color line = Color(0xFF49382A);

  // いいね・フォロー状態
  bool isLiked = false;
  bool isFollowing = false;

  int likeCount = 2310;

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
      'text': '何度読み返しても泣ける。最終話、本当にありがとうございました。',
      'initial': 'ゆ',
    },
  ];

  // 関連作品のサンプルデータ
  final List<Map<String, String>> relatedWorks = [
    {
      'title': 'サイレント・チャプター',
      'author': '海野',
      'views': '5.1万',
    },
    {
      'title': '花布の記憶',
      'author': 'しおり',
      'views': '2.2万',
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // 作品情報を取得
  String get title =>
      widget.work['title']?.toString() ?? 'タイトルなし';

  String get author =>
      widget.work['user_name']?.toString() ??
      widget.work['user_id']?.toString() ??
      '投稿者';

  String get detail =>
      widget.work['work_detail']?.toString() ?? '';

  String get genre {
    final type = widget.work['work_type'];

    switch (type.toString()) {
      case '1':
        return '小説';
      case '2':
        return '画像';
      case '3':
        return '動画';
      default:
        return '作品';
    }
  }

  // いいねボタン
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  // フォローボタン
  void toggleFollow() {
    setState(() {
      isFollowing = !isFollowing;
    });
  }

  // コメント投稿
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // 上部の戻るボタン
            _buildHeader(),

            // 画面本体
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 作品情報
                    _buildWorkInfo(),

                    const SizedBox(height: 24),

                    // 作品本文
                    _buildWorkContent(),

                    const SizedBox(height: 32),

                    // 関連作品
                    _buildRelatedWorks(),

                    const SizedBox(height: 32),

                    // コメント
                    _buildComments(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              color: subText,
              size: 17,
            ),
            SizedBox(width: 5),
            Text(
              '作品',
              style: TextStyle(
                color: subText,
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
                orange,
                Color(0xFF713A2C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.star_border,
            color: mainText,
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
                color: mainText,
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
            CircleAvatar(
              radius: 18,
              backgroundColor: orange,
              child: const Icon(
                Icons.person,
                color: bg,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                author,
                style: const TextStyle(
                  color: mainText,
                  fontSize: 14,
                ),
              ),
            ),
            OutlinedButton(
              onPressed: toggleFollow,
              style: OutlinedButton.styleFrom(
                foregroundColor: mainText,
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

        // 閲覧数・コメント数
        const Text(
          '閲覧 8.4万 ・ コメント 3',
          style: TextStyle(
            color: subText,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 16),

        // いいねボタン
        OutlinedButton.icon(
          onPressed: toggleLike,
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? orange : mainText,
            size: 17,
          ),
          label: Text(
            likeCount.toString(),
            style: const TextStyle(
              color: mainText,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: card,
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
        color: card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: subText,
          fontSize: 11,
        ),
      ),
    );
  }

  // 作品本文
  Widget _buildWorkContent() {
    return SizedBox(
      width: double.infinity,
      child: Text(
        detail.isEmpty ? '作品本文はまだ登録されていません。' : detail,
        style: const TextStyle(
          color: mainText,
          fontSize: 15,
          height: 2.1,
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
            color: subText,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

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
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF78805A),
                        Color(0xFF473D24),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.star_border,
                    color: mainText,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        work['title']!,
                        style: const TextStyle(
                          color: mainText,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${work['author']} ・ 閲覧 ${work['views']}',
                        style: const TextStyle(
                          color: subText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('関連作品の画面遷移は未接続です。'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: bg,
                    shape: const StadiumBorder(),
                    minimumSize: const Size(52, 34),
                  ),
                  child: const Text(
                    '見る',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
  Widget _buildComments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'コメント',
          style: TextStyle(
            color: subText,
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
              backgroundColor: orange,
              child: Text(
                'あ',
                style: TextStyle(color: bg),
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: _commentController,
                style: const TextStyle(
                  color: mainText,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '感想を書く',
                  hintStyle: const TextStyle(color: subText),
                  filled: true,
                  fillColor: card,
                  contentPadding: const EdgeInsets.symmetric(
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
                    borderSide: const BorderSide(color: orange),
                  ),
                ),
                onSubmitted: (_) => addComment(),
              ),
            ),

            const SizedBox(width: 10),

            ElevatedButton(
              onPressed: addComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: bg,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          : orange,
                  child: Text(
                    comment['initial']!,
                    style: const TextStyle(
                      color: bg,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment['name']!,
                            style: const TextStyle(
                              color: mainText,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            comment['time']!,
                            style: const TextStyle(
                              color: subText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        comment['text']!,
                        style: const TextStyle(
                          color: mainText,
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
