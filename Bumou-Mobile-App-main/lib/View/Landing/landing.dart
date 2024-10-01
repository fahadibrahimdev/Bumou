// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:aliyun_push/aliyun_push.dart';
import 'package:app/Constants/api.dart';
import 'package:app/Constants/color.dart';
import 'package:app/Controller/auth_controller.dart';
import 'package:app/Controller/chats/chat_controller.dart';
import 'package:app/Controller/friend_controller.dart';
import 'package:app/Controller/help_controller.dart';
import 'package:app/Controller/momment_controller.dart';
import 'package:app/Controller/mood_controller.dart';
import 'package:app/Services/aliyun_push_notification.dart';
import 'package:aliyun_push/aliyun_push.dart'; 
import 'package:app/Utils/comon.dart';
import 'package:app/View/Chart/chart.dart';
import 'package:app/View/Chat/all_chat.dart';
import 'package:app/View/Emoji/emoji.dart';
import 'package:app/View/Help/help.dart';
import 'package:app/View/Moment/moment.dart';
import 'package:app/View/Profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pushy_flutter/pushy_flutter.dart';

import '../../Model/Help/help_request.dart';
import '../../Utils/loading_overlays.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    Get.put(FriendController(), permanent: true);
    Get.put(MoodController());
    Get.put(MommentController());
    Get.put(ChatController(), permanent: true);
    Get.put(HelpController(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onsignalSetup();
    });
    super.initState();
  }
     final AliyunPush aliyunPush = AliyunPush();


  Future<void> onsignalSetup() async {
    bool isNotificationAllowed = await Permission.notification.isGranted;
    print("NOTIFICATION PERMISSION IS --> ${isNotificationAllowed}");
    if (!isNotificationAllowed) {
      bool isAllowed = await Common.showPermissionBottomSheet(
        context: context,
        title: 'Notification Permission'.tr,
        description:
            "App needs notification permission to send you notification about various activities."
                .tr,
        icon: Lottie.asset(
          'assets/Animation/notification.json',
          width: MediaQuery.of(context).size.width / 2,
        ),
      );
      if (!isAllowed) {
        return;
      }
    }

    // final isAllowed = await OneSignal.Notifications.requestPermission(true);
    final isAllowed = await Permission.notification.request();

    debugPrint(
        'Notification Permission is: $isAllowed for user --> ${Get.find<AuthController>().user?.id}');
    if (isAllowed.isDenied) return;
    try {
       if (await aliyunPush.initPush(appKey: Apis.aliyueApiKey, appSecret: Apis.aliyueAppSecret) == false) {
        var deviceToken = await aliyunPush.initPush(appKey: Apis.aliyueApiKey, appSecret: Apis.aliyueAppSecret).then((value){
        return value;
      });
        print('Device token: $deviceToken');
      }
  //add the listen for notification click from this '

//  Pushy.setNotificationClickListener((Map<String, dynamic> data) async {
//         log("OneSignal Notification Clicked: ${jsonEncode(data)}");

//         if (data['type'] == 'MESSAGE') {
//           onItemTapped(3);
//         } else if (data['type'] == 'HELP') {
//           HelpRequest request = HelpRequest.fromJson(jsonDecode(data['data']));
//           await kOverlayWithAsync(asyncFunction: () async {
//             await Future.delayed(const Duration(milliseconds: 500));
//           });
//         }
//       });
//     } catch (error) {
//       log("ERROR IN NOTIFICATIONS -> ${error.toString()}");
//     }

//     isListenAdded = true;
//   }

//   _initializeNotification() async {
//     // Pushy.toggleForegroundService(true, this);

//     // NotificationService notificationService=AwesomeNotificationService();
//     // await notificationService.initialize();
//     // notificationService.showNotification("Title", "Body",[
//     //   "assets/bitmap/verybad.png",
//     //   "assets/bitmap/verybad.png",
//     //   "assets/bitmap/verybad.png",
//     //   "assets/bitmap/verybad.png",
//     //   "assets/bitmap/verybad.png",
//     // ],["Good","bad","wores","helo","he"]);
//   }
      // Listen for notification click
  void onAliyunNotificationClicked(Map<String, dynamic> data) async {
      try {
        
    log("Aliyun Notification Clicked: ${jsonEncode(data)}");

    if (data['type'] == 'MESSAGE') {
      onItemTapped(3);
    } else if (data['type'] == 'HELP') {
      HelpRequest request = HelpRequest.fromJson(jsonDecode(data['data']));
      await kOverlayWithAsync(asyncFunction: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      });
    }
  } catch (e) {
    log("Error handling notification: $e");
  }
}

// Initialize Aliyun push notification
      aliyunPush.initAndroidThirdPush();
        //  AliyunPush.setNotificationClickListener(onAliyunNotificationClicked);
    } catch (error) {
      log("ERROR IN NOTIFICATIONS -> ${error.toString()}");
    }

    isListenAdded = true;
  }
