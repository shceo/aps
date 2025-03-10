import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/",  
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      Response response = await _dio.post(
        "api_login/",  
        data: {"username": username, "password": password},
      );

      print("Login successful: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      print("Dio error: ${e.response?.data ?? e.message}");
      return {
        "status": "error",
        "message": e.response?.data["message"] ?? "Login failed"
      };
    } catch (e) {
      print("Unexpected error: $e");
      return {"status": "error", "message": "Something went wrong"};
    }
  }
}
