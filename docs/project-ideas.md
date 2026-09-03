# Project Ideas

Two personal projects to build. Pick one to start, then move to the next.

---

## Project 1: Free Coding Terminal Agent

### Problem
AI coding assistants (Claude Code, Cursor, GitHub Copilot) require paid subscriptions. I want a free alternative I can use daily.

### Vision
A CLI-based coding agent that runs in the terminal, understands codebases, and helps with development tasks — powered by free/open-source LLMs.

### Core Features
- **Chat in terminal** — ask questions, get code suggestions
- **File awareness** — read, edit, and create files in the project
- **Code generation** — generate functions, classes, boilerplate
- **Code explanation** — explain existing code
- **Bug fixing** — analyze errors and suggest fixes
- **Shell command execution** — run build/test commands
- **Context management** — understand project structure and relevant files

### Possible Tech Stack (TBD)
| Component | Options |
|-----------|---------|
| Language | Python, Node.js, Go, Rust |
| LLM Backend | Ollama (local), LM Studio, free API tiers (Groq, Together, HuggingFace) |
| Models | Llama 3, DeepSeek Coder, CodeGemma, Mistral, Qwen Coder |
| Terminal UI | Rich (Python), Ink (Node), Bubble Tea (Go) |

### Key Decisions Needed
- [ ] Local-only LLM vs free API tier vs hybrid?
- [ ] Which programming language for the agent itself?
- [ ] Which LLM model(s) to support?
- [ ] Scope: simple chat or full agent with file editing?
- [ ] Plugin/extension system needed?

### Challenges
- Local LLMs need decent hardware (8GB+ RAM for small models, 16GB+ for good ones)
- Free API tiers have rate limits
- Context window limits with large codebases
- Quality gap vs paid models (GPT-4, Claude)

---

## Project 2: Tech Trends Mobile App

### Problem
Staying updated with the latest tech trends requires checking multiple sources (Twitter/X, Hacker News, Reddit, blogs, newsletters). I want one app that aggregates and curates everything.

### Vision
A mobile app that automatically searches, aggregates, and presents the latest tech trends, tools, frameworks, and industry news — personalized to my interests.

### Core Features
- **Auto-aggregation** — pulls from multiple sources automatically
- **Trending topics** — shows what's hot in tech right now
- **Category filtering** — AI/ML, Web Dev, Mobile, DevOps, Cloud, etc.
- **Daily digest** — morning summary of what's new
- **Search** — find specific topics or technologies
- **Bookmarks** — save articles for later
- **Push notifications** — alerts for major trends or topics you follow
- **Personalization** — learns what you care about over time

### Data Sources (TBD)
| Source | What It Provides |
|--------|-----------------|
| Hacker News | Developer community trends |
| Reddit (r/programming, r/technology) | Community discussions |
| GitHub Trending | Popular repos, new tools |
| Dev.to / Medium | Blog posts, tutorials |
| Twitter/X | Real-time tech discourse |
| Product Hunt | New product launches |
| Google Trends | Search trend data |
| Tech blogs (Vercel, Netlify, etc.) | Official announcements |
| RSS feeds | Custom source aggregation |

### Possible Tech Stack (TBD)
| Component | Options |
|-----------|---------|
| Mobile Framework | React Native, Flutter, Swift (iOS only) |
| Backend | Node.js, Python (FastAPI), Go |
| Database | PostgreSQL, Supabase, Firebase |
| Scraping/Aggregation | Python (BeautifulSoup, Scrapy), Node (Cheerio) |
| AI Summarization | OpenAI API, local LLM, HuggingFace models |
| Push Notifications | Firebase Cloud Messaging, OneSignal |
| Search | Algolia, Meilisearch, Elasticsearch |
| Hosting | Vercel, Railway, Fly.io, self-hosted |

### Key Decisions Needed
- [ ] Mobile framework choice?
- [ ] iOS only, Android only, or both?
- [ ] Backend language?
- [ ] Free tier hosting vs self-hosted?
- [ ] AI summarization needed or just aggregation?
- [ ] How to handle rate limits on data sources?
- [ ] Monetization plan (if any)?

### Challenges
- Rate limits on scraping/APIs
- Keeping data fresh (real-time vs scheduled updates)
- Content quality filtering (noise vs signal)
- Mobile app store requirements (Apple review, etc.)
- Cost of running backend + AI summarization

---

## Comparison

| Factor | Coding Agent | Tech Trends App |
|--------|-------------|-----------------|
| Complexity | Medium-High | High |
| Daily usefulness | Very High | High |
| Learning value | LLM integration, CLI tools | Full-stack, mobile, scraping |
| Cost to run | Free (local LLM) | Backend hosting costs |
| Time to MVP | 2-4 weeks | 4-8 weeks |
| Monetization potential | Low (open source) | Medium (ads, premium) |

---

## Next Steps

1. Choose which project to start
2. Finalize tech stack decisions
3. Create detailed architecture and plan
4. Start building (TDD approach)
