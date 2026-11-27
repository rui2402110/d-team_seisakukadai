import 'package:shared_preferences/shared_preferences.dart';

/// ミュートワードの保存・取得を行うリポジトリ
///
/// UC-17「ミュートワードを設定する」準拠:
/// - ユーザーID単位でミュートワードを管理する
/// - 登録(add)・全件取得(getAll)・更新(update)・削除(remove)
/// - 登録/更新時は重複していれば false を返す（画面側で「すでに登録されています」表示）
///
/// 保存先はshared_preferences。サーバーで保存。
/// クライアント側の永続化。キーはユーザーIDごとに分ける。
class MuteWordRepository {
  /// デモ版 community-common.js の初期値と同じ
  static const List<String> defaultWords = ['ネタバレ', '最終回'];

  /// ユーザーIDごとの保存キー（デモのキー名 kakko.mutewords.v1 にユーザーIDを付与）
  String _key(String userId) => 'kakko.mutewords.v1.$userId';

  Future<List<String>> _load(SharedPreferences prefs, String userId) async {
    // キーが無い（初回）場合はデモと同じ初期値を返す。保存はしない
    // （全削除後に初期値が復活しないようにするため）
    return prefs.getStringList(_key(userId)) ?? List.of(defaultWords);
  }

  Future<void> _save(
    SharedPreferences prefs,
    String userId,
    List<String> words,
  ) async {
    await prefs.setStringList(_key(userId), words);
  }

  /// 全件取得
  Future<List<String>> getAll(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return _load(prefs, userId);
  }

  /// 登録する。重複または空文字なら false（UC-17: 「すでに登録されています」）
  Future<bool> add(String userId, String word) async {
    final w = word.trim();
    if (w.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final words = await _load(prefs, userId);
    if (words.contains(w)) return false;
    words.add(w);
    await _save(prefs, userId, words);
    return true;
  }

  /// 更新する。index はミュートワードID相当。
  /// 範囲外・空文字・別の項目と重複する場合は false
  Future<bool> update(String userId, int index, String word) async {
    final w = word.trim();
    if (w.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final words = await _load(prefs, userId);
    if (index < 0 || index >= words.length) return false;
    // 自分自身への変更は許可し、別の項目との重複のみ弾く
    if (words[index] != w && words.contains(w)) return false;
    words[index] = w;
    await _save(prefs, userId, words);
    return true;
  }

  /// 削除する。index はミュートワードID相当。範囲外なら false
  Future<bool> remove(String userId, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final words = await _load(prefs, userId);
    if (index < 0 || index >= words.length) return false;
    words.removeAt(index);
    await _save(prefs, userId, words);
    return true;
  }
}
