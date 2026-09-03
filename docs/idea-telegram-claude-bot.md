# Project: ClaudeGram — Claude AI via Telegram

> Chat with Claude from anywhere. Your phone, desktop, group chats. Full Claude power in Telegram.

## Vision

A Telegram bot that acts as a full-featured Claude interface — streaming responses, vision, voice messages, file analysis, code review, and remote Claude Code execution. Not a toy wrapper — a production-grade personal AI assistant accessible from any device.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    ClaudeGram                         │
│                                                       │
│  Telegram Users                                       │
│  ┌────────┐ ┌────────┐ ┌────────┐                   │
│  │ User A │ │ User B │ │ Group  │                    │
│  └───┬────┘ └───┬────┘ └───┬────┘                   │
│      │          │          │                          │
│      └──────────┼──────────┘                          │
│                 │                                     │
│           ┌─────▼──────┐                              │
│           │  aiogram    │  Webhook / Polling           │
│           │  Router     │                              │
│           └─────┬──────┘                              │
│                 │                                     │
│     ┌───────────┼───────────┐                         │
│     │           │           │                         │
│  ┌──▼──┐   ┌───▼───┐   ┌──▼──────┐                  │
│  │ Cmd │   │ Msg   │   │ Media   │  Handlers         │
│  │ Hnd │   │ Hnd   │   │ Handler │                   │
│  └──┬──┘   └───┬───┘   └──┬──────┘                  │
│     │          │          │                           │
│     └──────────┼──────────┘                           │
│                │                                     │
│  ┌─────────────▼──────────────┐                      │
│  │      Middleware Layer       │                      │
│  │  Auth │ RateLimit │ Logger  │                      │
│  └─────────────┬──────────────┘                      │
│                │                                     │
│  ┌─────────────▼──────────────┐                      │
│  │      Service Layer          │                      │
│  │  ┌──────────┐ ┌──────────┐ │                      │
│  │  │ Claude   │ │ Session  │ │                      │
│  │  │ Service  │ │ Manager  │ │                      │
│  │  └────┬─────┘ └────┬─────┘ │                      │
│  │       │             │       │                      │
│  │  ┌────▼─────┐ ┌────▼─────┐ │                      │
│  │  │ Anthro-  │ │ SQLite   │ │                      │
│  │  │ pic API  │ │ Storage  │ │                      │
│  │  └──────────┘ └──────────┘ │                      │
│  └─────────────────────────────┘                      │
└───────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Component | Technology | Why |
|-----------|-----------|-----|
| **Bot Framework** | aiogram 3.x | Native async, FSM, middleware, routers — best for concurrent streaming |
| **AI** | Anthropic Python SDK (async) | Streaming, tool use, vision |
| **Storage** | SQLite via aiosqlite | Zero config, embedded, sufficient for personal bot |
| **Voice Transcription** | faster-whisper (local) or OpenAI Whisper API | Voice message → text |
| **PDF Parsing** | PyMuPDF (pymupdf) | Fast, reliable |
| **HTTP Client** | httpx | Async, modern |
| **Logging** | structlog | Structured JSON logs |
| **Deployment** | Docker on Oracle Cloud Free Tier | Permanently free, 24GB RAM |

---

## Core Features

### 1. Streaming Responses

Claude response streams into Telegram — user sees text appearing in real-time.

**How it works:**
1. User sends message
2. Bot sends placeholder ("Thinking...")
3. Bot streams from Claude API
4. Bot edits placeholder every 1-2 seconds with accumulated text
5. On complete, sends final message (splits if > 4096 chars)

```
User: "Explain async/await in Python"
Bot: "Thinking..."
Bot: "Async/await is Python's way of writing..." (updates live)
Bot: [final complete response]
```

**Key constraint:** Telegram allows editing a message max once per second per chat. Batch streaming updates.

### 2. Multi-Modal — Vision

Send images → Claude Vision analyzes them.

| Input | What Claude Can Do |
|-------|-------------------|
| Screenshot of error | Explain error, suggest fix |
| Photo of whiteboard | Transcribe and organize notes |
| UI mockup | Generate code to match |
| Diagram | Explain architecture |
| Code screenshot | Extract and review code |

### 3. Voice Messages

Telegram voice message → transcribe → Claude → text response (optionally TTS audio back).

```
User: [voice message] "How do I fix a merge conflict?"
Bot: "Transcribed: How do I fix a merge conflict?"
Bot: [Claude's response about merge conflicts]
```

