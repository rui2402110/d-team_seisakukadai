// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../component/navbar.dart';
import '../../core/kakko_theme.dart';
import '../repository/timeline_repository.dart';
import '../../component/postTile.dart';

class Timeline extends StatefulWidget {
  const Timeline({super.key});
  @override
  State<Timeline> createState() => _TimelineState();
}
class _TimelineState extends State<Timeline> 
  with SingleTickerProviderStateMixin {
    // 全てのコミュニティータイムライン
    Future<List<TimelineModel>> _getTimeline()async{
      return await TimelineRepository().getTimeline();
    }
    // お気に入りコミュニティ
    Future<List<CommunityModel>> _getMyCommunity()async{
      return await TimelineRepository().getMyCommunity();
    }
    late Future<List<TimelineModel>> _allTimelineFuture;
    late Future<List<CommunityModel>> _myCommunityFuture;
  
  //-------------------------------------------------
  final _postController = TextEditingController();//投稿内容
  bool icons = false;

  @override
  void dispose() {//リソース解放
    _postController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    _allTimelineFuture = _getTimeline();
    _myCommunityFuture = _getMyCommunity();
  }

  Future<void> refreshTimeline() async {
    setState(() {
      _allTimelineFuture = _getTimeline();
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return Navbar(
      selectedIndex: NavIndex.timeline,
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: Future.wait([
                _getMyCommunity(),
                _getTimeline(),
              ]),
              builder: (context, snapshot) {
                /// Loading
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: KakkoColors.accent,
                    ),
                  );
                }

                /// Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "エラーが発生しました\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: KakkoColors.errorText,
                      ),
                    ),
                  );
                }

                /// データなし
                if (!snapshot.hasData ||
                    snapshot.data == null) {
                  return const Center(
                    child: Text(
                      "データが見つかりません",
                      style: TextStyle(
                        color: KakkoColors.muted,
                      ),
                    ),
                  );
                }

                final communities =
                    snapshot.data![0]
                        as List<CommunityModel>;

                final posts =
                    snapshot.data![1]
                        as List<TimelineModel>;

                return Container(
                  decoration: BoxDecoration(
                    color: KakkoColors.inkSoft,
                    border: Border.all(
                      color: KakkoColors.inkLine,
                    ),
                  ),
                  child: DefaultTabController(
                    length: communities.length + 1,
                    child: Column(
                      children: [
                        TabBar(
                          isScrollable: true,

                          labelColor:
                              KakkoColors.accent,

                          unselectedLabelColor:
                              KakkoColors.muted,

                          dividerColor:
                              Colors.transparent,

                          indicator: const UnderlineTabIndicator(
                            borderSide: BorderSide(
                              color:
                                  KakkoColors.accent,
                              width: 3,
                            ),
                          ),

                          tabs: [
                            const Tab(
                              text: "フォロー",
                            ),
                            ...communities.map(
                              (c) => Tab(
                                text: c.name,
                              ),
                            ),
                          ],
                        ),

                        Expanded(
                          child: TabBarView(
                            children: [
                              /// フォロータブ
                              RefreshIndicator(
                                color:
                                    KakkoColors.accent,

                                onRefresh:
                                    refreshTimeline,

                                child: posts.isEmpty
                                    ? const Center(
                                        child: Text(
                                          "投稿がありません",
                                          style:
                                              TextStyle(
                                            color:
                                                KakkoColors
                                                    .muted,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),

                                        itemCount:
                                            posts.length,

                                        itemBuilder:
                                            (context,
                                                index) {
                                          return PostTile(
                                            post:posts[index],
                                            onReplySuccess: () {
                                              setState(() {
                                                _allTimelineFuture = _getTimeline();
                                              });
                                            },
                                          );
                                        },
                                      ),
                              ),

                              /// コミュニティ別タブ
                              ...communities.map(
                                (community) {
                                  final filteredPosts =
                                      posts.where(
                                    (post) {
                                      return post.communityId ==
                                              community
                                                  .communityId &&
                                          post.replyId ==
                                              0;
                                    },
                                  ).toList();

                                  if (filteredPosts
                                      .isEmpty) {
                                    return const Center(
                                      child: Text(
                                        "投稿がありません",
                                        style:
                                            TextStyle(
                                          color:
                                              KakkoColors
                                                  .muted,
                                        ),
                                      ),
                                    );
                                  }

                                  return RefreshIndicator(
                                    color:
                                        KakkoColors
                                            .accent,

                                    onRefresh:
                                        refreshTimeline,

                                    child:
                                        ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),

                                      itemCount:
                                          filteredPosts
                                              .length,

                                      itemBuilder:
                                          (context,
                                              index) {
                                        return PostTile(
                                          post:
                                              filteredPosts[
                                                  index],
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
