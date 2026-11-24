import 'package:flutter/material.dart';
import 'package:frontend/component/timeAgo.dart';
import 'package:frontend/component/video.dart';
import 'package:frontend/core/kakko_theme.dart';
import 'package:frontend/timeline/repository/timeline_repository.dart';

class PostDetailHeader extends StatefulWidget {
  final TimelineModel post;

  const PostDetailHeader({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailHeader> createState() =>
      _PostDetailHeaderState();
}

class _PostDetailHeaderState
    extends State<PostDetailHeader> {

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    final imageMedias = post.medias
        .where((m) => m.mediaType == "image")
        .toList();

    final videoMedias = post.medias
        .where((m) => m.mediaType == "video")
        .toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: KakkoColors.inkLine,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ユーザー情報
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  post.iconUrl,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      post.name,
                      style: const TextStyle(
                        color: KakkoColors.paperText,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    Text(
                      "@${post.userId}",
                      style: const TextStyle(
                        color:
                            KakkoColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 本文
          Text(
            post.post,
            style: const TextStyle(
              color: KakkoColors.paperText,
              fontSize: 20,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          // 画像
          ...imageMedias.map(
            (media) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 8,
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(12),
                child: Image.network(
                  media.media,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 動画
          ...videoMedias.map(
            (media) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 8,
              ),
              child: VideoWidget(
                url: media.media,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            formatCreatedAt(
              post.createdAt,
            ),
            style: const TextStyle(
              color: KakkoColors.muted,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 12),

          const Divider(),

          Row(
            children: [
              const SizedBox(width: 4),
              // わざとアイコンだけ
              const Icon(
                Icons.chat_bubble_outline,
                color: KakkoColors.muted,
              ),

              const SizedBox(width: 4),

              Text(
                "${post.replyCount}",
                style: const TextStyle(
                  color:
                      KakkoColors.paperText,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(width:   24),
              IconButton(
                icon: Icon(
                  post.isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: post.isLiked
                      ? Colors.red
                      : KakkoColors.muted,
                ),
                onPressed: () async {

                  final oldLiked = post.isLiked;
                  final oldLike = post.like;

                  setState(() {
                    post.isLiked = !post.isLiked;

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
                      post.like = oldLike;
                    });

                    debugPrint(e.toString());
                  }
                },
              ),

              const SizedBox(width: 4),

              Text(
                "${post.like}",
                style: const TextStyle(
                  color:
                      KakkoColors.paperText,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const Divider(),
        ],
      ),
    );
  }
}