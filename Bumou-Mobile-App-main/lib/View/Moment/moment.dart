import 'package:app/Constants/color.dart';
import 'package:app/Controller/auth_controller.dart';
import 'package:app/Controller/momment_controller.dart';
import 'package:app/Data/Local/hive_storage.dart';
import 'package:app/Model/moment.dart';
import 'package:app/Utils/datetime.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/View/Moment/Widget/commet_button.dart';
import 'package:app/View/Moment/Widget/like_button.dart';
import 'package:app/View/Moment/create_moment.dart';
import 'package:app/View/Moment/moment_detail.dart';
import 'package:app/View/Widget/carousel.dart'as customCarousel;
import 'package:app/View/Widget/k_net_image.dart';
import 'package:app/View/Widget/video_thumbnail_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../Controller/Bindings/bindings.dart';
import '../Profile/user_profile_details.dart';

class MomentView extends StatefulWidget {
  const MomentView({super.key});

  @override
  State<MomentView> createState() => _MomentViewState();
}

class _MomentViewState extends State<MomentView> {
  final TextEditingController comment = TextEditingController();
  @override
  void initState() {
    MommentController.to.getAllPost(context);
    super.initState();
  }

  void onRefresh() async {
    await MommentController.to.onRefresh();
  }

  void onLoading() async {
    await MommentController.to.onNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 100),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              KCircularCacheImg(
                  imgPath: AuthController.to.user?.profilePicture, radius: 40),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  onTap: () => Get.to(() => const CreatePost()),
                  decoration:
                      InputDecoration(hintText: 'What\'s on your mind?'.tr),
                ),
              ),
            ]),
          ),
        ),
      ),
      body: GetBuilder<MommentController>(
        builder: (cntrlr) {
          if (cntrlr.isLoadingMoment) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return SmartRefresher(
              controller: cntrlr.refreshController,
              enablePullDown: true,
              enablePullUp: true,
              onRefresh: onRefresh,
              onLoading: onLoading,
              child: cntrlr.errorMsgOfMoment != null
                  ? Text(cntrlr.errorMsgOfMoment!)
                  : cntrlr.moment.isEmpty
                      ? Center(
                          child: TextButton(
                            onPressed: () => cntrlr.onRefresh(),
                            child: Text('No Posts yet. Pull to refresh'.tr),
                          ),
                        )
                      : ListView.builder(
                          itemCount: cntrlr.moment.length,
                          shrinkWrap: true,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemBuilder: (context, index) {
                            final moment = cntrlr.moment[index];
                            bool isMine =
                                moment.user?.id == LocalStorage.getUserId;
                            String imgTag =
                                'user_profile_picture_${moment.user?.id}$index';
                            return MomentWidget(
                              moment: moment,
                              imgTag: imgTag,
                              isMine: isMine,
                            );
                          },
                        ),
            );
          }
        },
      ),
    );
  }
}

class MomentWidget extends StatelessWidget {
  const MomentWidget({
    super.key,
    required this.moment,
    required this.imgTag,
    required this.isMine,
  });

  final Moment moment;
  final String imgTag;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: AppColors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
        decoration: BoxDecoration(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            Get.to(
              () => MomentDetail(moment: moment),
              arguments: moment.id,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (moment.user != null)
                ListTile(
                  onTap: () {
                    Get.to(
                      () => UserProfileDetails(
                        imgTag: imgTag,
                      ),
                      binding: UserDetailsBinding(),
                      arguments: moment.user!.id,
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(
                    vertical: -4,
                    horizontal: 4,
                  ),
                  horizontalTitleGap: 4,
                  minVerticalPadding: 0,
                  leading: Hero(
                    tag: imgTag,
                    child: KCircularCacheImg(
                      imgPath: moment.user!.profilePicture,
                      radius: 40,
                    ),
                  ),
                  title: Text(
                    "${moment.user!.firstName} ${moment.user!.lastName}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    moment.user?.userType?.tr ?? "",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: PopupMenuButton<int>(
                    onSelected: (value) {
                      if (value == 1) {
                        kOverlayWithAsync(asyncFunction: () async {
                          await Get.find<MommentController>()
                              .deleteMomentPost(context, moment.id!);
                        });
                      }
                      if (value == 2) {
                        kOverlayWithAsync(asyncFunction: () async {
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                          Get.snackbar(
                            "Success".tr,
                            "User blocked successfully".tr,
                          );
                        });
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        if (isMine)
                          PopupMenuItem<int>(
                            value: 1,
                            child: Text(
                              'Delete'.tr,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        PopupMenuItem<int>(
                          value: 1,
                          child: Text('Report'.tr),
                        ),
                        PopupMenuItem<int>(
                          value: 2,
                          child: Text('Block user'.tr),
                        ),
                      ];
                    },
                  ),
                ),
              if (moment.text != null)
                Text(moment.text!,
                    style: Theme.of(context).textTheme.bodyLarge),
              if (moment.mediaAttachments != null &&
                  moment.mediaAttachments!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: moment.mediaAttachments!.length == 1
                      ? KMediaWidget(
                          moment: moment,
                          media: moment.mediaAttachments![0],
                          index: 0,
                        )
                      : SizedBox(
                          height: 180,
                          child: ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 5),
                            itemCount: moment.mediaAttachments!.length < 5
                                ? moment.mediaAttachments!.length
                                : 5,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final media = moment.mediaAttachments![index];
                              return SizedBox(
                                width: MediaQuery.sizeOf(context).width /
                                    (moment.mediaAttachments!.length < 5
                                        ? moment.mediaAttachments!.length
                                        : 5),
                                child: KMediaWidget(
                                  moment: moment,
                                  media: media,
                                  index: index,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.all(1),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () async {
                      MommentController.to.likePost(
                        context,
                        postId: moment.id!,
                      );
                    },
                    icon: moment.isLikeByMe!
                        ? const Icon(Icons.favorite, color: AppColors.red)
                        : const Icon(Icons.favorite_border),
                  ),
                  const SizedBox(width: 8),
                  KCommentButton(
                    onPressed: () => Get.to(
                        () => MomentDetail(moment: moment, isForComment: true),
                        arguments: moment.id),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(moment.createdAt.dateTimeString,
                            style: Theme.of(context).textTheme.bodySmall)),
                  ),
                ],
              ),
              if (moment.numberOfLikes != 0) KNumbOfLike(moment: moment),
              if (moment.comments!.isNotEmpty)
                ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      moment.comments!.length > 3 ? 3 : moment.comments!.length,
                  itemBuilder: (context, indexx) {
                    final comment = moment.comments![indexx];
                    final user = comment.user;
                    return Card(
                      margin: EdgeInsets.zero,
                      color: AppColors.white,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${user?.username} ',
                                style: Theme.of(context).textTheme.bodyMedium),
                            Expanded(
                              child: Text(
                                ' ${comment.text}',
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class KMediaWidget extends StatelessWidget {
  const KMediaWidget({
    super.key,
    required this.moment,
    required this.media,
    required this.index,
  });

  final Moment moment;
  final MediaAttachments media;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() =>
         customCarousel.CarouselView(mediaList: moment.mediaAttachments!, index: index)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: media.type == MediaType.image
            ? KCachedImage(imgPath: media.url!)
            : media.type == MediaType.video
                ? SizedBox(
                    child: VideoThumbnailWidget(videoUrl: media.url!),
                  )
                : Text('Unknown media type'.tr),
      ),
    );
  }
}
