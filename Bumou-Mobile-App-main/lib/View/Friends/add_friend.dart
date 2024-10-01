import 'dart:async';
import 'dart:developer';
import 'package:app/Constants/api.dart';
import 'package:app/Constants/color.dart';
import 'package:app/Controller/auth_controller.dart';
import 'package:app/Controller/friend_controller.dart';
import 'package:app/Data/Network/request_client.dart';
import 'package:app/Model/enums.dart';
import 'package:app/Model/user.dart';
import 'package:app/Utils/comon.dart';
import 'package:app/Utils/input_utils.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/View/Friends/friend_detail.dart';
import 'package:app/View/Widget/k_net_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AddFriendView extends StatefulWidget {
  const AddFriendView({super.key});

  @override
  State<AddFriendView> createState() => _AddFriendViewState();
}

class _AddFriendViewState extends State<AddFriendView> {
  RxList<dynamic> suggestion = <dynamic>[].obs;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController teacherController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isValidated = false;
  RxBool isSearch = false.obs;
  RxBool isLoading = false.obs;
  Timer? debounce;
  final user = AuthController.to.user;

  void onRefresh() async {
    await FriendController.to.onRefreshSuggestion();
  }

  void onLoading() async {
    await FriendController.to.onNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FriendController>(builder: (cntrlr) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search'.tr,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                suggestion.clear();
                isLoading.value = false;
                isSearch.value = false;
                setState(() {});
              } else if (value.isNotEmpty && value.length > 1) {
                isLoading.value = true;
                setState(() {});
                if (debounce?.isActive ?? false) debounce!.cancel();
                debounce = Timer(const Duration(milliseconds: 100), () async {
                  final response =
                      await NetworkClient.get(Apis.searchFriend + value);
                  if (response.statusCode == 200) {
                    final jsonData = response.data;
                    log(jsonData.toString());
                    suggestion.value = jsonData;
                    isSearch.value = true;
                    isLoading.value = true;
                    setState(() {});
                  } else {
                    suggestion.clear();
                    isLoading.value = false;
                    isSearch.value = false;
                    setState(() {});
                  }
                });
                setState(() {});
              } else {
                suggestion.clear();
                isLoading.value = false;
                isSearch.value = false;
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 10),
          isLoading.value
              ? Obx(() => isSearch.value && suggestion.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: suggestion.length,
                          itemBuilder: (context, index) {
                            final friendUser = User.fromJson(suggestion[index]);
                            return ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: KCircularCacheImg(
                                  imgPath: friendUser.profilePicture,
                                  radius: 50),
                              title: Text(
                                  '${friendUser.firstName} ${friendUser.lastName}'),
                              subtitle: Text(friendUser.userType?.tr ?? ""),
                              onTap: () {
                                question(friendUser);
                              },
                              trailing: user?.userType == UserType.adult.name &&
                                      friendUser.userType ==
                                          UserType.student.name
                                  ? const SizedBox()
                                  : IconButton(
                                      onPressed: () {
                                        kOverlayWithAsync(
                                            asyncFunction: () async {
                                          await FriendController.to
                                              .sendRequest(context,
                                                  id: friendUser.id!)
                                              .then((value) {
                                            if (value) {
                                              Common.showSuccessDialog(context,
                                                  message:
                                                      'Request sent successfully'
                                                          .tr);
                                            }
                                          });
                                        });
                                      },
                                      icon: const Icon(
                                          Icons.person_add_outlined)),
                            );
                          }),
                    )
                  : isSearch.value && suggestion.isEmpty
                      ? Center(child: Text('No User Found'.tr))
                      : const CircularProgressIndicator())
              : Expanded(
                  child: cntrlr.isLoadingSuggestion
                      ? const Center(child: CircularProgressIndicator())
                      : SmartRefresher(
                          controller: cntrlr.refreshsuggestionController,
                          enablePullDown: true,
                          enablePullUp: true,
                          onRefresh: onRefresh,
                          onLoading: onLoading,
                          child: cntrlr.errorMsgofSuggestion != null
                              ? Center(
                                  child: Text(cntrlr.errorMsgofSuggestion!))
                              : cntrlr.suggestedFriendList.isEmpty
                                  ? Center(
                                      child: TextButton(
                                          onPressed: () => cntrlr.onRefresh(),
                                          child:
                                              Text('No Suggestion Found'.tr)))
                                  : SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Suggested Friends'.tr,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge),
                                          const SizedBox(height: 10),
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: cntrlr
                                                .suggestedFriendList.length,
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(height: 10),
                                            itemBuilder: (context, index) {
                                              final friendUser = cntrlr
                                                  .suggestedFriendList[index];
                                              return ListTile(
                                                contentPadding:
                                                    const EdgeInsets.all(0),
                                                leading: KCircularCacheImg(
                                                    imgPath: friendUser
                                                        .profilePicture,
                                                    radius: 50),
                                                title: Text(
                                                    '${friendUser.firstName} ${friendUser.lastName}'),
                                                subtitle: Text(
                                                    friendUser.userType?.tr ??
                                                        ""),
                                                onTap: () {
                                                  question(friendUser);
                                                },
                                                trailing: IconButton(
                                                    onPressed: () {
                                                      if (user?.userType ==
                                                              UserType
                                                                  .adult.name &&
                                                          friendUser.userType ==
                                                              UserType.student
                                                                  .name) {
                                                        question(friendUser);
                                                      } else {
                                                        kOverlayWithAsync(
                                                            asyncFunction:
                                                                () async {
                                                          await FriendController
                                                              .to
                                                              .sendRequest(
                                                                  context,
                                                                  id: friendUser
                                                                      .id!)
                                                              .then((value) {
                                                            if (value) {
                                                              Common.showSuccessDialog(
                                                                  context,
                                                                  message:
                                                                      'Request sent successfully'
                                                                          .tr);
                                                            }
                                                          });
                                                        });
                                                      }
                                                    },
                                                    icon: const Icon(Icons
                                                        .person_add_outlined)),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                        ),
                ),
        ]),
      );
    });
  }

  void question(User friendUser) {
    if (user?.userType == UserType.adult.name &&
        friendUser.userType == UserType.student.name) {
      Get.dialog(
        Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          elevation: 0.0,
          backgroundColor: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You have to answer these questions to add student'.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: classController,
                        validator: requiredValidator(),
                        keyboardType: TextInputType.text,
                        autovalidateMode: isValidated == true
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        decoration: InputDecoration(
                            hintText: 'Class Name of Student?'.tr),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: teacherController,
                        validator: requiredValidator(),
                        keyboardType: TextInputType.text,
                        autovalidateMode: isValidated == true
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        decoration: InputDecoration(
                            hintText: 'Teacher Name of Student?'.tr),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 60.0)),
                      onPressed: () {
                        setState(() {
                          isValidated = true;
                        });
                        if (formKey.currentState!.validate()) {
                          if (classController.text == friendUser.className &&
                              teacherController.text ==
                                  friendUser.teacherName) {
                            Get.back();
                            Get.to(
                              () => FriendDetail(
                                friend: friendUser,
                              ),
                            );
                          } else {
                            Common.showErrorDialog(context,
                                e: 'You have entered wrong information'.tr);
                          }
                        }
                      },
                      child: Text('Continue'.tr),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 60.0)),
                      onPressed: () => Get.back(),
                      child: Text('Cancel'.tr),
                    ),
                  ),
                ])
              ],
            ),
          ),
        ),
      );
    } else {
      Get.to(() => FriendDetail(friend: friendUser));
    }
  }
}
