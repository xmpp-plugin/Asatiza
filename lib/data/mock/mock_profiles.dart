import '../models/enums/fee_unit.dart';
import '../models/enums/gender.dart';
import '../models/enums/learner_age_group.dart';
import '../models/enums/learner_level.dart';
import '../models/enums/subject.dart';
import '../models/enums/teacher_gender_preference.dart';
import '../models/enums/teaches_audience.dart';
import '../models/enums/teaching_language.dart';
import '../models/enums/user_role.dart';
import '../models/enums/weekday.dart';
import '../models/profile.dart';
import '../models/student_details.dart';
import '../models/teacher_details.dart';

/// Stable mock ids (UUID strings, like Supabase auth ids).
abstract final class MockIds {
  static String _id(int n) =>
      '00000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';

  // Teachers
  static final String ahmed = _id(1);
  static final String maryam = _id(2);
  static final String khadija = _id(3);
  static final String usman = _id(4);
  static final String amina = _id(5);
  static final String bilalAhmad = _id(6);
  static final String fatimaZahra = _id(7);
  static final String hamza = _id(8);
  static final String sumaya = _id(9);
  static final String imran = _id(10);
  static final String zainab = _id(11);
  static final String abdullah = _id(12);
  static final String hafsa = _id(13);
  static final String saad = _id(14);
  static final String aishaBakr = _id(15);
  static final String yasir = _id(16);
  static final String rabia = _id(17);
  static final String kashif = _id(18);
  static final String nida = _id(19);
  static final String zubair = _id(20);

  // Students
  static final String ayesha = _id(101);
  static final String hira = _id(102);
  static final String yusuf = _id(103);
  static final String sana = _id(104);
  static final String omar = _id(105);
  static final String maham = _id(106);
  static final String bilalKhan = _id(107);
  static final String zara = _id(108);
  static final String hamid = _id(109);
  static final String noor = _id(110);
  static final String ibrahim = _id(111);
  static final String laiba = _id(112);
  static final String daniyal = _id(113);
  static final String mariamNadeem = _id(114);
}

/// Emails of the two built-in mock accounts (role comes from the profile).
abstract final class MockAccounts {
  static const String studentEmail = 'ayesha.khan@gmail.com';
  static const String teacherEmail = 'ahmed.khan@gmail.com';
}

/// The signed-in user's connections, used for feed order.
Set<String> mockConnectedIds(String userId) {
  if (userId == MockIds.ayesha) {
    return <String>{MockIds.ahmed, MockIds.maryam, MockIds.khadija};
  }
  if (userId == MockIds.ahmed) {
    return <String>{MockIds.ayesha, MockIds.hira, MockIds.yusuf};
  }
  return const <String>{};
}

