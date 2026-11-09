import 'package:flutter/material.dart';
import '../timeline/page/timeline_page.dart';
import '../profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NavigationRail Sample',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(43, 32, 22, 1),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0 ;
  bool _showProfile = false;

  final List<Widget> _pages = [
    Timeline(),
    const Center(
      child: Text(
        '検索画面',
        style: TextStyle(fontSize: 24),
      ),
    ),
    const Center(
      child: Text(
        '作品画面',
        style: TextStyle(fontSize: 24),
      ),
    ),
    const Center(
      child: Text(
        'コミュニティ画面',
        style: TextStyle(fontSize: 24),
      ),
    ),
    const Center(
      child: Text(
        '通知画面',
        style: TextStyle(fontSize: 24),
      ),
    ),
    const Center(
      child: Text(
        '設定画面',
        style: TextStyle(fontSize: 24),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            // minWidth: 56.0, 
            extended: true,
            selectedIndex: _selectedIndex >= 0
              ? _selectedIndex
              : null,
            onDestinationSelected: (int index) {
              setState(() {
                _showProfile = false;
                _selectedIndex = index;
              });
            },
            leading: SizedBox(
              width: 200,
              child: Row(
                children: [
                  Image.asset('assets/images/orbit.png'),
                  Text(" Kakko.",style: TextStyle(fontSize: 24.0),),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.notes),
                selectedIcon: Icon(Icons.notes),
                label: Text('タイムライン'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.search),
                label: Text('検索'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book),
                selectedIcon: Icon(Icons.menu_book),
                label: Text('作品'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('コミュニティ'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_none),
                selectedIcon: Icon(Icons.notifications),
                label: Text('通知'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                selectedIcon: Icon(Icons.settings),
                label: Text('設定'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
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
                        _showProfile = true;
                        _selectedIndex= -1;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),

          const VerticalDivider(width: 1),

          Expanded(
            child: _showProfile
                ? Profile()
                : _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}