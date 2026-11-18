# Asatiza — Version 1.0 Plan (Release 1)

Final plan for the first release · Version 1.0 · Nov 18, 2026

## 1. Summary

**Asatiza** is a LinkedIn-style professional network for the Quran-learning world. Teachers and students create profiles, connect, chat, and share Islamic posts in a moderated feed.

**Version 1.0 goal:** launch a simple, easy-to-use app on Android and iOS, on free plans only, that proves teachers and students will join, connect and talk. Payments, video classes and other advanced features come in later versions (see the Full Product Plan).

| Item | Decision |
| --- | --- |
| Brand name | **Asatiza** |
| Play Store title | **Asatiza: Find Quran Teachers** (28 characters; limit is 30) |
| Short description | Connect with Quran teachers & students worldwide. Learn Tajweed, Hifz & more. |
| Roles | Two: **Teacher** and **Student** (one role per account, chosen at sign-up) |
| Who can sign up | Adults **18+**. A parent may open a Student account for their child |
| Platforms | Android + iOS, one **Flutter** codebase |
| Backend | **Supabase** free plan (login, database, files, realtime chat) |
| Push notifications | **Firebase Cloud Messaging** (free) + Crashlytics |
| Email delivery | **Brevo** free SMTP (300 emails/day) |
| Later backend | Our own **Python (FastAPI)** API, added step by step |
| Languages at launch | English (Urdu and Arabic in v1.1) |
| Target launch | \~8 weeks build + \~3 weeks Play Store testing and review |

## 2. Version 1.0 success targets (first 3 months)

| Metric | Target |
| --- | --- |
| Approved teachers | 150+ |
| Students signed up | 1,000+ |
| Sign-ups that confirm the email code | 80%+ |
| Profiles at 100% strength | 40%+ |
| Accepted connections | 500+ |
| Weekly active users | 30% of all users |
| Crash-free users | 99%+ |

## 3. What Version 1.0 delivers

### In scope

1. Sign up with **name, email, password, role** → confirm email with a **6-digit code**.
2. Log in with **email + password only** (no code at login).
3. Forgot password with an emailed code.
4. **Skip-able profile setup** — users land on Home right after confirming; profile can be finished later.
5. **Profile strength meter** and checklist card until 100%.
6. **Home feed** — posts from connections first, then recent posts from everyone.
7. **Create post** — text + one photo + one tag.
8. **Like, comment, report** on posts; delete own posts and comments.
9. **Teachers / Students tab** — search + filters, role-aware.
10. **Connections** — request, accept, decline, remove.
11. **Chat** — 1-to-1 text + image messages after connecting; read ticks; unread badges.
12. **Notifications tab** + push notifications.
13. **Profiles** — my profile, edit profile, other people's profiles with their posts.
14. **Safety** — report, block, delete account, admin approval of teachers.
15. **Settings** — change password, notification switches, privacy policy, terms, log out, delete account.

### Out of scope for 1.0 (planned later)

Payments · in-app video classes · class booking · parent/child accounts · reviews and ratings · Sanad Tree · academies · jobs board · group chats · video posts · Urdu/Arabic interface · web app.

Until video arrives, teachers share a Zoom or Google Meet link in chat. Until payments arrive, fees are arranged directly between teacher and student.

## 4. User flows

### Sign up

1. Welcome screen → **Create account**.
2. Form: full name, email, password (8+ characters), "I am a **Teacher** / **Student**", tick "I am 18 or older and agree to the Terms".
3. App calls Supabase sign-up → Supabase emails a **6-digit code**.
4. Code screen: 6 boxes, auto-submit, "Resend code" after 60 seconds, "Wrong email? Change it".
5. Code correct → signed in → **Profile setup** (skip-able) → **Home**.

### Log in

Email + password → Home. If the email was never confirmed, the app sends a fresh code and opens the code screen.

### Forgot password

Email → 6-digit code → new password → signed in.

### Profile setup (after sign-up, every step has "Skip for now")

| Step | Teacher | Student |
| --- | --- | --- |
| 1 | Photo + headline (e.g. "Hafiz & Tajweed teacher, 8 years") | Photo (optional) + age group of the learner |
| 2 | Subjects + languages + gender + country/time zone | What I want to learn + current level + languages |
| 3 | Bio, experience, fee, availability, certificates | Preferred teacher gender + "Looking for a teacher" switch |

