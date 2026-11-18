# Asatiza — Full Product Plan (All Versions)

Complete product roadmap from Version 1.0 to Version 4.0 · Nov 18, 2026

## 1. Vision

**Asatiza is the professional home of the Quran-teaching world** — where every Quran teacher has a trusted, verifiable professional identity, and every student or parent can find, connect with and learn from the right teacher, anywhere in the world.

**Mission:** make finding a qualified, safe, trusted Quran teacher as easy as finding a professional on LinkedIn.

**Brand:** Asatiza (أساتذة, "teachers"). Store title: "Asatiza: Find Quran Teachers". The word is familiar in the Arab world and South Asia, and as "asatizah" in Malaysia, Singapore and Indonesia; the English store title carries worldwide search words.

## 2. The problem

- Parents and students struggle to judge whether an online Quran teacher is qualified, safe and right for them.
- Good teachers have no professional profile that proves their ijazah, sanad, experience and reputation.
- Existing apps are single-purpose: tutor marketplaces without community, social networks without hiring, AI tools without human teachers.

## 3. Market and competitors

| Category | Examples | Gap Asatiza fills |
| --- | --- | --- |
| Quran tutor marketplaces | Moddakir, Tajweedly / Quran Courses, Munabook, Tibyan, Meqraa, Sanad Quran, Hafizulquran | No professional identity, no community or networking |
| AI / self-learning | Tarteel, UstadApp, Mualim Al Quran, Qurania | No human teachers or community |
| Muslim social networks | Umma Life, DeenConnect, Zaytun AI, Muslim Connect, Sila | Not about Quran education; no hiring |
| Halaqa / group apps | Halaqa, Iqraa, Hamil Al Quran, Quran Space | No teacher discovery |
| Madrasa management | ILMIFY, Mualim | Closed to one institution |

**Our position:** the identity, trust and connection layer for Quran teachers and learners — starting as a professional network, growing into a full learning platform.

## 4. What makes Asatiza unique (across versions)

1. **Professional teacher identity** — LinkedIn-style profiles built for Quran teaching (v1.0).
2. **Verified teachers** — admin approval (v1.0) → verified ijazah badges (v2.0).
3. **Role-aware discovery** — students find teachers, teachers find students who are looking (v1.0).
4. **Safety by design** — 18+ accounts in v1.0, parent-managed child accounts and recorded classes in v2.0.
5. **Sanad Tree** — a living, verifiable chain-of-transmission graph linking teachers to their teachers (v3.0).
6. **Learner portfolio** — hifz and recitation progress that moves with the student between teachers (v2.0).

## 5. Users by version

| User type | v1.0 | v2.0 | v3.0 | v4.0 |
| --- | --- | --- | --- | --- |
| Teacher | ✓ | ✓ | ✓ | ✓ |
| Student (18+) | ✓ | ✓ | ✓ | ✓ |
| Parent with child sub-profiles | — | ✓ | ✓ | ✓ |
| Academy / Madrasa (company page) | — | — | ✓ | ✓ |
| Masjid / employer (jobs) | — | — | ✓ | ✓ |
| Admin / moderator | Supabase dashboard | Admin web panel | Admin web panel + roles | Same |

## 6. Roadmap overview

| Version | Name | Theme | Estimated timing |
| --- | --- | --- | --- |
| **1.0** | Connect | Profiles, feed, discovery, connections, chat | Months 0–3 |
| **1.1** | Polish | Urdu + Arabic (RTL), bookmarks, sharing, small fixes | Months 3–4 |
| **2.0** | Learn | Booking, video classes, payments, parent accounts, reviews, progress, Python API starts | Months 4–10 |
| **3.0** | Grow | Sanad Tree, academies, group classes & halaqas, jobs board, Teacher Pro, web app | Months 10–18 |
| **4.0** | Scale | AI recitation help, events & competitions, certificates, more languages, full own infrastructure | Months 18+ |

Timings are estimates for a small team and depend on funding and traction after each release.

## 7. Version 1.0 — Connect (first release)

Full details are in the separate **Asatiza — Version 1.0 Plan** doc. Summary:

- Two roles: Teacher and Student (18+).
- Sign up with email + password + role, confirmed by a 6-digit email code; login with email + password only.
- Skip-able profile setup with a LinkedIn-style profile-strength meter.
- Five tabs: Home (feed) · Teachers/Students · ＋ Post · Chats · Notifications; profile from the top-left photo.
- Feed with text + photo posts, likes, comments, reports.
- Role-aware search with filters; connection requests; 1-to-1 chat after accepting.
- Report, block, delete account; admin approval of teachers.
- Flutter + Supabase free plan + Firebase (push only) + Brevo email.

**Exit criteria to start v2.0:** 150+ approved teachers, 1,000+ students, 500+ accepted connections, and clear demand for in-app booking/payment (surveyed in-app).

