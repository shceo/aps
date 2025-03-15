// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get login => 'Вход';

  @override
  String get register => 'Регистрация';

  @override
  String get phone => 'Телефон';

  @override
  String get password => 'Пароль';

  @override
  String get confirm_password => 'Подтвердите пароль';

  @override
  String get name => 'Имя';

  @override
  String get log_in => 'Войти';

  @override
  String get sign_up => 'Зарегистрироваться';

  @override
  String get already_have_account => 'Уже есть аккаунт? Войти';

  @override
  String get dont_have_account => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get phone_hint => 'Введите номер телефона';

  @override
  String get password_hint => 'Введите пароль';

  @override
  String get confirm_password_hint => 'Повторите пароль';

  @override
  String get name_hint => 'Введите ваше имя';

  @override
  String get cargo_system => 'Грузовая система';

  @override
  String get cargo => 'Груз';

  @override
  String get contractors => 'Подрядчики';

  @override
  String get accounting => 'Бухгалтерия';

  @override
  String get reports => 'Отчеты';

  @override
  String get setup => 'Настройки и информация';

  @override
  String get settings => 'Настройки';

  @override
  String get flights => 'Рейсы';

  @override
  String get flight_plan => 'План полета';

  @override
  String get plane_layout => 'Схема самолета';

  @override
  String get payload_info => 'Информация о грузе';

  @override
  String get enter_order_code => 'Введите код заказа';

  @override
  String get order_code_hint => 'Например, 1234';

  @override
  String get confirm_order_code => 'Подтвердить';

  @override
  String get invalid_order_code => 'Неверный код заказа';

  @override
  String get details => 'Подробнее';

  @override
  String get shop => 'Магазин';

  @override
  String get profile => 'Профиль';
}
