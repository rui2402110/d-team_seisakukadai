// ユーザーのセッション情報を保持するクラス
class UserSession {
  static String? userId;
  static String? name;
  static String? iconUrl;
  static String? bio;
  static String? link;

  static void clear() {
    userId = null;
    name = null;
    iconUrl = null;
    bio = null;
    link = null;
  }
}