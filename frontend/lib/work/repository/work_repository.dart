import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/api_client.dart';

// Djangoの作品APIとの通信を担当するクラス
class WorkRepository {

  // Djangoからフォロー作品とおすすめ作品を取得する
  // ログイン確認とトークン取得はここで行う(画面側では行わない)
  Future<Map<String, dynamic>> getWorkMenu() async {

    // ログイン中ユーザーのIDトークンを取得(未ログインなら ApiException)
    final idToken = await ApiClient.idToken();

    // Djangoの作品一覧APIにGETリクエストを送信する
    final res = await http.get(
      Uri.parse('${ApiClient.baseUrl}/work/workmenu/'),
      headers: ApiClient.headers(idToken),
    );

    // トークンが無効・期限切れの場合
    if (res.statusCode == 401) {
      throw ApiException('ログインの有効期限が切れました。もう一度ログインしてください');
    }

    // HTTPステータスコードが200以外ならエラーにする
    if (res.statusCode != 200) {
      throw ApiException('作品の取得に失敗しました(${res.statusCode})');
    }

    // Djangoから返されたJSONをMap形式に変換する
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }
}