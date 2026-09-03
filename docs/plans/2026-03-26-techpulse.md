# TechPulse Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build TechPulse — a React Native CLI mobile app that aggregates tech & AI news from 30+ sources, summarizes with Gemini 2.5 Flash, and delivers breaking news push notifications.

**Architecture:** GitHub Actions runs twice daily (+ on-demand via Supabase Edge Function) to fetch RSS feeds, score articles, and summarize with Gemini. Mobile app reads pre-processed articles from Supabase. Firebase FCM handles push notifications. All $0/month.

**Tech Stack:** React Native CLI 0.73+ (TypeScript, New Architecture), React Navigation v7, FlashList v2, TanStack Query v5, Zustand, react-native-mmkv, WatermelonDB, @react-native-firebase/messaging, Notifee, Supabase PostgreSQL, GitHub Actions, Gemini 2.5 Flash

---

## Phase 0: Project Scaffold

### Task 0.1 — Initialize React Native CLI project

**Files:**
- Create: `techpulse/` (project root)

**Step 1: Create the project**
```bash
cd /Users/muhammadafzal/Desktop/personal/my_dev
npx @react-native-community/cli@latest init techpulse --template react-native-template-typescript
cd techpulse
```

**Step 2: Verify it builds and runs**
```bash
# iOS
npx react-native run-ios

# Android
npx react-native run-android
```
Expected: Default React Native welcome screen on simulator.

**Step 3: Commit**
```bash
git init
git add .
git commit -m "chore: init React Native CLI project"
```

---

### Task 0.2 — Install all dependencies

**Step 1: Install navigation**
```bash
npm install @react-navigation/native@^7 @react-navigation/bottom-tabs@^7 @react-navigation/stack@^7
npm install react-native-screens react-native-safe-area-context react-native-gesture-handler react-native-reanimated
```

**Step 2: Install data & state**
```bash
npm install @tanstack/react-query zustand
npm install react-native-mmkv
```

**Step 3: Install UI & lists**
```bash
npm install @shopify/flash-list
npm install react-native-webview
npm install @nozbe/watermelondb
```

**Step 4: Install Firebase & notifications**
```bash
npm install @react-native-firebase/app @react-native-firebase/messaging
npm install @notifee/react-native
npm install react-native-background-fetch
```

**Step 5: Install Supabase client**
```bash
npm install @supabase/supabase-js
npm install react-native-url-polyfill
```

**Step 6: Install dev dependencies**
```bash
npm install -D @types/react @types/react-native
```

**Step 7: iOS pod install**
```bash
cd ios && pod install && cd ..
```

**Step 8: Commit**
```bash
git add .
git commit -m "chore: install all dependencies"
```

---

### Task 0.3 — Setup folder structure

**Files to create:**
```
src/
├── screens/
│   ├── FeedScreen.tsx
│   ├── ArticleScreen.tsx
│   ├── BookmarksScreen.tsx
│   ├── DiscoverScreen.tsx
│   └── SettingsScreen.tsx
├── components/
│   ├── ArticleCard.tsx
│   ├── CategoryTabs.tsx
│   ├── SkeletonCard.tsx
│   └── EmptyState.tsx
├── navigation/
│   ├── AppNavigator.tsx
│   └── types.ts
├── store/
│   ├── usePreferencesStore.ts
│   └── useBookmarksStore.ts
├── api/
│   ├── supabase.ts
│   └── articles.ts
├── lib/
│   └── queryClient.ts
├── types/
│   └── index.ts
└── constants/
    └── index.ts
```

**Step 1: Create all directories and placeholder files**
```bash
mkdir -p src/screens src/components src/navigation src/store src/api src/lib src/types src/constants

# Create placeholder files
touch src/screens/FeedScreen.tsx
touch src/screens/ArticleScreen.tsx
touch src/screens/BookmarksScreen.tsx
touch src/screens/DiscoverScreen.tsx
touch src/screens/SettingsScreen.tsx
touch src/components/ArticleCard.tsx
touch src/components/CategoryTabs.tsx
touch src/components/SkeletonCard.tsx
touch src/components/EmptyState.tsx
touch src/navigation/AppNavigator.tsx
touch src/navigation/types.ts
touch src/store/usePreferencesStore.ts
touch src/store/useBookmarksStore.ts
touch src/api/supabase.ts
touch src/api/articles.ts
touch src/lib/queryClient.ts
touch src/types/index.ts
touch src/constants/index.ts
```

**Step 2: Create `.env` file (do NOT commit this)**
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GEMINI_API_KEY=your_gemini_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
```

**Step 3: Create `.env.example` (commit this)**
```
SUPABASE_URL=
SUPABASE_ANON_KEY=
GEMINI_API_KEY=
FIREBASE_PROJECT_ID=
```

**Step 4: Add `.env` to `.gitignore`**
```bash
echo ".env" >> .gitignore
echo "google-services.json" >> .gitignore
echo "GoogleService-Info.plist" >> .gitignore
```

**Step 5: Commit**
```bash
git add .
git commit -m "chore: setup folder structure and env config"
```

---

### Task 0.4 — Define TypeScript types

**File:** `src/types/index.ts`
```typescript
export interface Article {
  id: string
  source_id: string
  source_name: string
  title: string
  url: string
  published_at: string
  author: string | null
  thumbnail_url: string | null
  excerpt: string | null
  summary_tldr: string | null
  summary_bullets: string[] | null
  why_it_matters: string | null
  tags: string[]
  impact_score: number
  reading_time_seconds: number
  created_at: string
}

export interface Source {
  id: string
  name: string
  category: ArticleCategory
  rss_url: string
  tier_score: number
  is_active: boolean
}

export type ArticleCategory =
  | 'all'
  | 'ai_labs'
  | 'tools'
  | 'papers'
  | 'dev'
  | 'news'
  | 'funding'

export type Theme = 'dark' | 'light' | 'oled'

export interface UserPreferences {
  theme: Theme
  selectedCategories: ArticleCategory[]
  notificationsEnabled: boolean
  breakingNewsOnly: boolean
}
```

**Step 1: Write the file above**

**Step 2: Commit**
```bash
git add src/types/index.ts
git commit -m "feat: add TypeScript type definitions"
```

---

### Task 0.5 — Setup navigation

**File:** `src/navigation/types.ts`
```typescript
import { StackNavigationProp } from '@react-navigation/stack'
import { RouteProp } from '@react-navigation/native'

export type RootStackParamList = {
  MainTabs: undefined
  Article: { articleId: string; url: string; title: string }
}

export type MainTabParamList = {
  Feed: undefined
  Bookmarks: undefined
  Discover: undefined
  Settings: undefined
}

