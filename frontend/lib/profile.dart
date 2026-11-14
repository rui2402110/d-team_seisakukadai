import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.all(10),
          child: 
            Row( //appberの代わり
              spacing: 10,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue, // 背景色
                    foregroundColor: Colors.white, // アイコンの色
                  ),
                  splashRadius: 20.0,
                  onPressed: () =>  Navigator.of(context).pop()
                ),
                // Icon(Icons.arrow_back_ios_new),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("あなた"),
                    Text("投稿128件")
                  ],
                )
              ],
            ),
          ),
          //----------------------------------------------------
          Container(
            margin: EdgeInsets.only(bottom: 50),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    //LinearGradient:直線上
                    //RadialGradient:放射上
                    //SweepGradient:環状
                    gradient: LinearGradient( 
                      colors: [
                        Colors.deepOrange,
                        Colors.black
                      ],
                    )
                  ),
                ),
                Positioned(
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
                  child: ElevatedButton(onPressed: (){}, child: Text("プロフィールを編集")),
                )

              ],
            ),
          ),
          //-----------------------------------------------------
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("あなた",style: TextStyle(fontSize: 20),),
                Text("@anata_kakko"),
                SizedBox(height: 10,),
                Text('''物語を読むのも書くのも好きです。灰と星屑、夜想曲のリベルタが今期のお気に入り。感想はいつでも大歓迎。'''),
                Row(
                  spacing: 10,
                  children: [
                    Icon(Icons.checklist_rounded),
                    Text("https://www.o-hara.jp/"),
                    Icon(Icons.checklist_rounded),
                    Text("2023年4月から利用"),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  spacing: 15,
                  children: [
                    Text("1フォロー中"),
                    Text("0フォロワー"),
                  ],
                ),

              ],
            ),
          )
        ],
    );
  }
}