### 4. File Analysis

Send files → Claude reads and analyzes.

| File Type | Handling |
|-----------|----------|
| `.py`, `.js`, `.ts`, `.go`, `.java` | Direct text extraction, code review |
| `.pdf` | PyMuPDF text extraction |
| `.json`, `.yaml`, `.toml`, `.xml` | Direct text |
| `.csv` | Parse and summarize |
| `.md`, `.txt` | Direct text |
| Images | Claude Vision |

### 5. Conversation Modes

Switch via inline keyboard or `/mode` command:

| Mode | System Prompt | Use Case |
|------|--------------|----------|
| **Chat** | General assistant | Default conversation |
| **Code Review** | Senior code reviewer | Paste code for review |
| **Summarize** | Concise summarizer | Summarize articles, docs |
| **Translate** | Translator | Translate text |
| **Explain** | Teacher / explainer | ELI5 complex topics |
| **Custom** | User-defined via `/system` | Anything |

### 6. Model Switching

```
/model haiku    → Fast, cheap responses
/model sonnet   → Balanced (default)
/model opus     → Maximum reasoning
```

### 7. Remote Claude Code (Advanced)

Run Claude Code CLI from Telegram. **Admin only, heavily sandboxed.**

```
User: /run Fix the linting errors in src/main.py
Bot: "Running Claude Code in /projects/myapp..."
Bot: [streams Claude Code output]
Bot: "Done. Fixed 3 linting errors. Changes committed."
```

---

## Telegram Commands

Register via BotFather for autocomplete:

| Command | Description |
|---------|-------------|
| `/start` | Welcome + register |
| `/new` | New conversation (clear history) |
| `/mode` | Switch mode (chat/code/summarize/translate) |
| `/model` | Switch Claude model |
| `/system` | Set custom system prompt |
| `/export` | Export conversation as .md file |
| `/usage` | Show token usage + estimated cost |
| `/help` | List all commands |
| `/allow <user_id>` | Admin: allow a user |
| `/ban <user_id>` | Admin: ban a user |
| `/stats` | Admin: usage statistics |
| `/run <prompt>` | Admin: run Claude Code remotely |

---

## Session Management

### Per-Chat Sessions

Each `chat_id` gets independent conversation. Same user in different chats = different sessions.

### Database Schema

```sql
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    username TEXT,
    is_allowed BOOLEAN DEFAULT FALSE,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sessions (
    chat_id INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    messages TEXT,                    -- JSON array
    system_prompt TEXT,
    mode TEXT DEFAULT 'chat',
    model TEXT DEFAULT 'claude-sonnet-4-20250514',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_input_tokens INTEGER DEFAULT 0,
    total_output_tokens INTEGER DEFAULT 0
);

CREATE TABLE usage_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    chat_id INTEGER,
    user_id INTEGER,
    model TEXT,
    input_tokens INTEGER,
    output_tokens INTEGER,
    cost_usd REAL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Context Window Management

When conversation approaches token limit (~150K):
1. Ask Claude to summarize conversation so far
2. Replace history with summary as context
3. Continue fresh with summary context

### Auto-Cleanup

Sessions inactive > 24 hours → auto-clear (configurable).

---

## Security

### User Allowlisting

Bot only responds to allowed users. Admin adds via `/allow`.

```python
# Middleware — runs before every handler
class AuthMiddleware(BaseMiddleware):
    async def __call__(self, handler, event, data):
        user_id = event.from_user.id
        if not await is_user_allowed(user_id):
            await event.answer("Not authorized. Ask admin for access.")
            return
        return await handler(event, data)
```

### Rate Limiting

Per-user limits prevent abuse:
- Max 30 messages/minute
- Max 10 file uploads/hour
- Max 5 Claude Code runs/hour (admin only)

### Secrets

```env
# .env — NEVER commit
TELEGRAM_BOT_TOKEN=123456:ABC-DEF...
ANTHROPIC_API_KEY=sk-ant-...
ADMIN_USER_IDS=123456789,987654321
ALLOWED_WORKING_DIR=/projects
```

---

## Formatting Layer

Claude outputs Markdown. Telegram expects HTML. Need reliable converter.

| Claude Markdown | Telegram HTML |
|----------------|---------------|
| `**bold**` | `<b>bold</b>` |
| `*italic*` | `<i>italic</i>` |
| `` `code` `` | `<code>code</code>` |
| ```` ```python ```` | `<pre><code class="language-python">` |
| `[text](url)` | `<a href="url">text</a>` |
| `# Header` | `<b>Header</b>` (no native headers in Telegram) |

