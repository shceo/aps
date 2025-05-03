import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uz.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
    Locale('uz'),
    Locale('zh')
  ];

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get register;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @log_in.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get log_in;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get already_have_account;

  /// No description provided for @dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get dont_have_account;

  /// No description provided for @phone_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get phone_hint;

  /// No description provided for @password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get password_hint;

  /// No description provided for @confirm_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get confirm_password_hint;

  /// No description provided for @name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get name_hint;

  /// No description provided for @cargo_system.
  ///
  /// In en, this message translates to:
  /// **'Cargo System'**
  String get cargo_system;

  /// No description provided for @cargo.
  ///
  /// In en, this message translates to:
  /// **'Cargo'**
  String get cargo;

  /// No description provided for @contractors.
  ///
  /// In en, this message translates to:
  /// **'Contractors'**
  String get contractors;

  /// No description provided for @accounting.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get accounting;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @setup.
  ///
  /// In en, this message translates to:
  /// **'Info & Setup'**
  String get setup;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @flights.
  ///
  /// In en, this message translates to:
  /// **'Flights'**
  String get flights;

  /// No description provided for @flight_plan.
  ///
  /// In en, this message translates to:
  /// **'Flight Plan'**
  String get flight_plan;

  /// No description provided for @plane_layout.
  ///
  /// In en, this message translates to:
  /// **'Plane Layout'**
  String get plane_layout;

  /// No description provided for @payload_info.
  ///
  /// In en, this message translates to:
  /// **'Payload Info'**
  String get payload_info;

  /// No description provided for @enter_order_code.
  ///
  /// In en, this message translates to:
  /// **'Enter Order Code'**
  String get enter_order_code;

  /// No description provided for @order_code_hint.
  ///
  /// In en, this message translates to:
  /// **'For example, 1234'**
  String get order_code_hint;

  /// No description provided for @confirm_order_code.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm_order_code;

  /// No description provided for @invalid_order_code.
  ///
  /// In en, this message translates to:
  /// **'Invalid order code'**
  String get invalid_order_code;

  /// No description provided for @invalid_order_code_des.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get invalid_order_code_des;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @reset_order_code_title.
  ///
  /// In en, this message translates to:
  /// **'Reset Order Code'**
  String get reset_order_code_title;

  /// No description provided for @reset_order_code_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the order code?'**
  String get reset_order_code_message;

  /// No description provided for @reset_order_code_button.
  ///
  /// In en, this message translates to:
  /// **'Reset Order Code'**
  String get reset_order_code_button;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @deleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Confirmation'**
  String get deleteConfirmationTitle;

  /// No description provided for @deleteConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteConfirmationContent;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @orderNo.
  ///
  /// In en, this message translates to:
  /// **'Order No.'**
  String get orderNo;

  /// No description provided for @addInvoice.
  ///
  /// In en, this message translates to:
  /// **'Add Invoice'**
  String get addInvoice;

  /// No description provided for @noAdminsWithContainers.
  ///
  /// In en, this message translates to:
  /// **'No admins with containers'**
  String get noAdminsWithContainers;

  /// No description provided for @emailPrefix.
  ///
  /// In en, this message translates to:
  /// **'📧'**
  String get emailPrefix;

  /// No description provided for @addNewContainer.
  ///
  /// In en, this message translates to:
  /// **'Add New Container'**
  String get addNewContainer;

  /// No description provided for @welcomeToAdminPanel.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Admin Panel!'**
  String get welcomeToAdminPanel;

  /// No description provided for @adminPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanelTitle;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @addNewEmail.
  ///
  /// In en, this message translates to:
  /// **'Add New Email'**
  String get addNewEmail;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @uzbek.
  ///
  /// In en, this message translates to:
  /// **'O\'zbek'**
  String get uzbek;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @serverTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Server time'**
  String get serverTimeLabel;

  /// No description provided for @overLimitError.
  ///
  /// In en, this message translates to:
  /// **'Order exceeds the \$1000 limit'**
  String get overLimitError;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @fieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get fieldsRequired;

  /// No description provided for @chooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose a city'**
  String get chooseCity;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Save error'**
  String get saveError;

  /// No description provided for @successMessage.
  ///
  /// In en, this message translates to:
  /// **'Data saved successfully!'**
  String get successMessage;

  /// No description provided for @closeToLimit.
  ///
  /// In en, this message translates to:
  /// **'You are close to the \$1000 limit'**
  String get closeToLimit;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successTitle;

  /// No description provided for @warningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningTitle;

  /// No description provided for @digitsOnlyError.
  ///
  /// In en, this message translates to:
  /// **'Only digits are allowed'**
  String get digitsOnlyError;

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoice;

  /// No description provided for @selectedSection.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selectedSection;

  /// No description provided for @orderCode.
  ///
  /// In en, this message translates to:
  /// **'Order Code'**
  String get orderCode;

  /// No description provided for @senderName.
  ///
  /// In en, this message translates to:
  /// **'Sender Name'**
  String get senderName;

  /// No description provided for @senderTel.
  ///
  /// In en, this message translates to:
  /// **'Sender Phone'**
  String get senderTel;

  /// No description provided for @receiverName.
  ///
  /// In en, this message translates to:
  /// **'Receiver Name'**
  String get receiverName;

  /// No description provided for @receiverTel.
  ///
  /// In en, this message translates to:
  /// **'Receiver Phone'**
  String get receiverTel;

  /// No description provided for @passportId.
  ///
  /// In en, this message translates to:
  /// **'Passport/ID'**
  String get passportId;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @addressFull.
  ///
  /// In en, this message translates to:
  /// **'Address (full)'**
  String get addressFull;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter address or choose city'**
  String get addressHint;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @bruttoWeight.
  ///
  /// In en, this message translates to:
  /// **'Brutto Weight (kg)'**
  String get bruttoWeight;

  /// No description provided for @totalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Value (USD)'**
  String get totalValue;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @doorToDoor.
  ///
  /// In en, this message translates to:
  /// **'Door to Door'**
  String get doorToDoor;

  /// No description provided for @zone2.
  ///
  /// In en, this message translates to:
  /// **'ZONE 2'**
  String get zone2;

  /// No description provided for @pvzLabel.
  ///
  /// In en, this message translates to:
  /// **'PVZ [SPB33] on Zvezdnaya'**
  String get pvzLabel;

  /// No description provided for @generateFirst.
  ///
  /// In en, this message translates to:
  /// **'Generate code first'**
  String get generateFirst;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @unsavedDataWarning.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Leave?'**
  String get unsavedDataWarning;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @monthlyLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit of \$200 exceeded'**
  String get monthlyLimitExceeded;

  /// No description provided for @noPassportError.
  ///
  /// In en, this message translates to:
  /// **'Cannot add new container: passport not filled'**
  String get noPassportError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru', 'tr', 'uz', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
    case 'tr': return AppLocalizationsTr();
    case 'uz': return AppLocalizationsUz();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
