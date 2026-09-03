# Project: JARVIS — AI Voice Agent for macOS

> Not a simple voice command executor. A full AI agent that sees, understands, and controls your Mac.

## Vision

An always-listening, context-aware AI agent that manages your Mac through natural conversation. Think Open Interpreter + Siri + Claude — but open source and extensible via plugins.

**What makes this different from basic voice assistants:**
- **Screen awareness** — takes screenshots, understands what you're looking at
- **Multi-step reasoning** — breaks complex requests into steps, executes autonomously
- **Plugin architecture** — extensible with custom tools
- **Memory** — remembers preferences, past conversations, learned patterns
- **Confirmation gates** — asks before destructive actions
- **Context injection** — knows active app, clipboard, running processes

---

## Architecture

```
                     ┌─────────────────────────────────────────────┐
                     │              JARVIS Core                     │
                     │                                             │
  Mic ──► VAD ──► Wake Word ──► STT ──► ┌──────────────┐          │
                                         │  Agent Loop   │          │
                                         │  (Claude API) │          │
                                         │  + Tools      │          │
  Speaker ◄── TTS ◄─────────────────────│  + Memory     │          │
                                         │  + Context    │          │
                                         └──────┬───────┘          │
                                                │                  │
                     ┌──────────────────────────┼──────────────┐   │
                     │         Tool Registry     │              │   │
                     │  ┌─────────┐ ┌──────────┐ ┌───────────┐│   │
                     │  │ System  │ │ Apps     │ │ Browser   ││   │
                     │  │ Control │ │ Control  │ │ Automation││   │
                     │  └─────────┘ └──────────┘ └───────────┘│   │
                     │  ┌─────────┐ ┌──────────┐ ┌───────────┐│   │
                     │  │ Vision  │ │ Files    │ │ Calendar  ││   │
                     │  │ Screen  │ │ Manager  │ │ Contacts  ││   │
                     │  └─────────┘ └──────────┘ └───────────┘│   │
                     │  ┌─────────┐ ┌──────────┐ ┌───────────┐│   │
                     │  │ Plugins │ │ Shell    │ │ Web       ││   │
                     │  │ (user)  │ │ Execute  │ │ Search    ││   │
                     │  └─────────┘ └──────────┘ └───────────┘│   │
                     └─────────────────────────────────────────┘   │
                     └─────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| **Wake Word** | Porcupine (free tier) or OpenWakeWord | Low CPU, custom wake words |
| **VAD** | silero-vad | Best accuracy, lightweight |
| **STT** | faster-whisper (local) | Free, private, excellent quality |
| **AI Brain** | Claude API (tool use) | Best reasoning for agent tasks |
| **Vision** | Claude Vision + Apple Vision OCR | Screen understanding |
| **TTS** | edge-tts (free) or OpenAI TTS | Natural voice, low latency |
| **macOS Control** | pyobjc + AppleScript (osascript) | Maximum system access |
| **Audio I/O** | sounddevice | Clean API, streaming callbacks |
| **Memory** | SQLite (aiosqlite) | Simple, embedded, sufficient |
| **Config** | YAML | Human-readable |

---

## Core Capabilities

### Tier 1 — System Control
| Command Example | Implementation |
|----------------|----------------|
| "Set volume to 50%" | `osascript -e 'set volume output volume 50'` |
| "Turn on dark mode" | AppleScript → System Events |
| "Toggle WiFi" | `networksetup -setairportpower en0 off/on` |
| "Toggle Bluetooth" | `blueutil --power 0/1` |
| "Set brightness to 70%" | `brightness` CLI or IOKit via pyobjc |
| "Enable Do Not Disturb" | `defaults write` + shortcuts |
| "Lock my screen" | `pmset displaysleepnow` |
| "Empty trash" | AppleScript (with confirmation gate) |

### Tier 2 — App Management
| Command Example | Implementation |
|----------------|----------------|
| "Open Safari" | `NSWorkspace.launchApplication_("Safari")` |
| "Kill Chrome" | `app.terminate()` via NSRunningApplication |
| "Switch to VS Code" | `app.activateWithOptions_()` |
| "What apps are running?" | `NSWorkspace.runningApplications()` |
| "Close all Finder windows" | AppleScript → Finder |
| "Open Terminal and run git status" | AppleScript → Terminal + keystroke |

### Tier 3 — Browser Automation
| Command Example | Implementation |
|----------------|----------------|
| "Open GitHub in Safari" | AppleScript → Safari URL |
| "Search Google for X" | AppleScript → Safari + URL |
| "Read this page for me" | Screenshot → Claude Vision or AppleScript → page source |
| "Fill out this form" | AXUIElement or Playwright |

### Tier 4 — File Management
| Command Example | Implementation |
|----------------|----------------|
| "Find all PDFs on Desktop" | `glob` / `pathlib` |
| "Move downloads older than a week to archive" | Python file ops |
| "What's in my clipboard?" | NSPasteboard |
| "Copy this file path" | NSPasteboard write |
| "Create a new folder called Projects" | `os.makedirs` |

### Tier 5 — PIM (Calendar, Contacts, Reminders, Notes)
| Command Example | Implementation |
|----------------|----------------|
| "What's on my calendar today?" | EventKit via pyobjc |
| "Add a reminder for 3pm" | EventKit |
| "Create a note with meeting summary" | AppleScript → Notes |
| "Find John's phone number" | Contacts framework via pyobjc |

### Tier 6 — Vision & Context Awareness
| Command Example | Implementation |
|----------------|----------------|
| "What am I looking at?" | Screenshot → Claude Vision |
| "Read the error on screen" | Screenshot → Vision + OCR |
| "What's in this spreadsheet?" | Screenshot → Claude Vision |
| "Help me with what I'm working on" | Context injection (active app, window title, screen) |

### Tier 7 — Complex Multi-Step Tasks
| Command Example | Steps |
|----------------|-------|
| "Email the PDF on my Desktop to John" | 1. Find PDF → 2. Find John's email → 3. Open Mail → 4. Compose → 5. Attach → 6. Send |
| "Summarize this article and save to Notes" | 1. Screenshot → 2. OCR/Vision → 3. Claude summarize → 4. Create Note |
| "Set up a meeting with Sarah tomorrow at 2pm" | 1. Check calendar → 2. Find Sarah's contact → 3. Create event → 4. Send invite |

---

## Agent Loop Design

```python
# Simplified agent loop — Claude decides which tools to call

