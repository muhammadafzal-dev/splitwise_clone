# Supabase + Google OAuth Setup Guide
> Reusable setup steps for any Next.js project using Supabase Auth with Google OAuth.

---

## Stack
- Next.js 14 (App Router)
- @supabase/supabase-js v2.100+
- @supabase/ssr

---

## Step 1 — Create Supabase Project

1. Go to supabase.com → New Project
2. Choose org, name, and DB password
3. Wait ~2 min for provisioning
4. Go to **Settings → General** → copy **Project URL**
5. Go to **Settings → API Keys → Publishable and secret API keys** → copy **Publishable key**

### .env.local
```
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sb_publishable_...
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

> Note: Supabase now uses `sb_publishable_` prefix for anon keys (new format as of 2025).
> Use the **Publishable key** (not the Legacy anon key) with supabase-js v2.100+.

---

## Step 2 — Run DB Migrations

Go to **SQL Editor** in Supabase Dashboard and run your schema SQL.

Typical base tables for any auth-enabled app:

```sql
-- Profiles (extends auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  created_at timestamp with time zone default timezone('utc', now())
);
alter table public.profiles enable row level security;
create policy "Users own their profile"
  on public.profiles for all using (auth.uid() = id);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

---

## Step 3 — Google OAuth Setup

### Part A — Google Cloud Console

1. Go to console.cloud.google.com → New Project
2. **APIs & Services → OAuth consent screen**
   - User type: External → Create
   - Fill in App name, support email, developer email
   - Save and Continue through all steps (no extra scopes needed)
3. **APIs & Services → Credentials → + Create Credentials → OAuth 2.0 Client ID**
   - Application type: Web application
   - Authorized redirect URIs:
     ```
     https://YOUR-PROJECT-REF.supabase.co/auth/v1/callback
     ```
   - Create → copy **Client ID** and **Client Secret**

### Part B — Supabase Dashboard

1. Authentication → Providers → Google → Enable
2. Paste Client ID and Client Secret → Save

---

## Step 4 — Auth URL Configuration

Supabase → **Authentication → URL Configuration**:

| Setting | Local Dev | Production |
|---|---|---|
| Site URL | `http://localhost:3000` | `https://your-app.vercel.app` |
| Redirect URLs | `http://localhost:3000/auth/callback` | `https://your-app.vercel.app/auth/callback` |

> When deploying to production, update both values here AND in Google Cloud Console
> (add the production redirect URI to the OAuth 2.0 client).

---

## Step 5 — Supabase Client Code (Next.js App Router)

### Browser client — `lib/supabase/client.ts`
```typescript
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

### Server client — `lib/supabase/server.ts`
```typescript
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export function createClient() {
  const cookieStore = cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll() },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {}
        },
      },
    }
  )
}
```

### OAuth callback route — `app/auth/callback/route.ts`
```typescript
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  if (code) {
    const supabase = createClient()
    await supabase.auth.exchangeCodeForSession(code)
  }
  return NextResponse.redirect(`${origin}/dashboard`)
}
```

### Sign in with Google (client component)
```typescript
const supabase = createClient()
await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: { redirectTo: `${window.location.origin}/auth/callback` },
})
```

### Sign out
```typescript
await supabase.auth.signOut()
```

---

## Step 6 — Middleware (route protection)

`middleware.ts` at project root:
```typescript
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return request.cookies.getAll() },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value))
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )
  const { data: { user } } = await supabase.auth.getUser()
  const url = request.nextUrl.clone()
  const protectedRoutes = ['/dashboard', '/settings', '/profile']
  const isProtected = protectedRoutes.some(r => url.pathname.startsWith(r))
  if (isProtected && !user) {
    url.pathname = '/'
    return NextResponse.redirect(url)
  }
  return supabaseResponse
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)'],
}
```

---

## Common Gotchas

| Problem | Fix |
|---|---|
| Build fails with "Invalid supabaseUrl" | Use a valid URL format in `.env.local` even as placeholder: `https://placeholder.supabase.co` |
| Server pages pre-render and crash | Add `export const dynamic = 'force-dynamic'` to pages that use Supabase server client |
| Old `eyJ...` key vs new `sb_publishable_` | Use supabase-js v2.100+ for new key format. Both work but use Publishable key going forward |
| Google redirect URI mismatch | Make sure the URI in Google Cloud Console exactly matches Supabase's callback URL |
| Profile not created on signup | Check the `handle_new_user` trigger exists and function has `security definer` |
