import 'package:app/Constants/color.dart';
import 'package:app/Controller/friend_controller.dart';
import 'package:app/Data/Local/hive_storage.dart';
import 'package:app/Model/chats/chatroom.dart';
import 'package:app/Model/enums.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/Utils/navigations.dart';
import 'package:app/Utils/utils.dart';
import 'package:app/View/Chat/message.dart';
import 'package:app/View/Friends/add_friend.dart';
import 'package:app/View/Friends/pending_friend.dart';
import 'package:app/View/Widget/k_net_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FriendView extends StatefulWidget {
  const FriendView({super.key});

  @override
  State<FriendView> createState() => _FriendViewState();
}

class _FriendViewState extends State<FriendView> {
  RxBool isLoading = false.obs;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FriendController.to.getAllFriends(context);
      FriendController.to.getPendingRequest(context);
      FriendController.to.suggestedFriends(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FriendController>(builder: (cntrlr) {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Friends'.tr),
            bottom: TabBar(
              dividerColor: AppColors.white,
              labelStyle: Theme.of(context).textTheme.titleMedium,
              padding: const EdgeInsets.all(10),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColors.primary),
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.black,
              tabs: [
                Tab(text: 'All Friends'.tr),
                Tab(text: 'Pending'.tr),
                Tab(text: 'Add Friends'.tr),
              ],
              indicatorColor: Colors.transparent,
            ),
          ),
          body: TabBarView(
            children: [
              //! Tab BAr View 1
              cntrlr.isLoadingMyFriends
                  ? const Center(child: CircularProgressIndicator())
                  : cntrlr.myFriendErrorMsg != null
                      ? Center(child: Text(cntrlr.myFriendErrorMsg!))
                      : cntrlr.myFriends.isEmpty
                          ? SmartRefresher(
                              controller: cntrlr.refreshFriendController,
                              enablePullDown: true,
                              header: const WaterDropHeader(
                                  waterDropColor: AppColors.primary),
                              onRefresh: cntrlr.onRefresh,
                              onLoading: cntrlr.onLoading,
                              child: Center(child: Text('No Friends'.tr)),
                            )
                          : SmartRefresher(
                              controller: cntrlr.refreshFriendController,
                              enablePullDown: true,
                              header: const WaterDropHeader(
                                  waterDropColor: AppColors.primary),
                              onRefresh: cntrlr.onRefresh,
                              onLoading: cntrlr.onLoading,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: cntrlr.myFriends.length,
                                itemBuilder: (context, index) {
                                  final user = cntrlr.myFriends[index];
                                  return ListTile(
                                    onTap: () =>
                                        navigateToUserDetails(user.id!),
                                    leading: KCircularCacheImg(
                                      imgPath: user.profilePicture,
                                      radius: 50,
                                      isBorder:
                                          user.userType == UserType.student.name
                                              ? true
                                              : false,
                                    ),
                                    title: Text(
                                        '${user.firstName} ${user.lastName}'),
                                    subtitle: Text(user.userType?.tr ?? ""),
                                    trailing: PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'message',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.chat),
                                              const SizedBox(width: 10),
                                              Text('Message'.tr),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'remove',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.delete),
                                              const SizedBox(width: 10),
                                              Text('Remove'.tr),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) async {
                                        if (value == 'remove') {
                                          await kOverlayWithAsync(
                                              asyncFunction: () async {
                                            await FriendController.to
                                                .removeFriend(context,
                                                    id: user.id!);
                                          });
                                        } else if (value == 'message') {
                                          String chatId =
                                              AppUtils.buildChatroomId(
                                                  LocalStorage.getUserId!,
                                                  user.id!);
                                          Get.to(
                                            () => MessageView(
                                                chatroom: Chatroom(
                                                    id: chatId,
                                                    members: [user])),
                                            arguments: chatId,
                                          );
                                        }
                                      },
                                    ),
                                    // IconButton(
                                    //   onPressed: () {
                                    //     String chatId =
                                    //         AppUtils.buildChatroomId(
                                    //             LocalStorage.getUserId!,
                                    //             user.id!);
                                    //     Get.to(
                                    //       () => MessageView(
                                    //           chatroom: Chatroom(
                                    //               id: chatId, members: [user])),
                                    //       arguments: chatId,
                                    //     );
                                    //   },
                                    //   icon: const Icon(Icons.chat),
                                    // ),
                                  );
                                },
                              ),
                            ),
              //! Tab BAr View 2
              const PendingFriend(),
              //! Tab BAr View 3
              const AddFriendView()
            ],
          ),
        ),
      );
    });
  }
}
