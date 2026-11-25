import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_client.dart';

class TimelineRepository{

  Future<List<TimelineModel>> getTimeline({int? postId}) async {
    final idtoken = await ApiClient.idToken();
    final Uri url;

    if (postId == null || postId == 0) {
      url = Uri.parse('${ApiClient.baseUrl}/timeline/timeline/');
    }else{
      url = Uri.parse('${ApiClient.baseUrl}/timeline/timeline/$postId/');
    }

    final res = await http.get(
      url,
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
  
  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('サーバーから不正なデータが返されました');
  }

  Future<Map<String,dynamic>> like({
    required int postId,
  })async{
    // ログイン中ユーザーのIDトークンを取得(未ログインなら ApiException)
    final idToken = await ApiClient.idToken();

    //url
    final url = Uri.parse('${ApiClient.baseUrl}/timeline/like/');

    //リクエスト
    final res = await http.post(
      url,
      headers: {
        ...ApiClient.headers(idToken),
        //データ形式と文字コード
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode({'postId' : postId}),
    );
    // 認証エラー
    if (res.statusCode == 401) {
      throw ApiException(
        'ログインの有効期限が切れました。もう一度ログインしてください',
      );
    }

    // ユーザーが存在しない
    if (res.statusCode == 404) {
      throw ApiException('投稿が見つかりません');
    }
    // 不正なリクエスト
    if (res.statusCode == 400) {
      final data = _decodeResponse(res);
      throw ApiException(
        data['error']?.toString() ?? '不正なリクエストです',
      );
    }

    // その他のエラー
    if (res.statusCode != 200) {
      throw ApiException(
        'フォロー処理に失敗しました (${res.statusCode})',
      );
    }

    //成功時
    return _decodeResponse(res);
  }
  
}

class TimelineModel {
  final int postId;
  final String userId;
  final String name;
  final String iconUrl;
  final int communityId;
  final String communityName;
  final String post;
  int like;
  bool isLiked;
  final int replyId;
  int replyCount;
  final DateTime createdAt;
  final List<MediaModel> medias;

  TimelineModel({
    required this.postId,
    required this.userId,
    required this.name,
    required this.iconUrl,
    required this.communityId,
    required this.communityName,
    required this.post,
    required this.like,
    required this.isLiked,
    required this.replyId,
    required this.replyCount,
    required this.createdAt,
    required this.medias,
  });

  factory TimelineModel.fromJson(
    Map<String, dynamic> json,
  ) {

    final iconUrl = json['icon_url'] ?? '';
    return TimelineModel(
      postId: json['post_id'],
      userId: json['user_id'],
      name: json['name'] ?? '',
      iconUrl: iconUrl.startsWith('http')
        ? iconUrl
        : '${ApiClient.baseUrl}$iconUrl',
      communityId: json['community_id'],
      communityName: json['community_name'] ?? '',
      post: json['post'] ?? '',
      like: json['like'],
      isLiked: json['is_liked'],
      replyId: json['reply_id'],
      replyCount: json['reply_count'],
      createdAt: DateTime.parse(json['created_at']),
      medias: (json['medias'] as List?)
        ?.map(
            (e) => MediaModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      [],
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

class MediaModel {
  final String media;
  final String mediaType;
  final int mediaNumber;

  MediaModel({
    required this.media,
    required this.mediaType,
    required this.mediaNumber,
  });

  factory MediaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MediaModel(
      media: json['media'],
      mediaType: json['media_type'],
      mediaNumber: json['media_number'],
    );
  }
}