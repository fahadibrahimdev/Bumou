import 'package:app/Constants/color.dart';
import 'package:app/Controller/comments_controller.dart';
import 'package:app/Controller/momment_controller.dart';
import 'package:app/Model/moment.dart';
import 'package:app/Utils/datetime.dart';
import 'package:app/Utils/input_utils.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/View/Moment/Widget/like_button.dart';
import 'package:app/View/Widget/k_net_image.dart';
import 'package:app/View/Widget/overflow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class MomentDetail extends StatefulWidget {
  const MomentDetail(
      {super.key, required this.moment, this.isForComment = false});
  final Moment moment;
  final bool isForComment;

  @override
  State<MomentDetail> createState() => _MomentDetailState();
}

class _MomentDetailState extends State<MomentDetail> {
  bool? isLikedMe = false;
  @override
  void initState() {
    Get.put(CommentsController());
    isLikedMe = widget.moment.isLikeByMe;
    super.initState();
  }

  final TextEditingController commentCntrlr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unfocusKeyboard(context),
      child: Scaffold(
        appBar: AppBar(title: Text('Moment'.tr)),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: KCircularCacheImg(
                          imgPath: widget.moment.user?.profilePicture,
                          radius: 40),
                      title: Text(
                        '${widget.moment.user?.firstName} ${widget.moment.user?.lastName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        widget.moment.user?.userType?.tr ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: Text(widget.moment.createdAt.dateTimeString),
                    ),
                    if (widget.moment.text != null)
                      Text(
                        widget.moment.text!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    if (widget.moment.mediaAttachments != null &&
                        widget.moment.mediaAttachments!.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.moment.mediaAttachments?.length,
                        itemBuilder: (context, index) {
                          final media = widget.moment.mediaAttachments![index];
                          return Column(
                            children: [
                              if (media.type == MediaType.image)
                                KCachedImage(imgPath: media.url),
                              if (media.type == MediaType.video)
                                VideoPlayer(VideoPlayerController.networkUrl(
                                    Uri.parse(media.url!))),
                            ],
                          );
                        },
                      ),
                    // if (widget.moment.imageUrl != null) KCachedImage(imgPath: widget.moment.imageUrl),
                    // if (widget.moment.videoUrl != null)
                    //   VideoPlayer(
                    //     VideoPlayerController.networkUrl(Uri.parse(widget.moment.videoUrl!)),
                    //   ),
                    const SizedBox(height: 10),
                    // Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    //   // KCommentBox(moment: widget.moment),
                    // ]),
                    Row(
                      children: [
                        IconButton(
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.all(1),
                            minimumSize: Size.zero,
                          ),
                          onPressed: () async {
                            await MommentController.to
                                .likePost(context, postId: widget.moment.id!);
                            setState(() {
                              isLikedMe = !isLikedMe!;
                            });
                          },
                          icon: isLikedMe!
                              ? const Icon(Icons.favorite, color: AppColors.red)
                              : const Icon(Icons.favorite_border),
                        ),
                        if (widget.moment.numberOfLikes != 0)
                          KNumbOfLike(moment: widget.moment),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const KOverflowWidget(child: Divider()),
                    const SizedBox(height: 8),
                    // const SizedBox(height: 10),
                    GetBuilder<CommentsController>(builder: (contrlr) {
                      return ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: contrlr.comments.length,
                          itemBuilder: (context, index) {
                            final comment = contrlr.comments[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: KCircularCacheImg(
                                      imgPath: comment.user?.profilePicture,
                                      radius: 35),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${comment.user?.firstName} ${comment.user?.lastName}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(comment.createdAt.timeAgo,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                          ],
                                        ),
                                        Text(comment.text ?? ''),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          });
                    }),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 8),
                child: Row(children: [
                  Expanded(
                    child: TextFormField(
                      autofocus: widget.isForComment,
                      controller: commentCntrlr,
                      decoration: InputDecoration(
                        hintText: 'Add your comment'.tr,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (commentCntrlr.text.isNotEmpty) {
                        kOverlayWithAsync(asyncFunction: () async {
                          await CommentsController.to.addComment(context,
                              comment: commentCntrlr.text,
                              postId: widget.moment.id!);
                          await CommentsController.to
                              .onCommentRefresh(Get.arguments);
                          commentCntrlr.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.send),
                  ),
                ]),
              ),
            ),
          ],
        ),
        // bottomNavigationBar:
      ),
    );
  }
}
