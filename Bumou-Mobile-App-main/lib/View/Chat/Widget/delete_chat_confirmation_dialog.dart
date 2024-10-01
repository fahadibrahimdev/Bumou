import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Constants/color.dart';

class DeleteChatConfirmationDialog {
  static Future<bool> confirm(BuildContext context) async {
    bool isConfirmed = false;

    await Get.dialog(
      Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        elevation: 0.0,
        backgroundColor: AppColors.white,
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.delete,
                  size: 33,
                ),
                const SizedBox(height: 15),
                Text("Are you sure you want to delete this chat?".tr,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 15),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 60.0)),
                        onPressed: () => Get.back(),
                        child: Text('Cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 60.0),
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          isConfirmed = true;
                          Get.back();
                        },
                        child: Text('Continue'.tr),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );

    return isConfirmed;
  }
}