export type FeedNavigationProp = StackNavigationProp<RootStackParamList, 'MainTabs'>
export type ArticleRouteProp = RouteProp<RootStackParamList, 'Article'>
```

**File:** `src/navigation/AppNavigator.tsx`
```typescript
import React from 'react'
import { NavigationContainer } from '@react-navigation/native'
import { createStackNavigator } from '@react-navigation/stack'
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs'
import FeedScreen from '../screens/FeedScreen'
import ArticleScreen from '../screens/ArticleScreen'
import BookmarksScreen from '../screens/BookmarksScreen'
import DiscoverScreen from '../screens/DiscoverScreen'
import SettingsScreen from '../screens/SettingsScreen'
import type { RootStackParamList, MainTabParamList } from './types'

const Stack = createStackNavigator<RootStackParamList>()
const Tab = createBottomTabNavigator<MainTabParamList>()

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: { backgroundColor: '#0f172a', borderTopColor: '#1e293b' },
        tabBarActiveTintColor: '#3b82f6',
        tabBarInactiveTintColor: '#64748b',
      }}
    >
      <Tab.Screen name="Feed" component={FeedScreen} />
      <Tab.Screen name="Bookmarks" component={BookmarksScreen} />
      <Tab.Screen name="Discover" component={DiscoverScreen} />
      <Tab.Screen name="Settings" component={SettingsScreen} />
    </Tab.Navigator>
  )
}

export default function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        <Stack.Screen name="MainTabs" component={MainTabs} />
        <Stack.Screen name="Article" component={ArticleScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  )
}
```

**File:** `App.tsx` (replace contents)
```typescript
import React from 'react'
import { GestureHandlerRootView } from 'react-native-gesture-handler'
import { QueryClientProvider } from '@tanstack/react-query'
import AppNavigator from './src/navigation/AppNavigator'
import { queryClient } from './src/lib/queryClient'
import 'react-native-url-polyfill/auto'

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <QueryClientProvider client={queryClient}>
        <AppNavigator />
      </QueryClientProvider>
    </GestureHandlerRootView>
  )
}
```

**File:** `src/lib/queryClient.ts`
```typescript
import { QueryClient } from '@tanstack/react-query'

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,   // 5 minutes
      gcTime: 1000 * 60 * 30,      // 30 minutes
      retry: 2,
    },
  },
})
```

**Step 1: Write all files above**

**Step 2: Add placeholder screens so navigation compiles**

For each screen file (`FeedScreen.tsx`, `ArticleScreen.tsx`, etc.):
```typescript
import React from 'react'
import { View, Text, StyleSheet } from 'react-native'

export default function FeedScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>Feed</Text>
    </View>
  )
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0f172a', justifyContent: 'center', alignItems: 'center' },
  text: { color: '#fff', fontSize: 18 },
})
```

**Step 3: Run the app to verify navigation works**
```bash
npx react-native run-ios
```
Expected: App opens with bottom tabs (Feed, Bookmarks, Discover, Settings).

**Step 4: Commit**
```bash
git add .
git commit -m "feat: setup navigation structure with bottom tabs"
```

---

## Phase 1: Supabase Database

### Task 1.1 — Create Supabase project (manual step)

**Step 1:** Go to https://supabase.com → New project
**Step 2:** Copy `Project URL` and `anon key`
**Step 3:** Paste into `.env`:
```
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

---

### Task 1.2 — Run database schema

**Step 1:** Go to Supabase Dashboard → SQL Editor → run this:

```sql
-- Sources table
CREATE TABLE public.sources (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  rss_url TEXT NOT NULL,
  category TEXT NOT NULL,
  tier_score INTEGER DEFAULT 50,
  is_active BOOLEAN DEFAULT true,
  last_fetched_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Articles table
CREATE TABLE public.articles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  source_id UUID REFERENCES public.sources(id),
  source_name TEXT NOT NULL,
  title TEXT NOT NULL,
  url TEXT UNIQUE NOT NULL,
  published_at TIMESTAMPTZ NOT NULL,
  author TEXT,
  thumbnail_url TEXT,
  excerpt TEXT,
  full_text TEXT,
  summary_tldr TEXT,
  summary_bullets JSONB,
  why_it_matters TEXT,
  tags TEXT[] DEFAULT '{}',
  impact_score INTEGER DEFAULT 0,
  hn_score INTEGER DEFAULT 0,
  hn_comments INTEGER DEFAULT 0,
  reading_time_seconds INTEGER DEFAULT 120,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_articles_published_at ON public.articles(published_at DESC);
CREATE INDEX idx_articles_impact_score ON public.articles(impact_score DESC);
CREATE INDEX idx_articles_source_id ON public.articles(source_id);
CREATE INDEX idx_articles_tags ON public.articles USING GIN(tags);

-- Enable RLS (public read, no write from client)
ALTER TABLE public.sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read sources" ON public.sources FOR SELECT USING (true);
CREATE POLICY "Public read articles" ON public.articles FOR SELECT USING (true);
```

**Step 2:** Verify tables exist in Supabase Dashboard → Table Editor.

---

### Task 1.3 — Seed initial sources

**Step 1:** Run this in Supabase SQL Editor:

```sql
INSERT INTO public.sources (name, rss_url, category, tier_score) VALUES
-- AI Labs (tier 95)
('OpenAI Blog', 'https://openai.com/news/rss.xml', 'ai_labs', 95),
('Anthropic Blog', 'https://www.anthropic.com/rss.xml', 'ai_labs', 95),
('Google DeepMind', 'https://deepmind.google/blog/rss.xml', 'ai_labs', 95),
('HuggingFace Blog', 'https://huggingface.co/blog/feed.xml', 'ai_labs', 85),
-- Papers (tier 80)
('Papers With Code', 'https://paperswithcode.com/rss', 'papers', 80),
('TLDR AI', 'https://tldr.tech/api/rss/ai', 'papers', 75),
-- Dev (tier 70)
('GitHub Trending', 'https://mshibanami.github.io/GitHubTrendingRSS/daily/all.xml', 'dev', 70),
-- News (tier 65)
('TechCrunch AI', 'https://techcrunch.com/category/artificial-intelligence/feed/', 'news', 65),
('VentureBeat AI', 'https://venturebeat.com/ai/feed/', 'news', 65),
('MIT Tech Review', 'https://www.technologyreview.com/c/artificial-intelligence/rss/', 'news', 65),
('Ars Technica', 'https://feeds.arstechnica.com/arstechnica/index', 'news', 60),
('The Verge', 'https://www.theverge.com/rss/index.xml', 'news', 55);
```

---

### Task 1.4 — Setup Supabase client in app

**File:** `src/api/supabase.ts`
```typescript
import { createClient } from '@supabase/supabase-js'
import { MMKV } from 'react-native-mmkv'

const storage = new MMKV({ id: 'supabase-storage' })

const supabaseUrl = process.env.SUPABASE_URL!
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: {
      getItem: (key) => storage.getString(key) ?? null,
      setItem: (key, value) => storage.set(key, value),
      removeItem: (key) => storage.delete(key),
    },
    autoRefreshToken: false,
    persistSession: false,
    detectSessionInUrl: false,
  },
})
```

