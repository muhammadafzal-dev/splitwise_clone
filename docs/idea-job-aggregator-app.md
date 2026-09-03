# Job Aggregator Mobile App — Research & Plan

> Researched: 2026-03-30

---

## Idea

A React Native mobile app that aggregates tech job listings from multiple sources (LinkedIn, Indeed, remote boards, EU boards), saves them to a central database, and notifies the user when new matching jobs arrive. User selects their job category (e.g. Software Engineer) and gets a filtered, deduplicated feed.

---

## Architecture (No Backend Required)

```
React Native App (Expo/CLI)
        |
        | supabase-js (direct)
        v
    Supabase
    - jobs table
    - user_prefs table
    - bookmarks table
    - Edge Function (push notifications only)
        ^
        |  insert new jobs via Supabase REST
        |
GitHub Actions (cron every 6 hours)
    - Fetch from all APIs
    - Normalize to common schema
    - Deduplicate (company + title + date hash)
    - Insert new jobs into Supabase
    - Trigger Edge Function → Expo Push API → user notified
```

**Key principle:** No separate backend server. GitHub Actions handles scheduling + fetching. Supabase handles storage + auth + push trigger. React Native reads directly from Supabase.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | React Native CLI (yarn) |
| Database | Supabase (PostgreSQL) |
| Auth | Supabase Auth (Google OAuth) |
| Scheduler | GitHub Actions (cron `0 */6 * * *`) |
| Fetcher Script | Node.js (runs in GitHub Actions) |
| Push Notifications | Expo Push API + Supabase Edge Function |
| Local storage | MMKV (preferences cache) |
| State management | Zustand + TanStack Query |

---

## Job API Sources

### Tier 1 — Free, No Credit Card (Always On)

#### Traditional / Office / Hybrid Jobs

| API | Countries | Free Limit | Auth | Endpoint |
|-----|-----------|------------|------|----------|
| **Adzuna** | US, UK, DE, FR, AU, CA + 8 more | 2,500 req/month | `app_id` + `app_key` query params | `api.adzuna.com/v1/api/jobs/{cc}/search/{page}` |
| **CareerJet** | 90+ countries | Free (affiliate signup) | Affiliate ID | `search.api.careerjet.net/v4/query` |
| **Reed.co.uk** | UK only | ~1,000 req/day | HTTP Basic Auth (API key) | `reed.co.uk/api/1.0/search` |
| **Arbeitnow** | Germany + EU | Unlimited | None | `arbeitnow.com/api/job-board-api` |
| **Bundesagentur** | Germany (official gov) | Unlimited | Fixed public key | `rest.arbeitsagentur.de/jobboerse/jobsuche-service/pc/v4/jobs` |
| **Jooble** | 70+ countries | Free (registration) | API key in POST body | `jooble.org/api/{key}` |

#### Remote Jobs

| API | Coverage | Free Limit | Auth | Endpoint |
|-----|----------|------------|------|----------|
| **Himalayas** | Global remote | Free (429 if abused) | None | `himalayas.app/jobs/api/search` |
| **RemoteOK** | Global remote (tech-heavy) | Free | None | `remoteok.io/api` |
| **Remotive** | Global remote | 2 req/min, max 4/day | None | `remotive.com/api/remote-jobs` |
| **Jobicy** | Global + regional | 1 req/hour recommended | None | `jobicy.com/api/v2/remote-jobs` |
| **We Work Remotely** | Global remote | Free | None | RSS: `weworkremotely.com/remote-jobs.rss` |
| **The Muse** | US-heavy | 3,600/hr (free key) | Optional API key | `themuse.com/api/public/v2/jobs` |

### Tier 2 — Low Cost Aggregators (Add Later)

| API | Coverage | Free Limit | Cost After Free |
|-----|----------|------------|-----------------|
| **JSearch (RapidAPI)** | Global — pulls Google for Jobs (includes LinkedIn + Indeed re-posts) | 500 req/month | ~$10-20/month for 10k req |
| **SerpAPI** | Global — live Google Jobs scrape | 250 searches/month | $25/month for 1k |

> JSearch is the key to getting LinkedIn + Indeed data indirectly through Google for Jobs, without needing their closed partner APIs.

### Not Viable for Solo Devs (Closed/Deprecated)

| Platform | Status |
|----------|--------|
| LinkedIn | Partner program only — no public API |
| Indeed Search API | Deprecated since 2023 |
| Glassdoor | Closed since 2021 |
| ZipRecruiter | Posting-only API (for employers) |
| Monster | Closed |
| Xing | No public API (DACH region) |
| StepStone | ATS posting API only |
| GitHub Jobs | Permanently shut down 2021 |

