import 'package:flutter/material.dart';
import 'package:frontend/timeline/repository/timeline_repository.dart';
import './postDetailPage.dart';

class PostTile extends StatefulWidget{
  final TimelineModel post;

  const PostTile({
    super.key,
    required this.post
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile>{
  /// プロフィール画面を開く(戻るボタンで戻れるように、履歴は残す)
  void _openProfile(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name == '/profile') return;
    Navigator.of(context).pushNamed('/profile');
  }

  @override
  Widget build(BuildContext context){

    var post = widget.post;

    return 
    ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(
            post.iconUrl
        ),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.name),
          SizedBox(width: 5,),
          Text(post.communityName)
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.post),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.chat),
                onPressed: () {
                  print("aaa");
                  //  showDialog(
                  //   context: context,
                  //   barrierDismissible: false, // 外側タップで閉じないようにする場合
                  //   builder: (BuildContext context) {
                  //     return AlertDialog(
                  //       title: Column(
                  //         children: [
                  //           ListTile(
                  //             leading: const CircleAvatar(
                  //               radius: 20,
                  //               backgroundImage: NetworkImage(
                  //                 'https://picsum.photos/200/300',
                  //               ),
                  //             ),
                  //             title: Text(post.name),
                  //             subtitle: Text(post.communityName),
                  //             onTap: () => _openProfile(context),
                  //           ),
                  //           Text(post.post),
                  //         ],
                  //       ),
                  //       content: SizedBox(
                  //         width: 500,
                  //         height: 600,
                  //         // child: PostDetailPage(post: post),
                  //       ),
                  //       actions: <Widget>[
                  //         TextButton(
                  //           child: Text('キャンセル'),
                  //           onPressed: () {
                  //             Navigator.of(context).pop(); // ダイアログを閉じる
                  //           },
                  //         ),
                  //         TextButton(
                  //           child: Text('OK'),
                  //           onPressed: () {
                  //             // 処理
                  //             Navigator.of(context).pop();
                  //           },
                  //         ),
                  //       ],
                  //     );
                  //   },
                  // );
                },
              ),
              Text("${post.replyCount}"),
              IconButton(
                icon: post.isLiked
                  ?Icon(Icons.favorite)
                  :Icon(Icons.favorite_border),
                onPressed: () async{
                  final oldLiked = post.isLiked;
                  final oldLikeCount = post.like;
                  setState(() {
                    post.isLiked = !post.isLiked;
                    if(post.isLiked){
                      post.like++;
                    }else{
                      post.like--;
                    }
                    
                  });
                  try{
                    await TimelineRepository().like(
                      postId:post.postId
                    );
                  }catch (e){
                    setState(() {
                      post.isLiked = oldLiked;
                      post.like = oldLikeCount;
                    });
                    debugPrint(e.toString());
                  }
                  
                },
              ),
              Text("${post.like}"),
            ],
          )
        ],
      ),
      // onTap: (){
        
      // },
    );        
  }
}