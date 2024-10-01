import 'package:app/Constants/color.dart';
import 'package:app/Controller/help_controller.dart';
import 'package:app/Data/Local/hive_storage.dart';
import 'package:app/Utils/datetime.dart';
import 'package:app/View/Help/components/delete_help_confirmation_dialog.dart';
import 'package:app/View/Help/help_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class OngoingRequestsView extends StatefulWidget {
  const OngoingRequestsView({super.key});

  @override
  State<OngoingRequestsView> createState() => _OngoingRequestsViewState();
}

class _OngoingRequestsViewState extends State<OngoingRequestsView> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HelpController>(builder: (controller) {
      Widget content;

      if (controller.isLoadingOngoing) {
        content = const Center(
          child: CircularProgressIndicator(),
        );
      } else if (controller.errorMessageOngoing != null) {
        content = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${controller.errorMessageOngoing}".tr,
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
      } else if (controller.ongoingHelps.isEmpty) {
        content = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No ongoing help requests".tr,
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
        controller.sortOngoingHelp();
        content = CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final help = controller.ongoingHelps[index];
                    final message = help.messages.first;
                    final bool isRequestedByMe =
                        help.requestedBy.id == LocalStorage.getUserId;
                    final String username = isRequestedByMe
                        ? help.helper!.username ?? 'Unknown'.tr
                        : help.requestedBy.username ?? 'Unknown'.tr;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Card(
                        color: isRequestedByMe
                            ? Colors.green[100]
                            : Colors.blue[100],
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          // onLongPress: () async {},
                          onTap: () {
                            Get.to(
                              () => HelpChatView(help: help),
                              arguments: help.id,
                            );
                          },
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            username,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            message.type == "JOIN"
                                                ? "${message.sender.username} ${"joined the chat".tr}"
                                                : message.message != null
                                                    ? message.message!
                                                    : "",
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              help.messages.first.updatedAt
                                                  .timeAgo,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                  right: 0,
                                  child: IconButton(
                                    onPressed: () async {
                                      if (await DeleteHelpConfirmationDialog
                                          .confirm(context)) {
                                        controller.deleteHelp(help);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: controller.ongoingHelps.length,
                ),
              ),
            ),
          ],
        );
      }
      return SmartRefresher(
        controller: refreshController,
        onRefresh: () async {
          await Get.find<HelpController>().getOngoingHelp();
          refreshController.refreshCompleted();
        },
        child: content,
      );
    });
  }
}
