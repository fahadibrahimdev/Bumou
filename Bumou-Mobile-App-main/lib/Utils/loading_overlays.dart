import 'package:app/Constants/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

Future<void> kOverlayWithAsync({required Function asyncFunction}) async {
  await Get.showOverlay(
    opacity: 0.8,
    opacityColor: AppColors.white,
    loadingWidget: const LoadingWidget(),
    asyncFunction: () async => await asyncFunction(),
  );
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.height = 350});
  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white.withOpacity(0.7),
      child: Center(
        child: Lottie.asset('assets/Animation/loading.json', frameRate: FrameRate(100), height: height),
      ),
    );
  }
}
