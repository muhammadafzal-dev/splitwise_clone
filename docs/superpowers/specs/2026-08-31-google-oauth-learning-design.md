# Google OAuth Learning Playground — Design

## Goal

Create a standalone React/Vite project, `oauth-google-playground`, that teaches the distinction between Google sign-in (identity) and Google API access (authorization). The project must run immediately in a simulated demonstration mode and also support a real Google OAuth client configured locally.

## Scope

The app presents two deliberate paths:

1. **Continue with Google** requests `openid`, `email`, and `profile`. It demonstrates creating or locating an application user and then establishing an application session.
2. **Connect Google Calendar** requests a Calendar read-only scope only when the user chooses to connect the feature. It demonstrates incremental authorization and calling a Google API with an access token.

The page includes a stepper showing authorization-code flow with PKCE, an explanation of the current step, a scope/permission panel, and a token inspector. Demo tokens are clearly synthetic and no real Google data is shown in demo mode.

## Architecture

The application is a client-side teaching tool, separated into:

- `oauth/`: PKCE generation, OAuth URL construction, callback parsing, and provider configuration.
- `demo/`: a deterministic in-browser simulator which moves the learning flow through the same conceptual stages without contacting Google.
- `components/`: flow visualization, action cards, permission view, token inspector, and teaching panels.
- `App.tsx`: composition and transient page state only.

An environment file provides `VITE_GOOGLE_CLIENT_ID`, plus an optional switch for real mode. The callback URL is the Vite app origin. Real redirect/callback logic is displayed and implemented for the browser learning demo, but the interface explicitly describes that a production app should exchange authorization codes and retain refresh tokens on a trusted backend.

## User Flow

1. The visitor chooses **Try the safe demo** or enables real Google mode with configuration.
2. They select **Continue with Google**. The UI displays the requested identity scopes and shows the authorization redirect / PKCE stages.
3. On completion, a mock or Google identity profile is shown with an app-session marker. The access token is categorized as temporary Google API authorization, not the app session.
4. The visitor can select **Connect Calendar**. This requests the optional Calendar scope and displays its incremental permission stage.
5. In demo mode, sample calendar data becomes available. In real mode, the app can make a narrowly scoped Calendar `events` request with the access token; errors are explained without exposing secrets.
6. The visitor can disconnect Calendar and reset the exercise. Reset clears in-memory state.

## Security and Constraints

- Use Authorization Code with PKCE for browser redirects; no implicit flow.
- Never include a client secret in browser code or environment variables with the `VITE_` prefix.
- Keep all demonstration tokens in memory, never `localStorage`.
- Never expose or simulate a usable refresh token in the browser.
- Request minimal scopes and use incremental consent for Calendar.
- Describe backend token exchange/storage as the production path, including HTTP-only application session cookies.
- The project is educational rather than a production authentication service. A server component is intentionally out of scope.

## Verification

- TypeScript build succeeds.
- Unit tests cover PKCE value generation, authorization URL parameters, callback parsing, and scope composition.
- The demo’s identity and Calendar paths can be exercised manually without external credentials.
- The README documents setup, Google Cloud redirect URI registration, scopes, and the production-oriented backend boundary.
