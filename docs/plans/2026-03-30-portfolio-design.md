# Portfolio Website — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a modern, animated portfolio website with a full admin panel so the user can log in and update all content (projects, skills, about, experience, etc.) without touching code.

**Architecture:** Next.js 15 App Router with Supabase as the backend (auth + PostgreSQL + file storage). Public portfolio pages are server-rendered for SEO. Admin dashboard is a protected route group with Supabase Auth (email/password). All portfolio content is stored in Supabase tables and fetched at request time with ISR/revalidation for performance.

**Tech Stack:**
- **Framework:** Next.js 15 (App Router, TypeScript)
- **Styling:** Tailwind CSS 4 + Shadcn/UI components
- **Animations:** Framer Motion
- **Backend:** Supabase (Auth, PostgreSQL, Storage)
- **Deployment:** Vercel (free tier)
- **Icons:** Lucide React

---

## Database Schema (Supabase)

```sql
-- Profile (single row — the portfolio owner)
CREATE TABLE profile (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  title TEXT NOT NULL,            -- "Frontend Developer"
  bio TEXT,
  avatar_url TEXT,
  resume_url TEXT,
  email TEXT,
  github TEXT,
  linkedin TEXT,
  twitter TEXT,
  location TEXT,
  available_for_hire BOOLEAN DEFAULT true,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Skills
CREATE TABLE skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  icon_url TEXT,                  -- or icon name from lucide/devicons
  category TEXT NOT NULL,         -- "Frontend", "Backend", "Tools", etc.
  proficiency INT DEFAULT 80,    -- 0-100
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Projects
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT NOT NULL,
  long_description TEXT,
  thumbnail_url TEXT,
  live_url TEXT,
  github_url TEXT,
  tech_stack TEXT[],             -- array of tech names
  featured BOOLEAN DEFAULT false,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Experience
CREATE TABLE experience (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company TEXT NOT NULL,
  role TEXT NOT NULL,
  description TEXT,
  start_date DATE NOT NULL,
  end_date DATE,                 -- null = current
  company_logo_url TEXT,
  location TEXT,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Education
CREATE TABLE education (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  institution TEXT NOT NULL,
  degree TEXT NOT NULL,
  field TEXT,
  start_date DATE NOT NULL,
  end_date DATE,
  logo_url TEXT,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Testimonials
CREATE TABLE testimonials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  role TEXT,
  company TEXT,
  content TEXT NOT NULL,
  avatar_url TEXT,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Contact messages (from visitors)
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  subject TEXT,
  message TEXT NOT NULL,
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

---

## Project Structure

```
portfolio/
├── public/
│   └── images/
├── src/
│   ├── app/
│   │   ├── (public)/              # Public portfolio pages
│   │   │   ├── layout.tsx         # Public layout (navbar + footer)
│   │   │   ├── page.tsx           # Home / Hero
│   │   │   ├── about/page.tsx
│   │   │   ├── projects/
│   │   │   │   ├── page.tsx       # All projects grid
│   │   │   │   └── [slug]/page.tsx # Single project detail
│   │   │   └── contact/page.tsx
│   │   ├── (admin)/               # Protected admin routes
│   │   │   ├── layout.tsx         # Admin layout (sidebar + auth guard)
│   │   │   ├── admin/
│   │   │   │   ├── page.tsx       # Dashboard overview
│   │   │   │   ├── profile/page.tsx
│   │   │   │   ├── projects/
│   │   │   │   │   ├── page.tsx   # List + CRUD
│   │   │   │   │   └── [id]/page.tsx # Edit single project
│   │   │   │   ├── skills/page.tsx
│   │   │   │   ├── experience/page.tsx
│   │   │   │   ├── education/page.tsx
│   │   │   │   ├── testimonials/page.tsx
│   │   │   │   └── messages/page.tsx
│   │   ├── auth/
│   │   │   └── login/page.tsx     # Admin login page
│   │   ├── layout.tsx             # Root layout
│   │   └── globals.css
│   ├── components/
│   │   ├── public/                # Public-facing components
│   │   │   ├── navbar.tsx
│   │   │   ├── footer.tsx
│   │   │   ├── hero.tsx
│   │   │   ├── about-section.tsx
│   │   │   ├── skills-section.tsx
│   │   │   ├── projects-grid.tsx
│   │   │   ├── project-card.tsx
│   │   │   ├── experience-timeline.tsx
│   │   │   ├── testimonials-carousel.tsx
│   │   │   ├── contact-form.tsx
│   │   │   └── section-heading.tsx
│   │   ├── admin/                 # Admin components
│   │   │   ├── sidebar.tsx
│   │   │   ├── admin-header.tsx
│   │   │   ├── data-table.tsx
│   │   │   ├── image-upload.tsx
│   │   │   ├── form-field.tsx
│   │   │   └── stat-card.tsx
│   │   └── ui/                    # Shadcn components (auto-generated)
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── client.ts          # Browser client
│   │   │   ├── server.ts          # Server client
│   │   │   └── middleware.ts      # Auth middleware helper
│   │   ├── types.ts               # TypeScript types (from DB schema)
│   │   └── utils.ts               # cn() helper etc.
│   └── middleware.ts              # Next.js middleware (protect /admin)
├── supabase/
│   └── migrations/                # SQL migration files
├── .env.local                     # Supabase keys
├── next.config.ts
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

