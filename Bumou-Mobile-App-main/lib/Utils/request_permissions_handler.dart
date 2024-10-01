// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:app/Utils/comon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestPermissionHandler {
  //galler permission
  static Future<bool> checkRequstGalleryPermission(BuildContext context) async {
    bool isGranted = false;

    final status = await Permission.photos.status;
    log("status: $status");
    if (status.isGranted) {
      return true;
    }
    bool isAllowedToRequest = await Common.showPermissionBottomSheet(
      context: context,
      title: "Gallery Permission".tr,
      description:
          'App needs gallery permission to select photo for profile, post or chat.'
              .tr,
      icon: Lottie.asset(
        'assets/Animation/gallery.json',
        width: MediaQuery.sizeOf(context).width / 2,
      ),
    );

    log("isAllowedToRequest: $isAllowedToRequest");

    if (!isAllowedToRequest) {
      return false;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      await openAppSettings();

      return false;
    }

    if (isAllowedToRequest) {
      log("request");
      final result = await Permission.photos.request();
      log("result: $result");
      if (result.isGranted || result.isLimited || result.isDenied) {
        isGranted = true;
      }
    }

    log("isGranted: $isGranted");
    return isGranted;
  }

  //camera permission
  static Future<bool> checkRequstCameraPermission(BuildContext context) async {
    bool isGranted = false;
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    }
    bool isAllowedToRequest = await Common.showPermissionBottomSheet(
      context: context,
      title: "Camera Permission".tr,
      description:
          'App needs camera permission to take photo for profile, post or chat.'
              .tr,
      icon: Lottie.asset(
        'assets/Animation/camera.json',
        width: MediaQuery.sizeOf(context).width / 2,
      ),
    );

    if (!isAllowedToRequest) {
      return false;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      await openAppSettings();
      return false;
    }

    if (isAllowedToRequest) {
      final result = await Permission.camera.request();
      if (result.isGranted || result.isLimited || result.isDenied) {
        isGranted = true;
      }
    }

    return isGranted;
  }

  //storage file permission
  static Future<bool> checkRequstStoragePermission(BuildContext context) async {
    bool isGranted = false;
    log("isGranted: $isGranted");
    final status = await Permission.storage.status;
    log("status: $status");
    if (status.isGranted) {
      return true;
    }
    bool isAllowedToRequest = await Common.showPermissionBottomSheet(
      context: Get.context!,
      title: "Storage Permission".tr,
      description:
          'App needs storage permission to select video for your post or chat.'
              .tr,
      icon: Lottie.asset(
        'assets/Animation/gallery.json',
        width: MediaQuery.sizeOf(Get.context!).width / 2,
      ),
    );
    log("isAllowedToRequest: $isAllowedToRequest");
    if (!isAllowedToRequest) {
      return false;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      log("openAppSettings");
      await openAppSettings();
      return false;
    }

    if (isAllowedToRequest) {
      log("request");
      final result = await Permission.storage.request();
      log("result: $result");
      if (result.isGranted || result.isLimited || result.isDenied) {
        isGranted = true;
      }
    }

    log("isGranted: $isGranted");

    return isGranted;
  }

  //location permission
  static Future<bool> checkRequstLocationPermission(
      BuildContext context) async {
    bool isGranted = false;
    final status = await Permission.location.status;
    if (status.isGranted) {
      return true;
    }
    bool isAllowedToRequest = await Common.showPermissionBottomSheet(
      context: Get.context!,
      title: "Location Permission".tr,
      description:
          'App needs location permission to get your current location for chat.'
              .tr,
      icon: Lottie.asset(
        'assets/Animation/location.json',
        width: MediaQuery.sizeOf(Get.context!).width / 2,
      ),
    );

    if (!isAllowedToRequest) {
      return false;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      await openAppSettings();
      return false;
    }

    if (isAllowedToRequest) {
      final result = await Permission.location.request();
      if (result.isGranted || result.isLimited || result.isDenied) {
        isGranted = true;
      }
    }

    return isGranted;
  }

  //microphone permission
  static Future<bool> checkRequstMicrophonePermission(
      BuildContext context) async {
    bool isGranted = false;
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      return true;
    }
    bool isAllowedToRequest = await Common.showPermissionBottomSheet(
      context: context,
      title: 'Microphone Permission'.tr,
      description:
          "App needs microphone permission to record audio for voice chat.".tr,
      icon: Lottie.asset(
        'assets/Animation/mic.json',
        width: MediaQuery.sizeOf(context).width / 2,
      ),
    );

    if (!isAllowedToRequest) {
      return false;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      await openAppSettings();
      return false;
    }

    if (isAllowedToRequest) {
      final result = await Permission.microphone.request();
      if (result.isGranted || result.isLimited || result.isDenied) {
        isGranted = true;
      }
    }

    return isGranted;
  }

  //notification permission
}
