# Agent Research: Codex CLI vs Gemini CLI vs CodeMate

> Deep technical analysis of open-source coding agents to guide CodeMate improvements.

## Repos (cloned locally)

| Agent | Path | Language | Stars |
|-------|------|----------|-------|
| Codex CLI | `../codex/` | Rust (primary) + Node.js thin wrapper | ~30k |
| Gemini CLI | `../gemini-cli/` | TypeScript / Node.js | ~60k |
| CodeMate | `../codeMate/` | Python | ours |

---

## Problem Statement (Our Issues)

1. **Slow startup** — 15-20 seconds vs Codex's instant start
2. **Token explosion** — reaches context limit quickly
3. Both root in Python's heavy import chain + our large system prompt + rules injection

---

## 1. Startup Time Analysis

### Codex CLI — Near-Instant Startup

**Root cause of speed: It's compiled Rust.**

```
User types `codex`
  ↓
Compiled binary loads (no interpreter, no JIT)
  ↓
arg0_dispatch_or_else()  ← 1 function call
  ↓
clap arg parsing         ← pure struct deserialization
  ↓
First TUI frame renders  ← ratatui
```

Key optimizations:
- `lto = "fat"` — full cross-crate link-time optimization (76 crates merged)
- `codegen-units = 1` — maximum optimization
- `strip = true` — minimal binary size
- No module resolution, no interpreter warmup
- **V8 embedded directly** — JS REPL doesn't spawn `node`, it's compiled in

### Gemini CLI — Fast via Code Splitting

**Root cause of speed: esbuild code splitting.**

```
User types `gemini`
  ↓
Node.js starts (~50ms)
  ↓
Loads thin `bundle/gemini.js` only
  ↓
Heavy modules (React/Ink UI, full SDK, tool registry)
loaded lazily on first use via dynamic import()
```

Key:
- `esbuild` with `splitting: true` — creates multiple `.js` chunks
- Entry bundle is tiny; Ink/React UI, full Gemini SDK loaded only when needed
- `--version` or `--help` resolves in milliseconds
- Build-time constant inlining: `CLI_VERSION`, sandbox image tag = zero runtime lookups
- Optional native deps (`node-pty`, `keytar`) don't block startup if missing

### CodeMate — Why It's Slow (15-20s)

Python's import system is the bottleneck. On `python -m src.main`:

```python
import litellm          # ~8-12s alone — imports boto3, openai, anthropic, etc.
import rich             # ~0.5s
import prompt_toolkit   # ~0.5s
# + loading config, rules, CLAUDE.md, skills, memories...
```

**LiteLLM is the #1 culprit.** It imports every provider SDK on startup even if you only use one.

---

## 2. Token Efficiency Analysis

### Codex CLI — Layered Context Strategy

**System prompt is NOT monolithic** — assembled from components:

```
Base instructions (lean)
  + AGENTS.md files (scoped to working directory hierarchy)
  + Skill instructions (XML-tagged, only active skills)
  + Turn-level context (injected at first turn only)
```

**Context compaction** (`codex-rs/core/src/compact.rs`):
- Triggered when approaching token limit
- Spawns a separate LLM call to summarize old history
- Replaces full history with: `[summary] + [recent N messages]`
- Falls back to progressively removing oldest items if compaction itself fails

**Tool output capping**:
- Shell stdout/stderr capped at 8KB for history retention
- Live streaming capped at 10,000 delta events

**WebSocket incremental payloads** (huge optimization):
- Primary transport: WebSocket (not HTTP)
- Only sends *changed* input items each turn (not full conversation)
- Connection prewarm: sends `generate=false` request to pre-establish connection before first prompt

### Gemini CLI — Multi-Stage Context Protection