### Connect and chat

1. Student opens Teachers tab → filters → opens a teacher's profile → **Connect** (optional note, 200 characters).
2. Teacher gets a push + Notifications entry → **Accept** or **Decline**.
3. Accepted → both get a chat. Either side can remove the connection or block.
4. Teachers can also send Connect to students who have "Looking for a teacher" switched on.

### Post

**+ Post** → write text (up to 1,500 characters) → add one photo (optional) → choose a tag (Reminder, Tajweed tip, Hifz, Question, Class announcement, Achievement) → **Post**.

## 5. Navigation

**Bottom tabs (5):**

| # | Tab | Contents |
| --- | --- | --- |
| 1 | Home | Feed, profile-strength card |
| 2 | Teachers (student) / Students (teacher) | Search, filters, people cards with Connect |
| 3 | **＋ Post** (centre) | Create post |
| 4 | Chats | Chat list with unread badges |
| 5 | Notifications | Requests (Accept/Decline), likes, comments, accepts |

**Top bar:** your photo (top-left → My Profile, Settings, Log out) + search bar.

## 6. Screen list (22 screens)

| # | Screen | Who |
| --- | --- | --- |
| 1 | Splash | All |
| 2 | Welcome (3 short slides) | All |
| 3 | Sign up | All |
| 4 | Email code (OTP) | All |
| 5 | Log in | All |
| 6 | Forgot password (email → code → new password) | All |
| 7 | Profile setup — 3 steps | Teacher / Student versions |
| 8 | Home feed | All |
| 9 | Post detail with comments | All |
| 10 | Create post | All |
| 11 | Teachers list + filters | Student |
| 12 | Students list + filters | Teacher |
| 13 | Filter sheet | All |
| 14 | Public profile (teacher or student) | All |
| 15 | Send connection request sheet | All |
| 16 | My connections | All |
| 17 | Chats list | All |
| 18 | Chat conversation | All |
| 19 | Notifications | All |
| 20 | My profile + Edit profile | All |
| 21 | Settings | All |
| 22 | Report / Block sheet | All |

## 7. Profiles

### Teacher profile fields

Full name · photo · headline · gender · country · time zone · languages · subjects (Noorani Qaida, Nazra, Tajweed, Hifz, Tafsir, Arabic, Islamic studies) · bio · years of experience · qualifications (text) · certificates (images/PDF) · fee amount + currency + per (class / month) · availability (days + time ranges) · teaches (children / women / men / all).

### Student profile fields

Full name · photo (optional, never shown in the Students list) · gender · country · time zone · languages · learner age group (child / teen / adult) · what I want to learn · current level · preferred teacher gender · "Looking for a teacher" switch · short note.

### Profile strength (how the % is counted)

| Teacher item | % | Student item | % |
| --- | --- | --- | --- |
| Photo | 15 | Learner age group | 15 |
| Headline | 10 | Learning goals | 25 |
| Subjects | 15 | Level | 15 |
| Languages | 10 | Languages | 15 |
| Bio | 15 | Country / time zone | 10 |
| Experience + qualifications | 10 | Preferred teacher gender | 10 |
| Fee + availability | 15 | Photo or short note | 10 |
| Certificate uploaded | 10 |  |  |

### Visibility rules

- **Teachers** appear in the Teachers tab only when strength ≥ 80% **and** an admin has approved them ("Verified" tick).
- **Students** appear in the Students tab only when "Looking for a teacher" is ON and strength ≥ 60%.
- Anyone can **read and post** in the feed right after confirming their email.
- Sending a **connection request** needs your own profile at ≥ 60%.

## 8. Teachers / Students search

| Student filters teachers by | Teacher filters students by |
| --- | --- |
| Subject | Subject wanted |
| Teacher gender | Student gender |
| Language | Language |
| Country / time zone | Country / time zone |
| Fee range | Level |
| Years of experience | Learner age group |
| Teaches children / women | Newest first |

Search box matches name, headline and subjects. Default sort: verified + most complete first, then newest.

## 9. Feed rules and moderation