SYSTEM_PROMPT = """
You are JARVIS, an AI assistant managing a macOS computer.
You have access to tools for controlling the system.
Current context: {system_context}

Rules:
- For destructive actions (delete, quit, send), ask for confirmation first
- Be concise in voice responses (user is listening, not reading)
- If you need to see the screen, use take_screenshot tool
- Chain multiple tools for complex tasks
- Report errors clearly
"""

def agent_loop(user_input, history, tools, max_steps=10):
    history.append({"role": "user", "content": user_input})
    
    for step in range(max_steps):
        response = claude.messages.create(
            model="claude-sonnet-4-20250514",
            system=SYSTEM_PROMPT.format(system_context=get_context()),
            tools=tools,
            messages=history,
        )
        
        history.append({"role": "assistant", "content": response.content})
        
        if response.stop_reason == "end_turn":
            text = extract_text(response)
            speak(text)  # TTS
            return text
        
        # Execute tools Claude requested
        tool_results = []
        for block in response.content:
            if block.type == "tool_use":
                if block.name in DESTRUCTIVE_ACTIONS:
                    if not confirm_with_user(block.name, block.input):
                        tool_results.append(tool_result(block.id, "Cancelled by user"))
                        continue
                result = execute_tool(block.name, block.input)
                tool_results.append(tool_result(block.id, result))
        
        history.append({"role": "user", "content": tool_results})
```

---

## Context Injection

Every turn, inject current system state so Claude knows what's happening:

```python
def get_system_context():
    return {
        "active_app": get_frontmost_app(),           # "VS Code"
        "active_window": get_active_window_title(),   # "main.py — my_project"
        "running_apps": get_running_apps(),           # ["Safari", "Terminal", ...]
        "clipboard": get_clipboard_text()[:200],      # First 200 chars
        "time": datetime.now().strftime("%I:%M %p"),   # "3:45 PM"
        "date": date.today().isoformat(),              # "2026-04-14"
        "battery": get_battery_percent(),              # "87%"
        "wifi": get_wifi_network(),                    # "HomeNetwork"
        "volume": get_volume(),                        # "50%"
    }
