# Open-Source AI Coding Tools (Free Cursor/Windsurf Alternatives)

> Researched: March 2026

---

## VS Code Extensions

### 1. Continue.dev
- **Repo:** https://github.com/continuedev/continue
- **License:** Apache 2.0
- **LLM Support:** OpenAI, Anthropic, Gemini, Ollama (local/free), OpenRouter
- **Features:** Inline chat, autocomplete, codebase context, custom agents
- **Cost:** Free — pay per API call, or $0 with local Ollama
- **IDEs:** VS Code, JetBrains

### 2. Cline
- **Repo:** https://github.com/cline/cline
- **License:** Apache 2.0
- **LLM Support:** OpenAI, Anthropic, Google, OpenRouter, Ollama
- **Features:** Full agent mode, sub-agents, file creation, terminal, browser control
- **Cost:** Free extension — pay per API call or use free local models
- **IDEs:** VS Code

---

## Standalone Open-Source Editors

### 3. Void Editor
- **Site:** https://voideditor.com
- **Repo:** https://github.com/voideditor/void
- **License:** Open source (VS Code fork), YC-backed
- **LLM Support:** DeepSeek, Llama, Gemini, Qwen, Ollama — direct connection, no middleman
- **Features:** Cursor-like UI, full data privacy, VS Code settings migration
- **Cost:** Free
- **Status:** ⚠️ Development currently paused — features may degrade over time

### 4. Zed
- **Site:** https://zed.dev
- **License:** Open source (Rust-based)
- **LLM Support:** Anthropic, OpenAI, Google, Ollama (local)
- **Features:** GPU-accelerated performance, inline AI, multiplayer collaboration, agent panel
- **Cost:** Free forever tier; Pro $10/mo

---

## Terminal / CLI Tools

### 5. Aider
- **Repo:** https://github.com/Aider-AI/aider
- **License:** Apache 2.0
- **LLM Support:** GPT-4, Claude, Gemini, Ollama, any OpenAI-compatible API
- **Features:** Multi-file edits, auto git commits, architect mode, codebase-aware
- **Cost:** Fully free — use local models at $0

---

## Self-Hosted Server (Teams / Enterprise)

### 6. Tabby
- **Repo:** https://github.com/TabbyML/tabby
- **Site:** https://tabbyml.com
- **License:** Apache 2.0
- **LLM Support:** CodeLlama, StarCoder, other local coding models
- **Features:** Code completion, chat, IDE plugins (VS Code, JetBrains), enterprise SSO, audit logs
- **Cost:** Free self-hosted; runs on consumer GPUs
- **Stars:** ~32k GitHub stars — actively maintained

---

## Quick Comparison

| Tool         | Type             | Local LLM     | Agent Mode | Status        |
|--------------|------------------|---------------|------------|---------------|
| Continue.dev | VS Code ext      | Yes (Ollama)  | Partial    | Active        |
| Cline        | VS Code ext      | Yes (Ollama)  | Full       | Active        |
| Void Editor  | Standalone IDE   | Yes (Ollama)  | Yes        | Paused        |
| Zed          | Standalone IDE   | Yes (Ollama)  | Yes        | Active        |
| Aider        | CLI              | Yes (Ollama)  | Yes        | Active        |
| Tabby        | Self-hosted svr  | Yes (local)   | No         | Active        |

---

## Running Fully Free (Zero Cost Setup)

Use **Ollama** + a free coding model + any tool above:

```bash
# Install Ollama
brew install ollama

# Pull a free coding model
ollama pull qwen2.5-coder    # Recommended
ollama pull deepseek-coder
ollama pull codellama

# Then connect via Continue.dev or Cline in VS Code
```

**Best free coding models via Ollama:**
- `qwen2.5-coder` — strong general coding
- `deepseek-coder-v2` — strong reasoning + code
- `codellama` — Meta's classic coding model

---

## Recommendations

| Use Case | Pick |
|----------|------|
| Zero cost, local only | Continue.dev + Ollama |
| Best agent experience | Cline |
| Best editor feel | Zed |
| Team / on-prem | Tabby |
| Terminal / git workflow | Aider |
