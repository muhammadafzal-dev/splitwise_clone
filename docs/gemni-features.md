┌──────────────────────────┬──────────────────────────────────────────────────────────────────────┬────────┐
│ Feature │ What It Does │ Effort │
├──────────────────────────┼──────────────────────────────────────────────────────────────────────┼────────┤
│ Git checkpointing │ Auto-creates git snapshot before file edits, /restore to undo │ Medium │
├──────────────────────────┼──────────────────────────────────────────────────────────────────────┼────────┤
│ CODEMATE.md context file │ Auto-read project instructions from root file (like GEMINI.md) │ Low │
├──────────────────────────┼──────────────────────────────────────────────────────────────────────┼────────┤
│ Sandbox mode │ Restrict file writes to project directory only │ Low │
├──────────────────────────┼──────────────────────────────────────────────────────────────────────┼────────┤
│ Streaming responses │ Real-time token-by-token output instead of waiting for full response │ Medium │
├──────────────────────────┼──────────────────────────────────────────────────────────────────────┼────────┤
│ JSONL headless mode │ codemate --headless "fix the bug" for CI/CD scripting │ Medium │
└──────────────────────────┴──────────────────────────────────────────────────────────────────────┴────────┘

Medium Impact (nice to have)

┌─────────────────────────────┬─────────────────────────────────────────────────────────┬────────┐
│ Feature │ What It Does │ Effort │
├─────────────────────────────┼─────────────────────────────────────────────────────────┼────────┤
│ MCP support │ Let users plug in custom tool servers │ High │
├─────────────────────────────┼─────────────────────────────────────────────────────────┼────────┤
│ Multi-stage edit correction │ If find-replace fails, AI retries with refined match │ Medium │
├─────────────────────────────┼─────────────────────────────────────────────────────────┼────────┤
│ Allow always │ "Allow this tool for rest of session" (not just yes/no) │ Low │
├─────────────────────────────┼─────────────────────────────────────────────────────────┼────────┤
│ Mouse support │ Click to place cursor in terminal │ Low │
└─────────────────────────────┴─────────────────────────────────────────────────────────┴────────┘

Low Priority (future)

┌──────────────────────┬───────────────────────────────────────┬───────────┐
│ Feature │ What It Does │ Effort │
├──────────────────────┼───────────────────────────────────────┼───────────┤
│ GitHub Action │ @codemate in PRs/issues for AI review │ High │
├──────────────────────┼───────────────────────────────────────┼───────────┤
│ VS Code extension │ IDE integration with native diffs │ Very High │
├──────────────────────┼───────────────────────────────────────┼───────────┤
│ OAuth authentication │ Google OAuth for Gemini free tier │ Medium │
├──────────────────────┼───────────────────────────────────────┼───────────┤
│ Docker sandbox │ Full container isolation │ Medium │
└──────────────────────┴───────────────────────────────────────┴───────────┘
