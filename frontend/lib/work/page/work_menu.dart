
import 'package:flutter/material.dart';

import '../../component/navbar.dart';
import '../../core/kakko_theme.dart';
import '../repository/work_repository.dart';
import 'work_detail.dart';
import 'work_post.dart';

class WorkMenuPage extends StatefulWidget {
  const WorkMenuPage({super.key});

  @override
  State<WorkMenuPage> createState() => _WorkState();
}

class _WorkState extends State<WorkMenuPage> {
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

  // 検索用コントローラー
  final TextEditingController _searchController =
      TextEditingController();

  // 選択中のカテゴリー
  // null = すべて
  // 1 = 文字、2 = 画像、3 = 動画
  int? _selectedType;

  // API取得結果
  late Future<Map<String, dynamic>> _workMenuFuture;

  @override
  void initState() {
    super.initState();
    _workMenuFuture = _loadWorkMenu();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==============================
  // APIから作品データを取得
  // ==============================

  Future<Map<String, dynamic>> _loadWorkMenu() async {
    return WorkRepository().getWorkMenu();
  }

  // 再読み込み
  void _reloadWorkMenu() {
    setState(() {
      _workMenuFuture = _loadWorkMenu();
    });
  }

  // ==============================
  // 画面全体
  // ==============================

  @override
  Widget build(BuildContext context) {
    return Navbar(
      selectedIndex: NavIndex.work,
      child: Scaffold(
        backgroundColor: KakkoColors.ink,
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
                          color: KakkoColors.accent,
                        ),
                      );
                    }

                    // エラー
                    if (snapshot.hasError) {
                      return _buildError(snapshot.error);
                    }

                    // データが存在しない場合
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(
                          '作品がありません',
                          style: TextStyle(
                            color: KakkoColors.muted,
                          ),
                        ),
                      );
                    }

                    final result = snapshot.data!;

                    final followWorks = _convertWorks(
                      result['follow'],
                    );

                    final recommendWorks = _convertWorks(
                      result['recommend'],
                    );

                    // 検索・カテゴリーで絞り込み
                    final filteredFollow =
                        _filterWorks(followWorks);

                    final filteredRecommend =
                        _filterWorks(recommendWorks);

                    return ListView(
                      padding: const EdgeInsets.only(
                        bottom: 30,
                      ),
                      children: [
                        // フォロー作品
                        _buildWorkSection(
                          'フォロー作品',
                          filteredFollow,
                        ),

                        const SizedBox(height: 20),

                        // おすすめ作品
                        _buildWorkSection(
                          'おすすめ作品',
                          filteredRecommend,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // APIデータ変換
  // ==============================

  List<Map<String, dynamic>> _convertWorks(dynamic data) {
    if (data is! List) {
      return [];
    }

    return data
        .where((item) => item is Map)
        .map(
          (item) => Map<String, dynamic>.from(item as Map),
        )
        .toList();
  }

  // ==============================
  // 作品の検索・絞り込み
  // ==============================

  List<Map<String, dynamic>> _filterWorks(
    List<Map<String, dynamic>> works,
  ) {
    final keyword = _searchController.text.trim().toLowerCase();

    return works.where((work) {
      // カテゴリー判定
      final workType = int.tryParse(
        work['work_type']?.toString() ?? '',
      );

      if (_selectedType != null &&
          workType != _selectedType) {
        return false;
      }

      // タイトル・概要で検索
      if (keyword.isNotEmpty) {
        final title =
            work['title']?.toString().toLowerCase() ?? '';

        final detail =
            work['work_detail']?.toString().toLowerCase() ?? '';

        if (!title.contains(keyword) &&
            !detail.contains(keyword)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // ==============================
  // エラー表示
  // ==============================

  Widget _buildError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: KakkoColors.accent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              '作品の取得に失敗しました\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: KakkoColors.paperText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _reloadWorkMenu,
              style: ElevatedButton.styleFrom(
                backgroundColor: KakkoColors.accent,
                foregroundColor: KakkoColors.ink,
              ),
              child: const Text('再読み込み'),
            ),
          ],
        ),
      ),
    );
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
            color: KakkoColors.accent,
            size: 28,
          ),
          const SizedBox(width: 10),
          const Text(
            '作品',
            style: TextStyle(
              color: KakkoColors.paperText,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.notifications_none,
            color: KakkoColors.paperText,
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
        controller: _searchController,
        onChanged: (_) {
          setState(() {});
        },
        style: const TextStyle(
          color: KakkoColors.paperText,
        ),
        decoration: InputDecoration(
          hintText: '作品名やあらすじで検索',
          hintStyle: const TextStyle(
            color: KakkoColors.muted,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: KakkoColors.muted,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
            icon: const Icon(
              Icons.close,
              color: KakkoColors.muted,
            ),
          ),
          filled: true,
          fillColor: KakkoColors.inkSoft,
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
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('マイ作品画面は別途実装します'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _actionCard(
              Icons.add_circle_outline,
              '作品投稿',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const WorkPostPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: KakkoColors.inkSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: KakkoColors.accent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: KakkoColors.paperText,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
          _tab('すべて', null),
          _tab('文字', 1),
          _tab('画像', 2),
          _tab('動画', 3),
        ],
      ),
    );
  }

  Widget _tab(String title, int? type) {
    final selected = _selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 7),
          padding: const EdgeInsets.symmetric(
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: selected
                ? KakkoColors.accent
                : KakkoColors.inkSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? KakkoColors.ink
                  : KakkoColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
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
    List<Map<String, dynamic>> works,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Text(
              sectionTitle,
              style: const TextStyle(
                color: KakkoColors.paperText,
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
                  style: TextStyle(
                    color: KakkoColors.muted,
                  ),
                ),
              ),
            )

          // 作品がある場合
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: works.length,
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                mainAxisExtent: 235,
              ),
              itemBuilder: (context, index) {
                final work = works[index];

                final workType = int.tryParse(
                      work['work_type']?.toString() ?? '',
                    ) ??
                    1;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkDetailPage(
                          work: work,
                        ),
                      ),
                    );
                  },
                  child: _WorkCard(
                    title: work['title']?.toString() ??
                        'タイトルなし',
                    author:
                        '投稿者ID: ${work['user_id'] ?? '不明'}',
                    views: '—',
                    workType: workType,
                    colors:
                        workColors[index % workColors.length],
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
  final int workType;
  final List<Color> colors;

  const _WorkCard({
    required this.title,
    required this.author,
    required this.views,
    required this.workType,
    required this.colors,
  });

  String get typeName {
    switch (workType) {
      case 1:
        return '小説・ブログ';
      case 2:
        return '漫画・イラスト';
      case 3:
        return '動画';
      default:
        return '作品';
    }
  }

  IconData get typeIcon {
    switch (workType) {
      case 1:
        return Icons.auto_stories;
      case 2:
        return Icons.image_outlined;
      case 3:
        return Icons.play_circle_outline;
      default:
        return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KakkoColors.inkSoft,
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
              child: Center(
                child: Icon(
                  typeIcon,
                  color: KakkoColors.paperText,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeName,
                    style: const TextStyle(
                      color: KakkoColors.accent,
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
                      color: KakkoColors.paperText,
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
                      color: KakkoColors.muted,
                      fontSize: 9,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 閲覧数
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        color: KakkoColors.muted,
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        views,
                        style: const TextStyle(
                          color: KakkoColors.muted,
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
