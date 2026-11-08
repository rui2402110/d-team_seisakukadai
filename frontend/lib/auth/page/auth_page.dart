import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../repository/auth_repository.dart';
import 'register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repo = AuthRepository();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      final token = await cred.user!.getIdToken();
      final registered = await _repo.login(token!);
      if (!mounted) return;
      if (registered) {
        Navigator.of(context).pushReplacementNamed('/timeline');
      } else {
        // Firebaseにはあるが、DBにいない → 登録画面でやり直す(Firebase作成は飛ばす)
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const RegisterPage(alreadySignedIn: true),
        ));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _firebaseMessage(e.code));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = '通信に失敗しました。ネットワークを確認してください');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _firebaseMessage(String code) {
    switch (code) {
      case 'invalid-email': return 'メールアドレスの形式が正しくありません';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential': return 'メールアドレスまたはパスワードが違います';
      case 'too-many-requests': return '試行回数が多すぎます。しばらくしてからお試しください';
      default: return 'ログインに失敗しました($code)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'メールアドレス'),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'パスワード'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('ログイン'),
              ),
              TextButton(
                // 1. バックエンドの動きなし
                onPressed: _loading
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterPage())),
                child: const Text('新規登録はこちら'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}