import 'package:app/Constants/color.dart';
import 'package:app/Controller/auth_controller.dart';
import 'package:app/Model/enums.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/Utils/navigations.dart';
import 'package:app/View/Profile/Widget/k_account_row.dart';
import 'package:app/View/Profile/edit_profile.dart';
import 'package:app/View/Widget/k_net_image.dart';
import 'package:app/View/Widget/language_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:unlock_detector/unlock_detector.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:developer'as developer;

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     UnlockDetectorStatus _status = UnlockDetectorStatus.screenOn;
    UnlockDetector.stream.listen((status) {
      setState(() {
        _status = status;
      });
    });
    developer.log("mobile phone status $_status");
  }
  //scaffold key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (cntrlr) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Profile'.tr,
              style: Theme.of(context).textTheme.titleMedium),
          actions: [
            IconButton(
                onPressed: () => Get.to(() => const EditProfileView()),
                icon: SvgPicture.asset('assets/svgs/edit.svg')),
          ],
        ),
        drawer: Drawer(
          child: Column(
            children: [
              const SafeArea(child: SizedBox(height: 20)),
              ListTile(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                onTap: () {
                  _scaffoldKey.currentState!.closeDrawer();
                  Get.to(() => const EditProfileView());
                },
                leading: const Icon(Icons.person),
                title: Text('Edit Profile'.tr),
              ),
              const Spacer(),
              ListTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                onTap: () async {
                  String email = "273219010@qq.com";
                  try {
                    if (await canLaunchUrlString('mailto:$email')) {
                      await launchUrlString(
                        'mailto:$email',
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      await Clipboard.setData(ClipboardData(text: email));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Our email address copied to your clipboard'.tr),
                        ),
                      );
                    }
                  } catch (e) {
                    await Clipboard.setData(ClipboardData(text: email));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Email copied to clipboard'.tr),
                      ),
                    );
                  }
                },
                leading: const Icon(Icons.support_agent),
                title: Text(
                  'Feedback or Support'.tr,
                  style: const TextStyle(color: AppColors.black),
                ),
              ),
              const Divider(),
              ListTile(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                onTap: () => openPrivacyPolicy(),
                leading: const Icon(Icons.policy),
                title: Text(
                  'Privacy Policy & Terms of Services'.tr,
                  style: const TextStyle(color: AppColors.black),
                ),
              ),
              const Divider(),
              ListTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                onTap: () {
                  showAdaptiveDialog(
                    context: context,
                    builder: (context) => AlertDialog.adaptive(
                      title: Text('Logout'.tr),
                      content: Text('Are you sure you want to logout?'.tr),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            await kOverlayWithAsync(asyncFunction: () async {
                              await cntrlr.logout();
                            });
                          },
                          child: Text('Logout'.tr,
                              style: const TextStyle(color: AppColors.error)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel'.tr),
                        ),
                      ],
                    ),
                  );
                },
                leading: const Icon(Icons.logout),
                title: Text('Logout'.tr),
              ),
              const Divider(),
              ListTile(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                iconColor: AppColors.error,
                textColor: AppColors.error,
                onTap: () async {
                  showAdaptiveDialog(
                    context: context,
                    builder: (context) => AlertDialog.adaptive(
                      title: Text('Delete Account'.tr),
                      content: Text(
                          'Are you sure you want to delete your account?'.tr),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            await kOverlayWithAsync(asyncFunction: () async {
                              await cntrlr.deleteUser(context);
                            });
                          },
                          child: Text('Delete'.tr),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel'.tr,
                            style: const TextStyle(color: AppColors.black),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                leading: const Icon(Icons.delete),
                title: Text(
                  'Delete Account'.tr,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Hero(
                tag: 'profilepicture',
                child: KCircularCacheImg(
                  imgPath: cntrlr.user?.profilePicture,
                  radius: MediaQuery.sizeOf(context).width * 0.4,
                  paddingDefault: 0,
                ),
              ),
              const SizedBox(height: 16),
              Text('${cntrlr.user?.firstName} ${cntrlr.user?.lastName}',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 30),
              KAccountRow(title: 'Email:'.tr, body: cntrlr.user?.email ?? ''),
              const Divider(color: AppColors.primary40),
              KAccountRow(
                  title: 'User Name:'.tr, body: cntrlr.user?.username ?? ''),
              const Divider(color: AppColors.primary40),
              KAccountRow(
                  title: 'Mobile No:'.tr, body: cntrlr.user?.phone ?? ''),
              const Divider(color: AppColors.primary40),
              if (cntrlr.user?.userType == UserType.student.name)
                Column(children: [
                  KAccountRow(
                      title: 'School Name:'.tr,
                      body: cntrlr.user?.schoolName ?? ''),
                  const Divider(color: AppColors.primary40),
                  KAccountRow(
                      title: 'Class Name:'.tr,
                      body: cntrlr.user?.className ?? ''),
                  const Divider(color: AppColors.primary40),
                  KAccountRow(
                      title: 'Teacher Name:'.tr,
                      body: cntrlr.user?.teacherName ?? ''),
                  const Divider(color: AppColors.primary40),
                ]),
              KAccountRow(title: 'City:'.tr, body: cntrlr.user?.city ?? ''),
              const Divider(color: AppColors.primary40),
              KAccountRow(
                  title: 'Country:'.tr, body: cntrlr.user?.country ?? ''),
              const Divider(color: AppColors.primary40),
              Center(
                child: TextButton(
                    onPressed: () {
                      Get.dialog(
                        Dialog(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Select Language'.tr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 20),
                                const LanguageChangeBar(),
                                // Row(
                                //   mainAxisAlignment:
                                //       MainAxisAlignment.spaceEvenly,
                                //   children: List.generate(
                                //     2,
                                //     (index) => ElevatedButton(
                                //       style: ElevatedButton.styleFrom(
                                //         backgroundColor:
                                //             cntrlr.selectedLanguage == index
                                //                 ? AppColors.primary
                                //                 : AppColors.white,
                                //       ),
                                //       onPressed: () {
                                //         cntrlr.selectedLanguage = index;
                                //         cntrlr.updateLanguage(
                                //             cntrlr.locale[index]['locale']);
                                //         Get.back();
                                //       },
                                //       child: Text(
                                //         cntrlr.locale[index]['name'],
                                //         style: Theme.of(context)
                                //             .textTheme
                                //             .bodyMedium!
                                //             .copyWith(
                                //               color: cntrlr.selectedLanguage ==
                                //                       index
                                //                   ? AppColors.white
                                //                   : AppColors.black,
                                //             ),
                                //       ),
                                //     ),
                                //   ),
                                // )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Language'.tr,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(width: 10),
                        const Icon(Icons.language_outlined)
                      ],
                    )),
              )
            ],
          ),
        ),
      );
    });
  }
}