## 8. Version 1.1 — Polish

- Urdu and Arabic interface (right-to-left), language switcher.
- Save/bookmark posts; share profile and post links (deep links).
- Teacher "Open to new students" badge; student "Looking for a teacher" badge on the feed.
- Better feed ranking (connections + same subjects + same languages).
- Performance, accessibility and crash fixes from v1.0 feedback.
- Upgrade to Supabase Pro when the free-plan upgrade triggers are hit.

## 9. Version 2.0 — Learn

**Goal:** let teaching happen *inside* Asatiza, safely and paid.

### Features

- **Parent accounts** with child sub-profiles; parents see all chats and class records of their children. Opens the app to child learners (Google Play Families Policy compliance).
- **Booking & scheduling:** teacher availability calendar, free trial class, recurring weekly classes, time-zone handling, reminders.
- **In-app video classes** (Agora, 100ms or LiveKit) with Quran page view and whiteboard; **recording for classes with children**.
- **Payments:** Stripe (international) + JazzCash / Easypaisa (Pakistan) + other local wallets; platform commission; teacher payouts.
- **Reviews & ratings** after classes.
- **Learner progress tracker:** Qaida lessons, surahs read, juz memorized, homework, monthly report to parent.
- **Verified ijazah badges:** certificate review + optional live recitation check by a panel.
- **Admin web panel:** teacher verification, reports, refunds, payouts, analytics.
- **Group chats** for a teacher and their students.

### Backend in 2.0

- Python **FastAPI** service launched next to Supabase, connected to the same Postgres.
- New v2.0 features (payments, booking, video tokens) are built in Python from day one.
- Existing features move one by one from Supabase calls to the API; the Flutter repositories switch with a remote setting.

## 10. Version 3.0 — Grow

**Goal:** become the professional network of the whole Quran-education sector.

- **Sanad Tree:** teachers add their ijazah chain; teachers on the platform are linked; chains are verified by the teachers above them.
- **Academy / Madrasa pages:** company pages with multiple teachers, shared bookings, academy dashboard.
- **Jobs board:** academies and masjids post teacher vacancies; teachers apply with their Asatiza profile.
- **Group classes and halaqas:** live group sessions, khatam circles, Ramadan programs.
- **Teacher Pro subscription:** profile boost, analytics, priority verification, custom booking page.
- **Web app** for teachers and academies (desktop teaching and management).
- **Endorsements and recommendations** on profiles.

## 11. Version 4.0 — Scale

- **AI recitation help** between classes (pronunciation and memorization checks), built or via a partner — teachers stay at the centre.
- **Events and competitions:** online Quran competitions, khatam events, Ramadan challenges.
- **Digital certificates** for course completion issued by teachers/academies.
- **More languages:** Bangla, Indonesian, Malay, Turkish, French.
- **Full own infrastructure:** database moved from Supabase to our own managed Postgres; Python API serves everything.
- **Analytics & recommendations:** teacher–student matching suggestions.

## 12. Feature matrix

| Feature | 1.0 | 1.1 | 2.0 | 3.0 | 4.0 |
| --- | --- | --- | --- | --- | --- |
| Email sign-up + OTP, password login | ✓ | ✓ | ✓ | ✓ | ✓ |
| Teacher & student profiles, strength meter | ✓ | ✓ | ✓ | ✓ | ✓ |
| Feed, posts, likes, comments | ✓ | ✓ | ✓ | ✓ | ✓ |
| Discovery + filters, connections | ✓ | ✓ | ✓ | ✓ | ✓ |
| 1-to-1 chat, push notifications | ✓ | ✓ | ✓ | ✓ | ✓ |
| Report, block, admin approval | ✓ | ✓ | ✓ | ✓ | ✓ |
| Urdu / Arabic interface |  | ✓ | ✓ | ✓ | ✓ |
| Bookmarks, deep links |  | ✓ | ✓ | ✓ | ✓ |
| Parent & child accounts |  |  | ✓ | ✓ | ✓ |
| Booking, video classes, payments |  |  | ✓ | ✓ | ✓ |
| Reviews, progress tracker, ijazah badges |  |  | ✓ | ✓ | ✓ |
| Group chats |  |  | ✓ | ✓ | ✓ |
| Sanad Tree, academies, jobs, Teacher Pro |  |  |  | ✓ | ✓ |
| Group classes & halaqas, web app |  |  |  | ✓ | ✓ |
| AI recitation help, events, certificates |  |  |  |  | ✓ |

## 13. Technology evolution

