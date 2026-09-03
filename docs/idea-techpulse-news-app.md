# TechPulse — AI-Powered Tech & AI News Aggregator
### Full High-Level Research & Product Document

> React Native CLI Mobile App (iOS + Android)
> Status: Pre-Development Research
> Last Updated: 2026-03-26

---

## App Name: TechPulse

**Why TechPulse?**
Pulse = real-time heartbeat of what's happening. Tech = exactly what it covers. Together it's instantly clear, memorable, and searchable. Visually brandable with a pulsing animation on the logo/loading state.

**Alternatives considered:** Pulsar, Flare, Briefd, Epoch, Cortex

---

## The Problem

Tech moves fast. AI moves faster.

Every week: new models launch, new tools drop, new papers change the game, new companies raise or die. Yet:

- **Feedly/Inoreader** are for RSS power users, paywalled, no push notifications for breaking news
- **Flipboard/SmartNews** are ad-heavy, algorithm-driven, generic — not for developers
- **TLDR/Morning Brew** are email newsletters, once-a-day, no real-time updates
- **Twitter/X** is noise — finding signal requires already knowing who to follow
- **Artifact** (Instagram co-founders) tried to solve this but shut down in Jan 2024 — mixed identity, not focused

**No app exists today that:**
- Focuses exclusively on tech + AI news
- Delivers breaking AI lab announcements in real time
- Summarizes content with AI so you read 10x faster
- Works offline, without an account, with full personalization

---

## The Solution: Pulsar

Pulsar aggregates signals from 30+ top tech and AI sources, summarizes every article with AI into 3-line cards, and alerts you the moment something major drops — before anyone in your network tells you.

**Core value proposition:**
> "Know what matters in tech and AI — faster than everyone around you."

---

## Target User

**Primary:** Developers, engineers, tech PMs, startup founders aged 22–40
- Reads Hacker News but wants less noise
- Subscribes to TLDR but wants real-time, not daily
- Misses Artifact, uses Feedly but frustrated with cost/UX

**Secondary:** Tech-curious non-developers who want to stay informed on AI
- Hears about ChatGPT updates from colleagues after the fact
- Wants to understand what's happening without reading 10 tabs

---

## Unique Differentiators (vs All Competitors)

| Feature | Pulsar | Feedly | SmartNews | TLDR | Artifact |
|---------|--------|--------|-----------|------|----------|
| AI-generated summaries | ✅ | ❌ | ❌ | Manual | ✅ (had it) |
| Push for breaking AI news | ✅ | ❌ | ❌ | ❌ | ❌ |
| arXiv / research papers | ✅ | Manual | ❌ | ❌ | ❌ |
| GitHub Trending | ✅ | ❌ | ❌ | ❌ | ❌ |
| No account required | ✅ | ❌ | ❌ | ❌ | ❌ |
| "Why it matters" context | ✅ | ❌ | ❌ | ❌ | ❌ |
| Offline reading | ✅ | Pro only | ❌ | ❌ | ❌ |
| Developer mode filter | ✅ | ❌ | ❌ | ❌ | ❌ |
| Free, no ads in core | ✅ | ❌ | ❌ | ✅ | ✅ |
| Impact score (HN + Reddit) | ✅ | ❌ | ❌ | ❌ | ❌ |

---

## News Sources (30+ Feeds)

### AI Labs (Highest Priority)
| Source | Feed Type | Update Frequency |
|--------|-----------|-----------------|
| OpenAI Blog | RSS | Weekly |
| Anthropic News | RSS | Weekly |
| Google DeepMind Blog | RSS | Weekly |
| Meta AI Blog | RSS | Weekly |
| HuggingFace Blog | RSS | Daily |
| HuggingFace Daily Papers | API | Daily |
| Mistral AI Blog | RSS | Monthly |

### Developer / Code
| Source | Feed Type |
|--------|-----------|
| Hacker News (top stories, 100+ points) | Official API |
| GitHub Trending (daily) | RSSHub |
| Papers With Code | RSS |
| arXiv (cs.AI, cs.LG, cs.CL) | Official API |