// class HelpResponseWidget extends StatelessWidget {
//   final HelpRequest request;
//   HelpResponseWidget({super.key, required this.request});

//   final TextEditingController _responseController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return CupertinoPageScaffold(
//       navigationBar: CupertinoNavigationBar(
//         middle: Text('Help Request Details'.tr),
//       ),
//       child: GestureDetector(
//         onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 10),
//                       Text('Requested By:'.tr,
//                           style: Theme.of(context).textTheme.titleMedium),
//                       ListTile(
//                         leading: KCircularCacheImg(
//                             imgPath: request.requestedBy?.profilePicture,
//                             radius: 45,
//                             paddingDefault: 0),
//                         title: Text(
//                             '${request.requestedBy?.firstName} ${request.requestedBy?.lastName}'),
//                         subtitle: Text('${request.requestedBy?.userType}'),
//                         contentPadding: EdgeInsets.zero,
//                       ),
//                       const Divider(),
//                       Text('Request Details:'.tr,
//                           style: Theme.of(context).textTheme.titleMedium),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: AppColors.black10,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(request.message != null &&
//                                 request.message!.isNotEmpty
//                             ? request.message!
//                             : 'I need help'.tr),
//                       ),
//                       const SizedBox(height: 10),
//                       Text('Response:'.tr,
//                           style: Theme.of(context).textTheme.titleMedium),
//                       TextFormField(
//                         maxLines: 1,
//                         controller: _responseController,
//                         decoration: InputDecoration(
//                           hintText: 'Write your response here'.tr,
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: double.infinity,
//                         child: FilledButton(
//                           onPressed: () async {
//                             await kOverlayWithAsync(asyncFunction: () async {
//                               if (_responseController.text.isEmpty) {
//                                 Common.showErrorDialog(context,
//                                     e: "Please enter response message".tr);
//                                 return;
//                               }

//                               bool isConnected =
//                                   await Get.find<HelpController>().acceptHelp(
//                                 context,
//                                 helpId: request.id!,
//                                 message: _responseController.text,
//                               );
//                               if (isConnected) {
//                                 Get.find<HelpController>().getOngoingHelp();
//                                 Get.back();
//                               }
//                             });
//                           },
//                           child: Text('Send Response'.tr),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
