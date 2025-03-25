import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://khaledo.pythonanywhere.com/",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  /// ✅ Логин обычного пользователя
  Future<Response<Map<String, dynamic>>?> login(String phone, String password) async {
    return _sendPostRequest("login/", {
      "phone": phone,
      "password": password,
    });
  }

  /// ✅ Логин админа
  Future<Response<Map<String, dynamic>>?> loginAdmin(String phone, String password) async {
    return _sendPostRequest("login/admin/", {
      "phone": phone,
      "password": password,
    });
  }

  /// ✅ Регистрация пользователя
  Future<Response<Map<String, dynamic>>?> register(
      String username, String phone, String password, String passwordConfirm) async {
    return _sendPostRequest("reg/", {
      "first_name": username,
      "phone": phone,
      "password": password,
      "password_confirm": passwordConfirm,
    });
  }

  /// ✅ Регистрация админа
  Future<Response<Map<String, dynamic>>?> registerAdmin(
      String name, String phone, String password, String passwordConfirm) async {
    return _sendPostRequest("reg/admin/", {
      "first_name": name,
      "phone": phone,
      "password": password,
      "password_confirm": passwordConfirm,
    });
  }

  /// 🔥 Вынес базовый POST-запрос в отдельную функцию
  Future<Response<Map<String, dynamic>>?> _sendPostRequest(String path, Map<String, dynamic> data) async {
    try {
      Response<Map<String, dynamic>> response = await _dio.post(path, data: data);
      return response; // ✅ Теперь возвращаем Response
    } on DioException catch (e) {
      print("Ошибка запроса: ${e.response?.data ?? e.message}");
      return null; // ✅ Вернем null в случае ошибки
    }
  }
}