### Product Launches
| Source | Feed Type |
|--------|-----------|
| Product Hunt (daily top) | GraphQL API |
| BetaList | RSS |

### Tech News
| Source | Feed Type |
|--------|-----------|
| TechCrunch AI | RSS |
| VentureBeat AI | RSS |
| MIT Technology Review | RSS |
| Wired (Tech) | RSS |
| Ars Technica | RSS |
| The Verge | RSS |
| The Information (excerpts) | RSS |

### Research & Deep Tech
| Source | Feed Type |
|--------|-----------|
| TLDR AI Newsletter | RSS |
| deeplearning.ai The Batch | RSS |
| AI News (ainews.io) | RSS |

---

## Core Features (MVP)

### 1. Smart Feed
- Unified feed from all sources, sorted by "Impact Score" (not just recency)
- AI-generated 2-sentence summary + 3 bullet points per article
- "Why this matters" 1-liner for developer audience
- Source tag, reading time, published time
- Pull-to-refresh + auto-refresh every 30 minutes

### 2. Categories / Tabs
- **All** — full feed
- **AI Models** — lab announcements, model releases
- **Tools** — new products, Product Hunt drops
- **Papers** — arXiv + HuggingFace + Papers With Code
- **Dev** — Hacker News, GitHub Trending
- **Funding** — startup raises, acquisitions

### 3. Breaking News Push Notifications
- Instant push when a major AI lab posts something new
- Topic subscriptions: "OpenAI", "Claude", "Gemini", "Breaking AI"
- Smart throttling — max 3 pushes/day to avoid notification fatigue

### 4. Offline Reading Queue
- Save any article with one tap (full text cached)
- Access saved articles with zero internet
- WatermelonDB for fast SQLite-backed offline storage

### 5. No Account Required
- All preferences stored on-device (device UUID in MMKV)
- Bookmarks, read history, topic preferences — all local
- Optional account sync (future) for cross-device

### 6. Dark Mode by Default
- Dark and light themes
- OLED dark mode option (true black)

---

## Impact Score Algorithm

Each article is scored 0–100 based on:

```
Impact Score = (
  HN_points * 0.4 +
  HN_comment_count * 0.2 +
  source_tier_score * 0.25 +    // AI lab post = 100, TechCrunch = 60
  recency_score * 0.15           // published < 2 hours ago gets boost
)
```

Source tier scores:
- OpenAI / Anthropic / Google DeepMind / Meta AI direct post = 95
- HuggingFace / arXiv paper = 80
- TechCrunch / MIT Tech Review = 65
- The Verge / Wired = 55
- Others = 40

---

## Technical Architecture

### Mobile App (React Native CLI)

```
src/
├── screens/
│   ├── FeedScreen          # Main article list (FlashList v2)
│   ├── ArticleScreen       # Full article / in-app browser
│   ├── BookmarksScreen     # Saved articles
│   ├── DiscoverScreen      # Topics + Sources browser
│   └── SettingsScreen      # Preferences, notifications
├── components/
│   ├── ArticleCard         # Summary card with impact score
│   ├── CategoryTabs        # Horizontal scrolling tabs
│   ├── SkeletonLoader      # Loading placeholders
│   └── BottomSheet         # Article preview sheet
├── store/
│   ├── usePreferencesStore  # Zustand: topics, sources, theme
│   └── useBookmarksStore    # Zustand: bookmarked articles
├── api/
│   └── articles.ts          # TanStack Query hooks
├── db/
│   └── watermelon.ts        # WatermelonDB schema
└── notifications/
    └── firebase.ts          # FCM setup
```

**Stack:**

| Layer | Technology |
|-------|-----------|
| Framework | React Native CLI 0.73+ (New Architecture) |
| Language | TypeScript |
| Navigation | React Navigation v7 (Stack + Bottom Tabs) |
| Feed Lists | FlashList v2 (Shopify) |
| Server State | TanStack Query v5 |
| Client State | Zustand |
| Persistence | react-native-mmkv |
| Offline DB | WatermelonDB |
| Push Notifications | @react-native-firebase/messaging + Notifee |
| Background Fetch | react-native-background-fetch |
| In-app Browser | react-native-webview |
| Animations | react-native-reanimated 3 |

