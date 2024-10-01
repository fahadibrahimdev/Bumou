import 'package:app/Constants/color.dart';
import 'package:app/Controller/chats/chat_controller.dart';
import 'package:app/Controller/help_message_controller.dart';
import 'package:app/Data/Local/hive_storage.dart';
import 'package:app/Model/Help/help_model.dart';
import 'package:app/Model/user.dart';
import 'package:app/Utils/datetime.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Widget/custom_text_long_press_widget.dart';

class HelpChatView extends StatefulWidget {
  final HelpModel help;
  const HelpChatView({super.key, required this.help});

  @override
  State<HelpChatView> createState() => _HelpChatViewState();
}

class _HelpChatViewState extends State<HelpChatView> {
  late User user;
  final msgController = TextEditingController();
  @override
  initState() {
    Get.put(HelpMessagesController());
    if (widget.help.requestedBy.id == LocalStorage.getUserId) {
      user = widget.help.helper!;
    } else {
      user = widget.help.requestedBy;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          user.username ?? "${user.firstName} ${user.lastName}",
          // style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: GetBuilder<HelpMessagesController>(
        builder: (cntrlr) {
          return Column(
            children: [
              Expanded(
                child: cntrlr.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : cntrlr.errorMsg != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${cntrlr.errorMsg}".tr,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.error,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  cntrlr.onInit();
                                },
                                child: Text("Refresh".tr),
                              ),
                            ],
                          )
                        : cntrlr.allMessages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "No messages yet".tr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () {
                                        cntrlr.onInit();
                                      },
                                      child: Text("Refresh".tr),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                reverse: true,
                                itemCount: cntrlr.allMessages.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return HelpMessageBubble(
                                    message: cntrlr.allMessages[index],
                                  );
                                },
                              ),
              ),
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: msgController,
                          maxLines: 5,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Type a message'.tr,
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary, iconSize: 20),
                        onPressed: () async {
                          if (msgController.text.isNotEmpty) {
                            Get.find<ChatController>().sendHelpMessage(
                              {
                                "helpId": widget.help.id,
                                "message": msgController.text,
                                "senderId": LocalStorage.getUserId,
                              },
                              msgController: msgController,
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.send,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HelpMessageBubble extends StatelessWidget {
  const HelpMessageBubble({super.key, required this.message});
  final HelpMessage message;
  @override
  Widget build(BuildContext context) {
    if (message.type == "JOIN") {
      return Align(
        alignment: Alignment.center,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              "${message.sender.username} ${"joined the chat".tr}",
              // style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      );
    }
    bool isMyMessage = message.sender.id == LocalStorage.getUserId;
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: isMyMessage ? 50 : 0,
          right: isMyMessage ? 0 : 50,
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMyMessage ? 10 : 0),
              topRight: Radius.circular(isMyMessage ? 0 : 10),
              bottomLeft: const Radius.circular(10),
              bottomRight: const Radius.circular(10),
            ),
          ),
          color: isMyMessage ? AppColors.primaryLight : AppColors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              crossAxisAlignment: isMyMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                CustomTextLongPressWidget(
                  message:  message.message ?? "${message.type} ${"message".tr}",
                ),
                // Text(
                //   message.message ?? "${message.type} ${"message".tr}",
                // ),
                const SizedBox(height: 5),
                Align(
                  alignment: isMyMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Text(
                    message.createdAt.timeAgo,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
