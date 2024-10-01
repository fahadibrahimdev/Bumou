import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class KCommentButton extends StatelessWidget {
  const KCommentButton({super.key, required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.all(3),
        minimumSize: const Size(0, 20),
      ),
      onPressed: onPressed,
      icon: SvgPicture.asset('assets/svgs/comment.svg', height: 18),
      label: Text(
        'Comments'.tr,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

// class KCommentBox extends StatefulWidget {
//   const KCommentBox({super.key, required this.moment});
//   final Moment moment;

//   @override
//   State<KCommentBox> createState() => _KCommentBoxState();
// }

// class _KCommentBoxState extends State<KCommentBox> {
//   final TextEditingController comment = TextEditingController();
//   void onRefresh() async {
//     await MommentController.to.onCommentRefresh(widget.moment.id!);
//   }

//   void onLoading() async {
//     await MommentController.to.onCommentNextPage(widget.moment.id!);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size.width;
//     return GetBuilder<MommentController>(builder: (cntrlr) {
//       return IconButton(
//         style: IconButton.styleFrom(
//           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           padding: const EdgeInsets.all(3),
//           minimumSize: Size(widget.moment.comments!.isEmpty ? 0 : 0, 20),
//         ),
//         onPressed: () async {
//           await cntrlr.getComment(context, postId: widget.moment.id!);
//           Get.bottomSheet(
//             Scaffold(
//               appBar: AppBar(
//                 automaticallyImplyLeading: false,
//                 title: Column(
//                   children: [
//                     Divider(thickness: 3, color: AppColors.grey, indent: size * 0.4, endIndent: size * 0.4),
//                     Text('Comment'.tr, style: Theme.of(context).textTheme.titleMedium),
//                   ],
//                 ),
//               ),
//               body: cntrlr.isLoadingComment
//                   ? const Center(child: CircularProgressIndicator())
//                   : SmartRefresher(
//                       controller: cntrlr.commentRefreshController,
//                       enablePullDown: false,
//                       enablePullUp: true,
//                       onRefresh: onRefresh,
//                       onLoading: onLoading,
//                       child: cntrlr.errorMsgOfComment != null
//                           ? Center(child: Text(cntrlr.errorMsgOfComment!))
//                           : cntrlr.comments.isEmpty
//                               ? Center(child: TextButton(onPressed: () => onRefresh(), child: Text('No comments yet'.tr)))
//                               : ListView.separated(
//                                   shrinkWrap: true,
//                                   separatorBuilder: (context, index) => const SizedBox(height: 5),
//                                   itemCount: cntrlr.comments.length,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemBuilder: (context, index) {
//                                     final comment = cntrlr.comments[index];
//                                     return ListTile(
//                                       contentPadding: EdgeInsets.zero,
//                                       minVerticalPadding: 20,
//                                       leading: KCircularCacheImg(imgPath: comment.user!.profilePicture, radius: 40),
//                                       title: Text(comment.user!.username!, style: Theme.of(context).textTheme.titleMedium),
//                                       subtitle: Text(comment.text!, style: Theme.of(context).textTheme.bodyMedium),
//                                       trailing: Text(comment.createdAt.toString(), style: Theme.of(context).textTheme.bodySmall),
//                                     );
//                                   },
//                                 )),
//               bottomNavigationBar: SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: TextFormField(
//                     controller: comment,
//                     decoration: InputDecoration(
//                       hintText: 'Add a comment'.tr,
//                       suffixIcon: IconButton(
//                         onPressed: () {
//                           cntrlr.addComment(context, comment: comment.text, postId: widget.moment.id!).then((value) {
//                             comment.clear();
//                             Get.close(1);
//                           });
//                         },
//                         icon: const Icon(Icons.send),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             isScrollControlled: true,
//             ignoreSafeArea: false,
//             persistent: true,
//           );
//         },
//         icon: Row(
//           children: [SvgPicture.asset('assets/svgs/comment.svg', height: 18), const SizedBox(width: 6), Text('Comments'.tr)],
//         ),
//       );
//     });
//   }
// }
