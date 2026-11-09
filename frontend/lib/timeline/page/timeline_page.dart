// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});
  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  // 取得した内容を保持するリスト
  List<Map<String, dynamic>> contents = [];
  // DBからすべて取得する
  Future<void> _loadData() async {
    print("loadData");
  }

  @override
  void initState(){
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("simpleSNS"),
      ),
      body: Column(
        children: [
          Expanded(
            child: contents.isNotEmpty
                ? ListView(
                    children: contents.map((doc) {
                      return ListTile(
                        title: Text(doc['name'] ?? ''),
                        subtitle: Text(doc['text'] ?? ''),
                      );
                    }).toList(),
                  )
                : const Center( 
                    child: Text("投稿がありません"),
                  ),
          ),

        ],
      ),
      
    );
  }
}