**Note:** For environment variables in React Native CLI, install `react-native-config`:
```bash
npm install react-native-config
cd ios && pod install && cd ..
```
Then use `Config.SUPABASE_URL` instead of `process.env.SUPABASE_URL`.

**Step 1: Install react-native-config**
```bash
npm install react-native-config
cd ios && pod install && cd ..
```

**Step 2: Update `src/api/supabase.ts` to use Config:**
```typescript
import Config from 'react-native-config'
// Replace process.env.SUPABASE_URL with Config.SUPABASE_URL
// Replace process.env.SUPABASE_ANON_KEY with Config.SUPABASE_ANON_KEY
```

**Step 3: Commit**
```bash
git add .
git commit -m "feat: setup Supabase client with MMKV storage"
```

---

## Phase 2: Backend Worker (GitHub Actions)

### Task 2.1 — Create the worker script

**Files:**
- Create: `worker/index.ts`
- Create: `worker/fetchFeeds.ts`
- Create: `worker/summarize.ts`
- Create: `worker/package.json`

**File:** `worker/package.json`
```json
{
  "name": "techpulse-worker",
  "version": "1.0.0",
  "scripts": {
    "start": "ts-node index.ts",
    "build": "tsc"
  },
  "dependencies": {
    "@supabase/supabase-js": "^2",
    "rss-parser": "^3",
    "@google/generative-ai": "^0.21.0",
    "node-fetch": "^3"
  },
  "devDependencies": {
    "typescript": "^5",
    "ts-node": "^10",
    "@types/node": "^20"
  }
}
```

**File:** `worker/fetchFeeds.ts`
```typescript
import Parser from 'rss-parser'

const parser = new Parser({
  timeout: 10000,
  headers: { 'User-Agent': 'TechPulse/1.0 RSS Reader' },
})

export interface RawArticle {
  title: string
  url: string
  published_at: string
  author: string | null
  excerpt: string | null
  source_name: string
  source_id: string
  tier_score: number
  category: string
}

export async function fetchFeed(source: {
  id: string
  name: string
  rss_url: string
  tier_score: number
  category: string
}): Promise<RawArticle[]> {
  try {
    const feed = await parser.parseURL(source.rss_url)
    return (feed.items || []).slice(0, 20).map((item) => ({
      title: item.title?.trim() || '',
      url: item.link || item.guid || '',
      published_at: item.pubDate || item.isoDate || new Date().toISOString(),
      author: item.creator || item.author || null,
      excerpt: item.contentSnippet?.slice(0, 500) || item.summary?.slice(0, 500) || null,
      source_name: source.name,
      source_id: source.id,
      tier_score: source.tier_score,
      category: source.category,
    })).filter((a) => a.url && a.title)
  } catch (err) {
    console.error(`Failed to fetch ${source.name}:`, err)
    return []
  }
}
```

**File:** `worker/summarize.ts`
```typescript
import { GoogleGenerativeAI } from '@google/generative-ai'
import type { RawArticle } from './fetchFeeds'

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!)
const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' })

export interface SummarizedArticle extends RawArticle {
  summary_tldr: string
  summary_bullets: string[]
  why_it_matters: string
  tags: string[]
  reading_time_seconds: number
}

const BATCH_SIZE = 5

function buildPrompt(articles: RawArticle[]): string {
  const articlesText = articles
    .map((a, i) => `[${i}] TITLE: ${a.title}\nEXCERPT: ${a.excerpt || 'No excerpt available'}`)
    .join('\n\n')

  return `You are a tech news analyst for developers and engineers. Summarize these ${articles.length} articles.

${articlesText}

Return ONLY a JSON array with exactly ${articles.length} objects in the same order:
[
  {
    "tldr": "2 sentence summary",
    "bullets": ["key point 1", "key point 2", "key point 3"],
    "why_it_matters": "1 sentence: why a developer should care",
    "tags": ["tag1", "tag2", "tag3"],
    "reading_time_seconds": 120
  }
]

