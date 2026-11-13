
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repository/work_repository.dart';

// ==========================================
// 作品一覧画面
// ==========================================
class Work extends StatefulWidget {
  const Work({super.key});

  @override
  State<Work> createState() => _WorkState();
}

// ==========================================
// 画面の状態を管理するクラス
// ==========================================
class _WorkState extends State<Work> {

  // Djangoから取得した作品情報を保持する変数
  late Future<Map<String, dynamic>> _workMenuFuture;

  // 画面の色
  static const Color bg = Color(0xFF2D2016);
  static const Color sidebar = Color(0xFF302116);
  static const Color card = Color(0xFF3A2A1B);
  static const Color orange = Color(0xFFE9782B);
  static const Color mainText = Color(0xFFE9D9C6);
  static const Color subText = Color(0xFFB5A18A);

  // 作品カードの背景色
  static const List<List<Color>> workColors = [
    [Color(0xFFD87939), Color(0xFF74392B)],
    [Color(0xFF858B5C), Color(0xFF49371F)],
    [Color(0xFF607FAB), Color(0xFF29384E)],
  ];

  // 画面が最初に作られたときに実行する
  @override
  void initState() {
    super.initState();

    // Djangoから作品情報を取得する
    _workMenuFuture = _loadWorkMenu();
  }

  // ==========================================
  // Djangoから作品情報を取得
  // ==========================================
  Future<Map<String, dynamic>> _loadWorkMenu() async {

    // Firebaseにログインしているユーザーを取得
    final user = FirebaseAuth.instance.currentUser;

    // ログインしていない場合はエラー
    if (user == null) {
      throw Exception('ログインしていません');
    }

    // FirebaseのIDトークンを取得
    final idToken = await user.getIdToken();

    if (idToken == null) {
      throw Exception('認証トークンを取得できませんでした');
    }

    // Djangoと通信するRepositoryを作成
    final repository = WorkRepository();

    // Djangoから作品情報を取得
    final result = await repository.getWorkMenu(idToken);

    return result;
  }

  // ==========================================
  // 画面の表示
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      body: Column(
        children: [

          // ヘッダー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 17, 16, 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF493729),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '作品',
                  style: TextStyle(
                    color: mainText,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '好きな作品を投稿したり、見つけたりしよう',
                  style: TextStyle(
                    color: subText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // メインコンテンツ
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 検索欄
                  Container(
                    height: 33,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B2B1B),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF594531),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Icon(
                          Icons.search,
                          size: 15,
                          color: subText,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '作品名やあらすじで検索（デモ）',
                          style: TextStyle(
                            color: subText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 11),

                  // マイ作品・作品投稿
                  Row(
                    children: [
                      Expanded(
                        child: _actionCard(
                          Icons.grid_view,
                          'マイ作品',
                          '投稿した作品を管理する',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionCard(
                          Icons.upload,
                          '作品投稿',
                          '新しい作品を投稿する',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // カテゴリ
                  Row(
                    children: [
                      _tab('すべて', true),
                      _tab('文字', false),
                      _tab('画像', false),
                      _tab('動画', false),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ==================================
                  // Djangoから取得した作品を表示
                  // ==================================
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

                        // エラーが発生した場合
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: orange,
                                  size: 35,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '作品の取得に失敗しました',
                                  style: TextStyle(
                                    color: mainText,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${snapshot.error}',
                                  style: TextStyle(
                                    color: subText,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _workMenuFuture = _loadWorkMenu();
                                    });
                                  },
                                  child: const Text('再読み込み'),
                                ),
                              ],
                            ),
                          );
                        }

                        // 取得したデータが存在しない場合
                        if (!snapshot.hasData) {
                          return Center(
                            child: Text(
                              '作品データがありません',
                              style: TextStyle(color: subText),
                            ),
                          );
                        }

                        // Djangoから取得したデータ
                        final result = snapshot.data!;

                        // フォロー作品
                        final followWorks =
                            List<dynamic>.from(
                              result['follow'] ?? [],
                            );

                        // おすすめ作品
                        final recommendWorks =
                            List<dynamic>.from(
                              result['recommend'] ?? [],
                            );

                        // 作品一覧を表示
                        return ListView(
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
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 作品一覧のセクションを作成
  // ==========================================
  Widget _buildWorkSection(
    String sectionTitle,
    List<dynamic> works,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // セクションのタイトル
        Text(
          sectionTitle,
          style: const TextStyle(
            color: mainText,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // 作品がない場合
        if (works.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: Text(
                '作品がありません',
                style: TextStyle(
                  color: subText,
                  fontSize: 11,
                ),
              ),
            ),
          )

        // 作品がある場合
        else
          LayoutBuilder(
            builder: (context, constraints) {

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                // 3列で表示
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                  childAspectRatio:
                      constraints.maxWidth / 3 / 235,
                ),

                itemCount: works.length,

                itemBuilder: (context, index) {

                  // 作品データを取得
                  final work = works[index];

                  // 作品タイトル
                  final title =
                      work['title']?.toString() ?? 'タイトルなし';

                  // 投稿者ID
                  // 現在のAPIではユーザー名ではなくIDを表示
                  final author =
                      '投稿者ID: ${work['user_id'] ?? '不明'}';

                  // 閲覧数はAPIにないため仮表示
                  const views = '—';

                  // カードの色を順番に変更
                  final colors =
                      workColors[index % workColors.length];

                  return _WorkCard(
                    title: title,
                    author: author,
                    views: views,
                    colors: colors,
                  );
                },
              );
            },
          ),
      ],
    );
  }

  // ==========================================
  // サイドバーのメニュー
  // ==========================================
  static Widget _menu(
    IconData icon,
    String title, {
    bool selected = false,
    bool notification = false,
  }) {
    return Container(
      height: 31,
      margin: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF50321B)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 13,
                color: selected ? orange : subText,
              ),
              if (notification)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: selected ? orange : subText,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // マイ作品・作品投稿カード
  // ==========================================
  static Widget _actionCard(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF554331),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF58371D),
            child: Icon(
              icon,
              size: 13,
              color: orange,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: mainText,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subText,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: subText,
            size: 15,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // カテゴリタブ
  // ==========================================
  static Widget _tab(String title, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: selected ? orange : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? mainText : subText,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ==========================================
// 作品カード
// ==========================================
class _WorkCard extends StatelessWidget {

  // 作品タイトル
  final String title;

  // 投稿者
  final String author;

  // 閲覧数
  final String views;

  // 背景色
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
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFF554331),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [

          // 作品のサムネイル部分
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [

                  const Icon(
                    Icons.star_border,
                    color: Color(0xFFFFE9D0),
                    size: 34,
                  ),

                  // 作品カテゴリ
                  Positioned(
                    top: 7,
                    left: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF59432F),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        '小説',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // お気に入りアイコン
                  const Positioned(
                    top: 7,
                    right: 7,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0xFF443323),
                      child: Icon(
                        Icons.star_border,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 作品情報
          Container(
            height: 48,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              12, 7, 8, 5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 作品タイトル
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE9D9C6),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                // 投稿者・閲覧数
                Text(
                  '$author ・ 閲覧 $views',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFB5A18A),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
