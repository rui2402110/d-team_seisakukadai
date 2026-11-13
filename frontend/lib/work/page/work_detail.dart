// Flutterの画面部品（Scaffold、Text、Button、Columnなど）を利用するためのライブラリ。
// ※元コードでは同じ material.dart が2回読み込まれていたため、1つに整理しています。
import 'package:flutter/material.dart';

// 作品詳細画面で使うデータは、一覧画面から work として受け取っています。
// 現在のこのファイルでは FirebaseAuth と WorkRepository を直接使用していないため、
// 未使用の import は削除しています。API連携をここに追加するときに必要に応じて再追加してください。

// 作品詳細画面のウィジェット。
// StatefulWidget にすることで、いいね・フォロー・コメント追加など、
// ユーザー操作によって変化する画面状態を管理できるようにしています。
class WorkDetailPage extends StatefulWidget {
  // 作品一覧画面から受け取る作品情報
  // 一覧画面から受け取る作品データ。
  // Map形式なので、Django APIから返されたJSONの各項目をキーで参照できます。
  // dynamic は値の型が項目ごとに異なる可能性があるため指定しています。
  final Map<String, dynamic> work;

  // コンストラクタ。
  // required により、画面を開く側は必ず作品データ work を渡す必要があります。
  const WorkDetailPage({
    super.key,
    required this.work,
  });

  @override
  State<WorkDetailPage> createState() => _WorkDetailPageState();
}

// WorkDetailPage の状態を管理するクラス。
// 先頭の _ は、このクラスがこのDartファイル内だけで使われる非公開クラスであることを表します。
class _WorkDetailPageState extends State<WorkDetailPage> {
  // 画面全体で共通利用する色を定数として定義しています。
  // static const にすることで、Stateのインスタンスごとに作らず固定値として利用できます。
  // デモ画面に合わせた色
  static const Color bg = Color(0xFF2D2016);
  static const Color card = Color(0xFF3A2A1B);
  static const Color orange = Color(0xFFE9782B);
  static const Color mainText = Color(0xFFE9D9C6);
  static const Color subText = Color(0xFFB5A18A);
  static const Color line = Color(0xFF49382A);

  // いいね・フォローのON/OFF状態。
  // true は押されている状態、false は押されていない状態を表します。
  // 現在は画面内だけで保持しており、アプリを再起動すると初期値に戻ります。
  // ボタン操作時は setState() で値を変更し、画面を再描画します。
  // いいね・フォロー状態
  bool isLiked = false;
  bool isFollowing = false;

  // 画面に表示するいいね数の初期値。
  // 現在はサンプル値で、Djangoのデータベースから取得した値ではありません。
  int likeCount = 2310;

  // コメント入力欄の文字列を読み書きするためのコントローラー。
  // TextField の controller に設定し、送信時に入力内容を取得したり、
  // 投稿後に clear() で入力欄を空にしたりします。
  // コメント入力欄
  final TextEditingController _commentController =
      TextEditingController();

  // コメント一覧に表示する仮データ。
  // name は投稿者名、time は投稿時刻の表示、text はコメント本文、
  // initial は丸いアイコン内に表示する1文字です。
  // 現状はDjango APIから取得しておらず、アプリ内だけで管理しています。
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

  // 関連作品欄に表示する仮データ。
  // title は作品名、author は投稿者、views は閲覧数です。
  // 現在は固定データで、関連作品APIとの接続や詳細画面への遷移は未実装です。
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

  // この画面が破棄されるときに呼び出されるライフサイクルメソッド。
  // TextEditingController を使い終わったら dispose() して、
  // 不要なリソースが残らないようにします。
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // 以下は受け取った work から表示用の値を取り出す getter（取得専用プロパティ）です。
  // APIの値が null の場合に備えて、?? で代わりに表示する文字列を指定しています。
  // 作品情報を取得
  String get title =>
      widget.work['title']?.toString() ?? 'タイトルなし';

  String get author =>
      widget.work['user_name']?.toString() ??
      widget.work['user_id']?.toString() ??
      '投稿者';

  String get detail =>
      widget.work['work_detail']?.toString() ?? '';

  // work_type の数値を画面表示用のジャンル名に変換します。
  // Django側の選択肢が 1=文字、2=画像、3=動画 であることを前提にしています。
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