**Use `mistune` or `markdown-it-py`** for parsing, then post-process for Telegram's limited HTML subset.

**Long message splitting:**
- Split at 4096 chars
- Never split inside code blocks
- Never split mid-sentence if possible

---

## Project Structure

```
claudegram/
├── pyproject.toml
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── README.md
│
├── bot/
│   ├── __init__.py
│   ├── __main__.py              # Entry point
│   ├── config.py                # Env config loader
│   │
│   ├── handlers/
│   │   ├── __init__.py
│   │   ├── commands.py          # /start, /new, /mode, /model, /help
│   │   ├── messages.py          # Text messages → Claude
│   │   ├── media.py             # Photos, voice, documents
│   │   ├── admin.py             # /allow, /ban, /stats, /run
│   │   └── callbacks.py        # Inline keyboard callbacks
│   │
│   ├── services/
│   │   ├── __init__.py
│   │   ├── claude.py            # Claude API client (streaming, vision, tools)
│   │   ├── session.py           # Session CRUD, history management
│   │   ├── transcribe.py        # Voice → text (faster-whisper)
│   │   ├── files.py             # File parsing (PDF, code, etc.)
│   │   └── cost.py              # Usage tracking, cost calculation
│   │
│   ├── middleware/
│   │   ├── __init__.py
│   │   ├── auth.py              # User allowlist check
│   │   ├── rate_limit.py        # Per-user rate limiting
│   │   └── logging.py           # Request/response logging
│   │
│   ├── storage/
│   │   ├── __init__.py
│   │   ├── sqlite.py            # SQLite implementation
│   │   └── models.py            # Data models
│   │
│   └── utils/
│       ├── __init__.py
│       ├── formatting.py        # Markdown → Telegram HTML
│       └── splitting.py         # Long message splitting
│
├── tests/
│   ├── test_handlers/
│   ├── test_services/
│   └── test_utils/
│
└── data/                        # SQLite DB (Docker volume)
```

---

## Dependencies

```toml
[project]
name = "claudegram"
requires-python = ">=3.11"

dependencies = [
    # Bot
    "aiogram>=3.15",
    
    # AI
    "anthropic>=0.49",
    
    # Storage
    "aiosqlite>=0.20",
    
    # HTTP
    "httpx>=0.27",
    
    # File parsing
    "pymupdf>=1.25",
    
    # Voice (optional)
    "faster-whisper>=1.1",
    
    # Formatting
    "mistune>=3.0",
    
    # Logging
    "structlog>=24.0",
]
```

---

## Deployment

### Option 1: Oracle Cloud Free Tier (Recommended)

**Permanently free.** 4 ARM cores, 24GB RAM. More than enough.

```bash
# On Oracle Cloud ARM instance
sudo apt update && sudo apt install docker.io docker-compose -y
git clone <repo>
cp .env.example .env  # Fill in tokens
docker-compose up -d
```

### Option 2: Home Server

Run on any machine. Use Cloudflare Tunnel for webhook (free).

```bash
# Install cloudflared
cloudflared tunnel --url http://localhost:8443
# Use the tunnel URL as webhook
```

### Option 3: Fly.io

```bash
fly launch
fly secrets set TELEGRAM_BOT_TOKEN=... ANTHROPIC_API_KEY=...
fly deploy
```

### Docker Setup

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY pyproject.toml .
RUN pip install --no-cache-dir .
COPY . .

VOLUME /app/data
ENV DATABASE_PATH=/app/data/bot.db

CMD ["python", "-m", "bot"]
```

```yaml
# docker-compose.yml
services:
  bot:
    build: .
    restart: unless-stopped
    env_file: .env
    volumes:
      - ./data:/app/data
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
```

---

## Cost Estimate

| Component | Cost |
|-----------|------|
| Telegram Bot API | Free |
| Claude Sonnet (default) | ~$3/1M input, $15/1M output |
| Claude Haiku (fast mode) | ~$0.80/1M input, $4/1M output |
| Oracle Cloud hosting | Free |
| **Total for moderate personal use** | **~$3-10/month** |

### Cost Tracking Per User

```
/usage

Token usage this session:
  Input:  12,450 tokens
  Output: 8,320 tokens
  Cost:   $0.16

All time:
  Total cost: $4.23
  Messages:   342
