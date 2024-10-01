import 'package:app/Model/chats/chat_message.dart';
import 'package:app/Model/enums.dart';
import 'package:app/Model/user.dart';

class Chatroom {
  String? id;
  String? lastMessage;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? name;
  bool? isMuted;
  List<User>? members;
  int? unreadCount;
  List<ChatMessage>? messages;

  Chatroom({
    this.id,
    this.lastMessage,
    this.members,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.isMuted,
    this.unreadCount = 0,
    this.messages,
  });

  Chatroom.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lastMessage = json['lastMessage'];
    members = <User>[];
    if (json['members'] != null && json['members'].isNotEmpty) {
      json['members'].forEach((v) {
        members!.add(User.fromJson(v));
      });
    } else {
      members!.add(deletedUser);
    }
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt']).toLocal()
        : null;
    updatedAt = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt']).toLocal()
        : null;
    name = json['name'];
    isMuted = json['isMuted'];
    unreadCount = json['unreadCount'];
    messages = <ChatMessage>[];
    if (json['messages'] != null && json['messages'].isNotEmpty) {
      json['messages'].forEach((v) {
        messages!.add(ChatMessage.fromJson(v));
      });
    }
  }
}

User deletedUser = User(
  id: '',
  firstName: 'Deleted',
  lastName: 'User',
  email: '',
  username: '',
  phone: '',
  profilePicture: '',
  userType: UserType.adult.name,
  schoolName: '',
  className: '',
  teacherName: '',
  city: '',
  country: '',
);
