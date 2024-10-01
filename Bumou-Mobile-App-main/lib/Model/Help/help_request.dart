import 'package:app/Model/user.dart';

class HelpRequest {
  String? id;
  String? updatedAt;
  String? message;
  String? enHelpMessage;
  String? requestedById;
  String? zhHelpMessage;
  String? notificationId;
  bool? isDeleted;
  String? type;
  String? address;
  num? locationLat;
  User? requestedBy;
  String? helperId;
  String? createdAt;
  String? status;
  num? locationLng;

  HelpRequest({
    this.id,
    this.updatedAt,
    this.message,
    this.enHelpMessage,
    this.requestedById,
    this.zhHelpMessage,
    this.notificationId,
    this.isDeleted,
    this.type,
    this.address,
    this.locationLat,
    this.requestedBy,
    this.helperId,
    this.createdAt,
    this.status,
    this.locationLng,
  });

  HelpRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    updatedAt = json['updatedAt'];
    message = json['message'];
    enHelpMessage = json['enHelpMessage'];
    requestedById = json['requestedById'];
    zhHelpMessage = json['zhHelpMessage'];
    notificationId = json['notificationId'];
    isDeleted = json['isDeleted'];
    type = json['type'];
    address = json['address'];
    locationLat = json['locationLat'];
    requestedBy = json['requestedBy'] != null ? User.fromJson(json['requestedBy']) : null;
    helperId = json['helperId'];
    createdAt = json['createdAt'];
    status = json['status'];
    locationLng = json['locationLng'];
  }
}
