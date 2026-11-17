import 'package:flutter/material.dart';

import '../../component/navbar.dart';
import '../../core/kakko_theme.dart';
import '../../core/api_client.dart';
import '../repository/work_repository.dart';

// 作品のいいね情報を表示する画面
class WorkLikePage extends StatefulWidget {
  // 作品一覧・作品詳細から受け取る作品情報(id か pk を持っていること)
  final Map<String, dynamic> work;

  const WorkLikePage({
    super.key,
    required this.work,
  });

  @override
  State<WorkLikePage> createState() => _WorkLikePageState();
}

class _WorkLikePageState extends State<WorkLikePage> {
  // 区切り線の色だけ、この画面専用
  static const Color line = Color(0xFF49382A);

  // ==============================
  // APIからいいね情報を取得
  // ==============================

  late Future<Map<String, dynamic>> _likeFuture;

  @override
  void initState() {
    super.initState();

    // 画面表示時にいいね情報を取得
    _likeFuture = _loadWorkLike();
  }

  Future<Map<String, dynamic>> _loadWorkLike() async {
    final workId = widget.work['id'] ?? widget.work['pk'];

    if (workId == null) {
      throw ApiException('作品IDがありません');
    }

    // (ログイン確認とIDトークンの取得は WorkRepository の中で行う)
    return WorkRepository().getWorkLike(workId);
  }

  // 作品タイプ → ジャンル名
  String _genre(dynamic type) {
    switch ((type as num?)?.toInt()) {
      case 1:
        return '小説';
      case 2:
        return '画像';
      case 3:
        return '動画';
      default:
        return '作品';
    }
  }

  // ==============================
  // 画面全体
  // ==============================

  @override
  Widget build(BuildContext context) {
    return Navbar(
      selectedIndex: NavIndex.work,
      child: Scaffold(
        backgroundColor: KakkoColors.ink,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _likeFuture,
                  builder: (context, snapshot) {
                    // 読み込み中
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: KakkoColors.accent,
                        ),
                      );
                    }

                    // エラー
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: KakkoColors.accent,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'いいね情報の取得に失敗しました\n${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: KakkoColors.paperText,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _likeFuture = _loadWorkLike();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: KakkoColors.accent,
                                  foregroundColor: KakkoColors.ink,
                                ),
                                child: const Text('再読み込み'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // データが存在しない場合
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(
                          'いいね情報がありません',
                          style: TextStyle(color: KakkoColors.muted),
                        ),
                      );
                    }

                    return _buildBody(snapshot.data!);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // ヘッダー
  // ==============================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back,
              color: KakkoColors.muted,
              size: 17,
            ),
            SizedBox(width: 5),
            Text(
              '作品',
              style: TextStyle(
                color: KakkoColors.muted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // 本体(workLikeViewの値を表示)
  // ==============================

  Widget _buildBody(Map<String, dynamic> data) {
    final work = Map<String, dynamic>.from(
      (data['work'] as Map?) ?? {},
    );
    final user = Map<String, dynamic>.from(
      (data['user'] as Map?) ?? {},
    );
    final likeCount = (data['likecount'] as num?)?.toInt() ?? 0;
    final liked = data['liked'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 作品情報
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KakkoColors.inkSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _genre(work['work_type']),
                  style: const TextStyle(
                    color: KakkoColors.accent,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  work['title']?.toString() ?? 'タイトルなし',
                  style: const TextStyle(
                    color: KakkoColors.paperText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '投稿日: ${work['created_at'] ?? '不明'}',
                  style: const TextStyle(
                    color: KakkoColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // いいね数
          Center(
            child: Column(
              children: [
                Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked
                      ? KakkoColors.accent
                      : KakkoColors.paperText,
                  size: 56,
                ),
                const SizedBox(height: 10),
                Text(
                  '$likeCount',
                  style: const TextStyle(
                    color: KakkoColors.paperText,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'いいね',
                  style: TextStyle(
                    color: KakkoColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: line),
          const SizedBox(height: 12),

          // ログイン中ユーザーの状態
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: KakkoColors.accent,
                child: Icon(
                  Icons.person,
                  color: KakkoColors.ink,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name']?.toString() ?? 'ユーザー',
                      style: const TextStyle(
                        color: KakkoColors.paperText,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      liked
                          ? 'この作品にいいね済みです'
                          : 'この作品にはまだいいねしていません',
                      style: const TextStyle(
                        color: KakkoColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
