import 'package:app/Constants/color.dart';
import 'package:app/Model/moment.dart';
import 'package:app/View/Widget/k_net_image.dart';
import 'package:app/View/Widget/video_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselView extends StatefulWidget {
  const CarouselView({super.key, required this.mediaList, required this.index});
  final List<MediaAttachments> mediaList;
  final int index;

  @override
  State<CarouselView> createState() => _CarouselViewState();
}

class _CarouselViewState extends State<CarouselView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.white),
          ),
        ],
      ),
      body: CarouselSlider.builder(
        itemCount: widget.mediaList.length,
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height,
          viewportFraction: 1,
          enableInfiniteScroll: false,
          initialPage: widget.index,
          scrollDirection: Axis.horizontal,
        ),
        itemBuilder: (context, index, realIndex) {
          final media = widget.mediaList[index];
          return media.type == MediaType.image
              ? FullImageView(imgPath: media.url!)
              : VideoPlayerScreen(videoUrl: media.url!);
        },
      ),
    );
  }
}
