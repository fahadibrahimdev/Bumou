import 'package:app/Constants/color.dart';
import 'package:app/Controller/app_controller.dart';
import 'package:app/Data/Local/hive_storage.dart';
import 'package:app/Utils/logging.dart';
import 'package:app/Utils/navigations.dart';
import 'package:app/View/Auth/pending_policy.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Common {
  static void showDioErrorDialog(BuildContext context,
      {required DioException e}) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text('Oops!'.tr),
        content: Text(getErrorMsgOfDio(e)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Got it!".tr),
          ),
        ],
      ),
    );
  }

  static void showErrorDialog(BuildContext context, {required String e}) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text('Oops!'.tr),
        content: Text(e),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Got it!".tr),
          ),
        ],
      ),
    );
  }

  static Future<void> showSuccessDialog(BuildContext context,
      {required String message}) async {
    await showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
              title: Text('Success!'.tr),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Got it!'.tr),
                ),
              ],
            ));
  }

  static String getErrorMsgOfDio(DioException e) {
    try {
      Logger.error(
          'Status Code: ${e.response?.statusCode}, Error: $e, Response: ${e.response?.data}');
      String errorMsg = 'Please, check your internet connection';
      if (e.response?.statusCode == 406) {
        errorMsg = '${e.response?.data}';
      } else if (e.response != null && e.response!.data != null) {
        if (e.response?.data.runtimeType == String) {
          errorMsg = e.response!.data.toString();
        } else if (e.response?.data['message'] != null) {
          errorMsg = e.response!.data['message'].toString();
        } else if (e.response?.data['error'] != null) {
          errorMsg = e.response!.data['error'].toString();
        } else {
          errorMsg = e.response!.data.toString();
        }
      } else if (e.message != null) {
        errorMsg = e.message!;
      }
      return errorMsg;
    } catch (e) {
      Logger.error('Errorexxx: $e');
      return 'Something went wrong';
    }
  }

  //bottom sheet for permission request with icon title and description and two buttons
  static Future<bool> showPermissionBottomSheet({
    required BuildContext context,
    Widget? icon,
    required String title,
    required String description,
    String? buttonText,
    // required Function onButtonPressed,
  }) async {
    bool isGranted = true;
    await showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) icon,
              if (icon != null) const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(
                height: 10,
                width: double.infinity,
              ),
              Text(
                description,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  isGranted = true;
                  Navigator.of(context).pop();
                },
                child: Text(
                  buttonText ?? 'Continue'.tr,
                ),
              ),
              const SizedBox(height: 10),
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     minimumSize: const Size(double.infinity, 50),
              //     textStyle: Theme.of(context)
              //         .textTheme
              //         .titleMedium
              //         ?.copyWith(fontWeight: FontWeight.bold),
              //   ),
              //   onPressed: () => Navigator.of(context).pop(),
              //   child: Text('Cancel'.tr),
              // ),
            ],
          ),
        ),
      ),
    );
    return isGranted;
  }

  static Future<bool> showPrivacyPolicyBottomSheet(BuildContext context) async {
    bool isAccepted = false;
    await showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (context) => SafeArea(
        child: GetBuilder<AppController>(
          builder: (cntrlr) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.policy_rounded,
                    size: 50,
                    color: Get.theme.primaryColor,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Privacy Policy Agreement'.tr,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10, width: double.infinity),
                  Text(
                    'Welcome to Bumou 咘呣'.tr,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10, width: double.infinity),
                  Text(
                    'Before you continue, please take a moment to read and understand our Privacy Policy. This will explain how we handle your personal information.'
                        .tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10, width: double.infinity),
                  Text(
                    'You can review the Privacy Policy at any time by visiting'
                        .tr,
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () => openPrivacyPolicy(),
                    child: Text(
                      'Privacy Policy & Terms of Services'.tr,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      isAccepted = true;
                      LocalStorage.setFirstOpen();
                      Get.back();
                    },
                    child: Text(
                      'Accept'.tr,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      isAccepted = false;
                      Get.offAll(() => const PendingPrivacyPolicy());
                    },
                    child: Text('Reject'.tr),
                  ),
                  SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        2,
                        (index) => TextButton(
                          onPressed: () async {
                            cntrlr.selectedLanguage = index;
                            cntrlr
                                .updateLanguage(cntrlr.locale[index]['locale']);
                          },
                          child: Text(
                            cntrlr.locale[index]['name'],
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Get.locale?.countryCode ==
                                          cntrlr.locale[index]['locale']
                                              .countryCode
                                      ? AppColors.primary
                                      : AppColors.black,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    return isAccepted;
  }
}
