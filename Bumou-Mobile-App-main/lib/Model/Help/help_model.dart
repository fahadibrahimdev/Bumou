import 'package:app/Model/user.dart';

class HelpModel {
  late String id;
  late DateTime createdAt;
  late DateTime updatedAt;
  String? notificationId;
  late String status;
  String? message;
  num? locationLat;
  num? locationLng;
  String? address;
  bool? isDeleted;
  late String requestedById;
  late User requestedBy;
  String? helperId;
  User? helper;
  late List<HelpMessage> messages;

  HelpModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.notificationId,
    required this.requestedById,
    this.helperId,
    required this.status,
    this.message,
    this.locationLat,
    this.locationLng,
    this.address,
    this.isDeleted,
    required this.requestedBy,
    this.helper,
    this.messages = const [],
  });

  HelpModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = DateTime.parse(json['createdAt']).toLocal();
    updatedAt = DateTime.parse(json['updatedAt']).toLocal();
    notificationId = json['notificationId'];
    requestedById = json['requestedById'];
    helperId = json['helperId'];
    status = json['status'];
    message = json['message'];
    locationLat = json['locationLat'];
    locationLng = json['locationLng'];
    address = json['address'];
    isDeleted = json['isDeleted'];
    requestedBy = User.fromJson(json['requestedBy']);
    helper = json['helper'] != null ? User.fromJson(json['helper']) : null;
    if (json['messages'] != null) {
      messages = [];
      json['messages'].forEach((v) {
        messages.add(HelpMessage.fromJson(v));
      });
    } else {
      messages = [];
    }
  }
}

class HelpMessage {
  late String id;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String helpId;
  String? senderId;
  late User sender;
  String? message;
  String? status;
  String? type;
  String? file;
  num? locationLat;
  num? locationLng;

  HelpMessage({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.helpId,
    this.senderId,
    this.message,
    this.status,
    this.type,
    this.file,
    this.locationLat,
    this.locationLng,
    required this.sender,
  });

  HelpMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = DateTime.parse(json['createdAt']).toLocal();
    updatedAt = DateTime.parse(json['updatedAt']).toLocal();
    helpId = json['helpId'];
    senderId = json['senderId'];
    message = json['message'];
    status = json['status'];
    type = json['type'];
    file = json['file'];
    locationLat = json['locationLat'];
    locationLng = json['locationLng'];
    sender = User.fromJson(json['sender']);
  }
}