```

---

## Plugin System

Plugins = Python modules that expose tools to Claude.

```
plugins/
├── __init__.py
├── spotify.py          # Music control
├── slack_plugin.py     # Slack messaging
├── github_plugin.py    # GitHub operations
├── homekit.py          # Smart home control
├── pomodoro.py         # Focus timer
└── custom/             # User plugins
```

**Plugin contract:**

```python
# plugins/spotify.py
class SpotifyPlugin:
    name = "spotify"
    description = "Control Spotify playback"
    
    tools = [
        {
            "name": "spotify_play",
            "description": "Play a song, album, or playlist",
            "input_schema": {
                "type": "object",
                "properties": {
                    "query": {"type": "string"}
                },
                "required": ["query"]
            }
        },
        {
            "name": "spotify_pause",
            "description": "Pause/resume playback",
            "input_schema": {"type": "object", "properties": {}}
        },
        {
            "name": "spotify_next",
            "description": "Skip to next track",
            "input_schema": {"type": "object", "properties": {}}
        }
    ]
    
    def execute(self, tool_name, args):
        if tool_name == "spotify_play":
            return run_applescript(f'''
                tell application "Spotify"
                    play track "{args['query']}"
                end tell
            ''')
        # ...
```

**Dynamic loading:**
```python
def load_plugins(plugin_dir):
    registry = {}
    for file in Path(plugin_dir).glob("*.py"):
        module = importlib.import_module(f"plugins.{file.stem}")
        for cls in get_plugin_classes(module):
            instance = cls()
            registry[instance.name] = instance
    return registry
