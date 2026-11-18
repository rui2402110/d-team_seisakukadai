
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_client.dart';

class CommunityRepository {
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

  // コミュニティメニュー取得
  Future<Map<String, dynamic>> getCommunityMenu() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse(
        '${ApiClient.baseUrl}/community/communitymenu/',
      ),
      headers: ApiClient.headers(token),
    );

    if (response.statusCode == 401) {
      throw Exception('認証に失敗しました');
    }

    if (response.statusCode != 200) {
      throw Exception('コミュニティメニューの取得に失敗しました');
    }

    return _decodeResponse(response);
  }

  // コミュニティ一覧取得
  Future<List<Map<String, dynamic>>> getAllCommunities() async {
    final data = await getCommunityMenu();

    final List<dynamic> communities = data['community'] ?? [];

    return communities.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }
}
