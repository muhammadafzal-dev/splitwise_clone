# InterviewAI — Design Document
> Status: APPROVED — ready for implementation
> Created: 2026-03-30

---

## Overview

AI-powered mock interview app for Android (React Native CLI). Users paste a job description, select a mode and difficulty, then get a live interview session with behavioral and/or coding questions. Gemini scores every answer with detailed feedback.

**Differentiator:** Job-description-specific questions + LeetCode-style coding round + voice/text flexible input + persistent progress tracking — all free.

---

## Tech Stack

| Layer | Library |
|-------|---------|
| Framework | React Native CLI 0.76+ |
| Language | TypeScript |
| Navigation | React Navigation v7 (Stack + Bottom Tabs) |
| Server state | TanStack Query v5 |
| Client state | Zustand v5 |
| Persistence | react-native-mmkv |
| Auth + DB | Supabase (Google OAuth) |
| AI | Gemini 2.5 Flash |
| Voice input | @react-native-voice/voice |
| Code editor | react-native-code-editor |
| Icons | react-native-vector-icons (Ionicons) |
| Animations | react-native-reanimated v4 |

---

## User Flow

```
Launch
  └── SplashScreen
        ├── Not logged in → LoginScreen (Google OAuth)
        └── Logged in
              ├── First launch → OnboardingScreen (3 steps)
              └── Returning → HomeScreen (dashboard)

HomeScreen
  ├── Quick Start → SetupScreen
  ├── History tab → HistoryScreen
  └── Profile tab → ProfileScreen

SetupScreen
  └── (paste JD + pick mode + pick difficulty) → InterviewScreen

InterviewScreen
  ├── Behavioral mode: AI question card + voice/text input (switchable)
  ├── Coding mode: question panel + code editor + run tests
  └── Mixed mode: alternates behavioral + coding questions
        └── (session complete) → ResultsScreen

ResultsScreen
  └── Overall score + per-question feedback + save to history
```

---

## Screens

### Auth Stack
- **SplashScreen** — animated logo, checks auth state
- **LoginScreen** — Google OAuth button, minimal UI

### Onboarding (one-time, 3 steps)
- Step 1: Select role — Fresh Grad / FAANG Prep / Career Switcher / ESL Practice
- Step 2: Years of experience (0-1 / 1-3 / 3-5 / 5+)
- Step 3: Target companies (optional multi-select chips: Google, Meta, Amazon, Startup, etc.)

### Bottom Tab Navigator
- **HomeScreen** — recent sessions, streak counter, quick start CTA
- **HistoryScreen** — list of past sessions with scores + date
- **ProfileScreen** — user info, settings, total sessions, avg score

### Session Stack
- **SetupScreen** — job description textarea, mode picker (Behavioral/Coding/Mixed), difficulty selector (Easy/Medium/Expert)
- **InterviewScreen** — live session (see details below)
- **ResultsScreen** — full breakdown of scores and feedback

### InterviewScreen Details
- Progress bar: Question X of Y
- Timer per question (optional, can be disabled)
- Skip button
- **Behavioral mode:**
  - AI question card (large, readable)
  - Floating mic button → voice recording with live transcript
  - Toggle to switch to text input mid-session
  - Submit answer button
- **Coding mode:**
  - Split screen: question + constraints top half
  - Code editor bottom half
  - Language selector (JavaScript / Python / Java / C++)
  - Run Tests button → shows pass/fail per test case
  - Hint button (shows stored hint)

---

## Question Bank Structure

Stored as static TypeScript files in `src/data/questions/` — zero Supabase storage.

```typescript
export type Question = {
  id: string
  category: 'behavioral' | 'system-design' | 'coding'
  difficulty: 'easy' | 'medium' | 'expert'
  topic: string
  question: string
  hints?: string[]
  sampleAnswer?: string       // behavioral reference answer
  starterCode?: string        // coding: boilerplate
  testCases?: TestCase[]      // coding: static test cases
  timeComplexity?: string     // coding: expected solution complexity
}

export type TestCase = {
  input: string
  expectedOutput: string
  isHidden: boolean
}
```

**Topics covered:**

| Category | Topics |
|----------|--------|
| Behavioral | Leadership, Conflict, Teamwork, Failure, Achievement, Communication, Adaptability |
| System Design | Scalability, Databases, Caching, APIs, Microservices, Rate Limiting |
| Coding | Arrays, Strings, Trees, Graphs, Dynamic Programming, Sorting, Hash Maps |

**Session question selection:**
1. Gemini receives: job description + difficulty + mode + user profile
2. Selects 3-4 best-matching questions from static bank
3. Generates 2-3 fresh JD-specific questions
4. Total: 6-7 questions per session

