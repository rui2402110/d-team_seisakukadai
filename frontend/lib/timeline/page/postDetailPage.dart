import 'package:flutter/material.dart';
import 'package:frontend/timeline/repository/timeline_repository.dart';
import '../../component/postTile.dart';
import 'package:frontend/component/navbar.dart';
import 'package:frontend/core/kakko_theme.dart';
import 'package:frontend/component/timeAgo.dart';
import 'package:frontend/component/postReply.dart';
import 'package:frontend/core/user_session.dart';

class PostDetailPage extends StatefulWidget{
  final TimelineModel post;
  Future<List<TimelineModel>> _getTimeline()async{
    return await TimelineRepository().getTimeline();
  }

  const PostDetailPage({
    super.key,
    required this.post
  });
  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage>{
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context){
    final post = widget.post;

    // プロフィールページに遷移する関数
    void _openProfile(BuildContext context) {
      if (ModalRoute.of(context)?.settings.name == '/profile') return;

      Navigator.of(context).pushNamed('/profile');
    }

    return 
    Navbar(
      selectedIndex: NavIndex.timeline,
      child:Container(
        decoration: BoxDecoration(
          color: KakkoColors.inkSoft,
          border: Border.all(
            color: KakkoColors.inkLine,
          ),
        ),
        child:Column(
            children: [
              // header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Text(
                  '投稿詳細',
                  style: TextStyle(
                    color: KakkoColors.paperText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            // -------------------------------------------------------
            // ユーザー情報
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                      post.iconUrl,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    // ユーザー名
                    post.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: KakkoColors.paperText,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    // 枠線
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: KakkoColors.accent,
                      ),
                    ),
                    // コミュニティ名
                    child: Text(
                      post.communityName,
                      style: const TextStyle(
                        color: KakkoColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 投稿時間
                  Text(
                    timeAgo(post.createdAt),
                    style: const TextStyle(
                      color: KakkoColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // 投稿内容
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.post,
                    style: const TextStyle(
                      color:KakkoColors.paperText,
                    ),
                  ),
                ],
              ),
            ),
            // 投稿時間
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 8),
                Text(
                  formatCreatedAt(post.createdAt),
                  style: const TextStyle(
                    color: KakkoColors.muted,
                    fontSize: 12,
                  ),
                ),
                
              ],
            ),
            
            // 返信・いいねボタン
            Divider(
              color: KakkoColors.inkLine,
              indent: 8,
              endIndent: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(children: [
                    IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: KakkoColors.muted,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ReplyDialog(parentPost:post);
                        },
                      );
                    },
                  ),

                  Text(
                    "${post.replyCount}",
                    style: const TextStyle(
                      color: KakkoColors.muted,
                    ),
                  ),
                ],),
                

                Row(children:[
                  const SizedBox(width: 12),

                  IconButton(
                    icon: Icon(
                      post.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: post.isLiked
                          ? Colors.redAccent
                          : KakkoColors.muted,
                    ),
                    onPressed: () async {
                      final oldLiked =
                          post.isLiked;
                      final oldLikeCount =
                          post.like;

                      setState(() {
                        post.isLiked =
                            !post.isLiked;

                        if (post.isLiked) {
                          post.like++;
                        } else {
                          post.like--;
                        }
                      });

                      try {
                        await TimelineRepository().like(
                          postId: post.postId,
                        );
                      } catch (e) {
                        setState(() {
                          post.isLiked = oldLiked;
                          post.like = oldLikeCount;
                        });

                        debugPrint(
                          e.toString(),
                        );
                      }
                    },
                  ),

                  Text(
                    "${post.like}",
                    style: TextStyle(
                      color: post.isLiked
                          ? Colors.redAccent
                          : KakkoColors.muted,
                    ),
                  ),
                ])
              ],
            ),
            Divider(
              color: KakkoColors.inkLine,
              indent: 8,
              endIndent: 8,
            ),
            // ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "返信先: ",
                    style: TextStyle(
                      color: KakkoColors.paperText.withValues(alpha: 0.3),
                      height: 1.5,
                    ),
                  ),
                  TextSpan(
                    text: "${post.name}(@${post.userId})",
                    style: const TextStyle(
                      color: KakkoColors.accent,
                      height: 1.5,
                    ),
                  ),
                  TextSpan(
                    text: "さん ",
                    style: TextStyle(
                      color: KakkoColors.paperText.withValues(alpha: 0.3),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding( 
              padding:EdgeInsets.all(8.0),
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          UserSession.iconUrl!,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: TextField(
                          controller: controller,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '返信を入力',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        // reply API
                      },
                      child: const Text("返信"),
                    ),
                  ),
                ],
              ),
            ),
            // ーーーーーーーーーーーーーーーーーーーーーーーーーー
            Divider(
              color: KakkoColors.inkLine,
              indent: 8,
              endIndent: 8,
            ),
            Expanded(
              child: FutureBuilder<List<TimelineModel>>(
                future: TimelineRepository().getTimeline(
                  postId: post.postId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'エラー: ${snapshot.error}',
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('返信がありません'),
                    );
                  }

                  final replyPosts = snapshot.data!;

                  return ListView.builder(
                    itemCount: replyPosts.length,
                    itemBuilder: (context, index) {
                      return PostTile(
                          post: replyPosts[index],
                        );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}