---

## Public Pages Design

### Home Page (Single-page scroll)
1. **Hero** — Name, title, tagline, CTA buttons (View Work / Contact), animated gradient background or particles
2. **About** — Photo, short bio, available-for-hire badge
3. **Skills** — Categorized grid with icons and proficiency bars, staggered fade-in
4. **Featured Projects** — 3-4 cards with hover effects, "View All" link
5. **Experience** — Vertical timeline with company logos
6. **Testimonials** — Carousel/marquee of quotes
7. **Contact** — Form (name, email, message) that saves to Supabase `messages` table

### Projects Page
- Filterable grid by tech stack
- Each card: thumbnail, title, description, tech badges
- Click opens `/projects/[slug]` detail page

### Project Detail Page
- Full description, screenshots gallery, tech stack, live/GitHub links
- "Next/Previous" navigation

### Animations (Framer Motion)
- Scroll-triggered fade-in/slide-up for each section
- Staggered children animations for grids
- Smooth page transitions
- Hover scale/glow on project cards
- Navbar blur + shrink on scroll

---

## Admin Dashboard Design

### Auth Flow
- `/auth/login` — email + password form (Supabase Auth)
- Middleware protects all `/admin/*` routes
- Single admin user (seeded in Supabase)
- No public registration

### Dashboard Pages
| Page | Functionality |
|------|--------------|
| `/admin` | Stats overview: total projects, messages (unread), skills count |
| `/admin/profile` | Edit name, title, bio, avatar, social links, resume upload |
| `/admin/projects` | Table with add/edit/delete, drag-to-reorder, image upload |
| `/admin/skills` | Grid with add/edit/delete, category grouping |
| `/admin/experience` | Timeline entries CRUD |
| `/admin/education` | Education entries CRUD |
| `/admin/testimonials` | Testimonials CRUD |
| `/admin/messages` | Inbox of contact form submissions, mark as read |

### Admin Features
- Image upload via Supabase Storage (drag & drop)
- Rich text editing for descriptions (simple markdown or textarea)
- Sort order drag-and-drop
- Real-time preview link ("View on site")
- Toast notifications for save/delete actions

---

## Implementation Tasks

### Task 1: Project Setup

**Files:**
- Create: `portfolio/package.json`
- Create: `portfolio/src/app/layout.tsx`
- Create: `portfolio/src/app/globals.css`
- Create: `portfolio/.env.local`

**Step 1: Create Next.js project**
```bash
cd /Users/muhammadafzal/Desktop/personal/my_dev
npx create-next-app@latest portfolio --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
```

**Step 2: Install dependencies**
```bash
cd portfolio
npm install @supabase/supabase-js @supabase/ssr framer-motion lucide-react sonner
npx shadcn@latest init
```

**Step 3: Install Shadcn components**
```bash
npx shadcn@latest add button card input textarea label dialog table badge dropdown-menu avatar separator sheet tabs toast
```

