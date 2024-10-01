import 'package:app/Constants/color.dart';
import 'package:app/Controller/help_controller.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/View/Help/components/incoming_requests.dart';
import 'package:app/View/Help/components/ongoing_requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ripple_wave/ripple_wave.dart';

class HelpView extends StatefulWidget {
  const HelpView({super.key});

  @override
  State<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'.tr),
        centerTitle: false,
        actions: [
          GetBuilder<HelpController>(builder: (cntrlr) {
            if (cntrlr.isLoading) {
              return const Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (cntrlr.errorMessage != null) {
              return TextButton.icon(
                onPressed: () async {
                  await kOverlayWithAsync(asyncFunction: () async {
                    await Get.find<HelpController>().getMyCurrentHelp();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: Text('Retry'.tr),
              );
            }
            return TextButton.icon(
              onPressed: () async {
                if (cntrlr.currentHelp != null) {
                  await kOverlayWithAsync(asyncFunction: () async {
                    await Get.find<HelpController>()
                        .cancelHelp(cntrlr.currentHelp!.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Help request cancelled'.tr),
                        ),
                      );
                    }
                  });
                } else {
                  await kOverlayWithAsync(asyncFunction: () async {
                    await Get.find<HelpController>()
                        .askForHelp(context, message: "Need help here".tr);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Help request sent'.tr),
                        ),
                      );
                    }
                  });
                }
              },
              icon: Center(
                child: cntrlr.currentHelp != null
                    ? RippleWave(
                        color: AppColors.primaryLight,
                        repeat: true,
                        child: SvgPicture.asset('assets/svgs/bell.svg'),
                      )
                    : const Icon(
                        Icons.notification_important,
                      ),
              ),
              label: Text(
                cntrlr.currentHelp != null
                    ? "Cancel Request".tr
                    : "Request Help".tr,
              ),
            );
          }),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            GetBuilder<HelpController>(
              init: HelpController(),
              builder: (cntrlr) {
                return TabBar(
                  tabs: [
                    Tab(
                      icon: Badge(
                        offset: const Offset(15, -5),
                        isLabelVisible: cntrlr.ongoingHelps.isNotEmpty,
                        label: Text(
                          cntrlr.ongoingHelps.length.toString(),
                        ),
                        child: Text('Ongoing help'.tr),
                      ),
                    ),
                    Tab(
                      icon: Badge(
                        offset: const Offset(15, -5),
                        isLabelVisible: cntrlr.incomingHelps.isNotEmpty,
                        label: Text(
                          cntrlr.incomingHelps.length.toString(),
                        ),
                        child: Text('Incoming requests'.tr),
                      ),
                    ),
                  ],
                );
              },
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  OngoingRequestsView(),
                  IncomingRequestsView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    // GetBuilder<HelpController>(
    //   builder: (cntrlr) {
    //     if (cntrlr.isLoading) {
    //       return const Center(child: LoadingWidget(height: 100));
    //     } else if (cntrlr.currentHelp != null) {
    //       return OnGoingHelpWidget();
    //     } else {
    //       return const RequestHelpWidget();
    //     }
    //   },
    // );
  }
}

// class RequestHelpWidget extends StatefulWidget {
//   const RequestHelpWidget({super.key});

//   @override
//   State<RequestHelpWidget> createState() => _RequestHelpWidgetState();
// }

