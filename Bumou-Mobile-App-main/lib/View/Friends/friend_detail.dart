import 'package:app/Controller/friend_controller.dart';
import 'package:app/Model/enums.dart';
import 'package:app/Model/user.dart';
import 'package:app/Utils/comon.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/View/Widget/k_net_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendDetail extends StatefulWidget {
  const FriendDetail({super.key, required this.friend});
  final User friend;

  @override
  State<FriendDetail> createState() => _FriendDetailState();
}

class _FriendDetailState extends State<FriendDetail> {
  bool isRequestSent = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('${widget.friend.firstName} ${widget.friend.lastName}',
              style: Theme.of(context).textTheme.titleMedium)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              KCircularCacheImg(imgPath: widget.friend.profilePicture),
              const SizedBox(height: 16),
              Text(widget.friend.username!,
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('About'.tr,
                      style: Theme.of(context).textTheme.titleLarge)),
              const SizedBox(height: 10),
              if (widget.friend.city != null && widget.friend.country != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${widget.friend.city}, ${widget.friend.country}',
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
              if (widget.friend.userType == UserType.student.name)
                Column(children: [
                  const SizedBox(height: 10),
                  Row(children: [
                    Text('School:'.tr,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(width: 20),
                    Text(widget.friend.schoolName ?? '',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Text('Teacher:'.tr,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(width: 20),
                    Text(widget.friend.teacherName ?? '',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Text('Class:'.tr,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(width: 20),
                    Text(widget.friend.className ?? '',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ]),
                ]),
              const SizedBox(height: 30),
              !isRequestSent
                  ? FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        kOverlayWithAsync(asyncFunction: () async {
                          await FriendController.to
                              .sendRequest(context, id: widget.friend.id!)
                              .then((value) {
                            if (value) {
                              Common.showSuccessDialog(context,
                                  message: 'Request sent successfully'.tr);
                            }
                          }).then((value) {
                            setState(() {
                              isRequestSent = true;
                            });
                          });
                        });
                      },
                      child: Text('Add Friend'.tr),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
