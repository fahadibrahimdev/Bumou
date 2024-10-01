import 'package:app/Controller/momment_controller.dart';
import 'package:app/Model/moment.dart';
import 'package:app/View/Widget/k_net_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KNumbOfLike extends StatefulWidget {
  const KNumbOfLike({super.key, required this.moment});
  final Moment moment;
  @override
  State<KNumbOfLike> createState() => _KNumbOfLikeState();
}

class _KNumbOfLikeState extends State<KNumbOfLike> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MommentController>(builder: (cntrlr) {
      return TextButton(
          style: TextButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.all(1),
            minimumSize: Size.zero,
          ),
          onPressed: () async {
            if (context.mounted) {
              await MommentController.to.getLikes(context, postId: widget.moment.id!);
            }
            Get.bottomSheet(
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                child: Column(children: [
                  Text('Likes'.tr, style: Theme.of(context).textTheme.titleMedium),
                  cntrlr.isLoadingLike
                      ? const Center(child: CircularProgressIndicator())
                      : cntrlr.errorMsgOfLike != null
                          ? Center(child: Text(cntrlr.errorMsgOfLike!))
                          : cntrlr.likes.isEmpty
                              ? Center(child: Text('No Likes yet'.tr))
                              : ListView.separated(
                                  itemCount: cntrlr.likes.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final like = cntrlr.likes[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      minVerticalPadding: 20,
                                      leading: KCircularCacheImg(imgPath: like['user']['profilePicture'], radius: 40),
                                      title: Text(like['user']['username'], style: Theme.of(context).textTheme.bodyLarge),
                                      subtitle: Text(like['user']['userType'], style: Theme.of(context).textTheme.bodySmall),
                                      trailing: Text(like['createdAt'], style: Theme.of(context).textTheme.bodyMedium),
                                    );
                                  },
                                ),
                ]),
              ),
              backgroundColor: Colors.white,
            );
          },
          child: Text('${widget.moment.numberOfLikes.toString()} ${'likes'.tr}', style: Theme.of(context).textTheme.bodyMedium));
    });
  }
}
