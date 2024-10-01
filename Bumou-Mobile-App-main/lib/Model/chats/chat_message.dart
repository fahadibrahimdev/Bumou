// ignore_for_file: constant_identifier_names

class ChatMessage {
  String? id, chatroomId, senderId, receiverId, message, file;
  DateTime? createdAt, updatedAt;
  ChatMessageStatus? chatMessageStatus;
  ChatMessageType? chatMessageType;
  late List<ReadBy> readBy;

  ChatMessage({
    this.id,
    this.chatroomId,
    this.senderId,
    this.receiverId,
    this.message,
    this.file,
    this.createdAt,
    this.updatedAt,
    this.chatMessageStatus,
    this.chatMessageType,
    this.readBy = const [],
  });

  ChatMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatroomId = json['chatroomId'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    message = json['message'];
    file = json['file'];
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt']).toLocal()
        : null;
    updatedAt = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt']).toLocal()
        : null;
    chatMessageStatus = json['status'] != null
        ? (json['status'] as String).toChatMessageStatus
        : null;
    chatMessageType = json['type'] != null
        ? (json['type'] as String).toChatMessageType
        : null;
    readBy = <ReadBy>[];
    if (json['readBy'] != null && json['readBy'].isNotEmpty) {
      json['readBy'].forEach((v) {
        readBy.add(ReadBy.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['chatroomId'] = chatroomId;
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    data['message'] = message;
    data['file'] = file;
    data['status'] = chatMessageStatus.toString().split('.').last;
    data['type'] = chatMessageType.toString().split('.').last;
    return data;
  }
}

enum ChatMessageStatus {
  PENDING,
  SENT,
  DELIVERED,
  READ,
}

enum ChatMessageType {
  TEXT,
  IMAGE,
  VIDEO,
  AUDIO,
  VOICE,
}

extension OnChatMessageStatusString on String? {
  ChatMessageStatus get toChatMessageStatus {
    switch (this) {
      case 'PENDING':
        return ChatMessageStatus.PENDING;
      case 'SENT':
        return ChatMessageStatus.SENT;
      case 'DELIVERED':
        return ChatMessageStatus.DELIVERED;
      case 'READ':
        return ChatMessageStatus.READ;
      default:
        return ChatMessageStatus.PENDING;
    }
  }
}

extension OnChatMessageTypeString on String? {
  ChatMessageType get toChatMessageType {
    switch (this) {
      case 'TEXT':
        return ChatMessageType.TEXT;
      case 'IMAGE':
        return ChatMessageType.IMAGE;
      case 'VIDEO':
        return ChatMessageType.VIDEO;
      case 'AUDIO':
        return ChatMessageType.AUDIO;
      case 'VOICE':
        return ChatMessageType.VOICE;
      default:
        return ChatMessageType.TEXT;
    }
  }
}

extension ChatMessageTypeEx on ChatMessageType {
  String get toShortString {
    switch (this) {
      case ChatMessageType.TEXT:
        return 'text';
      case ChatMessageType.IMAGE:
        return 'image';
      case ChatMessageType.VIDEO:
        return 'video';
      case ChatMessageType.AUDIO:
        return 'audio';
      case ChatMessageType.VOICE:
        return 'voice';
    }
  }
}

class ReadBy {
  late String id;
  late String chatroomId;
  late String userId;
  late String messageId;

  ReadBy({
    required this.id,
    required this.chatroomId,
    required this.userId,
    required this.messageId,
  });

  ReadBy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatroomId = json['chatroomId'];
    userId = json['userId'];
    messageId = json['messageId'];
  }
}
