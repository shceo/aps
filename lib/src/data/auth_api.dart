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
    return _sendPostRequest("login/", {"phone": phone, "password": password});
  }

  /// ✅ Логин админа
  Future<Response<Map<String, dynamic>>?> loginAdmin(String phone, String password) async {
    return _sendPostRequest("login/admin/", {"phone": phone, "password": password});
  }

  /// ✅ Регистрация (с OTP)
  ///
  /// Если поле code пустое, сервер отправит SMS с OTP и вернет сообщение об этом.
  /// Если code заполнено и корректно, регистрация завершится успешно.
  /// В случае ошибки (например, неверного OTP) сервер возвращает ответ с полем error.
  Future<Response<Map<String, dynamic>>?> registerWithOtp(
    String firstName,
    String phone, 
    String password,
    String passwordConfirm,
    String code,
  ) async {
    return _sendPostRequest("reg/", {
      "first_name": firstName,
      "phone_number": phone,
      "password": password,
      "password_confirm": passwordConfirm,
      "code": code,
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

  /// 🔥 Базовый POST-запрос с обработкой ошибок
  Future<Response<Map<String, dynamic>>?> _sendPostRequest(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      Response<Map<String, dynamic>> response = await _dio.post(
        path,
        data: data,
      );
      return response;
    } on DioException catch (e) {
      String errorMsg = "Ошибка запроса";
      
      if (e.response?.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = e.response!.data;
        if (responseData.containsKey('error')) {
          String errorCode = responseData['error'];
          Map<String, String>? params;

          if (responseData.containsKey('username')) {
            params = {"username": responseData['username'].toString()};
          } else if (responseData.containsKey('error_detail')) {
            params = {"error": responseData['error_detail'].toString()};
          }
          
          errorMsg = _formatErrorMessage(errorCode, params);
        }
      } else {
        errorMsg = "Неверный формат ответа";
      }
      
      print("Ошибка запроса: $errorMsg");
      return null;
    }
  }

  /// Метод для форматирования сообщения об ошибке по коду ошибки.
  ///
  /// Здесь перечислены возможные тексты ошибок, которые могут быть возвращены сервером.
  /// При необходимости добавьте или измените сообщения.
  String _formatErrorMessage(String errorCode, Map<String, String>? params) {
    final Map<String, String> errorMessages = {
      // Ошибки для логина (login)
      "already_authenticated_user": "You are already authenticated as {username}",
      "missing_credentials": "Phone number and password are required",
      "user_not_found": "User not found",
      "invalid_credentials": "Invalid phone number or password",
      "invalid_json": "Invalid JSON format",
      "method_not_allowed": "Only POST requests are allowed",
      "login_success": "Login successful",
      // Ошибки для логина админа (login_admin)
      "already_authenticated_admin": "You are already authenticated as {username}",
      "admin_not_found": "User not found",
      // Ошибки для регистрации (registration)
      "already_authenticated": "User is already logged in.",
      "invalid_phone_format": "Invalid Uzbek phone number format. Example: +998971233322.",
      "phone_already_registered": "This phone number is already registered. Please log in.",
      "verification_sent": "Verification code sent successfully.",
      "verification_code_expired": "Verification code expired.",
      "session_expired": "Your session has expired. Please register again.",
      "invalid_otp": "Invalid OTP.",
      "registration_success": "User registered successfully!",
      // Ошибки для регистрации админа (admin_registration)
      "missing_fields": "Please enter all required fields",
      "password_mismatch": "Passwords do not match",
      "phone_registered": "Phone number is already registered",
      "authentication_failed": "Authentication failed after registration",
      "database_error": "Error occurred while saving to the database: {error}",
      "invalid_json_format": "Invalid JSON format",
      "registration_successful": "Registration successful"
    };

    String message = errorMessages[errorCode] ?? "Unknown error";
    if (params != null) {
      params.forEach((key, value) {
        message = message.replaceAll('{$key}', value);
      });
    }
    return message;
  }
}
