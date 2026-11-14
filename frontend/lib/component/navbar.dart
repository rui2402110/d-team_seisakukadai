import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import '../core/kakko_theme.dart';

/// ナビの項目の番号。各画面が「自分は何番目か」を Navbar に伝えるために使う
/// (例: Navbar(selectedIndex: NavIndex.work, child: ...))
class NavIndex {
  static const timeline = 0;
  static const search = 1;
  static const work = 2;
  static const community = 3;
  static const setting = 4;
  static const notification = 5;
}

/// ナビの1項目(表示名・アイコン・移動先のルート名)
class _NavItem {
  final String label;
  final IconData icon;
  final String route; // main.dart の routes と同じ名前にする
  const _NavItem(this.label, this.icon, this.route);
}

// 並び順は NavIndex の番号と同じにする
const List<_NavItem> _navItems = [
  _NavItem('タイムライン', Icons.notes, '/timeline'),
  _NavItem('検索', Icons.search, '/search'),
  _NavItem('作品', Icons.menu_book, '/work'),
  _NavItem('コミュニティ', Icons.people, '/community'),
  _NavItem('設定', Icons.settings, '/setting'),
  _NavItem('通知', Icons.notifications, '/notification'),
];

/// ナビゲーション付きの画面の枠(部品)
/// 各画面が、自分の中身を child に渡して使う。画面の切り替えは Navigator が行う
class Navbar extends StatelessWidget {
  /// 選択中の項目(NavIndex)。プロフィールなど、どれも選択しない画面は null
  final int? selectedIndex;

  /// ナビの右側に表示する、画面の中身
  final Widget child;

  const Navbar({
    super.key,
    required this.selectedIndex,
    required this.child,
  });

  /// 別の画面へ移動する(それまでの履歴は消す = 3度目4度目でも画面が積み重ならない)
  void _goTo(BuildContext context, String route) {
    // いま表示している画面と同じ場合は何もしない
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }

  /// プロフィール画面を開く(戻るボタンで戻れるように、履歴は残す)
  void _openProfile(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name == '/profile') return;
    Navigator.of(context).pushNamed('/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 狭い画面(スマホなど)の場合
          if (constraints.maxWidth < kWideBreakpoint) {
            // TODO(学習用・スマホ対応): ここで「フリックで開くメニュー」に切り替える。
            //   Scaffold の drawer に _buildSidebar(context) を渡して配置すると、
            //   画面の左端からのフリック(スワイプ)でメニューが開く。
            //   例: return Scaffold(
            //         appBar: AppBar(),
            //         drawer: Drawer(child: _buildSidebar(context)),
            //         body: child,
            //       );
            //   いまは広い画面と同じ表示のままにしている。
          }

          // 広い画面: 左にサイドバー、右に画面の中身
          return Row(
            children: [
              // kakko_Theme.dart を適用し、カラーを指定
              Theme(
                data: kakkoTheme(),
                child: Material(
                  color: KakkoColors.ink,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 260,
                        child: _buildSidebar(context),
                      ),
                      const VerticalDivider(
                        width: 1,
                        color: KakkoColors.inkLine,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          );
        },
      ),
    );
  }

  /// サイドバー(ロゴ・項目・ユーザー名)
  Widget _buildSidebar(BuildContext context) {
    return Column(
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
                'Kakko.',
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
            itemCount: _navItems.length,
            itemBuilder: (context, index) {
              final item = _navItems[index];
              return ListTile(
                // 通知だけバッジ付き(いまは固定値)
                leading: item.route == '/notification'
                    ? Badge(
                        label: const Text('99+'),
                        isLabelVisible: true,
                        child: Icon(item.icon),
                      )
                    : Icon(item.icon),
                title: Text(item.label),
                selected: selectedIndex == index,
                onTap: () => _goTo(context, item.route),
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
            onTap: () => _openProfile(context),
          ),
        ),
      ],
    );
  }
}
