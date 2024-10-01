import 'package:app/Constants/color.dart';
import 'package:app/Controller/auth_controller.dart';
import 'package:app/Data/Local/hive_storage.dart';
import 'package:app/Model/enums.dart';
import 'package:app/Utils/comon.dart';
import 'package:app/Utils/input_utils.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/Utils/navigations.dart';
import 'package:app/View/Auth/signup.dart';
import 'package:app/View/Widget/language_bottom_bar.dart';
// import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  String selectedUserType = UserType.student.name;
  bool isValidated = false;
  bool obscureText = true;

  bool isAcceptedTerms = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      bool isFirstOpen = LocalStorage.getFirstOpen;
      if (isFirstOpen) {
        Common.showPrivacyPolicyBottomSheet(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (cntrlr) {
      return GestureDetector(
        onTap: () => unfocusKeyboard(context),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // FilledButton(
                    //   onPressed: () {
                    //     LocalStorage.clearAuth();
                    //   },
                    //   child: Text('-----'),
                    // ),
                    Hero(
                        tag: "logo",
                        child: SvgPicture.asset('assets/svgs/logo-text.svg',
                            width: 200)),
                    const SizedBox(height: 10),
                    // Text(
                    //   "Visible psychological pulsation".tr,
                    //   style: Theme.of(context).textTheme.bodyMedium,
                    // ),
                    const SizedBox(height: 20),
                    Text('Log in'.tr,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 30),
                    Form(
                      key: _key,
                      child: Column(children: [
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile.adaptive(
                                selected:
                                    selectedUserType == UserType.student.name,
                                selectedTileColor: AppColors.primaryLight,
                                activeColor: AppColors.primary,
                                title: Text(
                                  'Student'.tr,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                value: UserType.student.name,
                                groupValue: selectedUserType,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedUserType = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RadioListTile.adaptive(
                                selected:
                                    selectedUserType == UserType.adult.name,
                                selectedTileColor: AppColors.primaryLight,
                                activeColor: AppColors.primary,
                                title: Text(
                                  'Adult'.tr,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                value: UserType.adult.name,
                                groupValue: selectedUserType,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedUserType = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailController,
                          maxLines: 1,
                          validator: requiredValidator(),
                          autovalidateMode: isValidated
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          onChanged: (value) {},
                          decoration: InputDecoration(
                            hintText: 'Email, Phone or Username'.tr,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          autofillHints: const [AutofillHints.password],
                          maxLines: 1,
                          validator: passwordValidator(),
                          obscureText: obscureText,
                          autovalidateMode: isValidated
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          decoration: InputDecoration(
                            hintText: 'Password'.tr,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              icon: obscureText
                                  ? const Icon(Icons.visibility_off_outlined,
                                      color: AppColors.grey, size: 22)
                                  : const Icon(Icons.visibility_outlined,
                                      color: AppColors.grey, size: 22),
                            ),
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 8),
                    CheckboxListTile.adaptive(
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: isAcceptedTerms,
                      checkColor: AppColors.white,
                      checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      fillColor: MaterialStateProperty.all(AppColors.primary),
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          isAcceptedTerms = value!;
                        });
                      },
                      title: RichText(
                        text: TextSpan(
                          text: 'I accept the '.tr,
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            WidgetSpan(
                              child: InkWell(
                                onTap: () => openPrivacyPolicy(),
                                child: Text(
                                  'Terms of Service'.tr,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(color: AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 60.0)),
                      onPressed: () {
                        if (!isAcceptedTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Please accept the terms of service'.tr),
                            ),
                          );
                          return;
                        }
                        Map<String, dynamic> data = {
                          'username': emailController.text,
                          'password': passwordController.text,
                          'userType': selectedUserType
                        };
                        setState(() {
                          isValidated = true;
                        });
                        if (_key.currentState!.validate()) {
                          kOverlayWithAsync(asyncFunction: () async {
                            await cntrlr.login(context, data: data);
                          });
                        }
                      },
                      child: Text('Login'.tr),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t have an account?'.tr,
                            style: Theme.of(context).textTheme.bodyMedium),
                        TextButton(
                          onPressed: () {
                            cntrlr.isEmailAvailable = null;
                            Get.off(() => const SignUpView());
                          },
                          child: Text(
                            'Sign Up'.tr,
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => openPrivacyPolicy(),
                      child: Text(
                        'Privacy Policy & Terms of Services'.tr,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: const SafeArea(
            child: LanguageChangeBar(),
          ),
        ),
      );
    });
  }
}
