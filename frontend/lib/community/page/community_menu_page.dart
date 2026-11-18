import 'package:flutter/material.dart';

import '../repository/community_repository.dart';

import '../../component/navbar.dart';
import '../../core/breakpoints.dart';

/// Django APIから取得したコミュニティデータ
class Community {
  final int id;
  final String name;
  final String work;
  final String description;
  final String members;
  final String iconUrl;
  final int communityType;
  final IconData icon;
  final Color color;

  const Community({
    required this.id,
    required this.name,
    required this.work,
    required this.description,
    required this.members,
    required this.iconUrl,
    required this.communityType,
    required this.icon,
    required this.color,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      work: json['target']?.toString() ?? '',
      description: json['detail']?.toString() ?? '',
      members: '${json['member_count'] ?? 0}人',
      iconUrl: json['icon_url']?.toString() ?? '',
      communityType: (json['community_type'] as num?)?.toInt() ?? 1,
      icon: Icons.groups_outlined,
      color: const Color(0xFF9B5134),
    );
  }
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

  final CommunityRepository _repo = CommunityRepository();

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

  /// Repositoryからコミュニティ一覧を取得
  Future<void> _loadCommunities() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final communityData = await _repo.getAllCommunities();
      final communities = communityData
          .map((data) => Community.fromJson(data))
          .toList();

      if (!mounted) return;
      setState(() {
        // 話題・おすすめの分類APIが未実装のため、全件を一覧に表示
        _trendCommunities = communities;
        _recommendCommunities = [];
        _muteWords = [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'コミュニティの取得に失敗しました: $e';
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
                clipBehavior: Clip.antiAlias,
                child: community.iconUrl.isEmpty
                    ? Icon(community.icon, color: Colors.white, size: 28)
                    : Image.network(
                        community.iconUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(community.icon, color: Colors.white, size: 28),
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
                          : '『${community.work}』 ・ ${community.members}',
                      style: const TextStyle(
                        color: Color(0xFFBEA88E),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 参加状態の取得は未実装のため詳細画面へ遷移
              ElevatedButton(
                onPressed: () =>
                    _openCommunity(community),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFE9842B),
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                ),
                child: const Text('見る'),
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
    // ナビ付きの枠に、この画面の中身を渡す
    return Navbar(
      selectedIndex: NavIndex.community,
      child: Scaffold(
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

                            if (constraints.maxWidth < kContentWideBreakpoint) {
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

                        // おすすめデータが取得できたときのみ表示
                        if (_recommendCommunities.isNotEmpty)
                          _communitySection(
                            title: 'おすすめコミュニティ',
                            communities: _recommendCommunities,
                          ),
                      ],
                    ),
                  ),
      ),
    ));
  }
}