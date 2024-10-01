import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:aliyun_push/aliyun_push.dart';
import 'package:app/Constants/api.dart';
import 'package:app/Controller/chats/chat_controller.dart';
import 'package:app/Data/Local/hive_storage.dart';
import 'package:app/Data/Network/request_client.dart';
import 'package:app/Model/user.dart';
import 'package:app/Services/aliyun_push_notification.dart';
import 'package:app/Utils/comon.dart';
import 'package:app/Utils/logging.dart';
import 'package:app/View/Auth/login.dart';
import 'package:app/View/Landing/landing.dart';
import 'package:app/View/Splash/splash.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:pushy_flutter/pushy_flutter.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  User? user;

  Timer? debounce;
  bool? isEmailAvailable;
  bool? isUsernameAvailable;
  bool? isPhoneAvailable;
  bool isCheckingEmail = false;
  bool isCheckingUsername = false;
  bool isCheckingPhone = false;

  @override
  void onInit() {
    checkAuth();
    super.onInit();
  }
  final AliyunPush aliyunPush = AliyunPush();


  void validateEmail(BuildContext context, String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 100), () async {
      try {
        isCheckingEmail = true;
        isEmailAvailable = null;
        update();
        final response = await NetworkClient.get(
          Apis.emailAvailability,
          queryParameters: {'email': value},
        );
        if (response.statusCode == 200) {
          if (response.data['isAvailable'] == true) {
            isEmailAvailable = true;
          } else {
            isEmailAvailable = false;
          }
        }
      } catch (e) {
        isEmailAvailable = false;
        Get.snackbar("Failed", e.toString());
      } finally {
        isCheckingEmail = false;
        update();
      }
    });
  }

  void validateUserName(BuildContext context, String value) async {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 100), () async {
      try {
        isCheckingUsername = true;
        update();
        isUsernameAvailable = null;
        update();
        final response = await NetworkClient.get(
          Apis.usernameAvailabile,
          queryParameters: {'username': value},
        );
        if (response.statusCode == 200) {
          if (response.data['isAvailable'] == true) {
            isUsernameAvailable = true;
          } else {
            isUsernameAvailable = false;
          }
        }
      } catch (e) {
        isUsernameAvailable = false;
        Get.snackbar("Failed", e.toString());
      } finally {
        isCheckingUsername = false;
        update();
      }
    });
  }

  void phoneAvailability(BuildContext context, String value) async {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 100), () async {
      try {
        isCheckingPhone = true;
        isPhoneAvailable = null;
        update();
        final response = await NetworkClient.get(
          Apis.phoneAvailability,
          queryParameters: {'phone': value},
        );
        if (response.statusCode == 200) {
          if (response.data['isAvailable'] == true) {
            isPhoneAvailable = true;
          } else {
            isPhoneAvailable = false;
          }
        }
      } catch (e) {
        isPhoneAvailable = false;
        Get.snackbar("Failed", e.toString());
      } finally {
        isCheckingPhone = false;
        update();
      }
    });
  }

  Future<void> checkAuth() async {
    try {
      String? accessToken = LocalStorage.getAccessToken;
      log(accessToken.toString());
      if (accessToken != null) {
        final token =  await aliyunPush.initPush(appKey: Apis.aliyueApiKey, appSecret: Apis.aliyueAppSecret).then((value) {
          return value;
        },);
        var response = await NetworkClient.get(Apis.getCurrentUser,
            queryParameters: {"Aliyun_token": token});
        Logger.message(
          'Get Current User Response: ${response.statusCode}, ${jsonEncode(response.data)} :: ${token}',
        );
        if (response.statusCode == 200) {
          await setUser(response.data);
          Get.offAll(() => const LandingView());
        } else {
          log('User could not be found');
          await logout();
        }
      } else {
        log('No access token');
        Get.offAll(() => const LoginView());
      }
    } catch (e) {
      log('Error on Auth check: $e');
      await logout();
    }
  }

  Future<void> setUser(Map<String, dynamic> data) async {
    user = User.fromJson(data);
    String token = data['access_token'];
    update();
    await LocalStorage.setAccessToken(token);
    await LocalStorage.setUserId(user!.id!);
  }

  Future<void> login(BuildContext context,
      {required Map<String, dynamic> data}) async {
    try {
      final token = await aliyunPush.initPush(appKey: Apis.aliyueApiKey, appSecret: Apis.aliyueAppSecret).then((value) {
          return value;
        },);
      var response = await NetworkClient.post(
        Apis.login,
        data: {
          ...data,
          "Aliyun_token": token,
        },
        isTokenRequired: false,
      );
      Logger.message(
          'Login Response: ${response.statusCode}, ${jsonEncode(response.data)}');
      if (response.statusCode == 200) {
        await setUser(response.data);
        Get.offAll(() => const LandingView());
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
    }
  }

  Future<bool> getUserById(BuildContext context, {required String id}) async {
    try {
      var response = await NetworkClient.get('${Apis.getUserById}$id');
      Logger.message(
          'Get User By Id Response: ${response.statusCode}, ${jsonEncode(response.data)}');
      if (response.statusCode == 200) {
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

  Future<void> signUp(
    BuildContext context, {
    required Map<String, dynamic> data,
  }) async {
    try {
      String languageCode = LocalStorage.getLanguageCode;
      String countryCode = LocalStorage.getCountryCode;
      data['local'] = '${languageCode}_$countryCode';
      final token = await aliyunPush.initPush(appKey: Apis.aliyueApiKey, appSecret: Apis.aliyueAppSecret).then((value) {
          return value;
        },);
      var response = await NetworkClient.post(
        Apis.signUp,
        data: {
          ...data,
          "Aliyun_token": token,
        },
        isTokenRequired: false,
      );
      Logger.message(
          'SignUp Response: ${response.statusCode}, ${jsonEncode(response.data)}');
      if (response.statusCode == 200) {
        await setUser(response.data);
        Get.offAll(() => const LandingView());
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
    }
  }

  Future<void> updateUser(
    BuildContext context, {
    required Map<String, dynamic> data,
  }) async {
    try {
      String languageCode = LocalStorage.getLanguageCode;
      String countryCode = LocalStorage.getCountryCode;
      data['local'] = '${languageCode}_$countryCode';
      var response = await NetworkClient.patch(Apis.updateUser, data: data);
      Logger.message(
          'Update User Response: ${response.statusCode}, ${jsonEncode(response.data)}');
      if (response.statusCode == 200) {
        user = User.fromJson(response.data);
        update();
        Get.back();
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
    }
  }

  Future<void> updateHelpStatus(BuildContext context,
      {required bool isHelping}) async {
    try {
      var response = await NetworkClient.put(Apis.updateHelpStatus, data: {
        'isHelping': isHelping,
      });
      Logger.message(
          'Update Help Status Response: ${response.statusCode}, ${jsonEncode(response.data)}');
      if (response.statusCode == 200) {
        user?.isHelping = User.fromJson(response.data).isHelping;
        update();
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
    } catch (e) {
      Logger.message('Error: $e');
      Get.snackbar("Failed", e.toString());
    }
  }

  Future<String> uploadFile(
    BuildContext context, {
    required String file,
    required String path,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file),
        'path': path,
      });
      var response = await NetworkClient.post(
        Apis.uploadFile,
        formData: formData,
      );
      Logger.message(
          'Upload File Response: ${response.statusCode}, ${jsonEncode(response.data)}');
      return response.data['url'];
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
      rethrow;
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
      rethrow;
    }
  }

  Future<void> deleteUser(BuildContext context) async {
    try {
      var response = await NetworkClient.delete(Apis.users);
      Logger.message(
          'Delete User Response: ${response.statusCode}, ${jsonEncode(response.data)}');
      if (response.statusCode == 200) {
        await logout();
      }
    } on DioException catch (e) {
      if (context.mounted) Common.showDioErrorDialog(context, e: e);
    } catch (error) {
      Logger.message('Error: $error');
      Get.snackbar("Failed", error.toString());
    }
  }

  Future<void> logout() async {
    try {
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().disconnectSocket();
      }
      await aliyunPush.unbindAccount();
      await LocalStorage.clearAuth();
      user = null;
      update();

      await Get.deleteAll(force: true).then(
        (value) => log("All routes deleted"),
      );
      Get.offAll(() => const SplashView());
    } catch (e) {
      Logger.message('Logout Error: $e');
    }
  }
}
