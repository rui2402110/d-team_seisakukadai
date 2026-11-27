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
  final int replyId;
  final VoidCallback? onPosted;

  const PostForm({
    super.key,
    required this.replyId,
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
  bool get canPost {
    final hasText = _postController.text.trim().isNotEmpty;
    final hasMedia = selectedImages.isNotEmpty || selectedVideo != null;
    return hasText || hasMedia;
  }

  final ImagePicker picker = ImagePicker();

  List<XFile> selectedImages=[];
  XFile? selectedVideo;
  List<Uint8List> imageBytesList=[];
  int replyId = 0;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {

    String? mediaType;
    List<String>? keys;
    
    // 存在するかどうか(bool)
    final hasImages = selectedImages.isNotEmpty;
    final hasVideo = selectedVideo != null;

    // 画像または動画が存在する
    if(hasImages || hasVideo){
      final repo =TimelinePostRepository();

      // 画像
      if(hasImages){
        mediaType = "image";

        final List<String>contentTypes =[];
        for(final file in selectedImages){
          // ファイル名からコンテンツタイプ（MIMEタイプ）を取得
          final ct = contentTypeOf(file.name);
          if(ct == null){
            throw Exception("未対応の画像形式です:${file.name}");
          }
          contentTypes.add(ct);
        }

        // 画像枚数分アップロード先のURLを取得
        final uploads = await repo.getUploadUrls(2,replyId,contentTypes);

        // 順番を保ったまま各画像をS3へアップロードしkeyを収集
        final List<String> uplodedKeys=[];
        for(int i=0; i<imageBytesList.length;i++){
          // フォールバック処理
          final bytes = i < imageBytesList.length
            // imageBytesList に既に読み込み済みデータ
            ? imageBytesList[i]
            // なければselectedImages から直接読み込む
            : await selectedImages[i].readAsBytes();
          
          await repo.putToS3(
            uploads[i]["upload_url"],
            contentTypes[i], 
            bytes
          );
          uplodedKeys.add(uploads[i]["key"]);

          keys = uplodedKeys;
        } 
      }else if(hasVideo){
        mediaType = "video";
        final videoFile = selectedVideo!;

        final contentType = contentTypeOf(videoFile.name);
        if(contentType == null){
          throw Exception("未対応の動画形式です: ${videoFile.name}");
        }

        final uploads = await repo.getUploadUrls(3, replyId,[contentType]);
        final bytes = await videoFile.readAsBytes();

        await repo.putToS3(
          uploads[0]["upload_url"], 
          contentType, 
          bytes
        );

        keys = [uploads[0]["key"]];
      }
    }

    // 投稿
    await TimelinePostRepository().createPost(
      communityId:widget.communityId,
      post: _postController.text,
      mediaType: mediaType,
      keys: keys,
    );

    // コントローラクリア
    _postController.clear();

    setState(() {
      selectedImages.clear();
      imageBytesList.clear();
      selectedVideo = null;
      icons = false;
    });

    widget.onPosted?.call();
  }
  // 画像投稿(1枚のみ)
  // Future<void> pickImage() async {
  //   final file = await picker.pickImage(
  //     source: ImageSource.gallery,
  //   );

  //   // ユーザーキャンセル時データをNULL
  //   if (file == null) return;
  //   // プレビュー用にバイトデータを取得する
  //   final bytes = await file.readAsBytes();

  //   setState(() {
  //     selectedImages = file;
  //     selectedVideo = null;
  //     imageBytesList = bytes;
  //   });
  // }

  //画像複数枚または動画投稿
  Future<void> pickMultiImages() async{
    const maxImages = 4;
    final remaining = maxImages - selectedImages.length;
    // 上限に達した
    if (remaining <= 0) return;

    final picked =  await picker.pickMultiImage(
      // 残り上限枚数
      limit: remaining
    );
    // ファイルの中身が何もなかった
    if (picked.isEmpty) return;

    // 新しく追加された分だけバイトデータを読み込む
    final List<Uint8List> newBytes = [];
    for (final file in picked) {
      newBytes.add(await file.readAsBytes());
    }
    // 画面が閉じられていた場合、
    // 以降の処理を中断して抜ける
    if (!mounted) return;

    setState(() {
      selectedImages = [
        ...selectedImages,
        ...picked.take(remaining), // Web等 limit が効かない環境向け
      ];
      imageBytesList = [
        ...imageBytesList,
        ...newBytes.take(remaining),
      ];
      selectedVideo = null;
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
      selectedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    replyId = widget.replyId;
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
                  style: TextStyle(
                    color: KakkoColors.paperText
                  ),
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
            if (imageBytesList.isNotEmpty)
              // Padding(
              //   padding: const EdgeInsets.only(top: 8),
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(12),
              //     child: SizedBox(
              //       width: 150,
              //       height: 100,
              //       child: Image.memory(imageBytesList!)
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 110,
                // 画面に表示される部分だけを生成
                child: ListView.separated(
                    // 左右スクロール
                    scrollDirection: Axis.horizontal,
                    itemCount: imageBytesList.length,
                    // リストのアイテム間に8ピクセルの横方向（水平）の余白
                    separatorBuilder: (_,__) => const SizedBox(width: 8),
                    itemBuilder: (context, index){
                      // 重ねて配置
                      return Stack(
                        children: [
                          // 角丸の長方形で切り抜く
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            // 各画像
                            child: Image.memory(
                              imageBytesList[index],
                              width: 110,
                              height: 110,
                              // 縦横比率を変えずに枠いっぱい
                              fit: BoxFit.cover,
                            ),
                          ),
                          // 個別削除ボタン
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  // 削除
                                  imageBytesList.removeAt(index);
                                  selectedImages.removeAt(index);
                                });
                              },
                              // 丸く表示
                              child: const CircleAvatar(
                                radius: 12,
                                child: Icon(Icons.close,size: 14),
                              ),
                            )
                          )
                        ],
                      );
                    },
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
                      onPressed: pickMultiImages,
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
                          _postController.clear();
                          selectedImages.clear();
                          selectedVideo=null;
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
                        canPost
                          ? _submit
                          : null,
                      style:
                        canPost
                        ? ElevatedButton.styleFrom(
                            backgroundColor: KakkoColors.muted
                          )
                        : ElevatedButton.styleFrom(
                            backgroundColor: KakkoColors.ink
                          ),
                      child: 
                        canPost
                        ? Text(
                            "投稿",
                            style: TextStyle(
                              color: KakkoColors.paperText
                            ),
                          )
                        : Text(
                            "投稿",
                            style: TextStyle(
                              color: KakkoColors.inkSoft
                            ),
                          )
                      
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