```

---

## Development Phases

### Phase 1 — Basic Bot (Week 1)
- [ ] aiogram setup with polling
- [ ] `/start`, `/help`, `/new` commands
- [ ] Text messages → Claude → response (no streaming)
- [ ] User allowlisting
- [ ] SQLite session storage

### Phase 2 — Streaming & Formatting (Week 2)
- [ ] Streaming responses (edit placeholder)
- [ ] Markdown → Telegram HTML converter
- [ ] Long message splitting
- [ ] Error handling

### Phase 3 — Multi-Modal (Week 3)
- [ ] Photo → Claude Vision
- [ ] Voice messages → faster-whisper → Claude
- [ ] Document/file analysis
- [ ] PDF parsing

### Phase 4 — Modes & Models (Week 4)
- [ ] Conversation modes (chat, code review, summarize, translate)
- [ ] Model switching (haiku/sonnet/opus)
- [ ] Custom system prompts
- [ ] Inline keyboards for mode/model selection

### Phase 5 — Session Management (Week 5)
- [ ] Context window management (auto-summarize)
- [ ] Conversation export
- [ ] Session timeout/cleanup
- [ ] Usage tracking + cost calculation

### Phase 6 — Admin & Security (Week 6)
- [ ] Admin commands (/allow, /ban, /stats)
- [ ] Rate limiting middleware
- [ ] Structured logging
- [ ] Audit trail

### Phase 7 — Deployment (Week 7)
- [ ] Dockerfile + docker-compose
- [ ] Deploy to Oracle Cloud Free Tier
- [ ] Webhook setup
- [ ] Health checks + monitoring

### Phase 8 — Advanced (Week 8+)
- [ ] Remote Claude Code execution (/run)
- [ ] Tool use (web search, code execution)
- [ ] Group chat support
- [ ] Inline mode (@bot query)
- [ ] Scheduled messages

---

## Reference Projects

| Project | Learn From |
|---------|------------|
| **karfly/chatgpt_telegram_bot** (6k stars) | Streaming pattern, session management, architecture |
| **n3d1117/chatgpt-telegram-bot** (3k stars) | Voice messages, multi-modal, plugins |
| **yym68686/ChatGPT-Telegram-Bot** (1k stars) | Multi-provider architecture |

Swap OpenAI SDK → Anthropic SDK. Core patterns (streaming + edit, sessions, auth) are identical.

---

## Example Interactions

```
User: /start
Bot: Welcome to ClaudeGram! You're chatting with Claude.
     
     Commands:
     /new    — Start fresh conversation
     /mode   — Switch mode (chat, code, summarize)
     /model  — Switch model (haiku, sonnet, opus)
     /export — Download conversation
     /usage  — Check token usage
     
     Send any message to begin.

User: Explain Python generators in 3 sentences
Bot: Generators are functions that use `yield` to produce values 
     lazily — one at a time, on demand. Unlike lists that store 
     everything in memory, generators compute each value only when 
     requested, making them memory-efficient for large sequences. 
     Use them when you need to iterate over data that's too large 
     to fit in memory or when you want to pipeline processing steps.

User: [sends photo of code with a bug]
Bot: I can see a Python function with an off-by-one error on line 12.
     The loop uses `range(1, len(items))` but should start at 0:
     
     ```python
     # Bug: skips first item
     for i in range(1, len(items)):
     
     # Fix:
     for i in range(len(items)):
     ```

User: [voice message] "How do I revert a git commit?"
Bot: Transcribed: "How do I revert a git commit?"
     
     Two options:
     • `git revert <hash>` — creates new commit undoing changes (safe)
     • `git reset --hard <hash>` — removes commits (destructive, don't
       use on shared branches)
     
     For the last commit: `git revert HEAD`

User: /mode code_review
Bot: Switched to Code Review mode. Send code and I'll review it.

User: /usage
Bot: Session: 3,200 input / 1,800 output tokens ($0.04)
     All time: 45,000 / 28,000 tokens ($0.56)
     Model: claude-sonnet-4-20250514
```

---

## Connection with JARVIS Voice Agent

Both projects can integrate:

```
JARVIS (Mac) ←→ ClaudeGram (Telegram)

• JARVIS sends notifications to Telegram ("Task complete", "Meeting in 5 min")
• Telegram commands trigger JARVIS actions ("Hey, turn on dark mode on my Mac")
• Shared conversation history between voice and text
• Telegram as remote control when away from Mac
```

Shared Claude API key, shared session storage, different interfaces to same brain.
