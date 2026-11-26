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
  String get errorNoConnection =>
      'No internet connection. Check it and try again.';

  @override
  String get errorSomethingWentWrong =>
      'Something went wrong. Please try again in a moment.';

  @override
  String get errorSamePassword =>
      'Choose a new password, not the one you used before.';

  @override
  String get errorWeakPassword =>
      'This password is too weak. Try a longer one with letters and numbers.';

  @override
  String get checkEmailTitle => 'Check your email';

  @override
  String get codeSentPrefix => 'We sent a 6-digit code to ';

  @override
  String get codeSentSuffix => '. Enter it below.';

  @override
  String get resetCodeSentPrefix => 'If an account exists for ';

  @override
  String get resetCodeSentSuffix =>
      ', we’ve sent a 6-digit code. Check your Spam folder too.';

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
  String get uploadCertificatesAction => 'Upload certificate';

  @override
  String get uploadCertificatesHint => 'PDF';

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
      'Shows teachers that you\'re looking for a teacher now.';

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

  @override
  String get tabStudents => 'Students';

  @override
  String get studentsTitle => 'Students';

  @override
  String get discoverSearchPlaceholder => 'Name, subject or headline';

  @override
  String get searchTeachersLabel => 'Search teachers';

  @override
  String get searchStudentsLabel => 'Search students';

  @override
  String filtersButtonLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filters, $count active',
      one: 'Filters, 1 active',
      zero: 'Filters',
    );
    return '$_temp0';
  }

  @override
  String teacherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teachers',
      one: '1 teacher',
    );
    return '$_temp0';
  }

  @override
  String studentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '1 student',
    );
    return '$_temp0';
  }

  @override
  String teacherGenderChip(String gender) {
    return '$gender teacher';
  }

  @override
  String wantsSubjectChip(String subject) {
    return 'Wants $subject';
  }

  @override
  String feeRange(int min, int max) {
    return '\$$min – \$$max';
  }

  @override
  String get teachesChildrenLabel => 'Teaches children';

  @override
  String get connectAction => 'Connect';

  @override
  String get connectedLabel => 'Connected';

  @override
  String get requestedLabel => 'Requested';

  @override
  String get acceptAction => 'Accept';

  @override
  String get declineAction => 'Decline';

  @override
  String get messageAction => 'Message';

  @override
  String get viewProfileAction => 'View profile';

  @override
  String cityAndTimeZone(String place, String timeZone) {
    return '$place · $timeZone';
  }

  @override
  String yearsShort(int count) {
    return '$count yrs';
  }

  @override
  String feePerMonthShort(int amount) {
    return '\$$amount/mo';
  }

  @override
  String feePerClassShort(int amount) {
    return '\$$amount/class';
  }

  @override
  String feePerMonthLong(int amount) {
    return '\$$amount / month';
  }

  @override
  String feePerClassLong(int amount) {
    return '\$$amount / class';
  }

  @override
  String get lookingPill => 'Looking';

  @override
  String quotedNote(String note) {
    return '“$note”';
  }

  @override
  String noResultsTitle(String query) {
    return 'No results for “$query”';
  }

  @override
  String get noFilterMatchesTitle => 'Nobody matches these filters';

  @override
  String get noResultsMessage =>
      'Try a different word, or remove some filters.';

  @override
  String get clearFiltersAction => 'Clear filters';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get resetAction => 'Reset';

  @override
  String get subjectFilterLabel => 'Subject';

  @override
  String get teacherGenderLabel => 'Teacher gender';

  @override
  String get languageFilterLabel => 'Language';

  @override
  String get monthlyFeeLabel => 'Monthly fee';

  @override
  String get experienceFilterLabel => 'Experience';

  @override
  String experienceYearsPlus(int years) {
    return '$years+ years';
  }

  @override
  String showTeachersAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count teachers',
      one: 'Show 1 teacher',
      zero: 'No teachers to show',
    );
    return '$_temp0';
  }

  @override
  String showStudentsAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count students',
      one: 'Show 1 student',
      zero: 'No students to show',
    );
    return '$_temp0';
  }

  @override
  String get subjectWantedLabel => 'Subject wanted';

  @override
  String get studentGenderLabel => 'Student gender';

  @override
  String get countryTimeZoneLabel => 'Country / time zone';

  @override
  String get anyCountry => 'Any country';

  @override
  String get levelFilterLabel => 'Level';

  @override
  String get shareProfileAction => 'Share profile';

  @override
  String get reportOrBlockAction => 'Report or block';

  @override
  String profileShareText(String name, String headline) {
    return '$name — $headline · on Asatiza';
  }

  @override
  String get profileCopiedMessage => 'Profile details copied';

  @override
  String blockUserTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get blockUserMessage =>
      'They won’t see your profile or message you, and you won’t see them in lists or the feed.';

  @override
  String get blockAction => 'Block';

  @override
  String userBlockedMessage(String name) {
    return '$name is blocked';
  }

  @override
  String get profileUnavailableTitle => 'Profile not available';

  @override
  String get profileLoadFailedTitle => 'Couldn’t load your profile';

  @override
  String get profileUnavailableMessage => 'This account may have been deleted.';

  @override
  String learnerLabel(String ageGroup) {
    return '$ageGroup learner';
  }

  @override
  String get connectFirstHint => 'Connect first to send a message';

  @override
  String get statExperience => 'Experience';

  @override
  String get statConnections => 'Connections';

  @override
  String get statPosts => 'Posts';

  @override
  String get aboutLabel => 'About';

  @override
  String teachesAudience(String audience) {
    return 'Teaches $audience';
  }

  @override
  String get feeShortLabel => 'Fee';

  @override
  String availabilityLine(String days, String from, String to) {
    return '$days · $from–$to';
  }

  @override
  String get noteLabel => 'Note';

  @override
  String get wantsToLearnLabel => 'Wants to learn';

  @override
  String levelLine(String level) {
    return 'Level: $level';
  }

  @override
  String speaksLine(String languages) {
    return 'Speaks $languages';
  }

  @override
  String get prefersFemaleTeacher => 'Prefers a female teacher';

  @override
  String get prefersMaleTeacher => 'Prefers a male teacher';

  @override
  String get prefersAnyTeacher => 'Happy with any teacher';

  @override
  String connectWithTitle(String name) {
    return 'Connect with $name';
  }

  @override
  String connectSheetSubtitle(String gender) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      'male': 'Once he accepts, you can chat.',
      'female': 'Once she accepts, you can chat.',
      'other': 'Once they accept, you can chat.',
    });
    return '$_temp0';
  }

  @override
  String get addNoteLabel => 'Add a note (optional)';

  @override
  String get connectNotePlaceholder =>
      'Say salam and tell them what you would like to learn';

  @override
  String get sendRequestAction => 'Send request';

  @override
  String requestSentMessage(String name) {
    return 'Request sent to $name';
  }

  @override
  String get connectNoteTooLongError => 'Keep your note to 200 characters.';

  @override
  String get connectProfileIncompleteError =>
      'Complete at least 60% of your profile to send requests.';

  @override
  String get connectAlreadyError =>
      'You already have a request or connection with this person.';

  @override
  String get connectionsTitle => 'My connections';

  @override
  String connectedTab(int count) {
    return 'Connected $count';
  }

  @override
  String requestsTab(int count) {
    return 'Requests $count';
  }

  @override
  String sentTab(int count) {
    return 'Sent $count';
  }

  @override
  String studentLearningSubtitle(String subject) {
    return 'Student · Learning $subject';
  }

  @override
  String get removeOrBlockAction => 'Remove or block';

  @override
  String get removeConnectionAction => 'Remove connection';

  @override
  String get cancelRequestAction => 'Cancel request';

  @override
  String get emptyConnectionsTitle => 'No connections yet';

  @override
  String get emptyConnectionsMessage =>
      'Send a request from a teacher’s profile.';

  @override
  String get emptyRequestsTitle => 'No requests';

  @override
  String get emptyRequestsMessage =>
      'New connection requests will show up here.';

  @override
  String get emptySentTitle => 'No sent requests';

  @override
  String get emptySentMessage =>
      'Requests you send stay here until they are answered.';

  @override
  String get searchLabel => 'Search';

  @override
  String get clearSearchAction => 'Clear search';

  @override
  String get searchTabAll => 'All';

  @override
  String get searchTabPosts => 'Posts';

  @override
  String seeAllCount(int count) {
    return 'See all $count';
  }

  @override
  String get chatOptionsAction => 'Chat options';

  @override
  String get chatPhotoLabel => 'Photo';

  @override
  String get chatUnavailableTitle => 'Chat not available';

  @override
  String get chatUnavailableMessage =>
      'You can chat once your connection request is accepted.';

  @override
  String get connectedToday => 'Connected today';

  @override
  String connectedDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Connected $days days ago',
      one: 'Connected yesterday',
    );
    return '$_temp0';
  }

  @override
  String get dayToday => 'Today';

  @override
  String get emptyChatsTitle => 'No chats yet';

  @override
  String get emptyChatsMessage =>
      'Chats open once a teacher accepts your request.';

  @override
  String get emptyChatsMessageTeacher =>
      'Chats open once you accept a student’s request.';

  @override
  String get noChatResultsMessage => 'Try another name.';

  @override
  String get emptyNotificationsTitle => 'You’re all caught up';

  @override
  String get emptyNotificationsMessage =>
      'Requests, likes and comments will show up here.';

  @override
  String get linkCopiedMessage => 'Link copied';

  @override
  String get markAllReadAction => 'Mark all read';

  @override
  String get messageFieldHint => 'Message';

  @override
  String get messageReadLabel => 'Read';

  @override
  String get notifWantsToConnect => 'wants to connect with you';

  @override
  String get notifAccepted => 'accepted your request. Say salam!';

  @override
  String notifCommented(String text) {
    return 'commented: “$text”';
  }

  @override
  String notifLiked(int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: 'and $others others liked your post',
      one: 'and 1 other liked your post',
      zero: 'liked your post',
    );
    return '$_temp0';
  }

  @override
  String get notifApprovedPrefix => 'Your teacher profile was ';

  @override
  String get notifApprovedWord => 'approved';

  @override
  String get notifApprovedSuffix => '. You now appear in search.';

  @override
  String get notifNeedsChanges =>
      'Your teacher profile needs a few changes before approval. Check your email for details.';

  @override
  String get notificationsNew => 'New';

  @override
  String get notificationsEarlier => 'Earlier';

  @override
  String get searchChatsLabel => 'Search chats';

  @override
  String get sendAction => 'Send';

  @override
  String get sendPhotoAction => 'Send a photo';

  @override
  String get sentAPhoto => 'Sent a photo';

  @override
  String youPrefix(String text) {
    return 'You: $text';
  }

  @override
  String subjectTeacher(String subject) {
    return '$subject teacher';
  }

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get ageGroupFieldLabel => 'Age group';

  @override
  String appVersionLabel(String version) {
    return 'Asatiza $version';
  }

  @override
  String blockedOn(String date) {
    return 'Blocked on $date';
  }

  @override
  String get blockedUsersIntro =>
      'Blocked people can’t see your profile or posts, or message you. They aren’t told that you blocked them.';

  @override
  String get blockedUsersTitle => 'Blocked users';

  @override
  String certificatesApproved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count certificates · approved',
      one: '1 certificate · approved',
    );
    return '$_temp0';
  }

  @override
  String certificatesInReview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count certificates · in review',
      one: '1 certificate · in review',
    );
    return '$_temp0';
  }

  @override
  String certificatesApprovedShort(int count) {
    return '$count approved';
  }

  @override
  String certificatesInReviewShort(int count) {
    return '$count in review';
  }

  @override
  String get certificatesLabel => 'Certificates';

  @override
  String get noCertificatesYet => 'No certificates yet';

  @override
  String get changePasswordIntro =>
      'Use at least 8 characters. You’ll stay logged in on this phone.';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePhotoAction => 'Change photo';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get currentPasswordWrong => 'That password isn’t right.';

  @override
  String get confirmNewPasswordLabel => 'Confirm new password';

  @override
  String get passwordRuleDifferent => 'Different from your current password';

  @override
  String get passwordChangedMessage => 'Password changed';

  @override
  String get savePasswordAction => 'Save password';

  @override
  String get forgotCurrentPasswordAction => 'Forgot your current password?';

  @override
  String get resetByEmailTitle => 'Reset by email?';

  @override
  String get resetByEmailMessage =>
      'You’ll be logged out and we’ll email you a code to set a new password.';

  @override
  String connectionsCountAction(int count) {
    return 'Connections ($count)';
  }

  @override
  String get contentPolicyTitle => 'Content policy';

  @override
  String get contentAimTitle => 'Our aim';

  @override
  String get contentAimBody =>
      'Asatiza is a place to learn and teach the Quran. Everything you share should be respectful and beneficial.';

  @override
  String get contentShareTitle => 'What you can share';

  @override
  String get contentShare1 =>
      'Quranic verses, hadith and Islamic reminders with their source';

  @override
  String get contentShare2 =>
      'Tajweed and Hifz tips, questions and study routines';

  @override
  String get contentShare3 =>
      'Class announcements and student achievements, with permission';

  @override
  String get contentNotAllowedTitle => 'Not allowed';

  @override
  String get contentNotAllowed1 => 'Music, songs or music videos';

  @override
  String get contentNotAllowed2 => 'Politics or sectarian debate and attacks';

  @override
  String get contentNotAllowed3 =>
      'Ads, spam or paid promotions outside your profile';

  @override
  String get contentNotAllowed4 =>
      'Hate, harassment or private details of others';

  @override
  String get contentReportingTitle => 'Reporting and review';

  @override
  String get contentReportingBody =>
      'Tap Report on any post, comment or profile. A post reported by three people is hidden until our team reviews it. Breaking these rules can lead to a warning or a ban.';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get privacyCollectTitle => 'What we collect';

  @override
  String get privacyCollectBody =>
      'Your name, email, role, profile details and photo, the posts, comments and messages you send, a device token for notifications, and crash reports.';

  @override
  String get privacyUseTitle => 'How we use it';

  @override
  String get privacyUseBody =>
      'To run your account, show your profile to the right people, deliver messages and notifications, keep the community safe and fix bugs. We never sell your data.';

  @override
  String get privacySeeTitle => 'Who can see what';

  @override
  String get privacySeeBody =>
      'Your profile and posts are visible to signed-in members. Messages are visible only to you and the person you chat with. Certificates are seen only by our review team.';

  @override
  String get privacyChoicesTitle => 'Your choices';

  @override
  String get privacyChoicesBody =>
      'Edit your profile any time, turn notifications off in Settings, block people, and delete your account from Settings or our website.';

  @override
  String get termsTitle => 'Terms of use';

  @override
  String get termsJoinTitle => 'Who can join';

  @override
  String get termsJoinBody =>
      'You must be 18 or older. A parent or guardian may create a student account for their child and is responsible for it.';

  @override
  String get termsAccountTitle => 'Your account';

  @override
  String get termsAccountBody =>
      'Keep your password safe and your details accurate. Teachers must only upload certificates that are genuinely theirs.';

  @override
  String get termsClassesTitle => 'Classes and fees';

  @override
  String get termsClassesBody =>
      'Teachers and students arrange class times, video links and fees directly. Asatiza is not a party to these arrangements and does not handle payments.';

  @override
  String get termsContentTitle => 'Content';

  @override
  String get termsContentBody =>
      'You own what you post, and you give Asatiza permission to show it in the app. All content must follow our Content policy.';

  @override
  String get termsEndingTitle => 'Ending your account';

  @override
  String get termsEndingBody =>
      'You can delete your account at any time. We may suspend accounts that break these terms or put others at risk.';

  @override
  String get policyLastUpdated => 'Last updated 18 November 2026';

  @override
  String get deleteAccountAction => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountMessage =>
      'This is permanent and can’t be undone. The following will be deleted:';

  @override
  String get deleteItemProfile => 'Your profile, photo and certificates';

  @override
  String get deleteItemPosts => 'Your posts, comments and likes';

  @override
  String get deleteItemChats => 'Your chats and shared photos';

  @override
  String get deleteItemConnections => 'Your connections and requests';

  @override
  String get deleteAccountConfirm =>
      'I understand that my account and data will be permanently deleted.';

  @override
  String get deleteAccountFailed =>
      'Your account couldn’t be deleted. Please try again.';

  @override
  String get editProfileAction => 'Edit profile';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get saveAction => 'Save';

  @override
  String get profileSavedMessage => 'Profile saved';

  @override
  String get nameRequiredError => 'Enter your name.';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get iTeachLabel => 'I teach';

  @override
  String get learningLabel => 'Learning';

  @override
  String get wantToLearnLabel => 'What I want to learn';

  @override
  String get lookingSwitchHint =>
      'Shows teachers that you\'re looking for a teacher now.';

  @override
  String get myPostsLabel => 'My posts';

  @override
  String get noPostsYet => 'You haven’t posted yet.';

  @override
  String get myProfileTitle => 'My profile';

  @override
  String get qualificationsLabel => 'Qualifications';

  @override
  String get qualificationsPlaceholder =>
      'e.g. Ijazah in Hafs, Hifz from Jamia Ashrafia';

  @override
  String get removeCertificateAction => 'Remove certificate';

  @override
  String get uploadCertificateAction => 'Upload certificate';

  @override
  String get logOutAction => 'Log out';

  @override
  String get logOutTitle => 'Log out of Asatiza?';

  @override
  String get logOutMessage =>
      'You can log back in any time with your email and password.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPrivacySafety => 'Privacy & safety';

  @override
  String get settingConnectionRequests => 'Connection requests';

  @override
  String get settingNewMessages => 'New messages';

  @override
  String get settingComments => 'Comments on my posts';

  @override
  String get settingLikes => 'Likes';

  @override
  String get noBlockedUsersTitle => 'No blocked users';

  @override
  String get noBlockedUsersMessage =>
      'If you block someone from a profile, post or chat, they’ll appear here.';

  @override
  String get unblockAction => 'Unblock';

  @override
  String get photoSourceTitle => 'Profile photo';

  @override
  String get photoSourceCamera => 'Take a photo';

  @override
  String get photoSourceGallery => 'Choose from gallery';

  @override
  String get certificateInstructions =>
      'Upload one certificate (ijazah, sanad or diploma) as a PDF, up to 3 MB. Make sure your name and the issuing institute are clear. Only our review team can see it.';

  @override
  String get uploadErrorTooLarge =>
      'This file is too large. A certificate PDF can be up to 3 MB.';

  @override
  String get uploadErrorNotPdf => 'Only PDF files can be uploaded.';

  @override
  String get uploadErrorCertificateLimit =>
      'You can upload one certificate. Remove it to upload a different one.';

  @override
  String get uploadErrorFailed => 'Upload failed. Please try again.';

  @override
  String get openCertificateAction => 'Open certificate';

  @override
  String get certificateViewerTitle => 'Certificate';

  @override
  String get certificateOpenFailedTitle => 'Couldn’t open the certificate';

  @override
  String get certificateOpenFailedMessage =>
      'Check your connection and try again.';

  @override
  String get retryAction => 'Try again';

  @override
  String requiredFieldsMissing(String fields) {
    return 'Fill in to save: $fields';
  }

  @override
  String get discoverLoadFailedTitle => 'Couldn’t load people';

  @override
  String get discoverLoadFailedMessage =>
      'Check your connection and try again.';

  @override
  String certificatePageIndicator(int page, int total) {
    return '$page / $total';
  }
}
