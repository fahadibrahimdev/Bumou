// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:app/Constants/color.dart';
import 'package:app/Controller/auth_controller.dart';
import 'package:app/Controller/chats/chat_controller.dart';
import 'package:app/Controller/chats/chat_messages_controller.dart';
import 'package:app/Model/chats/chat_message.dart';
import 'package:app/Model/chats/chatroom.dart';
import 'package:app/Utils/datetime.dart';
import 'package:app/Utils/image_picker.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/Utils/navigations.dart';
import 'package:app/Utils/request_permissions_handler.dart';
import 'package:app/View/Chat/Widget/media_view.dart';
import 'package:app/View/Chat/voice_message.dart';
import 'package:app/View/Widget/k_net_image.dart';
import 'package:app/View/Widget/video_screen.dart';
import 'package:app/View/Widget/video_thumbnail_widget.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../Data/Local/hive_storage.dart';
import '../Widget/custom_text_long_press_widget.dart';
import 'call_view.dart';

class MessageView extends StatefulWidget {
  const MessageView({super.key, required this.chatroom});

  final Chatroom chatroom;

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  final TextEditingController msgController = TextEditingController();

  // AnimationController? controller;
  RecorderController recordCntrlr = RecorderController();

  bool isPlaying = false;
  bool isTextFieldEmpty = false;

  String? tempPath;