```

---

## Safety & Confirmation Gates

### Action Classification

| Level | Actions | Behavior |
|-------|---------|----------|
| **Safe** | Read clipboard, get app list, take screenshot, get settings | Execute immediately |
| **Moderate** | Open app, change volume, set brightness, create file | Execute, notify user |
| **Destructive** | Delete file, quit app, send email, empty trash, run shell command | Ask confirmation before executing |
| **Blocked** | `rm -rf`, format disk, system shutdown (without explicit enable) | Refuse, explain why |

### Confirmation via Voice

```
User: "Delete all screenshots from Desktop"
JARVIS: "I found 23 screenshots on your Desktop. Should I delete all of them?"
User: "Yes"
JARVIS: "Done. 23 files moved to Trash."
```

### Audit Log

Every action logged to `~/.jarvis/audit.log`:
```
2026-04-14 15:30:22 | EXECUTE | open_application | {"app": "Safari"} | SUCCESS
2026-04-14 15:30:45 | CONFIRM | delete_files | {"count": 23, "path": "~/Desktop"} | APPROVED
2026-04-14 15:30:46 | EXECUTE | delete_files | {"count": 23} | SUCCESS
```

---

## Memory System

```
~/.jarvis/
├── config.yaml            # User config
├── memory.db              # SQLite — conversations, preferences
├── audit.log              # Action log
├── plugins/               # User plugins
└── cache/                 # TTS cache, screenshot cache
```

**What memory stores:**
- Conversation history (with auto-summarization for long convos)
- User preferences ("I prefer dark mode", "Don't close Terminal")
- Learned patterns ("When I say 'work mode', open VS Code, Slack, and Safari")
- Command shortcuts ("meeting setup = open Zoom + mute Slack + set DND")

---

## macOS Permissions Required

| Permission | Required For | How to Grant |
|------------|-------------|--------------|
| **Microphone** | Voice input | Auto-prompted on first use |
| **Accessibility** | UI control, AXUIElement | Manual: System Settings → Privacy → Accessibility |
| **Screen Recording** | Screenshots for vision | Manual: System Settings → Privacy → Screen Recording |
| **Automation** | AppleScript to other apps | Auto-prompted per app |
| **Calendars** | Calendar access | Auto-prompted |
| **Contacts** | Contact lookup | Auto-prompted |
| **Reminders** | Reminders access | Auto-prompted |
| **Full Disk Access** | File operations everywhere | Manual (optional) |

**First-run setup wizard should guide user through granting these.**

---

## Audio Pipeline Detail

```
┌──────────────────────────────────────────────┐
│                Audio Pipeline                 │
│                                               │
│  sounddevice (16kHz, mono, int16)             │
│       │                                       │
│       ▼                                       │
│  silero-vad (voice activity detection)        │
│       │                                       │
│       ├── silence → continue listening        │
│       │                                       │
│       ▼ voice detected                        │
│  Porcupine / OpenWakeWord                     │
│       │                                       │
│       ├── no wake word → discard              │
│       │                                       │
│       ▼ wake word detected                    │
│  Record until silence (2s timeout)            │
│       │                                       │
│       ▼                                       │
│  faster-whisper (transcribe)                  │
│       │                                       │
│       ▼                                       │
│  Agent Loop (Claude API)                      │
│       │                                       │
│       ▼                                       │
│  edge-tts / OpenAI TTS → speaker             │
└──────────────────────────────────────────────┘
```

**Also supports push-to-talk:** Global hotkey (e.g., `Cmd+Shift+Space`) via `pynput` to bypass wake word.

---

## Reference Projects

| Project | Stars | Learn From |
|---------|-------|------------|
| **Open Interpreter** | 55k+ | Agent loop, tool execution, voice mode, safety patterns |
| **Open Interpreter/01** | — | Dedicated voice interface architecture |
| **anthropic computer-use-demo** | — | Screen interaction via Claude Vision |
| **screenpipe** | — | Continuous screen/audio capture for AI context |
| **Leon AI** | — | Plugin system, multi-platform assistant |

---

## Project Structure

```
jarvis/
├── pyproject.toml
├── config.default.yaml
├── README.md
│
├── jarvis/
│   ├── __init__.py
│   ├── __main__.py              # Entry point
│   ├── config.py                # Config loader (YAML)
│   │
│   ├── audio/
│   │   ├── listener.py          # Mic input, VAD, wake word
│   │   ├── transcriber.py       # STT (faster-whisper)
│   │   └── speaker.py           # TTS (edge-tts / OpenAI)
│   │
│   ├── agent/
│   │   ├── loop.py              # Claude agent loop
│   │   ├── context.py           # System context injection
│   │   ├── memory.py            # Conversation history + persistence
│   │   └── safety.py            # Confirmation gates, action classification
│   │
│   ├── tools/
│   │   ├── registry.py          # Tool registration + dispatch
│   │   ├── system.py            # Volume, brightness, WiFi, BT, dark mode
│   │   ├── apps.py              # Open, close, switch apps
│   │   ├── browser.py           # Safari/Chrome automation
│   │   ├── files.py             # File operations
│   │   ├── calendar.py          # EventKit wrapper
│   │   ├── contacts.py          # Contacts framework wrapper
│   │   ├── clipboard.py         # NSPasteboard operations
│   │   ├── shell.py             # Shell command execution (gated)
│   │   ├── vision.py            # Screenshot + Claude Vision
│   │   └── notifications.py     # macOS notifications
│   │
│   ├── plugins/
│   │   ├── loader.py            # Dynamic plugin loading
│   │   ├── base.py              # Plugin base class
│   │   └── builtin/
│   │       ├── spotify.py
│   │       ├── pomodoro.py
│   │       └── shortcuts.py     # User-defined command chains
│   │
│   └── utils/
│       ├── applescript.py       # AppleScript runner helper
│       ├── permissions.py       # Permission checker
│       └── logging.py           # Audit logger
│
├── tests/
│   ├── test_agent_loop.py
│   ├── test_tools/
│   └── test_audio/
│
└── plugins/                     # User custom plugins directory
```

---

## Dependencies

```toml
[project]
name = "jarvis"
requires-python = ">=3.11"

