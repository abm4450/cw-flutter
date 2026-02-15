import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'The fastest, cleanest, smartest wash in town.'**
  String get tagline;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Customer Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'New Membership'**
  String get register;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin Portal'**
  String get admin;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobile;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @plate.
  ///
  /// In en, this message translates to:
  /// **'Car Plate Number'**
  String get plate;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get submit;

  /// No description provided for @myCard.
  ///
  /// In en, this message translates to:
  /// **'My Membership Card'**
  String get myCard;

  /// No description provided for @washCounter.
  ///
  /// In en, this message translates to:
  /// **'Wash Progress'**
  String get washCounter;

  /// No description provided for @progressMsg.
  ///
  /// In en, this message translates to:
  /// **'Remaining for your gift..'**
  String get progressMsg;

  /// No description provided for @freeNextMsg.
  ///
  /// In en, this message translates to:
  /// **'Your next wash is on us'**
  String get freeNextMsg;

  /// No description provided for @scanned.
  ///
  /// In en, this message translates to:
  /// **'Scan complete!'**
  String get scanned;

  /// No description provided for @totalWashes.
  ///
  /// In en, this message translates to:
  /// **'Total Washes'**
  String get totalWashes;

  /// No description provided for @memberId.
  ///
  /// In en, this message translates to:
  /// **'Member ID'**
  String get memberId;

  /// No description provided for @registerWash.
  ///
  /// In en, this message translates to:
  /// **'Register New Wash'**
  String get registerWash;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Control Center'**
  String get adminDashboard;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Quick Scan'**
  String get scanBarcode;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// No description provided for @totalMembers.
  ///
  /// In en, this message translates to:
  /// **'Total Members'**
  String get totalMembers;

  /// No description provided for @freeWashAlert.
  ///
  /// In en, this message translates to:
  /// **'CONGRATULATIONS! This wash is FREE!'**
  String get freeWashAlert;

  /// No description provided for @paidWashAlert.
  ///
  /// In en, this message translates to:
  /// **'Paid wash registered successfully.'**
  String get paidWashAlert;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'Smart Business Assistant'**
  String get aiInsights;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hello;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members Directory'**
  String get members;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get activity;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name or plate...'**
  String get searchPlaceholder;

  /// No description provided for @noMembers.
  ///
  /// In en, this message translates to:
  /// **'No members found.'**
  String get noMembers;

  /// No description provided for @exclusiveMember.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Member'**
  String get exclusiveMember;

  /// No description provided for @level1.
  ///
  /// In en, this message translates to:
  /// **'Level 1'**
  String get level1;

  /// No description provided for @plateNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get plateNumberLabel;

  /// No description provided for @pointsEarned.
  ///
  /// In en, this message translates to:
  /// **'Points Earned'**
  String get pointsEarned;

  /// No description provided for @scanAtCounter.
  ///
  /// In en, this message translates to:
  /// **'Scan at counter'**
  String get scanAtCounter;

  /// No description provided for @verifiedId.
  ///
  /// In en, this message translates to:
  /// **'Verified ID'**
  String get verifiedId;

  /// No description provided for @washHistory.
  ///
  /// In en, this message translates to:
  /// **'Wash History'**
  String get washHistory;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history recorded yet.'**
  String get noHistory;

  /// No description provided for @paidStatus.
  ///
  /// In en, this message translates to:
  /// **'Paid Wash'**
  String get paidStatus;

  /// No description provided for @freeStatus.
  ///
  /// In en, this message translates to:
  /// **'Free Reward'**
  String get freeStatus;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Business Data...'**
  String get analyzing;

  /// No description provided for @quietDay.
  ///
  /// In en, this message translates to:
  /// **'Quiet Day So Far'**
  String get quietDay;

  /// No description provided for @activityModal.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityModal;

  /// No description provided for @statusModal.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusModal;

  /// No description provided for @nextFree.
  ///
  /// In en, this message translates to:
  /// **'NEXT FREE'**
  String get nextFree;

  /// No description provided for @redeemReward.
  ///
  /// In en, this message translates to:
  /// **'Redeem Reward'**
  String get redeemReward;

  /// No description provided for @washesCount.
  ///
  /// In en, this message translates to:
  /// **'Washes'**
  String get washesCount;

  /// No description provided for @gift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get gift;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @secretKey.
  ///
  /// In en, this message translates to:
  /// **'Secret Key'**
  String get secretKey;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get hasAccount;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get registerNow;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmScan.
  ///
  /// In en, this message translates to:
  /// **'Confirm Scan'**
  String get confirmScan;

  /// No description provided for @undoWash.
  ///
  /// In en, this message translates to:
  /// **'Undo Last Wash'**
  String get undoWash;

  /// No description provided for @undoSuccess.
  ///
  /// In en, this message translates to:
  /// **'Last wash undone'**
  String get undoSuccess;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @editMember.
  ///
  /// In en, this message translates to:
  /// **'Edit Member'**
  String get editMember;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this member?'**
  String get deleteConfirm;

  /// No description provided for @giftsReady.
  ///
  /// In en, this message translates to:
  /// **'Gifts Ready'**
  String get giftsReady;

  /// No description provided for @lastWash.
  ///
  /// In en, this message translates to:
  /// **'Last wash'**
  String get lastWash;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get filterGifts;

  /// No description provided for @filterNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get filterNew;

  /// No description provided for @filterInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get filterInactive;

  /// No description provided for @filterPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get filterPaid;

  /// No description provided for @filterFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get filterFree;

  /// No description provided for @sortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get sortRecent;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortWashes.
  ///
  /// In en, this message translates to:
  /// **'Washes'**
  String get sortWashes;

  /// No description provided for @topMember.
  ///
  /// In en, this message translates to:
  /// **'Top member'**
  String get topMember;

  /// No description provided for @quickFilters.
  ///
  /// In en, this message translates to:
  /// **'Quick filters'**
  String get quickFilters;

  /// No description provided for @clearActivity.
  ///
  /// In en, this message translates to:
  /// **'Clear activity'**
  String get clearActivity;

  /// No description provided for @clearActivityConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear recent activity?'**
  String get clearActivityConfirm;

  /// No description provided for @cleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get cleared;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Washing Circle'**
  String get appName;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
