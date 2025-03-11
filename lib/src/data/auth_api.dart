import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<Map<String, dynamic>> login(String  phone, String password) async {
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
      print("Ошибка входа: $e"); // Вывод ошибки в терминал
      return {
        "status": "error",
        "message": "Ошибка входа",
      };
    }
  }
}
