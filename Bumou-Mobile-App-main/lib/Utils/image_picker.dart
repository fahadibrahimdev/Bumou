// ignore_for_file: use_build_context_synchronously

import 'package:app/Constants/color.dart';
import 'package:app/Utils/request_permissions_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'logging.dart';

class FilePickerUtils {
  static Future<String?> imagePicker(
    BuildContext context, {
    ImageSource? source,
    bool needCropping = false,
  }) async {
    source = await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppColors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.border,
                child: SvgPicture.asset('assets/svgs/camera-outlined.svg'),
              ),
              title: Text(
                'Take a photo'.tr,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.border,
                child: SvgPicture.asset('assets/svgs/gallery.svg'),
              ),
              title: Text(
                'Choose from gallery'.tr,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
                onPressed: () => Navigator.pop(context, null),
                child: Text(
                  'Cancel'.tr,
                  style: const TextStyle(color: AppColors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      elevation: 0,
    );
    if (source == null) {
      Logger.message('Source is null');
      return null;
    } else {
      final file = await _pickImage(context, source);
      if (needCropping && file != null) {
        final croppedFile = await _cropImage(file.path);
        if (croppedFile != null) {
          return croppedFile.path;
        }
      } else if (file != null) {
        return file.path;
      } else {
        return null;
      }
      return null;
    }
  }

  static Future<XFile?> _pickImage(
    BuildContext context,
    ImageSource source,
  ) async {
    final isAllowed = source == ImageSource.camera
        ? await RequestPermissionHandler.checkRequstCameraPermission(context)
        : await RequestPermissionHandler.checkRequstGalleryPermission(context);
    if (!isAllowed) return null;

    return await ImagePicker().pickImage(source: source);
  }

  static Future<CroppedFile?> _cropImage(String path) async {
    return await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: AppColors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );
  }

  static Future<String?> imageSourcePicker(
    BuildContext context,
    ImageSource source, {
    bool isVideo = false,
  }) async {
    if (source == ImageSource.gallery && isVideo == true) {
      bool isAllowed =
          await RequestPermissionHandler.checkRequstStoragePermission(
        context,
      );
      if (!isAllowed) return null;
      final videoFile =
          await ImagePicker().pickVideo(source: ImageSource.gallery);
      return videoFile?.path;
    } else {
      bool isAllowed =
          await RequestPermissionHandler.checkRequstCameraPermission(
        context,
      );
      if (!isAllowed) return null;
      final file = await _pickImage(context, source);
      if (file != null) {
        final croppedfile = await _cropImage(file.path);
        if (croppedfile != null) {
          return croppedfile.path;
        }
      }
    }
    return null;
  }

  static Future<List<XFile>?> multiImageFromGallery() async {
    bool isAllowed =
        await RequestPermissionHandler.checkRequstGalleryPermission(
      Get.context!,
    );
    if (!isAllowed) return null;
    return await ImagePicker().pickMultipleMedia(
      imageQuality: 50,
      maxWidth: 1920,
      maxHeight: 1080,
    );
  }

  static Future<String?> pickMedia(BuildContext context) async {
    bool isAllowed =
        await RequestPermissionHandler.checkRequstGalleryPermission(
      context,
    );
    if (!isAllowed) return null;

    XFile? file = await ImagePicker().pickMedia();
    if (file != null) {
      if (await file.length() > 30 * 1024 * 1024) {
        Get.snackbar('Warning'.tr, 'You can\'t upload more than 40MB'.tr);
        return null;
      }
    }
    return file?.path;
  }
}