**Step 4: Set up env file**
Create `.env.local`:
```
NEXT_PUBLIC_SUPABASE_URL=your-project-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

**Step 5: Commit**
```bash
git init && git add . && git commit -m "chore: scaffold Next.js portfolio project with dependencies"
```

---

### Task 2: Supabase Setup

**Files:**
- Create: `supabase/migrations/001_initial_schema.sql`
- Create: `src/lib/supabase/client.ts`
- Create: `src/lib/supabase/server.ts`
- Create: `src/lib/types.ts`

**Step 1: Create Supabase project at supabase.com**
- Create new project
- Copy URL and anon key to `.env.local`
- Go to SQL Editor, run the full schema SQL from the "Database Schema" section above

**Step 2: Set up Row Level Security (RLS)**
```sql
-- Enable RLS on all tables
ALTER TABLE profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE experience ENABLE ROW LEVEL SECURITY;
ALTER TABLE education ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Public read access for portfolio content
CREATE POLICY "Public read" ON profile FOR SELECT USING (true);
CREATE POLICY "Public read" ON skills FOR SELECT USING (true);
CREATE POLICY "Public read" ON projects FOR SELECT USING (true);
CREATE POLICY "Public read" ON experience FOR SELECT USING (true);
CREATE POLICY "Public read" ON education FOR SELECT USING (true);
CREATE POLICY "Public read" ON testimonials FOR SELECT USING (true);

-- Only authenticated users can modify
CREATE POLICY "Admin write" ON profile FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin write" ON skills FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin write" ON projects FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin write" ON experience FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin write" ON education FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin write" ON testimonials FOR ALL USING (auth.role() = 'authenticated');

-- Anyone can INSERT messages (contact form), only admin can read
CREATE POLICY "Public insert" ON messages FOR INSERT WITH CHECK (true);
CREATE POLICY "Admin read" ON messages FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admin update" ON messages FOR UPDATE USING (auth.role() = 'authenticated');
```

**Step 3: Create Supabase Storage bucket**
- Go to Storage in Supabase dashboard
- Create bucket: `portfolio-assets` (public)
- Set policy: public read, authenticated write

**Step 4: Write Supabase client helpers**

`src/lib/supabase/client.ts`:
```typescript
import { createBrowserClient } from "@supabase/ssr";

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
```

`src/lib/supabase/server.ts`:
```typescript
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

export async function createClient() {
  const cookieStore = await cookies();
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll(); },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookieStore.set(name, value, options)
          );
        },
      },
    }
  );
}
```

`src/lib/types.ts`:
```typescript
export interface Profile {
  id: string;
  name: string;
  title: string;
  bio: string | null;
  avatar_url: string | null;
  resume_url: string | null;
  email: string | null;
  github: string | null;
  linkedin: string | null;
  twitter: string | null;
  location: string | null;
  available_for_hire: boolean;
  updated_at: string;
}

export interface Skill {
  id: string;
  name: string;
  icon_url: string | null;
  category: string;
  proficiency: number;
  sort_order: number;
}

export interface Project {
  id: string;
  title: string;
  slug: string;
  description: string;
  long_description: string | null;
  thumbnail_url: string | null;
  live_url: string | null;
  github_url: string | null;
  tech_stack: string[];
  featured: boolean;
  sort_order: number;
  created_at: string;
}

export interface Experience {
  id: string;
  company: string;
  role: string;
  description: string | null;
  start_date: string;
  end_date: string | null;
  company_logo_url: string | null;
  location: string | null;
  sort_order: number;
}

export interface Education {
  id: string;
  institution: string;
  degree: string;
  field: string | null;
  start_date: string;
  end_date: string | null;
  logo_url: string | null;
  sort_order: number;
}

export interface Testimonial {
  id: string;
  name: string;
  role: string | null;
  company: string | null;
  content: string;
  avatar_url: string | null;
  sort_order: number;
}

export interface Message {
  id: string;
  name: string;
  email: string;
  subject: string | null;
  message: string;
  read: boolean;
  created_at: string;
}
```

**Step 5: Commit**
```bash
git add . && git commit -m "feat: add Supabase setup, types, and client helpers"
```

---

### Task 3: Auth & Middleware

**Files:**
- Create: `src/app/auth/login/page.tsx`
- Create: `src/middleware.ts`

**Step 1: Write Next.js middleware to protect admin routes**

`src/middleware.ts`:
```typescript
import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return request.cookies.getAll(); },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  const { data: { user } } = await supabase.auth.getUser();

  if (request.nextUrl.pathname.startsWith("/admin") && !user) {
    return NextResponse.redirect(new URL("/auth/login", request.url));
  }

  if (request.nextUrl.pathname === "/auth/login" && user) {
    return NextResponse.redirect(new URL("/admin", request.url));
  }

  return response;
}

