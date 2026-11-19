// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Asatiza';

  @override
  String get tabHome => 'Home';

  @override
  String get tabTeachers => 'Teachers';

  @override
  String get tabChats => 'Chats';

  @override
  String get tabAlerts => 'Alerts';

  @override
  String get createPostAction => 'Create post';

  @override
  String get teachersTitle => 'Teachers';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get newPostTitle => 'New post';

  @override
  String get closeAction => 'Close';

  @override
  String get backAction => 'Back';

  @override
  String get logoLabel => 'Asatiza logo';

  @override
  String get loadingLabel => 'Loading';

  @override
  String get splashTagline => 'Find Quran teachers & students';

  @override
  String get skipAction => 'Skip';

  @override
  String get welcomeTitle1 => 'Learn the Quran with the right teacher';

  @override
  String get welcomeMessage1 =>
      'Find verified Tajweed, Hifz and Nazra teachers who match your language, time zone and goals.';

  @override
  String get welcomeTitle2 => 'Connect with verified teachers';

  @override
  String get welcomeMessage2 =>
      'Send a request with a short note. Once a teacher accepts, you can chat safely in a moderated community.';

  @override
  String get welcomeTitle3 => 'Share and grow together';

  @override
  String get welcomeMessage3 =>
      'Post Islamic reminders, Tajweed tips and your Hifz achievements, and learn from teachers you follow.';

  @override
  String slideOf(int current, int total) {
    return 'Slide $current of $total';
  }

  @override
  String get createAccountAction => 'Create account';

  @override
  String get haveAccountAction => 'I already have an account';

  @override
  String get signUpTitle => 'Create your account';

  @override
  String get signUpSubtitle =>
      'Join teachers and students learning the Quran together.';

  @override
  String get iAmA => 'I am a';

  @override
  String get roleStudent => 'Student';

  @override
  String get roleStudentDescription =>
      'I want to learn, or I’m signing up my child';

  @override
  String get roleTeacher => 'Teacher';

  @override
  String get roleTeacherDescription => 'I teach the Quran';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPasswordAction => 'Show password';

  @override
  String get hidePasswordAction => 'Hide password';

  @override
  String get passwordRuleLength => 'At least 8 characters';

  @override
  String get passwordRuleMatch => 'Passwords match';

  @override
  String get consentPrefix => 'I am 18 or older and agree to the ';

  @override
  String get termsLink => 'Terms';

  @override
  String get consentAnd => ' and ';

  @override
  String get privacyLink => 'Privacy Policy';

  @override
  String get consentSuffix => '. Parents may sign up for their child.';

  @override
  String get haveAccountQuestion => 'Already have an account? ';

  @override
  String get logInAction => 'Log in';

  @override
  String get errorInvalidEmail => 'Enter a valid email address';

  @override
  String get errorEmailRegistered =>
      'This email already has an account. Log in instead.';

  @override
  String get errorWrongCredentials => 'Email or password is not correct';

  @override
  String get errorInvalidCode =>
      'That code didn’t work. Check it and try again.';

  @override
  String get checkEmailTitle => 'Check your email';

  @override
  String get codeSentPrefix => 'We sent a 6-digit code to ';

  @override
  String get codeSentSuffix => '. Enter it below.';

  @override
  String get codeFieldLabel => '6-digit code';

  @override
  String get resendCodeIn => 'Resend code in ';

  @override
  String get resendCodeAction => 'Resend code';

  @override
  String get wrongEmailAction => 'Wrong email? Change it';

  @override
  String get spamFolderNote =>
      'Can’t find it? Check your Spam or Promotions folder. The code is valid for 10 minutes.';

  @override
  String get verifyAction => 'Verify';

  @override
  String get logInTitle => 'Welcome back';

  @override
  String get logInSubtitle => 'Assalamu alaikum! Log in to continue.';

  @override
  String get forgotPasswordAction => 'Forgot password?';

  @override
  String get newToAsatiza => 'New to Asatiza? ';

  @override
  String get resetStepEmail => 'Email';

  @override
  String get resetStepCode => 'Code';

  @override
  String get resetStepNewPassword => 'New password';

  @override
  String get resetTitle => 'Reset your password';

  @override
  String get resetSubtitle =>
      'Enter the email you signed up with. We’ll send you a 6-digit code.';

  @override
  String get sendCodeAction => 'Send code';

  @override
  String get enterCodeTitle => 'Enter the code';

  @override
  String get continueAction => 'Continue';

  @override
  String get newPasswordTitle => 'Create a new password';

  @override
  String get newPasswordSubtitle => 'Choose something you haven’t used before.';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get saveAndLogInAction => 'Save and log in';

  @override
  String setupStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get teacherSetupTitle1 => 'Let students see who you are';

  @override
  String get teacherSetupTitle2 => 'What do you teach?';

  @override
  String get teacherSetupTitle3 => 'Your classes and fee';

  @override
  String get addProfilePhoto => 'Add a profile photo';

  @override
  String get teacherPhotoHint =>
      'A clear, modest photo builds trust with parents and students.';

  @override
  String get headlineLabel => 'Headline';

  @override
  String get headlineHint =>
      'Shown under your name everywhere. 60 characters max.';

  @override
  String profilePercent(int percent) {
    return 'Profile $percent%';
  }

  @override
  String get subjectsLabel => 'Subjects';

  @override
  String get teachingLanguagesLabel => 'Languages you teach in';

  @override
  String get genderLabel => 'Gender';

  @override
  String get countryLabel => 'Country';

  @override
  String get timeZoneLabel => 'Time zone';

  @override
  String get bioLabel => 'Bio';

  @override
  String get experienceLabel => 'Experience (years)';

  @override
  String feeLabel(String currency) {
    return 'Fee ($currency)';
  }

  @override
  String get availableDaysLabel => 'Available days';

  @override
  String get uploadCertificatesAction => 'Upload certificates';

  @override
  String get uploadCertificatesHint => 'JPG or PDF';

  @override
  String certificatesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count certificates added',
      one: '1 certificate added',
    );
    return '$_temp0';
  }

  @override
  String get finishSetupAction => 'Finish setup';

  @override
  String get studentSetupTitle1 => 'Tell us about the learner';

  @override
  String get addPhotoOptional => 'Add a photo (optional)';

  @override
  String get studentPhotoHint =>
      'Your photo is never shown in the Students list. Teachers see it only on your profile.';

  @override
  String get learnerAgeGroupLabel => 'Learner age group';

  @override
  String get parentSetupNote =>
      'Setting up for your child? Choose Child. You keep the account and see every chat with their teacher.';

  @override
  String get studentSetupTitle2 => 'What would you like to learn?';

  @override
  String get currentLevelLabel => 'Current level';

  @override
  String get languagesLabel => 'Languages';

  @override
  String get studentSetupTitle3 => 'Your ideal teacher';

  @override
  String get preferredTeacherGenderLabel => 'Preferred teacher gender';

  @override
  String get lookingForTeacherLabel => 'Looking for a teacher';

  @override
  String get lookingForTeacherHint =>
      'Teachers can find you in the Students tab and send you requests.';

  @override
  String get shortNoteLabel => 'Short note (optional)';

  @override
  String get shortNotePlaceholder =>
      'For example: evenings after 6 pm work best for me.';

  @override
  String characterCounter(int count, int max) {
    return '$count / $max';
  }

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderAny => 'Any';

  @override
  String get subjectNooraniQaida => 'Noorani Qaida';

  @override
  String get subjectNazra => 'Nazra';

  @override
  String get subjectTajweed => 'Tajweed';

  @override
  String get subjectHifz => 'Hifz';

  @override
  String get subjectTafsir => 'Tafsir';

  @override
  String get subjectArabic => 'Arabic';

  @override
  String get subjectIslamicStudies => 'Islamic studies';

  @override
  String get languageUrdu => 'Urdu';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languagePunjabi => 'Punjabi';

  @override
  String get languagePashto => 'Pashto';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get ageGroupChild => 'Child';

  @override
  String get ageGroupTeen => 'Teen';

  @override
  String get ageGroupAdult => 'Adult';

  @override
  String get ageGroupChildRange => '6–12';

  @override
  String get ageGroupTeenRange => '13–17';

  @override
  String get ageGroupAdultRange => '18+';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelBeginnerDescription => 'Can’t read Arabic letters yet';

  @override
  String get levelReadsWithHelp => 'Can read with help';

  @override
  String get levelReadsWithHelpDescription => 'Reads slowly and makes mistakes';

  @override
  String get levelReadsFluently => 'Reads fluently';

  @override
  String get levelReadsFluentlyDescription => 'Wants to improve Tajweed';

  @override
  String get levelMemorising => 'Memorising';

  @override
  String get levelMemorisingDescription => 'Working on Hifz';

  @override
  String get feeUnitPerClass => 'Per class';

  @override
  String get feeUnitPerMonth => 'Per month';

  @override
  String get audienceChildren => 'Children';

  @override
  String get audienceWomen => 'Women';

  @override
  String get audienceMen => 'Men';

  @override
  String get audienceAll => 'Everyone';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayMondayInitial => 'M';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayTuesdayInitial => 'T';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayWednesdayInitial => 'W';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayThursdayInitial => 'T';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdayFridayInitial => 'F';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySaturdayInitial => 'S';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get weekdaySundayInitial => 'S';

  @override
  String get tagReminder => 'Reminder';

  @override
  String get tagTajweedTip => 'Tajweed tip';

  @override
  String get tagHifz => 'Hifz';

  @override
  String get tagQuestion => 'Question';

  @override
  String get tagClassAnnouncement => 'Class announcement';

  @override
  String get tagAchievement => 'Achievement';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonInappropriate => 'Inappropriate content';

  @override
  String get reportReasonHate => 'Hate or harassment';

  @override
  String get reportReasonFalseInformation => 'False information';

  @override
  String get reportReasonSomethingElse => 'Something else';

  @override
  String get searchPlaceholder => 'Search teachers, posts, subjects';

  @override
  String get myProfileAndSettings => 'My profile and settings';

  @override
  String strengthTitle(int percent) {
    return 'Your profile is $percent% complete';
  }

  @override
  String stepsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps left',
      one: '1 step left',
      zero: 'All done',
    );
    return '$_temp0';
  }

  @override
  String get completeProfileAction => 'Complete profile';

  @override
  String get hideAction => 'Hide';

  @override
  String get strengthHintPhoto => 'Add a profile photo to build trust.';

  @override
  String get strengthHintHeadline =>
      'Add a headline so students know what you teach.';

  @override
  String get strengthHintSubjects => 'Add the subjects you teach.';

  @override
  String get strengthHintLanguages => 'Add the languages you speak.';

  @override
  String get strengthHintBio => 'Write a short bio about your teaching.';

  @override
  String get strengthHintExperience => 'Add your years of experience.';

  @override
  String get strengthHintFee => 'Add your fee and available days.';

  @override
  String get strengthHintCertificate =>
      'Upload a certificate to get verified faster.';

  @override
  String get strengthHintGoals =>
      'Add your learning goal to reach teachers faster.';

  @override
  String get strengthHintAgeGroup => 'Add the learner’s age group.';

  @override
  String get strengthHintLevel => 'Add your current reading level.';

  @override
  String get strengthHintLocation => 'Add your country and time zone.';

  @override
  String get strengthHintPreferredGender =>
      'Choose your preferred teacher gender.';

  @override
  String get strengthHintPhotoOrNote =>
      'Add a photo or a short note for teachers.';

  @override
  String get verifiedTeacher => 'Verified teacher';

  @override
  String postMetaTeacher(String subject) {
    return '$subject teacher';
  }

  @override
  String postCounts(int likes, int comments) {
    String _temp0 = intl.Intl.pluralLogic(
      likes,
      locale: localeName,
      other: '$likes likes',
      one: '1 like',
    );
    String _temp1 = intl.Intl.pluralLogic(
      comments,
      locale: localeName,
      other: '$comments comments',
      one: '1 comment',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get likeAction => 'Like';

  @override
  String get likedAction => 'Liked';

  @override
  String get commentAction => 'Comment';

  @override
  String get reportAction => 'Report';

  @override
  String get replyAction => 'Reply';

  @override
  String get postOptionsAction => 'Post options';

  @override
  String get postPhotoLabel => 'Post photo';

  @override
  String get timeNow => 'now';

  @override
  String timeMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String timeHours(int hours) {
    return '${hours}h';
  }

  @override
  String get timeYesterday => 'Yesterday';

  @override
  String get emptyFeedTitle => 'Your feed is quiet';

  @override
  String get emptyFeedMessage =>
      'Connect with teachers to see their posts here.';

  @override
  String get findTeachersAction => 'Find teachers';

  @override
  String get postTitle => 'Post';

  @override
  String commentsHeading(int count) {
    return 'Comments ($count)';
  }

  @override
  String get writeCommentPlaceholder => 'Write a comment…';

  @override
  String get sendCommentAction => 'Send comment';

  @override
  String get postAction => 'Post';

  @override
  String get postingToEveryone => 'Posting to everyone';

  @override
  String get postPlaceholder =>
      'Share a reminder, a Tajweed tip or a question…';

  @override
  String get removePhotoAction => 'Remove photo';

  @override
  String get chooseTagLabel => 'Choose a tag';

  @override
  String get requiredLabel => 'Required';

  @override
  String get contentPolicyNote =>
      'Keep it Islamic and respectful. No music, politics, sectarian debate or ads.';

  @override
  String get photoAction => 'Photo';

  @override
  String postCounter(String count, String max) {
    return '$count / $max';
  }

  @override
  String get reportTitle => 'Report this post';

  @override
  String get reportSubtitle =>
      'Your report is anonymous. Our team reviews every report.';

  @override
  String get alsoBlockPrefix => 'Also block ';

  @override
  String get alsoBlockSuffix => '. They won’t see your profile or message you.';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get reportSentMessage => 'Thank you. Our team will review this post.';
}
