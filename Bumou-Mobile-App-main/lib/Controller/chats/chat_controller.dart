import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app/Constants/api.dart';
import 'package:app/Controller/chats/chat_messages_controller.dart';
import 'package:app/Controller/help_controller.dart';
import 'package:app/Controller/help_message_controller.dart';
import 'package:app/Data/Local/hive_storage.dart';
import 'package:app/Data/Network/request_client.dart';
import 'package:app/Model/Help/help_model.dart';
import 'package:app/Model/chats/chatroom.dart';
import 'package:app/Utils/comon.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/Utils/logging.dart';
import 'package:app/View/Chat/call_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_ringtone_manager/flutter_ringtone_manager.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';

import '../../Model/chats/chat_message.dart';

class ChatController extends GetxController {
  late io.Socket socket;

  bool get isConnected => socket.connected;

  @override
  void onInit() {
    log("chat controller called....");
    connectSocket();
    getAllChatrooms();
    super.onInit();
  }

  @override
  void onClose() {
    disconnectSocket();
    super.onClose();
    log("on close called,");
  }

  void attachEventListeners() {
    connectionData();
    receiveMessage();
    receiveHelpRequests();
    listenHelpRequestRemove();
    listenHelpMessage();
  }

  void connectSocket() {
    try {
      socket = io.io(
        Apis.socketUrl,
        OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': LocalStorage.getAccessToken})
            .enableAutoConnect()
            .build(),
      );

      socket.onConnect((data) {
        log("🚀 Socket Connected: $data");
        if (!isListeningEvents) {
          log("🚀 LISTENERS INITIALIZED CALLED $data");
          attachEventListeners();
          isListeningEvents = true;
        }
      });

      socket.onDisconnect((_) {
        log('disconnect: $_');
        _removeAllListeners();
        isListeningEvents = false;
      });
      socket.onReconnectAttempt((_) => log('reconnecting: $_'));
      socket.onReconnect((_) {
        log('reconnected: $_');
        if (!isListeningEvents) {
          attachEventListeners();
          isListeningEvents = true;
        }
      });
      socket.onConnectError((_) => log('connect_timeout: $_'));
      socket.onError((data) {
        log("onError: $data");
        update(['connection']);
      });
      socket.onConnectError((data) {
        log("onConnectError: $data");
        update(['connection']);
      });
      socket.onReconnectError((data) {
        log("onReconnectError: $data");
        update(['connection']);
      });

      log("Is Socket Connected: ${socket.connected}");
    } catch (e) {
      log("Socket Connection Error: $e");
    }
  }

