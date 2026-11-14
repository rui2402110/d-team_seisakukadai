import 'package:firebase_auth/firebase_auth.dart';

/// Django(API)からのエラーや、ログインしていない場合のエラー
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// Djangoと通信するときの共通部分(各repositoryから使う)
class ApiClient {
  // Webは localhost、Androidエミュレータは 10.0.2.2 に切り替える
  // 例: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
  static const baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');

  /// 認証トークンをHTTPヘッダーに設定する
  static Map<String, String> headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  /// ログイン中ユーザーのIDトークンを取得する(毎回取り直す。保存はしない)
  /// ログインしていない場合は ApiException を投げる
  static Future<String> idToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw ApiException('ログインしていません');
    final token = await user.getIdToken();
    if (token == null) throw ApiException('認証トークンを取得できませんでした');
    return token;
  }
}
