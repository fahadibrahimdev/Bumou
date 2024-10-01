import 'dart:convert';

import 'package:app/Constants/api.dart';
import 'package:app/Data/Network/request_client.dart';
import 'package:app/Model/moment.dart';
import 'package:app/Utils/comon.dart';
import 'package:app/Utils/logging.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MommentController extends GetxController {
  static MommentController get to => Get.find();
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  // final RefreshController commentRefreshController = RefreshController(initialRefresh: false);

  List<Moment> moment = [];
  bool isLoadingMoment = true;
  String? errorMsgOfMoment;
  bool isLoadingMoreData = true;
  int page = 1;
  int pageSize = 10;
  bool isLastPage = false;
  bool isFirstData = true;

  int pageLike = 1;
  int pageSizeLike = 10000;
  List<Map<String, dynamic>> likes = [];
  bool isLoadingLike = false;
  String? errorMsgOfLike;

  // int pageComment = 1;
  // int pageSizeComment = 10;
  // List<Comment> comments = [];
  // bool isLoadingComment = false;
  // String? errorMsgOfComment;
  // bool isLastPageComment = false;
  // bool isFirstPageComment = true;
  // bool isLoadingMoreComment = false;

  Future<void> onRefresh() async {
    page = 1;
    pageSize = 10;
    isLastPage = false;
    isFirstData = true;
    isLoadingMoment = true;
    moment = [];
    await getAllPost(Get.context!);
    refreshController.refreshCompleted();
    refreshController.resetNoData();
    update();
  }

  Future<void> onNextPage() async {
    if (!isLastPage && !isLoadingMoreData) {
      isLoadingMoreData = true;
      page++;
      await getAllPost(Get.context!);
      refreshController.loadComplete();
    } else if (isLastPage) {
      refreshController.loadNoData();
    }
  }

  // Future<void> onCommentRefresh(String postId) async {
  //   pageComment = 1;
  //   pageSizeComment = 10;
  //   isLastPageComment = false;
  //   isFirstPageComment = true;
  //   isLoadingMoreComment = false;
  //   comments = [];
  //   await getComment(Get.context!, postId: postId);
  //   commentRefreshController.refreshCompleted();
  //   commentRefreshController.resetNoData();
  // }

  // Future<void> onCommentNextPage(String postId) async {
  //   if (!isLastPageComment && !isLoadingMoreComment) {
  //     isLoadingMoreComment = true;
  //     pageComment++;
  //     await getComment(Get.context!, postId: postId);
  //     commentRefreshController.loadComplete();
  //   } else if (isLastPageComment) {
  //     commentRefreshController.loadNoData();
  //   }
  // }

  Future<void> createPost(BuildContext context, {required Map<String, dynamic> data}) async {
    try {
      var response = await NetworkClient.post(Apis.createPost, data: data);
      Logger.message('Create Post Response: ${response.statusCode}, ${jsonEncode(response.data)}');
      if (response.statusCode == 200) {
        await onRefresh();
        Get.back();
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
    }
  }

  Future<void> getAllPost(BuildContext context) async {
    try {
      errorMsgOfMoment = null;
      isLoadingMoreData = true;
      Response<dynamic> response = await NetworkClient.get(Apis.moments,
          queryParameters: {"page": page.toString(), "pageSize": pageSize.toString()});
      Logger.message('Get All Post Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        if (isFirstData && response.data.isEmpty) {
          isLastPage = true;
          refreshController.loadNoData();
        } else if (response.data.isEmpty) {
          isLastPage = true;
          refreshController.loadNoData();
        } else if (response.data.isNotEmpty) {
          // moment = [];
          for (var item in response.data) {
            moment.add(Moment.fromJson(item));
          }
        }
        isFirstData = false;
      } else {
        errorMsgOfMoment = response.data['message'];
        refreshController.loadNoData();
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
      errorMsgOfMoment = e.message;
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
      errorMsgOfMoment = error.toString();
    } finally {
      isLoadingMoment = false;
      isLoadingMoreData = false;
      update();
    }
  }

  Future<void> likePost(BuildContext context, {required String postId}) async {
    try {
      var response = await NetworkClient.post(
        '${Apis.moments}/$postId/like',
      );
      Logger.message('Like Post Response: ${response.statusCode}, ${jsonEncode(response.data)}');
      if (response.statusCode == 200 && context.mounted) {
        await onRefresh();
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
    }
  }

  Future<void> getLikes(BuildContext context, {required String postId}) async {
    try {
      errorMsgOfLike = null;
      isLoadingLike = true;
      update();
      var response = await NetworkClient.get(
        '${Apis.moments}/$postId/likes?page=${pageLike.toString()}&pageSize=${pageSizeLike.toString()}',
      );
      Logger.message('Get Likes Response: ${response.statusCode}, ${jsonEncode(response.data)}');
      if (response.statusCode == 200) {
        likes = [];
        for (var item in response.data["likes"]) {
          likes.add(item);
        }
      } else {
        errorMsgOfLike = response.data['message'];
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
      errorMsgOfLike = e.message;
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
      errorMsgOfLike = error.toString();
    } finally {
      isLoadingLike = false;
      update();
    }
  }

  Future<void> deleteMomentPost(BuildContext context, String postId) async {
    try {
      final response = await NetworkClient.delete("${Apis.deletePost}/$postId");
      if (response.statusCode == 200 && context.mounted) {
        Common.showSuccessDialog(context, message: response.data['message']);
        int indexOfMoment = moment.indexWhere((element) => element.id == postId);
        if (indexOfMoment != -1) {
          moment.removeAt(indexOfMoment);
          update();
        }
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
    } catch (e) {
      if (context.mounted) Common.showErrorDialog(context, e: e.toString());
    }
  }

  // Future<void> addComment(BuildContext context, {required String comment, required String postId}) async {
  //   try {
  //     var response = await NetworkClient.post(
  //       '${Apis.moments}/$postId/comment',
  //       data: {"comment": comment},
  //     );
  //     Logger.message('Add Comment Response: ${response.statusCode}, ${jsonEncode(response.data)}');
  //     if (response.statusCode == 200) {
  //       moment = [];
  //       await getAllPost(Get.context!);
  //     }
  //   } on DioException catch (e) {
  //     if (context.mounted) Common.showDioErrorDialog(context, e: e);
  //   } catch (error) {
  //     Logger.message('Error: $error');
  //     Get.snackbar("Failed", error.toString());
  //   }
  // }

  // Future<void> getComment(BuildContext context, {required String postId}) async {
  //   try {
  //     errorMsgOfComment = null;
  //     isLoadingComment = true;
  //     update();
  //     var response = await NetworkClient.get('${Apis.moments}/$postId/comments',
  //         queryParameters: {"page": pageComment.toString(), "pageSize": pageSizeComment.toString()});
  //     Logger.message('Get Comment Response: ${response.statusCode}, ${jsonEncode(response.data)}');
  //     if (response.statusCode == 200) {
  //       if (isFirstPageComment && response.data.isEmpty) {
  //         isLastPageComment = true;
  //         commentRefreshController.loadNoData();
  //       } else if (response.data.isEmpty) {
  //         isLastPageComment = true;
  //         commentRefreshController.loadNoData();
  //       } else if (response.data.isNotEmpty) {
  //         for (var item in response.data) {
  //           comments.add(Comment.fromJson(item));
  //         }
  //       }
  //       isFirstPageComment = false;
  //     } else {
  //       errorMsgOfComment = response.data['message'];
  //       commentRefreshController.loadNoData();
  //     }
  //   } on DioException catch (e) {
  //     if (context.mounted) Common.showDioErrorDialog(context, e: e);
  //     errorMsgOfComment = e.message;
  //   } catch (error) {
  //     Logger.message('Error: $error');
  //     Get.snackbar("Failed", error.toString());
  //     errorMsgOfComment = error.toString();
  //   } finally {
  //     isLoadingComment = false;
  //     isLoadingMoreComment = false;
  //     update();
  //   }
  // }
}
