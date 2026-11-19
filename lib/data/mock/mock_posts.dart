import '../models/comment.dart';
import '../models/enums/post_tag.dart';
import '../models/post.dart';
import 'mock_profiles.dart';

/// A seeded post with the users who already liked it.
typedef MockPostSeed = ({Post post, Set<String> likedBy});

/// Bundled illustrations used as mock post photos.
abstract final class MockImages {
  static const String certificatePhoto =
      'assets/illustrations/certificate_photo.svg';
  static const String postPhoto = 'assets/illustrations/post_photo.svg';
  static const String qaidaPage = 'assets/illustrations/qaida_page.svg';
}

/// 14 seed posts, created relative to [now]. `commentCount` is filled from
/// [buildMockComments] by the repository.
List<MockPostSeed> buildMockPosts(DateTime now) {
  MockPostSeed seed(
    int n,
    String authorId,
    Duration age,
    PostTag tag,
    String body, {
    String? verse,
    String? image,
    int otherLikes = 0,
    Set<String> likedBy = const <String>{},
  }) {
    return (
      post: Post(
        id: 'post-${n.toString().padLeft(3, '0')}',
        authorId: authorId,
        body: body,
        tag: tag,
        createdAt: now.subtract(age),
        arabicVerse: verse,
        imagePath: image,
        likeCount: otherLikes + likedBy.length,
      ),
      likedBy: likedBy,
    );
  }

  return <MockPostSeed>[
    seed(
      1,
      MockIds.ahmed,
      const Duration(hours: 2),
      PostTag.tajweedTip,
      'Read slowly and beautifully. Today’s tip: give the madd its full two counts before you move on, and don’t rush the ghunnah.',
      verse: 'وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا',
      otherLikes: 47,
      likedBy: <String>{MockIds.ayesha},
    ),
    seed(
      2,
      MockIds.maryam,
      const Duration(hours: 5),
      PostTag.achievement,
      'Alhamdulillah! My student Fatima (11) completed Juz Amma today. May Allah make it easy for her.',
      image: MockImages.certificatePhoto,
      otherLikes: 212,
    ),
    seed(
      3,
      MockIds.khadija,
      const Duration(hours: 8),
      PostTag.reminder,
      'A gentle reminder: the best of you are those who learn the Quran and teach it. Ten minutes a day, every day, is better than one long session a week.',
      otherLikes: 96,
    ),
    seed(
      4,
      MockIds.usman,
      const Duration(hours: 26),
      PostTag.classAnnouncement,
      'New Hifz batch for boys aged 8–12 starts Monday after Asr, Pakistan time. Three places left — send me a request with your son’s current level.',
      otherLikes: 38,
    ),
    seed(
      5,
      MockIds.ayesha,
      const Duration(days: 2),
      PostTag.question,
      'Assalamu alaikum! Can anyone recommend a good routine for revising the last 3 juz? I keep forgetting what I memorised last month.',
      otherLikes: 14,
    ),
    seed(
      6,
      MockIds.fatimaZahra,
      const Duration(hours: 30),
      PostTag.tajweedTip,
      'The qalqalah letters are ق ط ب ج د — remember them as “qutbu jad”. Give the letter a light bounce only when it carries a sukoon.',
      otherLikes: 74,
    ),
    seed(
      7,
      MockIds.bilalAhmad,
      const Duration(days: 2, hours: 3),
      PostTag.reminder,
      'Before you open the mushaf, make wudu and sit facing the qiblah if you can. Small adab, big barakah.',
      otherLikes: 120,
    ),
    seed(
      8,
      MockIds.hamza,
      const Duration(days: 3),
      PostTag.hifz,
      'Muraja’ah tip: revise yesterday’s lesson before today’s new lines. Old before new keeps the foundation strong.',
      otherLikes: 57,
    ),
    seed(
      9,
      MockIds.hira,
      const Duration(days: 3, hours: 5),
      PostTag.achievement,
      'I finished Noorani Qaida with Ustadha Khadija and read my first full page of Surah Al-Baqarah today. JazakAllahu khairan!',
      otherLikes: 88,
    ),
    seed(
      10,
      MockIds.imran,
      const Duration(days: 4),
      PostTag.classAnnouncement,
      'Free Arabic grammar circle every Saturday at 8 pm PKT. We read short ayaat and break down every word. All levels welcome.',
      otherLikes: 45,
    ),
    seed(
      11,
      MockIds.zainab,
      const Duration(days: 5),
      PostTag.hifz,
      'For sisters starting Hifz: choose one mushaf and stay with it. Your visual memory of each page is half the work.',
      otherLikes: 63,
    ),
    seed(
      12,
      MockIds.sana,
      const Duration(days: 6),
      PostTag.question,
      'Is it better to learn the Tajweed rules first, or to start reading with a teacher and learn the rules along the way?',
      otherLikes: 21,
    ),
    seed(
      13,
      MockIds.abdullah,
      const Duration(days: 7),
      PostTag.tajweedTip,
      'Makharij practice for beginners: say each letter with a sukoon after an alif — اَبْ، اَتْ، اَثْ — and notice exactly where the sound comes from.',
      image: MockImages.qaidaPage,
      otherLikes: 52,
    ),
    seed(
      14,
      MockIds.hafsa,
      const Duration(days: 8),
      PostTag.reminder,
      'Struggling with your recitation this week? Keep going. Every stumble is rewarded twice.',
      verse: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
      otherLikes: 140,
    ),
  ];
}

