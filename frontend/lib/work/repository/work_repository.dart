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

  // Djangoから作品の詳細(workDetailViewの返す値)を取得する
  // 返る値: pk / fields(user, title, work_type, work_detail, created_at)
  //        / likecount / relation / Main
  // ログイン確認とトークン取得はここで行う(画面側では行わない)
  Future<Map<String, dynamic>> getWorkDetail(dynamic workId) async {

    // ログイン中ユーザーのIDトークンを取得(未ログインなら ApiException)
    final idToken = await ApiClient.idToken();

    // Djangoの作品詳細APIにGETリクエストを送信する
    final res = await http.get(
      Uri.parse('${ApiClient.baseUrl}/work/workdetail/$workId/'),
      headers: ApiClient.headers(idToken),
    );

    // トークンが無効・期限切れの場合
    if (res.statusCode == 401) {
      throw ApiException('ログインの有効期限が切れました。もう一度ログインしてください');
    }

    // 作品が存在しない場合
    if (res.statusCode == 404) {
      throw ApiException('作品が見つかりませんでした');
    }

    // HTTPステータスコードが200以外ならエラーにする
    if (res.statusCode != 200) {
      throw ApiException('作品詳細の取得に失敗しました(${res.statusCode})');
    }

    // Djangoから返されたJSONをMap形式に変換する
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  // Djangoから作品のいいね情報(workLikeViewの返す値)を取得する
  // 返る値: pk / work(title, work_type, work_detail, created_at)
  //        / user(user_id, name) / likecount / liked
  // ログイン確認とトークン取得はここで行う(画面側では行わない)
  Future<Map<String, dynamic>> getWorkLike(dynamic workId) async {

    // ログイン中ユーザーのIDトークンを取得(未ログインなら ApiException)
    final idToken = await ApiClient.idToken();

    // DjangoのいいねAPIにGETリクエストを送信する
    final res = await http.get(
      Uri.parse('${ApiClient.baseUrl}/work/worklike/$workId/'),
      headers: ApiClient.headers(idToken),
    );

    // トークンが無効・期限切れの場合
    if (res.statusCode == 401) {
      throw ApiException('ログインの有効期限が切れました。もう一度ログインしてください');
    }

    // 作品またはユーザーが存在しない場合
    if (res.statusCode == 404) {
      throw ApiException('作品またはユーザーが見つかりませんでした');
    }

    // HTTPステータスコードが200以外ならエラーにする
    if (res.statusCode != 200) {
      throw ApiException('いいね情報の取得に失敗しました(${res.statusCode})');
    }

    // Djangoから返されたJSONをMap形式に変換する
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  // いいねを切り替える(していなければ追加、していれば取り消し)
  // 返る値は getWorkLike と同じ(likecount / liked など)
  Future<Map<String, dynamic>> toggleWorkLike(dynamic workId) async {

    // ログイン中ユーザーのIDトークンを取得(未ログインなら ApiException)
    final idToken = await ApiClient.idToken();

    // DjangoのいいねAPIにPOSTリクエストを送信する
    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/work/worklike/$workId/'),
      headers: ApiClient.headers(idToken),
    );

    // トークンが無効・期限切れの場合
    if (res.statusCode == 401) {
      throw ApiException('ログインの有効期限が切れました。もう一度ログインしてください');
    }

    // 作品またはユーザーが存在しない場合
    if (res.statusCode == 404) {
      throw ApiException('作品またはユーザーが見つかりませんでした');
    }

    // HTTPステータスコードが200以外ならエラーにする
    if (res.statusCode != 200) {
      throw ApiException('いいねの更新に失敗しました(${res.statusCode})');
    }

    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }
}
