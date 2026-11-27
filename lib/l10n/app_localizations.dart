import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Asatiza'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabTeachers.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get tabTeachers;

  /// No description provided for @tabChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get tabChats;

  /// No description provided for @tabAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get tabAlerts;

  /// No description provided for @createPostAction.
  ///
  /// In en, this message translates to:
  /// **'Create post'**
  String get createPostAction;

  /// No description provided for @teachersTitle.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get teachersTitle;

  /// No description provided for @chatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @newPostTitle.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get newPostTitle;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @backAction.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backAction;

  /// No description provided for @logoLabel.
  ///
  /// In en, this message translates to:
  /// **'Asatiza logo'**
  String get logoLabel;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loadingLabel;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Find Quran teachers & students'**
  String get splashTagline;

  /// No description provided for @skipAction.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipAction;

  /// No description provided for @welcomeTitle1.
  ///
  /// In en, this message translates to:
  /// **'Learn the Quran with the right teacher'**
  String get welcomeTitle1;

  /// No description provided for @welcomeMessage1.
  ///
  /// In en, this message translates to:
  /// **'Find verified Tajweed, Hifz and Nazra teachers who match your language, time zone and goals.'**
  String get welcomeMessage1;

  /// No description provided for @welcomeTitle2.
  ///
  /// In en, this message translates to:
  /// **'Connect with verified teachers'**
  String get welcomeTitle2;

  /// No description provided for @welcomeMessage2.
  ///
  /// In en, this message translates to:
  /// **'Send a request with a short note. Once a teacher accepts, you can chat safely in a moderated community.'**
  String get welcomeMessage2;

  /// No description provided for @welcomeTitle3.
  ///
  /// In en, this message translates to:
  /// **'Share and grow together'**
  String get welcomeTitle3;

  /// No description provided for @welcomeMessage3.
  ///
  /// In en, this message translates to:
  /// **'Post Islamic reminders, Tajweed tips and your Hifz achievements, and learn from teachers you follow.'**
  String get welcomeMessage3;

  /// No description provided for @slideOf.
  ///
  /// In en, this message translates to:
  /// **'Slide {current} of {total}'**
  String slideOf(int current, int total);

  /// No description provided for @createAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountAction;

  /// No description provided for @haveAccountAction.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get haveAccountAction;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join teachers and students learning the Quran together.'**
  String get signUpSubtitle;

  /// No description provided for @iAmA.
  ///
  /// In en, this message translates to:
  /// **'I am a'**
  String get iAmA;

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

  /// No description provided for @roleStudentDescription.
  ///
  /// In en, this message translates to:
  /// **'I want to learn, or I’m signing up my child'**
  String get roleStudentDescription;

  /// No description provided for @roleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get roleTeacher;

  /// No description provided for @roleTeacherDescription.
  ///
  /// In en, this message translates to:
  /// **'I teach the Quran'**
  String get roleTeacherDescription;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @showPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPasswordAction;

  /// No description provided for @hidePasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePasswordAction;

  /// No description provided for @passwordRuleLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordRuleLength;

  /// No description provided for @passwordRuleMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get passwordRuleMatch;

  /// No description provided for @consentPrefix.
  ///
  /// In en, this message translates to:
  /// **'I am 18 or older and agree to the '**
  String get consentPrefix;

  /// No description provided for @termsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get termsLink;

  /// No description provided for @consentAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get consentAnd;

  /// No description provided for @privacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyLink;

  /// No description provided for @consentSuffix.
  ///
  /// In en, this message translates to:
  /// **'. Parents may sign up for their child.'**
  String get consentSuffix;

  /// No description provided for @haveAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccountQuestion;

  /// No description provided for @logInAction.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logInAction;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get errorInvalidEmail;

  /// No description provided for @errorEmailRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email already has an account. Log in instead.'**
  String get errorEmailRegistered;

  /// No description provided for @errorWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is not correct'**
  String get errorWrongCredentials;

  /// No description provided for @errorInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'That code didn’t work. Check it and try again.'**
  String get errorInvalidCode;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check it and try again.'**
  String get errorNoConnection;

  /// No description provided for @errorSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again in a moment.'**
  String get errorSomethingWentWrong;

  /// No description provided for @errorSamePassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password, not the one you used before.'**
  String get errorSamePassword;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'This password is too weak. Try a longer one with letters and numbers.'**
  String get errorWeakPassword;

  /// No description provided for @checkEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkEmailTitle;

  /// No description provided for @codeSentPrefix.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to '**
  String get codeSentPrefix;

  /// No description provided for @codeSentSuffix.
  ///
  /// In en, this message translates to:
  /// **'. Enter it below.'**
  String get codeSentSuffix;

  /// No description provided for @resetCodeSentPrefix.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for '**
  String get resetCodeSentPrefix;

  /// No description provided for @resetCodeSentSuffix.
  ///
  /// In en, this message translates to:
  /// **', we’ve sent a 6-digit code. Check your Spam folder too.'**
  String get resetCodeSentSuffix;

  /// No description provided for @codeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get codeFieldLabel;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in '**
  String get resendCodeIn;

  /// No description provided for @resendCodeAction.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCodeAction;

  /// No description provided for @wrongEmailAction.
  ///
  /// In en, this message translates to:
  /// **'Wrong email? Change it'**
  String get wrongEmailAction;

  /// No description provided for @spamFolderNote.
  ///
  /// In en, this message translates to:
  /// **'Can’t find it? Check your Spam or Promotions folder. The code is valid for 10 minutes.'**
  String get spamFolderNote;

  /// No description provided for @verifyAction.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyAction;

  /// No description provided for @logInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get logInTitle;

  /// No description provided for @logInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assalamu alaikum! Log in to continue.'**
  String get logInSubtitle;

  /// No description provided for @forgotPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordAction;

  /// No description provided for @newToAsatiza.
  ///
  /// In en, this message translates to:
  /// **'New to Asatiza? '**
  String get newToAsatiza;

  /// No description provided for @resetStepEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get resetStepEmail;

  /// No description provided for @resetStepCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get resetStepCode;

  /// No description provided for @resetStepNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get resetStepNewPassword;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email you signed up with. We’ll send you a 6-digit code.'**
  String get resetSubtitle;

  /// No description provided for @sendCodeAction.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeAction;

  /// No description provided for @enterCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get enterCodeTitle;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new password'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose something you haven’t used before.'**
  String get newPasswordSubtitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @saveAndLogInAction.
  ///
  /// In en, this message translates to:
  /// **'Save and log in'**
  String get saveAndLogInAction;

  /// No description provided for @setupStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String setupStepOf(int step, int total);

  /// No description provided for @teacherSetupTitle1.
  ///
  /// In en, this message translates to:
  /// **'Let students see who you are'**
  String get teacherSetupTitle1;

  /// No description provided for @teacherSetupTitle2.
  ///
  /// In en, this message translates to:
  /// **'What do you teach?'**
  String get teacherSetupTitle2;

  /// No description provided for @teacherSetupTitle3.
  ///
  /// In en, this message translates to:
  /// **'Your classes and fee'**
  String get teacherSetupTitle3;

  /// No description provided for @addProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a profile photo'**
  String get addProfilePhoto;

  /// No description provided for @teacherPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'A clear, modest photo builds trust with parents and students.'**
  String get teacherPhotoHint;

  /// No description provided for @headlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Headline'**
  String get headlineLabel;

  /// No description provided for @headlineHint.
  ///
  /// In en, this message translates to:
  /// **'Shown under your name everywhere. 60 characters max.'**
  String get headlineHint;

  /// No description provided for @subjectsLabel.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjectsLabel;

  /// No description provided for @teachingLanguagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Languages you teach in'**
  String get teachingLanguagesLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @timeZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get timeZoneLabel;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// No description provided for @experienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience (years)'**
  String get experienceLabel;

  /// No description provided for @feeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee ({currency})'**
  String feeLabel(String currency);

  /// No description provided for @availableDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Available days'**
  String get availableDaysLabel;

  /// No description provided for @uploadCertificatesAction.
  ///
  /// In en, this message translates to:
  /// **'Upload certificate'**
  String get uploadCertificatesAction;

  /// No description provided for @uploadCertificatesHint.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get uploadCertificatesHint;

  /// No description provided for @certificatesAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 certificate added} other{{count} certificates added}}'**
  String certificatesAdded(int count);

  /// No description provided for @finishSetupAction.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get finishSetupAction;

  /// No description provided for @studentSetupTitle1.
  ///
  /// In en, this message translates to:
  /// **'Tell us about the learner'**
  String get studentSetupTitle1;

  /// No description provided for @addPhotoOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a photo (optional)'**
  String get addPhotoOptional;

  /// No description provided for @studentPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Your photo is never shown in the Students list. Teachers see it only on your profile.'**
  String get studentPhotoHint;

  /// No description provided for @learnerAgeGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Learner age group'**
  String get learnerAgeGroupLabel;

  /// No description provided for @parentSetupNote.
  ///
  /// In en, this message translates to:
  /// **'Setting up for your child? Choose Child. You keep the account and see every chat with their teacher.'**
  String get parentSetupNote;

  /// No description provided for @studentSetupTitle2.
  ///
  /// In en, this message translates to:
  /// **'What would you like to learn?'**
  String get studentSetupTitle2;

  /// No description provided for @currentLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Current level'**
  String get currentLevelLabel;

  /// No description provided for @languagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languagesLabel;

  /// No description provided for @studentSetupTitle3.
  ///
  /// In en, this message translates to:
  /// **'Your ideal teacher'**
  String get studentSetupTitle3;

  /// No description provided for @preferredTeacherGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred teacher gender'**
  String get preferredTeacherGenderLabel;

  /// No description provided for @lookingForTeacherLabel.
  ///
  /// In en, this message translates to:
  /// **'Looking for a teacher'**
  String get lookingForTeacherLabel;

  /// No description provided for @lookingForTeacherHint.
  ///
  /// In en, this message translates to:
  /// **'Shows teachers that you\'re looking for a teacher now.'**
  String get lookingForTeacherHint;

  /// No description provided for @shortNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Short note (optional)'**
  String get shortNoteLabel;

  /// No description provided for @shortNotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'For example: evenings after 6 pm work best for me.'**
  String get shortNotePlaceholder;

  /// No description provided for @characterCounter.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max}'**
  String characterCounter(int count, int max);

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get genderAny;

  /// No description provided for @subjectNooraniQaida.
  ///
  /// In en, this message translates to:
  /// **'Noorani Qaida'**
  String get subjectNooraniQaida;

  /// No description provided for @subjectNazra.
  ///
  /// In en, this message translates to:
  /// **'Nazra'**
  String get subjectNazra;

  /// No description provided for @subjectTajweed.
  ///
  /// In en, this message translates to:
  /// **'Tajweed'**
  String get subjectTajweed;

  /// No description provided for @subjectHifz.
  ///
  /// In en, this message translates to:
  /// **'Hifz'**
  String get subjectHifz;

  /// No description provided for @subjectTafsir.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get subjectTafsir;

  /// No description provided for @subjectArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get subjectArabic;

  /// No description provided for @subjectIslamicStudies.
  ///
  /// In en, this message translates to:
  /// **'Islamic studies'**
  String get subjectIslamicStudies;

  /// No description provided for @languageUrdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get languageUrdu;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languagePunjabi.
  ///
  /// In en, this message translates to:
  /// **'Punjabi'**
  String get languagePunjabi;

  /// No description provided for @languagePashto.
  ///
  /// In en, this message translates to:
  /// **'Pashto'**
  String get languagePashto;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @ageGroupChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get ageGroupChild;

  /// No description provided for @ageGroupTeen.
  ///
  /// In en, this message translates to:
  /// **'Teen'**
  String get ageGroupTeen;

  /// No description provided for @ageGroupAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get ageGroupAdult;

  /// No description provided for @ageGroupChildRange.
  ///
  /// In en, this message translates to:
  /// **'6–12'**
  String get ageGroupChildRange;

  /// No description provided for @ageGroupTeenRange.
  ///
  /// In en, this message translates to:
  /// **'13–17'**
  String get ageGroupTeenRange;

  /// No description provided for @ageGroupAdultRange.
  ///
  /// In en, this message translates to:
  /// **'18+'**
  String get ageGroupAdultRange;

  /// No description provided for @levelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get levelBeginner;

  /// No description provided for @levelBeginnerDescription.
  ///
  /// In en, this message translates to:
  /// **'Can’t read Arabic letters yet'**
  String get levelBeginnerDescription;

  /// No description provided for @levelReadsWithHelp.
  ///
  /// In en, this message translates to:
  /// **'Can read with help'**
  String get levelReadsWithHelp;

  /// No description provided for @levelReadsWithHelpDescription.
  ///
  /// In en, this message translates to:
  /// **'Reads slowly and makes mistakes'**
  String get levelReadsWithHelpDescription;

  /// No description provided for @levelReadsFluently.
  ///
  /// In en, this message translates to:
  /// **'Reads fluently'**
  String get levelReadsFluently;

  /// No description provided for @levelReadsFluentlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Wants to improve Tajweed'**
  String get levelReadsFluentlyDescription;

  /// No description provided for @levelMemorising.
  ///
  /// In en, this message translates to:
  /// **'Memorising'**
  String get levelMemorising;

  /// No description provided for @levelMemorisingDescription.
  ///
  /// In en, this message translates to:
  /// **'Working on Hifz'**
  String get levelMemorisingDescription;

  /// No description provided for @feeUnitPerClass.
  ///
  /// In en, this message translates to:
  /// **'Per class'**
  String get feeUnitPerClass;

  /// No description provided for @feeUnitPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Per month'**
  String get feeUnitPerMonth;

  /// No description provided for @audienceChildren.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get audienceChildren;

  /// No description provided for @audienceWomen.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get audienceWomen;

  /// No description provided for @audienceMen.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get audienceMen;

  /// No description provided for @audienceAll.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get audienceAll;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayMondayInitial.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekdayMondayInitial;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayTuesdayInitial.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayTuesdayInitial;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayWednesdayInitial.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekdayWednesdayInitial;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayThursdayInitial.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayThursdayInitial;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdayFridayInitial.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekdayFridayInitial;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySaturdayInitial.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySaturdayInitial;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @weekdaySundayInitial.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySundayInitial;

  /// No description provided for @tagReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get tagReminder;

  /// No description provided for @tagTajweedTip.
  ///
  /// In en, this message translates to:
  /// **'Tajweed tip'**
  String get tagTajweedTip;

  /// No description provided for @tagHifz.
  ///
  /// In en, this message translates to:
  /// **'Hifz'**
  String get tagHifz;

  /// No description provided for @tagQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get tagQuestion;

  /// No description provided for @tagClassAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Class announcement'**
  String get tagClassAnnouncement;

  /// No description provided for @tagAchievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get tagAchievement;

  /// No description provided for @reportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonHate.
  ///
  /// In en, this message translates to:
  /// **'Hate or harassment'**
  String get reportReasonHate;

  /// No description provided for @reportReasonFalseInformation.
  ///
  /// In en, this message translates to:
  /// **'False information'**
  String get reportReasonFalseInformation;

  /// No description provided for @reportReasonSomethingElse.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get reportReasonSomethingElse;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search teachers, posts, subjects'**
  String get searchPlaceholder;

  /// No description provided for @myProfileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'My profile and settings'**
  String get myProfileAndSettings;

  /// No description provided for @verifiedTeacher.
  ///
  /// In en, this message translates to:
  /// **'Verified teacher'**
  String get verifiedTeacher;

  /// No description provided for @postMetaTeacher.
  ///
  /// In en, this message translates to:
  /// **'{subject} teacher'**
  String postMetaTeacher(String subject);

  /// No description provided for @postCounts.
  ///
  /// In en, this message translates to:
  /// **'{likes, plural, =1{1 like} other{{likes} likes}} · {comments, plural, =1{1 comment} other{{comments} comments}}'**
  String postCounts(int likes, int comments);

  /// No description provided for @likeAction.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get likeAction;

  /// No description provided for @likedAction.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get likedAction;

  /// No description provided for @commentAction.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentAction;

  /// No description provided for @reportAction.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportAction;

  /// No description provided for @replyAction.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get replyAction;

  /// No description provided for @postOptionsAction.
  ///
  /// In en, this message translates to:
  /// **'Post options'**
  String get postOptionsAction;

  /// No description provided for @postPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Post photo'**
  String get postPhotoLabel;

  /// No description provided for @timeNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get timeNow;

  /// No description provided for @timeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String timeMinutes(int minutes);

  /// No description provided for @timeHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String timeHours(int hours);

  /// No description provided for @timeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get timeYesterday;

  /// No description provided for @emptyFeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your feed is quiet'**
  String get emptyFeedTitle;

  /// No description provided for @emptyFeedMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect with teachers to see their posts here.'**
  String get emptyFeedMessage;

  /// No description provided for @findTeachersAction.
  ///
  /// In en, this message translates to:
  /// **'Find teachers'**
  String get findTeachersAction;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postTitle;

  /// No description provided for @commentsHeading.
  ///
  /// In en, this message translates to:
  /// **'Comments ({count})'**
  String commentsHeading(int count);

  /// No description provided for @writeCommentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write a comment…'**
  String get writeCommentPlaceholder;

  /// No description provided for @sendCommentAction.
  ///
  /// In en, this message translates to:
  /// **'Send comment'**
  String get sendCommentAction;

  /// No description provided for @postAction.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postAction;

  /// No description provided for @postingToEveryone.
  ///
  /// In en, this message translates to:
  /// **'Posting to everyone'**
  String get postingToEveryone;

  /// No description provided for @postPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Share a reminder, a Tajweed tip or a question…'**
  String get postPlaceholder;

  /// No description provided for @removePhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhotoAction;

  /// No description provided for @chooseTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose a tag'**
  String get chooseTagLabel;

  /// No description provided for @requiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredLabel;

  /// No description provided for @contentPolicyNote.
  ///
  /// In en, this message translates to:
  /// **'Keep it Islamic and respectful. No music, politics, sectarian debate or ads.'**
  String get contentPolicyNote;

  /// No description provided for @photoAction.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoAction;

  /// No description provided for @postCounter.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max}'**
  String postCounter(String count, String max);

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this post'**
  String get reportTitle;

  /// No description provided for @reportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your report is anonymous. Our team reviews every report.'**
  String get reportSubtitle;

  /// No description provided for @alsoBlockPrefix.
  ///
  /// In en, this message translates to:
  /// **'Also block '**
  String get alsoBlockPrefix;

  /// No description provided for @alsoBlockSuffix.
  ///
  /// In en, this message translates to:
  /// **'. They won’t see your profile or message you.'**
  String get alsoBlockSuffix;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @reportSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Our team will review this post.'**
  String get reportSentMessage;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @deletePostTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this post?'**
  String get deletePostTitle;

  /// No description provided for @deletePostMessage.
  ///
  /// In en, this message translates to:
  /// **'The post, its likes and comments will be deleted. This can’t be undone.'**
  String get deletePostMessage;

  /// No description provided for @deleteCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this comment?'**
  String get deleteCommentTitle;

  /// No description provided for @deleteCommentMessage.
  ///
  /// In en, this message translates to:
  /// **'This can’t be undone.'**
  String get deleteCommentMessage;

  /// No description provided for @reportCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this comment'**
  String get reportCommentTitle;

  /// No description provided for @reportCommentSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Our team will review this comment.'**
  String get reportCommentSentMessage;

  /// No description provided for @postUnderReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Under review — only you can see this post'**
  String get postUnderReviewLabel;

  /// No description provided for @dailyCommentLimitError.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached today\'s limit of 100 comments. You can comment more tomorrow.'**
  String get dailyCommentLimitError;

  /// No description provided for @tabStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get tabStudents;

  /// No description provided for @studentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get studentsTitle;

  /// No description provided for @discoverSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Name, subject or headline'**
  String get discoverSearchPlaceholder;

  /// No description provided for @searchTeachersLabel.
  ///
  /// In en, this message translates to:
  /// **'Search teachers'**
  String get searchTeachersLabel;

  /// No description provided for @searchStudentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Search students'**
  String get searchStudentsLabel;

  /// No description provided for @filtersButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Filters} =1{Filters, 1 active} other{Filters, {count} active}}'**
  String filtersButtonLabel(int count);

  /// No description provided for @teacherCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 teacher} other{{count} teachers}}'**
  String teacherCount(int count);

  /// No description provided for @studentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student} other{{count} students}}'**
  String studentCount(int count);

  /// No description provided for @teacherGenderChip.
  ///
  /// In en, this message translates to:
  /// **'{gender} teacher'**
  String teacherGenderChip(String gender);

  /// No description provided for @wantsSubjectChip.
  ///
  /// In en, this message translates to:
  /// **'Wants {subject}'**
  String wantsSubjectChip(String subject);

  /// No description provided for @feeRange.
  ///
  /// In en, this message translates to:
  /// **'\${min} – \${max}'**
  String feeRange(int min, int max);

  /// No description provided for @teachesChildrenLabel.
  ///
  /// In en, this message translates to:
  /// **'Teaches children'**
  String get teachesChildrenLabel;

  /// No description provided for @connectAction.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectAction;

  /// No description provided for @connectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectedLabel;

  /// No description provided for @requestedLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get requestedLabel;

  /// No description provided for @acceptAction.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptAction;

  /// No description provided for @declineAction.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineAction;

  /// No description provided for @messageAction.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageAction;

  /// No description provided for @viewProfileAction.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfileAction;

  /// No description provided for @cityAndTimeZone.
  ///
  /// In en, this message translates to:
  /// **'{place} · {timeZone}'**
  String cityAndTimeZone(String place, String timeZone);

  /// No description provided for @yearsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} yrs'**
  String yearsShort(int count);

  /// No description provided for @feePerMonthShort.
  ///
  /// In en, this message translates to:
  /// **'\${amount}/mo'**
  String feePerMonthShort(int amount);

  /// No description provided for @feePerClassShort.
  ///
  /// In en, this message translates to:
  /// **'\${amount}/class'**
  String feePerClassShort(int amount);

  /// No description provided for @feePerMonthLong.
  ///
  /// In en, this message translates to:
  /// **'\${amount} / month'**
  String feePerMonthLong(int amount);

  /// No description provided for @feePerClassLong.
  ///
  /// In en, this message translates to:
  /// **'\${amount} / class'**
  String feePerClassLong(int amount);

  /// No description provided for @lookingPill.
  ///
  /// In en, this message translates to:
  /// **'Looking'**
  String get lookingPill;

  /// No description provided for @quotedNote.
  ///
  /// In en, this message translates to:
  /// **'“{note}”'**
  String quotedNote(String note);

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”'**
  String noResultsTitle(String query);

  /// No description provided for @noFilterMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nobody matches these filters'**
  String get noFilterMatchesTitle;

  /// No description provided for @noResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different word, or remove some filters.'**
  String get noResultsMessage;

  /// No description provided for @clearFiltersAction.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFiltersAction;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @resetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetAction;

  /// No description provided for @subjectFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subjectFilterLabel;

  /// No description provided for @teacherGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Teacher gender'**
  String get teacherGenderLabel;

  /// No description provided for @languageFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageFilterLabel;

  /// No description provided for @monthlyFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly fee'**
  String get monthlyFeeLabel;

  /// No description provided for @experienceFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experienceFilterLabel;

  /// No description provided for @experienceYearsPlus.
  ///
  /// In en, this message translates to:
  /// **'{years}+ years'**
  String experienceYearsPlus(int years);

  /// No description provided for @showTeachersAction.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No teachers to show} =1{Show 1 teacher} other{Show {count} teachers}}'**
  String showTeachersAction(int count);

  /// No description provided for @showStudentsAction.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No students to show} =1{Show 1 student} other{Show {count} students}}'**
  String showStudentsAction(int count);

  /// No description provided for @subjectWantedLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject wanted'**
  String get subjectWantedLabel;

  /// No description provided for @studentGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Student gender'**
  String get studentGenderLabel;

  /// No description provided for @countryTimeZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Country / time zone'**
  String get countryTimeZoneLabel;

  /// No description provided for @anyCountry.
  ///
  /// In en, this message translates to:
  /// **'Any country'**
  String get anyCountry;

  /// No description provided for @levelFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelFilterLabel;

  /// No description provided for @shareProfileAction.
  ///
  /// In en, this message translates to:
  /// **'Share profile'**
  String get shareProfileAction;

  /// No description provided for @reportOrBlockAction.
  ///
  /// In en, this message translates to:
  /// **'Report or block'**
  String get reportOrBlockAction;

  /// No description provided for @profileShareText.
  ///
  /// In en, this message translates to:
  /// **'{name} — {headline} · on Asatiza'**
  String profileShareText(String name, String headline);

  /// No description provided for @profileCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Profile details copied'**
  String get profileCopiedMessage;

  /// No description provided for @blockUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String blockUserTitle(String name);

  /// No description provided for @blockUserMessage.
  ///
  /// In en, this message translates to:
  /// **'They won’t see your profile or message you, and you won’t see them in lists or the feed.'**
  String get blockUserMessage;

  /// No description provided for @blockAction.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get blockAction;

  /// No description provided for @userBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} is blocked'**
  String userBlockedMessage(String name);

  /// No description provided for @profileUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile not available'**
  String get profileUnavailableTitle;

  /// No description provided for @profileLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your profile'**
  String get profileLoadFailedTitle;

  /// No description provided for @profileUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'This account may have been deleted.'**
  String get profileUnavailableMessage;

  /// No description provided for @learnerLabel.
  ///
  /// In en, this message translates to:
  /// **'{ageGroup} learner'**
  String learnerLabel(String ageGroup);

  /// No description provided for @connectFirstHint.
  ///
  /// In en, this message translates to:
  /// **'Connect first to send a message'**
  String get connectFirstHint;

  /// No description provided for @statExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get statExperience;

  /// No description provided for @statConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get statConnections;

  /// No description provided for @statPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get statPosts;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @teachesAudience.
  ///
  /// In en, this message translates to:
  /// **'Teaches {audience}'**
  String teachesAudience(String audience);

  /// No description provided for @feeShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get feeShortLabel;

  /// No description provided for @availabilityLine.
  ///
  /// In en, this message translates to:
  /// **'{days} · {from}–{to}'**
  String availabilityLine(String days, String from, String to);

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @wantsToLearnLabel.
  ///
  /// In en, this message translates to:
  /// **'Wants to learn'**
  String get wantsToLearnLabel;

  /// No description provided for @levelLine.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}'**
  String levelLine(String level);

  /// No description provided for @speaksLine.
  ///
  /// In en, this message translates to:
  /// **'Speaks {languages}'**
  String speaksLine(String languages);

  /// No description provided for @prefersFemaleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Prefers a female teacher'**
  String get prefersFemaleTeacher;

  /// No description provided for @prefersMaleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Prefers a male teacher'**
  String get prefersMaleTeacher;

  /// No description provided for @prefersAnyTeacher.
  ///
  /// In en, this message translates to:
  /// **'Happy with any teacher'**
  String get prefersAnyTeacher;

  /// No description provided for @connectWithTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with {name}'**
  String connectWithTitle(String name);

  /// No description provided for @connectSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{gender, select, male{Once he accepts, you can chat.} female{Once she accepts, you can chat.} other{Once they accept, you can chat.}}'**
  String connectSheetSubtitle(String gender);

  /// No description provided for @addNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get addNoteLabel;

  /// No description provided for @connectNotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Say salam and tell them what you would like to learn'**
  String get connectNotePlaceholder;

  /// No description provided for @sendRequestAction.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequestAction;

  /// No description provided for @requestSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Request sent to {name}'**
  String requestSentMessage(String name);

  /// No description provided for @connectNoteTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Keep your note to 200 characters.'**
  String get connectNoteTooLongError;

  /// No description provided for @connectProfileIncompleteError.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up your profile to connect.'**
  String get connectProfileIncompleteError;

  /// No description provided for @connectAlreadyError.
  ///
  /// In en, this message translates to:
  /// **'You already have a request or connection with this person.'**
  String get connectAlreadyError;

  /// No description provided for @connectRequestLimitError.
  ///
  /// In en, this message translates to:
  /// **'You\'ve sent 10 requests in the last 24 hours. Try again later.'**
  String get connectRequestLimitError;

  /// No description provided for @connectDeclinedRecentlyError.
  ///
  /// In en, this message translates to:
  /// **'This person declined your request. You can ask again after 3 days.'**
  String get connectDeclinedRecentlyError;

  /// No description provided for @connectReceiverNotActiveTeacher.
  ///
  /// In en, this message translates to:
  /// **'This teacher is still completing their profile. You can connect once it\'s complete.'**
  String get connectReceiverNotActiveTeacher;

  /// No description provided for @connectReceiverNotActiveStudent.
  ///
  /// In en, this message translates to:
  /// **'This student is still completing their profile. You can connect once it\'s complete.'**
  String get connectReceiverNotActiveStudent;

  /// No description provided for @notAcceptingRequestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Not accepting requests yet'**
  String get notAcceptingRequestsLabel;

  /// No description provided for @connectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'My connections'**
  String get connectionsTitle;

  /// No description provided for @connectedTab.
  ///
  /// In en, this message translates to:
  /// **'Connected {count}'**
  String connectedTab(int count);

  /// No description provided for @requestsTab.
  ///
  /// In en, this message translates to:
  /// **'Requests {count}'**
  String requestsTab(int count);

  /// No description provided for @sentTab.
  ///
  /// In en, this message translates to:
  /// **'Sent {count}'**
  String sentTab(int count);

  /// No description provided for @studentLearningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Student · Learning {subject}'**
  String studentLearningSubtitle(String subject);

  /// No description provided for @removeOrBlockAction.
  ///
  /// In en, this message translates to:
  /// **'Remove or block'**
  String get removeOrBlockAction;

  /// No description provided for @removeConnectionAction.
  ///
  /// In en, this message translates to:
  /// **'Remove connection'**
  String get removeConnectionAction;

  /// No description provided for @cancelRequestAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelRequestAction;

  /// No description provided for @emptyConnectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No connections yet'**
  String get emptyConnectionsTitle;

  /// No description provided for @emptyConnectionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a request from a teacher’s profile.'**
  String get emptyConnectionsMessage;

  /// No description provided for @emptyRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'No requests'**
  String get emptyRequestsTitle;

  /// No description provided for @emptyRequestsMessage.
  ///
  /// In en, this message translates to:
  /// **'New connection requests will show up here.'**
  String get emptyRequestsMessage;

  /// No description provided for @emptySentTitle.
  ///
  /// In en, this message translates to:
  /// **'No sent requests'**
  String get emptySentTitle;

  /// No description provided for @emptySentMessage.
  ///
  /// In en, this message translates to:
  /// **'Requests you send stay here until they are answered.'**
  String get emptySentMessage;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @clearSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchAction;

  /// No description provided for @searchTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchTabAll;

  /// No description provided for @searchTabPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get searchTabPosts;

  /// No description provided for @seeAllCount.
  ///
  /// In en, this message translates to:
  /// **'See all {count}'**
  String seeAllCount(int count);

  /// No description provided for @chatOptionsAction.
  ///
  /// In en, this message translates to:
  /// **'Chat options'**
  String get chatOptionsAction;

  /// No description provided for @chatPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get chatPhotoLabel;

  /// No description provided for @chatUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat not available'**
  String get chatUnavailableTitle;

  /// No description provided for @chatUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'You can chat once your connection request is accepted.'**
  String get chatUnavailableMessage;

  /// No description provided for @chatReadOnlyMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re no longer connected. You can still read your messages.'**
  String get chatReadOnlyMessage;

  /// No description provided for @messageTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Messages can be up to 2,000 characters.'**
  String get messageTooLongError;

  /// No description provided for @dailyMessageLimitError.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached today\'s limit of 300 messages. You can send more tomorrow.'**
  String get dailyMessageLimitError;

  /// No description provided for @dailyPhotoLimitError.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached today\'s limit of 30 photos. You can still send text, and more photos tomorrow.'**
  String get dailyPhotoLimitError;

  /// No description provided for @connectedToday.
  ///
  /// In en, this message translates to:
  /// **'Connected today'**
  String get connectedToday;

  /// No description provided for @connectedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Connected yesterday} other{Connected {days} days ago}}'**
  String connectedDaysAgo(int days);

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// No description provided for @emptyChatsTitle.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get emptyChatsTitle;

  /// No description provided for @emptyChatsMessage.
  ///
  /// In en, this message translates to:
  /// **'Chats open once a teacher accepts your request.'**
  String get emptyChatsMessage;

  /// No description provided for @emptyChatsMessageTeacher.
  ///
  /// In en, this message translates to:
  /// **'Chats open once you accept a student’s request.'**
  String get emptyChatsMessageTeacher;

  /// No description provided for @noChatResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another name.'**
  String get noChatResultsMessage;

  /// No description provided for @emptyNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re all caught up'**
  String get emptyNotificationsTitle;

  /// No description provided for @emptyNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Requests, likes and comments will show up here.'**
  String get emptyNotificationsMessage;

  /// No description provided for @linkCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopiedMessage;

  /// No description provided for @markAllReadAction.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllReadAction;

  /// No description provided for @messageFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageFieldHint;

  /// No description provided for @messageReadLabel.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get messageReadLabel;

  /// No description provided for @messageSentLabel.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get messageSentLabel;

  /// No description provided for @notifWantsToConnect.
  ///
  /// In en, this message translates to:
  /// **'wants to connect with you'**
  String get notifWantsToConnect;

  /// No description provided for @notifAccepted.
  ///
  /// In en, this message translates to:
  /// **'accepted your request. Say salam!'**
  String get notifAccepted;

  /// No description provided for @notifCommented.
  ///
  /// In en, this message translates to:
  /// **'commented: “{text}”'**
  String notifCommented(String text);

  /// No description provided for @notifLiked.
  ///
  /// In en, this message translates to:
  /// **'{others, plural, =0{liked your post} =1{and 1 other liked your post} other{and {others} others liked your post}}'**
  String notifLiked(int others);

  /// No description provided for @notifApprovedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Your teacher profile was '**
  String get notifApprovedPrefix;

  /// No description provided for @notifApprovedWord.
  ///
  /// In en, this message translates to:
  /// **'approved'**
  String get notifApprovedWord;

  /// No description provided for @notifApprovedSuffix.
  ///
  /// In en, this message translates to:
  /// **'. You now appear in search.'**
  String get notifApprovedSuffix;

  /// No description provided for @notifNeedsChanges.
  ///
  /// In en, this message translates to:
  /// **'Your teacher profile needs a few changes before approval. Check your email for details.'**
  String get notifNeedsChanges;

  /// No description provided for @notificationsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationsNew;

  /// No description provided for @notificationsEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notificationsEarlier;

  /// No description provided for @searchChatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Search chats'**
  String get searchChatsLabel;

  /// No description provided for @sendAction.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendAction;

  /// No description provided for @sendPhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Send a photo'**
  String get sendPhotoAction;

  /// No description provided for @sentAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Sent a photo'**
  String get sentAPhoto;

  /// No description provided for @youPrefix.
  ///
  /// In en, this message translates to:
  /// **'You: {text}'**
  String youPrefix(String text);

  /// No description provided for @subjectTeacher.
  ///
  /// In en, this message translates to:
  /// **'{subject} teacher'**
  String subjectTeacher(String subject);

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String timeDaysAgo(int count);

  /// No description provided for @ageGroupFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Age group'**
  String get ageGroupFieldLabel;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Asatiza {version}'**
  String appVersionLabel(String version);

  /// No description provided for @blockedOn.
  ///
  /// In en, this message translates to:
  /// **'Blocked on {date}'**
  String blockedOn(String date);

  /// No description provided for @blockedUsersIntro.
  ///
  /// In en, this message translates to:
  /// **'Blocked people can’t see your profile or posts, or message you. They aren’t told that you blocked them.'**
  String get blockedUsersIntro;

  /// No description provided for @blockedUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get blockedUsersTitle;

  /// No description provided for @certificatesApproved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 certificate · approved} other{{count} certificates · approved}}'**
  String certificatesApproved(int count);

  /// No description provided for @certificatesInReview.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 certificate · in review} other{{count} certificates · in review}}'**
  String certificatesInReview(int count);

  /// No description provided for @certificatesApprovedShort.
  ///
  /// In en, this message translates to:
  /// **'{count} approved'**
  String certificatesApprovedShort(int count);

  /// No description provided for @certificatesInReviewShort.
  ///
  /// In en, this message translates to:
  /// **'{count} in review'**
  String certificatesInReviewShort(int count);

  /// No description provided for @certificatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get certificatesLabel;

  /// No description provided for @noCertificatesYet.
  ///
  /// In en, this message translates to:
  /// **'No certificates yet'**
  String get noCertificatesYet;

  /// No description provided for @changePasswordIntro.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters. You’ll stay logged in on this phone.'**
  String get changePasswordIntro;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @changePhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhotoAction;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @currentPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'That password isn’t right.'**
  String get currentPasswordWrong;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordLabel;

  /// No description provided for @passwordRuleDifferent.
  ///
  /// In en, this message translates to:
  /// **'Different from your current password'**
  String get passwordRuleDifferent;

  /// No description provided for @passwordChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChangedMessage;

  /// No description provided for @savePasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get savePasswordAction;

  /// No description provided for @forgotCurrentPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Forgot your current password?'**
  String get forgotCurrentPasswordAction;

  /// No description provided for @resetByEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset by email?'**
  String get resetByEmailTitle;

  /// No description provided for @resetByEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'You’ll be logged out and we’ll email you a code to set a new password.'**
  String get resetByEmailMessage;

  /// No description provided for @connectionsCountAction.
  ///
  /// In en, this message translates to:
  /// **'Connections ({count})'**
  String connectionsCountAction(int count);

  /// No description provided for @contentPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Content policy'**
  String get contentPolicyTitle;

  /// No description provided for @contentAimTitle.
  ///
  /// In en, this message translates to:
  /// **'Our aim'**
  String get contentAimTitle;

  /// No description provided for @contentAimBody.
  ///
  /// In en, this message translates to:
  /// **'Asatiza is a place to learn and teach the Quran. Everything you share should be respectful and beneficial.'**
  String get contentAimBody;

  /// No description provided for @contentShareTitle.
  ///
  /// In en, this message translates to:
  /// **'What you can share'**
  String get contentShareTitle;

  /// No description provided for @contentShare1.
  ///
  /// In en, this message translates to:
  /// **'Quranic verses, hadith and Islamic reminders with their source'**
  String get contentShare1;

  /// No description provided for @contentShare2.
  ///
  /// In en, this message translates to:
  /// **'Tajweed and Hifz tips, questions and study routines'**
  String get contentShare2;

  /// No description provided for @contentShare3.
  ///
  /// In en, this message translates to:
  /// **'Class announcements and student achievements, with permission'**
  String get contentShare3;

  /// No description provided for @contentNotAllowedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get contentNotAllowedTitle;

  /// No description provided for @contentNotAllowed1.
  ///
  /// In en, this message translates to:
  /// **'Music, songs or music videos'**
  String get contentNotAllowed1;

  /// No description provided for @contentNotAllowed2.
  ///
  /// In en, this message translates to:
  /// **'Politics or sectarian debate and attacks'**
  String get contentNotAllowed2;

  /// No description provided for @contentNotAllowed3.
  ///
  /// In en, this message translates to:
  /// **'Ads, spam or paid promotions outside your profile'**
  String get contentNotAllowed3;

  /// No description provided for @contentNotAllowed4.
  ///
  /// In en, this message translates to:
  /// **'Hate, harassment or private details of others'**
  String get contentNotAllowed4;

  /// No description provided for @contentReportingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reporting and review'**
  String get contentReportingTitle;

  /// No description provided for @contentReportingBody.
  ///
  /// In en, this message translates to:
  /// **'Tap Report on any post, comment or profile. A post reported by three people is hidden until our team reviews it. Breaking these rules can lead to a warning or a ban.'**
  String get contentReportingBody;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'What we collect'**
  String get privacyCollectTitle;

  /// No description provided for @privacyCollectBody.
  ///
  /// In en, this message translates to:
  /// **'Your name, email, role, profile details and photo, the posts, comments and messages you send, a device token for notifications, and crash reports.'**
  String get privacyCollectBody;

  /// No description provided for @privacyUseTitle.
  ///
  /// In en, this message translates to:
  /// **'How we use it'**
  String get privacyUseTitle;

  /// No description provided for @privacyUseBody.
  ///
  /// In en, this message translates to:
  /// **'To run your account, show your profile to the right people, deliver messages and notifications, keep the community safe and fix bugs. We never sell your data.'**
  String get privacyUseBody;

  /// No description provided for @privacySeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Who can see what'**
  String get privacySeeTitle;

  /// No description provided for @privacySeeBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile and posts are visible to signed-in members. Messages are visible only to you and the person you chat with. Certificates are seen only by our review team.'**
  String get privacySeeBody;

  /// No description provided for @privacyChoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your choices'**
  String get privacyChoicesTitle;

  /// No description provided for @privacyChoicesBody.
  ///
  /// In en, this message translates to:
  /// **'Edit your profile any time, turn notifications off in Settings, block people, and delete your account from Settings or our website.'**
  String get privacyChoicesBody;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsTitle;

  /// No description provided for @termsJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Who can join'**
  String get termsJoinTitle;

  /// No description provided for @termsJoinBody.
  ///
  /// In en, this message translates to:
  /// **'You must be 18 or older. A parent or guardian may create a student account for their child and is responsible for it.'**
  String get termsJoinBody;

  /// No description provided for @termsAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get termsAccountTitle;

  /// No description provided for @termsAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Keep your password safe and your details accurate. Teachers must only upload certificates that are genuinely theirs.'**
  String get termsAccountBody;

  /// No description provided for @termsClassesTitle.
  ///
  /// In en, this message translates to:
  /// **'Classes and fees'**
  String get termsClassesTitle;

  /// No description provided for @termsClassesBody.
  ///
  /// In en, this message translates to:
  /// **'Teachers and students arrange class times, video links and fees directly. Asatiza is not a party to these arrangements and does not handle payments.'**
  String get termsClassesBody;

  /// No description provided for @termsContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get termsContentTitle;

  /// No description provided for @termsContentBody.
  ///
  /// In en, this message translates to:
  /// **'You own what you post, and you give Asatiza permission to show it in the app. All content must follow our Content policy.'**
  String get termsContentBody;

  /// No description provided for @termsEndingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ending your account'**
  String get termsEndingTitle;

  /// No description provided for @termsEndingBody.
  ///
  /// In en, this message translates to:
  /// **'You can delete your account at any time. We may suspend accounts that break these terms or put others at risk.'**
  String get termsEndingBody;

  /// No description provided for @policyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated 18 November 2026'**
  String get policyLastUpdated;

  /// No description provided for @deleteAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountAction;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This is permanent and can’t be undone. The following will be deleted:'**
  String get deleteAccountMessage;

  /// No description provided for @deleteItemProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile, photo and certificates'**
  String get deleteItemProfile;

  /// No description provided for @deleteItemPosts.
  ///
  /// In en, this message translates to:
  /// **'Your posts, comments and likes'**
  String get deleteItemPosts;

  /// No description provided for @deleteItemChats.
  ///
  /// In en, this message translates to:
  /// **'Your chats and shared photos'**
  String get deleteItemChats;

  /// No description provided for @deleteItemConnections.
  ///
  /// In en, this message translates to:
  /// **'Your connections and requests'**
  String get deleteItemConnections;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'I understand that my account and data will be permanently deleted.'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Your account couldn’t be deleted. Please try again.'**
  String get deleteAccountFailed;

  /// No description provided for @editProfileAction.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileAction;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @profileSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSavedMessage;

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get nameRequiredError;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @iTeachLabel.
  ///
  /// In en, this message translates to:
  /// **'I teach'**
  String get iTeachLabel;

  /// No description provided for @learningLabel.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learningLabel;

  /// No description provided for @wantToLearnLabel.
  ///
  /// In en, this message translates to:
  /// **'What I want to learn'**
  String get wantToLearnLabel;

  /// No description provided for @lookingSwitchHint.
  ///
  /// In en, this message translates to:
  /// **'Shows teachers that you\'re looking for a teacher now.'**
  String get lookingSwitchHint;

  /// No description provided for @myPostsLabel.
  ///
  /// In en, this message translates to:
  /// **'My posts'**
  String get myPostsLabel;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven’t posted yet.'**
  String get noPostsYet;

  /// No description provided for @myProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get myProfileTitle;

  /// No description provided for @qualificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Qualifications'**
  String get qualificationsLabel;

  /// No description provided for @qualificationsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ijazah in Hafs, Hifz from Jamia Ashrafia'**
  String get qualificationsPlaceholder;

  /// No description provided for @removeCertificateAction.
  ///
  /// In en, this message translates to:
  /// **'Remove certificate'**
  String get removeCertificateAction;

  /// No description provided for @uploadCertificateAction.
  ///
  /// In en, this message translates to:
  /// **'Upload certificate'**
  String get uploadCertificateAction;

  /// No description provided for @logOutAction.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOutAction;

  /// No description provided for @logOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of Asatiza?'**
  String get logOutTitle;

  /// No description provided for @logOutMessage.
  ///
  /// In en, this message translates to:
  /// **'You can log back in any time with your email and password.'**
  String get logOutMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsPrivacySafety.
  ///
  /// In en, this message translates to:
  /// **'Privacy & safety'**
  String get settingsPrivacySafety;

  /// No description provided for @settingConnectionRequests.
  ///
  /// In en, this message translates to:
  /// **'Connection requests'**
  String get settingConnectionRequests;

  /// No description provided for @settingNewMessages.
  ///
  /// In en, this message translates to:
  /// **'New messages'**
  String get settingNewMessages;

  /// No description provided for @settingComments.
  ///
  /// In en, this message translates to:
  /// **'Comments on my posts'**
  String get settingComments;

  /// No description provided for @settingLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get settingLikes;

  /// No description provided for @noBlockedUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'No blocked users'**
  String get noBlockedUsersTitle;

  /// No description provided for @noBlockedUsersMessage.
  ///
  /// In en, this message translates to:
  /// **'If you block someone from a profile, post or chat, they’ll appear here.'**
  String get noBlockedUsersMessage;

  /// No description provided for @unblockAction.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblockAction;

  /// No description provided for @photoSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get photoSourceTitle;

  /// No description provided for @photoSourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get photoSourceCamera;

  /// No description provided for @photoSourceGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get photoSourceGallery;

  /// No description provided for @certificateInstructions.
  ///
  /// In en, this message translates to:
  /// **'Upload one certificate (ijazah, sanad or diploma) as a PDF, up to 3 MB. Make sure your name and the issuing institute are clear. Only our review team can see it.'**
  String get certificateInstructions;

  /// No description provided for @uploadErrorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This file is too large. A certificate PDF can be up to 3 MB.'**
  String get uploadErrorTooLarge;

  /// No description provided for @uploadErrorNotPdf.
  ///
  /// In en, this message translates to:
  /// **'Only PDF files can be uploaded.'**
  String get uploadErrorNotPdf;

  /// No description provided for @uploadErrorCertificateLimit.
  ///
  /// In en, this message translates to:
  /// **'You can upload one certificate. Remove it to upload a different one.'**
  String get uploadErrorCertificateLimit;

  /// No description provided for @uploadErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Please try again.'**
  String get uploadErrorFailed;

  /// No description provided for @openCertificateAction.
  ///
  /// In en, this message translates to:
  /// **'Open certificate'**
  String get openCertificateAction;

  /// No description provided for @certificateViewerTitle.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get certificateViewerTitle;

  /// No description provided for @certificateOpenFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the certificate'**
  String get certificateOpenFailedTitle;

  /// No description provided for @certificateOpenFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get certificateOpenFailedMessage;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryAction;

  /// No description provided for @blockFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t update the block. Check your connection and try again.'**
  String get blockFailedMessage;

  /// No description provided for @requiredFieldsMissing.
  ///
  /// In en, this message translates to:
  /// **'Fill in to save: {fields}'**
  String requiredFieldsMissing(String fields);

  /// No description provided for @discoverLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load people'**
  String get discoverLoadFailedTitle;

  /// No description provided for @discoverLoadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get discoverLoadFailedMessage;

  /// No description provided for @certificatePageIndicator.
  ///
  /// In en, this message translates to:
  /// **'{page} / {total}'**
  String certificatePageIndicator(int page, int total);
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