| Layer | v1.0 | v2.0 | v3.0 | v4.0 |
| --- | --- | --- | --- | --- |
| Mobile | Flutter | Flutter | Flutter | Flutter |
| Web | — | Admin panel (React/Next.js) | Teacher & academy web app | Same |
| Auth | Supabase Auth | Supabase Auth (verified by Python API) | Same | Own auth or keep Supabase Auth |
| API | Supabase direct (via repositories) | FastAPI for new features | FastAPI for most features | FastAPI for everything |
| Database | Supabase Postgres (free) | Supabase Postgres (Pro) | Supabase Postgres (Pro/Team) | Own managed Postgres |
| Files | Supabase Storage | Supabase Storage + CDN | Same | Object storage + CDN |
| Realtime chat | Supabase Realtime | Supabase Realtime | Realtime or WebSockets from API | WebSockets from API |
| Video | Meet/Zoom links | Agora / 100ms / LiveKit | Same | Same |
| Payments | — | Stripe + JazzCash/Easypaisa | + subscriptions | + more local methods |
| Push / crashes | Firebase FCM + Crashlytics | Same | Same | Same |
| Email | Brevo free | Brevo/Resend paid | Same | Same |

### Safe migration rules (apply from v1.0)

1. Screens talk only to repositories, never to Supabase directly.
2. UUID primary keys; files stored as paths.
3. Every Postgres function and Edge Function is documented so it can be rewritten in Python.
4. Move one feature at a time behind a remote switch; keep the old path until the new one is proven.
5. Users never re-register: tokens stay valid during the move, and accounts move with the database.

## 14. Business model by version

| Version | Revenue |
| --- | --- |
| 1.0–1.1 | Free for everyone (build the network) |
| 2.0 | Commission on paid classes (target 10–15%) |
| 3.0 | + Teacher Pro subscription, academy plans, paid job posts |
| 4.0 | + premium learner features (AI practice, certificates), event sponsorship |

## 15. Costs by stage (estimates)

| Stage | Monthly running cost |
| --- | --- |
| v1.0 launch | US$0 (free plans) + one-time US$25 Play account, \~US$12 domain |
| v1.1 growth | \~US$25–50 (Supabase Pro) |
| v2.0 | \~US$100–400 (Supabase Pro, API hosting, video minutes, email) + payment fees per transaction |
| v3.0+ | Grows with usage; plan from revenue |

Apple Developer Program (US$99/year) is added when the iOS version is published.

## 16. Compliance and safety by version

| Area | v1.0 | v2.0+ |
| --- | --- | --- |
| Age | 18+ accounts only | Parent-managed child profiles; Families Policy compliance |
| User content | Report, block, moderation, content policy | + automated filters, moderator team |
| Teachers | Admin approval | + ID check, ijazah verification, background check for teaching children |
| Classes | Outside the app | Recorded when a child is present; parent visibility |
| Payments | — | Payment provider compliance, refunds policy, invoices |
| Data | Privacy policy, data-safety form, account deletion | + data export, regional privacy laws (GDPR for Europe) |

## 17. Success metrics by version

| Version | Key metrics |
| --- | --- |
| 1.0 | Approved teachers, sign-ups, profile completion, accepted connections, weekly active users |
| 2.0 | Booked classes per week, trial-to-paid conversion, gross bookings, repeat students, average rating |
| 3.0 | Academies onboarded, jobs filled, Pro subscribers, sanad chains verified |
| 4.0 | Monthly active learners, retention at 90 days, revenue per teacher, countries with 100+ teachers |

## 18. Team by version

| Version | Team |
| --- | --- |
| 1.0–1.1 | Product owner, 1–2 Flutter developers, part-time designer, part-time tester/moderator |
| 2.0 | + Python backend developer, + full-time moderator/verification lead, + support person |
| 3.0 | + web developer, + community/partnerships manager for academies and masjids |
| 4.0 | + data/ML engineer, + growth marketing |

## 19. Risks and how we handle them

| Risk | Mitigation |
| --- | --- |
| Not enough teachers at launch | Recruit 20+ founding teachers before launch; free Pro features for them later |
| Child-safety incident | 18+ only in v1.0; parent visibility, recordings and vetting before children join in v2.0 |
| Inappropriate or sectarian content | Clear content policy, report thresholds, moderators, block |
| Free-plan limits or project pause | Image compression, keep-alive ping, written upgrade triggers |
| Fake teachers / false credentials | Admin approval, certificate review, later ijazah verification and Sanad Tree endorsements |
| Teachers and students taking payments outside the app | Make in-app booking worth it: reminders, records, reviews, refunds, progress reports |
| Store rejection | Follow Play policies for UGC, data safety, account deletion; run the 12-tester / 14-day closed test |

## 20. Immediate next steps

1. Confirm the name **Asatiza**: Play/App Store search, domain, social handles, trademark search.
2. Create the Supabase project, Firebase project (FCM only) and Brevo account; buy the domain.
3. Recruit 20 founding teachers and 12+ closed-test testers.
4. Design the v1.0 screens.
5. Start the v1.0 build (8 weeks) following the Version 1.0 Plan.
