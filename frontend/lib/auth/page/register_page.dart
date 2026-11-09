import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repository/auth_repository.dart';
import '../widget/auth_widgets.dart';
import 'login_page.dart';

/// 新規登録画面
class RegisterPage extends StatefulWidget {
  /// true: Firebaseには作成済み(ログイン時に未登録と判定された場合など)
  final bool alreadySignedIn;

  const RegisterPage({super.key, this.alreadySignedIn = false});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _repo = AuthRepository();

  bool _loading = false;
  bool _firebaseDone = false; // Firebase作成済みなら、再試行時に作成を飛ばす
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _message;

  @override
  void initState() {
    super.initState();
    _firebaseDone = widget.alreadySignedIn;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// 入力チェック 問題がなければ true
  bool _validate() {
    final name = _name.text.trim();
    String? nameError;
    if (name.isEmpty) {
      nameError = 'ユーザー名を入力してください';
    } else if (name.length > 50) {
      nameError = 'ユーザー名は50文字以内で入力してください';
    }

    String? emailError;
    String? passwordError;
    String? confirmError;
    if (!_firebaseDone) {
      if (_email.text.trim().isEmpty) emailError = 'メールアドレスを入力してください';
      if (_password.text.isEmpty) passwordError = 'パスワードを入力してください';
      if (_confirm.text.isEmpty) {
        confirmError = '確認用のパスワードを入力してください';
      } else if (_confirm.text != _password.text) {
        confirmError = 'パスワードが一致しません';
      }
    }

    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmError = confirmError;
      _message = null;
    });
    return nameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmError == null;
  }

  Future<void> _register() async {
    if (!_validate()) return;

    setState(() => _loading = true);
    try {
      final auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      // Firebaseのアカウント作成(作成済みなら飛ばす = やり直し対応)
      if (!_firebaseDone || user == null) {
        final cred = await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        user = cred.user;
        _firebaseDone = true;
      }

      final token = await user!.getIdToken();
      await _repo.register(token!, _name.text.trim()); // Django: ユーザーDBに作成

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/timeline', (_) => false);
    } on FirebaseAuthException catch (e) {
      _showFirebaseError(e.code);
    } on ApiException catch (e) {
      // Firebaseは作成済み。もう一度押せば、register だけが再実行される
      setState(() => _message = '${e.message}。もう一度「登録する」を押してください');
    } catch (_) {
      setState(() => _message = '通信に失敗しました。もう一度「登録する」を押してください');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showFirebaseError(String code) {
    setState(() {
      switch (code) {
        case 'email-already-in-use':
          _emailError = 'このメールアドレスはすでに登録されています';
          break;
        case 'invalid-email':
          _emailError = 'メールアドレスの形式が正しくありません';
          break;
        case 'weak-password':
          _passwordError = 'パスワードは6文字以上にしてください';
          break;
        default:
          _message = '登録に失敗しました($code)';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      showBack: true,
      children: [
        AuthTitle(
          title: '新規登録',
          sub: _firebaseDone
              ? 'ユーザー名を決めてください'
              : 'ユーザー名、メールアドレス、パスワードを決めてください',
        ),
        AuthField(
          label: 'ユーザー名',
          controller: _name,
          error: _nameError,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {
            _nameError = null;
            _message = null;
          }),
        ),
        if (!_firebaseDone) ...[
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
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {
              _passwordError = null;
              _confirmError = null;
              _message = null;
            }),
          ),
          AuthField(
            label: 'パスワード(確認)',
            controller: _confirm,
            error: _confirmError,
            obscure: true,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {
              _confirmError = null;
              _message = null;
            }),
            onSubmitted: (_) => _register(),
          ),
        ],
        const SizedBox(height: 8),
        AuthButton(label: '登録する', loading: _loading, onPressed: _register),
        if (_message != null) AuthMessage(message: _message!),
        AuthSwitch(
          text: 'すでにアカウントをお持ちの方は',
          linkLabel: 'ログイン',
          onTap: _loading
              ? null
              : () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
        ),
      ],
    );
  }
}
