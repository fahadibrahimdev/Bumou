import 'package:app/Constants/api.dart';
import 'package:app/Data/Network/request_client.dart';
import 'package:app/Model/user.dart';
import 'package:app/Utils/comon.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../Model/moment.dart';

class UserDetailsController extends GetxController {
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  late String userId;

  bool isUserLoading = false;
  bool isPostsLoading = false;
  bool isPostsLoadingMore = false;

  User? user;
  String? userError;

  List<Moment> posts = [];
  String? postsError;

  int page = 1;
  bool hasMore = true;
  int limit = 10;

  @override
  void onInit() {
    userId = Get.arguments;
    // log('userId: $userId');
    super.onInit();
  }

  @override
  void onReady() {
    onRefreshData();
    super.onReady();
  }

  Future<void> getUser() async {
    isUserLoading = true;
    update();
    try {
      final res = await NetworkClient.get(Apis.getUserById + userId);
      // log('res: ${res.data}');
      user = User.fromJson(res.data);
      getPosts();
    } on DioException catch (e) {
      userError = Common.getErrorMsgOfDio(e);
    } catch (e) {
      userError = e.toString();
    } finally {
      isUserLoading = false;
      update();
    }
  }

  // refresh
  Future<void> onRefreshData() async {
    page = 1;
    hasMore = true;
    posts = [];
    await getUser();
    refreshController.refreshCompleted();
    refreshController.resetNoData();
  }

  Future<void> onNextPage() async {
    if (!hasMore || isPostsLoadingMore) {
      return;
    }
    await getPosts();
    refreshController.loadComplete();
  }

  Future<void> getPosts() async {
    isPostsLoadingMore = true;
    update();
    try {
      final res = await NetworkClient.get(
        '${Apis.getUserPosts}/$userId?page=$page&size=$limit',
      );
      page++;
      List<Moment> newPosts = [];
      res.data.forEach((v) {
        newPosts.add(Moment.fromJson(v));
      });
      if (newPosts.length < limit) {
        hasMore = false;
      }
      posts.addAll(newPosts);
    } on DioException catch (e) {
      postsError = Common.getErrorMsgOfDio(e);
    } catch (e) {
      postsError = e.toString();
    } finally {
      isPostsLoading = false;
      isPostsLoadingMore = false;
      update();
    }
  }
}
