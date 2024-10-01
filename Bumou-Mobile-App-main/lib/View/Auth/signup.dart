import 'package:app/Constants/color.dart';
import 'package:app/Controller/auth_controller.dart';
import 'package:app/Model/enums.dart';
import 'package:app/Utils/input_utils.dart';
import 'package:app/Utils/loading_overlays.dart';
import 'package:app/Utils/navigations.dart';
import 'package:app/Utils/validators.dart';
import 'package:app/View/Auth/login.dart';
import 'package:app/View/Widget/language_bottom_bar.dart';
import 'package:app/main.dart';
// import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController? fNameController = TextEditingController();
  final TextEditingController? lNameController = TextEditingController();
  final TextEditingController? schoolController = TextEditingController();
  final TextEditingController? classController = TextEditingController();
  final TextEditingController? teacherController = TextEditingController();
  final TextEditingController? mobileController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  String selectedUserType = UserType.student.name;
  bool isValidated = false;
  bool obscureText = true;
  bool isAcceptedTerms = false;

  @override
  void initState() {
    countryController.text = ipData?.country ?? '';
    cityController.text = ipData?.city ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (cntrlr) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
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
                  Text('Sign Up'.tr,
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
                              selected: selectedUserType == UserType.adult.name,
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
                        controller: fNameController,
                        keyboardType: TextInputType.name,
                        autofillHints: const [AutofillHints.name],
                        maxLines: 1,
                        validator: requiredValidator(),
                        decoration: InputDecoration(
                          hintText: 'First Name'.tr,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: lNameController,
                        keyboardType: TextInputType.name,
                        autofillHints: const [AutofillHints.name],
                        maxLines: 1,
                        validator: requiredValidator(),
                        decoration: InputDecoration(
                          hintText: 'Last Name'.tr,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: countryController,
                        keyboardType: TextInputType.text,
                        autofillHints: const [AutofillHints.countryName],
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Country name'.tr,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cityController,
                        keyboardType: TextInputType.text,
                        autofillHints: const [AutofillHints.addressCity],
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: 'City name'.tr,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (selectedUserType == UserType.student.name)
                        Column(children: [
                          TextFormField(
                            controller: schoolController,
                            keyboardType: TextInputType.text,
                            autofillHints: const [
                              AutofillHints.organizationName
                            ],
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'School Name'.tr,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: classController,
                            keyboardType: TextInputType.text,
                            autofillHints: const [
                              AutofillHints.organizationName
                            ],
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Class Name'.tr,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: teacherController,
                            keyboardType: TextInputType.text,
                            autofillHints: const [AutofillHints.name],
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Teacher Name'.tr,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ]),
                      TextFormField(
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        maxLines: 1,
                        validator: requiredValidator(),
                        onChanged: (value) {
                          cntrlr.phoneAvailability(context, value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Mobile No'.tr,
                          suffixIcon: cntrlr.isPhoneAvailable == null
                              ? cntrlr.isCheckingPhone
                                  ? const CupertinoActivityIndicator()
                                  : null
                              : cntrlr.isPhoneAvailable ?? true
                                  ? const Icon(Icons.check,
                                      color: AppColors.success)
                                  : const Icon(Icons.close,
                                      color: AppColors.red),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: usernameController,
                        keyboardType: TextInputType.name,
                        autofillHints: const [AutofillHints.username],
                        maxLines: 1,
                        validator: requiredValidator(),
                        autovalidateMode: isValidated
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        onChanged: (value) {
                          cntrlr.validateUserName(context, value);
                          emailController.text = "$value@bumou.com";
                        },
                        decoration: InputDecoration(
                          hintText: 'Username'.tr,
                          suffixIcon: cntrlr.isUsernameAvailable == null
                              ? cntrlr.isCheckingUsername
                                  ? const CupertinoActivityIndicator()
                                  : null
                              : cntrlr.isUsernameAvailable ?? false
                                  ? const Icon(Icons.check,
                                      color: AppColors.success)
                                  : const Icon(Icons.close,
                                      color: AppColors.red),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        maxLines: 1,
                        // validator: emailValidator(),
                        autovalidateMode: isValidated
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        onChanged: (value) {
                          if (KValidators.isEmail(value)) {
                            cntrlr.validateEmail(context, value);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Email'.tr,
                          suffixIcon: cntrlr.isEmailAvailable == null
                              ? null
                              : cntrlr.isEmailAvailable ?? false
                                  ? const Icon(Icons.check,
                                      color: AppColors.success)
                                  : const Icon(Icons.close,
                                      color: AppColors.red),
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
                                ? const Icon(
                                    Icons.visibility_off_outlined,
                                    color: AppColors.grey,
                                    size: 22,
                                  )
                                : const Icon(
                                    Icons.visibility_outlined,
                                    color: AppColors.grey,
                                    size: 22,
                                  ),
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
                      minimumSize: const Size(double.infinity, 60.0),
                    ),
                    onPressed: () {
                      // statesController.value.add(MaterialState.);
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
                        'email': emailController.text,
                        'firstName': fNameController?.text,
                        'lastName': lNameController?.text,
                        'schoolName': schoolController?.text,
                        'className': classController?.text,
                        'teacherName': teacherController?.text,
                        'phone': mobileController?.text,
                        'username': usernameController.text,
                        'password': passwordController.text,
                        'userType': selectedUserType,
                        'city': cityController.text,
                        'country': countryController.text,
                      };
                      setState(() {
                        isValidated = true;
                      });
                      if (_key.currentState!.validate()) {
                        kOverlayWithAsync(asyncFunction: () async {
                          await cntrlr
                              .signUp(context, data: data)
                              .then((value) {
                            cntrlr.isEmailAvailable = null;
                            cntrlr.isUsernameAvailable = null;
                          });
                        });
                      }
                    },
                    child: Text('Sign Up'.tr),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?'.tr,
                          style: Theme.of(context).textTheme.bodyMedium),
                      TextButton(
                        onPressed: () {
                          cntrlr.isEmailAvailable = null;
                          cntrlr.isUsernameAvailable = null;
                          Get.off(() => const LoginView());
                        },
                        child: Text(
                          'Log In'.tr,
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      )
                    ],
                  ),
                  TextButton(
                    onPressed: () => openPrivacyPolicy(),
                    child: Text(
                      'Privacy Policy & Terms of Services'.tr,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const SafeArea(
          child: LanguageChangeBar(),
        ),
      );
    });
  }
}
