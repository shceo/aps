import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://khaledo.pythonanywhere.com/",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      Response response = await _dio.post(
        "login/", 
        data: {
          "phone": phone,
          "password": password,
        },
      );

      return response.data;
    } catch (e) {
      print("Ошибка входа: $e");
      return {
        "status": "error",
        "message": "Ошибка входа",
      };
    }
  }

  Future<Map<String, dynamic>> register(
      String username, String phone, String password, String passwordConfirm) async {
    try {
      Response response = await _dio.post(
        "reg/", 
        data: {
          "first_name": username,
          "phone": phone,
          "password": password,
          "password_confirm": passwordConfirm,
        },
      );

      return response.data;
    } catch (e) {
      print("Ошибка регистрации: $e");
      return {
        "status": "error",
        "message": "Ошибка регистрации",
      };
    }
  }
}
