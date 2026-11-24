import 'package:flutter/material.dart';
import 'package:frontend/timeline/repository/timeline_repository.dart';
import '../../component/postTile.dart';
import 'package:frontend/component/navbar.dart';
import 'package:frontend/core/kakko_theme.dart';
import 'package:frontend/component/timeAgo.dart';
import 'package:frontend/component/postReply.dart';
import 'package:frontend/component/post_detail_header.dart';
import 'package:frontend/core/user_session.dart';
import 'package:frontend/component/video.dart';

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

    final imageMedias = post.medias
      .where((m) => m.mediaType == 'image')
      .toList();

    final videoMedias = post.medias
      .where((m) => m.mediaType == 'video')
      .toList();

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
        child:Expanded(
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

              final replies = snapshot.data ?? [];

              return ListView.builder(
                itemCount: replies.length + 2,
                itemBuilder: (context, index) {
                  // 元投稿
                  if (index == 0) {
                    return PostDetailHeader(
                      post: post,
                    );
                  }

                  // 返信入力欄
                  if (index == 1) {
                    return Column(
                      children: [

                        Divider(
                          color: KakkoColors.inkLine,
                          indent: 8,
                          endIndent: 8,
                        ),

                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "返信先: ",
                                style: TextStyle(
                                  color: KakkoColors.paperText
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              TextSpan(
                                text:
                                    "${post.name}(@${post.userId})",
                                style: const TextStyle(
                                  color: KakkoColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [

                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        NetworkImage(
                                      UserSession.iconUrl!,
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: TextField(
                                      controller: controller,
                                      maxLines: null,
                                      decoration:
                                          const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '返信を入力',
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Align(
                                alignment:
                                    Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () async {

                                    // reply API

                                  },
                                  child: const Text(
                                    "返信",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(
                          color: KakkoColors.inkLine,
                        ),
                      ],
                    );
                  }

                  // 返信一覧
                  final reply =
                      replies[index - 2];

                  return PostTile(
                    post: reply,
                  );
                },
              );
            },
          ),
        )
      ),
    );
  }

}