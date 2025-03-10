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
  String get email => 'Эл. почта';

  @override
  String get password => 'Пароль';

  @override
  String get remember_me => 'Запомнить меня, ЗАБЫЛИ ПАРОЛЬ';

  @override
  String get log_in => 'Войти';

  @override
  String get register => 'Нет аккаунта? РЕГИСТРАЦИЯ';

  @override
  String get customer => 'Заказчик';

  @override
  String get recipient => 'Получатель';

  @override
  String get phone => 'Телефон';

  @override
  String get email_hint => 'Введите email';

  @override
  String get phone_hint => 'Введите номер телефона';

  @override
  String get password_hint => 'Введите пароль';
}