// included these lines...

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    debugPrint("Current state : $state");

    if (state == AppLifecycleState.resumed) {
      Pushy.toggleInAppBanner(true);
      Get.find<ChatController>().getAllChatrooms(shouldShowLoading: false);
    }
  }

  @override
  void dispose() {
    // OneSignal.Notifications.removeClickListener((event) {});
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool isListenAdded = false;

  int selectedIndex = 0;
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  List<Widget> screen = <Widget>[
    const ProfileView(),
    const EmojiView(),
    const ChartView(),
    const ChatRoomView(),
    const MomentView(),
    const HelpView(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.black,
        currentIndex: selectedIndex,
        selectedFontSize: 12,
        onTap: onItemTapped,
        elevation: 1.5,
        items: [
          BottomNavigationBarItem(
            label: 'Profile'.tr,
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('assets/svgs/profile.svg', height: 15),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('assets/svgs/profile.svg',
                  height: 15, color: AppColors.primary),
            ),
          ),
          BottomNavigationBarItem(
            label: 'Emoji'.tr,
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('assets/svgs/emoji.svg', height: 15),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('assets/svgs/emoji.svg',
                  height: 15, color: AppColors.primary),
            ),
          ),
          BottomNavigationBarItem(
            label: 'Chart'.tr,
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('assets/svgs/chart.svg', height: 15),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('assets/svgs/chart.svg',
                  height: 15, color: AppColors.primary),
            ),
          ),
          BottomNavigationBarItem(
            label: 'Chat'.tr,
            icon: buildChatIcon(context),
            activeIcon: buildChatIcon(context, isActive: true),
          ),
          BottomNavigationBarItem(
            label: 'Moments'.tr,
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('assets/svgs/moment.svg', height: 15),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SvgPicture.asset('assets/svgs/moment.svg',
                  height: 15, color: AppColors.primary),
            ),
          ),
          BottomNavigationBarItem(
            label: 'Help'.tr,
            icon: buildHelpIcon(context),
            activeIcon: buildHelpIcon(context, isActive: true),
          ),
        ],
      ),
    );
  }

  Widget buildChatIcon(BuildContext context, {bool isActive = false}) {
    return GetBuilder<ChatController>(
      init: ChatController(),
      initState: (_) {},
      builder: (cntrlr) {
        bool isAnyUnread =
            cntrlr.allChatroom.any((element) => (element.unreadCount ?? 0) > 0);
        return Badge(
          isLabelVisible: isAnyUnread,
          largeSize: 12,
          smallSize: 8,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SvgPicture.asset(
              'assets/svgs/chat.svg',
              height: 15,
              color: isActive ? AppColors.primary : AppColors.black,
            ),
          ),
        );
      },
    );
  }

  Widget buildHelpIcon(BuildContext context, {bool isActive = false}) {
    return GetBuilder<HelpController>(
      init: HelpController(),
      initState: (_) {},
      builder: (cntrlr) {
        return Badge(
          // backgroundColor: Color.fromARGB(255, 255, 222, 222),
          isLabelVisible:
              cntrlr.ongoingHelps.isNotEmpty || cntrlr.incomingHelps.isNotEmpty,
          largeSize: 20,
          smallSize: 12,
          label: HelpBadge(
            ongoingCount: cntrlr.ongoingHelps.length,
            incomingCount: cntrlr.incomingHelps.length,
          ),
          // Text(
          //   'Online'.tr,
          //   style: const TextStyle(
          //       color: AppColors.white,
          //       fontSize: 10,
          //       fontWeight: FontWeight.bold),
          // ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SvgPicture.asset('assets/svgs/help.svg',
                height: 15,
                color: isActive ? AppColors.primary : AppColors.black),
          ),
        );
      },
    );
  }
}

class HelpBadge extends StatelessWidget {
  const HelpBadge(
      {super.key, required this.ongoingCount, required this.incomingCount});
  final int ongoingCount, incomingCount;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          if (ongoingCount > 0)
            Text(
              "$ongoingCount",
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (ongoingCount > 0 && incomingCount > 0) const VerticalDivider(),
          if (incomingCount > 0)
            Text(
              "$incomingCount",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
