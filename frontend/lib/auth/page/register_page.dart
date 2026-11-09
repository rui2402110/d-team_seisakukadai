import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../repository/auth_repository.dart';

class RegisterPage extends StatefulWidget {
  /// true: Firebaseには作成済み(ログイン時に未登録と判定された場合)
  final bool alreadySignedIn;
  const RegisterPage({super.key, this.alreadySignedIn = false});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repo = AuthRepository();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _name.text.trim();
    if (name.isEmpty || name.length > 50) {
      setState(() => _error = '名前は1〜50文字で入力してください');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      // Firebaseのアカウント作成(作成済みなら飛ばす = やり直し対応)
      if (!widget.alreadySignedIn || user == null) {
        final cred = await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        user = cred.user;
      }

      final token = await user!.getIdToken();
      await _repo.register(token!, name); // Django: ユーザーDBに作成

      if (!mounted) return;
      // 3. 戻り先の履歴を消してタイムラインへ
      Navigator.of(context).pushNamedAndRemoveUntil('/timeline', (_) => false);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _firebaseMessage(e.code));
    } on ApiException catch (e) {
      // Firebaseは作成済み。もう一度押せば、Firebase作成を飛ばして再試行する
      setState(() => _error = '${e.message}。もう一度「新規登録」を押してください');
      _markFirebaseDone();
    } catch (_) {
      setState(() => _error = '通信に失敗しました。ネットワークを確認してください');
      _markFirebaseDone();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Django側で失敗しても、Firebaseのアカウントは残っているため、次の押下で作成を飛ばす
  void _markFirebaseDone() {
    if (FirebaseAuth.instance.currentUser != null && !widget.alreadySignedIn) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => const RegisterPage(alreadySignedIn: true),
      ));
    }
  }

  String _firebaseMessage(String code) {
    switch (code) {
      case 'email-already-in-use': return 'このメールアドレスはすでに登録されています';
      case 'weak-password': return 'パスワードは6文字以上にしてください';
      case 'invalid-email': return 'メールアドレスの形式が正しくありません';
      default: return '登録に失敗しました($code)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = widget.alreadySignedIn;
    return Scaffold(
      appBar: AppBar(title: const Text('新規登録')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: '表示名'),
              ),
              if (!signedIn) ...[
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
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('新規登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}