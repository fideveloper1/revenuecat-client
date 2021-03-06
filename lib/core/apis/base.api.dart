import 'package:app/core/models/api_error.model.dart';
import 'package:app/core/models/hive/session.model.dart';
import 'package:app/core/utils/logger.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:either_option/either_option.dart';
import 'package:get/get.dart';

final logger = initLogger('BaseAPI');

class BaseAPI extends GetxController {
  Map<String, String> get baseHeaders => {
        'Authorization': Session.token,
        'X-Requested-With': 'XMLHttpRequest',
      };

  Map<String, String> get baseParams => {};

  Future<Either<ApiError, Map<String, dynamic>>> baseRequest({
    final String function,
    final Map<String, dynamic> params,
    final Map<String, String> headers,
    final String url,
    final int timeout = 15000,
    final bool debug = false,
    final String method = 'GET',
  }) async {
    final _dio = Dio(BaseOptions(
      headers: headers,
      method: method,
      responseType: ResponseType.json,
      contentType: 'application/json',
      connectTimeout: timeout,
      receiveTimeout: timeout,
    ));

    Response<Map<String, dynamic>> response;

    try {
      if (method == 'GET') {
        response = await _dio.get(url, queryParameters: params);
      } else if (method == 'POST') {
        response = await _dio.post(url, data: params);
      }

      if (debug) {
        logger.i('HTTP STATUS: ${response.statusCode}');
        logger.i(response.data);
      }

      return Right(response.data);
    } on DioError catch (e) {
      logger.e(
          'dio error. function: $function, error: ${e.error}, data: ${e.response.data}');
      if (e.response.data != null) {
        return Left(ApiError.fromJson(e.response.data));
      }

      return Left(
        ApiError(
          code: 1,
          message:
              'Status: ${e.response.statusCode}, Error: ${e.error}, Data: ${e.response.data}',
        ),
      );
    } catch (e) {
      logger.e('network error. function: $function, error: $e');
      return Left(ApiError(code: 0, message: '$e'));
    }
  }

  Future<bool> internetConnected() async {
    return await Connectivity().checkConnectivity() != ConnectivityResult.none;
  }
}
