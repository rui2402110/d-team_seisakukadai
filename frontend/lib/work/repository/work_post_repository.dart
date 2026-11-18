import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
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
  Future<List<Map<String, dynamic>>> getUplaodUrls(
    int workType,
    List<String> contentType,
  ) async {

  final idToken = await ApiClient.idToken();
  

  final res = await http.post(
    Uri.parse('${ApiClient.baseUrl}/work/uploadurls'),
    headers: ApiClient.headers(idToken),
    body: jsonEncode({
      'work_type': workType,
      'content_type': contentType,
    }),
  );

  if (res.statusCode == 401) {
      throw Exception('認証に失敗しました');
    }

    if (res.statusCode != 200) {
      throw Exception('アップロードの準備に失敗しました');
    }
  final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['uploads']);
    
    }}