No markdown, no explanation. Just the JSON array.`
}

export async function summarizeBatch(articles: RawArticle[]): Promise<SummarizedArticle[]> {
  const results: SummarizedArticle[] = []

  for (let i = 0; i < articles.length; i += BATCH_SIZE) {
    const batch = articles.slice(i, i + BATCH_SIZE)
    try {
      const result = await model.generateContent(buildPrompt(batch))
      const text = result.response.text().trim()
      const jsonText = text.replace(/^```json?\n?/, '').replace(/\n?```$/, '')
      const summaries = JSON.parse(jsonText)

      batch.forEach((article, idx) => {
        results.push({
          ...article,
          summary_tldr: summaries[idx]?.tldr || '',
          summary_bullets: summaries[idx]?.bullets || [],
          why_it_matters: summaries[idx]?.why_it_matters || '',
          tags: summaries[idx]?.tags || [],
          reading_time_seconds: summaries[idx]?.reading_time_seconds || 120,
        })
      })

      // Rate limit: wait 2 seconds between batches (free tier: 10 RPM)
      if (i + BATCH_SIZE < articles.length) {
        await new Promise((r) => setTimeout(r, 2000))
      }
    } catch (err) {
      console.error(`Summarization batch failed:`, err)
      // Add articles without summaries on failure
      batch.forEach((article) => {
        results.push({
          ...article,
          summary_tldr: '',
          summary_bullets: [],
          why_it_matters: '',
          tags: [],
          reading_time_seconds: 120,
        })
      })
    }
  }

  return results
}
```

**File:** `worker/index.ts`
```typescript
import { createClient } from '@supabase/supabase-js'
import { fetchFeed } from './fetchFeeds'
import { summarizeBatch } from './summarize'

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!  // service role for writes
)

async function calculateImpactScore(article: {
  tier_score: number
  hn_score?: number
  hn_comments?: number
  published_at: string
}): Promise<number> {
  const tierComponent = article.tier_score * 0.4
  const hnComponent = Math.min((article.hn_score || 0) * 0.3, 30)
  const commentComponent = Math.min((article.hn_comments || 0) * 0.1, 10)
  const hoursOld = (Date.now() - new Date(article.published_at).getTime()) / 3600000
  const recencyScore = Math.max(0, 20 - hoursOld * 0.5)

  return Math.round(tierComponent + hnComponent + commentComponent + recencyScore)
}

async function run() {
  console.log('TechPulse worker starting...')

  // 1. Fetch all active sources from DB
  const { data: sources, error: sourcesError } = await supabase
    .from('sources')
    .select('*')
    .eq('is_active', true)

  if (sourcesError || !sources) {
    console.error('Failed to fetch sources:', sourcesError)
    process.exit(1)
  }

  console.log(`Fetching from ${sources.length} sources...`)

  // 2. Fetch all feeds in parallel
  const allRawArticles = (
    await Promise.all(sources.map((source) => fetchFeed(source)))
  ).flat()

  console.log(`Fetched ${allRawArticles.length} raw articles`)

  // 3. Deduplicate against existing articles
  const urls = allRawArticles.map((a) => a.url)
  const { data: existing } = await supabase
    .from('articles')
    .select('url')
    .in('url', urls)

  const existingUrls = new Set((existing || []).map((a) => a.url))
  const newArticles = allRawArticles.filter((a) => !existingUrls.has(a.url))

  console.log(`${newArticles.length} new articles to process`)

  if (newArticles.length === 0) {
    console.log('No new articles. Done.')
    return
  }

  // 4. Summarize with Gemini
  const summarized = await summarizeBatch(newArticles)

  // 5. Calculate impact scores and insert
  const toInsert = await Promise.all(
    summarized.map(async (article) => ({
      source_id: article.source_id,
      source_name: article.source_name,
      title: article.title,
      url: article.url,
      published_at: article.published_at,
      author: article.author,
      excerpt: article.excerpt,
      summary_tldr: article.summary_tldr,
      summary_bullets: article.summary_bullets,
      why_it_matters: article.why_it_matters,
      tags: article.tags,
      reading_time_seconds: article.reading_time_seconds,
      impact_score: await calculateImpactScore({
        tier_score: article.tier_score,
        published_at: article.published_at,
      }),
    }))
  )

  const { error: insertError } = await supabase
    .from('articles')
    .upsert(toInsert, { onConflict: 'url', ignoreDuplicates: true })

  if (insertError) {
    console.error('Insert failed:', insertError)
    process.exit(1)
  }

  console.log(`Successfully inserted ${toInsert.length} articles`)
}

run().catch((err) => {
  console.error('Worker failed:', err)
  process.exit(1)
})
```

**Step 1: Write all files above**

**Step 2: Install worker dependencies**
```bash
cd worker
npm install
cd ..
```

**Step 3: Test locally with a real .env**
```bash
cd worker
SUPABASE_URL=xxx SUPABASE_SERVICE_ROLE_KEY=xxx GEMINI_API_KEY=xxx npx ts-node index.ts
```
Expected: "Successfully inserted N articles"

**Step 4: Commit**
```bash
git add worker/
git commit -m "feat: add RSS fetch + Gemini summarize worker"
```

---

### Task 2.2 — Create GitHub Actions workflow

**File:** `.github/workflows/fetch-news.yml`
```yaml
name: Fetch News

on:
  schedule:
    - cron: '0 8 * * *'   # 8 AM UTC daily
    - cron: '0 20 * * *'  # 8 PM UTC daily
  workflow_dispatch:         # Allow manual trigger from GitHub UI

jobs:
  fetch:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: worker

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: worker/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Run worker
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
        run: npx ts-node index.ts
```

**Step 1: Write the workflow file**

**Step 2: Add GitHub Secrets**
- Go to your GitHub repo → Settings → Secrets → Actions
- Add: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `GEMINI_API_KEY`

> Get `SUPABASE_SERVICE_ROLE_KEY` from Supabase Dashboard → Settings → API → service_role key

**Step 3: Commit and push**
```bash
git add .github/
git commit -m "feat: add GitHub Actions cron workflow for news fetching"
git push
```

**Step 4: Verify**
- Go to GitHub repo → Actions tab → manually trigger "Fetch News"
- Check run logs for "Successfully inserted N articles"
- Check Supabase Table Editor → articles table for rows

---

### Task 2.3 — Create Supabase Edge Function (manual refresh)

**File:** `supabase/functions/refresh/index.ts`
```typescript
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

// This Edge Function triggers the same worker logic on-demand
// Called when user taps "Refresh" in the app

serve(async (req) => {
  // Simple auth check — app sends a secret header
  const authHeader = req.headers.get('x-refresh-token')
  if (authHeader !== Deno.env.get('REFRESH_SECRET')) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 })
  }

  try {
    // Trigger GitHub Actions workflow_dispatch via API
    const response = await fetch(
      `https://api.github.com/repos/${Deno.env.get('GITHUB_REPO')}/actions/workflows/fetch-news.yml/dispatches`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${Deno.env.get('GITHUB_TOKEN')}`,
          'Accept': 'application/vnd.github+json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ ref: 'main' }),
      }
    )

    if (!response.ok) {
      throw new Error(`GitHub API error: ${response.status}`)
    }

    return new Response(
      JSON.stringify({ success: true, message: 'Refresh triggered' }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
```

**Step 1: Install Supabase CLI**
```bash
npm install -g supabase
supabase init
```

**Step 2: Write the Edge Function file above**

**Step 3: Deploy**
```bash
supabase functions deploy refresh --project-ref your-project-ref
```

**Step 4: Set Edge Function secrets in Supabase Dashboard**
- `REFRESH_SECRET` = any random string (e.g. `openssl rand -hex 32`)
- `GITHUB_TOKEN` = GitHub Personal Access Token with `workflow` scope
- `GITHUB_REPO` = `yourusername/techpulse`

**Step 5: Commit**
```bash
git add supabase/
git commit -m "feat: add Supabase Edge Function for manual refresh trigger"
```

---

## Phase 3: Articles API in App

### Task 3.1 — Create articles API hooks

**File:** `src/api/articles.ts`
```typescript
import { useInfiniteQuery, useQuery } from '@tanstack/react-query'
import { supabase } from './supabase'
import type { Article, ArticleCategory } from '../types'

const PAGE_SIZE = 20

export function useArticles(category: ArticleCategory = 'all') {
  return useInfiniteQuery({
    queryKey: ['articles', category],
    queryFn: async ({ pageParam = 0 }) => {
      let query = supabase
        .from('articles')
        .select('*')
        .order('impact_score', { ascending: false })
        .order('published_at', { ascending: false })
        .range(pageParam * PAGE_SIZE, (pageParam + 1) * PAGE_SIZE - 1)

      if (category !== 'all') {
        query = query.contains('tags', [category])
      }

      const { data, error } = await query
      if (error) throw error
      return data as Article[]
    },
    getNextPageParam: (lastPage, allPages) =>
      lastPage.length === PAGE_SIZE ? allPages.length : undefined,
    initialPageParam: 0,
  })
}

export function useArticle(id: string) {
  return useQuery({
    queryKey: ['article', id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('articles')
        .select('*')
        .eq('id', id)
        .single()
      if (error) throw error
      return data as Article
    },
  })
}

export async function triggerRefresh(): Promise<void> {
  const response = await fetch(
    `${process.env.SUPABASE_URL}/functions/v1/refresh`,
    {
      method: 'POST',
      headers: {
        'x-refresh-token': process.env.REFRESH_SECRET!,
        'Content-Type': 'application/json',
      },
    }
  )
  if (!response.ok) throw new Error('Refresh failed')
}
```

**Step 1: Write the file above**

**Step 2: Add `REFRESH_SECRET` to `.env`**
```
REFRESH_SECRET=your_refresh_secret_here
```

**Step 3: Commit**
```bash
git add src/api/articles.ts
git commit -m "feat: add articles API hooks with infinite scroll"
```

---

## Phase 4: Feed Screen

### Task 4.1 — ArticleCard component

**File:** `src/components/ArticleCard.tsx`
```typescript
import React from 'react'
import { View, Text, TouchableOpacity, StyleSheet, Image } from 'react-native'
import type { Article } from '../types'

interface Props {
  article: Article
  onPress: () => void
}

function ImpactBadge({ score }: { score: number }) {
  const color = score >= 80 ? '#ef4444' : score >= 60 ? '#f59e0b' : '#3b82f6'
  const label = score >= 80 ? 'Breaking' : score >= 60 ? 'Trending' : 'New'
  return (
    <View style={[styles.badge, { backgroundColor: color + '20', borderColor: color + '40' }]}>
      <Text style={[styles.badgeText, { color }]}>{label}</Text>
    </View>
  )
}

export default function ArticleCard({ article, onPress }: Props) {
  const timeAgo = getTimeAgo(article.published_at)
  const readingMin = Math.ceil(article.reading_time_seconds / 60)

  return (
    <TouchableOpacity style={styles.card} onPress={onPress} activeOpacity={0.7}>
      <View style={styles.header}>
        <View style={styles.sourceMeta}>
          <Text style={styles.sourceName}>{article.source_name}</Text>
          <Text style={styles.dot}>·</Text>
          <Text style={styles.time}>{timeAgo}</Text>
          <Text style={styles.dot}>·</Text>
          <Text style={styles.time}>{readingMin}m read</Text>
        </View>
        <ImpactBadge score={article.impact_score} />
      </View>

      <Text style={styles.title} numberOfLines={3}>{article.title}</Text>

      {article.summary_tldr ? (
        <Text style={styles.summary} numberOfLines={2}>{article.summary_tldr}</Text>
      ) : article.excerpt ? (
        <Text style={styles.summary} numberOfLines={2}>{article.excerpt}</Text>
      ) : null}

      {article.summary_bullets && article.summary_bullets.length > 0 && (
        <View style={styles.bullets}>
          {article.summary_bullets.slice(0, 2).map((bullet, i) => (
            <Text key={i} style={styles.bullet} numberOfLines={1}>• {bullet}</Text>
          ))}
        </View>
      )}

      {article.why_it_matters ? (
        <View style={styles.whyBox}>
          <Text style={styles.whyLabel}>Why it matters</Text>
          <Text style={styles.whyText} numberOfLines={2}>{article.why_it_matters}</Text>
        </View>
      ) : null}

      {article.tags.length > 0 && (
        <View style={styles.tags}>
          {article.tags.slice(0, 3).map((tag) => (
            <View key={tag} style={styles.tag}>
              <Text style={styles.tagText}>{tag}</Text>
            </View>
          ))}
        </View>
      )}
    </TouchableOpacity>
  )
}

function getTimeAgo(dateStr: string): string {
  const diff = Date.now() - new Date(dateStr).getTime()
  const hours = Math.floor(diff / 3600000)
  if (hours < 1) return `${Math.floor(diff / 60000)}m ago`
  if (hours < 24) return `${hours}h ago`
  return `${Math.floor(hours / 24)}d ago`
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#1e293b',
    borderRadius: 12,
    padding: 16,
    marginHorizontal: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#334155',
  },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 },
  sourceMeta: { flexDirection: 'row', alignItems: 'center', flex: 1, flexWrap: 'wrap' },
  sourceName: { color: '#3b82f6', fontSize: 12, fontWeight: '600' },
  dot: { color: '#475569', fontSize: 12, marginHorizontal: 4 },
  time: { color: '#64748b', fontSize: 12 },
  badge: { borderRadius: 4, paddingHorizontal: 6, paddingVertical: 2, borderWidth: 1 },
  badgeText: { fontSize: 10, fontWeight: '700' },
  title: { color: '#f1f5f9', fontSize: 16, fontWeight: '700', lineHeight: 22, marginBottom: 8 },
  summary: { color: '#94a3b8', fontSize: 14, lineHeight: 20, marginBottom: 8 },
  bullets: { marginBottom: 8 },
  bullet: { color: '#cbd5e1', fontSize: 13, lineHeight: 18, marginBottom: 2 },
  whyBox: { backgroundColor: '#0f172a', borderRadius: 8, padding: 10, marginBottom: 8, borderLeftWidth: 3, borderLeftColor: '#3b82f6' },
  whyLabel: { color: '#3b82f6', fontSize: 11, fontWeight: '700', marginBottom: 2 },
  whyText: { color: '#94a3b8', fontSize: 13, lineHeight: 18 },
  tags: { flexDirection: 'row', flexWrap: 'wrap', gap: 6 },
  tag: { backgroundColor: '#0f172a', borderRadius: 4, paddingHorizontal: 8, paddingVertical: 3, borderWidth: 1, borderColor: '#334155' },
  tagText: { color: '#64748b', fontSize: 11 },
})
```

**Step 1: Write the file above**

**Step 2: Commit**
```bash
git add src/components/ArticleCard.tsx
git commit -m "feat: add ArticleCard component with summary display"
```

---

### Task 4.2 — SkeletonCard component

**File:** `src/components/SkeletonCard.tsx`
```typescript
import React, { useEffect, useRef } from 'react'
import { View, Animated, StyleSheet } from 'react-native'

