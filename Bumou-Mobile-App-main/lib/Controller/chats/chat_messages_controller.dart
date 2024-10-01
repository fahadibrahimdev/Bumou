import 'dart:convert';

import 'package:app/Constants/api.dart';
import 'package:app/Controller/chats/chat_controller.dart';
import 'package:app/Data/Network/request_client.dart';
import 'package:app/Model/chats/chat_message.dart';
import 'package:app/Utils/logging.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../Utils/comon.dart';

class ChatMessagesController extends GetxController {
  List<ChatMessage> allMessages = [];
  String? errorMsg;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool isLastData = false;
  int page = 0;
  int pageSize = 100;

  @override
  void onInit() {
    getMessages();
    super.onInit();
  }

  Future<void> getMessages() async {
    try {
      isLoading = true;
      update();
      final response = await NetworkClient.get(
          '${Apis.messages}/${Get.arguments}?page=$page&pageSize=$pageSize');
      Logger.message("Get Messages: ${response.statusCode}");
      if (response.statusCode == 200) {
        allMessages = (response.data as List)
            .map((e) => ChatMessage.fromJson(e))
            .toList();
      }
    } on DioException catch (e) {
      errorMsg = Common.getErrorMsgOfDio(e);
      Logger.error(errorMsg!);
    } catch (e) {
      errorMsg = e.toString();
      Logger.error("-get-messages- Error: $errorMsg");
    } finally {
      isLoading = false;
      update();
    }
  }

  // _markAllMessagesAsRead() {
  //   try {
  //     for (int i = 0; i < allMessages.length; i++) {
  //       if (!allMessages[i]
  //           .readBy
  //           .map((e) => e.userId)
  //           .contains((Get.find<AuthController>().user!.id))) {
  //         markAsRead(chatroomId: Get.arguments, messageId: allMessages[i].id!);
  //       }
  //     }
  //   } catch (e) {
  //     // print("MARKING MESSAGES AS READ FAILED --> $e");
  //   }
  // }

  Future<void> markAsRead({
    required String chatroomId,
    required String messageId,
  }) async {
    try {
      final response =
          await NetworkClient.put('${Apis.markRead}/$chatroomId/$messageId');
      Logger.message("Mark as read: ${response.statusCode}");
      Logger.message(jsonEncode(response.data));
      if (response.statusCode == 200) {
        ReadBy readBy = ReadBy.fromJson(response.data);
        for (var element in allMessages) {
          if (element.id == readBy.messageId) {
            element.readBy.add(readBy);
          }
        }

        final chatController = Get.find<ChatController>();

        for (var element in chatController.allChatroom) {
          if (element.id == chatroomId) {
            element.unreadCount = element.unreadCount! - 1;
          }
        }

        chatController.update();
        chatController.updateBadge();
        update();
      }
    } on DioException catch (e) {
      Logger.error("Mark as read exception: ${Common.getErrorMsgOfDio(e)}");
    } catch (e) {
      Logger.error("-mark-as-read- Error: $e");
    }
  }
}
