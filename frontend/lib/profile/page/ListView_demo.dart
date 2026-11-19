import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('ListView.builder with All Properties'),
        ),
        body: MyListView(),
      ),
    );
  }
}

class MyListView extends StatelessWidget {
  // リストアイテムの作成
  final List<String> items = List<String>.generate(20, (i) => "Item $i");

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length, // リストのアイテム数を指定
      // リストに表示するアイテムを表現
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${items[index]}'),
        );
      },
      scrollDirection: Axis.vertical, // スクロール方向を垂直に設定
      reverse: false, // 順序を逆にしない
      padding: EdgeInsets.all(8.0), // リスト全体に8ピクセルの余白を追加
      primary: true, // このリストがプライマリスクロールビューかどうかを指定
      shrinkWrap: false, // リストの高さをその内容に基づいて調整しない
      physics: BouncingScrollPhysics(), // スクロール挙動を指定
      addAutomaticKeepAlives: true, // 各アイテムが自動的に保持されるかどうかを指定
      addRepaintBoundaries: true, // 各アイテムが再描画境界を持つかどうかを指定
      addSemanticIndexes: true, // 各アイテムがセマンティックインデックスを持つかどうかを指定
    );
  }
}