export const config = {
  matcher: ["/admin/:path*", "/auth/:path*"],
};
```

**Step 2: Build login page**
- Email + password form using Shadcn components
- Call `supabase.auth.signInWithPassword()`
- Redirect to `/admin` on success
- Show error toast on failure

**Step 3: Seed admin user**
- In Supabase dashboard > Authentication > Users > Add user
- Add your email + password (this is the only admin account)

**Step 4: Commit**
```bash
git add . && git commit -m "feat: add auth login page and admin route protection middleware"
```

---

### Task 4: Public Layout & Navbar

**Files:**
- Create: `src/app/(public)/layout.tsx`
- Create: `src/components/public/navbar.tsx`
- Create: `src/components/public/footer.tsx`

**Steps:**
1. Build responsive navbar — logo/name, nav links (Home, About, Projects, Contact), mobile hamburger menu (Shadcn Sheet)
2. Navbar should blur + shrink on scroll (Framer Motion `useScroll` + `useTransform`)
3. Build footer — social links, copyright, "Built with Next.js"
4. Wire into `(public)/layout.tsx`
5. Commit: `feat: add public layout with animated navbar and footer`

---

### Task 5: Hero Section

**Files:**
- Create: `src/app/(public)/page.tsx`
- Create: `src/components/public/hero.tsx`

**Steps:**
1. Fetch profile data from Supabase (server component)
2. Build hero: large name, animated title (typewriter or gradient text), tagline, CTA buttons
3. Add animated gradient/mesh background or subtle particle effect
4. Framer Motion fade-in + slide-up on mount
5. Commit: `feat: add hero section with animated background`

---

### Task 6: About Section

**Files:**
- Create: `src/components/public/about-section.tsx`

**Steps:**
1. Fetch profile data
2. Layout: image on left, bio text on right (responsive stack on mobile)
3. Available-for-hire badge with pulse animation
4. Scroll-triggered fade-in animation
5. Commit: `feat: add about section with scroll animations`

---

### Task 7: Skills Section

**Files:**
- Create: `src/components/public/skills-section.tsx`

**Steps:**
1. Fetch skills from Supabase, group by category
2. Display as categorized grid with icon + name + proficiency bar
3. Staggered fade-in animation on scroll
4. Commit: `feat: add skills section with categorized grid`

---

### Task 8: Projects Section + Detail Page

**Files:**
- Create: `src/components/public/projects-grid.tsx`
- Create: `src/components/public/project-card.tsx`
- Create: `src/app/(public)/projects/page.tsx`
- Create: `src/app/(public)/projects/[slug]/page.tsx`

**Steps:**
1. Build project card: thumbnail, title, description excerpt, tech badges, hover scale + glow
2. Home page: show featured projects (3-4), "View All" link
3. `/projects` page: full grid with tech filter buttons
4. `/projects/[slug]`: full detail page with screenshots, description, links
5. Commit: `feat: add projects grid, cards, and detail pages`

---

### Task 9: Experience Timeline

**Files:**
- Create: `src/components/public/experience-timeline.tsx`

**Steps:**
1. Fetch experience entries ordered by `sort_order`
2. Vertical timeline with alternating left/right cards (single column on mobile)
3. Company logo, role, dates, description
4. Scroll-triggered staggered animation
5. Commit: `feat: add experience timeline section`

---

### Task 10: Testimonials Section

**Files:**
- Create: `src/components/public/testimonials-carousel.tsx`

**Steps:**
1. Fetch testimonials from Supabase
2. Auto-scrolling marquee or carousel with quote cards
3. Avatar, name, role/company
4. Commit: `feat: add testimonials carousel section`

---

### Task 11: Contact Form

**Files:**
- Create: `src/app/(public)/contact/page.tsx`
- Create: `src/components/public/contact-form.tsx`

**Steps:**
1. Build form: name, email, subject, message (Shadcn inputs)
2. Client-side validation
3. On submit: insert into Supabase `messages` table (no auth needed per RLS)
4. Success toast notification
5. Also display on home page as a section
6. Commit: `feat: add contact form with Supabase integration`

---

### Task 12: Admin Layout & Dashboard

**Files:**
- Create: `src/app/(admin)/layout.tsx`
- Create: `src/app/(admin)/admin/page.tsx`
- Create: `src/components/admin/sidebar.tsx`
- Create: `src/components/admin/admin-header.tsx`
- Create: `src/components/admin/stat-card.tsx`

**Steps:**
1. Build admin sidebar: nav links to each admin section, logout button
2. Admin header: page title, user avatar
3. Dashboard page: stat cards (total projects, unread messages, skills count, etc.)
4. Responsive: sidebar collapses to hamburger on mobile
5. Commit: `feat: add admin layout with sidebar and dashboard overview`

---

### Task 13: Admin Profile Editor

**Files:**
- Create: `src/app/(admin)/admin/profile/page.tsx`
- Create: `src/components/admin/image-upload.tsx`

**Steps:**
1. Form pre-filled with current profile data
2. Avatar upload via Supabase Storage (drag & drop or click)
3. Resume PDF upload
4. Save button calls `supabase.from('profile').update()`
5. Toast on success
6. Commit: `feat: add admin profile editor with image upload`

---

### Task 14: Admin Projects CRUD

**Files:**
- Create: `src/app/(admin)/admin/projects/page.tsx`
- Create: `src/app/(admin)/admin/projects/[id]/page.tsx`

**Steps:**
1. Projects list page: table with title, status, actions (edit/delete)
2. Add new project button opens create form
3. Edit page: form with all project fields, thumbnail upload, tech stack multi-input
4. Delete with confirmation dialog
5. Commit: `feat: add admin projects CRUD with image upload`

---

### Task 15: Admin Skills CRUD

**Files:**
- Create: `src/app/(admin)/admin/skills/page.tsx`

**Steps:**
1. Skills grouped by category
2. Add/edit/delete with inline forms or dialog
3. Proficiency slider
4. Commit: `feat: add admin skills management`

---

### Task 16: Admin Experience & Education CRUD

**Files:**
- Create: `src/app/(admin)/admin/experience/page.tsx`
- Create: `src/app/(admin)/admin/education/page.tsx`

**Steps:**
1. Similar CRUD pattern as projects
2. Date pickers for start/end dates
3. "Current" toggle for end_date = null
4. Commit: `feat: add admin experience and education management`

---

### Task 17: Admin Testimonials & Messages

**Files:**
- Create: `src/app/(admin)/admin/testimonials/page.tsx`
- Create: `src/app/(admin)/admin/messages/page.tsx`

**Steps:**
1. Testimonials: CRUD with avatar upload
2. Messages: read-only inbox, mark as read, delete
3. Unread count badge in sidebar
4. Commit: `feat: add admin testimonials and messages management`

---

### Task 18: SEO & Metadata

**Files:**
- Modify: `src/app/layout.tsx`
- Modify: `src/app/(public)/projects/[slug]/page.tsx`

**Steps:**
1. Add `generateMetadata()` to root layout with profile data
2. Add dynamic `generateMetadata()` to project detail page
3. Add Open Graph images
4. Add `robots.txt` and `sitemap.xml` generation
5. Commit: `feat: add SEO metadata and sitemap generation`

---

### Task 19: Polish & Deploy

**Steps:**
1. Add loading skeletons for data fetching states
2. Add error boundaries
3. Test responsive design (mobile, tablet, desktop)
4. Dark/light mode toggle (Shadcn theme)
5. Deploy to Vercel: connect GitHub repo, add env vars
6. Commit: `feat: add loading states, error boundaries, and dark mode`

---

## Cost: $0

| Service | Plan | Cost |
|---------|------|------|
| Supabase | Free tier (500MB DB, 1GB storage, 50k auth users) | $0 |
| Vercel | Hobby plan | $0 |
| Domain (optional) | Custom domain | ~$10/year |

---

## Summary

| Phase | Tasks | What You Get |
|-------|-------|-------------|
| **Foundation** | 1-3 | Project scaffolded, DB ready, auth working |
| **Public Site** | 4-11 | Complete animated portfolio with all sections |
| **Admin Panel** | 12-17 | Full CMS to manage all content |
| **Polish** | 18-19 | SEO, dark mode, deploy to production |

**Total: 19 tasks, ~40-50 files**