---

### Backend

```
.github/
└── workflows/
    └── fetch-news.yml       # Scheduled: runs twice daily (8 AM + 8 PM UTC)

scripts/
├── fetch-feeds.ts           # Fetches all RSS feeds + HN API + GitHub Trending
├── score-articles.ts        # Calculates impact score per article
├── summarize.ts             # Batches articles → Gemini 2.5 Flash
└── notify.ts                # Triggers FCM push if impact_score > 85

supabase/
└── migrations/
    └── schema.sql           # PostgreSQL schema
```

**Stack (100% Free):**

| Component | Technology | Cost |
|-----------|-----------|------|
| Cron Jobs | GitHub Actions (scheduled workflow) | $0 |
| Database | Supabase PostgreSQL (free tier) | $0 |
| RSS Feeds | Direct RSS URLs (no hosting needed) | $0 |
| GitHub Trending RSS | mshibanami.github.io/GitHubTrendingRSS | $0 |
| HN Feed | Official Hacker News Firebase API | $0 |
| Product Hunt | Official GraphQL API (free tier) | $0 |
| AI Summarization | Gemini 2.5 Flash (Google AI Studio free tier) | $0 |
| Push Notifications | Firebase Cloud Messaging (FCM) | $0 |
| Monitoring | Sentry (free tier, 5K errors/month) | $0 |
| **Total** | | **$0/month** |

> **GitHub Actions free limits:** Public repo = unlimited minutes. Private repo = 2,000 min/month. 2 runs/day × 3 min × 30 days = 180 min/month. Well within limits.
>
> **Gemini 2.5 Flash free limits:** ~500 req/day. Batch 5 articles per request = 20 req/day used. Well within limits.
>
> **Supabase free tier note:** Projects pause after 1 week of inactivity. Add a keep-alive GitHub Actions ping every 5 days to prevent this.

---

### Data Flow

```
Trigger A — Scheduled (8 AM + 8 PM via GitHub Actions):
  → fetch all RSS feeds + HN API + GitHub Trending RSS
  → deduplicate (skip already-stored URLs)
  → calculate impact score per article
  → batch new articles → Gemini 2.5 Flash → store summaries
  → if impact_score > 85 → trigger FCM push notification

Trigger B — Manual refresh (user taps Refresh in app):
  → calls Supabase Edge Function (same logic as above)
  → fetch RSS → deduplicate → summarize with Gemini → store
  → app receives fresh summarized cards immediately

Trigger C — App opens:
  → TanStack Query reads latest articles from Supabase DB
  → instant, no extra processing
```

Mobile App:
  On open → TanStack Query fetches latest 50 articles
  On scroll → infinite scroll loads next page
  On background → react-native-background-fetch checks for new articles
  On notification tap → deep link to specific article
```

---

## Database Schema

```sql
-- Sources
CREATE TABLE sources (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  rss_url TEXT NOT NULL,
  category TEXT NOT NULL,  -- ai_labs, dev, news, papers, products
  tier_score INTEGER DEFAULT 50,
  is_active BOOLEAN DEFAULT true,
  last_fetched_at TIMESTAMPTZ
);

-- Articles
CREATE TABLE articles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  source_id UUID REFERENCES sources(id),
  title TEXT NOT NULL,
  url TEXT UNIQUE NOT NULL,
  published_at TIMESTAMPTZ NOT NULL,
  author TEXT,
  thumbnail_url TEXT,
  full_text TEXT,
  excerpt TEXT,
  summary_tldr TEXT,        -- AI: 2-sentence summary
  summary_bullets JSONB,    -- AI: ["bullet1", "bullet2", "bullet3"]
  why_it_matters TEXT,      -- AI: 1-line developer context
  tags TEXT[],              -- AI: extracted tags
  hn_score INTEGER DEFAULT 0,
  hn_comments INTEGER DEFAULT 0,
  impact_score INTEGER DEFAULT 0,
  reading_time_seconds INTEGER,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_articles_published_at ON articles(published_at DESC);