export default function SkeletonCard() {
  const opacity = useRef(new Animated.Value(0.3)).current

  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(opacity, { toValue: 0.7, duration: 800, useNativeDriver: true }),
        Animated.timing(opacity, { toValue: 0.3, duration: 800, useNativeDriver: true }),
      ])
    ).start()
  }, [])

  return (
    <Animated.View style={[styles.card, { opacity }]}>
      <View style={styles.row}>
        <View style={styles.shortLine} />
        <View style={styles.badge} />
      </View>
      <View style={styles.titleLine} />
      <View style={styles.titleLineShort} />
      <View style={styles.bodyLine} />
      <View style={styles.bodyLineShort} />
    </Animated.View>
  )
}

const styles = StyleSheet.create({
  card: { backgroundColor: '#1e293b', borderRadius: 12, padding: 16, marginHorizontal: 16, marginBottom: 12 },
  row: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 12 },
  shortLine: { height: 10, width: 100, backgroundColor: '#334155', borderRadius: 4 },
  badge: { height: 16, width: 50, backgroundColor: '#334155', borderRadius: 4 },
  titleLine: { height: 14, backgroundColor: '#334155', borderRadius: 4, marginBottom: 6 },
  titleLineShort: { height: 14, width: '60%', backgroundColor: '#334155', borderRadius: 4, marginBottom: 12 },
  bodyLine: { height: 10, backgroundColor: '#1e3a5f', borderRadius: 4, marginBottom: 6 },
  bodyLineShort: { height: 10, width: '80%', backgroundColor: '#1e3a5f', borderRadius: 4 },
})
```

**Step 1: Write the file above**

**Step 2: Commit**
```bash
git add src/components/SkeletonCard.tsx
git commit -m "feat: add skeleton loading card"
```

---

### Task 4.3 — CategoryTabs component

**File:** `src/components/CategoryTabs.tsx`
```typescript
import React from 'react'
import { ScrollView, TouchableOpacity, Text, StyleSheet, View } from 'react-native'
import type { ArticleCategory } from '../types'

