import 'package:flutter/material.dart';
import 'component/navbar.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    // ナビ付きの枠に、この画面の中身を渡す
    return Navbar(
      selectedIndex: NavIndex.search,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("検索画面"),
            // 通知テスト用
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/profile_test'),
              child: const Text('テスト、他人のプロフィールを開く　(DBをローカルでテストしている都合、阿部君しか動かないはず)'),
            ),
          ],
        ),
      ),
    );
  }
}