import 'dart:developer';
import 'dart:io';
import 'package:app/Constants/color.dart';
import 'package:app/Controller/auth_controller.dart';
import 'package:app/Controller/momment_controller.dart';
import 'package:app/Model/moment.dart';
import 'package:app/Utils/image_picker.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/View/Widget/carousel.dart' as customCarousel;
import 'package:app/View/Widget/k_net_image.dart';
import 'package:app/View/Widget/video_thumbnail_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:unlock_detector/unlock_detector.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer' as developer;

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  String? selectedImg;
  File? video;
  List<MediaAttachments> mediaAttachments = [];
  List<MediaAttachments> updteMediaAttachments = [];
  VideoPlayerController? videoPlayerController;
  final TextEditingController textController = TextEditingController();
  bool isAnonymous = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Post'.tr),
          actions: [
            TextButton(
              onPressed: () async {
                if (textController.text.isEmpty && mediaAttachments.isEmpty) {
                  return;
                }
                updteMediaAttachments.clear();
                kOverlayWithAsync(asyncFunction: () async {
                  String? fileUrl;
                  if (mediaAttachments.isNotEmpty && context.mounted) {
                    for (var element in mediaAttachments) {
                      fileUrl = await AuthController.to.uploadFile(context,
                          file: element.url!, path: 'Moments');
                      updteMediaAttachments.add(MediaAttachments(
                        type: element.type,
                        url: fileUrl,
                      ));
                    }
                  }
                  log(
                    updteMediaAttachments
                        .map((e) => e.toJson())
                        .toList()
                        .toString(),
                  );
                  if (context.mounted) {
                    await MommentController.to.createPost(
                      context,
                      data: {
                        'text': textController.text.isNotEmpty
                            ? textController.text
                            : null,
                        'isAnonymous': isAnonymous,
                        'mediaAttachments': updteMediaAttachments
                            .map((e) => e.toJson())
                            .toList(),
                      },
                    );
                  }
                });
              },
              child: Text('Post'.tr),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ListTile(
              //   leading: KCircularCacheImg(
              //     imgPath: AuthController.to.user?.profilePicture,
              //     radius: 40,
              //   ),
              //   title: Text(
              //     '${AuthController.to.user?.firstName} ${AuthController.to.user?.lastName}',
              //     style: Theme.of(context).textTheme.bodyLarge,
              //   ),
              // ),
              CheckboxListTile(
                tileColor: Colors.white,
                value: isAnonymous,
                visualDensity: const VisualDensity(vertical: -4),
                title: Text('Is Anonymous'.tr),
                subtitle: Text('Your identity will be hidden'.tr),
                onChanged: (value) {
                  setState(() {
                    isAnonymous = value!;
                  });
                },
              ),
              TextFormField(
                controller: textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "What's on your mind?".tr,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
              mediaAttachments.isNotEmpty
                  ? GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: mediaAttachments.length,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final media = mediaAttachments[index];
                        return Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topRight,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => customCarousel.CarouselView(
                                    mediaList: mediaAttachments,
                                    index: index,
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                child: media.type == MediaType.image
                                    ? KCachedImage(imgPath: media.url)
                                    : VideoThumbnailWidget(
                                        videoUrl: media.url!),
                              ),
                            ),
                            Positioned(
                              top: -22,
                              right: -22,
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      mediaAttachments.remove(media);
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: AppColors.red,
                                    size: 20,
                                    weight: 30,
                                  )),
                            ),
                          ],
                        );
                      },
                    )
                  : const SizedBox()
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () async {
                  final img = await FilePickerUtils.multiImageFromGallery();
                  if (img != null) {
                    for (var element in img) {
                      if (mediaAttachments.length < 10) {
                        final mimeType = lookupMimeType(element.path);
                        final type = mimeType!.split('/')[0];
                        mediaAttachments.add(MediaAttachments(
                            type: type == 'video'
                                ? MediaType.video
                                : MediaType.image,
                            url: element.path));
                      } else {
                        Get.snackbar("Warning".tr,
                            "You can't upload more than 10 images".tr);
                        break;
                      }
                      setState(() {});
                    }
                  }
                },
                icon: const Icon(Icons.image_outlined),
              ),
              IconButton(
                onPressed: () async {
                  final img = await FilePickerUtils.imageSourcePicker(
                      context, ImageSource.camera);
                  if (img != null) {
                    if (mediaAttachments.length < 10) {
                      mediaAttachments.add(
                          MediaAttachments(type: MediaType.image, url: img));
                    } else {
                      Get.snackbar("Warning".tr,
                          "You can't upload more than 10 images".tr);
                    }
                    setState(() {});
                  }
                },
                icon: const Icon(Icons.camera_alt_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
