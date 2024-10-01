import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';

void unfocusKeyboard(BuildContext context) {
  final currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}

String? Function(String?)? requiredValidator({String? error}) {
  return RequiredValidator(errorText: error ?? 'This field is required'.tr).call;
}

MultiValidator emailValidator() {
  return MultiValidator([
    RequiredValidator(errorText: 'Email is required'.tr),
    EmailValidator(errorText: 'Invalid email address'.tr),
  ]);
}

MultiValidator passwordValidator() {
  return MultiValidator([
    RequiredValidator(errorText: 'Password is required'.tr),
    MinLengthValidator(6, errorText: 'Password must be at least 6 digits long'.tr),
    MaxLengthValidator(20, errorText: 'Password must not be more than 20 digits long'.tr),
  ]);
}
