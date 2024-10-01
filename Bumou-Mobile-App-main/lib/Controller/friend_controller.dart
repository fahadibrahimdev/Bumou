import 'package:app/Constants/api.dart';
import 'package:app/Data/Network/request_client.dart';
import 'package:app/Model/user.dart';
import 'package:app/Utils/comon.dart';
import 'package:app/Utils/logging.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FriendController extends GetxController {
  static FriendController get to => Get.find();

  final RefreshController refreshPendingController =
      RefreshController(initialRefresh: false);

  final RefreshController refreshFriendController =
      RefreshController(initialRefresh: false);

  final RefreshController refreshsuggestionController =
      RefreshController(initialRefresh: false);

  List<User> myFriends = [];
  String? myFriendErrorMsg;
  bool isLoadingMyFriends = false;

  List<User> myRequest = [];
  String? myRequestErrorMsg;
  bool isLoadingMyRequests = false;

  List<User> suggestedFriendList = [];
  String? errorMsgofSuggestion;
  bool isLoadingSuggestion = false;
  bool isLoadingMoreData = true;
  int page = 1;
  int pageSize = 20;
  bool isLastPage = false;
  bool isFirstData = true;

  @override
  void onInit() {
    super.onInit();
    getPendingRequest(Get.context!);
    getAllFriends(Get.context!);
    suggestedFriends(Get.context!);
  }

  void onRefresh() async {
    FriendController.to.getAllFriends(Get.context!);
    FriendController.to.getPendingRequest(Get.context!);
    refreshFriendController.refreshCompleted();
  }

  void onLoading() async {
    refreshPendingController.loadComplete();
    refreshFriendController.loadComplete();
  }

  Future<void> onRefreshSuggestion() async {
    page = 1;
    pageSize = 20;
    isLastPage = false;
    isFirstData = true;
    isLoadingSuggestion = true;
    suggestedFriendList = [];
    update();
    await suggestedFriends(Get.context!);
    refreshsuggestionController.refreshCompleted();
    refreshsuggestionController.resetNoData();
    update();
  }

  Future<void> onNextPage() async {
    if (!isLastPage && !isLoadingMoreData) {
      isLoadingMoreData = true;
      page++;
      await suggestedFriends(Get.context!);
      refreshsuggestionController.loadComplete();
    } else if (isLastPage) {
      refreshsuggestionController.loadNoData();
    }
  }

  Future<void> getAllFriends(BuildContext context) async {
    try {
      myFriendErrorMsg = null;
      isLoadingMyFriends = true;
      update();
      var response = await NetworkClient.get(Apis.getAllFriends);
      Logger.message('Get All Friend Response: ${response.statusCode}}');
      if (response.statusCode == 200) {
        myFriends = [];
        final jsonData = response.data;
        for (var item in jsonData) {
          myFriends.add(User.fromJson(item));
        }
      } else {
        myFriendErrorMsg = response.data['message'];
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
      myFriendErrorMsg = e.message;
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
      myFriendErrorMsg = error.toString();
    } finally {
      isLoadingMyFriends = false;
      update();
    }
  }

  Future<bool> acceptRequest(BuildContext context,
      {required String id, required String status}) async {
    try {
      var response = await NetworkClient.patch(Apis.acceptFriendRequest, data: {
        'friendshipId': id,
        'status': status,
      });
      Logger.message('Accept Request Response: ${response.statusCode}}');
      if (response.statusCode == 200) {
        if (context.mounted) getPendingRequest(context);
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
      return false;
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
      return false;
    }
  }

  Future<bool> sendRequest(BuildContext context, {required String id}) async {
    try {
      var response = await NetworkClient.post(Apis.sendFriendRequest,
          data: {'userId': id});
      Logger.message('Send Request Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        int index =
            suggestedFriendList.indexWhere((element) => element.id == id);
        if (index != -1) {
          suggestedFriendList.remove(suggestedFriendList[index]);
          update();
        }
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
      return false;
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
      return false;
    }
  }

  Future<void> getPendingRequest(BuildContext context) async {
    try {
      isLoadingMyRequests = true;
      myRequestErrorMsg = null;
      update();
      var response = await NetworkClient.get(Apis.pending);
      Logger.message('Pending Request Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        myRequest = [];
        final jsonData = response.data;
        for (var item in jsonData) {
          final id = item['user1Id'];
          final friendShipId = item['id'];
          var userResponse = await NetworkClient.get('${Apis.getUserById}$id');
          Logger.message('Get User By Id Response: ${userResponse.statusCode}');
          if (userResponse.statusCode == 200) {
            final userData = userResponse.data;
            userData['friendShipId'] = friendShipId;
            myRequest.add(User.fromJson(userData));
          }
        }
      } else {
        myRequestErrorMsg = response.data['message'];
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
      myRequestErrorMsg = e.message;
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
      myRequestErrorMsg = error.toString();
    } finally {
      isLoadingMyRequests = false;
      update();
    }
  }

  Future<void> suggestedFriends(BuildContext context) async {
    try {
      errorMsgofSuggestion = null;
      isLoadingSuggestion = true;
      update();
      var response = await NetworkClient.get(Apis.suggestedFriend,
          queryParameters: {
            "page": page.toString(),
            "pageSize": pageSize.toString()
          });
      Logger.message('Suggested Friends Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        if (isFirstData && response.data.isEmpty) {
          isLastPage = true;
          refreshsuggestionController.loadNoData();
        } else if (response.data.isEmpty) {
          isLastPage = true;
          refreshsuggestionController.loadNoData();
        } else if (response.data.isNotEmpty) {
          for (var item in response.data) {
            suggestedFriendList.add(User.fromJson(item));
          }
        }
        isFirstData = false;
      } else {
        errorMsgofSuggestion = response.data['message'];
        refreshsuggestionController.loadNoData();
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
      errorMsgofSuggestion = e.message;
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
      errorMsgofSuggestion = error.toString();
    } finally {
      isLoadingSuggestion = false;
      isLoadingMoreData = false;
      update();
    }
  }

  Future<void> removeFriend(BuildContext context, {required String id}) async {
    try {
      var response = await NetworkClient.patch('${Apis.removeFriend}/$id');
      Logger.message('Remove Friend Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        for (var i = 0; i < myFriends.length; i++) {
          if (myFriends[i].id == id) {
            myFriends.removeAt(i);
            update();
            break;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Friend removed successfully'.tr),
          ),
        );
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
    }
  }
}
