import 'package:flutter/material.dart';
import 'component/navbar.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> 
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(
    length: 5, //タブ数
    vsync: this, //アニメーション同期用
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ナビ付きの枠に、この画面の中身を渡す(プロフィールはナビのどの項目も選択しない)
    return Navbar(
      selectedIndex: null,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                spacing: 10,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue, // 背景色
                      foregroundColor: Colors.white, // アイコンの色
                    ),
                    splashRadius: 20.0,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("あなた", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("投稿128件", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            //----------------------------------------------------
            Container(
              margin: const EdgeInsets.only(bottom: 50),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepOrange,
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 50,
                    left: 10,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/200/300',
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 110,
                    child: ElevatedButton(
                      onPressed: () {}, 
                      child: const Text("プロフィールを編集"),
                    ),
                  )
                ],
              ),
            ),
            //-----------------------------------------------------
            // 【修正箇所】プロフィール詳細情報のレイアウト
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名前 ＆ ID
                  const Text(
                    "あなた",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "@anata_kakko",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  
                  // 自己紹介文
                  const Text(
                    '''物語を読むのも書くのも好きです。灰と星屑、夜想曲のリベルタが今期のお気に入り。感想はいつでも大歓迎。''',
                    style: TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  
                  // ウェブサイト ＆ 利用開始日（アイコンとテキストを綺麗にペアリング）
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.link, size: 18, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            "https://www.o-hara.jp/",
                            style: TextStyle(color: Colors.blue, fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            "2023年4月から利用",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // フォロー / フォロワー数
                  Row(
                    spacing: 16,
                    children: const [
                      Row(
                        spacing: 4,
                        children: [
                          Text("1", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("フォロー中", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                      Row(
                        spacing: 4,
                        children: [
                          Text("0", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("フォロワー", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            //-----------------------------------------------------
            Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '投稿'),
                    Tab(text: '返信'),
                    Tab(text: 'メディア'),
                    Tab(text: '作品'),
                    Tab(text: 'いいね'),
                  ],
                ),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      
                      Text("返信"),
                      Text("メディア"),
                      Text("作品"),
                      Text("いいね"),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}