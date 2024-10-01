import 'package:app/Constants/api.dart';
import 'package:app/Controller/Bindings/bindings.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../View/Profile/user_profile_details.dart';

Future<void> navigateToUserDetails(String userId) async {
  await Get.to(
    () => const UserProfileDetails(),
    binding: UserDetailsBinding(),
    arguments: userId,
  );
}

Future<void> openPrivacyPolicy() async {
  await launchUrlString(
    Apis.privacyPolicy,
    mode: LaunchMode.externalApplication,
  );
}
