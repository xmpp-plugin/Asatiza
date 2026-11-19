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

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

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

  /// No description provided for @profilePercent.
  ///
  /// In en, this message translates to:
  /// **'Profile {percent}%'**
  String profilePercent(int percent);

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
  /// **'Upload certificates'**
  String get uploadCertificatesAction;

  /// No description provided for @uploadCertificatesHint.
  ///
  /// In en, this message translates to:
  /// **'JPG or PDF'**
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
  /// **'Teachers can find you in the Students tab and send you requests.'**
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

  /// No description provided for @strengthTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile is {percent}% complete'**
  String strengthTitle(int percent);

  /// No description provided for @stepsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All done} =1{1 step left} other{{count} steps left}}'**
  String stepsLeft(int count);

  /// No description provided for @completeProfileAction.
  ///
  /// In en, this message translates to:
  /// **'Complete profile'**
  String get completeProfileAction;

  /// No description provided for @hideAction.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hideAction;

  /// No description provided for @strengthHintPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a profile photo to build trust.'**
  String get strengthHintPhoto;

  /// No description provided for @strengthHintHeadline.
  ///
  /// In en, this message translates to:
  /// **'Add a headline so students know what you teach.'**
  String get strengthHintHeadline;

  /// No description provided for @strengthHintSubjects.
  ///
  /// In en, this message translates to:
  /// **'Add the subjects you teach.'**
  String get strengthHintSubjects;

  /// No description provided for @strengthHintLanguages.
  ///
  /// In en, this message translates to:
  /// **'Add the languages you speak.'**
  String get strengthHintLanguages;

  /// No description provided for @strengthHintBio.
  ///
  /// In en, this message translates to:
  /// **'Write a short bio about your teaching.'**
  String get strengthHintBio;

  /// No description provided for @strengthHintExperience.
  ///
  /// In en, this message translates to:
  /// **'Add your years of experience.'**
  String get strengthHintExperience;

  /// No description provided for @strengthHintFee.
  ///
  /// In en, this message translates to:
  /// **'Add your fee and available days.'**
  String get strengthHintFee;

  /// No description provided for @strengthHintCertificate.
  ///
  /// In en, this message translates to:
  /// **'Upload a certificate to get verified faster.'**
  String get strengthHintCertificate;

  /// No description provided for @strengthHintGoals.
  ///
  /// In en, this message translates to:
  /// **'Add your learning goal to reach teachers faster.'**
  String get strengthHintGoals;

  /// No description provided for @strengthHintAgeGroup.
  ///
  /// In en, this message translates to:
  /// **'Add the learner’s age group.'**
  String get strengthHintAgeGroup;

  /// No description provided for @strengthHintLevel.
  ///
  /// In en, this message translates to:
  /// **'Add your current reading level.'**
  String get strengthHintLevel;

  /// No description provided for @strengthHintLocation.
  ///
  /// In en, this message translates to:
  /// **'Add your country and time zone.'**
  String get strengthHintLocation;

  /// No description provided for @strengthHintPreferredGender.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred teacher gender.'**
  String get strengthHintPreferredGender;

  /// No description provided for @strengthHintPhotoOrNote.
  ///
  /// In en, this message translates to:
  /// **'Add a photo or a short note for teachers.'**
  String get strengthHintPhotoOrNote;

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
