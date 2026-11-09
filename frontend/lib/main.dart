import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth/page/auth_page.dart';
import 'firebase_options.dart'; // `flutterfire configure` で自動生成される あとでやってもらう
import 'component/navbar.dart' show MyHomePage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KakkoApp());
}

class KakkoApp extends StatelessWidget {
  const KakkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'kakko.',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(43, 32, 22, 1),
        ),
      ),
      home: const AuthPage(), // 最初の画面はログイン
      routes: {
        '/timeline': (_) => const MyHomePage(), // ナビゲーション付きのメイン画面
      },
    );
  }
}
