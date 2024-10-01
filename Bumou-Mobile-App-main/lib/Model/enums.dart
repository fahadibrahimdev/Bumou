enum UserType { student, adult }

extension UserTypeEx on UserType {
  String get name {
    switch (this) {
      case UserType.student:
        return "STUDENT";
      case UserType.adult:
        return "ADULT";
      default:
        return "Others";
    }
  }
}
