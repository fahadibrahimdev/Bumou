import 'dart:convert';
import 'dart:developer';

import 'package:app/Data/Network/request_client.dart';
import 'package:app/Model/mood.dart';
import 'package:app/Utils/comon.dart';
import 'package:app/Utils/logging.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Constants/api.dart';

class MoodController extends GetxController {
  static MoodController get to => Get.find();

  List<Mood> mood = [];
  String? moodErrorMsg;
  bool isLoadingMood = false;

  List<String> heading = ['Weekly', 'Monthly', 'Yearly'];
  int selectedIndex = 0;

  void onTap(int index) {
    switch (index) {
      case 0:
        getMoodPercentage(Get.context!, pastdays: 7);
        break;
      case 1:
        getMoodPercentage(Get.context!, pastdays: 30);
        break;
      case 2:
        getMoodPercentage(Get.context!, pastdays: 365);
        break;
    }
  }

  @override
  void onInit() {
    getMoodPercentage(Get.context!, pastdays: 7);
    super.onInit();
  }

  Future<bool> addMood(BuildContext context, {required String mood, required String? note}) async {
    try {
      log("Adding mood: $mood, $note");
      var response = await NetworkClient.post(Apis.addMood, data: {'mood': mood, 'note': note});
      Logger.message('Add Mood Response: ${response.statusCode}, ${jsonEncode(response.data)}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (context.mounted) getMoodPercentage(context, pastdays: 7);
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      log(Common.getErrorMsgOfDio(e));
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
      return false;
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
      return false;
    }
  }

  Future<void> getMoodPercentage(BuildContext context, {required int pastdays}) async {
    try {
      moodErrorMsg = null;
      isLoadingMood = true;
      update();
      var response = await NetworkClient.get('${Apis.moodPercentage}?previousDaysOf=$pastdays');
      Logger.message('Mood Percentage Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        mood = [];
        final jsonData = response.data;
        for (var item in jsonData) {
          mood.add(Mood.fromJson(item));
        }
      } else {
        moodErrorMsg = response.data['message'];
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
      moodErrorMsg = e.message;
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
      moodErrorMsg = error.toString();
    } finally {
      isLoadingMood = false;
      update();
    }
  }
}
