import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repository/auth_repository.dart';
import '../widget/auth_widgets.dart';
import 'register_page.dart';

/// ログイン画面
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 初期値を設定（プライベート）
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repo = AuthRepository();

  bool _loading = false;
  String? _emailError;
  String? _passwordError;
  // サーバーやFirebaseからのエラー
  String? _message; 

  // メモリリークを起こさないように使った後に破棄
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  // 入力欄からテキストを取得
  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text;

    // 空欄チェック
    setState(() {
      _emailError = email.isEmpty ? 'メールアドレスを入力してください' : null;
      _passwordError = password.isEmpty ? 'パスワードを入力してください' : null;
      _message = null;
    });
    // 空欄がある場合は、ここでログイン処理をストップ
    if (email.isEmpty || password.isEmpty) return;

    // 画面を再描画
    setState(() => _loading = true);
    // メールとパスワードでログインを行う
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // 認証成功したらIDトークンを取得する
      final token = await cred.user!.getIdToken();
      // 取得したトークンをDjangoのAPIに送り、PostgreSQLにもユーザー登録されているか確認する
      final registered = await _repo.login(token!);
      // ここまでで画面がなかったらリターン
      if (!mounted) return;

      if (registered) {
        // DjangoのAPIでPostgreSQLにもユーザー登録されていることが分かった場合、タイムライン画面へ遷移する
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/timeline', (_) => false);
      } else {
        // Firebaseにはあるが、DBにいない → 登録画面でやり直す(Firebase作成は飛ばす)
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const RegisterPage(alreadySignedIn: true),
        ));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _message = _firebaseMessage(e.code));
    } on ApiException catch (e) {
      setState(() => _message = e.message);
    } catch (_) {
      setState(() => _message = '通信に失敗しました。ネットワークを確認してください');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _firebaseMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'メールアドレスの形式が正しくありません';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'メールアドレスまたはパスワードが違います';
      case 'too-many-requests':
        return '試行回数が多すぎます。しばらくしてからお試しください';
      default:
        return 'ログインに失敗しました($code)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      showBack: true,
      children: [
        const AuthTitle(
          title: 'ログイン',
          sub: 'メールアドレスとパスワードを入力してください',
        ),
        AuthField(
          label: 'メールアドレス',
          controller: _email,
          error: _emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {
            _emailError = null;
            _message = null;
          }),
        ),
        AuthField(
          label: 'パスワード',
          controller: _password,
          error: _passwordError,
          obscure: true,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {
            _passwordError = null;
            _message = null;
          }),
          onSubmitted: (_) => _login(),
        ),
        const SizedBox(height: 8),
        AuthButton(label: 'ログインする', loading: _loading, onPressed: _login),
        if (_message != null) AuthMessage(message: _message!),
        AuthSwitch(
          text: 'アカウントをお持ちでない方は',
          linkLabel: '新規登録',
          onTap: _loading
              ? null
              : () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
        ),
      ],
    );
  }
}
