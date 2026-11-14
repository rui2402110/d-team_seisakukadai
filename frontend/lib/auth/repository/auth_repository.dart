// Firebase(認証)とDjango(API)との通信を担当するクラス
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../core/api_client.dart';

class AuthRepository {
  /// Firebaseにログイン中かどうか
  bool get isSignedIn => FirebaseAuth.instance.currentUser != null;

  /// アプリ起動時に、Firebaseにログイン済みかを調べる(ブラウザの再読み込み後も判定できる)
  /// 最初の状態が分かるまで待つため、currentUser を直接見るより確実
  Future<bool> isSignedInAtStart() async {
    final user = await FirebaseAuth.instance.authStateChanges().first;
    return user != null;
  }

  /// メールとパスワードでFirebaseにログインし、Djangoにも登録済みかを返す
  /// 登録済みなら true、未登録なら false
  Future<bool> signIn(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return login();
  }

  /// Firebaseのアカウントを新規作成する(作成後は自動的にログイン状態になる)
  Future<void> createFirebaseAccount(String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 登録済みなら true、未登録なら false
  Future<bool> login() async {
    final idToken = await ApiClient.idToken();
    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/accounts/login/'),
      headers: ApiClient.headers(idToken),
    );
    if (res.statusCode != 200) throw ApiException('ログインに失敗しました(${res.statusCode})');
    return jsonDecode(res.body)['registered'] == true;
  }

  /// 新規登録(登録済みでも200が返るので、やり直しに使える)
  Future<void> register(String name) async {
    final idToken = await ApiClient.idToken();
    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/accounts/register/'),
      headers: ApiClient.headers(idToken),
      body: jsonEncode({'name': name}),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw ApiException('登録に失敗しました(${res.statusCode})');
    }
  }
}
