# Project: GrabIt — Personal Video Downloader (YT / IG / FB)

> Mobile app for personal use. Download videos from YouTube, Instagram, Facebook to phone gallery. Sideload only, no store publish. Zero-cost stack.

---

## Vision

Solo-dev personal Android app that takes any YT / IG / FB video link → saves video file directly to phone gallery. No subscriptions, no ads, no app store. Sideload via APK. Built once, used forever.

**Constraints (hard)**
- Personal use only — no Play Store / App Store
- Zero monthly cost (no card-required services)
- Android first (skip iOS to avoid $99 Apple Dev fee)
- Reuse existing skills: React Native + Expo + Redux Toolkit

---

## Why this exist

- Existing free downloader apps: ad-heavy, broken often, request invasive permissions
- Browser sites (savefrom, ytdown.to, snapsave) work but: pop-up ads, no resume, no batch, no gallery save
- Want a clean personal tool, full control

---

## Legal reality

| Platform | Terms | Personal-use risk |
|---|---|---|
| YouTube | ToS forbids download w/o button | Low — personal, offline-only |
| Instagram | ToS forbids scraping | Low — personal use |
| Facebook | ToS forbids download | Low — personal use |

Apple Guideline 5.2.3 + Google Play both ban these apps → confirms sideload-only path.

---

## Stack decision

| Layer | Pick | Why |
|---|---|---|
| **Mobile** | React Native + Expo SDK 54 | Already proficient, Redux Toolkit preferred, EAS Build |
| **State** | Redux Toolkit + RTK Query | Existing preference |
| **Storage** | `expo-file-system` + `expo-media-library` | Battle-tested, saves to gallery |
| **Background dl** | `expo-background-task` (SDK 52+) | Survives app close |
| **HTTP** | RTK Query (built-in) | No extra dep |
| **Build** | `eas build --local` on Mac | Unlimited free APK |
| **Distribute** | APK sideload | Free, no store |

### Backend (the hard question)

Pure client-side extraction = **not viable**:
- YouTube PoToken / visitor data enforced late 2024 — breaks pure-JS libs constantly
- Instagram + Facebook rate-limit mobile IPs hard

Options ranked by free-tier durability:

1. **Cloudflare Tunnel + yt-dlp on Mac** — Mac runs Express + yt-dlp, exposed via free CF Tunnel. Works only when Mac on. **Cost: $0.**
2. **Oracle Cloud Always Free + cobalt Docker** — ARM 4-core/24GB VM, never expires. 1 hr setup. **Cost: $0.**
3. **Cloudflare Worker proxy** — 100k req/day free, wraps public cobalt instance. Lazy fallback. **Cost: $0.**
4. **WebView wrap of savefrom/ytdown** — render existing sites in app, intercept download URL. Brittle but no backend. **Cost: $0.**

**Decision: start with Option 1 (CF Tunnel + Mac).** If Mac-sleep annoying → migrate Option 2 (Oracle).

---

## Architecture (recommended)

```
┌──────────────────────────────────────────────────────────┐
│                      GrabIt App (Android)                │
│                                                          │
│  ┌──────────────┐   ┌──────────────┐   ┌─────────────┐  │
│  │ Paste URL    │ → │ RTK Query    │ → │ Download    │  │
│  │ from clipbd  │   │ /extract     │   │ Manager     │  │
│  └──────────────┘   └──────┬───────┘   └──────┬──────┘  │
│                            │                   │         │
└────────────────────────────┼───────────────────┼─────────┘
                             │                   │
                             ▼                   │
         ┌───────────────────────────────┐       │
         │   Cloudflare Tunnel (free)    │       │
         │   grabit.<your>.trycloudflare │       │
         └───────────────┬───────────────┘       │
                         │                       │
                         ▼                       │
         ┌───────────────────────────────┐       │
         │   Mac (or Oracle Free VM)     │       │
         │   ┌─────────────────────────┐ │       │
         │   │ Express /extract        │ │       │
         │   │ → yt-dlp --get-url      │ │       │
         │   │ → returns direct CDN URL│ │       │
         │   └─────────────────────────┘ │       │
         └───────────────┬───────────────┘       │
                         │                       │
                         │   { videoUrl, title } │
                         ▼                       │
                                                 │
                  ┌──────────────┐               │
                  │ YT/IG/FB CDN │◄──────────────┘
                  └──────────────┘
                        │
                        ▼ (bytes stream direct to phone)
                  ┌──────────────┐
                  │ Phone Gallery│
                  └──────────────┘
```