// class _RequestHelpWidgetState extends State<RequestHelpWidget> {
//   bool isRinging = false;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => unfocusKeyboard(context),
//       child: GetBuilder<HelpController>(builder: (cntrlr) {
//         return Scaffold(
//           appBar: AppBar(
//             automaticallyImplyLeading: false,
//             title:
//                 Text('Help'.tr, style: Theme.of(context).textTheme.titleMedium),
//             centerTitle: false,
//             actions: [
//               GetBuilder<AuthController>(builder: (authCntrlr) {
//                 return Switch(
//                   value: authCntrlr.user?.isHelping ?? false,
//                   onChanged: (value) async {
//                     bool result = true;
//                     if (!value) {
//                       result = await showAdaptiveDialog(
//                         context: context,
//                         builder: (context) => AlertDialog.adaptive(
//                           title: Text('Are you sure?'.tr),
//                           content: Text(
//                               "You are about to turn off the emergency help feature? You will no longer be able to get or send help requests"
//                                   .tr),
//                           actions: <Widget>[
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(false),
//                               child: Text("Cancel".tr),
//                             ),
//                             TextButton(
//                               onPressed: () async {
//                                 Navigator.of(context).pop(true);
//                               },
//                               child: Text("Turn off".tr),
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//                     if (result == true) {
//                       await kOverlayWithAsync(asyncFunction: () async {
//                         await authCntrlr.updateHelpStatus(context,
//                             isHelping: value);
//                       });
//                     }
//                   },
//                 );
//               }),
//               const SizedBox(width: 10),
//             ],
//           ),
//           body: SmartRefresher(
//             controller: cntrlr.refreshController,
//             enablePullDown: true,
//             enablePullUp: false,
//             onRefresh: cntrlr.onRefresh,
//             // onLoading: onLoading,
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20.0),
//               child: GetBuilder<AuthController>(builder: (authCntrlr) {
//                 if (authCntrlr.user?.isHelping ?? false) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Are you in Emergency?'.tr,
//                         style: Theme.of(context).textTheme.headlineSmall,
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         'Press the button below to trigger an alarm that will help people know that you are in trouble.'
//                             .tr,
//                         style: Theme.of(context).textTheme.bodyMedium,
//                       ),
//                       SizedBox(
//                           height: MediaQuery.of(context).size.height * 0.1),
//                       Center(
//                         child: isRinging
//                             ? RippleWave(
//                                 color: AppColors.primaryLight,
//                                 repeat: true,
//                                 child: SvgPicture.asset('assets/svgs/bell.svg'),
//                               )
//                             : SvgPicture.asset('assets/svgs/bell.svg'),
//                       ),
//                       // Center(child: SvgPicture.asset('assets/svgs/bell.svg')),
//                       SizedBox(
//                           height: MediaQuery.of(context).size.height * 0.1),
//                       FilledButton(
//                         style: FilledButton.styleFrom(
//                           minimumSize: const Size(double.infinity, 50.0),
//                           // backgroundColor: state.playing ? AppColors.error : AppColors.primary,
//                         ),
//                         onPressed: () async {
//                           TextEditingController messageController =
//                               TextEditingController();
//                           showAdaptiveDialog(
//                             context: context,
//                             builder: (context) => AlertDialog.adaptive(
//                               title: Text('Send a message'.tr),
//                               content: Material(
//                                 type: MaterialType.transparency,
//                                 child: TextFormField(
//                                   controller: messageController,
//                                   decoration: InputDecoration(
//                                     hintText: 'Type your message here'.tr,
//                                   ),
//                                 ),
//                               ),
//                               actions: <Widget>[
//                                 TextButton(
//                                   onPressed: () => Navigator.of(context).pop(),
//                                   child: Text('Cancel'.tr),
//                                 ),
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                     kOverlayWithAsync(asyncFunction: () async {
//                                       await cntrlr.askForHelp(context,
//                                           message: messageController.text);
//                                       await cntrlr.getOngoingHelp();
//                                     });
//                                   },
//                                   child: Text('Send'.tr),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                         child: Text(isRinging ? "Stop Ringing".tr : "Ring".tr),
//                       ),
//                     ],
//                   );
//                 } else {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SvgPicture.asset('assets/svgs/bell.svg'),
//                         const SizedBox(height: 20),
//                         Text(
//                           'You have turned off the emergency feature'.tr,
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           'Please turn on the emergency feature to send and receive the requests'
//                               .tr,
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//               }),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }

// class OnGoingHelpWidget extends StatelessWidget {
//   OnGoingHelpWidget({super.key});

//   final TextEditingController messageController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<HelpController>(
//       builder: (cntrlr) {
//         final HelpModel help = cntrlr.currentHelp!;
//         bool isMyRequest =
//             help.requestedById == Get.find<AuthController>().user?.id;
//         log("OnGoingHelpWidget");
//         return Scaffold(
//           appBar: AppBar(
//             title: Text("Ongoing help".tr),
//             centerTitle: false,
//             actions: [
//               TextButton.icon(
//                 onPressed: () {
//                   showAdaptiveDialog(
//                     context: context,
//                     builder: (context) => AlertDialog.adaptive(
//                       title: Text('Cancel Help'.tr),
//                       content: Text(
//                           'Are you sure you want to cancel this help request?'
//                               .tr),
//                       actions: <Widget>[
//                         TextButton(
//                           onPressed: () => Navigator.of(context).pop(),
//                           child: Text('No'.tr),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             Get.back();
//                             kOverlayWithAsync(asyncFunction: () async {
//                               await Get.find<HelpController>()
//                                   .cancelHelp(help.id);
//                             });
//                           },
//                           child: Text('Yes'.tr),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//                 icon: const Icon(Icons.close),
//                 label: Text('End Help Request'.tr),
//               ),
//             ],
//           ),
//           body: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12.0),
//             child: SmartRefresher(
//               controller: cntrlr.refreshController,
//               enablePullDown: true,
//               enablePullUp: false,
//               onRefresh: cntrlr.onRefresh,
//               child: help.status == "PENDING"
//                   ? SizedBox(
//                       height: MediaQuery.sizeOf(context).width / 1.2,
//                       width: MediaQuery.sizeOf(context).width / 1.2,
//                       child: RippleWave(
//                         color: AppColors.primaryLight,
//                         repeat: true,
//                         child: SvgPicture.asset(
//                           'assets/svgs/bell.svg',
//                           width: MediaQuery.sizeOf(context).width / 5,
//                         ),
//                       ),
//                     )
//                   : Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           isMyRequest && help.helper != null
//                               ? 'Help asked by:'.tr
//                               : 'Help requested by:'.tr,
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         !isMyRequest
//                             ? help.status == "ACCEPTED" && help.helper != null
//                                 ? ListTile(
//                                     visualDensity:
//                                         const VisualDensity(vertical: -4),
//                                     contentPadding: EdgeInsets.zero,
//                                     leading: KCircularCacheImg(
//                                         imgPath: help.helper!.profilePicture,
//                                         radius: 30),
//                                     title: Text(
//                                         "${help.helper!.firstName} ${help.helper!.lastName}"),
//                                   )
//                                 : Text("Help is on going".tr)
//                             : ListTile(
//                                 visualDensity:
//                                     const VisualDensity(vertical: -4),
//                                 contentPadding: EdgeInsets.zero,
//                                 leading: KCircularCacheImg(
//                                     imgPath: help.requestedBy.profilePicture,
//                                     radius: 30),
//                                 title: Text(
//                                     "${help.requestedBy.firstName} ${help.requestedBy.lastName}"),
//                               ),
//                         const Divider(),
//                         Expanded(
//                           child: ListView.builder(
//                             reverse: true,
//                             itemCount: help.messages.length,
//                             itemBuilder: (BuildContext context, int index) {
//                               final message = help.messages[index];
//                               return buildMessageWidget(message);
//                             },
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: TextFormField(
//                             controller: messageController,
//                             decoration: InputDecoration(
//                               suffixIcon: IconButton(
//                                 onPressed: () async {
//                                   await kOverlayWithAsync(
//                                       asyncFunction: () async {
//                                     Get.find<ChatController>().sendHelpMessage(
//                                         context,
//                                         helpId: help.id,
//                                         message: messageController.text);
//                                     await Future.delayed(
//                                         const Duration(seconds: 1));
//                                   });
//                                   messageController.clear();
//                                 },
//                                 icon: const Icon(Icons.send),
//                               ),
//                               hintText: 'Type your message here'.tr,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 16),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget buildMessageWidget(HelpMessage message) {
//     bool isMyMessage = message.senderId == Get.find<AuthController>().user?.id;
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       margin: EdgeInsets.only(
//           bottom: 8, left: isMyMessage ? 50 : 0, right: isMyMessage ? 0 : 50),
//       decoration: BoxDecoration(
//         color: isMyMessage ? AppColors.white : AppColors.primaryLight,
//         borderRadius: BorderRadius.only(
//           topLeft: const Radius.circular(15),
//           topRight: const Radius.circular(15),
//           bottomLeft: isMyMessage ? const Radius.circular(15) : Radius.zero,
//           bottomRight: isMyMessage ? Radius.zero : const Radius.circular(15),
//         ),
//         boxShadow: const [
//           BoxShadow(
//             color: AppColors.black10,
//             blurRadius: 6,
//             spreadRadius: -1,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment:
//             isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           Text(
//             message.message ?? 'Help request'.tr,
//             style: message.message != null
//                 ? const TextStyle(
//                     color: AppColors.black,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600)
//                 : const TextStyle(
//                     color: AppColors.grey40,
//                     fontSize: 15,
//                     fontStyle: FontStyle.italic),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             message.createdAt.timeAgo,
//             style: const TextStyle(fontSize: 10),
//           ),
//         ],
//       ),
//     );
//   }
// }
