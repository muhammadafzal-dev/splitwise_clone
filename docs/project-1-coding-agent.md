# Project 1: My Own Free Coding Agent

**Project Name:** DevPilot (working name)
**Status:** Phase 1 — MVP in progress

---

## Vision

Build my own coding terminal agent — like Claude Code — that is:
- 100% free to use
- Supports multiple LLM backends (switch anytime)
- Self-hosted on my own server or free cloud platform
- Full coding capabilities (read, write, edit files, run commands)

---

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│              MY CODING AGENT                │
│                                              │
│  ┌──────────┐   ┌────────────────────────┐  │
│  │ Terminal  │   │    LLM Router          │  │
│  │   UI      │──▶│  (Multi-LLM Switcher) │  │
│  └──────────┘   └────────┬───────────────┘  │
│                           │                  │
│  ┌──────────┐   ┌────────▼───────────────┐  │
│  │  Tools   │   │   LLM Providers        │  │
│  │ - File   │   │                        │  │
│  │ - Shell  │   │  ┌─────┐ ┌─────────┐  │  │
│  │ - Search │   │  │Groq │ │ Gemini  │  │  │
│  │ - Git    │   │  └─────┘ └─────────┘  │  │
│  └──────────┘   │  ┌──────┐ ┌────────┐  │  │
│                  │  │Ollama│ │OpenRouter│ │  │
│                  │  └──────┘ └────────┘  │  │
│                  │  ┌────────┐ ┌──────┐  │  │
│                  │  │HuggingF│ │Custom│  │  │
│                  │  └────────┘ └──────┘  │  │
│                  └────────────────────────┘  │
└─────────────────────────────────────────────┘
```

---

## Core Features

### 1. Multi-LLM Switcher (Key Feature)
Switch between LLM providers with a simple command:

```
> /switch groq          → Uses Groq (Llama 3.3 70B) — free, fast
> /switch gemini        → Uses Google Gemini 2.0 Flash — free tier
> /switch ollama        → Uses local Ollama model — free, offline
> /switch openrouter    → Uses OpenRouter free models
> /switch huggingface   → Uses HuggingFace Inference API
> /switch custom        → Uses any OpenAI-compatible API endpoint
> /models               → List all configured LLMs and their status
> /current              → Show which LLM is active right now
```

### 2. Coding Agent Capabilities
| Capability | Description |
|-----------|-------------|
| Chat | Ask questions, get code help |
| Read files | Read any file in your project |
| Write files | Create new files |
| Edit files | Modify existing files (smart diffs) |
| Run commands | Execute shell commands (build, test, git) |
| Search code | Find functions, classes, patterns in codebase |
| Project context | Understand folder structure and dependencies |
| Error fixing | Paste an error, get a fix |
| Code generation | Generate boilerplate, functions, classes |
| Explain code | Explain what existing code does |

### 3. Configuration System
```yaml
# config.yaml — stored in ~/.myagent/config.yaml
providers:
  groq:
    api_key: "gsk_..."       # Free API key from groq.com
    model: "llama-3.3-70b-versatile"
    enabled: true

  gemini:
    api_key: "AI..."          # Free API key from Google AI Studio
    model: "gemini-2.0-flash"
    enabled: true

  ollama:
    host: "http://localhost:11434"
    model: "deepseek-coder-v2"
    enabled: true

  openrouter:
    api_key: "sk-or-..."
    model: "meta-llama/llama-3.3-70b"
    enabled: true

  huggingface:
    api_key: "hf_..."
    model: "bigcode/starcoder2-15b"
    enabled: true

  custom:
    base_url: "http://your-server:8080/v1"
    api_key: "your-key"
    model: "your-model"
    enabled: false

default_provider: groq

# Auto-fallback: if primary provider fails, try next one
fallback_order:
  - groq
  - gemini
  - ollama
```

---

## Supported LLM Providers (All Free)

| Provider | Model | Free Tier | Speed | Coding Quality |
|----------|-------|-----------|-------|---------------|
| **Groq** | Llama 3.3 70B | 30 req/min, 14.4K/day | Blazing fast | Good (7/10) |
| **Google Gemini** | Gemini 2.0 Flash | 15 req/min | Fast | Good (7/10) |
| **Ollama (local)** | DeepSeek Coder V2 | Unlimited (local) | Depends on hardware | Very Good (8/10) |
| **OpenRouter** | Various free models | Limited | Medium | Varies |
| **HuggingFace** | StarCoder2, CodeLlama | Rate limited | Slow | Decent (6/10) |
| **Together AI** | Free tier models | Limited | Fast | Good |
| **Custom** | Any OpenAI-compatible | Depends | Depends | Depends |

---

## Tech Stack

| Component | Choice | Why |
|-----------|--------|-----|
| Language | **Python** | Best LLM library ecosystem, fast to build |
| Terminal UI | **Rich + Prompt Toolkit** | Beautiful terminal UI, autocomplete |
| LLM Integration | **LiteLLM** | One library to connect ALL LLM providers |
| File Operations | **Built-in (os, pathlib)** | Read, write, edit files |
| Code Search | **ripgrep (subprocess)** | Fast code search |
| Config | **YAML + Pydantic** | Type-safe configuration |
| Package Manager | **pip / Poetry** | Standard Python packaging |

### Why LiteLLM is the Key

LiteLLM is an open-source library that provides ONE unified API for 100+ LLM providers:

```python
from litellm import completion