---

## AI Scoring

### Behavioral Scoring (Gemini prompt → JSON response)
```
Evaluate on:
- Relevance (0-10): Does the answer address the question?
- STAR format (0-10): Situation / Task / Action / Result structure
- Specificity (0-10): Concrete examples vs vague statements
- Clarity (0-10): Communication quality
- Overall score: average
- Strengths: string[]
- Improvements: string[] (2-3 actionable tips)
- Verdict: "Strong" | "Good" | "Needs Work"
```

### Coding Scoring (Gemini prompt → JSON response)
```
Evaluate on:
- Correctness (0-10): Solves the problem
- Time complexity (0-10): Optimal or acceptable
- Space complexity (0-10)
- Code quality (0-10): Naming, readability, structure
- Edge cases (0-10): Handles nulls, empty inputs, overflow
- Overall score: average
- Test results: pass/fail per test case
- Improvements: string[]
```

### Results Screen
- Overall session score (0-100)
- Per-question score card with expandable AI feedback
- Strengths summary
- Top 3 areas to improve
- "Practice weak areas" shortcut
- Session saved to Supabase history

---

## Database Schema (Supabase)

```sql
-- profiles
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  role_type TEXT,                    -- 'fresh_grad' | 'faang' | 'switcher' | 'esl'
  experience_years TEXT,             -- '0-1' | '1-3' | '3-5' | '5+'
  target_companies TEXT[],
  onboarding_complete BOOLEAN DEFAULT FALSE,
  total_sessions INTEGER DEFAULT 0,
  avg_score NUMERIC(5,2) DEFAULT 0,
  streak_days INTEGER DEFAULT 0,
  last_session_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- sessions
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  job_description TEXT,
  company_name TEXT,
  mode TEXT,                         -- 'behavioral' | 'coding' | 'mixed'
  difficulty TEXT,                   -- 'easy' | 'medium' | 'expert'
  overall_score NUMERIC(5,2),
  duration_seconds INTEGER,
  question_count INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- session_answers
CREATE TABLE session_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  question_id TEXT,
  question_text TEXT,
  answer_text TEXT,
  answer_audio_url TEXT,
  score NUMERIC(5,2),
  ai_feedback JSONB,                 -- full scoring breakdown
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS: users can only read/write their own data
```

---

## File Structure

```
src/
├── screens/
│   ├── SplashScreen.tsx
│   ├── LoginScreen.tsx
│   ├── OnboardingScreen.tsx
│   ├── HomeScreen.tsx
│   ├── SetupScreen.tsx
│   ├── InterviewScreen.tsx
│   ├── ResultsScreen.tsx
│   ├── HistoryScreen.tsx
│   └── ProfileScreen.tsx
├── components/
│   ├── QuestionCard.tsx
│   ├── VoiceRecorder.tsx
│   ├── CodeEditor.tsx
│   ├── TestCaseResult.tsx
│   ├── ScoreCard.tsx
│   ├── ProgressBar.tsx
│   └── DifficultyBadge.tsx
├── data/
│   └── questions/
│       ├── behavioral.ts
│       ├── coding.ts
│       ├── systemDesign.ts
│       └── index.ts
├── lib/
│   ├── gemini.ts          -- AI question selection + scoring
│   ├── supabase.ts
│   └── voice.ts           -- voice recording helpers
├── hooks/
│   ├── useSession.ts
│   ├── useVoice.ts
│   └── useCodeRunner.ts
├── store/
│   ├── sessionStore.ts    -- active interview state
│   └── authStore.ts
├── navigation/
│   ├── AppNavigator.tsx
│   ├── AuthNavigator.tsx
│   └── TabNavigator.tsx
└── types/
    └── index.ts
```

---

## Implementation Phases

### Phase 1 — Foundation
- React Native CLI project setup
- Supabase auth (Google OAuth)
- Navigation structure
- Onboarding flow
- Home + Profile screens

### Phase 2 — Question Bank
- Static question data (behavioral + coding)
- SetupScreen (JD input + mode + difficulty)
- Gemini integration for question selection

### Phase 3 — Interview Session
- BehavioralMode (voice + text input)
- CodingMode (code editor + test cases)
- Session state management (Zustand)
- Timer + progress bar

### Phase 4 — AI Scoring
- Gemini scoring prompts
- ResultsScreen with full breakdown
- Save session to Supabase

### Phase 5 — Polish
- HistoryScreen
- Streak + stats on HomeScreen
- Animations + transitions
- App icon + splash screen
