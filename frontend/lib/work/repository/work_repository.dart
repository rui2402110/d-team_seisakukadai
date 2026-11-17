
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/api_client.dart';

// Djangoの作品APIとの通信を担当するクラス
class WorkRepository {

  // ==========================================
  // 共通：レスポンスのJSON変換
  // ==========================================

  Map<String, dynamic> _decodeResponse(
    http.Response response,
  ) {
    return jsonDecode(
      utf8.decode(response.bodyBytes),
    ) as Map<String, dynamic>;
  }

  // ==========================================
  // 作品一覧取得
  // ==========================================

  Future<Map<String, dynamic>> getWorkMenu() async {
    final idToken = await ApiClient.idToken();

    final res = await http.get(
      Uri.parse('${ApiClient.baseUrl}/work/workmenu/'),
      headers: ApiClient.headers(idToken),
    );

    if (res.statusCode == 401) {
      throw ApiException(
        'ログインの有効期限が切れました。もう一度ログインしてください',
      );
    }

    if (res.statusCode != 200) {
      throw ApiException(
        '作品の取得に失敗しました(${res.statusCode})',
      );
    }

    return _decodeResponse(res);
  }

  // ==========================================
  // 作品詳細取得
  // ==========================================

  Future<Map<String, dynamic>> getWorkDetail(
    dynamic workId,
  ) async {
    final idToken = await ApiClient.idToken();

    final res = await http.get(
      Uri.parse(
        '${ApiClient.baseUrl}/work/workdetail/$workId/',
      ),
      headers: ApiClient.headers(idToken),
    );

    if (res.statusCode == 401) {
      throw ApiException(
        'ログインの有効期限が切れました。もう一度ログインしてください',
      );
    }

    if (res.statusCode == 404) {
      throw ApiException('作品が見つかりませんでした');
    }

    if (res.statusCode != 200) {
      throw ApiException(
        '作品詳細の取得に失敗しました(${res.statusCode})',
      );
    }

    return _decodeResponse(res);
  }

  // ==========================================
  // いいね情報取得
  // ==========================================

  Future<Map<String, dynamic>> getWorkLike(
    dynamic workId,
  ) async {
    final idToken = await ApiClient.idToken();

    final res = await http.get(
      Uri.parse(
        '${ApiClient.baseUrl}/work/worklike/$workId/',
      ),
      headers: ApiClient.headers(idToken),
    );

    if (res.statusCode == 401) {
      throw ApiException(
        'ログインの有効期限が切れました。もう一度ログインしてください',
      );
    }

    if (res.statusCode == 404) {
      throw ApiException(
        '作品またはユーザーが見つかりませんでした',
      );
    }

    if (res.statusCode != 200) {
      throw ApiException(
        'いいね情報の取得に失敗しました(${res.statusCode})',
      );
    }

    return _decodeResponse(res);
  }

  // ==========================================
  // いいね切り替え
  // ==========================================

  Future<Map<String, dynamic>> toggleWorkLike(
    dynamic workId,
  ) async {
    final idToken = await ApiClient.idToken();

    final res = await http.post(
      Uri.parse(
        '${ApiClient.baseUrl}/work/worklike/$workId/',
      ),
      headers: ApiClient.headers(idToken),
    );

    if (res.statusCode == 401) {
      throw ApiException(
        'ログインの有効期限が切れました。もう一度ログインしてください',
      );
    }

    if (res.statusCode == 404) {
      throw ApiException(
        '作品またはユーザーが見つかりませんでした',
      );
    }

    if (res.statusCode != 200) {
      throw ApiException(
        'いいねの更新に失敗しました(${res.statusCode})',
      );
    }

    return _decodeResponse(res);
  }

  // ==========================================
  // 作品投稿
  //
  // workType:
  // 1 = 小説・ブログ
  // 2 = 漫画・イラスト
  // 3 = 動画
  //
  // ==========================================

  Future<Map<String, dynamic>> postWork({
    required String title,
    required int workType,
    required String workDetail,

    // 小説・ブログ本文
    String main = '',

    // 漫画・イラスト画像
    List<File> imageFiles = const [],

    // 動画ファイル
    File? videoFile,

    // 関連作品ID
    List<int> relatedWorkIds = const [],
  }) async {

    // ログイン中ユーザーのIDトークン
    final idToken = await ApiClient.idToken();

    // 入力チェック
    if (title.trim().isEmpty) {
      throw ApiException('タイトルを入力してください');
    }

    if (workType < 1 || workType > 3) {
      throw ApiException('作品の種類が正しくありません');
    }

    if (workType == 1 && main.trim().isEmpty) {
      throw ApiException('本文を入力してください');
    }

    if (workType == 2 && imageFiles.isEmpty) {
      throw ApiException('画像ファイルを選択してください');
    }

    if (workType == 3 && videoFile == null) {
      throw ApiException('動画ファイルを選択してください');
    }

    // MultipartRequestを作成
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiClient.baseUrl}/work/workpost/',
      ),
    );

    // 認証ヘッダー
    // MultipartRequestではContent-Typeを自動設定させる
    final headers = Map<String, String>.from(
      ApiClient.headers(idToken),
    );

    headers.removeWhere(
      (key, value) =>
          key.toLowerCase() == 'content-type',
    );

    request.headers.addAll(headers);

    // 基本情報
    request.fields['title'] = title.trim();
    request.fields['work_type'] = workType.toString();
    request.fields['work_detail'] = workDetail.trim();

    // 関連作品ID
    request.fields['related_work_ids'] =
        jsonEncode(relatedWorkIds);

    // ==========================================
    // 文字作品
    // ==========================================

    if (workType == 1) {
      request.fields['main'] = main;
    }

    // ==========================================
    // 画像作品
    // ==========================================

    if (workType == 2) {
      for (int i = 0; i < imageFiles.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            imageFiles[i].path,
          ),
        );
      }
    }

    // ==========================================
    // 動画作品
    // ==========================================

    if (workType == 3 && videoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'video',
          videoFile.path,
        ),
      );
    }

    // DjangoにPOSTリクエストを送信
    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    // ==========================================
    // エラー処理
    // ==========================================

    if (response.statusCode == 401) {
      throw ApiException(
        'ログインの有効期限が切れました。もう一度ログインしてください',
      );
    }

    if (response.statusCode == 400) {
      throw ApiException(
        '投稿内容が正しくありません: ${utf8.decode(response.bodyBytes)}',
      );
    }

    if (response.statusCode != 201 &&
        response.statusCode != 200) {
      throw ApiException(
        '作品の投稿に失敗しました(${response.statusCode})',
      );
    }

    // 投稿結果を返す
    return _decodeResponse(response);
  }
}
