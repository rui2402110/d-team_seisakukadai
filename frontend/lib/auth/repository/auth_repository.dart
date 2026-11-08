// httpでDjangoとの通信を行うクラス
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class AuthRepository {
  // Webは localhost、Androidエミュレータは 10.0.2.2 に切り替える
  // 例: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
  static const _baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  /// 登録済みなら true、未登録なら false
  Future<bool> login(String idToken) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/accounts/login/'),
      headers: _headers(idToken),
    );
    if (res.statusCode != 200) throw ApiException('ログインに失敗しました(${res.statusCode})');
    return jsonDecode(res.body)['registered'] == true;
  }

  /// 新規登録(登録済みでも200が返るので、やり直しに使える)
  Future<void> register(String idToken, String name) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/accounts/register/'),
      headers: _headers(idToken),
      body: jsonEncode({'name': name}),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw ApiException('登録に失敗しました(${res.statusCode})');
    }
  }
}