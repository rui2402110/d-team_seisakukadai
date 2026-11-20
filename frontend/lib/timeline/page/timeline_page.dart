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
    // ナビ付きの枠に、この画面の中身を渡す
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
            builder: (context, snapshot){
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
              // ------------------------------------------------------------------
              final communities =
                  snapshot.data![0] as List<CommunityModel>;
              final posts =
                  snapshot.data![1] as List<TimelineModel>;

              return DefaultTabController(
                length: communities.length+1, 
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(text: "フォロー",),
                        ...communities.map( // コミュニティ名を取得
                          (c) => Tab(text: c.name,),
                        )
                      ] 
                    ),
                    Expanded(child: 
                      TabBarView(children: [
                        // フォロータブ
                        ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return PostTile(
                              post: posts[index],
                            );
                          },
                        ),
                        

                        // コミュニティタブ
                        ...communities.map((community) {

                          final filteredPosts = posts.where(
                            (post){
                              return 
                                post.communityId == community.communityId &&
                                post.replyId == 0;
                            }
                          ).toList();

                          return ListView.builder(
                            itemCount: filteredPosts.length,
                            itemBuilder: (context, index) {

                              final post = filteredPosts[index];

                              return PostTile(post: filteredPosts[index]);
                            },
                          );
                        }),
                      ])  
                    )
                  ],
                )
              );
            }
          )
        )
      ]
    ));
  }
}
