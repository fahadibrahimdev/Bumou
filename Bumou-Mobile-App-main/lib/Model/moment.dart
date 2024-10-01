import 'user.dart';

class Moment {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? text;
  List<MediaAttachments>? mediaAttachments;
  String? mood;
  String? userId;
  User? user;
  List<Comment>? comments;
  List<Like>? likes;
  int? numberOfLikes;
  bool? isLikeByMe;
  bool? isAnonymous;

  Moment({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.text,
    this.mediaAttachments,
    this.mood,
    this.userId,
    this.comments,
    this.likes,
    this.user,
    this.numberOfLikes,
    this.isLikeByMe,
    this.isAnonymous,
  });

  Moment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt']).toLocal()
        : null;
    updatedAt = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt']).toLocal()
        : null;
    text = json['text'];
    if (json['mediaAttachments'] != null) {
      mediaAttachments = <MediaAttachments>[];
      json['mediaAttachments'].forEach((v) {
        mediaAttachments!.add(MediaAttachments.fromJson(v));
      });
    }
    mood = json['mood'];
    userId = json['userId'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['comments'] != null) {
      comments = <Comment>[];
      json['comments'].forEach((v) {
        comments!.add(Comment.fromJson(v));
      });
    }

    if (json['likes'] != null) {
      likes = <Like>[];
      json['likes'].forEach((v) {
        likes!.add(Like.fromJson(v));
      });
    }
    numberOfLikes = json['numberOfLikes'];
    isLikeByMe = json['isLikeByMe'];
    isAnonymous = json['is_anonymous'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    if (mediaAttachments != null) {
      data['mediaAttachments'] =
          mediaAttachments!.map((v) => v.toJson()).toList();
    }
    data['mood'] = mood;
    data['is_anonymous'] = isAnonymous;
    return data;
  }
}

class Comment {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? text;
  String? userId;
  String? postId;
  User? user;

  Comment({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.text,
    this.userId,
    this.postId,
    this.user,
  });

  Comment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt']).toLocal()
        : null;
    updatedAt = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt']).toLocal()
        : null;
    text = json['text'];
    userId = json['userId'];
    postId = json['postId'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['text'] = text;
    data['userId'] = userId;
    data['postId'] = postId;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class Like {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? userId;
  String? postId;

  Like({this.id, this.createdAt, this.updatedAt, this.userId, this.postId});

  Like.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    userId = json['userId'];
    postId = json['postId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['userId'] = userId;
    data['postId'] = postId;
    return data;
  }
}

class MediaAttachments {
  String? id;
  String? url;
  String? postId;
  MediaType? type;

  MediaAttachments({this.id, this.url, this.postId, this.type});

  MediaAttachments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    postId = json['postId'];
    type = (json['type'] as String?).toMediaType;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['type'] = type.toString().split('.').last.toUpperCase();
    return data;
  }
}

enum MediaType {
  unknown,
  image,
  video,
}

extension MediaTypeEx on String? {
  MediaType get toMediaType {
    switch (this) {
      case "image" || "IMAGE":
        return MediaType.image;
      case "video" || "VIDEO":
        return MediaType.video;
      default:
        return MediaType.unknown;
    }
  }
}
