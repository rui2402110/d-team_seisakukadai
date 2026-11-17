import 'dart:convert';
import 'package:http/http.dart' as http;

import 'core/api_client.dart';

// Djangoのプロフィールとの通信を担当するクラス
class ProfileRepository {

  // Djangoからプロフィールを取得する
  // ログイン確認とトークン取得はここで行う(画面側では行わない)
  Future<Map<String, dynamic>> getUserProfile({String? user_id}) async {

    // ログイン中ユーザーのIDトークンを取得(未ログインなら ApiException)
    final idToken = await ApiClient.idToken();

    // 1. user_id の有無によってURLを切り替える
    final Uri url;
    if (user_id == null || user_id.isEmpty) {
      // 自分のプロフィール (/profiles/userprofiles/)
      url = Uri.parse('${ApiClient.baseUrl}/profiles/userprofiles/');
    } else {
      // 他人のプロフィール (/profiles/userprofiles/123/)
      url = Uri.parse('${ApiClient.baseUrl}/profiles/userprofiles/$user_id/');
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
}