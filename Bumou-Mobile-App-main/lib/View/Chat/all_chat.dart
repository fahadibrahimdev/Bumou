import 'package:app/Constants/color.dart';
import 'package:app/Controller/chats/chat_controller.dart';
import 'package:app/Controller/friend_controller.dart';
import 'package:app/Data/Local/hive_storage.dart';
import 'package:app/Model/chats/chat_message.dart';
import 'package:app/Model/chats/chatroom.dart';
import 'package:app/Utils/datetime.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/View/Chat/Widget/delete_chat_confirmation_dialog.dart';
import 'package:app/View/Chat/message.dart';
import 'package:app/View/Friends/all_friend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../Widget/k_net_image.dart';

class ChatRoomView extends StatefulWidget {
  const ChatRoomView({super.key});

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  // get icon => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GetBuilder<ChatController>(
              id: 'connection',
              assignId: true,
              builder: (cntrlr) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor:
                        cntrlr.socket.connected ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
            Text('Messages'.tr),
          ],
        ),
        centerTitle: false,
        actions: [
          GetBuilder<FriendController>(builder: (cntrlr) {
            return Badge(
              isLabelVisible: cntrlr.myRequest.isNotEmpty,
              label: Text(cntrlr.myRequest.length.toString()),
              child: IconButton(
                onPressed: () => Get.to(() => const FriendView()),
                icon: const Icon(Icons.person_add, color: Colors.black),
              ),
            );
          }),
          IconButton(
            onPressed: () {
              Get.find<ChatController>().getAllChatrooms();
            },
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
      body: GetBuilder<ChatController>(
        builder: (cntrlr) {
          return cntrlr.isLoading
              ? const Center(child: LoadingWidget())
              : cntrlr.chatroomErrorMsg != null
                  ? Center(child: Text(cntrlr.chatroomErrorMsg!))
                  : cntrlr.allChatroom.isEmpty
                      ? Center(child: Text('No Chatrooms'.tr))
                      : ListView.builder(
                          itemCount: cntrlr.allChatroom.length,
                          itemBuilder: (context, index) {
                            Chatroom chatroom = cntrlr.allChatroom[index];
                            bool isMediaMsg = chatroom.messages != null &&
                                chatroom.messages!.isNotEmpty &&
                                chatroom.messages!.first.chatMessageType !=
                                    ChatMessageType.TEXT;
                            bool isDeletedUser =
                                chatroom.members!.first.id == '';
                            return Slidable(
                              key: ValueKey(index),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                extentRatio: 0.25,
                                openThreshold: 0.1,
                                children: [
                                  SlidableAction(
                                    onPressed: (ctx) async {
                                      if (await DeleteChatConfirmationDialog
                                          .confirm(context)) {
                                        cntrlr.deleteChatRoom(chatroom);
                                      }
                                    },
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                  ),
                                  // Expanded(
                                  //   child: InkWell(
                                  // onTap: () async {
                                  //   if (await DeleteChatConfirmationDialog
                                  //       .confirm(context)) {
                                  //     cntrlr.deleteChatRoom(chatroom);
                                  //   }
                                  // },
                                  //     child: Ink(
                                  //       height: double.maxFinite,
                                  //       color: Colors.red,
                                  //       child: const Icon(
                                  //         Icons.delete,
                                  //         color: Colors.white,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(),
                                leading: Hero(
                                  tag: chatroom.id!,
                                  child: KCircularCacheImg(
                                      imgPath: chatroom
                                          .members!.first.profilePicture,
                                      radius: 50),
                                ),
                                title: Text(
                                  "${chatroom.members?.first.firstName} ${chatroom.members?.first.lastName}",
                                  style: TextStyle(
                                      decoration: isDeletedUser
                                          ? TextDecoration.lineThrough
                                          : null),
                                ),
                                subtitle: (chatroom.messages != null &&
                                            chatroom.messages!.isNotEmpty) ||
                                        isMediaMsg
                                    ? buildRecentMessage(
                                        chatroom.messages!.first, isMediaMsg)
                                    : Text(
                                        'Start Chatting'.tr,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (chatroom.unreadCount != null &&
                                        chatroom.unreadCount! > 0)
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          chatroom.unreadCount.toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    Text(chatroom.updatedAt.timeAgo),
                                  ],
                                ),
                                onTap: () => Get.to(
                                  () => MessageView(chatroom: chatroom),
                                  arguments: chatroom.id,
                                ),
                              ),
                            );
                          },
                        );
        },
      ),
    );
  }

  Widget buildRecentMessage(ChatMessage message, bool isMediaMessage) {
    bool isMyMessage = message.senderId == LocalStorage.getUserId;
    String messageText = isMediaMessage
        ? isMyMessage
            ? 'you sent a '.tr +
                message.chatMessageType!.toShortString.tr +
                ' message'.tr
            : "you received a ".tr +
                message.chatMessageType!.toShortString.tr +
                ' message'.tr
        : message.message!;
    return Row(
      children: [
        if (isMyMessage)
          const Icon(
            Icons.done,
            size: 15,
            color: AppColors.blue,
          ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            messageText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
