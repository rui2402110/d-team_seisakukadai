import 'package:flutter/material.dart';
import '../../component/navbar.dart';
import '../repository/profile_repository.dart';

class Profile extends StatefulWidget {
  final String? user_id;
  const Profile({super.key,this.user_id});
  

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> 
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(
    length: 5, //タブ数
    vsync: this, //アニメーション同期用
  );
  late Future<Map<String, dynamic>> _userProfileFuture;

  String? get user_id => widget.user_id;

  Future<Map<String, dynamic>> _UserProfile(String? user_id) async {
    // Django APIからプロフィールを取得
    return await ProfileRepository().getUserProfile(userId:user_id);
  }

  @override
  void initState(){
    super.initState();
    _userProfileFuture = _UserProfile(user_id);
    
  }

  @override
  void didUpdateWidget(covariant Profile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user_id != widget.user_id) {
      setState(() {
        _userProfileFuture = _UserProfile(widget.user_id);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navbar(
      selectedIndex: null,
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _userProfileFuture,
            builder: (context, snapshot) {
              // Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error
              if (snapshot.hasError) {
                return Center(
                  child: Text('エラーが発生しました:\n${snapshot.error}'),
                );
              }

              // データが取得できなかった
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('データが見つかりません'));
              }

              // データ取得
              final data = snapshot.data!;
              final user = data['user'];
              final bool isMe = data['is_me'];
              final DateTime d = DateTime.parse(user['created_at']);
          
              // アイコンURLの取得（nullならデフォルトや空文字）
              final String iconUrl = user['icon_url'] ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      spacing: 10,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          splashRadius: 20.0,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Text("投稿128件", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  ),
                  //----------------------------------------------------
                  Container(
                    margin: const EdgeInsets.only(bottom: 50),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 100,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepOrange,
                                Colors.black,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          left: 10,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: iconUrl.isNotEmpty 
                                ? NetworkImage(iconUrl) 
                                : const NetworkImage('https://picsum.photos/200/300') as ImageProvider,
                          ),
                        ),
                        if (isMe)...{
                          Positioned(
                            right: 10,
                            top: 110,
                            child: ElevatedButton(
                              onPressed: () {}, 
                              child: const Text("プロフィールを編集"),
                            ),
                          )
                        } else...{
                          Positioned(
                            right: 10,
                            top: 110,
                            child: 
                              ElevatedButton(
                                onPressed: () async {
                                  print("aaaaaaaa");
                                  // 現在のフォロー状態を保存
                                  final bool oldFollow = user['is_follow'] ?? false;
                                  final int oldCount = user['follower_count'] ?? 0;

                                  // フォロー・解除後の状態
                                  final bool newFollow = !oldFollow;

                                  // 画面を先に更新
                                  setState(() {
                                    user['is_follow'] = newFollow;
                                    user['follower_count'] = oldCount + (newFollow ? 1 : -1);
                                  });

                                  try {
                                    await ProfileRepository().followUser(
                                      userId: user['user_id'].toString(),
                                      follow: newFollow,
                                    );
                                  } catch (e) {
                                    // DB更新に失敗した場合は元に戻す
                                    if (!mounted) return;

                                    setState(() {
                                      user['is_follow'] = oldFollow;
                                      user['follower_count'] = oldCount;
                                    });

                                    print('フォロー処理エラー: $e');
                                  }
                                },
                                child: Text(
                                  (user['is_follow'] ?? false) ? "フォロー中" : "フォロー",
                                ),
                              ),

                          )
                        }
                      ],
                    ),
                  ),
                  //-----------------------------------------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 名前
                        Text(
                          user['name'] ?? "",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        // ユーザーID
                        Text(
                          "@${user['user_id'] ?? ""}",
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        if(user['bio'] != null || user['bio'].isNotEmpty)
                          // 自己紹介文
                          Text(
                            user['bio'] ?? "自己紹介はありません。",
                            style: const TextStyle(height: 1.4),
                            softWrap: true, 
                          ),
                        const SizedBox(height: 12),
                        
                        // ウェブサイト ＆ 利用開始日
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            if (user['link'] != null && user['link'].toString().isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.link, size: 18, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    user['link'],
                                    style: const TextStyle(color: Colors.blue, fontSize: 13),
                                  ),
                                ],
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                   
                                  ("${d.year}年${d.month}月から利用中"),
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // フォロー / フォロワー数
                        const Row(
                          spacing: 16,
                          children: [
                            Row(
                              spacing: 4,
                              children: [
                                Text("1", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text("フォロー中", style: TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                            Row(
                              spacing: 4,
                              children: [
                                Text("0", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text("フォロワー", style: TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  //-----------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: '投稿'),
                            Tab(text: '返信'),
                            Tab(text: 'メディア'),
                            Tab(text: '作品'),
                            Tab(text: 'いいね'),
                          ],
                        ),
                        SizedBox(
                          height: 300,
                          child: TabBarView(
                            controller: _tabController,
                            children: const [
                              Center(child: Text("投稿")),
                              Center(child: Text("返信")),
                              Center(child: Text("メディア")),
                              Center(child: Text("作品")),
                              Center(child: Text("いいね")),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}