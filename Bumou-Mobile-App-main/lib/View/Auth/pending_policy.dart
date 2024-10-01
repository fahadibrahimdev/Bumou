import 'package:app/Constants/color.dart';
// import 'package:app/Controller/auth_controller.dart';
import 'package:app/Utils/comon.dart';
import 'package:app/View/Splash/splash.dart';
import 'package:app/View/Widget/language_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class PendingPrivacyPolicy extends StatelessWidget {
  const PendingPrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Center(
          child: Column(
            children: [
              Lottie.asset(
                'assets/Animation/failed.json',
                repeat: false,
              ),
              Text(
                'Privacy Policy Pending'.tr,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                'Please accept the privacy policy to continue'.tr,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  bool isAccepted =
                      await Common.showPrivacyPolicyBottomSheet(context);
                  if (isAccepted) {
                    Get.offAll(() => const SplashView());
                  }
                },
                child: Text(
                  'Open Privacy Policy'.tr,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(
        child: LanguageChangeBar(),
      ),
    );
  }
}
