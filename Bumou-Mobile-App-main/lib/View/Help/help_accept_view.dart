// import 'package:app/Constants/color.dart';
// import 'package:app/Controller/help_controller.dart';
// import 'package:app/Utils/loading_overlays.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:ripple_wave/ripple_wave.dart';

// class HelpAcceptView extends StatefulWidget {
//   const HelpAcceptView({super.key, required this.helpId});
//   final String helpId;

//   @override
//   State<HelpAcceptView> createState() => _HelpAcceptViewState();
// }

// class _HelpAcceptViewState extends State<HelpAcceptView> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             onPressed: () {
//               showAdaptiveDialog(
//                 context: context,
//                 builder: (context) => AlertDialog.adaptive(
//                   title: Text('Cancel Help'.tr),
//                   content: Text(
//                       'Are you sure you want to cancel this help request?'.tr),
//                   actions: <Widget>[
//                     TextButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: Text('No'.tr),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Get.back();
//                         // kOverlayWithAsync(asyncFunction: () async {
//                         //   await Get.find<HelpController>().cancelHelp(widget.helpId);
//                         // });
//                       },
//                       child: Text('Yes'.tr),
//                     ),
//                   ],
//                 ),
//               );
//             },
//             icon: const Icon(Icons.cancel),
//           ),
//         ],
//       ),
//       body: Center(
//         child: RippleWave(
//           color: AppColors.primaryLight,
//           repeat: true,
//           child: SvgPicture.asset('assets/svgs/bell.svg'),
//         ),
//       ),
//       //                    Column(
//       //   children: [
//       //     Text('helpppp'),
//       //   ],
//       // ),
//     );
//   }
// }
