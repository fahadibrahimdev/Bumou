import 'package:dio/dio.dart';

import '../Local/hive_storage.dart';

class NetworkClient {
  static final NetworkClient _singleton = NetworkClient._internal();
  factory NetworkClient() => _singleton;
  NetworkClient._internal();

  static final Dio dio = Dio();

  static Future<Response> get(String url, {Map<String, dynamic>? queryParameters, bool isTokenRequired = true}) async {
    return await dio.get(
      url,
      queryParameters: queryParameters,
      options: Options(
        headers: headers(isTokenRequired: isTokenRequired),
      ),
    );
  }

  static Future<Response> post(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
    bool isTokenRequired = true,
    Map<String, dynamic>? header,
  }) async {
    if (header != null) {
      header.addAll(headers(isTokenRequired: isTokenRequired));
    } else {
      header = headers(isTokenRequired: isTokenRequired);
    }
    return await dio.post(
      url,
      data: data ?? formData,
      options: Options(
        headers: header,
      ),
    );
  }

  static Future<Response> put(String url, {Map<String, dynamic>? data, bool isTokenRequired = true}) async {
    return await dio.put(
      url,
      data: data,
      options: Options(
        headers: headers(isTokenRequired: isTokenRequired),
      ),
    );
  }

  static Future<Response> patch(String url, {Map<String, dynamic>? data, bool isTokenRequired = true}) async {
    return await dio.patch(
      url,
      data: data,
      options: Options(
        headers: headers(isTokenRequired: isTokenRequired),
      ),
    );
  }

  static Future<Response> delete(String url, {Map<String, dynamic>? data, bool isTokenRequired = true}) async {
    return await dio.delete(
      url,
      data: data,
      options: Options(
        headers: headers(isTokenRequired: isTokenRequired),
      ),
    );
  }

  static Map<String, dynamic> headers({bool isTokenRequired = true}) {
    String languageCode = LocalStorage.getLanguageCode;
    String countryCode = LocalStorage.getCountryCode;
    Map<String, dynamic> header = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "x-lang": "${languageCode}_$countryCode",
    };
    String? accessToken = LocalStorage.getAccessToken;
    if (isTokenRequired && accessToken != null) {
      header["Authorization"] = "Bearer $accessToken";
    }
    return header;
  }
}