/// Seed profiles: 20 teachers and 14 students, created relative to [now].
List<Profile> buildMockProfiles(DateTime now) {
  Profile teacher(
    String id,
    String name, {
    required Gender gender,
    required String city,
    required String country,
    required String timeZone,
    required String headline,
    required List<Subject> subjects,
    required List<TeachingLanguage> languages,
    required int years,
    required int fee,
    String currency = 'PKR',
    FeeUnit unit = FeeUnit.perMonth,
    required Set<Weekday> days,
    int from = 17 * 60,
    int to = 21 * 60,
    required Set<TeachesAudience> teaches,
    required String bio,
    bool verified = true,
    bool certificate = true,
    String? email,
    int joinedDaysAgo = 120,
  }) {
    return Profile(
      id: id,
      role: UserRole.teacher,
      fullName: name,
      email: email,
      createdAt: now.subtract(Duration(days: joinedDaysAgo)),
      headline: headline,
      gender: gender,
      city: city,
      country: country,
      timeZone: timeZone,
      languages: languages,
      bio: bio,
      isVerified: verified,
      teacherDetails: TeacherDetails(
        subjects: subjects,
        experienceYears: years,
        feeAmount: fee,
        feeCurrency: currency,
        feeUnit: unit,
        availableDays: days,
        availableFromMinutes: from,
        availableToMinutes: to,
        teaches: teaches,
        certificatePaths: certificate
            ? <String>['certificates/$id/ijazah.pdf']
            : const <String>[],
      ),
    );
  }

  Profile student(
    String id,
    String name, {
    required Gender gender,
    required String city,
    required String country,
    required String timeZone,
    required LearnerAgeGroup ageGroup,
    required List<Subject> goals,
    required LearnerLevel level,
    required List<TeachingLanguage> languages,
    TeacherGenderPreference preference = TeacherGenderPreference.any,
    bool looking = true,
    String? note,
    String? email,
    int joinedDaysAgo = 60,
  }) {
    return Profile(
      id: id,
      role: UserRole.student,
      fullName: name,
      email: email,
      createdAt: now.subtract(Duration(days: joinedDaysAgo)),
      gender: gender,
      city: city,
      country: country,
      timeZone: timeZone,
      languages: languages,
      studentDetails: StudentDetails(
        ageGroup: ageGroup,
        goals: goals,
        level: level,
        preferredTeacherGender: preference,
        lookingForTeacher: looking,
        note: note,
      ),
    );
  }

  const mwfs = <Weekday>{
    Weekday.monday,
    Weekday.wednesday,
    Weekday.friday,
    Weekday.saturday,
  };
  const monThu = <Weekday>{
    Weekday.monday,
    Weekday.tuesday,
    Weekday.wednesday,
    Weekday.thursday,
  };
  const weekend = <Weekday>{Weekday.saturday, Weekday.sunday};
  const weekdays = <Weekday>{
    Weekday.monday,
    Weekday.tuesday,
    Weekday.wednesday,
    Weekday.thursday,
    Weekday.friday,
  };

  return <Profile>[
    teacher(
      MockIds.ahmed,
      'Qari Ahmed Khan',
      email: MockAccounts.teacherEmail,
      gender: Gender.male,
      city: 'Lahore',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Hafiz & Tajweed teacher, 8 years',
      subjects: const [Subject.tajweed, Subject.hifz, Subject.nazra],
      languages: const [TeachingLanguage.urdu, TeachingLanguage.english],
      years: 8,
      fee: 6000,
      days: mwfs,
      teaches: const {TeachesAudience.children, TeachesAudience.men},
      bio:
          'Completed Hifz at Jamia Ashrafia, Lahore. I teach Tajweed online to children and adults with patience and a clear weekly plan.',
      joinedDaysAgo: 210,
    ),
    teacher(
      MockIds.maryam,
      'Ustadha Maryam Siddiqui',
      gender: Gender.female,
      city: 'Lahore',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Hifz & Tajweed for sisters and children',
      subjects: const [Subject.hifz, Subject.tajweed],
      languages: const [TeachingLanguage.urdu, TeachingLanguage.english],
      years: 11,
      fee: 6000,
      days: monThu,
      from: 16 * 60,
      to: 20 * 60,
      teaches: const {TeachesAudience.children, TeachesAudience.women},
      bio:
          'Hafiza and Tajweed teacher for sisters and children. Small groups, gentle correction and a revision plan for every student.',
      joinedDaysAgo: 190,
    ),
    teacher(
      MockIds.khadija,
      'Ustadha Khadija Noor',
      gender: Gender.female,
      city: 'Karachi',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Tajweed & Nazra, ijazah in Hafs',
      subjects: const [Subject.tajweed, Subject.nazra],
      languages: const [TeachingLanguage.urdu, TeachingLanguage.arabic],
      years: 6,
      fee: 4500,
      days: weekdays,
      from: 15 * 60,
      to: 19 * 60,
      teaches: const {TeachesAudience.women, TeachesAudience.children},
      bio:
          'I hold an ijazah in the riwayah of Hafs. I help beginners move from Nazra to confident recitation with correct makharij.',
    ),
    teacher(
      MockIds.usman,
      'Hafiz Usman Tariq',
      gender: Gender.male,
      city: 'Islamabad',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Hifz teacher for boys, 12 years',
      subjects: const [Subject.hifz, Subject.nooraniQaida],
      languages: const [TeachingLanguage.urdu, TeachingLanguage.punjabi],
      years: 12,
      fee: 7000,
      days: weekdays,
      from: 16 * 60,
      to: 19 * 60,
      teaches: const {TeachesAudience.children},
      bio:
          'Twelve years teaching Hifz to boys aged 8 to 14. Daily sabaq, sabqi and manzil with a weekly progress note for parents.',
    ),
    teacher(
      MockIds.amina,
      'Ustadha Amina Yusuf',
      gender: Gender.female,
      city: 'Birmingham',
      country: 'United Kingdom',
      timeZone: 'GMT+0',
      headline: 'Noorani Qaida & Nazra for young children',
      subjects: const [Subject.nooraniQaida, Subject.nazra],
      languages: const [TeachingLanguage.english, TeachingLanguage.urdu],
      years: 5,
      fee: 15,
      currency: 'GBP',
      unit: FeeUnit.perClass,
      days: monThu,
      from: 17 * 60 + 30,
      to: 19 * 60 + 30,
      teaches: const {TeachesAudience.children},
      bio:
          'Primary teacher by training. I make Noorani Qaida fun for 5 to 9 year olds with short, focused 30-minute lessons.',
    ),
    teacher(
      MockIds.bilalAhmad,
      'Shaykh Bilal Ahmad',
      gender: Gender.male,
      city: 'Peshawar',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Tafsir & Arabic for adults',
      subjects: const [Subject.tafsir, Subject.arabic, Subject.islamicStudies],
      languages: const [
        TeachingLanguage.pashto,
        TeachingLanguage.urdu,
        TeachingLanguage.arabic,
      ],
      years: 15,
      fee: 8000,
      days: weekend,
      from: 20 * 60,
      to: 22 * 60,
      teaches: const {TeachesAudience.men},
      bio:
          'Graduate of Darul Uloom Haqqania. Weekly Tafsir circles and Quranic Arabic for adults who want to understand what they recite.',
      joinedDaysAgo: 300,
    ),
    teacher(
      MockIds.fatimaZahra,
      'Ustadha Fatima Zahra',
      gender: Gender.female,
      city: 'Toronto',
      country: 'Canada',
      timeZone: 'GMT−5',
      headline: 'Tajweed for sisters, ijazah in Hafs',
      subjects: const [Subject.tajweed],
      languages: const [TeachingLanguage.english, TeachingLanguage.arabic],
      years: 9,
      fee: 30,
      currency: 'CAD',
      unit: FeeUnit.perClass,
      days: mwfs,
      from: 18 * 60,
      to: 21 * 60,
      teaches: const {TeachesAudience.women},
      bio:
          'Ijazah holder teaching Tajweed to sisters in North America. Evening classes in Eastern time, one-to-one or in pairs.',
    ),
    teacher(
      MockIds.hamza,
      'Qari Hamza Saleem',
      gender: Gender.male,
      city: 'Faisalabad',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Tajweed & Hifz revision',
      subjects: const [Subject.tajweed, Subject.hifz],
      languages: const [TeachingLanguage.urdu, TeachingLanguage.punjabi],
      years: 7,
      fee: 5000,
      days: weekdays,
      teaches: const {TeachesAudience.children, TeachesAudience.men},
      bio:
          'I help huffaz keep their Hifz strong with structured muraja\'ah and careful Tajweed correction.',
    ),
    teacher(
      MockIds.sumaya,
      'Ustadha Sumaya Rehman',
      gender: Gender.female,
      city: 'Rawalpindi',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Nazra & Islamic studies for teens',
      subjects: const [Subject.nazra, Subject.islamicStudies],
      languages: const [TeachingLanguage.urdu, TeachingLanguage.english],
      years: 4,
      fee: 4000,
      days: monThu,
      teaches: const {TeachesAudience.children, TeachesAudience.women},
      bio:
          'Teaching Nazra and basic fiqh of worship to teenage girls, with plenty of room for their questions.',
    ),
    teacher(
      MockIds.imran,
      'Maulana Imran Qureshi',
      gender: Gender.male,
      city: 'Multan',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Islamic studies & Arabic grammar',
      subjects: const [Subject.arabic, Subject.islamicStudies],
      languages: const [TeachingLanguage.urdu, TeachingLanguage.arabic],
      years: 14,
      fee: 6500,
      days: weekend,
      from: 19 * 60,
      to: 22 * 60,
      teaches: const {TeachesAudience.all},
      bio:
          'Fourteen years teaching nahw and sarf. I teach Arabic grammar through the ayaat you already know.',
      joinedDaysAgo: 260,
    ),
    teacher(
      MockIds.zainab,
      'Ustadha Zainab Malik',
      gender: Gender.female,
      city: 'Manchester',
      country: 'United Kingdom',
      timeZone: 'GMT+0',
      headline: 'Hifz for girls, weekend classes',
      subjects: const [Subject.hifz],
      languages: const [TeachingLanguage.english, TeachingLanguage.urdu],
      years: 6,
      fee: 60,
      currency: 'GBP',
      days: weekend,
      from: 10 * 60,
      to: 13 * 60,
      teaches: const {TeachesAudience.children, TeachesAudience.women},
      bio:
          'Weekend Hifz classes for girls in the UK, with a monthly review call for parents.',
    ),
    teacher(
      MockIds.abdullah,
      'Qari Abdullah Farooq',
      gender: Gender.male,
      city: 'Karachi',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Noorani Qaida for beginners of all ages',
      subjects: const [Subject.nooraniQaida, Subject.nazra],
      languages: const [TeachingLanguage.urdu, TeachingLanguage.english],
      years: 10,
      fee: 3500,
      days: weekdays,
      from: 14 * 60,
      to: 18 * 60,
      teaches: const {TeachesAudience.all},
      bio:
          'It is never too late to start. I teach Noorani Qaida to children, adults and new Muslims, step by step.',
    ),
    teacher(
      MockIds.hafsa,
      'Ustadha Hafsa Iqbal',
      gender: Gender.female,
      city: 'Islamabad',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Tajweed & Tafsir circles for women',
      subjects: const [Subject.tajweed, Subject.tafsir],
      languages: const [TeachingLanguage.urdu, TeachingLanguage.english],
      years: 8,
      fee: 5500,
      days: monThu,
      from: 10 * 60,
      to: 13 * 60,
      teaches: const {TeachesAudience.women},
      bio:
          'Morning Tajweed and Tafsir circles for women, with notes after every class.',
    ),
    teacher(
      MockIds.saad,
      'Hafiz Saad Anwar',
      gender: Gender.male,
      city: 'Lahore',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Hifz & muraja\'ah plans',
      subjects: const [Subject.hifz],
      languages: const [TeachingLanguage.urdu],
      years: 5,
      fee: 5000,
      days: weekdays,
      from: 5 * 60 + 30,
      to: 8 * 60,
      teaches: const {TeachesAudience.children, TeachesAudience.men},
      bio:
          'Fajr-time Hifz sessions with a personal revision schedule for each student.',
    ),
    teacher(
      MockIds.aishaBakr,
      'Ustadha Aisha Bakr',
      gender: Gender.female,
      city: 'Dubai',
      country: 'United Arab Emirates',
      timeZone: 'GMT+4',
      headline: 'Arabic & Quran for children abroad',
      subjects: const [Subject.arabic, Subject.nazra],
      languages: const [
        TeachingLanguage.arabic,
        TeachingLanguage.english,
        TeachingLanguage.urdu,
      ],
      years: 7,
      fee: 100,
      currency: 'AED',
      unit: FeeUnit.perClass,
      days: mwfs,
      from: 16 * 60,
      to: 19 * 60,
      teaches: const {TeachesAudience.children},
      bio:
          'Helping children who grow up outside the Arab world read the Quran and speak simple Arabic.',
    ),
    teacher(
      MockIds.yasir,
      'Qari Yasir Hussain',
      gender: Gender.male,
      city: 'Sialkot',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Tajweed with qira\'at basics',
      subjects: const [Subject.tajweed],
      languages: const [TeachingLanguage.urdu, TeachingLanguage.punjabi],
      years: 9,
      fee: 6000,
      days: mwfs,
      teaches: const {TeachesAudience.men, TeachesAudience.children},
      bio:
          'Tajweed for students who already read fluently and want to polish their recitation.',
    ),
    teacher(
      MockIds.rabia,
      'Ustadha Rabia Shah',
      gender: Gender.female,
      city: 'Hyderabad',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Noorani Qaida & Nazra, patient with kids',
      subjects: const [Subject.nooraniQaida, Subject.nazra],
      languages: const [TeachingLanguage.urdu],
      years: 3,
      fee: 3000,
      days: weekdays,
      teaches: const {TeachesAudience.children},
      bio: 'Patient Qaida and Nazra lessons for young children, in Urdu.',
      verified: false,
      certificate: false,
      joinedDaysAgo: 12,
    ),
    teacher(
      MockIds.kashif,
      'Mufti Kashif Raza',
      gender: Gender.male,
      city: 'Lahore',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Tafsir & fiqh of worship',
      subjects: const [Subject.tafsir, Subject.islamicStudies],
      languages: const [TeachingLanguage.urdu, TeachingLanguage.english],
      years: 16,
      fee: 9000,
      days: weekend,
      from: 20 * 60,
      to: 22 * 60,
      teaches: const {TeachesAudience.all},
      bio:
          'Weekend Tafsir of Juz Amma and practical fiqh of salah and fasting.',
      joinedDaysAgo: 330,
    ),
    teacher(
      MockIds.nida,
      'Ustadha Nida Kamal',
      gender: Gender.female,
      city: 'Karachi',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Hifz & Tajweed for sisters',
      subjects: const [Subject.hifz, Subject.tajweed],
      languages: const [TeachingLanguage.urdu, TeachingLanguage.english],
      years: 6,
      fee: 5000,
      days: monThu,
      from: 11 * 60,
      to: 14 * 60,
      teaches: const {TeachesAudience.women},
      bio:
          'Daytime Hifz classes for sisters, including mothers fitting Hifz around school runs.',
    ),
    teacher(
      MockIds.zubair,
      'Qari Zubair Alam',
      gender: Gender.male,
      city: 'Quetta',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      headline: 'Nazra & Tajweed in Pashto and Urdu',
      subjects: const [Subject.nazra, Subject.tajweed],
      languages: const [TeachingLanguage.pashto, TeachingLanguage.urdu],
      years: 8,
      fee: 4500,
      days: weekdays,
      teaches: const {TeachesAudience.children, TeachesAudience.men},
      bio:
          'Nazra and Tajweed taught in Pashto or Urdu, whichever your child is most comfortable with.',
    ),
    // Students
    student(
      MockIds.ayesha,
      'Ayesha Khan',
      email: MockAccounts.studentEmail,
      gender: Gender.female,
      city: 'Islamabad',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      ageGroup: LearnerAgeGroup.adult,
      goals: const [],
      level: LearnerLevel.readsWithHelp,
      languages: const [TeachingLanguage.urdu, TeachingLanguage.english],
      preference: TeacherGenderPreference.female,
      joinedDaysAgo: 30,
    ),
    student(
      MockIds.hira,
      'Hira Baig',
      gender: Gender.female,
      city: 'Lahore',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      ageGroup: LearnerAgeGroup.adult,
      goals: const [Subject.tajweed],
      level: LearnerLevel.readsWithHelp,
      languages: const [TeachingLanguage.urdu],
      preference: TeacherGenderPreference.female,
      note: 'Evenings after Maghrib work best for me.',
    ),
    student(
      MockIds.yusuf,
      'Yusuf Raza',
      gender: Gender.male,
      city: 'Manchester',
      country: 'United Kingdom',
      timeZone: 'GMT+0',
      ageGroup: LearnerAgeGroup.child,
      goals: const [Subject.hifz, Subject.nazra],
      level: LearnerLevel.readsWithHelp,
      languages: const [TeachingLanguage.urdu],
      note: 'My son is 9 and wants to start Hifz. Weekday evenings UK time.',
    ),
    student(
      MockIds.sana,
      'Sana Iqbal',
      gender: Gender.female,
      city: 'Toronto',
      country: 'Canada',
      timeZone: 'GMT−5',
      ageGroup: LearnerAgeGroup.adult,
      goals: const [Subject.tajweed],
      level: LearnerLevel.readsFluently,
      languages: const [TeachingLanguage.english],
      preference: TeacherGenderPreference.female,
      note: 'Looking for a sister to correct my Tajweed, twice a week.',
    ),
    student(
      MockIds.omar,
      'Omar Farooq',
      gender: Gender.male,
      city: 'Karachi',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      ageGroup: LearnerAgeGroup.teen,
      goals: const [Subject.hifz],
      level: LearnerLevel.memorising,
      languages: const [TeachingLanguage.urdu, TeachingLanguage.english],
      preference: TeacherGenderPreference.male,
      note: 'Revising my first 10 juz before exams.',
    ),
    student(
      MockIds.maham,
      'Maham Ali',
      gender: Gender.female,
      city: 'Lahore',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      ageGroup: LearnerAgeGroup.teen,
      goals: const [Subject.tajweed, Subject.nazra],
      level: LearnerLevel.readsWithHelp,
      languages: const [TeachingLanguage.urdu],
      preference: TeacherGenderPreference.female,
    ),
    student(
      MockIds.bilalKhan,
      'Bilal Khan',
      gender: Gender.male,
      city: 'Peshawar',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      ageGroup: LearnerAgeGroup.adult,
      goals: const [Subject.tafsir, Subject.arabic],
      level: LearnerLevel.readsFluently,
      languages: const [TeachingLanguage.pashto, TeachingLanguage.urdu],
      looking: false,
    ),
    student(
      MockIds.zara,
      'Zara Ahmed',
      gender: Gender.female,
      city: 'Dubai',
      country: 'United Arab Emirates',
      timeZone: 'GMT+4',
      ageGroup: LearnerAgeGroup.child,
      goals: const [Subject.nooraniQaida],
      level: LearnerLevel.beginner,
      languages: const [TeachingLanguage.english, TeachingLanguage.arabic],
      preference: TeacherGenderPreference.female,
      note: 'My daughter is 6 and just starting Qaida. Afternoons, Dubai time.',
    ),
    student(
      MockIds.hamid,
      'Hamid Sheikh',
      gender: Gender.male,
      city: 'Islamabad',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      ageGroup: LearnerAgeGroup.adult,
      goals: const [Subject.nooraniQaida, Subject.nazra],
      level: LearnerLevel.beginner,
      languages: const [TeachingLanguage.urdu, TeachingLanguage.english],
      preference: TeacherGenderPreference.male,
      note: 'Learning to read as an adult. Weekends only.',
    ),
    student(
      MockIds.noor,
      'Noor Fatima',
      gender: Gender.female,
      city: 'Faisalabad',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      ageGroup: LearnerAgeGroup.adult,
      goals: const [Subject.hifz],
      level: LearnerLevel.memorising,
      languages: const [TeachingLanguage.urdu, TeachingLanguage.punjabi],
      preference: TeacherGenderPreference.female,
    ),
    student(
      MockIds.ibrahim,
      'Ibrahim Malik',
      gender: Gender.male,
      city: 'Birmingham',
      country: 'United Kingdom',
      timeZone: 'GMT+0',
      ageGroup: LearnerAgeGroup.child,
      goals: const [Subject.nazra],
      level: LearnerLevel.readsWithHelp,
      languages: const [TeachingLanguage.english],
      note: 'He is 10 and reads slowly. After school, around 5 pm UK.',
    ),
    student(
      MockIds.laiba,
      'Laiba Hassan',
      gender: Gender.female,
      city: 'Rawalpindi',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      ageGroup: LearnerAgeGroup.teen,
      goals: const [Subject.tajweed],
      level: LearnerLevel.readsFluently,
      languages: const [TeachingLanguage.urdu, TeachingLanguage.english],
      preference: TeacherGenderPreference.female,
    ),
    student(
      MockIds.daniyal,
      'Daniyal Akhtar',
      gender: Gender.male,
      city: 'Toronto',
      country: 'Canada',
      timeZone: 'GMT−5',
      ageGroup: LearnerAgeGroup.adult,
      goals: const [Subject.arabic, Subject.tafsir],
      level: LearnerLevel.readsFluently,
      languages: const [TeachingLanguage.english, TeachingLanguage.urdu],
      note: 'I want to understand the meaning of what I recite in salah.',
    ),
    student(
      MockIds.mariamNadeem,
      'Mariam Nadeem',
      gender: Gender.female,
      city: 'Karachi',
      country: 'Pakistan',
      timeZone: 'GMT+5',
      ageGroup: LearnerAgeGroup.adult,
      goals: const [Subject.tajweed, Subject.hifz],
      level: LearnerLevel.readsWithHelp,
      languages: const [TeachingLanguage.urdu],
      preference: TeacherGenderPreference.female,
      looking: false,
    ),
  ];
}
