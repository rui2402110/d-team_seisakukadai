import 'package:flutter/material.dart';
import 'package:frontend/core/kakko_theme.dart';
import 'package:frontend/timeline/repository/timeline_repository.dart';
import '../timeline/page/postDetailPage.dart';
import 'package:frontend/component/timeAgo.dart';

class PostTile extends StatefulWidget {
  final TimelineModel post;

  const PostTile({
    super.key,
    required this.post,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  void _openProfile(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name == '/profile') return;

    Navigator.of(context).pushNamed('/profile');
  }
  

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailPage(
              post: post,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: KakkoColors.inkLine,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// アイコン
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(
                post.iconUrl,
              ),
            ),

            const SizedBox(width: 12),

            /// 本文
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  /// 名前行
                  Row(
                    children: [
                      Text(
                        post.name,
                        style: const TextStyle(
                          color:
                              KakkoColors.paperText,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 6),
                      Text(
                        '@${post.userId}',
                        style: const TextStyle(
                          color:
                              KakkoColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                          border: Border.all(
                            color:
                                KakkoColors.accent,
                          ),
                        ),
                        child: Text(
                          post.communityName,
                          style: const TextStyle(
                            color:
                                KakkoColors.accent,
                            fontSize: 11,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        timeAgo(
                          post.createdAt,
                        ),
                        style:
                            const TextStyle(
                          color:
                              KakkoColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// 投稿本文
                  Text(
                    post.post,
                    style: const TextStyle(
                      color:
                          KakkoColors.paperText,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// アクション
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color:
                            KakkoColors.muted,
                        size: 18,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        "${post.replyCount}",
                        style:
                            const TextStyle(
                          color:
                              KakkoColors.muted,
                        ),
                      ),

                      const SizedBox(width: 20),

                      Icon(
                        post.isLiked
                            ? Icons.favorite
                            : Icons
                                .favorite_border,
                        color: post.isLiked
                            ? Colors.red
                            : KakkoColors.muted,
                        size: 18,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        "${post.like}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}