CREATE INDEX idx_articles_impact_score ON articles(impact_score DESC);
CREATE INDEX idx_articles_source_id ON articles(source_id);

-- No user accounts table — all preferences stored on-device
```

---

## Cost Breakdown

### Running Cost (MVP, 100 users/day) — 100% Free

| Item | Monthly Cost | Free Tier Limit |
|------|-------------|-----------------|
| GitHub Actions (cron jobs) | $0 | 2,000 min/month — using only 180 |
| Supabase PostgreSQL | $0 | 500MB DB, 50K MAU |
| Gemini 2.5 Flash | $0 | ~500 req/day — using only 20 |
| Firebase FCM | $0 | 1M messages/month |
| React Native CLI | $0 | Open source |
| RSS Feeds (direct URLs) | $0 | No limits |
| HN API / Product Hunt API | $0 | No rate limit / free tier |
| **Total** | **$0/month** | |

### Scaling Cost (when free tiers are exceeded)

| Item | Monthly Cost | When Needed |
|------|-------------|-------------|
| Supabase Pro | $25 | >500MB DB or >50K MAU |
| Gemini API paid | ~$5–16 | >500 articles/day summarized |
| **Total** | **~$30–41/month** | At 1,000+ active users |

---

## Build Phases

### Phase 0: Setup (Week 1)
- React Native CLI project init
- Navigation structure
- Supabase project + schema
- Railway + RSSHub deployment
- Basic RSS fetcher worker

### Phase 1: Core Feed (Week 1–2)
- Article list screen (FlashList v2)
- Article card component (title, source, excerpt)
- Basic category tabs
- Pull-to-refresh
- In-app browser for full article

### Phase 2: AI Layer (Week 2–3)
- Gemini summarization worker
- Display AI summaries on cards
- Impact score calculation
- "Why it matters" blurb

### Phase 3: Personalization (Week 3)
- Topic/source preference screen
- On-device filtering (Zustand + MMKV)
- Bookmarks / saved articles (WatermelonDB)
- Read history tracking

### Phase 4: Notifications (Week 3–4)
- Firebase setup (Android + iOS)
- Push for breaking news (impact_score > 85)
- Topic subscription (e.g., subscribe to "OpenAI news")
- Notification settings screen

### Phase 5: Polish (Week 4)
- Offline reading mode
- Skeleton loaders
- Dark/light/OLED themes
- Animations (react-native-reanimated)
- Performance tuning (New Architecture validation)

### Phase 6: Launch
- App Store submission (iOS)
- Google Play submission (Android)
- Beta test with 10 users

---

## MVP Success Metrics

| Metric | Target (30 days post-launch) |
|--------|------------------------------|
| Downloads | 500+ |
| D7 retention | > 40% |
| Average opens/week | > 5 |
| Notifications opt-in rate | > 60% |
| Crash-free sessions | > 99% |

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| RSS feeds change/break | Fallback to excerpt-only + source health check in DB |
| AI summarization cost spikes | Daily budget cap, fallback to excerpt-only |
| App Store rejection (scraping) | Use only RSS/official APIs, no scraping in app |
| Push notification fatigue | Max 3/day limit, user control in settings |
| Supabase free tier pausing | Keep-alive cron ping every 6 days |
| React Native CLI complexity vs Expo | Use well-documented libraries, detailed setup guide |

---

## What Makes Pulsar Win

1. **Speed** — Breaking AI news within 15 minutes of publication, not next morning
2. **Signal, not noise** — Impact Score filters out clickbait before it reaches your feed
3. **AI-native** — Not RSS with a veneer; AI summaries + context are first-class features
4. **Developer-first** — GitHub Trending, arXiv papers, HN integration — built for builders
5. **No friction** — No account, no onboarding form, open and read instantly
6. **Offline-first** — Full article cache works on flights, subway, poor connection

---

*Document created: 2026-03-26*
*Research basis: 40+ sources across competitor analysis, tech stack research, cost analysis*
