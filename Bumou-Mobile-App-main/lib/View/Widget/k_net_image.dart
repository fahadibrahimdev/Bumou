import 'dart:io';
import 'package:app/Constants/color.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class KCircularCacheImg extends StatelessWidget {
  const KCircularCacheImg({
    Key? key,
    required this.imgPath,
    this.radius = 100,
    this.isBorder = false,
    this.paddingDefault = 0,
  }) : super(key: key);
  final double radius;
  final String? imgPath;
  final bool isBorder;
  final double paddingDefault;
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: radius,
          height: radius,
          decoration: BoxDecoration(
            color: AppColors.border,
            shape: BoxShape.circle,
            border: isBorder ? Border.all(color: AppColors.primary, width: 2.0) : null,
          ),
          child: ClipOval(
            child: imgPath != null && !imgPath!.startsWith('null') && imgPath!.isNotEmpty
                ? imgPath!.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: imgPath!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Image.asset('assets/images/dummy.png', fit: BoxFit.cover),
                        placeholder: (context, url) => const KShimmerWidget(),
                      )
                    : imgPath!.startsWith('assets')
                        ? Image.asset(imgPath!, fit: BoxFit.cover)
                        : Image.file(File(imgPath!), fit: BoxFit.cover)
                : Padding(
                    padding: EdgeInsets.all(paddingDefault),
                    child: Image.asset(
                      'assets/images/dummy.png',
                      fit: BoxFit.cover,
                      height: 300,
                      width: 300,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class KCachedImage extends StatelessWidget {
  const KCachedImage({
    super.key,
    required this.imgPath,
    // this.radius = 300,
    this.isBorder = false,
    this.paddingDefault = 10,
  });
  // final double radius;
  final String? imgPath;
  final bool isBorder;
  final double paddingDefault;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 49, 49, 50),
          shape: BoxShape.rectangle,
          border: isBorder ? Border.all(color: AppColors.primary, width: 2.0) : null,
        ),
        child: imgPath != null && !imgPath!.startsWith('null') && imgPath!.isNotEmpty
            ? imgPath!.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: imgPath!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Image.asset('assets/images/dummy.png'),
                    placeholder: (context, url) => const KShimmerWidget(),
                  )
                : imgPath!.startsWith('assets')
                    ? Image.asset(imgPath!, fit: BoxFit.cover)
                    : Image.file(File(imgPath!), fit: BoxFit.cover)
            : Padding(
                padding: EdgeInsets.all(paddingDefault),
                child: Image.asset('assets/images/dummy.png', fit: BoxFit.cover),
              ));
  }
}

class KShimmerWidget extends StatelessWidget {
  const KShimmerWidget({super.key, this.radius, this.height, this.width, this.padding});
  final double? radius, height, width;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? 10),
        child: SizedBox(
          height: height ?? 100,
          width: width ?? double.infinity,
          child: Shimmer.fromColors(
            baseColor: AppColors.white20,
            highlightColor: AppColors.background,
            child: Container(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class FullImageView extends StatelessWidget {
  const FullImageView({super.key, required this.imgPath, this.isMessage});
  final String imgPath;
  final bool? isMessage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          isMessage != null
              ? IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                )
              : const SizedBox(),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Hero(
                tag: imgPath,
                child: imgPath.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: imgPath,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        placeholder: (context, url) => const KShimmerWidget(),
                      )
                    : imgPath.startsWith('assets')
                        ? Image.asset(imgPath, fit: BoxFit.cover)
                        : Image.file(File(imgPath), fit: BoxFit.cover)),
          ),
          // Positioned(
          //   // top: 40,
          //   right: 10,
          //   child: SafeArea(
          //     child: IconButton.filled(
          //       style: IconButton.styleFrom(
          //         backgroundColor: AppColors.white20,
          //       ),
          //       onPressed: () => Navigator.pop(context),
          //       icon: const Icon(Icons.close, color: AppColors.white),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
