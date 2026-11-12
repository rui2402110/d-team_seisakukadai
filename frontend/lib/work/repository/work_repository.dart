
import 'dart:convert';
import 'package:http/http.dart' as http;

// Djangoの作品APIとの通信を担当するクラス
class WorkRepository {

  // AuthRepositoryと同じサーバーURLを使用する
  static const _baseUrl =
      String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8000',
      );

  // 認証トークンをHTTPヘッダーに設定する
  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // Djangoからフォロー作品とおすすめ作品を取得する
  Future<Map<String, dynamic>> getWorkMenu(String idToken) async {

    // Djangoの作品一覧APIにGETリクエストを送信する
    final res = await http.get(
      Uri.parse('$_baseUrl/work/menu/'),
      headers: _headers(idToken),
    );

    // HTTPステータスコードが200以外ならエラーにする
    if (res.statusCode != 200) {
      throw Exception(
        '作品の取得に失敗しました(${res.statusCode})'
      );
    }

    // Djangoから返されたJSONをMap形式に変換する
    return jsonDecode(
      utf8.decode(res.bodyBytes)
    );
  }
}
