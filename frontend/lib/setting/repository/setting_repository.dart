import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_client.dart';

/// 設定画面のサーバーAPIリポジトリ（UC-17: ミュートワードなど）
///
/// サーバー保存方針:
/// - 一覧取得: GET    `/settings/muteword/`
/// - 登録:     POST   `/settings/muteword/`        body: {"mute_word": "..."}
/// - 更新:     PUT    `/settings/muteword/<id>/`  body: {"mute_word": "..."}
/// - 削除:     DELETE `/settings/muteword/<id>/`
/// レスポンスの一覧は {"muteWord": [{id, user, mute_word, created_at}, ...]}
class SettingRepository {
  List<Map<String, dynamic>> _decodeList(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is Map<String, dynamic>) {
      final list = decoded['muteWord'];
      if (list is List) {
        return list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    }
    throw Exception('サーバーから不正なデータが返されました');
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('サーバーから不正なデータが返されました');
  }

  /// 重複登録のステータス（サーバー側の実装に合わせて 400/409 を重複とみなす）
  bool _isDuplicate(int statusCode) => statusCode == 400 || statusCode == 409;

  /// ミュートワード一覧を取得する
  Future<List<Map<String, dynamic>>> getMuteWords() async {
    final token = await ApiClient.idToken();
    final res = await http.get(
      Uri.parse('${ApiClient.baseUrl}/settings/muteword/'),
      headers: ApiClient.headers(token),
    );

    if (res.statusCode == 401) {
      throw Exception('認証に失敗しました');
    }
    if (res.statusCode != 200) {
      throw Exception('ミュートワード一覧の取得に失敗しました');
    }
    return _decodeList(res);
  }

  /// ミュートワードを登録する。重複時は Exception('すでに登録されています')
  Future<Map<String, dynamic>> addMuteWord(String word) async {
    final token = await ApiClient.idToken();
    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/settings/muteword/'),
      headers: ApiClient.headers(token),
      body: jsonEncode({'mute_word': word}),
    );

    if (res.statusCode == 401) {
      throw Exception('認証に失敗しました');
    }
    if (_isDuplicate(res.statusCode)) {
      throw Exception('すでに登録されています');
    }
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('ミュートワードの登録に失敗しました');
    }
    return _decodeMap(res);
  }

  /// ミュートワードを更新する（id はミュートワードのpk）。重複時は Exception('すでに登録されています')
  Future<void> updateMuteWord(int id, String word) async {
    final token = await ApiClient.idToken();
    final res = await http.put(
      Uri.parse('${ApiClient.baseUrl}/settings/muteword/$id/'),
      headers: ApiClient.headers(token),
      body: jsonEncode({'mute_word': word}),
    );

    if (res.statusCode == 401) {
      throw Exception('認証に失敗しました');
    }
    if (_isDuplicate(res.statusCode)) {
      throw Exception('すでに登録されています');
    }
    if (res.statusCode != 200) {
      throw Exception('ミュートワードの更新に失敗しました');
    }
  }

  /// ミュートワードを削除する（id はミュートワードのpk）
  Future<void> deleteMuteWord(int id) async {
    final token = await ApiClient.idToken();
    final res = await http.delete(
      Uri.parse('${ApiClient.baseUrl}/settings/muteword/$id/'),
      headers: ApiClient.headers(token),
    );

    if (res.statusCode == 401) {
      throw Exception('認証に失敗しました');
    }
    if (res.statusCode == 404) {
      throw Exception('ミュートワードが見つかりません');
    }
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('ミュートワードの削除に失敗しました');
    }
  }
}