# Same code, different providers — just change the model string
response = completion(model="groq/llama-3.3-70b-versatile", messages=[...])
response = completion(model="gemini/gemini-2.0-flash", messages=[...])
response = completion(model="ollama/deepseek-coder-v2", messages=[...])
response = completion(model="openrouter/meta-llama/llama-3.3-70b", messages=[...])
```

This means: **add any new LLM provider by just adding a config entry. No code changes.**

---

## Project Structure

```
my-coding-agent/
├── README.md
├── pyproject.toml              # Dependencies
├── config.example.yaml         # Example config
│
├── src/
│   ├── __init__.py
│   ├── main.py                 # Entry point
│   │
│   ├── agent/
│   │   ├── __init__.py
│   │   ├── agent.py            # Main agent loop (chat → think → act)
│   │   ├── context.py          # Project context management
│   │   └── memory.py           # Conversation history
│   │
│   ├── llm/
│   │   ├── __init__.py
│   │   ├── router.py           # Multi-LLM router & switcher
│   │   ├── providers.py        # Provider configurations
│   │   └── fallback.py         # Auto-fallback logic
│   │
│   ├── tools/
│   │   ├── __init__.py
│   │   ├── file_read.py        # Read files
│   │   ├── file_write.py       # Write/create files
│   │   ├── file_edit.py        # Edit existing files
│   │   ├── shell.py            # Execute shell commands
│   │   ├── search.py           # Search code (grep/glob)
│   │   └── git.py              # Git operations
│   │
│   ├── ui/
│   │   ├── __init__.py
│   │   ├── terminal.py         # Terminal interface (Rich)
│   │   ├── colors.py           # Theme & styling
│   │   └── commands.py         # Slash commands (/switch, /models, etc.)
│   │
│   └── config/
│       ├── __init__.py
│       ├── settings.py         # Load & validate config
│       └── defaults.py         # Default settings
│
└── tests/
    ├── test_router.py
    ├── test_tools.py
    └── test_agent.py
```

---

## Development Phases

### Phase 1: MVP (Week 1-2)
- [ ] Basic terminal chat UI
- [ ] Connect to Groq (free LLM)
- [ ] File read tool
- [ ] File write tool
- [ ] Shell command execution
- [ ] Basic project context (read file tree)

### Phase 2: Multi-LLM (Week 2-3)
- [ ] LLM Router with LiteLLM
- [ ] `/switch` command to change providers
- [ ] Config file (YAML) for API keys
- [ ] Add Gemini, Ollama, OpenRouter support
- [ ] Auto-fallback when provider fails
- [ ] `/models` command to list available LLMs

### Phase 3: Smart Agent (Week 3-4)
- [ ] File edit tool (smart diffs, not full rewrites)
- [ ] Code search tool (grep/glob)
- [ ] Git integration (status, diff, commit)
- [ ] Conversation memory (remember context)
- [ ] Project structure understanding
- [ ] Error detection and fix suggestions

### Phase 4: Polish & Deploy (Week 4-5)
- [ ] Beautiful terminal UI (colors, syntax highlighting)
- [ ] Slash commands (/help, /clear, /switch, /models, etc.)
- [ ] Install script (one-command setup)
- [ ] Publish to PyPI (`pip install my-agent`)
- [ ] Documentation & README
- [ ] Deploy backend (if web version) to Render/Railway

---

## Deployment Options

### Option A: Local CLI Tool (Primary)
```bash
pip install my-coding-agent
my-agent                        # Start the agent
my-agent --provider groq        # Start with specific LLM
```
- Runs on your machine
- Full file access
- Free forever

### Option B: Self-Hosted Server (Optional, for access anywhere)
Deploy to free tier:
| Platform | Free Tier | Good For |
|----------|-----------|----------|
| **Render** | 750 hrs/month | Backend API |
| **Railway** | $5 free credit | Backend API |
| **Fly.io** | 3 shared VMs | Backend API |
| **GitHub Codespaces** | 60 hrs/month | Full dev environment |

---

## How It Will Work (User Experience)

```
$ my-agent

  Welcome to MyCodingAgent v0.1
  Provider: Groq (Llama 3.3 70B) | Model: llama-3.3-70b-versatile

> Read the main.py file and explain what it does

  Reading src/main.py...

  This file is the entry point for a Flask web app. It:
  1. Initializes the Flask app with config from .env
  2. Registers 3 blueprints (auth, api, admin)
  3. Sets up SQLAlchemy database connection
  4. Starts the dev server on port 5000

> Fix the bug on line 42

  Looking at line 42...
  The issue is a missing null check. Here's the fix:
  [shows diff]
  Apply this change? (y/n)

> /switch gemini

  Switched to: Google Gemini (gemini-2.0-flash)

> /switch ollama

  Switched to: Ollama (deepseek-coder-v2) — running locally

> /models

  Available providers:
  ✅ groq         — Llama 3.3 70B (online, fast)
  ✅ gemini       — Gemini 2.0 Flash (online, fast)
  ✅ ollama       — DeepSeek Coder V2 (local, offline)
  ❌ openrouter   — Not configured (missing API key)
  ❌ huggingface  — Not configured (missing API key)
```

---

## Key Advantages Over Existing Tools

| vs. | Our Agent Wins Because |
|-----|----------------------|
| Claude Code | Free, no subscription |
| Open Interpreter | Multi-LLM switcher, better UI, our own customizations |
| Aider | More tools (shell, search, git), not just file editing |
| Cursor | Terminal-based, no IDE lock-in, free |

---

## Next Steps

1. Set up Python project
2. Build Phase 1 MVP
3. Test with Groq free tier
4. Add multi-LLM support
5. Iterate and enhance
