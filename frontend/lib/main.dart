import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth/page/auth_gate.dart';
import 'community/page/community_menu_page.dart';
import 'firebase_options.dart'; // `flutterfire configure` で自動生成される あとでやってもらう
import 'notification.dart';
import 'profile.dart';
import 'search.dart';
import 'setting.dart';
import 'timeline/page/timeline_page.dart';
import 'work/page/work_menu.dart';


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
      home: const AuthGate(), // 最初の画面: ログイン済みならタイムライン、未ログインなら入口の画面
      // ナビから移動する画面。各画面が Navbar(枠)を自分で使う
      // ルート名は component/navbar.dart の _navItems と同じにする
      routes: {
        '/timeline': (_) => const Timeline(),
        '/search': (_) => const Search(),
        '/work': (_) => const WorkMenuPage(),
        '/community': (_) => const CommunityMenuPage(),
        '/setting': (_) => const Setting(),
        '/notification': (_) => const UserNotification(),
        '/profile': (_) => const Profile(),
      },
    );
  }
}
