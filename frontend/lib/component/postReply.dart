import 'package:flutter/material.dart';
import 'package:frontend/core/kakko_theme.dart';
import 'package:frontend/timeline/repository/timeline_repository.dart';
import '../timeline/page/postDetailPage.dart';
import 'package:frontend/component/timeAgo.dart';
import 'package:frontend/core/user_session.dart';

class ReplyDialog extends StatefulWidget {
  final TimelineModel parentPost;

  const ReplyDialog({
    super.key,
    required this.parentPost,
  });

  @override
  State<ReplyDialog> createState() =>
      _ReplyDialogState();
}

class _ReplyDialogState extends State<ReplyDialog> {
  final controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final post = widget.parentPost;
    return Dialog(
      backgroundColor: KakkoColors.inkSoft,
      child: SizedBox(
        width: 600,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// 閉じる
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: KakkoColors.paperText,
                    ),
                  ),
                ],
              ),

              /// 元投稿
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// アイコン＋縦線
                  SizedBox(
                    width: 48,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(
                            post.iconUrl,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Container(
                          width: 2,
                          height: 60,
                          color: KakkoColors.inkLine,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            // ユーザー名
                            // Flexible :利用可能なスペースを埋めるように拡大
                            Flexible(
                              child: Text(
                                post.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: KakkoColors.paperText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // ユーザーID
                            Text(
                              '@${post.userId}',
                              style: const TextStyle(
                                color: KakkoColors.muted,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(width: 4),
                            // ユーザーID
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                  color: KakkoColors.accent,
                                ),
                              ),
                              child: Text(
                                post.communityName,
                                style: const TextStyle(
                                  color: KakkoColors.accent,
                                  fontSize: 11,
                                ),
                              ),
                            ),

                            const SizedBox(width: 4),
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
                        const SizedBox(height: 4),
                        // 投稿内容
                        Text(
                          post.post,
                          style: const TextStyle(
                            color: KakkoColors.paperText,
                            height: 1.5,
                          ),
                        ),
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
                      ],
                    ),
                  ),
                ],
              ),
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
      ),
    );
  }
}