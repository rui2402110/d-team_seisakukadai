import 'package:flutter/material.dart';
import '../repository/work_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

// WorkRepositoryのファイルの場所に合わせてパスを調整してください
// 作品一覧画面
class Work extends StatefulWidget {
  const Work({super.key});

  @override
  State<Work> createState() => _WorkState();
}

// 画面の状態を管理するクラス
class _WorkState extends State<Work> {

  // Djangoから取得した作品情報を保持する変数
  late Future<Map<String, dynamic>> _workMenuFuture;

  // 画面が最初に作られたときに実行する
  @override
  void initState() {
    super.initState();

    // Djangoから作品情報を取得する
    _workMenuFuture = _loadWorkMenu();
  }

  // FirebaseのIDトークンを使ってDjangoと通信する
  Future<Map<String, dynamic>> _loadWorkMenu() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('ログインしていません');
    }

    final idToken = await user.getIdToken();

    final repository = WorkRepository();

    final result = await repository.getWorkMenu(idToken!);

    return result;
  }

  // ここから下にbuild()を書く
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 今までの画面のコード
    );
  }
}


// WorkRepositoryを使って作品情報を取得する
Future<Map<String, dynamic>> fetchWorkMenu(String idToken) async {
  
  // Djangoと通信するRepositoryを作成
  final repository = WorkRepository();


  // Djangoから作品情報を取得
  final result = await repository.getWorkMenu(idToken);

  // フォロー作品
  final followWorks = result['follow'];

  // おすすめ作品
  final recommendWorks = result['recommend'];

  // 取得したデータを返す
  return {
    'follow': followWorks,
    'recommend': recommendWorks,
  };
}


  // 画面の色
  static const Color bg = Color(0xFF2D2016);
  static const Color sidebar = Color(0xFF302116);
  static const Color card = Color(0xFF3A2A1B);
  static const Color orange = Color(0xFFE9782B);
  static const Color mainText = Color(0xFFE9D9C6);
  static const Color subText = Color(0xFFB5A18A);

  // 画面を作成するメソッド
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      // ここから下は、現在のColumn以下のコードを残す
      // Columnは子ウィジェットを上から下へ縦方向に並べる。
      // この画面ではメイン領域を縦に配置するために使用している。
      body: Column(
        children: [


          // 右側メイン画面
          // Expandedは親のColumn内で、残っている縦方向のスペースを占有する。
          // その中にヘッダーとメインコンテンツを縦に配置する。
          // タイトルと説明文がカード内に収まるよう、残りの横幅を使用する。
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー
                // 画面上部のヘッダー領域。
                // double.infinityを指定することで、親の横幅いっぱいに広げる。
                Container(
                  width: double.infinity,
                  // ヘッダー内側の余白を左・上・右・下の順番で指定する。
                  padding: const EdgeInsets.fromLTRB(
                    16, 17, 16, 20,
                  ),
                  // BoxDecorationで下線などの装飾を設定する。
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFF493729),
                      ),
                    ),
                  ),
                  // ヘッダー内のタイトルと説明文を縦方向に並べる。
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 画面タイトルを表示するTextウィジェット。
                      // constを付けることで、内容やスタイルが固定であることを示す。
                      const Text(
                        '作品',
                        style: TextStyle(
                          color: mainText,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // タイトルと説明文の間に4ピクセル分の空間を設ける。
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
                // ヘッダーより下の残りの領域をメインコンテンツとして使用する。
                // Paddingで画面端とコンテンツの間に余白を設ける。
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16, 18, 16, 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 検索欄
                        // 検索欄の見た目を作るContainer。
                        // 現状はデモ表示であり、入力欄や検索処理は実装されていない。
                        Container(
                          height: 33,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B2B1B),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF594531),
                            ),
                          ),
                          // 検索アイコンと案内文を横一列に並べる。
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
                        // 「マイ作品」と「作品投稿」のカードを横並びにする。
                        // Expandedを使うことで、2つのカードが利用可能な幅を均等に分け合う。
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
                        // 作品の種類を切り替えるためのカテゴリ表示。
                        // 第2引数trueは選択中、第2引数falseは未選択の見た目を表す。
                        // 現時点では表示だけで、タップによる切り替え処理はない。
                        Row(
                          children: [
                            _tab('すべて', true),
                            _tab('文字', false),
                            _tab('画像', false),
                            _tab('動画', false),
                          ],
                        ),

                        const SizedBox(height: 19),

                        // おすすめ作品
                        // 作品一覧の上に表示するセクション見出し。
                        const Text(
                          'おすすめ作品',
                          style: TextStyle(
                            color: mainText,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        // 作品一覧
                        // 残りの領域に作品カード一覧を表示する。
                        // LayoutBuilderを使うことで、親から渡された表示可能な幅や高さを取得できる。
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // GridView.countは、指定した列数で子ウィジェットを格子状に並べる。
                              return GridView.count(
                                // 1行に表示するカード数を3列に指定する。
                                crossAxisCount: 3,
                                // 横方向に隣り合うカードの間隔を16ピクセルにする。
                                crossAxisSpacing: 16,
                                // 縦方向に隣り合う行の間隔を12ピクセルにする。
                                mainAxisSpacing: 12,
                                // カードの横幅と高さの比率を指定する。
                                // 親の横幅を3列に分けた値を基準に、235を使って高さとの比率を調整する。
                                childAspectRatio:
                                    constraints.maxWidth /
                                    3 /
                                    235,
                                // スクロール操作を無効にする設定。
                                // 一覧をスクロールさせたい場合は、この設定を変更する。
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                children: const [
                                  _WorkCard(
                                    title: '灰と星屑',
                                    author: 'つむぎ',
                                    views: '8.4万',
                                    colors: [
                                      Color(0xFFD87939),
                                      Color(0xFF74392B),
                                    ],
                                  ),
                                  _WorkCard(
                                    title: 'サイレント・チャプター',
                                    author: '海野',
                                    views: '5.1万',
                                    colors: [
                                      Color(0xFF858B5C),
                                      Color(0xFF49371F),
                                    ],
                                  ),
                                  _WorkCard(
                                    title: '夜想曲のリベルタ',
                                    author: 'はると',
                                    views: '3.9万',
                                    colors: [
                                      Color(0xFF607FAB),
                                      Color(0xFF29384E),
                                    ],
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
          ),
        ],
      ),
    );
  }

  // サイドバーのメニュー項目を1つ作成する共通メソッド。
  // iconは表示するアイコン、titleはメニュー名を受け取る。
  // selectedがtrueなら選択中の色にし、notificationがtrueなら通知数のマークを表示する。
  // 先頭の_は、このメソッドが同じDartライブラリ内からのみ利用できることを示す。
  static Widget _menu(
    IconData icon,
    String title, {
    bool selected = false,
    bool notification = false,
  }) {
    // メニュー項目全体の大きさ、余白、背景などを設定するContainer。
    return Container(
      height: 31,
      margin: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      // 選択状態に応じて背景色を変更する。
      // 選択中は濃い茶色、未選択時は透明にする。
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF50321B)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Stackを使い、アイコンの右上に通知マークを重ねて配置する。
          // Clip.noneにより、Stackの範囲からはみ出した通知マークも表示できる。
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 13,
                color: selected ? orange : subText,
              ),
              // notificationがtrueの場合だけ通知マークを表示する。
              // Positionedでアイコンの右上に配置する位置を指定する。
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

  // 「マイ作品」「作品投稿」のような操作用カードを共通のデザインで作成するメソッド。
  // iconにはアイコン、titleには見出し、subtitleには補足説明を指定する。
  // 引数を変えるだけで、同じレイアウトのカードを複数作成できる。
  static Widget _actionCard(
    IconData icon,
    String title,
    String subtitle,
  ) {
    // カードの高さ、内側の余白、背景色、角丸、枠線を設定する。
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
          // アイコンの背景を円形に表示するCircleAvatar。
          // radiusで円の半径を指定し、その中央に受け取ったアイコンを配置する。
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
                // 作品タイトルを表示する。
                // 1行に収まらない場合は末尾を省略してカードのレイアウト崩れを防ぐ。
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
                  // 説明文は1行だけ表示し、長すぎる場合は末尾を省略記号にする。
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
          // カードの右端に、次の画面へ進めることを示す矢印アイコンを表示する。
          Icon(
            Icons.chevron_right,
            color: subText,
            size: 15,
          ),
        ],
      ),
    );
  }

  // 作品カテゴリのタブ表示を作成する共通メソッド。
  // titleはタブ名、selectedは選択状態を受け取る。
  // 選択中のタブにはオレンジ色の下線と明るい文字色を設定する。
  // 現状は見た目のみで、タップイベントやカテゴリ変更処理は実装していない。
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