  deleteChatRoom(Chatroom chatroom) async {
    try {
      isLoading = true;
      update();

      log("URL --> ${Apis.chatrooms}/${chatroom.id}");

      final response =
          await NetworkClient.delete("${Apis.chatrooms}/${chatroom.id}");

      // Logger.message("Get All Chatrooms: ${response.statusCode}}");
      if (response.statusCode == 200) {
        await getAllChatrooms();
        Get.snackbar(
          "Chat Deleted successfully.".tr,
          "",
        );
      }
    } on DioException catch (e) {
      Logger.error("Delete ChatRoom Error: ${Common.getErrorMsgOfDio(e)}");
    } catch (e) {
      Logger.error("-get-all-chatrooms- Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }
  // void connectSocket() {
  //   log("CONNECTING SOCKET +++++");
  //   try {
  //     socket = io.io(
  //       Apis.socketUrl,
  //       OptionBuilder()
  //           .setTransports(['websocket'])
  //           .setExtraHeaders({'Authorization': LocalStorage.getAccessToken})
  //           .enableAutoConnect()
  //           .build(),
  //     );
  //     log("ACCESS TOKEN ${LocalStorage.getAccessToken} +++++");
  //     socket.onConnect((data) {
  //       if (isListeningEvents) {
  //         return;
  //       }
  //       connectionData();
  //       receiveMessage();
  //       receiveHelpRequests();
  //       listenHelpRequestRemove();
  //       listenHelpMessage();
  //       // receiveHelps();
  //       // onNewCall();
  //       log("🚀 Socket Connected: $data");
  //       if (!isListeningEvents) isListeningEvents = true;
  //     });
  //
  //     socket.onDisconnect((_) =>(){
  //       log('disconnect: $_');
  //       isListeningEvents=false;
  //     });
  //     socket.onReconnectAttempt((_) => log('reconnecting: $_'));
  //     socket.onReconnect((_) => log('reconnect: $_'));
  //     socket.onConnectError((_) => log('connect_timeout: $_'));
  //
  //     log("====== Socket Connected: ${socket.connected} ======");
  //     socket.onError((data) {
  //       log("onError: $data");
  //       update(['connection']);
  //     });
  //     socket.onConnectError((data) {
  //       log("onConnectError: $data");
  //       update(['connection']);
  //     });
  //     socket.onReconnectError((data) {
  //       log("onReconnectError: $data");
  //       update(['connection']);
  //     });
  //
  //     log("Is Socket Connected: ${socket.connected}");
  //   } catch (e) {
  //     log("Socket Connection Error: $e");
  //   }
  // }

  _removeAllListeners() {
    socket.clearListeners();
    // Remove all listeners to avoid duplication
    socket.off("chat");
    socket.off("help-request");
    socket.off("help-message");
    socket.off("help-request-remove");
    socket.off("connection");
  }

  void disconnectSocket() {
    try {
      socket.dispose();
      socket.close();
      _removeAllListeners();
      socket.disconnect();
      isListeningEvents = false; // Reset the flag
      log("Socket disconnected and listeners removed");
    } catch (e) {
      log("Socket Disconnection Error: $e");
    }
  }

  void sendMessage(Map<String, dynamic> message,
      {TextEditingController? msgController}) {
    try {
      socket.emitWithAck('new-message', message, ack: (a) {
        msgController?.clear();
      });
      msgController?.clear();
    } catch (e) {
      log("Socket Message Error: $e");
    }
  }

  void sendHelpMessage(Map<String, dynamic> message,
      {TextEditingController? msgController}) {
    try {
      socket.emitWithAck('help-message', message, ack: (a) {
        msgController?.clear();
      });
      msgController?.clear();
    } catch (e) {
      log("Socket Message Error: $e");
    }
  }

  bool isListeningEvents = false;

  void receiveHelpRequests() {
    try {
      socket.on("help-request", (data) {
        // log("On -help-: ${jsonEncode(data)}");
        HelpModel help = HelpModel.fromJson(data);
        final helpController = Get.find<HelpController>();
        if (!helpController.incomingHelps
                .any((element) => element.id == help.id) &&
            help.requestedById != LocalStorage.getUserId) {
          helpController.incomingHelps.insert(0, help);
          FlutterRingtoneManager().playAudioAsset("sounds/desk_bell.mp3");
          Get.snackbar(
            "New Help Request".tr,
            "Please accept the help requests".tr,
            mainButton: TextButton(
              onPressed: () async {
                await kOverlayWithAsync(asyncFunction: () async {
                  await Get.find<HelpController>()
                      .acceptHelp(Get.context!, helpId: help.id);
                });
              },
              child: Text("Accept".tr),
            ),
          );
        }

        helpController.refresh();
      });
    } catch (e) {
      log("-help- Error: $e");
    } finally {}
  }

  listenHelpMessage() {
    try {
      socket.on("help-message", (data) {
        // log("On -help-message-: ${jsonEncode(data)}");
        HelpMessage message = HelpMessage.fromJson(data);
        HelpModel help = HelpModel.fromJson(data['help']);
        help.messages.insert(0, message);

        final helpController = Get.find<HelpController>();

        if (helpController.currentHelp != null &&
            helpController.currentHelp!.id == help.id) {
          helpController.currentHelp = null;
        }
        int indexWhere = helpController.ongoingHelps
            .indexWhere((element) => element.id == help.id);
        if (indexWhere != -1) {
          helpController.ongoingHelps[indexWhere] = help;
        } else {
          helpController.ongoingHelps.insert(0, help);
        }
        if (Get.isRegistered<HelpMessagesController>() &&
            Get.arguments == help.id) {
          Get.find<HelpMessagesController>().allMessages.insert(0, message);
          Get.find<HelpMessagesController>().update();
        }
        helpController.refresh();
      });
    } catch (e) {
      log("-help-message- Error: $e");
    } finally {}
  }

  void listenHelpRequestRemove() {
    try {
      socket.on("help-request-remove", (data) {
        // log("On (help-request-remove): ${jsonEncode(data)}");

        final helpController = Get.find<HelpController>();
        int indexWhere = helpController.incomingHelps
            .indexWhere((element) => element.id == data);
        if (indexWhere != -1) {
          helpController.incomingHelps.removeAt(indexWhere);
          helpController.refresh();
        }
      });
    } catch (e) {
      log("(help-request-remove) Error: $e");
    } finally {}
  }

  void receiveMessage() {
    try {
      socket.on("chat", (data) {
        log("On -chat-");

        log("DATA -> ${jsonEncode(data)}");

        log("Controller not found: ${Get.arguments}");
        data['chatroom']['members']
            .removeWhere((element) => element['id'] == LocalStorage.getUserId);
        Chatroom newChatRoom = Chatroom.fromJson(data['chatroom']);

        allChatroom.removeWhere((element) => element.id == newChatRoom.id);

        if (Get.isRegistered<ChatMessagesController>()) {
          log("Controller found: ${Get.arguments}");
          if (Get.arguments == data['chatroom']['id']) {
            newChatRoom.unreadCount = 0;

            log("active chatroom found: ${data['chatroom']['id']}");
            Get.find<ChatMessagesController>()
                .allMessages
                .insert(0, ChatMessage.fromJson(data['message']));
            Get.find<ChatMessagesController>().update();
          } else {
            if (Get.isRegistered<ChatMessagesController>()) {
              log("Controller found: ${Get.arguments}");
              if (Get.arguments == data['chatroom']['id']) {
                log("active chatroom found: ${data['chatroom']['id']}");
                Get.find<ChatMessagesController>()
                    .allMessages
                    .insert(0, ChatMessage.fromJson(data['message']));
                Get.find<ChatMessagesController>().update();
              }
            } else {
              log("I AM REACHED HERE -->");
            }
          }
        } else {}

        allChatroom.insert(0, newChatRoom);
        updateBadge();
        update();
      });
    } catch (e) {
      log("-chat- Error: $e");
    }
  }

  void checkSubs() {
    // log(socket.opts.toString());
    if (socket.subs != null && socket.subs!.isNotEmpty) {
      log("=====> Socket Subscriptions: ${socket.subs!.length}");
      for (var sub in socket.subs!) {
        log("Socket Subscriptions: ${sub.toString()}");
      }
    } else {
      log("Socket Subscriptions: Empty");
    }
  }

  dynamic incomingSDPOffer;

  void onNewCall() {
    log("making call...");
    try {
      socket.on("newCall", (data) {
        log("📱 On -call-: $data");
        FlutterRingtonePlayer().playRingtone(looping: true);
        incomingSDPOffer = data;
        Get.snackbar(
          "Incoming Call",
          "Incoming Call",
          isDismissible: false,
          duration: const Duration(seconds: 60),
          mainButton: TextButton(
            onPressed: () {
              FlutterRingtonePlayer().stop();
              if (Get.currentRoute != '/CallScreen') {
                Get.closeCurrentSnackbar();
                log("CallerID: ${data['callerId']}, CalleeID: ${data['calleeId']}");
                Get.to(() => CallScreen(
                    callerId: data['calleeId'], calleeId: data['callerId']));
              }
            },
            child: const Text("Accept"),
          ),
        );
      });
    } catch (e) {
      log("-call- Error: $e");
    }
  }

  void connectionData() {
    try {
      socket.on("connection", (data) {
        log("On -connection-: $data");
        update(['connection']);
      });
    } catch (e) {
      log("-connection- Error: $e");
    }
  }

  Future<void> getAllChatrooms({
    bool shouldShowLoading = true,
  }) async {
    try {
      if (shouldShowLoading) {
        isLoading = true;
        update();
      }
      final response = await NetworkClient.get(
          "${Apis.chatrooms}?page=$page&pageSize=$pageSize");
      Logger.message("Get All Chatrooms: ${response.statusCode}}");
      if (response.statusCode == 200) {
        allChatroom = (response.data as List).map((e) {
          return Chatroom.fromJson(e);
        }).toList();

        updateBadge();
      }
    } on DioException catch (e) {
      Logger.error("Get all chatroom exception: ${Common.getErrorMsgOfDio(e)}");
    } catch (e) {
      Logger.error("-get-all-chatrooms- Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  updateBadge() async {
    final count = allChatroom.fold(0, (previousValue, element) {
      if (element.unreadCount == null) return previousValue;
      return previousValue + element.unreadCount!;
    });

    if (Platform.isIOS) {
      if (await FlutterAppBadger.isAppBadgeSupported()) {
        await FlutterAppBadger.updateBadgeCount(count);

        log("BADGE COUNT UPDATED TO -> $count");
      }
    } else if (Platform.isAndroid) {
      // await FlutterDynamicIcon.setApplicationIconBadgeNumber(count);
      // if (await FlutterAppIconBadge.isAppBadgeSupported()) {
      //   FlutterAppIconBadge.updateBadge(count);
      // }
    }
  }

  // void sendHelpMessage(BuildContext context,
  //     {required String helpId, required String message}) {
  //   try {
  //     socket.emit("help", {
  //       "message": message,
  //       "helpId": helpId,
  //       "senderId": LocalStorage.getUserId,
  //     });
  //   } catch (e) {
  //     log("Send Help Message Error: $e");
  //   }
  // }

  List<Chatroom> allChatroom = [];
  String? chatroomErrorMsg;
  bool isLoading = false;
  bool isLoadMore = false;
  int page = 0;
  int pageSize = 20;
}
