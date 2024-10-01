import 'dart:developer';

import 'package:app/Constants/api.dart';
import 'package:app/Data/Network/request_client.dart';
import 'package:app/Model/Help/help_model.dart';
import 'package:app/Utils/comon.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpController extends GetxController {
  HelpModel? currentHelp;
  bool isLoading = false;
  String? errorMessage;

  bool isLoadingIncoming = false;
  String? errorMessageIncoming;
  List<HelpModel> incomingHelps = [];

  bool isLoadingOngoing = false;
  String? errorMessageOngoing;
  List<HelpModel> ongoingHelps = [];

  // final RefreshController refreshController =
  //     RefreshController(initialRefresh: false);

  // void onRefresh() async {
  //   // await getOngoingHelp();
  //   refreshController.refreshCompleted();
  // }

  @override
  onInit() {
    getOngoingHelp();
    getMyCurrentHelp();
    getIncomingHelps();
    super.onInit();
  }

  void refreshs() {
    update();
  }

  Future<void> getIncomingHelps() async {
    try {
      errorMessageIncoming = null;
      isLoadingIncoming = true;
      update();
      final resp = await NetworkClient.get(Apis.incomingHelps);
      log("getIncomingHelps: ${resp.statusCode}");

      if (resp.statusCode == 200) {
        if (resp.data != null && resp.data.isNotEmpty) {
          incomingHelps = List<HelpModel>.from(
            resp.data.map((x) => HelpModel.fromJson(x)).toList(),
          );
        } else {
          incomingHelps = [];
        }
      } else {
        errorMessage = resp.data['message'];
      }
    } on DioException catch (e) {
      incomingHelps = [];
      debugPrint("getIncomingHelps: ${Common.getErrorMsgOfDio(e)}");
      errorMessageIncoming = Common.getErrorMsgOfDio(e);
    } catch (e) {
      incomingHelps = [];
      debugPrint("getIncomingHelps: $e");
      errorMessageIncoming = e.toString();
    } finally {
      isLoadingIncoming = false;
      update();
    }
  }

  Future<void> getMyCurrentHelp() async {
    try {
      isLoading = true;
      errorMessage = null;
      update();
      final resp = await NetworkClient.get(Apis.myPendingHelp);
      log("getMyCurrentHelp: ${resp.statusCode}");
      if (resp.statusCode == 200) {
        if (resp.data != null && resp.data.isNotEmpty) {
          currentHelp = HelpModel.fromJson(resp.data);
        } else {
          currentHelp = null;
        }
      } else {
        errorMessage = resp.data['message'];
      }
    } on DioException catch (e) {
      currentHelp = null;
      debugPrint("getMyCurrentHelp: ${Common.getErrorMsgOfDio(e)}");
    } catch (e) {
      currentHelp = null;
      debugPrint("getMyCurrentHelp: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getOngoingHelp() async {
    try {
      errorMessageOngoing = null;
      isLoadingOngoing = true;
      update();
      final resp = await NetworkClient.get(Apis.getOngoingHelp);
      log("getOngoingHelp ++++: ${resp.statusCode}");
      log("data ++++: ${resp.data.last}");

      if (resp.statusCode == 200) {
        if (resp.data != null && resp.data.isNotEmpty) {
          resp.data.map((x) => print(x));
          ongoingHelps = List<HelpModel>.from(
            resp.data.map((x) => HelpModel.fromJson(x)).toList(),
          );
        } else {
          ongoingHelps = [];
        }
      } else {
        errorMessageOngoing = resp.data['message'];
      }
    } on DioException catch (e) {
      ongoingHelps = [];
      debugPrint("getOngoingHelp: ${Common.getErrorMsgOfDio(e)}");
      errorMessageOngoing = Common.getErrorMsgOfDio(e);
    } catch (e) {
      ongoingHelps = [];
      debugPrint("getOngoingHelp: $e");
      errorMessageOngoing = e.toString();
    } finally {
      isLoadingOngoing = false;
      update();
    }
  }

  Future<void> askForHelp(BuildContext context, {String? message}) async {
    try {
      final resp = await NetworkClient.post(
        Apis.askHelp,
        data: {'message': message},
      );
      log("askForHelp: ${resp.statusCode}");

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        currentHelp = HelpModel.fromJson(resp.data);
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
    } catch (e) {
      if (context.mounted) Common.showErrorDialog(context, e: e.toString());
    } finally {
      update();
    }
  }

  deleteHelp(HelpModel help) async {
    try {
      isLoadingOngoing = true;
      errorMessage = null;
      update();
      final resp = await NetworkClient.delete("${Apis.deleteHelp}/${help.id}");

      if (resp.statusCode == 200) {
        await getOngoingHelp();
        Get.snackbar("帮助 删除成功".tr, "");
      } else {
        errorMessage = resp.data['message'];
      }
    } on DioException catch (e) {
      currentHelp = null;
      debugPrint("deleteHelp: ${Common.getErrorMsgOfDio(e)}");
    } catch (e) {
      currentHelp = null;
      debugPrint("deleteHelp: $e");
    } finally {
      isLoadingOngoing = false;
      update();
    }
  }

  Future<void> cancelHelp(String id) async {
    try {
      final resp = await NetworkClient.put("${Apis.cancelHelp}/$id");
      log("cancelHelp: ${resp.statusCode}");
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        currentHelp = null;
      }
    } on DioException catch (e) {
      Common.showDioErrorDialog(Get.context!, e: e);
    } catch (e) {
      Common.showErrorDialog(Get.context!, e: e.toString());
    } finally {
      getMyCurrentHelp();
      // update();
    }
  }

  removeHelpLocal(String helpId) {
    incomingHelps.removeWhere((element) => element.id == helpId);
    update();
  }

  Future<void> acceptHelp(BuildContext context,
      {required String helpId}) async {
    try {
      final resp = await NetworkClient.put(
        "${Apis.acceptHelp}/$helpId",
      );
      log("Accept Help: ${resp.statusCode}");
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        // bool isConnected = resp.data['isConnected'];
        return;
      } else if (resp.statusCode == 404) {
        removeHelpLocal(helpId);
        return;
      } else {
        return;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        removeHelpLocal(helpId);
        Common.showErrorDialog(
          context,
          e: "Help request already accepted or canceled".tr,
        );
        return;
      }
      Common.showDioErrorDialog(Get.context!, e: e);
      // rethrow;
    } catch (e) {
      Common.showErrorDialog(Get.context!, e: e.toString());
      // rethrow;
    } finally {}
  }

  sortOngoingHelp() {
    ongoingHelps.sort((a, b) =>
        b.messages.first.updatedAt.compareTo(a.messages.first.updatedAt));
  }
}
