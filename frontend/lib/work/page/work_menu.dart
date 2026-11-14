import 'package:flutter/material.dart';

import '../../component/navbar.dart';
import '../repository/work_repository.dart';
import 'work_detail.dart';

class Work extends StatefulWidget {
  const Work({super.key});

  @override
  State<Work> createState() => _WorkState();
}

class _WorkState extends State<Work> {
  // ==============================
  // 色の設定
  // ==============================

  static const Color bg = Color(0xFF2D2016);
  static const Color sidebar = Color(0xFF241910);
  static const Color card = Color(0xFF3A2A1B);
  static const Color orange = Color(0xFFE9782B);
  static const Color mainText = Color(0xFFE9D9C6);
  static const Color subText = Color(0xFFB5A18A);
  static const Color line = Color(0xFF49382A);

  // 作品カードの色
  static const List<List<Color>> workColors = [
    [
      Color(0xFF8A674C),
      Color(0xFF493426),
    ],
    [
      Color(0xFF667D83),
      Color(0xFF293B42),
    ],
    [
      Color(0xFF88735D),
      Color(0xFF443326),
    ],
  ];

  // ==============================
  // APIから作品データを取得
  // ==============================

  late Future<Map<String, dynamic>> _workMenuFuture;

  @override
  void initState() {
    super.initState();

    // 画面表示時に作品データを取得
    _workMenuFuture = _loadWorkMenu();
  }

  Future<Map<String, dynamic>> _loadWorkMenu() async {
    // Django APIから作品一覧を取得
    // (ログイン確認とIDトークンの取得は WorkRepository の中で行う)
    return WorkRepository().getWorkMenu();
  }

  // ==============================
  // 画面全体
  // ==============================

  @override
  Widget build(BuildContext context) {
    // ナビ付きの枠に、この画面の中身を渡す
    return Navbar(
      selectedIndex: NavIndex.work,
      child: Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            _buildHeader(),

            // 検索欄
            _buildSearch(),

            // 作品投稿・マイ作品
            _buildActionMenu(),

            // カテゴリー
            _buildCategory(),

            // 作品一覧
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _workMenuFuture,

                builder: (context, snapshot) {
                  // 読み込み中
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: orange,
                      ),
                    );
                  }

                  // エラー
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: orange,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '作品の取得に失敗しました\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: mainText,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _workMenuFuture = _loadWorkMenu();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orange,
                              foregroundColor: bg,
                            ),
                            child: const Text('再読み込み'),
                          ),
                        ],
                      ),
                    );
                  }

                  // データが存在しない場合
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text(
                        '作品がありません',
                        style: TextStyle(color: subText),
                      ),
                    );
                  }

                  // APIから取得したデータ
                  final result = snapshot.data!;

                  final followWorks =
                      List<dynamic>.from(result['follow'] ?? []);

                  final recommendWorks =
                      List<dynamic>.from(result['recommend'] ?? []);

                  return ListView(
                    padding: const EdgeInsets.only(
                      bottom: 30,
                    ),
                    children: [
                      // フォロー作品
                      _buildWorkSection(
                        'フォロー作品',
                        followWorks,
                      ),

                      const SizedBox(height: 20),

                      // おすすめ作品
                      _buildWorkSection(
                        'おすすめ作品',
                        recommendWorks,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }

  // ==============================
  // ヘッダー
  // ==============================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.menu_book,
            color: orange,
            size: 28,
          ),
          const SizedBox(width: 10),
          const Text(
            '作品',
            style: TextStyle(
              color: mainText,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.notifications_none,
            color: mainText,
            size: 25,
          ),
        ],
      ),
    );
  }

  // ==============================
  // 検索欄
  // ==============================

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      child: TextField(
        style: const TextStyle(color: mainText),
        decoration: InputDecoration(
          hintText: '作品名やあらすじで検索（デモ）',
          hintStyle: const TextStyle(
            color: subText,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: subText,
          ),
          filled: true,
          fillColor: card,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ==============================
  // マイ作品・作品投稿メニュー
  // ==============================

  Widget _buildActionMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: _actionCard(
              Icons.bookmark_border,
              'マイ作品',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _actionCard(
              Icons.add_circle_outline,
              '作品投稿',
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: mainText,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================
  // カテゴリー
  // ==============================

  Widget _buildCategory() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      child: Row(
        children: [
          _tab('すべて', true),
          _tab('文字', false),
          _tab('画像', false),
          _tab('動画', false),
        ],
      ),
    );
  }

  Widget _tab(String title, bool selected) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 7),
        padding: const EdgeInsets.symmetric(
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected ? orange : card,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: selected ? bg : subText,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ==============================
  // 作品一覧
  // ==============================

  Widget _buildWorkSection(
    String sectionTitle,
    List<dynamic> works,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションタイトル
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Text(
              sectionTitle,
              style: const TextStyle(
                color: mainText,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 作品がない場合
          if (works.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  '作品がありません',
                  style: TextStyle(color: subText),
                ),
              ),
            )

          // 作品がある場合
          else
            // 列数を固定せず、カード1枚の最大幅だけを決める。
            // 画面の幅に合わせて、列数が自動で変わる(広い画面は多く、狭い画面は少なく)
            GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: works.length,
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260, // カード1枚の最大の幅
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 235, // カードの高さ
                  ),

                  // 作品カードを作成
                  itemBuilder: (context, index) {
                    final work =
                        Map<String, dynamic>.from(
                      works[index] as Map,
                    );

                    return GestureDetector(
                      // 作品カードを押したとき
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WorkDetailPage(
                              work: work,
                            ),
                          ),
                        );
                      },

                      // 作品カード
                      child: _WorkCard(
                        title: work['title']
                                ?.toString() ??
                            'タイトルなし',
                        author:
                            '投稿者ID: ${work['user_id'] ?? '不明'}',
                        views: '—',
                        colors: workColors[
                            index % workColors.length],
                      ),
                    );
                  },
            ),
        ],
      ),
    );
  }
}

// ==================================================
// 作品カード
// ==================================================

class _WorkCard extends StatelessWidget {
  final String title;
  final String author;
  final String views;
  final List<Color> colors;

  const _WorkCard({
    required this.title,
    required this.author,
    required this.views,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3A2A1B),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 作品画像部分
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_stories,
                  color: Color(0xFFE9D9C6),
                  size: 38,
                ),
              ),
            ),
          ),

          // 作品情報部分
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    '小説',
                    style: TextStyle(
                      color: Color(0xFFE9782B),
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // 作品タイトル
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE9D9C6),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  // 投稿者
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFB5A18A),
                      fontSize: 9,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 閲覧数
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        color: Color(0xFFB5A18A),
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        views,
                        style: const TextStyle(
                          color: Color(0xFFB5A18A),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}