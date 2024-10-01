import 'dart:typed_data';
import 'package:app/Constants/color.dart';
import 'package:app/View/Widget/k_net_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailWidget extends StatefulWidget {
  const VideoThumbnailWidget({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  Future<Uint8List?> getThumbnail() async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: widget.videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 100,
      quality: 50,
      timeMs: 1000,
    );
    return uint8list;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          color: AppColors.black10,
          child: FutureBuilder<Uint8List?>(
            future: getThumbnail(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              } else if (snapshot.hasError ||
                  (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data == null)) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.black,
                );
              } else {
                return const KShimmerWidget();
              }
            },
          ),
        ),
        SvgPicture.asset('assets/svgs/play.svg'),
      ],
    );
  }
}
