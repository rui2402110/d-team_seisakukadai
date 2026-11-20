import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../core/api_client.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

// 動画の制限
const int kMaxVideoSeconds = 120;
const int kMaxVideoBytes = 200 * 1024 * 1024;

Future<String?> checkVideo(XFile video) async {
  if (!video.name.toLowerCase().endsWith('.mp4')) {
    return '動画は mp4 形式のみ投稿できます';
  }

  final size = await video.length();
  if (size > kMaxVideoBytes) {
    //   final mb = (size / 1024 / 1024).toStringAsFixed(1);
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
  if (n.endsWith('jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
  if (n.endsWith('png')) return 'image/png';
  if (n.endsWith('.,mp4')) return 'video/mp4';
  return null;
  }


class WorkPostRepository {
  Future<List<Map<String, dynamic>>> getUploadUrls(
    int workType,
    List<String> contentType,
  ) async {
    final idToken = await ApiClient.idToken();

    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/work/uploadurls'),
      headers: ApiClient.headers(idToken),
      body: jsonEncode({'work_type': workType, 'content_type': contentType}),
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
    final res = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );
    if (res.statusCode != 200) {
      throw Exception('ファイルの送信に失敗しました。');
    }
  }

  Future<int> createWork({
    required String title,
    required int workType,
    String workDetail = '',
    String? text,
    List<String>? keys,
    List<int> relationIds = const[],
  }) async {
    final idToken = await ApiClient.idToken();

    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/work/create/'),
      headers: ApiClient.headers(idToken),
      body: jsonEncode({
        'title': title,
        'work_type': workType,
        'work_detail': workDetail,
        'relation_ids': relationIds,
        // nullのときはキーごと送らない
        // if (text != null) 'text'
        if (text != null) 'text': text,
        if (keys != null) 'keys': keys,
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
      throw ApiException('作品の投稿に失敗しました(${res.statusCode})');
    }

    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return (data['id'] as num).toInt();
  }
}
