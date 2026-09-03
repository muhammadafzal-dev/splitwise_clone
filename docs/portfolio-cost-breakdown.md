# Portfolio Project Cost Breakdown

**Purpose:** Free vs paid cost analysis for building portfolio projects.
**Last Updated:** March 2025

---

## Fully Free Stack (Zero Cost)

### Hosting & Deployment

| Service | What You Get Free |
|---------|------------------|
| Vercel | Next.js/React frontends, unlimited personal projects |
| Railway | $5 credit/month — backend services |
| Render | Web services, cron jobs (free tier) |
| Cloudflare Workers | 100K requests/day free |
| Supabase | PostgreSQL + auth + storage (free tier) |
| Neon | Serverless PostgreSQL with pgvector (free tier) |
| PlanetScale | MySQL serverless (free tier) |
| GitHub Pages | Static sites |

### AI APIs (Free Tiers)

| Service | Free Tier Details |
|---------|------------------|
| Groq | Fast LLM inference (LLaMA, Mixtral) — generous free tier |
| Google Gemini API | 15 requests/min free |
| Hugging Face Inference API | Free tier available |
| Ollama | Completely free — runs models locally |
| Cohere | Embeddings + generation free tier |

### Tools & Services (Free)

| Service | Purpose |
|---------|---------|
| GitHub | Code hosting + CI/CD via Actions |
| LangSmith | LLM observability (free tier) |
| Upstash | Redis + vector DB (free tier) |
| Clerk | Auth — free up to 10K MAU |
| Resend | Email — 3K emails/month free |

---

## Paid (But Affordable for Portfolio)

### LLM APIs (Pay Per Use)

| Model | Cost | Estimated Monthly (demo traffic) |
|-------|------|----------------------------------|
| OpenAI GPT-4o | ~$2.50/1M input tokens | $5-15/month |
| Anthropic Claude Sonnet | ~$3/1M input tokens | $5-15/month |
| OpenAI Whisper (speech) | $0.006/min | $1-5/month |

### Hosting (When You Need More)

| Service | Cost |
|---------|------|
| Vercel Pro | $20/month |
| Railway paid | $5-20/month |
| AWS/GCP (after free tier) | $0-10/month |

### Other

| Item | Cost |
|------|------|
| Domain name (Namecheap/Porkbun) | $8-12/year |
| .dev domain | $12/year |
| Qdrant Cloud (vector DB) | Free tier, paid from $25/month |
| Pinecone | Free tier (1 index), paid from $70/month |

---

## Recommended Free Stack Per Project Type

### RAG System
- **DB:** Neon (pgvector, free)
- **LLM:** Groq or Gemini API (free tier)
- **Deploy:** Vercel
- **Estimated cost:** $0/month

### Multi-Agent App
- **LLM:** Groq free tier
- **Observability:** LangSmith free tier
- **Deploy:** Vercel or Railway
- **Estimated cost:** $0/month

### MCP Server
- **Deploy:** Railway free tier
- **Code:** GitHub
- **LLM:** Claude API (~$5/month usage for demos)
- **Estimated cost:** ~$5/month

### Full Stack SaaS
- **DB + Auth:** Supabase (free)
- **Frontend:** Vercel (free)
- **Auth:** Clerk (free up to 10K MAU)
- **Email:** Resend (free tier)
- **Payments:** Stripe (test mode — free)
- **Estimated cost:** $0/month to start

---

## One-Time Cloud Credits (New Accounts)

| Provider | Credit |
|----------|--------|
| AWS Free Tier | 12 months free on many services |
| GCP | $300 free credits |
| Azure | $200 free credits |

Use these for any compute-heavy workloads (GPU inference, large storage, etc.).

---

See also:
- [portfolio-project-ideas-2025-2026.md](portfolio-project-ideas-2025-2026.md) — Which projects are worth building
