import 'package:app/Constants/api.dart';
import 'package:app/Data/Network/request_client.dart';
import 'package:app/Model/Help/help_model.dart';
import 'package:app/Utils/logging.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../Utils/comon.dart';

class HelpMessagesController extends GetxController {
  List<HelpMessage> allMessages = [];
  String? errorMsg;
  bool isLoading = true;
  // bool isLoadingMore = false;
  // bool isLastData = false;
  // int page = 0;
  // int pageSize = 100;

  @override
  void onInit() {
    getMessages();
    super.onInit();
  }

  Future<void> getMessages() async {
    try {
      isLoading = true;
      update();
      final response = await NetworkClient.get('${Apis.getHelpMessages}/${Get.arguments}');
      Logger.message("Get Help Messages: ${response.statusCode}");
      Logger.message("Get Help Messages: ${response.data}");

      if (response.statusCode == 200) {
        allMessages = (response.data as List)
            .map((e) => HelpMessage.fromJson(e))
            .toList();
      }
    } on DioException catch (e) {
      errorMsg = Common.getErrorMsgOfDio(e);
      Logger.error(errorMsg!);
    } catch (e) {
      errorMsg = e.toString();
      Logger.error("-get-help-messages- Error: $errorMsg");
    } finally {
      isLoading = false;
      update();
    }
  }
}