const CATEGORIES: { key: ArticleCategory; label: string }[] = [
  { key: 'all', label: 'All' },
  { key: 'ai_labs', label: '🤖 AI Labs' },
  { key: 'tools', label: '🛠 Tools' },
  { key: 'papers', label: '📄 Papers' },
  { key: 'dev', label: '💻 Dev' },
  { key: 'news', label: '📰 News' },
  { key: 'funding', label: '💰 Funding' },
]

interface Props {
  selected: ArticleCategory
  onSelect: (category: ArticleCategory) => void
}

export default function CategoryTabs({ selected, onSelect }: Props) {
  return (
    <ScrollView
      horizontal
      showsHorizontalScrollIndicator={false}
      style={styles.container}
      contentContainerStyle={styles.content}
    >
      {CATEGORIES.map(({ key, label }) => (
        <TouchableOpacity
          key={key}
          style={[styles.tab, selected === key && styles.activeTab]}
          onPress={() => onSelect(key)}
        >
          <Text style={[styles.tabText, selected === key && styles.activeTabText]}>
            {label}
          </Text>
        </TouchableOpacity>
      ))}
    </ScrollView>
  )
}

const styles = StyleSheet.create({
  container: { backgroundColor: '#0f172a', borderBottomWidth: 1, borderBottomColor: '#1e293b' },
  content: { paddingHorizontal: 12, paddingVertical: 10, gap: 8 },
  tab: { paddingHorizontal: 14, paddingVertical: 6, borderRadius: 20, backgroundColor: '#1e293b', borderWidth: 1, borderColor: '#334155' },
  activeTab: { backgroundColor: '#3b82f6', borderColor: '#3b82f6' },
  tabText: { color: '#64748b', fontSize: 13, fontWeight: '600' },
  activeTabText: { color: '#fff' },
})
```

**Step 1: Write the file above**

**Step 2: Commit**
```bash
git add src/components/CategoryTabs.tsx
git commit -m "feat: add category filter tabs"
```

---

### Task 4.4 — FeedScreen (main screen)

**File:** `src/screens/FeedScreen.tsx`
```typescript
import React, { useState, useCallback } from 'react'
import {
  View, Text, StyleSheet, TouchableOpacity,
  RefreshControl, ActivityIndicator, Alert,
} from 'react-native'
import { FlashList } from '@shopify/flash-list'
import { useSafeAreaInsets } from 'react-native-safe-area-context'
import { useNavigation } from '@react-navigation/native'
import ArticleCard from '../components/ArticleCard'
import SkeletonCard from '../components/SkeletonCard'
import CategoryTabs from '../components/CategoryTabs'
import { useArticles, triggerRefresh } from '../api/articles'
import { queryClient } from '../lib/queryClient'
import type { ArticleCategory, Article } from '../types'
import type { FeedNavigationProp } from '../navigation/types'

export default function FeedScreen() {
  const insets = useSafeAreaInsets()
  const navigation = useNavigation<FeedNavigationProp>()
  const [category, setCategory] = useState<ArticleCategory>('all')
  const [isRefreshing, setIsRefreshing] = useState(false)

  const { data, fetchNextPage, hasNextPage, isFetchingNextPage, isLoading } =
    useArticles(category)

  const articles = data?.pages.flat() ?? []

  const handleRefresh = useCallback(async () => {
    setIsRefreshing(true)
    try {
      await triggerRefresh()
      // Wait 30 seconds for worker to complete, then refetch
      await new Promise((r) => setTimeout(r, 30000))
      await queryClient.invalidateQueries({ queryKey: ['articles'] })
    } catch {
      Alert.alert('Refresh failed', 'Could not fetch latest news. Try again.')
    } finally {
      setIsRefreshing(false)
    }
  }, [])

  const handleArticlePress = useCallback((article: Article) => {
    navigation.navigate('Article', {
      articleId: article.id,
      url: article.url,
      title: article.title,
    })
  }, [navigation])

  const renderItem = useCallback(({ item }: { item: Article }) => (
    <ArticleCard article={item} onPress={() => handleArticlePress(item)} />
  ), [handleArticlePress])

  const renderFooter = useCallback(() => {
    if (!isFetchingNextPage) return null
    return <ActivityIndicator color="#3b82f6" style={{ padding: 20 }} />
  }, [isFetchingNextPage])

  if (isLoading) {
    return (
      <View style={[styles.container, { paddingTop: insets.top }]}>
        <Header onRefresh={handleRefresh} isRefreshing={isRefreshing} />
        <CategoryTabs selected={category} onSelect={setCategory} />
        {[...Array(5)].map((_, i) => <SkeletonCard key={i} />)}
      </View>
    )
  }

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <Header onRefresh={handleRefresh} isRefreshing={isRefreshing} />
      <CategoryTabs selected={category} onSelect={setCategory} />
      <FlashList
        data={articles}
        renderItem={renderItem}
        estimatedItemSize={280}
        keyExtractor={(item) => item.id}
        onEndReached={() => hasNextPage && fetchNextPage()}
        onEndReachedThreshold={0.5}
        ListFooterComponent={renderFooter}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Text style={styles.emptyText}>No articles yet.</Text>
            <Text style={styles.emptySubText}>Pull down to refresh.</Text>
          </View>
        }
        refreshControl={
          <RefreshControl
            refreshing={isRefreshing}
            onRefresh={async () => {
              await queryClient.invalidateQueries({ queryKey: ['articles'] })
            }}
            tintColor="#3b82f6"
          />
        }
        contentContainerStyle={{ paddingTop: 12, paddingBottom: insets.bottom + 20 }}
      />
    </View>
  )
}

