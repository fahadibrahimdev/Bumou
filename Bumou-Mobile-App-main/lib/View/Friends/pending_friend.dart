import 'package:app/Constants/color.dart';
import 'package:app/Controller/friend_controller.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/Utils/navigations.dart';
import 'package:app/View/Widget/k_net_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PendingFriend extends StatefulWidget {
  const PendingFriend({super.key});

  @override
  State<PendingFriend> createState() => _PendingFriendState();
}

class _PendingFriendState extends State<PendingFriend> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FriendController>(builder: (cntrlr) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: cntrlr.isLoadingMyRequests
            ? const Center(child: CircularProgressIndicator())
            : cntrlr.myRequestErrorMsg != null
                ? Center(child: Text(cntrlr.myRequestErrorMsg!))
                : cntrlr.myRequest.isEmpty
                    ? SmartRefresher(
                        controller: cntrlr.refreshPendingController,
                        enablePullDown: true,
                        header: const WaterDropHeader(
                            waterDropColor: AppColors.primary),
                        onRefresh: cntrlr.onRefresh,
                        onLoading: cntrlr.onLoading,
                        child: Center(
                          child: Text('No Pending Request'.tr),
                        ),
                      )
                    : SmartRefresher(
                        controller: cntrlr.refreshPendingController,
                        enablePullDown: true,
                        header: const WaterDropHeader(
                            waterDropColor: AppColors.primary),
                        onRefresh: cntrlr.onRefresh,
                        onLoading: cntrlr.onLoading,
                        child: GridView.builder(
                            shrinkWrap: true,
                            itemCount: cntrlr.myRequest.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10),
                            itemBuilder: (context, index) {
                              final user = cntrlr.myRequest[index];
                              return InkWell(
                                onTap: () => navigateToUserDetails(user.id!),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.primary40),
                                      borderRadius: BorderRadius.circular(20),
                                      color: AppColors.white),
                                  child: Column(children: [
                                    KCircularCacheImg(
                                        imgPath: user.profilePicture,
                                        radius: 80),
                                    const SizedBox(height: 10),
                                    Text('${user.firstName} ${user.lastName}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: FilledButton(
                                              style: FilledButton.styleFrom(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              onPressed: () {
                                                kOverlayWithAsync(
                                                    asyncFunction: () async {
                                                  await cntrlr.acceptRequest(
                                                      context,
                                                      id: user.friendShipId!,
                                                      status: 'ACCEPTED');
                                                });
                                              },
                                              child: Text('Confirm'.tr),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              onPressed: () {
                                                kOverlayWithAsync(
                                                    asyncFunction: () async {
                                                  await cntrlr.acceptRequest(
                                                      context,
                                                      id: user.friendShipId!,
                                                      status: 'REJECTED');
                                                });
                                              },
                                              child: Text('Cancel'.tr),
                                            ),
                                          ),
                                        ]),
                                  ]),
                                ),
                              );
                            }),
                      ),
      );
    });
  }
}