Phone hits backend → backend resolve direct URL → phone download direct from CDN. Backend bandwidth ≈ 0.

---

## Feature list (MVP)

- [ ] Paste URL (or auto-detect from clipboard)
- [ ] Detect platform (YT / IG / FB)
- [ ] Show preview: thumbnail, title, duration, available qualities
- [ ] Pick quality (highest by default)
- [ ] Download with progress bar
- [ ] Save to gallery
- [ ] Download history list
- [ ] Re-download from history
- [ ] Share sheet integration ("Share to GrabIt" from YT/IG/FB app)

### Later

- [ ] Batch download (paste multiple URLs)
- [ ] Audio-only mode (MP3 extract via yt-dlp)
- [ ] Subtitle download
- [ ] Playlist download

---

## Folder structure

```
grabit/
├── apps/
│   ├── mobile/           # Expo RN app
│   │   ├── src/
│   │   │   ├── store/    # Redux Toolkit + RTK Query
│   │   │   ├── screens/
│   │   │   ├── components/
│   │   │   └── lib/      # expo-file-system wrappers
│   │   └── app.json
│   └── api/              # Express + yt-dlp wrapper
│       ├── src/
│       │   ├── routes/extract.ts
│       │   └── lib/yt-dlp.ts
│       └── Dockerfile
└── docker-compose.yml
```

---

## Setup steps

1. **Backend (Mac local)**
   - `brew install yt-dlp`
   - `cd apps/api && npm i && npm run dev` (Express on :3000)
   - `brew install cloudflared`
   - `cloudflared tunnel --url http://localhost:3000` → get public URL

2. **Mobile**
   - `npx create-expo-app@latest mobile`
   - Add Redux Toolkit, RTK Query, expo-file-system, expo-media-library, expo-background-task
   - Set `API_URL` env to tunnel URL
   - `eas build --local --platform android` → APK
   - Transfer APK to phone, install

3. **Use**
   - Open YT/IG/FB app → share → GrabIt → tap download → done

---

## Backend-less option (research result, 2026-05-24)

Investigated wrapping existing browser downloaders (ytdown.to, savefrom, y2mate, snapinsta, fdown). Findings:

| Site | Platform | API pattern | Anti-bot | Stability | Verdict |
|---|---|---|---|---|---|
| **fdown.net** | FB | `POST /download.php` form → HTML parse | **None** | Stable years | ✅ Fire-and-forget |
| **y2mate.com** | YT | 2-step JSON: `/analyzeV2/ajax` → `/convertV2/index` | Cloudflare + cf_clearance | Breaks 3-6 mo | ⚠️ Need browser cookie warm-up |
| **snapinst.app** | IG | `POST /action2.php` form + CSRF token, returns obfuscated JS | Cloudflare + CSRF | Breaks ~monthly | ⚠️ Need JS deobfuscator port |
| **savefrom.net** | YT | Obfuscated JS, helper extension | Cloudflare | Breaks often | ❌ Hostile popunder ads |
| **snapsave.app** | FB/IG | Obfuscated JS eval | Cloudflare | Painful | ❌ |
| **fastdl.app** | IG | Form + token, obfuscated | Cloudflare | Breaks monthly | ⚠️ Better as WebView wrap |
| **getfvid** | FB | Form POST, HTML | None | Smaller, fragile | ✅ Backup for fdown |

