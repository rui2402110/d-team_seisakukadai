// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../component/navbar.dart';
import '../../core/kakko_theme.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});
  @override
  State<Timeline> createState() => _TimelineState();
}
//2026-11-10 12:00:00.000 固定時刻
class _TimelineState extends State<Timeline> 
  with SingleTickerProviderStateMixin {
  // 取得した内容を保持するリスト-DB
  List<Map<String, dynamic>> user = [
    {
      "userId":1,
      "name":"ゆき",
    },{
      "userId":2,
      "name":"はると",
    },{
      "userId":3,
      "name":"せんな",
    },{
      "userId":4,
      "name":"りく",
    },{
      "userId":5,
      "name":"しおり",
    },{
      "userId":6,
      "name":"あなた",
    },
  ];
  List muteWord =["ネタバレ","最終回"];
  List<Map<String, dynamic>> community = [
    {
      "comId":1,
      "comName":"灰と星屑 感想部",
      "icon":""
    },{
      "comId":2,
      "comName":"夜想曲のリベルタを語る会"
    },{
      "comId":3,
      "comName":"サイレント・チャプター部"
    }
  ];
  List<Map<String, dynamic>> comMen = [
    {
      "comId":1,
      "userId":{1,4,6}
    },{
      "comId":3,
      "userId":{3,6}
    }
    ];
  List<Map<String, dynamic>> post = [
    { 
      "postId":1, //投稿ID
      "userId":1, //ユーザーID
      "comId":1, //投稿先のコミュニティ
      "reply":0, //返信先のpostId、返信ではない場合0
      "image":"",
      "like":18,
      "post":"積読解消するぞの意気込みで開いた『夜想曲のリベルタ』1巻、もう心を持っていかれた…",
      "createdAt":"2026-11-10 11:50:00.000",
    },{ 
      "postId":2,
      "userId":4,
      "comId":1,
      "reply":1,
      "image":"",
      "like":0,
      "post":"わかる、あそこで声出た",
      "createdAt":"2026-11-10 11:58:00.000",
    },{ 
      "postId":3,
      "userId":3,
      "comId":1,
      "reply":1, 
      "image":"",
      "like":0,
      "post":"伏線、１巻からあったんですね…読み返します",
      "createdAt":"2026-11-10 11:59:00.000",
    },{ 
      "postId":4,
      "userId":2,
      "comId":2,
      "reply":0, 
      "image":"",
      "like":9,
      "post":"え、あの二人がまさかの再開…？！ここからどう転がるのか全く読めない",
      "createdAt":"2026-11-10 11:35:00.000",
    },{ 
      "postId":5,
      "userId":3,
      "comId":3,
      "reply":0, 
      "image":"",
      "like":40,
      "post":"3話の演出、完全に映画だった…円盤絶対買う。",
      "createdAt":"2026-11-10 11:20:00.000",
    },{ 
      "postId":6,
      "userId":2,
      "comId":3,
      "reply":5, 
      "image":"",
      "like":0,
      "post":"わかります、毎週OPだけで満足してます",
      "createdAt":"2026-11-10 11:20:00.000",
    },{ 
      "postId":7,
      "userId":5,
      "comId":3,
      "reply":5, 
      "image":"",
      "like":0,
      "post":"作画担当、他の作品も調べたくなりました",
      "createdAt":"2026-11-10 11:40:00.000",
    },{ 
      "postId":8,
      "userId":4,
      "comId":1,
      "reply":0, 
      "image":"https://placehold.jp/30/dd6699/ffffff/300x150.png?text=placeholder+image",
      "like":52,
      "post":"このコマの構図がとにかく好き。原作の静けさがそのまま絵になってる。",
      "createdAt":"2026-11-10 11:00:00.000",
    },{ 
      "postId":9,
      "userId":1,
      "comId":1,
      "reply":8, 
      "image":"",
      "like":0,
      "post":"このコマ本当に綺麗ですよね",
      "createdAt":"2026-11-10 11:10:00.000",
    },{ 
      "postId":10,
      "userId":1,
      "comId":1,
      "reply":0, 
      "image":"",
      "like":33,
      "post":"最終話の展開、完全に予想を裏切られた…あの１行で全部ひっくり返るとは思わなかった。",
      "createdAt":"2026-11-10 10:00:00.000",
    },{ 
      "postId":11,
      "userId":4,
      "comId":1,
      "reply":10, 
      "image":"",
      "like":0,
      "post":"まさかそんな結末になるとは…",
      "createdAt":"2026-11-10 11:00:00.000",
    },
  ];
  List<Map<String, dynamic>> postLikes = [
    { //いいねした投稿とユーザー
      "userId":6,
      "postId":1
    },{
      "userId":6,
      "postId":5
    }
  ];
  List<Map<String, dynamic>> follow =[
    {
      "id":1,
      "follow":6, //フォローするユーザー
      "following":1 //フォローされるユーザー
    },{
      "id":1,
      "follow":6, 
      "following":2
    },{
      "id":1,
      "follow":6, 
      "following":4
    },
  ];
  
  //-------------------------------------------------
  late final _tabController = TabController(
    length: comMen.length + 1, //タブ数
    vsync: this //アニメーション同期用
    );
  final _postController = TextEditingController();//投稿内容
  bool icons = false;

  Widget loadPost(){
    return Text("ぽすとないよう");
  }

  @override
  void dispose() {//リソース解放
    _tabController.dispose();
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ナビ付きの枠に、この画面の中身を渡す
    return Navbar(
      selectedIndex: NavIndex.timeline,
      child: Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,//タブのスクロール
          tabs: [
            Tab(text: "フォロー",),
            ...comMen.map((menber){ // コミュニティ名を取得
              final com = community.firstWhere(
                (c) => c["comId"] == menber["comId"],
              );
              return Tab(text: com["comName"],);
            })
          ]
        ),
        Expanded(child: 
          TabBarView(
            controller: _tabController,
            children: [
              loadPost(),
              ...comMen.map((menber){ 
              final com = community.firstWhere(
                (c) => c["comId"] == menber["comId"],
              );
              return 
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${com["comName"]}に投稿します"),
                          Row(
                            spacing: 10,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  'https://picsum.photos/200/300',
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "いま感じたことをシェアしよう"
                                  ),
                                  controller: _postController,
                                  onTap: () { //入力下部表示
                                    setState(() {
                                      icons = true;
                                    });
                                  },
                                  // onTapOutside: (PointerDownEvent event) {
                                  //   // 入力欄の外側がタップされたときに入力下部を非表示
                                  //   FocusManager.instance.primaryFocus?.unfocus();
                                  //   setState(() {
                                  //     icons = false;
                                  //   });
                                  // },
                                ),
                              ),
                            ]
                          ),
                          if (icons)...{
                            Divider(),
                            // 幅が狭いときは、アイコンとボタンを折り返して表示する
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 8,
                              children: [
                              Row(
                                spacing: 10,
                                children: [
                                IconButton(onPressed:(){print("写真添付おした");}, icon: Icon(Icons.image)),
                                IconButton(onPressed:(){print("動画添付おした");}, icon: Icon(Icons.movie)),
                                IconButton(onPressed:(){print("作品引用おした");}, icon: Icon(Icons.notes)),
                              ],),
                              Row(
                                spacing: 10,
                                children: [
                                  ElevatedButton(
                                    onPressed: (){
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      setState(() {
                                        icons = false;
                                      });
                                      print("キャンセル");
                                    }, 
                                    child: Text("キャンセル")),
                                  ElevatedButton(
                                    onPressed: (){
                                      if(_postController.text.isNotEmpty)
                                      print("投稿");
                                      }, 
                                    child: Text("投稿")),
                              ],)
                            ],),
                            
                          }
                        ],
                      ),
                    ),
                    loadPost(),
                  ],
                );
            })
            ],
          ),
        )
      ]
    ));
  }
}
