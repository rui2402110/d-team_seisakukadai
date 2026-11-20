
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
  Future<int> createCommunity({
    required String name,    
    required String target,
    String detail = "",
    required String icon_url
  }) async {
    final idToken = await ApiClient.idToken();

    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/community/communitycreate'),
      headers: ApiClient.headers(idToken),
      body: jsonEncode({
        'name': name,
        'target': target,
        'detail': detail,
        'icon_url': icon_url
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
