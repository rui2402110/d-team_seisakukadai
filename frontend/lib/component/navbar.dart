import 'package:flutter/material.dart';
import '../timeline/page/timeline_page.dart';
import '../../search.dart';
import '../../work.dart';
import '../../community.dart';
import '../../notification.dart';
import '../../setting.dart';
import '../profile.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});
  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int? selectedIndex ;

  List<Map<String, dynamic>> navList = [
    {
      "label": "タイムライン",
      "icon": Icons.notes,
      "page": Timeline(),
    },
    {
      "label": "検索",
      "icon": Icons.search,
      "page": Search(),
    },
    {
      "label": "作品",
      "icon": Icons.menu_book,
      "page": Work(),
    },
    {
      "label": "コミュニティ",
      "icon": Icons.people,
      "page": Community(),
    },
    {
      "label": "通知",
      "icon": Icons.notifications,
      "page": UserNotification(),
    },
    {
      "label": "設定",
      "icon": Icons.settings,
      "page": Setting(),
    },
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(width: 10,),
                Image.asset('assets/images/orbit.png'),
                Text(" Kakko.",style: TextStyle(fontSize: 24.0),),
              ],
            ),
          ),

          for (int i = 0; i < navList.length; i++)
            ListTile(
              leading: Icon(navList[i]["icon"]),
              title: Text(navList[i]["label"]),
              selected: selectedIndex == i,
              onTap: () {
                setState(() {
                  selectedIndex = i;
                  navList[i]["page"];
                });
              },
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  width: 200,
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/200/300',
                      ),
                    ),
                    title: const Text('ユーザー名'),
                    subtitle: const Text('@user'),
                    onTap: () {
                      setState(() {
                        selectedIndex = null;
                        Profile();
                      });
                    },
                  ),
                ),
              ),
            ),
        ],
        
      ),
    );
  }
}