/// Seed comments, oldest first per post.
List<Comment> buildMockComments(DateTime now) {
  var n = 0;
  Comment c(
    String postId,
    String authorId,
    Duration age,
    String body, {
    int likes = 0,
  }) {
    n++;
    return Comment(
      id: 'comment-${n.toString().padLeft(3, '0')}',
      postId: postId,
      authorId: authorId,
      body: body,
      createdAt: now.subtract(age),
      likeCount: likes,
    );
  }

  return <Comment>[
    c(
      'post-001',
      MockIds.hira,
      const Duration(hours: 1),
      'JazakAllahu khairan Ustadh, this is the exact mistake I keep making.',
      likes: 4,
    ),
    c(
      'post-001',
      MockIds.ahmed,
      const Duration(minutes: 58),
      'Wa iyyaki. Practise Surah Al-Fatiha slowly 3 times a day this week.',
      likes: 6,
    ),
    c(
      'post-001',
      MockIds.yusuf,
      const Duration(minutes: 20),
      'Could you share an example with Surah Al-Kawthar?',
      likes: 1,
    ),
    c(
      'post-001',
      MockIds.sana,
      const Duration(minutes: 15),
      'The point about the ghunnah really helped me, thank you.',
    ),
    c(
      'post-001',
      MockIds.omar,
      const Duration(minutes: 9),
      'I will practise this with my teacher tonight, in shaa Allah.',
    ),
    c(
      'post-001',
      MockIds.maham,
      const Duration(minutes: 4),
      'Saving this for my revision.',
    ),
    c(
      'post-002',
      MockIds.khadija,
      const Duration(hours: 4),
      'MashaAllah! May Allah make her among the people of the Quran.',
      likes: 12,
    ),
    c(
      'post-002',
      MockIds.yusuf,
      const Duration(hours: 3),
      'Barakallahu feeha. My son starts Hifz next month, in shaa Allah.',
      likes: 3,
    ),
    c(
      'post-002',
      MockIds.hira,
      const Duration(hours: 2),
      'Such a beautiful milestone, Alhamdulillah.',
    ),
    c(
      'post-002',
      MockIds.ayesha,
      const Duration(hours: 1),
      'MashaAllah, may Allah reward you both.',
    ),
    c(
      'post-003',
      MockIds.noor,
      const Duration(hours: 7),
      'Ten minutes a day is something I can actually keep up. JazakAllahu khairan.',
    ),
    c(
      'post-003',
      MockIds.hamid,
      const Duration(hours: 6),
      'I needed this reminder today.',
    ),
    c(
      'post-004',
      MockIds.yusuf,
      const Duration(hours: 20),
      'Sending a request now for my son, in shaa Allah.',
    ),
    c(
      'post-005',
      MockIds.maryam,
      const Duration(days: 1, hours: 20),
      'Revise one juz each day in rotation, and recite what you revise in your sunnah prayers.',
      likes: 9,
    ),
    c(
      'post-005',
      MockIds.hamza,
      const Duration(days: 1, hours: 18),
      'Listen to the same qari every day while revising. It anchors the memory.',
      likes: 5,
    ),
    c(
      'post-005',
      MockIds.noor,
      const Duration(days: 1, hours: 2),
      'Same problem here. Following this thread.',
    ),
    c(
      'post-006',
      MockIds.laiba,
      const Duration(hours: 28),
      'Qutbu jad — I will never forget that now!',
    ),
    c(
      'post-008',
      MockIds.omar,
      const Duration(days: 2, hours: 20),
      'This changed my Hifz completely.',
    ),
    c(
      'post-009',
      MockIds.khadija,
      const Duration(days: 3, hours: 2),
      'So proud of you, Hira. Keep going!',
      likes: 7,
    ),
    c(
      'post-012',
      MockIds.fatimaZahra,
      const Duration(days: 5, hours: 20),
      'Start reading with a teacher. The rules make much more sense when you hear them.',
      likes: 11,
    ),
  ];
}
