import 'package:flutter/material.dart';
import 'package:frontend/core/kakko_theme.dart';
import 'package:frontend/timeline/repository/timeline_repository.dart';
import 'package:frontend/timeline/repository/timeline_post_repository.dart';
import '../timeline/page/postDetailPage.dart';
import 'package:frontend/component/timeAgo.dart';
import 'package:frontend/core/user_session.dart';
import 'package:image_picker/image_picker.dart';

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
  final picker = ImagePicker();

  List<XFile> images = [];
  XFile? video;

  List<String> uploadedKeys = [];
  String? mediaType;

  bool isSending = false;

  // 画像を選択する
  Future<void> pickImages() async {
    final files = await picker.pickMultiImage();

    if (files.isEmpty) return;

    if (files.length > 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('画像は4枚までです'),
        ),
      );
      return;
    }

    setState(() {
      images = files;
      video = null;
    });
  }

  // 動画を選択する
  Future<void> pickVideo() async {
    final file = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (file == null) return;

    final err = await checkVideo(file);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }

    setState(() {
      video = file;
      images.clear();
    });
  }

  
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
                      style: const TextStyle(
                        color: KakkoColors.paperText,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '返信を入力',
                      ),
                    ),
                  ),
                ],
              ),
              if (images.isNotEmpty)
                Text(
                  "${images.length}枚選択中",
                  style: const TextStyle(
                    color: KakkoColors.paperText,
                  ),
                ),

              if (video != null)
                Text(
                  video!.name,
                  style: const TextStyle(
                    color: KakkoColors.paperText,
                  ),
                ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: pickImages,
                  ),
                  IconButton(
                    icon: const Icon(Icons.videocam),
                    onPressed: pickVideo,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    // 文字が入力されていない場合は何もしない
                    if (controller.text.isEmpty) {
                      return;
                    }
                    try{
                      List<String> uplodedKeys = [];
                      String? mediaType;
                      final repository = TimelinePostRepository();

                      //画像
                      if (images.isNotEmpty) {

                        mediaType = "image";

                        final contentTypes =
                            images.map((e) => contentTypeOf(e.name)!).toList();

                        final uploads =
                            await repository.getUploadUrls(
                          2,
                          post.postId,
                          contentTypes,
                        );

                        for (int i = 0; i < images.length; i++) {

                          final bytes =
                              await images[i].readAsBytes();

                          await repository.putToS3(
                            uploads[i]["upload_url"],
                            contentTypes[i],
                            bytes,
                          );

                          uploadedKeys.add(
                            uploads[i]["key"],
                          );
                        }
                      }

                      // 動画
                      if (video != null) {

                        mediaType = "video";

                        final contentType =
                            contentTypeOf(video!.name)!;

                        final uploads =
                            await repository.getUploadUrls(
                          3,
                          post.replyId,
                          [contentType],
                        );

                        final bytes =
                            await video!.readAsBytes();

                        await repository.putToS3(
                          uploads[0]["upload_url"],
                          contentType,
                          bytes,
                        );

                        uploadedKeys.add(
                          uploads[0]["key"],
                        );
                      }
                      await TimelinePostRepository().createPost(
                        communityId: post.communityId,
                        post: controller.text,
                        replyId: post.postId,
                        keys: uploadedKeys.isEmpty
                          ? null
                          : uploadedKeys,
                        mediaType: mediaType,
                      );
                      Navigator.pop(context, true);
                      
                    }catch (e) {

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                          ),
                        );
                      }
                    }
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