- Feed order: posts from connections (newest first), then recent public posts.
- Post limits: 1,500 characters, 1 photo (compressed to \~200 KB), max 10 posts per user per day.
- Content policy: Islamic, respectful content only; no music or video in v1.0; no politics, sectarian attacks, ads or spam.
- Report reasons: spam, inappropriate, hate/harassment, false information, other.
- A post reported by 3+ different users is hidden automatically until an admin reviews it.
- Blocked users can't see your profile or posts, can't message you, and disappear from your lists.

## 10. Notifications

| Event | Push | In-app |
| --- | --- | --- |
| New connection request | Yes | Yes |
| Request accepted | Yes | Yes |
| New message | Yes | Badge on Chats |
| Like on your post | No (grouped in app) | Yes |
| Comment on your post | Yes | Yes |
| Teacher profile approved / needs changes | Yes | Yes |

## 11. Technical architecture

```
Flutter app (Android + iOS)
   │  repositories (Auth, Profile, Feed, Connection, Chat, Notification)
   ├── Supabase Auth ── email + password, 6-digit email OTP
   ├── Supabase Postgres ── all app data, protected by Row Level Security
   ├── Supabase Storage ── avatars, post photos, certificates
   ├── Supabase Realtime ── live chat and notifications
   └── Supabase Edge Functions ── send push via Firebase Cloud Messaging
Brevo SMTP ── delivers sign-up and password-reset codes
Firebase ── FCM (push) + Crashlytics only
```

### Flutter packages

supabase\_flutter · firebase\_core · firebase\_messaging · firebase\_crashlytics · flutter\_riverpod · go\_router · image\_picker · flutter\_image\_compress · cached\_network\_image · pinput · intl · flutter\_local\_notifications.

### Folder structure

```
lib/
  core/            theme, router, constants, widgets, utils
  data/
    models/        Profile, TeacherDetails, StudentDetails, Post, Comment,
                   Connection, Conversation, Message, AppNotification
    repositories/  *_repository.dart  (interfaces)
      supabase/    v1.0 implementations
      api/         later: Python API implementations
  features/
    auth/ onboarding/ profile_setup/ feed/ post/ discover/
    connections/ chat/ notifications/ profile/ settings/
  main.dart
```

**Rule:** screens never import Supabase directly — only repositories. This makes the later move to the Python API safe.

## 12. Database (PostgreSQL on Supabase)

| Table | Main columns |
| --- | --- |
| profiles | id (auth user id), role, full\_name, headline, photo\_path, gender, country, timezone, languages\[\], bio, completion\_pct, is\_visible, is\_verified, created\_at |
| teacher\_details | profile\_id, subjects\[\], experience\_years, qualifications, fee\_amount, fee\_currency, fee\_unit, availability (json), teaches\[\], certificate\_paths\[\] |
| student\_details | profile\_id, age\_group, goals\[\], level, preferred\_teacher\_gender, looking\_for\_teacher, note |
| connections | id, requester\_id, receiver\_id, status, note, created\_at, responded\_at |
| posts | id, author\_id, body, image\_path, tag, like\_count, comment\_count, report\_count, is\_hidden, created\_at |
| post\_likes | post\_id, user\_id, created\_at |
| post\_comments | id, post\_id, author\_id, body, created\_at |
| conversations | id, user\_a, user\_b, last\_message, last\_message\_at |
| messages | id, conversation\_id, sender\_id, body, image\_path, read\_at, created\_at |
| notifications | id, user\_id, type, actor\_id, target\_id, is\_read, created\_at |
| reports | id, reporter\_id, target\_type, target\_id, reason, status, created\_at |
| blocks | blocker\_id, blocked\_id, created\_at |
| device\_tokens | user\_id, fcm\_token, platform, updated\_at |

**Row Level Security (required):** users write only their own rows · messages readable only by the two conversation members · conversations created only from accepted connections · hidden/unverified profiles and hidden posts excluded from lists · `role`, `is_verified` and `is_hidden` changeable only by admin · blocked users filtered from every query.

**Storage buckets:** `avatars` (public read), `post-images` (public read), `certificates` (private; owner + admin), `chat-images` (private; conversation members).

## 13. Free-plan setup and limits

