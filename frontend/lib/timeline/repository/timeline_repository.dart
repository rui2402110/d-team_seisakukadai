import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_client.dart';

class TimelineRepository{

  Future<List<TimelineModel>> getTimeline() async {
    final idtoken = await ApiClient.idToken();

    final res = await http.get(
      Uri.parse('${ApiClient.baseUrl}/timeline/timeline/'),
      headers: ApiClient.headers(idtoken),
    );

    if (res.statusCode == 401) {
      throw ApiException(
        'ログインの有効期限が切れました。もう一度ログインしてください'
      );
    }

    if (res.statusCode != 200) {
      throw ApiException(
        'データの取得に失敗しました (${res.statusCode})'
      );
    }

    final data = jsonDecode(
      utf8.decode(res.bodyBytes),
    ) as List;

    return data
    .map((e) => TimelineModel.fromJson(e))
    .toList();
  }

  Future<List<CommunityModel>> getMyCommunity()async{
    final idtoken = await ApiClient.idToken();

    final res = await http.get(
      Uri.parse('${ApiClient.baseUrl}/timeline/my-community/'),
      headers: ApiClient.headers(idtoken),
    );
    if (res.statusCode == 401) {
      throw ApiException(
        'ログインの有効期限が切れました。もう一度ログインしてください'
      );
    }

    if (res.statusCode != 200) {
      throw ApiException(
        'データの取得に失敗しました (${res.statusCode})'
      );
    }
    final data = jsonDecode(
      utf8.decode(res.bodyBytes),
    ) as List;

    return data
    .map((e) => CommunityModel.fromJson(e))
    .toList();

  }
  
}

class TimelineModel {
  final int postId;
  final String name;
  final String iconUrl;
  final int communityId;
  final String communityName;
  final String post;
  final int like;
  final int replyCount;
  final DateTime createdAt;

  TimelineModel({
    required this.postId,
    required this.name,
    required this.iconUrl,
    required this.communityId,
    required this.communityName,
    required this.post,
    required this.like,
    required this.replyCount,
    required this.createdAt,
  });

  factory TimelineModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TimelineModel(
      postId: json['post_id'],
      name: json['name'],
      iconUrl: json['icon_url'],
      communityId: json['community_id'],
      communityName: json['community_name'],
      post: json['post'],
      like: json['like'],
      replyCount: json['reply_count'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class CommunityModel {
  final int communityId;
  final String name;

  CommunityModel({
    required this.communityId,
    required this.name,
  });

  factory CommunityModel.fromJson(
    Map<String, dynamic> json,
  ){
    return CommunityModel(
      communityId: json['community_id'], 
      name: json['name']
    );
  }
}