dependencies = [
    # Audio
    "sounddevice>=0.5",
    "numpy>=1.26",
    "faster-whisper>=1.1",
    "pvporcupine>=3.0",       # or openwakeword
    "edge-tts>=6.1",
    "silero-vad>=5.1",
    
    # AI
    "anthropic>=0.49",
    
    # macOS
    "pyobjc-core>=10.0",
    "pyobjc-framework-Cocoa>=10.0",
    "pyobjc-framework-Quartz>=10.0",
    "pyobjc-framework-ApplicationServices>=10.0",
    "pyobjc-framework-EventKit>=10.0",
    "pyobjc-framework-Contacts>=10.0",
    "pyobjc-framework-Vision>=10.0",
    
    # Utils
    "pynput>=1.7",            # Global hotkeys
    "aiosqlite>=0.20",
    "pyyaml>=6.0",
    "structlog>=24.0",
]
```

---

## Development Phases

### Phase 1 — Core Audio Pipeline (Week 1-2)
- [ ] Mic input with sounddevice
- [ ] VAD with silero-vad
- [ ] Wake word detection (Porcupine)
- [ ] STT with faster-whisper
- [ ] TTS with edge-tts
- [ ] Push-to-talk hotkey
- [ ] Basic conversation loop (no tools yet)

### Phase 2 — Claude Agent Integration (Week 3)
- [ ] Claude API with tool use
- [ ] Agent loop (multi-step)
- [ ] System context injection
- [ ] Conversation history management

### Phase 3 — macOS Control Tools (Week 4-6)
- [ ] System settings (volume, brightness, WiFi, BT, dark mode)
- [ ] App management (open, close, switch, list)
- [ ] File operations (find, move, delete, create)
- [ ] Clipboard operations
- [ ] Shell command execution (with safety gate)
- [ ] Notifications

### Phase 4 — Vision & Screen Awareness (Week 7-8)
- [ ] Screenshot capture (Quartz)
- [ ] Claude Vision analysis
- [ ] Apple Vision OCR
- [ ] AXUIElement inspection
- [ ] Context-aware responses

### Phase 5 — PIM Integration (Week 9)
- [ ] Calendar (EventKit)
- [ ] Contacts
- [ ] Reminders
- [ ] Notes (AppleScript)
- [ ] Browser automation

### Phase 6 — Plugin System (Week 10)
- [ ] Plugin base class
- [ ] Dynamic loader
- [ ] Built-in plugins (Spotify, Pomodoro)
- [ ] User plugin directory

### Phase 7 — Memory & Polish (Week 11-12)
- [ ] Persistent memory (SQLite)
- [ ] User preferences learning
- [ ] Command shortcuts/macros
- [ ] Error handling polish
- [ ] First-run setup wizard
- [ ] Audit logging

### Phase 8 — Advanced (Week 13+)
- [ ] Custom wake words
- [ ] Multi-language support
- [ ] Anthropic Computer Use integration
- [ ] Homekit/smart home plugin
- [ ] Menu bar app wrapper (rumps/PyObjC)

---

## Cost Estimate (API)

| Component | Cost |
|-----------|------|
| Claude Sonnet (main brain) | ~$3/1M input, $15/1M output tokens |
| Claude Vision (screenshots) | ~$3-5 per 100 screenshots |
| Porcupine wake word | Free tier (3 keywords) |
| faster-whisper | Free (local) |
| edge-tts | Free |
| **Total for moderate use** | **~$5-15/month** |

---

## Example Interactions

```
You: "Hey Jarvis"
JARVIS: *chime* "Listening."

You: "What am I working on?"
JARVIS: *takes screenshot, reads context*
       "You're in VS Code editing main.py in the jarvis project.
        The file has a syntax error on line 42 — missing closing parenthesis."

You: "Fix it"
JARVIS: *uses AX API to navigate to line 42, inserts missing paren*
       "Fixed. The closing parenthesis was missing on the function call."

You: "Play some focus music and set Do Not Disturb"
JARVIS: "Playing your Focus playlist on Spotify. Do Not Disturb is now on."

You: "What meetings do I have tomorrow?"
JARVIS: "You have two meetings tomorrow:
        10am — standup with the team
        2pm — one-on-one with Sarah"

You: "Delete all .tmp files from Downloads"
JARVIS: "I found 7 .tmp files in Downloads, totaling 23MB. Should I delete them?"
You: "Yes"
JARVIS: "Done. 7 files moved to Trash."
```