| Service | Free limit | What we do |
| --- | --- | --- |
| Supabase database | 500 MB | Text-only rows; monitor monthly |
| Supabase file storage | 1 GB | Compress photos (posts \~200 KB, avatars \~60 KB) ≈ 5,000 post photos |
| Supabase bandwidth | 5 GB/month | Cache images in the app; thumbnails in lists |
| Supabase users | 50,000 monthly active | Enough for v1.0 |
| Supabase pause | After 7 days with no activity | Daily free ping (GitHub Actions) until there is daily traffic |
| Built-in Supabase email | 2/hour, team only | **Replace with Brevo SMTP before testing with real users** |
| Brevo SMTP | 300 emails/day | Enough for \~250 sign-ups a day |
| Firebase FCM + Crashlytics | Free | — |

**Upgrade triggers (move to paid):** database > 400 MB · files > 800 MB · bandwidth > 4 GB/month · sign-ups > 250/day · any outage from the pause after launch. First upgrade: Supabase Pro (US$25/month).

**One-time costs:** Google Play developer account US$25 · Apple Developer Program US$99/year (only when iOS launches) · domain \~US$10–15/year.

## 14. Ready for the Python API later

1. Repository layer in Flutter (section 11).
2. All IDs are UUIDs; files stored as paths, not full URLs.
3. Business rules live in a short, documented list of Postgres functions and Edge Functions, so each can be rewritten in Python.
4. Python (FastAPI) can connect to the same Postgres and take over one feature at a time; the app switches each repository with a remote setting.
5. Login stays the same during the move: the Python API verifies Supabase login tokens.

## 15. Admin for Version 1.0

No separate admin app yet. The admin uses the Supabase dashboard with saved views:

- **Pending teachers** → review certificates → set `is_verified = true` (or send "needs changes").
- **Open reports** → hide post / warn / ban user.
- **New users today**, **posts today**, **connections today**.

## 16. Safety and Google Play compliance

- Age gate 18+ at sign-up; Terms and Privacy Policy links on the sign-up screen and website.
- User-generated content: report, block, moderation and a written content policy (required by Google Play).
- In-app account deletion plus a web page where users can request deletion.
- Data safety form: email, name, photos, messages, device token, crash data.
- Teacher approval before appearing in search.
- Students' photos never shown in the Students list.

## 17. Timeline (8 weeks build + launch)

| Week | Work |
| --- | --- |
| 1 | Supabase + Firebase (FCM) + Brevo setup, domain email, Flutter structure, theme, 5-tab shell |
| 2 | Sign up + email OTP, login, forgot password |
| 3 | Profile setup (skip-able), profile pages, strength meter, photo upload |
| 4 | Feed, create post, likes, comments, image compression |
| 5 | Teachers/Students tab, search, filters, connection requests |
| 6 | Chat (realtime), push notifications, Notifications tab |
| 7 | Report/block, delete account, RLS tests, admin views, store assets |
| 8 | Bug fixing, internal testing, start Play Store closed test |
| 9–10 | Closed test: **at least 12 testers opted in for 14 continuous days** (rule for new personal developer accounts) |
| 11 | Apply for production access → review → launch on Google Play |

Recruit the 12+ testers early: founding teachers and their students are ideal.

## 18. Team

| Role | Need |
| --- | --- |
| Product owner (you) | Decisions, teacher recruitment, content policy |
| Flutter developer | 1–2 |
| Supabase/backend setup | Part-time (can be the senior Flutter developer) |
| UI/UX designer | Part-time, weeks 1–3 |
| Tester + moderator | Part-time from week 6 |

## 19. Launch checklist

- [ ] Name, domain and social handles registered
- [ ] Brevo SMTP connected; sign-up code email tested in Gmail, Outlook, Yahoo
- [ ] Privacy Policy, Terms, Content Policy, account-deletion page live on the website
- [ ] RLS policies tested with two test accounts per role
- [ ] 20 founding teachers approved with complete profiles before launch
- [ ] Store listing: icon, 6–8 screenshots, feature graphic, description
- [ ] Closed test running with 12+ testers for 14 days
- [ ] Crashlytics and daily keep-alive ping working

## 20. Definition of done

- New user signs up, confirms the 6-digit code and reaches Home in under a minute.
- Returning user logs in with email + password only.
- Skipping profile setup works; the strength card guides completion.
- Student finds a teacher by subject + gender + language, connects and chats.
- Teacher finds students looking for a teacher, connects and chats.
- Posts, likes, comments, reports and blocks work; admin can hide content and approve teachers.
- Everything runs on free plans with the upgrade triggers written down.
