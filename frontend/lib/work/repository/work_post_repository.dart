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

// 動画のチェックを行う関数
Future<String?> checkVideo(XFile video) async {
  // mp4でなければreturn
  if (!video.name.toLowerCase().endsWith('.mp4')) {
    return '動画は mp4 形式のみ投稿できます';
  }

  // 長さチェック
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

// 型チェック関数
String? contentTypeOf(String fileName) {
  final n = fileName.toLowerCase();
<<<<<<< HEAD
  if (n.endsWith('jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
  if (n.endsWith('png')) return 'image/png';
  if (n.endsWith('mp4')) return 'video/mp4';
=======
  if (n.endsWith('.jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
  if (n.endsWith('.png')) return 'image/png';
  if (n.endsWith('.mp4')) return 'video/mp4';
>>>>>>> 4cef6f5cd9f1702526f069d1afeae060bcd7a911
  return null;
  }


class WorkPostRepository {
  // S3の通行証を作成してもらう関数
  Future<List<Map<String, dynamic>>> getUploadUrls(
    int workType,
    List<String> contentType,
  ) async {
    // IDトークンを確認
    final idToken = await ApiClient.idToken();

    // DjangoのAPIに必要な値を詰めて送信
    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/work/uploadurls/'),
      headers: ApiClient.headers(idToken),
      body: jsonEncode({'work_type': workType, 'content_types': contentType}),
    );

    if (res.statusCode == 401) {
      throw Exception('認証に失敗しました');
    }

    if (res.statusCode != 200) {
      throw Exception('アップロードの準備に失敗しました');
    }
    // DjangoAPIの返り値を加工
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    // 加工した返り値をreturn
    return List<Map<String, dynamic>>.from(data['uploads']);
  }

  // ファイルをS3に送信

  Future<void> putToS3(
    String uploadUrl,
    String contentType,
    List<int> bytes,
  ) async {
    print(uploadUrl);
    print(contentType);

    // S3に値を送信
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

  // 作品をDBにinsertする関数
  Future<int> createWork({
    required String title,
    required int workType,
    String workDetail = '',
    String? text,
    List<String>? keys,
    List<int> relationIds = const[],
  }) async {
    // IDトークンを確認
    final idToken = await ApiClient.idToken();

    // 必要な値を詰めてDjangoAPIに送信
    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/work/workcreate/'),
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

    // Djangoの返り値を加工
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    // idを送信
    return (data['id'] as num).toInt();
  }
}
