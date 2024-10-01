class User {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? email;
  String? username;
  String? userType;
  String? firstName;
  String? lastName;
  String? profilePicture;
  String? phone;
  String? address;
  String? city;
  String? state;
  String? zip;
  String? country;
  String? schoolName;
  String? className;
  String? teacherName;
  bool? isVerified;
  bool? isBlocked;
  bool? isOnline;
  bool? isDeleted;
  bool? isHelping;
  String? accessToken;
  String? friendShipId;

  User({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.email,
    this.username,
    this.userType,
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.schoolName,
    this.className,
    this.teacherName,
    this.isVerified,
    this.isBlocked,
    this.isOnline,
    this.isDeleted,
    this.accessToken,
    this.friendShipId,
    this.isHelping,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    email = json['email'];
    username = json['username'];
    userType = json['userType'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    profilePicture = json['profilePicture'];
    phone = json['phone'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
    country = json['country'];
    schoolName = json['schoolName'];
    className = json['className'];
    teacherName = json['teacherName'];
    isVerified = json['isVerified'];
    isBlocked = json['isBlocked'];
    isOnline = json['isOnline'];
    isDeleted = json['isDeleted'];
    accessToken = json['access_token'];
    friendShipId = json['friendShipId'];
    isHelping = json['isHelping'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['email'] = email;
    data['username'] = username;
    data['userType'] = userType;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['profilePicture'] = profilePicture;
    data['phone'] = phone;
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['zip'] = zip;
    data['country'] = country;
    data['schoolName'] = schoolName;
    data['className'] = className;
    data['teacherName'] = teacherName;
    data['isVerified'] = isVerified;
    data['isBlocked'] = isBlocked;
    data['isOnline'] = isOnline;
    data['isDeleted'] = isDeleted;
    data['access_token'] = accessToken;
    data['friendShipId'] = friendShipId;
    return data;
  }
}
