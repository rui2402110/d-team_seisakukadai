import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_client.dart';

class WorkRepository {
  // JSONレスポンスをMapに変換
  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('サーバーから不正なデータが返されました');
  }

  // Firebase IDトークン取得
  Future<String> _getToken() async {
    final token = await ApiClient.idToken();

    if (token.isEmpty) {
  throw Exception('ログインしていません');
}

    return token;
  }

  // 作品メニュー取得
  Future<Map<String, dynamic>> getWorkMenu() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/work/workmenu/'),
      headers: ApiClient.headers(token),
    );

    if (response.statusCode == 401) {
      throw Exception('認証に失敗しました');
    }

    if (response.statusCode != 200) {
      throw Exception('作品メニューの取得に失敗しました');
    }

    return _decodeResponse(response);
  }

  // 作品詳細取得
  Future<Map<String, dynamic>> getWorkDetail(int workId) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/work/workdetail/$workId/'),
      headers: ApiClient.headers(token),
    );

    if (response.statusCode == 401) {
      throw Exception('認証に失敗しました');
    }

    if (response.statusCode == 404) {
      throw Exception('作品が見つかりません');
    }

    if (response.statusCode != 200) {
      throw Exception('作品詳細の取得に失敗しました');
    }

    return _decodeResponse(response);
  }

  // いいね情報取得
  Future<Map<String, dynamic>> getWorkLike(int workId) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/work/worklike/$workId/'),
      headers: ApiClient.headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('いいね情報の取得に失敗しました');
    }

    return _decodeResponse(response);
  }

  // いいね切り替え
  Future<Map<String, dynamic>> toggleWorkLike(int workId) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/work/worklike/$workId/'),
      headers: ApiClient.headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('いいねの更新に失敗しました');
    }

    return _decodeResponse(response);
  }

  // 全作品取得（関連作品選択用）
  Future<List<Map<String, dynamic>>> getAllWorks() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/work/workpost/'),
      headers: ApiClient.headers(token),
    );

    if (response.statusCode == 401) {
      throw Exception('認証に失敗しました');
    }

    if (response.statusCode != 200) {
      throw Exception('全作品の取得に失敗しました');
    }

    final data = _decodeResponse(response);

    final List<dynamic> works = data['work'] ?? [];

    return works.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }
}