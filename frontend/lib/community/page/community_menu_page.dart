
import 'package:flutter/material.dart';

/// コミュニティデータ
class Community {
  final int id;
  final String name;
  final String work;
  final String description;
  final String members;
  final bool isJoined;
  final IconData icon;
  final Color color;

  const Community({
    required this.id,
    required this.name,
    required this.work,
    required this.description,
    required this.members,
    required this.isJoined,
    required this.icon,
    required this.color,
  });
}

/// コミュニティメニュー画面
class CommunityMenuPage extends StatefulWidget {
  const CommunityMenuPage({super.key});

  @override
  State<CommunityMenuPage> createState() =>
      _CommunityMenuPageState();
}

class _CommunityMenuPageState
    extends State<CommunityMenuPage> {

  // 画面表示用のデータ
  List<Community> _trendCommunities = [];
  List<Community> _recommendCommunities = [];

  // ミュートワード
  List<String> _muteWords = [];

  // 読み込み状態
  bool _loading = true;

  // エラーメッセージ
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  /// コミュニティデータの取得
  Future<void> _loadCommunities() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      // 仮データ（後でRepositoryから取得する）
      final trends = [
        const Community(
          id: 1,
          name: '灰と星屑 感想部',
          work: '灰と星屑',
          description: '',
          members: '1.2万人',
          isJoined: true,
          icon: Icons.star_border,
          color: Color(0xFF9B5134),
        ),
        const Community(
          id: 2,
          name: 'サイレント・チャプター部',
          work: 'サイレント・チャプター',
          description: '',
          members: '8,400人',
          isJoined: true,
          icon: Icons.menu_book_outlined,
          color: Color(0xFF64643B),
        ),
        const Community(
          id: 3,
          name: '夜想曲のリベルタを語る会',
          work: '夜想曲のリベルタ',
          description: '',
          members: '6,201人',
          isJoined: true,
          icon: Icons.nightlight_round,
          color: Color(0xFF3F5C87),
        ),
      ];

      final recommends = [
        const Community(
          id: 4,
          name: '花布の記憶 読書会',
          work: '花布の記憶',
          description: '灰と星屑 感想部と近いジャンルです',
          members: '',
          isJoined: false,
          icon: Icons.local_florist_outlined,
          color: Color(0xFF486A40),
        ),
      ];

      // API通信を行う場合はここで取得する
      // final trends = await _repo.getTrendCommunities();
      // final recommends = await _repo.getRecommendCommunities();
      // final muteWords = await _repo.getMuteWords();

      if (!mounted) return;

      setState(() {
        _trendCommunities = trends;
        _recommendCommunities = recommends;
        _muteWords = [];
      });

    } catch (_) {
      if (!mounted) return;

      setState(() {
        _message = 'コミュニティの取得に失敗しました';
      });

    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// ミュートワードの判定
  bool _isMuted(Community community) {
    final text =
        '${community.name} ${community.work} '
        '${community.description}'.toLowerCase();

    return _muteWords.any(
      (word) => word.isNotEmpty &&
          text.contains(word.toLowerCase()),
    );
  }

  /// コミュニティ詳細へ遷移
  void _openCommunity(Community community) {
    Navigator.of(context).pushNamed(
      '/community/detail',
      arguments: community.id,
    );
  }

  /// メニューカード
  Widget _menuCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF3B2B1D),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    const Color(0xFF59391F),
                child: Icon(
                  icon,
                  color: const Color(0xFFE9842B),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFFBEA88E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Color(0xFFBEA88E),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// コミュニティ一覧の1行
  Widget _communityTile(Community community) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          child: Row(
            children: [
              // コミュニティアイコン
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: community.color,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  community.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // コミュニティ情報
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment:
                          WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          community.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF50311D),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'オープン',
                            style: TextStyle(
                              color: Color(0xFFE9842B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      community.description.isNotEmpty
                          ? community.description
                          : '『${community.work}』 ・ '
                            '${community.members} ・ '
                            '参加中',
                      style: const TextStyle(
                        color: Color(0xFFBEA88E),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 参加状態によってボタンを変更
              ElevatedButton(
                onPressed: () =>
                    _openCommunity(community),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFE9842B),
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  community.isJoined
                      ? '見る'
                      : '参加する',
                ),
              ),
            ],
          ),
        ),

        const Divider(
          color: Color(0xFF453629),
        ),
      ],
    );
  }

  /// コミュニティセクション
  Widget _communitySection({
    required String title,
    required List<Community> communities,
  }) {
    // ミュートワードに該当するデータを除外
    final visibleCommunities = communities
        .where((community) => !_isMuted(community))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFBEA88E),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        if (visibleCommunities.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 20,
            ),
            child: Text(
              '該当するコミュニティがヒットしません。',
              style: TextStyle(
                color: Color(0xFFBEA88E),
              ),
            ),
          )
        else
          ...visibleCommunities.map(
            (community) =>
                _communityTile(community),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2017),

      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE9842B),
                ),
              )
            : _message != null
                ? Center(
                    child: Text(
                      _message!,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // タイトル
                        const Text(
                          'コミュニティ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          '好きな作品ごとにコミュニティをつくって、感想を語り合おう',
                          style: TextStyle(
                            color: Color(0xFFBEA88E),
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // メニュー
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cards = [
                              _menuCard(
                                icon: Icons.grid_view,
                                title: '参加コミュニティ一覧',
                                description:
                                    '参加中のコミュニティとタイムラインを見る',
                                onTap: () =>
                                    Navigator.of(context)
                                        .pushNamed(
                                  '/community/joined',
                                ),
                              ),
                              _menuCard(
                                icon: Icons.person_add_alt,
                                title: 'コミュニティ参加',
                                description:
                                    '新しいコミュニティを探して参加する',
                                onTap: () =>
                                    Navigator.of(context)
                                        .pushNamed(
                                  '/community/search',
                                ),
                              ),
                              _menuCard(
                                icon:
                                    Icons.add_circle_outline,
                                title: 'コミュニティ作成',
                                description:
                                    '好きな作品のコミュニティをつくる',
                                onTap: () =>
                                    Navigator.of(context)
                                        .pushNamed(
                                  '/community/create',
                                ),
                              ),
                            ];

                            if (constraints.maxWidth < 800) {
                              return Column(
                                children: cards,
                              );
                            }

                            return Row(
                              children: cards
                                  .map(
                                    (card) => Expanded(
                                      child: card,
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),

                        const SizedBox(height: 36),

                        // 話題のコミュニティ
                        _communitySection(
                          title: '話題のコミュニティ',
                          communities:
                              _trendCommunities,
                        ),

                        const SizedBox(height: 32),

                        // おすすめコミュニティ
                        _communitySection(
                          title: 'おすすめコミュニティ',
                          communities:
                              _recommendCommunities,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