---

## Coverage Matrix by Region

| API | US | UK | Germany | France | EU (broad) | Remote |
|-----|----|----|---------|--------|------------|--------|
| Adzuna | ✅ | ✅ | ✅ | ✅ | ✅ (12 countries) | Partial |
| CareerJet | ✅ | ✅ | ✅ | ✅ | ✅ (90+ countries) | Partial |
| Jooble | ✅ | ✅ | ✅ | ✅ | ✅ (70+ countries) | Partial |
| Reed.co.uk | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Bundesagentur | ❌ | ❌ | ✅ | ❌ | ❌ | Partial |
| Arbeitnow | ❌ | ❌ | ✅ | ❌ | ✅ (EU) | ✅ |
| Remotive | Partial | Partial | Partial | Partial | Partial | ✅ only |
| RemoteOK | Partial | Partial | Partial | Partial | Partial | ✅ only |
| Himalayas | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ only |
| Jobicy | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ only |
| JSearch (paid) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## Normalized Job Schema

All sources get normalized to this before inserting into Supabase:

```json
{
  "id": "source_prefix:original_id",
  "title": "string",
  "company": "string",
  "location": "string",
  "country": "ISO 3166-1 alpha-2",
  "remote": "boolean",
  "salary_min": "number | null",
  "salary_max": "number | null",
  "currency": "string | null",
  "job_type": "full_time | part_time | contract | internship",
  "category": "software_engineer | frontend | backend | devops | data | mobile | ...",
  "description": "string",
  "apply_url": "string",
  "source": "adzuna | reed | remotive | himalayas | ...",
  "posted_at": "ISO 8601",
  "fetched_at": "ISO 8601"
}
```

---

## Supabase Tables

```sql
-- jobs: all aggregated job listings
jobs (id, title, company, location, country, remote, salary_min, salary_max,
      currency, job_type, category, description, apply_url, source,
      posted_at, fetched_at, hash)

-- user_prefs: per-user filters
user_prefs (user_id, categories[], locations[], remote_only, salary_min, push_token)

-- bookmarks: saved jobs per user
bookmarks (user_id, job_id, created_at)
```

---

## App Screens

1. **Home / Feed** — Job list filtered by user's selected category + filters
2. **Job Detail** — Full description, salary, apply button (opens browser)
3. **Bookmarks** — Saved jobs
4. **Filters / Preferences** — Category dropdown, location, remote toggle, salary range
5. **Notifications** — Toggle push alerts on/off per category

---

## GitHub Actions Workflow

```yaml
# .github/workflows/fetch-jobs.yml
name: Fetch Jobs
on:
  schedule:
    - cron: '0 */6 * * *'  # every 6 hours
  workflow_dispatch:         # manual trigger

jobs:
  fetch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npm install
      - run: node scripts/fetch-jobs.js
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_SERVICE_KEY: ${{ secrets.SUPABASE_SERVICE_KEY }}
          ADZUNA_APP_ID: ${{ secrets.ADZUNA_APP_ID }}
          ADZUNA_APP_KEY: ${{ secrets.ADZUNA_APP_KEY }}
          CAREERJET_AFFID: ${{ secrets.CAREERJET_AFFID }}
          REED_API_KEY: ${{ secrets.REED_API_KEY }}
          JOOBLE_API_KEY: ${{ secrets.JOOBLE_API_KEY }}
```

---

## Implementation Phases

### Phase 1 — Core (Build Now)
- [ ] React Native app scaffold (yarn, React Native CLI)
- [ ] Supabase setup (tables, RLS policies)
- [ ] GitHub Actions fetch script (Adzuna + Remotive + Himalayas + RemoteOK)
- [ ] Job feed screen with category filter
- [ ] Job detail screen with apply button
- [ ] Bookmark feature
- [ ] Push notifications (Expo Push + Supabase Edge Function)

### Phase 2 — Expand Sources
- [ ] Add CareerJet, Reed, Jooble, Jobicy, Arbeitnow, Bundesagentur
- [ ] Salary filter
- [ ] Remote toggle
- [ ] Location filter

### Phase 3 — Premium (Optional)
- [ ] Add JSearch (RapidAPI) for LinkedIn + Indeed coverage
- [ ] AI-based job matching score
- [ ] Resume upload → match percentage per job

---

## Cost Estimate (Monthly)

| Service | Cost |
|---------|------|
| Supabase | Free (up to 500MB DB, 50k MAU) |
| GitHub Actions | Free (2,000 min/month) |
| Expo Push Notifications | Free |
| All Tier 1 APIs | Free |
| **Total Phase 1** | **$0/month** |
