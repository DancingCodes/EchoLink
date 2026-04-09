import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/user_provider.dart';

class HttpClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:10005', // 模拟器用 10.0.2.2，真机用局域网 IP
      connectTimeout: const Duration(seconds: 5),
    ),
  );

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
            final int code = response.data['code'];
            if (code == 401) {
              // 登录失效逻辑
              final context = navigatorKey.currentContext;
              if (context != null) {
                Provider.of<UserProvider>(context, listen: false).logout();
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  '/auth',
                  (route) => false,
                );
              }
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  message: "登录过期",
                ),
              );
            }
            return handler.next(response);
          },
        ),
      );
      _isInit = true;
    }
    return _dio;
  }
}