// 作品一覧に表示する1件分のカードを定義するクラス。
// StatelessWidgetなので、受け取った情報を表示する役割を持ち、内部状態は保持しない。
// クラス名の先頭の_は、このライブラリ内でのみ使用する非公開クラスであることを示す。
class _WorkCard extends StatelessWidget {
  // 作品のタイトル。カード下部に表示する。
  final String title;
  // 作品を投稿したユーザー名。
  final String author;
  // 閲覧数を文字列として受け取る。例：「8.4万」。
  final String views;
  // 作品カード上部の背景グラデーションに使用する色のリスト。
  // LinearGradientに渡すため、複数のColorを受け取る。
  final List<Color> colors;

  // 各情報を必須引数として受け取るコンストラクタ。
  // requiredにより、カードを作成するときにtitle・author・views・colorsの指定が必要になる。
  const _WorkCard({
    required this.title,
    required this.author,
    required this.views,
    required this.colors,
  });

  // 受け取った作品情報を使って、カード全体のUIを組み立てる。
  @override
  Widget build(BuildContext context) {
    // 外側のContainerでカードの背景色、角丸、枠線を設定する。
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3A2A1B),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFF554331),
        ),
      ),
      // 角丸の外側にはみ出す子ウィジェットを切り取り、角を滑らかに表示する。
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                // 2色を使った斜め方向のグラデーションを背景に設定する。
                // colorsは_WorkCardの引数で受け取った色リストを利用する。
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
              // Stackを使い、中央のアイコンや左上・右上のラベルを重ねて配置する。
              // alignment.centerにより、通常位置の子ウィジェットを中央に配置する。
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // サムネイル中央に表示する装飾用の星アイコン。
                  // 現在は実際の画像ではなく、カードの仮デザインとして表示している。
                  const Icon(
                    Icons.star_border,
                    color: Color(0xFFFFE9D0),
                    size: 34,
                  ),

                  // サムネイル左上に作品カテゴリを表示するラベル。
                  // Positionedで上端と左端からの距離を指定する。
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

                  // サムネイル右上に星アイコンを配置する。
                  // 現状は装飾表示であり、お気に入り登録の処理は実装していない。
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

          // カード下部の作品情報領域。
          // タイトルと投稿者名・閲覧数を表示するため、高さを48に固定する。
          Container(
            height: 48,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              12, 7, 8, 5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                // 投稿者名と閲覧数を1行にまとめて表示する。
                // $authorと$viewsは文字列への変数埋め込み（文字列補間）。
                Text(
                  '$author ・ 閲覧 $views',
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