### Practical "no backend" architecture

```
RN client
  ├─ FB → fdown.net direct POST (clean HTML parse)         ← stable
  ├─ FB fallback → getfvid
  ├─ IG → WebView wrap fastdl.app, sniff cdninstagram.com  ← needs ad blocking
  ├─ IG fallback → snapinst direct (needs JS deobfuscator)
  ├─ YT → WebView wrap y2mate (pre-warm Cloudflare cookie)
  └─ YT fallback → self-hosted yt-dlp (only when others fail)
```

### Trade-offs (no-backend route)

| Pro | Con |
|---|---|
| Truly $0, no VM, no Mac dependency | Maintenance treadmill — patch ~monthly |
| Phone download direct from CDN | Cloudflare cookie expiry, JS obfuscation rotates |
| No infra to manage | Popunder ad networks need aggressive blocking |
| FB works perfectly via fdown.net | YT most fragile — yt-dlp community fixes faster than solo dev |

### Recommendation

**Hybrid**: backend-less first (fdown for FB, WebView for YT/IG) → keep self-host yt-dlp as fallback for when sites break. App auto-detects failure, falls through chain.

Solo-dev personal use accepts the monthly-patch cost. Worst case = swap to backend route (Option A in stack section) in 1 hour.

---

## Reference repos (proven scrapers to port)

- [`Simatwa/fdown-api`](https://github.com/Simatwa/fdown-api) — fdown.net Python wrapper
- [`Jumpathy/snapinsta`](https://github.com/Jumpathy/snapinsta) — snapinst.app token + action2.php flow
- [`jerry08/Y2mateApi`](https://github.com/jerry08/Y2mateApi) — y2mate 2-step API
- [`karjok/snapsave`](https://github.com/karjok/snapsave) — snapsave + deobfuscation pattern
- [`x404xx/Insta-Down`](https://github.com/x404xx/Insta-Down) — IG scraper reference

---

## Open questions

- Port `fdown-api` Python → TS for direct call from RN? (1-2 hr)
- WebView ad-blocker: bundle EasyList domain set or write minimal denylist? (PropellerAds, Adsterra, AdMaven)
- iOS later via AltStore (7-day re-sign)? Defer.

---

## Final decisions (2026-05-24)

- **Monorepo**: `grabit/` with yarn workspaces (`apps/api`, `apps/mobile`)
- **Mobile**: React Native CLI (not Expo) — full native control
- **Backend host**: Render (free tier, no CC, 100s timeout, 100GB egress) + Docker yt-dlp
- **Per-platform**:
  - **FB** → `fdown.net` direct POST (no backend) + fallback to backend yt-dlp
  - **IG** → `snapinst.app` direct POST + JS deobfuscator port (no backend) + fallback
  - **YT** → backend yt-dlp via Render (`--get-url` mode, phone DL direct from CDN)
- **Cold start mitigation**: app pings `/health` on launch to warm Render
- **Distribution**: APK sideload, personal use only

---

## Status

- [x] Idea drafted (2026-05-24)
- [x] Research browser-site approach
- [x] Final stack decided
- [x] Monorepo scaffolded at `/Users/gsoft/Desktop/personal/my_dev/grabit`
- [x] Backend prototype (Express + yt-dlp + fdown + snapinst routes) — 11 unit tests pass
- [x] Render deploy config (Dockerfile + render.yaml)
- [x] Mobile scaffold (RN CLI + Redux Toolkit + RTK Query + navigation + RNFS + camera-roll) — TS clean
- [x] AndroidManifest permissions (storage / media / notifications)
- [x] Docker dev setup (`docker-compose.yml` + `Dockerfile.dev` + `.dockerignore`) — matches Render env exactly, no brew needed
- [ ] First successful download — start Docker Desktop → `docker compose up --build` → `yarn mobile:android`
