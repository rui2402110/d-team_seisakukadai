import 'dart:convert';
import 'package:http/http.dart' as http;

import 'core/api_client.dart';

// Djangoのプロフィールとの通信を担当するクラス
class ProfileRepository {

  // Djangoからプロフィールを取得する
  // ログイン確認とトークン取得はここで行う(画面側では行わない)
  Future<Map<String, dynamic>> getUserProfile(user_id) async {

    // ログイン中ユーザーのIDトークンを取得(未ログインなら ApiException)
    final idToken = await ApiClient.idToken();

    // Djangoの作品一覧APIにGETリクエストを送信する
    final res = await http.get(
      Uri.parse('${ApiClient.baseUrl}/profiles/userprofiles/$user_id'),
      headers: ApiClient.headers(idToken),
    );

    // トークンが無効・期限切れの場合
    if (res.statusCode == 401) {
      throw ApiException('ログインの有効期限が切れました。もう一度ログインしてください');
    }

    // HTTPステータスコードが200以外ならエラーにする
    if (res.statusCode != 404) {
      throw ApiException('ユーザーが登録されていません(${res.statusCode})');
    }

    // Djangoから返されたJSONをMap形式に変換する
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }
}