  // いいねボタンが押されたときの処理。
  // isLiked を反転し、ONにしたときは件数を1増やし、OFFにしたときは1減らします。
  // setState() によってFlutterに状態変更を通知し、表示を更新します。
  // ※現在は画面内だけの仮処理で、サーバーへの保存は行っていません。
  // いいねボタン
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  // フォローボタンが押されたときの処理。
  // isFollowing の true/false を切り替えて、ボタンの表示を更新します。
  // ※現在は画面内だけの仮処理で、フォロー情報はDBに保存されません。
  // フォローボタン
  void toggleFollow() {
    setState(() {
      isFollowing = !isFollowing;
    });
  }

  // コメント送信時の処理。
  // 入力欄の前後の空白を trim() で取り除いてから内容を確認します。
  // ※現在はローカルの comments リストに追加するだけで、Djangoには送信しません。
  // コメント投稿
  void addComment() {
    final text = _commentController.text.trim();

    // 空文字、または空白だけのコメントは追加せずに処理を終了します。
    if (text.isEmpty) return;

    // setState() 内でリストを更新すると、コメント一覧が再描画されます。
    // insert(0, ...) はリストの先頭に追加するため、新しいコメントが一番上に表示されます。
    setState(() {
      comments.insert(0, {
        'name': 'あなた',
        'time': 'たった今',
        'text': text,
        'initial': 'あ',
      });

      _commentController.clear();
    });

    // キーボードにフォーカスが残っている場合は解除し、入力後にキーボードを閉じます。
    FocusScope.of(context).unfocus();
  }

  // Flutterが画面を描画するときに呼び出すメソッド。
  // Scaffoldを画面の土台にし、ヘッダーとスクロール可能な本文を縦方向に配置します。
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
            // Expanded は残りの縦スペースを本文に割り当てます。
            // SingleChildScrollView により、画面の高さを超える内容も上下にスクロールできます。
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 作品のタイトル・投稿者・ジャンル・いいね等を表示する部品。
                    // 表示処理を別メソッドに分けることで build() を読みやすくしています。
                    _buildWorkInfo(),

                    const SizedBox(height: 24),

                    // Djangoから受け取った work_detail を作品本文として表示する部品。
                    _buildWorkContent(),

                    const SizedBox(height: 32),

                    // 現在はサンプルデータを使って関連作品を表示する部品。
                    _buildRelatedWorks(),

                    const SizedBox(height: 32),

                    // コメント入力欄。
        // controller を指定することで addComment() から入力文字列を取得できます。
        // キーボードの送信操作でも addComment() が呼ばれます。
        // コメント入力欄とコメント一覧を表示する部品。
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

  // 画面上部のヘッダーを作成するメソッド。
  // 戻る操作を押すと Navigator.pop() で直前の画面へ戻ります。
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

  // 作品の基本情報をまとめて表示するメソッド。
  // アイコン、タイトル、ジャンル、投稿者、フォロー、閲覧数、いいねを配置します。
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
            // 押すと toggleFollow() を実行します。
            // isFollowing の状態によって「フォロー」「フォロー中」を切り替えます。
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

        // 閲覧数とコメント数の表示。
        // 現在は固定文字列なので、実データに連動していません。
        // 閲覧数・コメント数
        const Text(
          '閲覧 8.4万 ・ コメント 3',
          style: TextStyle(
            color: subText,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 16),

        // いいねボタン。
        // isLiked に応じてハートアイコンの形と色を変更し、件数を表示します。
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

  // ジャンル名を小さなラベルとして表示する共通部品。
  // 引数 value に「小説」「画像」「動画」などの文字列を受け取ります。
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

  // 作品本文を表示するメソッド。
  // detail が空なら未登録メッセージを表示し、値があればその本文を表示します。
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

  // 関連作品の一覧を表示するメソッド。
  // relatedWorks の各要素を map() でWidgetに変換し、... で children に展開します。
  // 現在「見る」ボタンは画面遷移せず、未接続であることをSnackBarで知らせます。
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

        // relatedWorks の件数分だけ、作品カードに相当するWidgetを生成します。
        // work にはリスト内の1作品分のMapが入ります。
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
                  // 関連作品の詳細画面への遷移はまだ実装していません。
                  // そのため、押したときに未接続であることをSnackBarで表示します。
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

  // コメント入力欄と投稿済みコメントを表示するメソッド。
  // TextField と送信ボタンを横並びにし、その下に comments の内容を一覧表示します。
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

        // comments の各コメントを画面部品に変換して表示します。
        // comment には name/time/text/initial の各項目が入っています。
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
