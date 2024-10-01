import 'package:app/Constants/color.dart';
import 'package:app/Controller/help_controller.dart';
import 'package:app/Utils/datetime.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IncomingRequestsView extends StatefulWidget {
  const IncomingRequestsView({super.key});

  @override
  State<IncomingRequestsView> createState() => _IncomingRequestsViewState();
}

class _IncomingRequestsViewState extends State<IncomingRequestsView> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HelpController>(
      builder: (controller) {
        Widget content;
        if (controller.isLoadingIncoming) {
          content = const Center(
            child: CircularProgressIndicator(),
          );
        } else if (controller.errorMessageIncoming != null) {
          content = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${controller.errorMessageIncoming}".tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.error,
                      ),
                ),
                Text(
                  "Pull down to refresh".tr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        } else if (controller.incomingHelps.isEmpty) {
          content = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No incoming help requests".tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  "Pull down to refresh".tr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        } else {
          content = CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final help = controller.incomingHelps[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        help.requestedBy.username ??
                                            'Unknown'.tr,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        help.messages.first.message ??
                                            'Need help'.tr,
                                      ),
                                      Text(
                                        help.updatedAt.timeAgo,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Card(
                                  color: Colors.green,
                                  child: InkWell(
                                    onTap: () async {
                                      await kOverlayWithAsync(
                                          asyncFunction: () async {
                                        await Get.find<HelpController>()
                                            .acceptHelp(context,
                                                helpId: help.id);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "Accept".tr,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                // FilledButton.icon(
                                //   onPressed: () {
                                //     Get.toNamed('/help/accept/${help.id}');
                                //   },
                                //   label: Text('Accept'.tr),
                                //   icon: const Icon(Icons.check),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: controller.incomingHelps.length,
                  ),
                ),
              ),
            ],
          );
        }
        return SmartRefresher(
          controller: refreshController,
          onRefresh: () async {
            await Get.find<HelpController>().getIncomingHelps();
            refreshController.refreshCompleted();
          },
          child: content,
        );
      },
    );
  }
}
