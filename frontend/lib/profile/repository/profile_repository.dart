import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_client.dart';

// Djangoのプロフィールとの通信を担当するクラス
class ProfileRepository {
  // JSONレスポンスをMapに変換
  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('サーバーから不正なデータが返されました');
  }

  // Djangoからプロフィールを取得する
  // ログイン確認とトークン取得はここで行う(画面側では行わない)
  Future<Map<String, dynamic>> getUserProfile({String? userId}) async {

    // ログイン中ユーザーのIDトークンを取得(未ログインなら ApiException)
    final idToken = await ApiClient.idToken();

    // 1. userId の有無によってURLを切り替える
    final Uri url;
    if (userId == null || userId.isEmpty) {
      // 自分のプロフィール (/profiles/userprofiles/)
      url = Uri.parse('${ApiClient.baseUrl}/profiles/userprofiles/');
    } else {
      // 他人のプロフィール (/profiles/userprofiles/123/)
      url = Uri.parse('${ApiClient.baseUrl}/profiles/userprofiles/$userId/');
    }

    // 2. リクエストを送信（res を ifの外で使えるように宣言）
    final res = await http.get(
      url,
      headers: ApiClient.headers(idToken),
    );

    // 3. トークンが無効・期限切れの場合
    if (res.statusCode == 401) {
      throw ApiException('ログインの有効期限が切れました。もう一度ログインしてください');
    }

    // 4. ユーザーが見つからなかった場合（404）
    if (res.statusCode == 404) {
      throw ApiException('ユーザーが登録されていません');
    }

    // 5. その他の予期せぬエラー（200以外）
    if (res.statusCode != 200) {
      throw ApiException('データの取得に失敗しました (${res.statusCode})');
    }

    // Djangoから返されたJSONをMap形式に変換して返却
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  // フォロー
  Future<Map<String,dynamic>> followUser({
    //required:必須の引数
    required String userId,
    required bool follow
  })async{
    // ログイン中ユーザーのIDトークンを取得(未ログインなら ApiException)
    final idToken = await ApiClient.idToken();

    //url
    final url = Uri.parse('${ApiClient.baseUrl}/users/follow/$userId/');

    //リクエスト
    final res = await http.post(
      url,
      headers: {
        ...ApiClient.headers(idToken),
        //データ形式と文字コード
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode({'follow' : follow}),
    );
    // 認証エラー
    if (res.statusCode == 401) {
      throw ApiException(
        'ログインの有効期限が切れました。もう一度ログインしてください',
      );
    }

    // ユーザーが存在しない
    if (res.statusCode == 404) {
      throw ApiException('ユーザーが見つかりません');
    }
    // 不正なリクエスト
    if (res.statusCode == 400) {
      final data = _decodeResponse(res);
      throw ApiException(
        data['error']?.toString() ?? '不正なリクエストです',
      );
    }

    // その他のエラー
    if (res.statusCode != 200) {
      throw ApiException(
        'フォロー処理に失敗しました (${res.statusCode})',
      );
    }

    //成功時
    return _decodeResponse(res);

  }
}