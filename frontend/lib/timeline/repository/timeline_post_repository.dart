import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../core/api_client.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

// 動画、画像の制限
const int kMaxVideoSeconds = 120; // 2分
const int kMaxVideoBytes = 200 * 1024 * 1024; // 200MB

Future<String?> checkVideo(XFile video) async {
  if (!video.name.toLowerCase().endsWith('.mp4')) {
    return '動画は mp4 形式のみ投稿できます';
  }

  final size = await video.length();
  if (size > kMaxVideoBytes) {
    return '動画が大きすぎます';
  }

  final controller = kIsWeb
      ? VideoPlayerController.networkUrl(Uri.parse(video.path))
      : VideoPlayerController.file(File(video.path));
  try {
    await controller.initialize();
    final seconds = controller.value.duration.inSeconds;
    if (seconds > kMaxVideoSeconds) {
      return '動画が長すぎます';
    }
  } catch (_) {
    return '動画を読み込みませんでした';
  } finally {
    await controller.dispose();
  }

  return null;
}

String? contentTypeOf(String fileName) {
  final n = fileName.toLowerCase();
  if (n.endsWith('.jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
  if (n.endsWith('.png')) return 'image/png';
  if (n.endsWith('.mp4')) return 'video/mp4';
  return null;
  }


class TimelinePostRepository {
  Future<List<Map<String, dynamic>>> getUploadUrls(
    int postType,
    int reprlyId,
    List<String> contentType,
  ) async {
    final idToken = await ApiClient.idToken();

    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/timeline/uploadurls/'),
      headers: ApiClient.headers(idToken),
      body: reprlyId == 0
      ? jsonEncode({'post_type': postType, 'content_types': contentType})
      : jsonEncode({'post_type': postType, 'content_types': contentType, 'reply_id':reprlyId})
    );

    if (res.statusCode == 401) {
      throw Exception('認証に失敗しました');
    }

    if (res.statusCode != 200) {
      throw Exception('アップロードの準備に失敗しました');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['uploads']);
  }

  // ファイルの

  Future<void> putToS3(
    String uploadUrl,
    String contentType,
    List<int> bytes,
  ) async {
    print(uploadUrl);
    print(contentType);

    final res = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );
    print("${res.body}");
    if (res.statusCode != 200) {
      throw Exception('ファイルの送信に失敗しました。');
    }
  }

  Future<int> createPost({
    required int communityId,
    required String post,
    String? mediaType,
    int? replyId,
    List<String>? keys,
  }) async {
    final idToken = await ApiClient.idToken();

    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/timeline/postcreate/'),
      headers: ApiClient.headers(idToken),
      body: jsonEncode({
        'community_id': communityId,
        'post': post,
        if (replyId != null) 'reply_id': replyId,
        if (keys != null) 'keys': keys,
        if (mediaType != null) 'media_type': mediaType,
      }),
    );

    if (res.statusCode == 401) {
      throw ApiException('ログインの有効期限が切れました。もう一度ログインしてください');
    }
    // 400のとき、Djangoは {"error": "..."} を返す。その文字を、エラーに含める
    if (res.statusCode == 400) {
      final err = jsonDecode(utf8.decode(res.bodyBytes))['error'];
      throw ApiException('入力内容に問題があります($err)');
    }
    // 201 = 作成成功
    if (res.statusCode != 201) {
      throw ApiException('投稿に失敗しました(${res.statusCode})');
    }

    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return (data['id'] as num).toInt();
  }
}
