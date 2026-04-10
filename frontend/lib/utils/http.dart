import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../providers/user.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class HttpClient {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: 'http://192.168.110.146:10005'),
  );

  static void _handleLogout() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Provider.of<UserProvider>(context, listen: false).logout();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/auth',
        (route) => false,
      );
    }
  }

  static void _showError(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static bool _isInit = false;

  static Dio get instance {
    if (!_isInit) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            final data = response.data;
            final int businessCode = data['code'] ?? 200;
            final String msg = data['msg'] ?? "";

            if (businessCode == 401) {
              _handleLogout();
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  message: msg,
                ),
              );
            }
            if (businessCode == 500) {
              _showError(msg);
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  message: msg,
                  type: DioExceptionType.badResponse,
                ),
              );
            }
            return handler.next(response);
          },
        ),
      );

      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: false,
        ),
      );
      _isInit = true;
    }
    return _dio;
  }
}
