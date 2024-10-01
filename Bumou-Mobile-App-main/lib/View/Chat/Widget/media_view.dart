import 'dart:io';

import 'package:app/Constants/color.dart';
import 'package:app/Controller/auth_controller.dart';
import 'package:app/Controller/chats/chat_controller.dart';
import 'package:app/Data/Local/hive_storage.dart';
import 'package:app/Model/chats/chat_message.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/View/Widget/k_net_image.dart';
import 'package:app/View/Widget/video_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KMediaView extends StatelessWidget {
  const KMediaView({
    super.key,
    required this.filePath,
    required this.reciverId,
    required this.chatId,
    required this.type,
  });
  final String filePath;
  final String reciverId;
  final String chatId;
  final String type;

  @override
  Widget build(BuildContext context) {
    final TextEditingController msgController = TextEditingController();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton.filled(
              style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white),
              onPressed: () => Get.back(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: type == 'image'
                    ? Hero(
                        tag: filePath,
                        child: filePath.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: filePath,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                placeholder: (context, url) =>
                                    const KShimmerWidget(),
                              )
                            : filePath.startsWith('assets')
                                ? Image.asset(filePath, fit: BoxFit.cover)
                                : Image.file(File(filePath), fit: BoxFit.cover))
                    : VideoPlayerScreen(videoUrl: filePath),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: msgController,
                        maxLines: 5,
                        minLines: 1,
                        decoration:
                            InputDecoration(hintText: 'Type a message'.tr),
                      ),
                    ),
                    IconButton.filled(
                        style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white),
                        onPressed: () async {
                          kOverlayWithAsync(
                            asyncFunction: () async {
                              final fileUrl = await AuthController.to
                                  .uploadFile(context,
                                      file: filePath, path: 'Chat');
                              ChatMessage msg = ChatMessage(
                                chatMessageStatus: ChatMessageStatus.SENT,
                                chatMessageType: type == 'video'
                                    ? ChatMessageType.VIDEO
                                    : ChatMessageType.IMAGE,
                                message: msgController.text.trim(),
                                senderId: LocalStorage.getUserId!,
                                receiverId: reciverId,
                                chatroomId: chatId,
                                file: fileUrl,
                              );
                              Get.find<ChatController>().sendMessage(
                                  msg.toJson(),
                                  msgController: msgController);
                              Get.back();
                            },
                          );
                        },
                        icon: const Icon(Icons.send))
                  ],
                ),
              ),
            ),
          ],
        ),

        // bottomNavigationBar: SafeArea(
        //     child: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child:
        // )),
      ),
    );
  }
}
