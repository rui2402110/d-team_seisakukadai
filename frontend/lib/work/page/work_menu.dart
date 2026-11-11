
import 'package:flutter/material.dart';

class Work extends StatelessWidget {

  const Work({super.key});

  static const Color bg = Color(0xFF2D2016);
  static const Color sidebar = Color(0xFF302116);
  static const Color card = Color(0xFF3A2A1B);
  static const Color orange = Color(0xFFE9782B);
  static const Color mainText = Color(0xFFE9D9C6);
  static const Color subText = Color(0xFFB5A18A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [


          // 右側メイン画面
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    16, 17, 16, 20,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFF493729),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '作品',
                        style: TextStyle(
                          color: mainText,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '好きな作品を投稿したり、見つけたりしよう',
                        style: TextStyle(
                          color: subText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // メインコンテンツ
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16, 18, 16, 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 検索欄
                        Container(
                          height: 33,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B2B1B),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF594531),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              Icon(
                                Icons.search,
                                size: 15,
                                color: subText,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '作品名やあらすじで検索（デモ）',
                                style: TextStyle(
                                  color: subText,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 11),

                        // マイ作品・作品投稿
                        Row(
                          children: [
                            Expanded(
                              child: _actionCard(
                                Icons.grid_view,
                                'マイ作品',
                                '投稿した作品を管理する',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _actionCard(
                                Icons.upload,
                                '作品投稿',
                                '新しい作品を投稿する',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // カテゴリ
                        Row(
                          children: [
                            _tab('すべて', true),
                            _tab('文字', false),
                            _tab('画像', false),
                            _tab('動画', false),
                          ],
                        ),

                        const SizedBox(height: 19),

                        // おすすめ作品
                        const Text(
                          'おすすめ作品',
                          style: TextStyle(
                            color: mainText,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        // 作品一覧
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return GridView.count(
                                crossAxisCount: 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 12,
                                childAspectRatio:
                                    constraints.maxWidth /
                                    3 /
                                    235,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                children: const [
                                  _WorkCard(
                                    title: '灰と星屑',
                                    author: 'つむぎ',
                                    views: '8.4万',
                                    colors: [
                                      Color(0xFFD87939),
                                      Color(0xFF74392B),
                                    ],
                                  ),
                                  _WorkCard(
                                    title: 'サイレント・チャプター',
                                    author: '海野',
                                    views: '5.1万',
                                    colors: [
                                      Color(0xFF858B5C),
                                      Color(0xFF49371F),
                                    ],
                                  ),
                                  _WorkCard(
                                    title: '夜想曲のリベルタ',
                                    author: 'はると',
                                    views: '3.9万',
                                    colors: [
                                      Color(0xFF607FAB),
                                      Color(0xFF29384E),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // サイドバーメニュー
  static Widget _menu(
    IconData icon,
    String title, {
    bool selected = false,
    bool notification = false,
  }) {
    return Container(
      height: 31,
      margin: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF50321B)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 13,
                color: selected ? orange : subText,
              ),
              if (notification)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: selected ? orange : subText,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // マイ作品・作品投稿
  static Widget _actionCard(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF554331),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF58371D),
            child: Icon(
              icon,
              size: 13,
              color: orange,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: mainText,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subText,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: subText,
            size: 15,
          ),
        ],
      ),
    );
  }

  // カテゴリタブ
  static Widget _tab(String title, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: selected ? orange : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? mainText : subText,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// 作品カード
class _WorkCard extends StatelessWidget {
  final String title;
  final String author;
  final String views;
  final List<Color> colors;

  const _WorkCard({
    required this.title,
    required this.author,
    required this.views,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3A2A1B),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFF554331),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.star_border,
                    color: Color(0xFFFFE9D0),
                    size: 34,
                  ),

                  Positioned(
                    top: 7,
                    left: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF59432F),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        '小説',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const Positioned(
                    top: 7,
                    right: 7,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0xFF443323),
                      child: Icon(
                        Icons.star_border,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            height: 48,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              12, 7, 8, 5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE9D9C6),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$author ・ 閲覧 $views',
                  style: const TextStyle(
                    color: Color(0xFFB5A18A),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
