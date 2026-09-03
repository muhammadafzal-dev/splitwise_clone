# Google OAuth Learning Playground Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a standalone React/Vite application that teaches Google sign-in versus incremental Google Calendar authorization.

**Architecture:** A compact TypeScript React single page keeps demo state in `App.tsx` and uses one small OAuth helper module for PKCE and authorization URLs. Demo mode works immediately; real mode builds an Authorization Code + PKCE redirect and clearly marks the production backend-only token boundary.

**Tech Stack:** Vite, React, TypeScript, Vitest, Testing Library, CSS.

**Spec:** `docs/superpowers/specs/2026-08-31-google-oauth-learning-design.md`

## Global Constraints

- Use Authorization Code with PKCE; do not use implicit flow.
- Never put a Google client secret or a usable refresh token in browser code.
- Keep all tokens in memory; never use `localStorage`.
- Request `openid email profile` for identity and Calendar read-only access only through an explicit second action.
- Make the project educational, local, and runnable without Google credentials.

---

## File Structure

- `oauth-google-playground/src/oauth/pkce.ts`: PKCE and authorization URL pure functions.
- `oauth-google-playground/src/oauth/google.ts`: scopes, provider configuration, and callback parsing.
- `oauth-google-playground/src/App.tsx`: demo state, interaction orchestration, and all instructional UI.
- `oauth-google-playground/src/index.css`: responsive visual system.
- `oauth-google-playground/README.md`: local setup, Google Cloud steps, and production boundary.

### Task 1: Bootstrap the TypeScript React project

**Files:**
- Create: `oauth-google-playground/package.json`, `vite.config.ts`, `tsconfig.json`, `index.html`
- Create: `oauth-google-playground/src/main.tsx`, `src/App.tsx`, `src/index.css`
- Create: `oauth-google-playground/src/test/setup.ts`

**Interfaces:**
- Produces: Vite commands `npm run dev`, `npm run build`, and `npm test`.

- [ ] **Step 1: Create package scripts and dependencies**

```json
{"scripts":{"dev":"vite","build":"tsc -b && vite build","test":"vitest run"}}
```

- [ ] **Step 2: Add the Vite React entry point**

```tsx
createRoot(document.getElementById('root')!).render(<StrictMode><App /></StrictMode>);
```

- [ ] **Step 3: Verify the compiler and test runner start**

Run: `npm install && npm run build && npm test`

Expected: production build completes and Vitest exits successfully.

### Task 2: Implement and test PKCE plus Google URL helpers

**Files:**
- Create: `oauth-google-playground/src/oauth/pkce.ts`
- Create: `oauth-google-playground/src/oauth/google.ts`
- Create: `oauth-google-playground/src/oauth/google.test.ts`

**Interfaces:**
- Produces: `createPkcePair(): Promise<{ verifier: string; challenge: string }>`, `buildGoogleAuthorizationUrl(input)`, and `parseAuthorizationCallback(search)`.

- [ ] **Step 1: Write failing helper tests**

```ts
expect(buildGoogleAuthorizationUrl({ clientId: 'client', redirectUri: 'http://localhost:5173/', scopes: IDENTITY_SCOPES, state: 'state', codeChallenge: 'challenge' })).toContain('code_challenge=challenge');
expect(parseAuthorizationCallback('?code=code&state=state')).toEqual({ code: 'code', state: 'state', error: null });
```

- [ ] **Step 2: Run helper tests**

Run: `npm test -- src/oauth/google.test.ts`

Expected: tests fail because helpers are not implemented.

- [ ] **Step 3: Implement helpers**

```ts
export const IDENTITY_SCOPES = ['openid', 'email', 'profile'] as const;
export const CALENDAR_SCOPE = 'https://www.googleapis.com/auth/calendar.events.readonly';
```

Encode the authorization query with `response_type=code`, `code_challenge_method=S256`, `include_granted_scopes=true`, and optional incremental scopes.

- [ ] **Step 4: Verify helper tests**

Run: `npm test -- src/oauth/google.test.ts`

Expected: PASS.

### Task 3: Build the compact interactive learning screen

**Files:**
- Create: `oauth-google-playground/src/App.test.tsx`
- Modify: `oauth-google-playground/src/App.tsx`, `src/index.css`

**Interfaces:**
- Consumes: `IDENTITY_SCOPES`, `CALENDAR_SCOPE`, and PKCE helpers.
- Produces: a single accessible screen that lets the learner run sign-in, connect Calendar, and reset an in-memory demo.

- [ ] **Step 1: Write a failing UI test**

```ts
render(<App />);
await user.click(screen.getByRole('button', { name: /try google sign-in/i }));
expect(screen.getByText(/app session created/i)).toBeInTheDocument();
```

- [ ] **Step 2: Run the UI test**

Run: `npm test -- src/App.test.tsx`

Expected: test fails until the controls are wired.

- [ ] **Step 3: Implement the single-page demo**

```ts
const [signedIn, setSignedIn] = useState(false);
const [calendarConnected, setCalendarConnected] = useState(false);
```

Use clearly labeled synthetic token text, three sample calendar events, a short four-step flow, two purpose-specific buttons, and one production-security note. Keep all values in React state.

- [ ] **Step 4: Verify the UI behavior**

Run: `npm test -- src/App.test.tsx && npm run build`

Expected: PASS.

### Task 4: Add optional real-mode wiring and concise documentation

**Files:**
- Create: `oauth-google-playground/.env.example`
- Create: `oauth-google-playground/README.md`
- Modify: `oauth-google-playground/src/App.tsx`

**Interfaces:**
- Consumes: `VITE_GOOGLE_CLIENT_ID`, OAuth helpers.
- Produces: opt-in browser redirect action and configuration instructions.

- [ ] **Step 1: Add a test for incomplete real configuration**

```ts
expect(getGoogleClientId({})).toBeNull();
```

- [ ] **Step 2: Implement the real-mode redirect boundary**

```ts
window.location.assign(buildGoogleAuthorizationUrl({ clientId, redirectUri: window.location.origin + window.location.pathname, scopes, state, codeChallenge }));
```

Keep PKCE verifier in `sessionStorage` only for the learning redirect and state clearly that code exchange belongs on a backend in production.

- [ ] **Step 3: Write setup documentation**

Document Google Cloud OAuth consent screen, web-client redirect URI, minimal/incremental scopes, local `.env` setup, demo mode, and the recommended backend exchange/session pattern.

- [ ] **Step 4: Run final verification**

Run: `npm test && npm run build`

Expected: all tests pass and `dist/` is produced.