**Token limit: 1M tokens** (Gemini's huge context window helps)

**5-stage cascade when approaching limit:**

1. **JIT Context Loading** — `jit_context` tool: model pulls files on demand, not upfront
2. **Tool Output Summarization** — verbose command output summarized by flash model before going into history
3. **Chat Compression** — flash model summarizes full conversation history
4. **Tool Output Masking** — replaces stored tool results with placeholder text
5. **Overflow Signal** — yields `ContextWindowWillOverflow` event, halts gracefully

**Loop detection** — auto-injects recovery message if model repeats same tool call

**IDE context delta encoding** — only sends changes since last turn, not full IDE state

### CodeMate — What's Consuming Tokens

1. **Giant system prompt** — `SYSTEM_PROMPT` in `agent.py` is ~175 lines of dense text
2. **ALL rules injected upfront** — `~/.claude/rules/` has 12+ files loaded at init
3. **Skills injected per-message** — not just at start, added as system messages each turn
4. **No compaction** — `trim_messages` is basic; no LLM-based summarization
5. **No tool output capping** — a large `run_command` result goes fully into history

---

## 3. Tool System Design

### Codex CLI Tools

| Tool | Key Feature |
|------|-------------|
| `apply_patch` | Custom diff format — simpler for LLMs than unified diff |
| `shell` | OS-level sandboxing (macOS seatbelt, Linux landlock+seccomp) |
| `grep_files` | Uses `ripgrep` subprocess, 30s timeout, max 2000 results |
| `js_repl` | V8 embedded directly — no subprocess for JS |
| `tool_search` | BM25 semantic search over available tools |
| `plan` | Structured task planning (renders in TUI) |
| `agent_jobs` | Spawn sub-agents on CSV batches |

**Parallel execution**: `RwLock` pattern — read tools run concurrently, write tools serialize.

### Gemini CLI Tools

| Tool | Key Feature |
|------|-------------|
| `edit` | 40KB implementation — exact string matching, diff display |
| `jit_context` | On-demand file loading for large codebases |
| `web_search` | Google Search grounding (not DuckDuckGo) |
| `memory` | GEMINI.md management tool |
| `write_todos` | Built-in todo tracking |
| `enter_plan_mode` | Switches agent to plan-only mode |

**Parallel execution**: Every tool gets auto-injected `wait_for_previous: boolean` parameter — model explicitly controls parallelism.

**Key insight**: `wait_for_previous` is brilliant — the model decides "read file A and file B simultaneously" by setting `wait_for_previous: false` on the second call.

### CodeMate Tools

Good set of tools but missing:
- No parallel execution
- No tool output capping/summarization
- No `apply_patch` style editing (only `edit_file` find-replace)
- No `jit_context` (lazy file loading)
- `web_search` uses DuckDuckGo (limited vs Google)

---

## 4. Permission & Sandbox System

### Codex CLI — 5-Level Approval + OS Sandbox

```
Approval modes:
  Never / OnFailure / OnRequest / UnlessTrusted / Granular

Sandbox layers:
  macOS: sandbox-exec (Seatbelt profiles)
  Linux: Landlock filesystem + seccomp syscall filtering
  Windows: restricted token
```

**Shell environment sanitization**: Strips all `*KEY*`, `*SECRET*`, `*TOKEN*` vars automatically — credentials can't leak to child processes.

### Gemini CLI — 4 Modes + Docker

```
ApprovalMode: DEFAULT / AUTO_EDIT / YOLO / PLAN

Sandbox: Docker/Podman container OR macOS seatbelt
```

**Saved policies** persist to `~/.gemini/config.json` — never ask again for trusted commands.

**Plan mode** restricts tool execution to reads + plan file writes only.

### CodeMate

- Basic permission system: `needs_approval` → `ask_permission`
- Sandbox: path-based (blocks writes outside project) — no OS-level isolation
- No environment variable sanitization
- No saved policies (each session starts fresh)

---

## 5. Architecture Patterns to Steal

### From Codex CLI

| Pattern | Implementation | Benefit for CodeMate |
|---------|---------------|---------------------|
| Lazy provider loading | Don't import litellm at top-level; use `importlib` on first use | **Eliminates 8-12s startup** |
| Tool output byte cap | Cap shell/command output at 8KB for history | Prevents context explosion |
| Compaction with LLM | Summarize old history with cheap model | Extends usable session length |
| WebSocket transport | Persistent connection, send only deltas | Reduces latency per turn |
| AGENTS.md scoping | Load instructions scoped to directory | Leaner context per project |

### From Gemini CLI

| Pattern | Implementation | Benefit for CodeMate |
|---------|---------------|---------------------|
| `wait_for_previous` on tools | Inject parallelism parameter into tool schemas | Speed up multi-file tasks |
| JIT context loading | Add `load_context` tool for on-demand file reading | Don't pre-load large repos |
| Loop detection | Track repeated tool calls; inject recovery message | Prevent infinite loops |
| Flash model for compression | Use cheap model to summarize history | Cost-effective compaction |
| Conditional system prompt sections | Only include relevant sections based on context | Smaller system prompts |
| `GEMINI.md`-style memory | Already have `CODEMATE.md` — improve injection | |
| Tool output masking | Replace stored large results with `[output truncated, N bytes]` | Reclaim tokens mid-session |
| Saved permission policies | Persist "always allow git commands" to config | Better UX |

---

## 6. Improvement Plan for CodeMate

### P0 — Fix Startup Time (Target: <2s)

**Problem**: LiteLLM imports all provider SDKs at module load time.

**Solution**: Lazy import LiteLLM

```python
# CURRENT (slow):
# src/llm/router.py
import litellm  # at top of file — triggers 8-12s import chain

# FIX (fast):
# Don't import at module level
class LLMRouter:
    def chat(self, messages, tools=None):
        import litellm  # first use only — cached by Python after that
        return litellm.completion(...)
```

Also defer:
- `ddgs` (DuckDuckGo) — import only when web_search is called
- `google.auth` — import only when Gemini OAuth is used
- Rules/skills loading — load after first prompt, not at startup
- Config validation — do minimal validation at startup, full validation lazily

### P1 — Fix Token Explosion

**A. Cap tool output sizes**

```python
# src/tools/shell.py — cap output at 8KB like Codex
MAX_OUTPUT_BYTES = 8_192

def execute(command: str, ...) -> str:
    result = run(command)
    if len(result) > MAX_OUTPUT_BYTES:
        half = MAX_OUTPUT_BYTES // 2
        return result[:half] + f"\n\n[...{len(result) - MAX_OUTPUT_BYTES} bytes truncated...]\n\n" + result[-half:]
    return result
```

**B. LLM-based history compaction** (like Codex + Gemini)

```python
# src/agent/context.py
def compact_history(messages, router):
    """Summarize old messages using a cheap/fast model."""
    # Keep system prompt + last 10 messages
    # Summarize everything in between
    # Replace with: [system] + [summary msg] + [last 10 msgs]
```

**C. Shrink system prompt — make it conditional**

```python
# Instead of always loading the 175-line prompt:
PROMPT_SECTIONS = {
    "core": ALWAYS_INCLUDED,
    "debugging": "include if 'bug' or 'error' in user_message",
    "building": "include if 'build' or 'create' in user_message",
    "git": "include if git repo detected",
    "security": "include if 'auth' or 'password' or 'secret' in user_message",
}
```

**D. Tool output masking** (reclaim tokens mid-session)

```python
# When approaching context limit, replace stored large tool results:
# "Error: file content..." (5000 chars) → "[read_file result: 5000 chars, truncated to save context]"
```

### P2 — Parallel Tool Execution

Add `wait_for_previous` parameter to all tool definitions:

```python
# Add to every tool definition:
"wait_for_previous": {
    "type": "boolean",
    "description": "If true, wait for previous tool calls to complete. Default false for read operations.",
}

# In registry.py — execute tool calls in parallel when wait_for_previous=False
import asyncio
from concurrent.futures import ThreadPoolExecutor
```

### P3 — Loop Detection

```python
# src/agent/agent.py
class LoopDetector:
    def __init__(self, window=5):
        self.recent_calls = []  # last N (tool_name, args_hash) pairs

    def check(self, tool_name, args) -> bool:
        """Returns True if loop detected."""
        key = (tool_name, hash(str(sorted(args.items()))))
        self.recent_calls.append(key)
        if len(self.recent_calls) > self.window:
            self.recent_calls.pop(0)
        # 3 identical calls in window = loop
        return self.recent_calls.count(key) >= 3
```

### P4 — JIT Context Loading

```python
# New tool: load_context
# Instead of reading all relevant files upfront,
# model calls this when it needs specific context
TOOL_DEFINITION = {
    "name": "load_context",
    "description": "Search codebase and load relevant files for current task. Use instead of reading files one by one.",
    "parameters": {
        "query": "What you're looking for",
        "max_files": "Max files to load (default 5)"
    }
}
```

### P5 — Saved Permission Policies

```python
# ~/.codemate/policies.json
{
    "always_allow": ["git", "npm test", "python -m pytest"],
    "always_deny": ["rm -rf"],
    "ask": []  # default for everything else
}
```

---

## 7. Quick Reference: Key Differences

| Feature | Codex | Gemini CLI | CodeMate |
|---------|-------|-----------|---------|
| Language | Rust | TypeScript | Python |
| Startup | <0.5s (compiled) | <1s (code split) | 15-20s |
| Token strategy | Byte caps + LLM compaction + WS deltas | JIT loading + masking + flash summary | Basic trim |
| Tool parallelism | RwLock (read=parallel) | `wait_for_previous` param | None |
| System prompt | Composable modules | Conditional sections | Single 175-line blob |
| Sandbox | OS-level (Landlock/Seatbelt) | Docker/macOS | Path-based only |
| History | SQLite + rollout files | JSON + proper-lockfile | JSON flat files |
| Loop detection | No | Yes (auto-recovery) | No |
| Context limit handling | LLM compaction | 5-stage cascade | trim_messages() |
| Saved permissions | Yes | Yes | No |

---

## 8. Files to Study

### Codex (startup + token efficiency)
- `codex/codex-rs/core/src/compact.rs` — LLM-based compaction
- `codex/codex-rs/core/src/context_manager/history.rs` — token management
- `codex/codex-rs/core/src/exec.rs` — output byte capping
- `codex/codex-rs/core/src/tools/` — parallel tool execution

### Gemini CLI (startup + token efficiency)
- `gemini-cli/esbuild.config.js` — code splitting (startup speed)
- `gemini-cli/packages/core/src/services/chatCompressionService.ts` — compression
- `gemini-cli/packages/core/src/services/loopDetectionService.ts` — loop detection
- `gemini-cli/packages/core/src/core/client.ts` — full agent loop (best reference)
- `gemini-cli/packages/core/src/tools/tools.ts` — `wait_for_previous` pattern
- `gemini-cli/packages/core/src/prompts/promptProvider.ts` — conditional system prompt

---

*Generated from live exploration of both repos. Last updated: 2026-03-21*