function Header({ onRefresh, isRefreshing }: { onRefresh: () => void; isRefreshing: boolean }) {
  return (
    <View style={styles.header}>
      <View>
        <Text style={styles.logo}>TechPulse</Text>
        <Text style={styles.logoSub}>Stay ahead of the curve</Text>
      </View>
      <TouchableOpacity
        style={[styles.refreshBtn, isRefreshing && styles.refreshBtnDisabled]}
        onPress={onRefresh}
        disabled={isRefreshing}
      >
        {isRefreshing ? (
          <ActivityIndicator color="#3b82f6" size="small" />
        ) : (
          <Text style={styles.refreshBtnText}>↻ Refresh</Text>
        )}
      </TouchableOpacity>
    </View>
  )
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0f172a' },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 16, paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: '#1e293b' },
  logo: { color: '#f1f5f9', fontSize: 22, fontWeight: '800' },
  logoSub: { color: '#475569', fontSize: 11, marginTop: 1 },
  refreshBtn: { backgroundColor: '#1e293b', borderWidth: 1, borderColor: '#3b82f6', borderRadius: 8, paddingHorizontal: 12, paddingVertical: 6 },
  refreshBtnDisabled: { opacity: 0.5 },
  refreshBtnText: { color: '#3b82f6', fontSize: 13, fontWeight: '600' },
  empty: { flex: 1, alignItems: 'center', justifyContent: 'center', paddingTop: 80 },
  emptyText: { color: '#475569', fontSize: 18, fontWeight: '600' },
  emptySubText: { color: '#334155', fontSize: 14, marginTop: 6 },
})
```

**Step 1: Write the file above**

**Step 2: Run the app and verify feed loads**
```bash
npx react-native run-ios
```
Expected: Feed screen shows article cards with summaries, category tabs work, refresh button triggers worker.

**Step 3: Commit**
```bash
git add src/screens/FeedScreen.tsx
git commit -m "feat: build main feed screen with FlashList and category filters"
```

---

## Phase 5: Article Detail Screen

### Task 5.1 — ArticleScreen with in-app browser

**File:** `src/screens/ArticleScreen.tsx`
```typescript
import React, { useState } from 'react'
import { View, Text, TouchableOpacity, StyleSheet, ActivityIndicator } from 'react-native'
import { WebView } from 'react-native-webview'
import { useSafeAreaInsets } from 'react-native-safe-area-context'
import { useRoute, useNavigation } from '@react-navigation/native'
import type { ArticleRouteProp } from '../navigation/types'

export default function ArticleScreen() {
  const insets = useSafeAreaInsets()
  const route = useRoute<ArticleRouteProp>()
  const navigation = useNavigation()
  const { url, title } = route.params
  const [loading, setLoading] = useState(true)

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Text style={styles.backText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title} numberOfLines={1}>{title}</Text>
      </View>
      {loading && (
        <ActivityIndicator
          color="#3b82f6"
          style={styles.loader}
          size="large"
        />
      )}
      <WebView
        source={{ uri: url }}
        onLoadEnd={() => setLoading(false)}
        style={styles.webview}
        allowsInlineMediaPlayback
        mediaPlaybackRequiresUserAction
      />
    </View>
  )
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0f172a' },
  header: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16, paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: '#1e293b' },
  backBtn: { marginRight: 12 },
  backText: { color: '#3b82f6', fontSize: 16, fontWeight: '600' },
  title: { flex: 1, color: '#f1f5f9', fontSize: 14, fontWeight: '600' },
  loader: { position: 'absolute', top: '50%', alignSelf: 'center', zIndex: 10 },
  webview: { flex: 1, backgroundColor: '#0f172a' },
})
```

**Step 1: Write the file above**

**Step 2: Verify tapping an article opens the in-app browser**

**Step 3: Commit**
```bash
git add src/screens/ArticleScreen.tsx
git commit -m "feat: add article detail screen with in-app browser"
```

---

## Phase 6: Bookmarks

### Task 6.1 — Bookmarks store (MMKV)

**File:** `src/store/useBookmarksStore.ts`
```typescript
import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import { MMKV } from 'react-native-mmkv'
import type { Article } from '../types'

const storage = new MMKV({ id: 'bookmarks' })

const mmkvStorage = {
  getItem: (key: string) => storage.getString(key) ?? null,
  setItem: (key: string, value: string) => storage.set(key, value),
  removeItem: (key: string) => storage.delete(key),
}

interface BookmarksState {
  bookmarks: Article[]
  addBookmark: (article: Article) => void
  removeBookmark: (id: string) => void
  isBookmarked: (id: string) => boolean
}

export const useBookmarksStore = create<BookmarksState>()(
  persist(
    (set, get) => ({
      bookmarks: [],
      addBookmark: (article) =>
        set((state) => ({ bookmarks: [article, ...state.bookmarks] })),
      removeBookmark: (id) =>
        set((state) => ({ bookmarks: state.bookmarks.filter((b) => b.id !== id) })),
      isBookmarked: (id) => get().bookmarks.some((b) => b.id === id),
    }),
    {
      name: 'bookmarks-storage',
      storage: createJSONStorage(() => mmkvStorage),
    }
  )
)
```

**File:** `src/screens/BookmarksScreen.tsx`
```typescript
import React from 'react'
import { View, Text, StyleSheet } from 'react-native'
import { FlashList } from '@shopify/flash-list'
import { useSafeAreaInsets } from 'react-native-safe-area-context'
import { useNavigation } from '@react-navigation/native'
import ArticleCard from '../components/ArticleCard'
import { useBookmarksStore } from '../store/useBookmarksStore'
import type { Article } from '../types'
import type { FeedNavigationProp } from '../navigation/types'

export default function BookmarksScreen() {
  const insets = useSafeAreaInsets()
  const navigation = useNavigation<FeedNavigationProp>()
  const bookmarks = useBookmarksStore((s) => s.bookmarks)

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Text style={styles.title}>Saved Articles</Text>
        <Text style={styles.count}>{bookmarks.length}</Text>
      </View>
      <FlashList
        data={bookmarks}
        renderItem={({ item }: { item: Article }) => (
          <ArticleCard
            article={item}
            onPress={() => navigation.navigate('Article', { articleId: item.id, url: item.url, title: item.title })}
          />
        )}
        estimatedItemSize={280}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{ paddingTop: 12, paddingBottom: insets.bottom + 20 }}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Text style={styles.emptyText}>No saved articles yet.</Text>
            <Text style={styles.emptySubText}>Tap the bookmark icon on any article.</Text>
          </View>
        }
      />
    </View>
  )
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0f172a' },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 16, paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: '#1e293b' },
  title: { color: '#f1f5f9', fontSize: 22, fontWeight: '800' },
  count: { color: '#475569', fontSize: 16 },
  empty: { flex: 1, alignItems: 'center', justifyContent: 'center', paddingTop: 80 },
  emptyText: { color: '#475569', fontSize: 18, fontWeight: '600' },
  emptySubText: { color: '#334155', fontSize: 14, marginTop: 6 },
})
```

**Step 1: Write both files above**

**Step 2: Add bookmark button to ArticleCard**

Add to `src/components/ArticleCard.tsx` — import `useBookmarksStore` and add a bookmark toggle button in the card footer.

**Step 3: Commit**
```bash
git add src/store/useBookmarksStore.ts src/screens/BookmarksScreen.tsx src/components/ArticleCard.tsx
git commit -m "feat: add bookmarks with MMKV persistence"
```

---

## Phase 7: Settings Screen

### Task 7.1 — Preferences store + Settings screen

**File:** `src/store/usePreferencesStore.ts`
```typescript
import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import { MMKV } from 'react-native-mmkv'
import type { UserPreferences, ArticleCategory, Theme } from '../types'

