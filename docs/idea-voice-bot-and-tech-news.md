# Project Ideas: Voice Bot & Tech News Aggregator

---

## Idea 1: Voice Bot — AI System Controller

### What It Is
A personal voice-controlled AI agent that runs on your desktop and can interact with your system — open apps, run commands, search the web, manage files, write code, send messages — anything you say, it does.

Think: Open Interpreter + voice, but fully yours.

### Core Features
- **Wake word** — say "Hey [name]" to activate
- **Natural language commands** — "Open VS Code and create a new file called index.js"
- **System access** — terminal commands, file management, browser control
- **Memory** — remembers context within a session
- **Safe mode** — confirm before destructive actions (delete, push to prod, etc.)

### Tech Stack
| Layer | Option |
|-------|--------|
| Speech-to-text | OpenAI Whisper (local) or Deepgram API |
| LLM brain | Claude API (claude-sonnet-4-6) |
| System tools | Python subprocess, shell commands, pyautogui |
| Desktop app | Electron (macOS/Windows) or Python + Tkinter |
| Hotkey trigger | pynput / global hotkey listener |

### Architecture
```
Microphone → Whisper (STT) → Claude (understand intent)
    → Tool calls (terminal, files, browser, clipboard)
    → Response → Text-to-speech (optional)
```

### Risks & Challenges
- **Safety**: Voice misfire could run destructive commands → need confirmation layer
- **Latency**: STT + LLM + tool execution adds up → needs streaming
- **Cross-platform**: macOS permissions for mic/screen access
- **Scope creep**: Easy to keep adding tools forever

### MVP Scope
1. Wake word listener
2. Record voice → transcribe with Whisper
3. Send to Claude with system tools (run terminal command, open app, read/write file)
4. Speak or print response
5. Confirm before any destructive action

### Platform
- **macOS desktop first** (Electron or Python app)

### Complexity: High
### Build Time (MVP): 3–4 weeks

---

## Idea 2: Tech Pulse — AI-Powered Tech News Mobile App

### What It Is
A mobile app that automatically aggregates the latest tech and AI news from top sources, summarizes it with AI, and shows you what matters — before anyone else tells you.

Launches, new models, free tools, product updates, industry moves — all in one feed.

### Core Features
- **Auto-refresh feed** — pulls latest content on open (or on-demand via button)
- **AI summarization** — long blog posts → 3-line cards you can actually read
- **Categories** — AI Models, New Tools, Product Launches, Dev News, Funding/Acquisitions
- **Push notifications** — breaking launches (new GPT, new Claude, etc.)
- **Save / bookmark** — keep articles you want to revisit
- **Source filter** — toggle which sources you follow

### News Sources (RSS / APIs)
| Source | What It Covers |
|--------|---------------|
| OpenAI Blog | GPT releases, API updates |
| Anthropic Blog | Claude updates |
| Google DeepMind | Gemini, research |
| Hacker News (top) | Dev community hot topics |
| TechCrunch AI | Startup launches, funding |
| Product Hunt | New tools launched daily |
| GitHub Trending | Hot new repos |
| The Verge Tech | Consumer tech news |
| MIT Tech Review | Deep tech, research |
| AI News (ainews.io) | AI-specific aggregator |

### Tech Stack
| Layer | Choice |
|-------|--------|
| Mobile | Expo (React Native) — iOS + Android |
| Backend | Next.js API routes or Supabase Edge Functions |
| Feed parsing | RSS parser + Cheerio for scraping fallback |
| AI summarization | Gemini Flash 1.5 (cheap) or Claude Haiku |
| Database | Supabase (saved articles, user prefs) |
| Push notifications | Expo Push Notifications |
| Hosting | Vercel (backend) |

### Architecture
```
Cron job (every 1–6 hrs)
    → Fetch RSS feeds from all sources
    → Parse + deduplicate articles
    → AI summarize each article (Gemini Flash = cheap)
    → Store in Supabase

Mobile App
    → On open: fetch latest articles from Supabase
    → Show as cards (title, source, 3-line AI summary, link)
    → Push notification for high-priority items
```

### MVP Scope
1. Backend cron fetches 5–10 RSS sources every 2 hours
2. AI summarizes each article into 2–3 sentences
3. Mobile app shows card feed (newest first)
4. Tap card → open full article in in-app browser
5. Pull-to-refresh
6. Category filter tabs (All / AI / Tools / Dev)

### Risks & Challenges
- **Rate limits** on AI summarization (batch carefully, use cheap models)
- **RSS reliability** — some sites block or have bad feeds → need fallback scraping
- **App store approval** — content aggregators usually pass fine
- **Keeping sources fresh** — need to add new sources as ecosystem grows

### Platform
- **iOS + Android** via Expo

### Complexity: Medium
### Build Time (MVP): 2–3 weeks

---

## Comparison

| | Voice Bot | Tech Pulse |
|--|-----------|------------|
| Complexity | High | Medium |
| Build Time | 3–4 weeks | 2–3 weeks |
| Immediate value | Personal productivity | Daily use, stays relevant |
| Monetization potential | Low (personal tool) | Medium (ads, premium feeds) |
| Portfolio value | Impressive demo | Practical product |
| Recommended to build first | 2nd | **1st** |

---

## Recommendation

**Build Tech Pulse first.**

- Faster to ship
- You'll use it every day
- Clear MVP with room to expand
- Good portfolio piece (real product, real users possible)

**Then build the Voice Bot.**

- More technically impressive
- Better after you have bandwidth to iterate on safety + UX
