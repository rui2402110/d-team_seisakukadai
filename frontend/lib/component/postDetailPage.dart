// import 'package:flutter/material.dart';
// import 'package:frontend/timeline/repository/timeline_repository.dart';
// import 'package:http/http.dart';
// import '../profile/repository/profile_repository.dart';
// import './postTile.dart';

// class PostDetailPage extends StatefulWidget{
//   final TimelineModel post;
//   Future<List<TimelineModel>> _getTimeline()async{
//     return await TimelineRepository().getTimeline();
//   }

//   const PostDetailPage({
//     super.key,
//     required this.post
//   });
//   @override
//   State<PostDetailPage> createState() => _PostDetailPageState();
// }

// class _PostDetailPageState extends State<PostDetailPage>{
  
//   @override
//   Widget build(BuildContext context){
//     final post = widget.post;

//     return Column(
//       children: [
//         Divider(),
//         Expanded(
//           child: FutureBuilder<List<TimelineModel>>(
//             future: TimelineRepository().getTimeline(postId:post.postId), 
//             builder: (context,snapshot){
//               // Loading
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               // Error
//               if (snapshot.hasError) {
//                 return Center(
//                   child: Text('エラーが発生しました:\n${snapshot.error}'),
//                 );
//               }
//               // データが取得できなかった
//               if (!snapshot.hasData || snapshot.data == null) {
//                 return const Center(child: Text('データが見つかりません'));
//               }
//               // ------------------------------------------------------------------
//               final riplyPosts =
//                   snapshot.data!;

//               return ListView.builder(
//                 itemCount: riplyPosts.length,
//                 itemBuilder: (context, index) {
//                   return PostTile(
//                     post: riplyPosts[index],
//                   );
//                 },
//               );
//             })
//         ),
//       ],
//     );
    
//   }
// }