# SOW Analysis — RO & Water Purifier Service Management Platform

**Date:** 2026-03-28
**Document Type:** Client Requirements + Technical Analysis

---

## TABLE OF CONTENTS

1. [Client Overview](#1-client-overview)
2. [Technology Stack](#2-technology-stack)
3. [Client Requirements — Scope of Work](#3-client-requirements--scope-of-work)
   - 3.1 Consumer Mobile Application
   - 3.2 Technician Mobile Application
   - 3.3 Admin Web Panel
4. [Technical Analysis](#4-technical-analysis)
5. [Development Hours Breakdown](#5-development-hours-breakdown)
6. [Timeline](#6-timeline)
7. [Budget Estimate](#7-budget-estimate)
8. [Clarification Questions for Client](#8-clarification-questions-for-client)
9. [Red Flags & Risks](#9-red-flags--risks)
10. [Recommendations](#10-recommendations)

---

## 1. Client Overview

This is a **field service management platform** for an RO and water purifier servicing business. The platform works similar to Urban Company — customers book a technician, the technician is dispatched, completes the job, and payment is collected — all managed through mobile apps and an admin panel.

The platform consists of three products:
- Consumer Mobile App (Android + iOS)
- Technician Mobile App (Android + iOS)
- Admin Web Panel

---

## 2. Technology Stack

| Layer | Technology |
|---|---|
| Mobile Apps | React Native (Android + iOS) |
| Admin Panel | React.js / Next.js |
| Backend | Node.js |
| Database | PostgreSQL |
| Payments | Razorpay |
| Notifications | WhatsApp API + Push Notifications |
| Maps | To be confirmed (Google Maps preferred) |

---

## 3. Client Requirements — Scope of Work

### 3.1 Consumer Mobile Application

#### Authentication & User Management
- Registration via email or phone number with OTP verification
- Optional social login (Google/Facebook)
- Sign in with email/phone + password
- Forgot password and change password
- Website redirect to app for registration

#### Service Booking & Management
- Multi-location support — users can add and manage multiple service addresses
- Service request creation:
  - Select service type (RO repair, water purifier service, brand-specific, local)
  - Upload RO/purifier photo
  - Select brand from predefined list or enter custom
  - Describe issue in text
  - Select preferred date and time slot
- View assigned technician details
- Real-time technician tracking on map (similar to Ola/Uber)
- Real-time notifications for service progress

#### AMC (Annual Maintenance Contract)
- Browse and purchase annual maintenance packages
- Clear pricing breakdown for AMC plans
- Payment options:
  - Full payment (one-time)
  - Partial payment — quarterly installments
  - Partial payment — half-yearly installments
- View active AMCs, renewal dates, and service history

#### Payment Integration
- Payment methods: UPI, Credit Card, Debit Card via Razorpay
- Pay for one-time services or AMC subscriptions
- Pay via app or by scanning technician-shared QR code
- Transaction history with downloadable invoices
- Refund management as per policy

#### Service Verification & Feedback
- Review completed service checklist
- View before/after photos of serviced equipment
- Confirm service completion in app
- Rate technician (1–5 stars) with written feedback

#### Notifications & Alerts
- AMC renewal reminders (30/15/7 days before expiry)
- Part replacement recommendations
- Service due notifications
- Promotional offers and updates
- Real-time push notifications for service status

#### User Profile Management
- Full name, email, phone number, profile photo
- Multiple addresses management
- Change password
- Secure logout with session termination

#### Additional Features
- FAQs section
- Terms of service, privacy policy, refund policy
- Contact form, phone number, email
- About / company information
- Referral / Refer & Earn functionality

---

### 3.2 Technician Mobile Application

#### Onboarding & Authentication
- Admin provides physical welcome kit with:
  - QR code for app download
  - Registered name, email, phone
  - Temporary login credentials
- First-time setup:
  - Login with provided credentials
  - Mandatory password change on first login
  - Location permission activation
  - Profile completion

#### Service Request Management
- Receive nearby service requests based on location
- View request details:
  - Customer name and contact
  - Service location on map
  - Service type and issue description
  - Customer-uploaded photos
  - Preferred date/time
- Accept or reject service requests
- View accepted and pending request queue

#### Navigation & Communication
- View customer location on integrated map
- Get directions to customer location
- Call customer directly from app
- Confirm service details or clarify location with customer

#### Live Location Tracking
- Real-time location sharing with customer and admin
- Automatic location updates during active service
- Location sharing only during active service hours (privacy)

#### Service Execution & Documentation
- Capture "Before Service" photos (mandatory)
- Capture "After Service" photos (mandatory)
- Service checklist:
  - Select products/parts used from predefined list
  - Add custom items if needed
  - Specify quantities

#### Billing & Payment
- Add service charges and parts/product costs
- Calculate applicable taxes
- Display total amount
- Generate and share payment QR code with customer
- Receive payment confirmation notifications
- Transaction history with filters

#### Profile Management
- Name, email, phone, profile photo
- Secure logout

---

### 3.3 Admin Web Panel

#### Authentication & Access Control
- Email and password-based admin login
- Change password and forgot password
- Role-based access control (optional)
- Secure session handling with timeout

#### Dashboard
- Real-time metrics:
  - Total active technicians
  - Total registered customers
  - Active service requests
  - Completed services (today/week/month)
  - Revenue metrics (today/week/month/year)
- System alerts:
  - Technician delay notifications
  - No-movement alerts for technicians
  - Service delays beyond SLA
  - Unusual activity patterns
- Quick actions: Add technician, assign task, view pending requests

#### Technician Management
- Add technician (name, email, phone, service zones, skills, ID proof)
- Generate welcome kit credentials
- Edit or deactivate technicians
- View technician details, assignments, history, performance, ratings
- Real-time location tracking on map
- Searchable and filterable technician list with pagination

#### Task Management
- View all service requests (pending/assigned/completed/cancelled)
- Filter by status, date, technician, location
- Manual or auto-assignment to technicians
- Reassign tasks if needed
- Monitor progress of each task

#### Performance & Analytics
- Service completion rates
- Average service time
- Customer satisfaction scores
- Technician efficiency metrics
- Individual technician rankings and ratings
- MIS reports with custom date range and export (PDF/Excel/CSV)

#### Customer Management
- View all registered customers
- View customer profile, service history, payments
- View and respond to customer queries

#### Payment & Financial Management
- View and monitor all payment transactions

#### System Settings
- Configure tax rates
- Manage service types and categories
- Add/edit RO and water purifier brands

---

## 4. Technical Analysis

### What Makes This Project Complex

| Complexity Area | Details |
|---|---|
| Real-time GPS tracking | Bi-directional location streaming (like Ola/Uber) using WebSockets |
| AMC installment billing | Subscription logic with partial payment schedules and missed payment handling |
| AI-based alerts | Movement detection and SLA monitoring for technicians |
| Three separate apps | Consumer, Technician, Admin — all sharing one backend |
| Multi-payment flows | App payment + QR code scan + installments + refunds |
| Offline capability | Technician app must handle poor connectivity in the field |

### Architecture Overview

```
Consumer App (React Native)
Technician App (React Native)     →   Node.js REST API + WebSocket Server   →   PostgreSQL
Admin Panel (Next.js)

Integrations:
- Razorpay (payments)
- WhatsApp Business API (notifications)
- Maps API (real-time tracking)
- Firebase / APNS (push notifications)
```

---

## 5. Development Hours Breakdown

| Module | Estimated Hours |
|---|---|
| Backend (APIs, DB design, auth, WebSockets) | 380h |
| Consumer Mobile App | 240h |
| Technician Mobile App | 180h |
| Admin Web Panel | 240h |
| Integrations (Razorpay, WhatsApp, Maps/GPS) | 90h |
| Real-time Tracking System | 60h |
| QA & Testing | 120h |
| Deployment & DevOps Setup | 50h |
| **Total** | **~1,360 hours** |

---

## 6. Timeline

### By Team Size

| Team Size | Estimated Timeline |
|---|---|
| Solo developer | 10–12 months |
| 2 developers | 6–7 months |
| 3 developers (recommended) | 4–5 months |

**Recommended team:** 1 backend dev + 1 mobile dev + 1 frontend/admin dev

### Phase Breakdown (3 Developers)

| Phase | Deliverable | Duration |
|---|---|---|
| Phase 1 | DB design, backend foundation, auth APIs | 3–4 weeks |
| Phase 2 | Consumer app + core backend APIs | 5–6 weeks |
| Phase 3 | Technician app + Razorpay + WhatsApp | 4–5 weeks |
| Phase 4 | Admin panel + live map + analytics | 5–6 weeks |
| Phase 5 | AI alerts + QA + bug fixes + deployment | 3–4 weeks |
| **Total** | | **4.5–5.5 months** |

---

## 7. Budget Estimate

### Hourly Rates (Pakistani dev / small agency — international client)

| Role | Rate |
|---|---|
| Backend Developer | $25–35/hr |
| Mobile Developer | $25–35/hr |
| Frontend Developer | $20–30/hr |

### Total Cost Estimate

| Scenario | Budget Range |
|---|---|
| Low (tight budget, small team) | $28,000 – $32,000 |
| Standard (recommended) | $35,000 – $42,000 |
| With buffer + revisions | $42,000 – $50,000 |

### Recommended Quote to Client

**$38,000 – $45,000**

Justification:
- 3-app + backend project — significant scope
- Real-time GPS tracking is technically complex
- Razorpay AMC installment billing is non-trivial
- AI alert system adds considerable scope
- Indian market comparable: agencies charge ₹30–40 lakhs (~$36,000–$48,000) for equivalent projects

### Payment Structure Recommendation
- 30–40% upfront to begin
- Milestone-based payments per phase
- Final 10% on deployment and handover

---

## 8. Clarification Questions for Client

### Technical Clarifications

**1. Real-time Tracking**
- Which maps provider do you prefer — Google Maps or any alternative?
- Who covers the Maps API usage cost (per-request billing)?

**2. WhatsApp API**
- Do you already have a WhatsApp Business API account/BSP provider?
- Or do we need to set that up? (Adds 2–4 weeks + extra cost)

**3. AI Alerts**
- "AI-driven delay and no-movement alerts" — is this simple rule-based logic (e.g., no movement for 10 min = alert) or actual machine learning / predictive system?
- What thresholds define "delayed" — is there an SLA per service type?

**4. Social Login**
- Google/Facebook login is marked "optional" — do you want it in v1 or later?

### Business Logic Clarifications

**5. AMC Installments**
- For quarterly/half-yearly payments — does the system auto-charge the card on the due date?
- Or does it send a reminder and the customer pays manually?
- What happens if a customer misses an installment — service suspended?

**6. Auto-Assignment Logic**
- When auto-assigning a technician, what is the priority — nearest available, highest rated, or specific specialization for the brand/issue?
- What if no technician is available in the zone?

**7. Referral Program**
- Does the referee get wallet credits, discount coupon, or cash?
- Is there a wallet system in the app or just coupon codes?

**8. Technician Payment**
- Does your company pay technicians through the app (earnings payout)?
- Or do technicians just track earnings and get paid separately?

**9. Service Zones**
- Do you already have defined service zones/cities?
- How many cities/zones at launch?

### Admin & Access

**10. Role-Based Admin Access**
- You mentioned this is "optional" — do you need it at launch?
- How many admin users and what roles? (e.g., super admin, city manager, support)

**11. MIS Reports**
- What specific reports do you need? (Revenue by zone, technician performance, AMC expiry list?)
- Any specific format the management team uses today?

### Product & Timeline

**12. Existing Data**
- Do you have existing customers or technicians to migrate into the new system?
- Or is this a fresh launch?

**13. Launch Priority**
- Which app do you want live first — Consumer, Technician, or all together?
- Do you have a target launch date?

**14. Design**
- Do you have brand guidelines, logo, or UI/UX designs ready?
- Or do we need to design from scratch? (Adds 3–4 weeks)

**15. App Store Accounts**
- Do you have Google Play and Apple Developer accounts ready?
- Apple approval can take time — important to start early

### 5 Most Critical Questions

| # | Question | Why It Matters |
|---|---|---|
| 1 | AMC auto-charge or manual payment? | Completely different billing architecture |
| 2 | WhatsApp API ready or we set it up? | Adds 2–4 weeks + extra cost |
| 3 | AI alerts — rule-based or actual ML? | 10x complexity difference |
| 4 | Technician payout through app? | Adds payout/split payment scope |
| 5 | Design ready or from scratch? | Adds 3–4 weeks if we design |

---

## 9. Red Flags & Risks

| Risk | Details |
|---|---|
| Vague AI requirement | "AI-driven alerts" could mean simple rules or full ML — 10x scope difference |
| Maps API cost | Google Maps charges per API call — ongoing cost the client must budget for |
| WhatsApp API approval | Takes 2–4 weeks to get approved — needs to start early |
| Apple App Store | Developer account approval + app review can add 2–3 weeks |
| Scope creep | Referral wallet, role-based admin, social login are all potential additions |
| Offline support | Technicians in the field may have poor connectivity — needs to be handled |
| Real-time tracking infra | WebSocket server needs to be scalable from day one |

---

## 10. Recommendations

1. **Quote a range, not a fixed price** — say $38K–$45K depending on final scope confirmed in the call
2. **Propose phased delivery** — Consumer App first, then Technician App, then Admin Panel — easier for client to approve and pay in milestones
3. **Clarify ambiguous items before signing** — referral wallet, AI alert thresholds, role-based admin
4. **Add 20% buffer** in your internal estimate for scope creep — clients always add features mid-project
5. **Suggest 30–40% upfront payment** to start, then milestone-based
6. **Start App Store accounts early** — Apple review process can delay launch by weeks
7. **Lock WhatsApp API setup early** — needs business verification which takes time
8. **Define AI alerts as rule-based in v1** — can upgrade to ML in v2 if client wants

---

*Document prepared: 2026-03-28*