  void initialiseControllers() {
    recordCntrlr = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  @override
  void initState() {
    // controller = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 600),
    // );
    Get.put(ChatMessagesController());
    initialiseControllers();
    super.initState();
  }

  @override
  void dispose() {
    recordCntrlr.dispose();
    super.dispose();
  }

  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    bool isDeletedUser = widget.chatroom.members!.first.id == '';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () =>
                navigateToUserDetails(widget.chatroom.members!.first.id!),
            child: Row(
              children: [
                Hero(
                  tag: widget.chatroom.id!,
                  child: KCircularCacheImg(
                    imgPath: widget.chatroom.members!.first.profilePicture,
                    radius: 40,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${widget.chatroom.members!.first.firstName} ${widget.chatroom.members!.first.lastName}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
        actions: [
          // if (!isDeletedUser) ...[
          //   IconButton(
          //     onPressed: () {
          //       Get.find<ChatController>().onNewCall();
          //     },
          //     icon: const Icon(Icons.call),
          //   ),
          //   IconButton(
          //     onPressed: () {
          //
          //     },
          //     icon: const Icon(Icons.video_call),
          //   ),
          // ]
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GetBuilder<ChatMessagesController>(
              builder: (cntrlr) {
                return cntrlr.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : cntrlr.errorMsg != null
                        ? Center(
                            child: Text(cntrlr.errorMsg!,
                                style: Theme.of(context).textTheme.titleMedium))
                        : cntrlr.allMessages.isEmpty
                            ? Center(
                                child: Text('No Messages, Start Chatting'.tr),
                              )
                            : MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                removeBottom: true,
                                child: SingleChildScrollView(
                                  reverse: true,
                                  child: ListView.builder(
                                    reverse: true,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: cntrlr.allMessages.length,
                                    itemBuilder: (context, index) {
                                      // bool isAlredySeen = controller!.status ==
                                      //     AnimationStatus.completed;
                                      final message = cntrlr.allMessages[index];
                                      return VisibilityDetector(
                                        key: Key(message.id!),
                                        onVisibilityChanged: (info) {
                                          // log("Visibility: ${info.key.toString().replaceAll("[<'", "").replaceAll("'>]", "")}");
                                          if (info.visibleFraction == 0) {
                                            print('not visible');
                                          } else {
                                            if (message.readBy.isEmpty) {
                                              cntrlr.markAsRead(
                                                chatroomId: widget.chatroom.id!,
                                                messageId: cntrlr
                                                    .allMessages[index].id!,
                                              );
                                            } else {
                                              // print('Already read');
                                            }
                                          }
                                        },
                                        child: MessageBubble(
                                          message: message,
                                          chatroom: widget.chatroom,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
              },
            ),
          ),
          if (!isDeletedUser)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                child: Row(
                  children: [
                    isPlaying
                        ? IconButton.filled(
                            style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                iconSize: 20),
                            onPressed: () async {
                              await recordCntrlr.stop();
                              setState(() {
                                isPlaying = false;
                              });
                            },
                            icon: const Icon(Icons.delete_forever_outlined),
                          )
                        : IconButton.filled(
                            style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                iconSize: 20),
                            onPressed: () {
                              chatBottomSheet(context);
                            },
                            icon: const Icon(Icons.add)),
                    Expanded(
                      child: isPlaying
                          ? AudioWaveforms(
                              size: Size(Get.width / 1.5, 40),
                              recorderController: recordCntrlr,
                              enableGesture: true,
                              waveStyle: const WaveStyle(
                                waveColor: Colors.black,
                                spacing: 8.0,
                                extendWaveform: true,
                                showMiddleLine: false,
                              ),
                            )
                          : TextFormField(
                              controller: msgController,
                              maxLines: 5,
                              minLines: 1,
                              decoration: InputDecoration(
                                hintText: 'Type a message'.tr,
                              ),
                              onChanged: (value) => setState(() {}),
                            ),
                    ),
                    msgController.text.isEmpty && !isPlaying
                        ? IconButton.filled(
                            style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                iconSize: 20),
                            onPressed: () async {
                              bool isAllowed = await RequestPermissionHandler
                                  .checkRequstMicrophonePermission(context);
                              if (!isAllowed) {
                                return;
                              }

                              if (tempPath != null) {
                                await File(tempPath!).delete();
                                tempPath = null;
                              }
                              await recordCntrlr.stop();
                              Directory appDocDirectory =
                                  await getApplicationDocumentsDirectory();
                              tempPath =
                                  '${appDocDirectory.path}/${DateTime.now().toIso8601String()}.m4a';
                              await recordCntrlr.record(path: tempPath);
                              setState(() {
                                isPlaying = true;
                              });
                            },
                            icon: const Icon(Icons.mic_none_outlined))
                        : IconButton.filled(
                            style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                iconSize: 20),
                            onPressed: () async {
                              if (msgController.text.isNotEmpty) {
                                ChatMessage msg = ChatMessage(
                                  chatMessageStatus: ChatMessageStatus.SENT,
                                  chatMessageType: ChatMessageType.TEXT,
                                  message: msgController.text.trim(),
                                  senderId: LocalStorage.getUserId!,
                                  receiverId: widget.chatroom.members?.first.id,
                                  chatroomId: widget.chatroom.id,
                                );
                                Get.find<ChatController>().sendMessage(
                                    msg.toJson(),
                                    msgController: msgController);
                                setState(() {
                                  isPlaying = false;
                                });
                              }
                              if (isPlaying) {
                                if (tempPath == null) {
                                  return;
                                }
                                await recordCntrlr.stop();
                                await kOverlayWithAsync(
                                    asyncFunction: () async {
                                  final url = await AuthController.to
                                      .uploadFile(context,
                                          file: tempPath!, path: 'Message');
                                  await File(tempPath!).delete();
                                  tempPath = null;
                                  ChatMessage msg = ChatMessage(
                                    chatMessageStatus: ChatMessageStatus.SENT,
                                    chatMessageType: ChatMessageType.VOICE,
                                    message: msgController.text.trim(),
                                    senderId: LocalStorage.getUserId!,
                                    receiverId:
                                        widget.chatroom.members?.first.id,
                                    chatroomId: widget.chatroom.id,
                                    file: url,
                                  );
                                  Get.find<ChatController>().sendMessage(
                                      msg.toJson(),
                                      msgController: msgController);
                                });
                                setState(() {
                                  isPlaying = false;
                                });
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
      ),
    );
  }

  Future<dynamic> chatBottomSheet(BuildContext context) {
    return Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: AppColors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    onTap: () async {
                      Get.back();
                      final filePath = await FilePickerUtils.imageSourcePicker(
                          context, ImageSource.camera);
                      if (filePath != null) {
                        Get.to(() => KMediaView(
                              filePath: filePath,
                              reciverId: widget.chatroom.members!.first.id!,
                              chatId: widget.chatroom.id!,
                              type: 'image',
                            ));
                      }
                    },
                    leading: const Icon(Icons.camera_alt_outlined),
                    title: Text('Camera'.tr),
                  ),
                  ListTile(
                    onTap: () async {
                      Get.back();
                      final img = await FilePickerUtils.pickMedia(context);
                      if (img != null) {
                        final mimeType = lookupMimeType(img);
                        final type = mimeType!.split('/')[0];
                        Get.to(() => KMediaView(
                              filePath: img,
                              reciverId: widget.chatroom.members!.first.id!,
                              chatId: widget.chatroom.id!,
                              type: type,
                            ));
                      }
                    },
                    leading: const Icon(Icons.photo_library_outlined),
                    title: Text('Gallery'.tr),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: AppColors.white),
              child: ListTile(
                onTap: () => Get.back(),
                title: Text('Cancel'.tr),
              ),
            )
          ],
        ),
      ),
      backgroundColor: AppColors.transparent,
      isDismissible: false,
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key, required this.message, required this.chatroom});

  final ChatMessage message;
  final Chatroom chatroom;

  @override
  Widget build(BuildContext context) {
    bool isMe = message.senderId == LocalStorage.getUserId;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: isMe
              ? const EdgeInsets.only(left: 60, right: 10, top: 15)
              : const EdgeInsets.only(left: 10, right: 60, top: 15),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : AppColors.black10,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              message.file != null
                  ? message.chatMessageType == ChatMessageType.VIDEO
                      ? GestureDetector(
                          onTap: () => Get.to(() => VideoPlayerScreen(
                              videoUrl: message.file!, isMessage: true)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: VideoThumbnailWidget(
                                  videoUrl: message.file!)))
                      : message.chatMessageType == ChatMessageType.IMAGE
                          ? GestureDetector(
                              onTap: () => Get.to(() => FullImageView(
                                  imgPath: message.file!, isMessage: true)),
                              child: Hero(
                                tag: message.file!,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child:
                                        KCachedImage(imgPath: message.file!)),
                              ),
                            )
                          : message.chatMessageType == ChatMessageType.VOICE
                              ? AudioMessageWidget(msg: message)
                              : const SizedBox()
                  : const SizedBox(),
              message.message != null && message.message != ''
                  ? CustomTextLongPressWidget(
                      message: message.message ?? "***",
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: isMe ? AppColors.white : AppColors.black,
                              ),
                    )
                  // SelectableAutoLinkText(
                  //         message.message ?? "***",
                  //         linkStyle: const TextStyle(color: Colors.blueAccent),
                  //         highlightedLinkStyle: TextStyle(
                  //           color: Colors.blueAccent,
                  //           backgroundColor: Colors.blueAccent.withAlpha(0x33),
                  //         ),
                  //         onTap: (url) => launchUrl(Uri.parse(url)),
                  //         onLongPress: (url) => Share.share(url),
                  //         contextMenuBuilder: (context, editableTextState) {
                  //           final TextEditingValue value =
                  //               editableTextState.textEditingValue;
                  //           final List<ContextMenuButtonItem> buttonItems = [];
                  //           buttonItems.insertAll(
                  //             0,
                  //             [
                  //               ContextMenuButtonItem(
                  //                 label: '举报',
                  //                 onPressed: () {
                  //                   // Implement your logic for handling "举报" here
                  //                   // This example shows a simple dialog
                  //                   showDialog(
                  //                     context: context,
                  //                     builder: (BuildContext context) {
                  //                       return AlertDialog(
                  //                         title: const Text('举报'),
                  //                         content: const Text('您确定要举报此内容吗？'),
                  //                         actions: [
                  //                           TextButton(
                  //                             onPressed: () {
                  //                               Navigator.pop(context);
                  //                               ScaffoldMessenger.of(context)
                  //                                   .showSnackBar(
                  //                                 SnackBar(
                  //                                   content: Text('内容已举报.'),
                  //                                 ),
                  //                               );
                  //                             },
                  //                             child: Text('取消'),
                  //                           ),
                  //                           TextButton(
                  //                             onPressed: () {
                  //                               // Add your actual reporting logic here
                  //                               Navigator.pop(context);
                  //                             },
                  //                             child: Text('确定'),
                  //                           ),
                  //                         ],
                  //                       );
                  //                     },
                  //                   );
                  //                 },
                  //               ),
                  //               ContextMenuButtonItem(
                  //                 label: '复制',
                  //                 onPressed: () {
                  //                   if (value.selection.baseOffset !=
                  //                       value.selection.extentOffset) {
                  //                     final selectedText =
                  //                         value.selection.baseOffset !=
                  //                                 value.selection.extentOffset
                  //                             ? value.text.substring(
                  //                                 value.selection.baseOffset,
                  //                                 value.selection.extentOffset)
                  //                             : '';
                  //                     final clipboard =
                  //                         ClipboardData(text: selectedText);
                  //                     Clipboard.setData(clipboard);
                  //                   }
                  //                   //   editableTextState.selectAll(SelectionChangedCause.forcePress);
                  //                   // // Access the selected text and copy it to clipboard
                  //                   // final clipboard = ClipboardData(text: value.text);
                  //                   // Clipboard.setData(clipboard);
                  //                 },
                  //               ),
                  //               ContextMenuButtonItem(
                  //                 label: '分享',
                  //                 onPressed: () {
                  //                   // Share the selected text (replace with your sharing logic)
                  //                   final textToShare = value.text;
                  //                   Share.share(textToShare);
                  //                 },
                  //               ),
                  //             ],
                  //           );
                  //           return AdaptiveTextSelectionToolbar.buttonItems(
                  //             anchors: editableTextState.contextMenuAnchors,
                  //             buttonItems: buttonItems,
                  //           );
                  //         },
                  //         style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  //               color: isMe ? AppColors.white : AppColors.black,
                  //             ),
                  //       )
                  : const SizedBox(),
            ],
          ),
        ),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              message.createdAt.timeAgo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
