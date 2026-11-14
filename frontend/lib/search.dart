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
    return const Navbar(
      selectedIndex: NavIndex.search,
      child: Center(
        child: Text("検索画面"),
      ),
    );
  }
}
