import 'package:flutter/material.dart';
import 'package:frontend/core/user_session.dart';
import 'package:frontend/timeline/repository/timeline_post_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:frontend/core/kakko_theme.dart';

class PostForm extends StatefulWidget {
  final int communityId;
  final String communityName;
  final VoidCallback? onPosted;

  const PostForm({
    super.key,
    required this.communityId,
    required this.communityName,
    this.onPosted,
  });

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final TextEditingController _postController =
      TextEditingController();

  bool icons = false;
  bool posting = false;

  final ImagePicker picker = ImagePicker();

  XFile? selectedImage;
  XFile? selectedVideo;
  Uint8List? imageBytes;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {

    String? mediaType;
    List<String>? keys;


    if (selectedImage != null ||
        selectedVideo != null) {

      final file =
          selectedImage ?? selectedVideo!;

      mediaType =
          selectedImage != null
          ? "image"
          : "video";

      final contentType =
          contentTypeOf(file.name);

      if (contentType == null) {
        throw Exception(
          "未対応の形式です",
        );
      }

      final repo =
          TimelinePostRepository();

      final uploads =
          await repo.getUploadUrls(
        selectedImage != null ? 2 : 3,
        [contentType],
      );

      final bytes =
          await file.readAsBytes();

      await repo.putToS3(
        uploads[0]["upload_url"],
        contentType,
        bytes,
      );

      keys = [
        uploads[0]["key"]
      ];
    }

    await TimelinePostRepository()
        .createPost(
      communityId:
          widget.communityId,
      post: _postController.text,
      mediaType: mediaType,
      keys: keys,
    );
    _postController.clear();

    setState(() {
      selectedImage = null;
      selectedVideo = null;
      icons = false;
    });

    widget.onPosted?.call();
  }
  // 画像投稿
  Future<void> pickImage() async {
    final file = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();

    setState(() {
      selectedImage = file;
      selectedVideo = null;
      imageBytes = bytes;
    });
  }

  // 動画投稿
  Future<void> pickVideo() async {
    final file = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (file == null) return;

    final error = await checkVideo(file);

    if (error != null) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );

      return;
    }

    setState(() {
      selectedVideo = file;
      selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            "${widget.communityName} に投稿",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: KakkoColors.paperText
            ),
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              CircleAvatar(
                radius: 20,
                backgroundImage:
                    NetworkImage(
                  UserSession.iconUrl ??
                      'https://picsum.photos/200',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: TextField(
                  controller:
                      _postController,
                  maxLines: null,
                  decoration:
                      const InputDecoration(
                    border:
                        InputBorder.none,
                    hintText:
                        "いま感じたことをシェアしよう",
                  ),
                  onTap: () {
                    setState(() {
                      icons = true;
                    });
                  },
                ),
              ),
            ],
          ),

          if (icons) ...[
            // 表示
            if (selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 150,
                    height: 100,
                    child: Image.file(
                      File(selectedImage!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            if (selectedVideo != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: 150,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 40,
                    ),
                  ),
                ),
              ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [

                    // 画像投稿
                    IconButton(
                      onPressed: pickImage,
                      icon: const Icon(
                        Icons.image,
                      ),
                    ),

                    //動画投稿
                    IconButton(
                      onPressed: pickVideo,
                      icon: const Icon(
                        Icons.movie,
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        debugPrint(
                          "作品引用",
                        );
                      },
                      icon: const Icon(
                        Icons.notes,
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [

                    OutlinedButton(
                      onPressed: () {

                        FocusManager
                            .instance
                            .primaryFocus
                            ?.unfocus();

                        setState(() {
                          icons = false;
                        });
                      },
                      child: const Text(
                        "キャンセル",
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    ElevatedButton(
                      onPressed:
                          posting
                              ? null
                              : _submit,
                      child: posting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "投稿",
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}