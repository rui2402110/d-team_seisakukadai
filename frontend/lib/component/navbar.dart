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
  bool profile = false;

  final List<Map<String, dynamic>> navList = [
    {
      "label": "タイムライン",
      "icon": Icons.notes,
    },
    {
      "label": "検索",
      "icon": Icons.search,
    },
    {
      "label": "作品",
      "icon": Icons.menu_book,
    },
    {
      "label": "コミュニティ",
      "icon": Icons.people,
    },
    {
      "label": "通知",
      "icon": Icons.notifications,
    },
    {
      "label": "設定",
      "icon": Icons.settings,
    },
  ];

  Widget getCurrentPage() {
    switch (selectedIndex) {
      case 0:
        return const Timeline();

      case 1:
        return Search();

      case 2:
        return Work();

      case 3:
        return Community();

      case 4:
        return UserNotification();

      case 5:
        return Setting();

      default:
        return const Timeline();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Image.asset(
                        'assets/images/orbit.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Kakko.",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: navList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(navList[index]["icon"]),
                        title: Text(navList[index]["label"]),
                        selected: selectedIndex == index,
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                            profile = false;
                          });
                        },
                      );
                    },
                  ),
                ),

                SizedBox(
                  width: double.infinity,
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
                        profile = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(width: 1),

          Expanded(
            child: profile
            ? Profile()
            : getCurrentPage()
          ),
        ],
      ),
    );
  }
}