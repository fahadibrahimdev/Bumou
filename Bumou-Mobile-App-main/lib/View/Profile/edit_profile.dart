import 'package:app/Constants/color.dart';
import 'package:app/Controller/auth_controller.dart';
import 'package:app/Model/enums.dart';
import 'package:app/Utils/image_picker.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/View/Widget/k_net_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController teacherNameController = TextEditingController();
  final TextEditingController classNameController = TextEditingController();

  @override
  void initState() {
    fNameController.text = AuthController.to.user?.firstName ?? '';
    lNameController.text = AuthController.to.user?.lastName ?? '';
    phoneController.text = AuthController.to.user?.phone ?? '';
    cityController.text = AuthController.to.user?.city ?? '';
    countryController.text = AuthController.to.user?.country ?? '';
    schoolNameController.text = AuthController.to.user?.schoolName ?? '';
    teacherNameController.text = AuthController.to.user?.teacherName ?? '';
    classNameController.text = AuthController.to.user?.className ?? '';
    super.initState();
  }

  String? selectedImg;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Edit Profile'.tr,
              style: Theme.of(context).textTheme.titleMedium)),
      body: GetBuilder<AuthController>(builder: (cntrlr) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: [
              const SizedBox(height: 10),
              Center(
                child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Hero(
                        tag: 'profilepicture',
                        child: KCircularCacheImg(
                          imgPath: selectedImg ?? cntrlr.user?.profilePicture,
                          radius: MediaQuery.sizeOf(context).width * 0.4,
                          paddingDefault: 0,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                            style: IconButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: AppColors.white),
                            onPressed: () async {
                              if (selectedImg != null) {
                                setState(() {
                                  selectedImg = null;
                                });
                                return;
                              }
                              final img = await FilePickerUtils.imagePicker(
                                  context,
                                  needCropping: true);
                              if (img != null) {
                                setState(() {
                                  selectedImg = img;
                                });
                              }
                            },
                            icon: Icon(selectedImg != null
                                ? Icons.delete_forever_outlined
                                : Icons.add_a_photo_outlined)),
                      ),
                    ]),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: fNameController,
                keyboardType: TextInputType.name,
                autofillHints: const [AutofillHints.name],
                maxLines: 1,
                decoration: InputDecoration(
                    hintText: cntrlr.user?.firstName ?? 'First Name'.tr),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: lNameController,
                keyboardType: TextInputType.name,
                autofillHints: const [AutofillHints.name],
                maxLines: 1,
                decoration: InputDecoration(
                    hintText: cntrlr.user?.lastName ?? 'Last Name'.tr),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                maxLines: 1,
                decoration: InputDecoration(
                    hintText: cntrlr.user?.phone ?? 'Mobile No'.tr),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: countryController,
                keyboardType: TextInputType.streetAddress,
                autofillHints: const [AutofillHints.countryName],
                maxLines: 1,
                decoration: InputDecoration(
                    hintText: cntrlr.user?.country ?? 'Country'.tr),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: cityController,
                keyboardType: TextInputType.streetAddress,
                autofillHints: const [AutofillHints.addressCity],
                decoration:
                    InputDecoration(hintText: cntrlr.user?.city ?? 'City'.tr),
              ),
              if (cntrlr.user?.userType == UserType.student.name)
                Column(children: [
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: schoolNameController,
                      keyboardType: TextInputType.text,
                      autofillHints: const [AutofillHints.organizationName],
                      maxLines: 1,
                      decoration: InputDecoration(
                          hintText:
                              cntrlr.user?.schoolName ?? 'School Name'.tr)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: teacherNameController,
                    keyboardType: TextInputType.text,
                    autofillHints: const [AutofillHints.name],
                    maxLines: 1,
                    decoration: InputDecoration(
                        hintText:
                            cntrlr.user?.teacherName ?? 'Teacher Name'.tr),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: classNameController,
                    keyboardType: TextInputType.text,
                    autofillHints: const [AutofillHints.name],
                    maxLines: 1,
                    decoration: InputDecoration(
                        hintText: cntrlr.user?.className ?? 'Class Name'.tr),
                  ),
                ]),
              const SizedBox(height: 20),
              FilledButton(
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60.0)),
                  onPressed: () async {
                    await kOverlayWithAsync(asyncFunction: () async {
                      String? imgUrl = cntrlr.user?.profilePicture;
                      if (selectedImg != null) {
                        imgUrl = await cntrlr.uploadFile(context,
                            file: selectedImg!, path: 'ProfileImages');
                        print(imgUrl);
                      }
                      Map<String, dynamic> data = {
                        'firstName': fNameController.text,
                        'lastName': lNameController.text,
                        'phone': phoneController.text,
                        'city': cityController.text,
                        'country': countryController.text,
                        'schoolName': schoolNameController.text,
                        'teacherName': teacherNameController.text,
                        'className': classNameController.text,
                        'profilePicture': imgUrl,
                      };
                      await cntrlr.updateUser(context, data: data);
                    });
                  },
                  child: Text('Save'.tr)),
            ]),
          ),
        );
      }),
    );
  }
}
