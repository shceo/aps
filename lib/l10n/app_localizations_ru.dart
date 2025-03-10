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
}
