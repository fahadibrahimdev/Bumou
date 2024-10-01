import 'package:app/Controller/user_details_controller.dart';
import 'package:app/Model/moment.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/View/Moment/moment.dart';
import 'package:app/View/Widget/k_net_image.dart';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:unlock_detector/unlock_detector.dart';

import '../../Model/user.dart';
import 'dart:developer' as developer;

class UserProfileDetails extends StatefulWidget {
  const UserProfileDetails({super.key, this.imgTag = ''});
  final String imgTag;

  @override
  State<UserProfileDetails> createState() => _UserProfileDetailsState();
}

class _UserProfileDetailsState extends State<UserProfileDetails> {
  @override
  Future<void> initState() async {
    // Get.put<UserDetailsController>(
    //   UserDetailsController(),
    // );
    await initAliyunPush();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SmartRefresher(
        controller: Get.find<UserDetailsController>().refreshController,
        onRefresh: Get.find<UserDetailsController>().onRefreshData,
        onLoading: Get.find<UserDetailsController>().onNextPage,
        child: SingleChildScrollView(
          child: GetBuilder<UserDetailsController>(
            builder: (_) {
              if (_.isUserLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_.userError != null) {
                return Center(child: Text(_.userError ?? 'Error'));
              }
              if (_.user == null) {
                return const Center(child: Text('No user found'));
              }

              User user = _.user!;
              return Column(
                children: [
                  Hero(
                    tag: widget.imgTag,
                    child: KCircularCacheImg(
                      imgPath: user.profilePicture,
                      radius: MediaQuery.sizeOf(context).width * 0.23,
                      paddingDefault: 0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    user.username!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Divider(),
                  _.isPostsLoading
                      ? const LoadingWidget()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _.posts.length,
                          itemBuilder: (BuildContext context, int index) {
                            Moment moment = _.posts[index];
                            String imgTag = 'moment$index';
                            bool isMine = false;
                            return MomentWidget(
                              moment: moment,
                              imgTag: imgTag,
                              isMine: isMine,
                            );
                          },
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