const storage = new MMKV({ id: 'preferences' })
const mmkvStorage = {
  getItem: (key: string) => storage.getString(key) ?? null,
  setItem: (key: string, value: string) => storage.set(key, value),
  removeItem: (key: string) => storage.delete(key),
}

const defaultPreferences: UserPreferences = {
  theme: 'dark',
  selectedCategories: ['all'],
  notificationsEnabled: true,
  breakingNewsOnly: false,
}

interface PreferencesState extends UserPreferences {
  setTheme: (theme: Theme) => void
  toggleCategory: (category: ArticleCategory) => void
  setNotificationsEnabled: (enabled: boolean) => void
  setBreakingNewsOnly: (enabled: boolean) => void
}

export const usePreferencesStore = create<PreferencesState>()(
  persist(
    (set) => ({
      ...defaultPreferences,
      setTheme: (theme) => set({ theme }),
      toggleCategory: (category) =>
        set((state) => ({
          selectedCategories: state.selectedCategories.includes(category)
            ? state.selectedCategories.filter((c) => c !== category)
            : [...state.selectedCategories, category],
        })),
      setNotificationsEnabled: (notificationsEnabled) => set({ notificationsEnabled }),
      setBreakingNewsOnly: (breakingNewsOnly) => set({ breakingNewsOnly }),
    }),
    {
      name: 'preferences-storage',
      storage: createJSONStorage(() => mmkvStorage),
    }
  )
)
```

**Step 1: Write the file above**

**Step 2: Build SettingsScreen with theme toggle and notification settings**

**Step 3: Commit**
```bash
git add src/store/usePreferencesStore.ts src/screens/SettingsScreen.tsx
git commit -m "feat: add settings and preferences with MMKV persistence"
```

---

## Phase 8: Push Notifications

### Task 8.1 — Firebase setup (manual steps)

**Step 1:** Create Firebase project at https://console.firebase.google.com
**Step 2:** Add Android app (package name from `android/app/build.gradle` — `applicationId`)
**Step 3:** Download `google-services.json` → place in `android/app/`
**Step 4:** Add iOS app (bundle ID from Xcode)
**Step 5:** Download `GoogleService-Info.plist` → place in `ios/techpulse/`
**Step 6:** Enable Push Notifications in Xcode → Signing & Capabilities → + Push Notifications
**Step 7:** Enable Background Modes → Remote notifications in Xcode

---

### Task 8.2 — Firebase messaging integration

**File:** `src/notifications/firebase.ts`
```typescript
import messaging from '@react-native-firebase/messaging'
import notifee, { AndroidImportance } from '@notifee/react-native'

export async function requestNotificationPermission(): Promise<boolean> {
  const authStatus = await messaging().requestPermission()
  return (
    authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
    authStatus === messaging.AuthorizationStatus.PROVISIONAL
  )
}

export async function getFCMToken(): Promise<string | null> {
  try {
    return await messaging().getToken()
  } catch {
    return null
  }
}

export async function setupNotificationChannel() {
  await notifee.createChannel({
    id: 'breaking-news',
    name: 'Breaking News',
    importance: AndroidImportance.HIGH,
    sound: 'default',
  })
}

// Register background handler (call outside component)
messaging().setBackgroundMessageHandler(async (remoteMessage) => {
  const { notification } = remoteMessage
  if (!notification) return
  await notifee.displayNotification({
    title: notification.title || 'TechPulse',
    body: notification.body || '',
    android: { channelId: 'breaking-news', pressAction: { id: 'default' } },
  })
})
```

**File:** Update `App.tsx` to call `setupNotificationChannel()` on mount:
```typescript
import { useEffect } from 'react'
import { setupNotificationChannel, requestNotificationPermission } from './src/notifications/firebase'

// Inside App component:
useEffect(() => {
  setupNotificationChannel()
  requestNotificationPermission()
}, [])
```

**Step 1: Write both files above**

**Step 2: Commit**
```bash
git add src/notifications/ App.tsx
git commit -m "feat: setup Firebase push notifications with Notifee"
```

---

## Phase 9: Final Polish & Launch

### Task 9.1 — App icons and splash screen

**Step 1:** Create 1024×1024 app icon (TechPulse logo — pulsing dot + wordmark)
**Step 2:** Use `react-native-bootsplash` for splash screen:
```bash
npm install react-native-bootsplash
cd ios && pod install && cd ..
npx react-native generate-bootsplash assets/logo.png --background-color=#0f172a --logo-width=200
```

**Step 3: Commit**
```bash
git add .
git commit -m "chore: add app icon and splash screen"
```

---

### Task 9.2 — App Store / Play Store preparation

**iOS:**
1. Open Xcode → set Bundle ID, version, build number
2. Archive → distribute via TestFlight first
3. App Store Connect → create listing

**Android:**
1. Generate keystore: `keytool -genkeypair -v -storetype PKCS12 -keystore techpulse.keystore -alias techpulse -keyalg RSA -keysize 2048 -validity 10000`
2. Add to `android/gradle.properties` (never commit the keystore!)
3. Build release: `cd android && ./gradlew bundleRelease`
4. Upload to Play Console

---

## Verification Checklist

- [ ] Feed loads articles from Supabase
- [ ] Articles show AI summaries ("Why it matters", bullets, TL;DR)
- [ ] Category tabs filter correctly
- [ ] Refresh button triggers GitHub Actions worker + refetches
- [ ] Pull-to-refresh re-reads latest from DB
- [ ] Tapping article opens in-app browser
- [ ] Bookmarks save/load correctly across app restarts (MMKV)
- [ ] Push notifications received on iOS and Android
- [ ] GitHub Actions runs twice daily and inserts new articles
- [ ] Supabase DB has no pause issues (keep-alive working)
- [ ] App works offline (cached articles visible)

---

## Cost Summary

| Service | Cost |
|---------|------|
| Supabase (DB) | $0 |
| GitHub Actions (cron) | $0 |
| Gemini 2.5 Flash | $0 |
| Firebase FCM | $0 |
| Supabase Edge Function (manual refresh trigger) | $0 |
| **Total** | **$0/month** |
