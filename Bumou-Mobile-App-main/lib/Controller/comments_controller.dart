import 'package:app/Controller/auth_controller.dart';
import 'package:app/Controller/momment_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../Constants/api.dart';
import '../Data/Network/request_client.dart';
import '../Model/moment.dart';
import '../Utils/comon.dart';
import '../Utils/logging.dart';

class CommentsController extends GetxController {
  static CommentsController get to => Get.find();

  final RefreshController commentRefreshController = RefreshController(initialRefresh: false);

  @override
  void onInit() {
    getComment(Get.context!, postId: Get.arguments);
    super.onInit();
  }

  int pageComment = 1;
  int pageSizeComment = 10;
  List<Comment> comments = [];
  bool isLoadingComment = false;
  String? errorMsgOfComment;
  bool isLastPageComment = false;
  bool isFirstPageComment = true;
  bool isLoadingMoreComment = false;

  Future<void> onCommentRefresh(String postId) async {
    pageComment = 1;
    pageSizeComment = 10;
    isLastPageComment = false;
    isFirstPageComment = true;
    isLoadingMoreComment = false;
    comments = [];
    await getComment(Get.context!, postId: postId);
    commentRefreshController.refreshCompleted();
    commentRefreshController.resetNoData();
  }

  Future<void> onCommentNextPage(String postId) async {
    if (!isLastPageComment && !isLoadingMoreComment) {
      isLoadingMoreComment = true;
      pageComment++;
      await getComment(Get.context!, postId: postId);
      commentRefreshController.loadComplete();
    } else if (isLastPageComment) {
      commentRefreshController.loadNoData();
    }
  }

  Future<void> addComment(BuildContext context, {required String comment, required String postId}) async {
    try {
      var response = await NetworkClient.post(
        '${Apis.moments}/$postId/comment',
        data: {"comment": comment},
      );
      Logger.message('Add Comment Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        comments.insert(0, Comment.fromJson(response.data));
        int indexOfMoment = Get.find<MommentController>().moment.indexWhere((element) => element.id == postId);
        if (indexOfMoment != -1) {
          Comment comment = Comment.fromJson(response.data);
          comment.user = Get.find<AuthController>().user;
          Get.find<MommentController>().moment[indexOfMoment].comments?.insert(0, comment);
          Get.find<MommentController>().update();
        }
        update();
      } else {
        Get.snackbar("Failed", response.data['message']);
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
    }
  }

  Future<void> getComment(
    BuildContext context, {
    required String postId,
  }) async {
    try {
      errorMsgOfComment = null;
      isLoadingComment = true;
      update();
      var response = await NetworkClient.get(
        '${Apis.moments}/$postId/comments',
        queryParameters: {
          "page": pageComment.toString(),
          "pageSize": pageSizeComment.toString(),
        },
      );
      Logger.message('Get Comment Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        if (isFirstPageComment && response.data.isEmpty) {
          isLastPageComment = true;
          commentRefreshController.loadNoData();
        } else if (response.data.isEmpty) {
          isLastPageComment = true;
          commentRefreshController.loadNoData();
        } else if (response.data.isNotEmpty) {
          for (var item in response.data) {
            comments.add(Comment.fromJson(item));
          }
        }
        isFirstPageComment = false;
      } else {
        errorMsgOfComment = response.data['message'];
        commentRefreshController.loadNoData();
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
      errorMsgOfComment = e.message;
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
      errorMsgOfComment = error.toString();
    } finally {
      isLoadingComment = false;
      isLoadingMoreComment = false;
      update();
    }
  }
}
