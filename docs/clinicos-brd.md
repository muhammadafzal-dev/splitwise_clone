# ClinicOS — Clinic Management SaaS (MVP)

**Version:** 1.3 (Simplified MVP)
**Date:** 2026-03-30
**Status:** Draft

---

## 1. Product Vision

A multi-tenant SaaS platform for small clinics to manage patients, visits, billing (advance/partial cash payments), and prescriptions.

**Core Design Principle:** Built for **non-technical staff** — receptionists operate on 3 screens max. Each clinic gets its own fully isolated tenant setup.

**Initial Target Market:** Small dental clinics (seed data + UX flows are dental-first, but architecture is clinic-agnostic).

---

## 2. Multi-Tenancy (SaaS)

Each subscribing clinic is a **tenant**. All data is strictly isolated per tenant. No cross-tenant data access is allowed — every query is filtered by `tenant_id`.

### Tenant Onboarding Flow

```
1. Clinic owner signs up → becomes Admin
2. Enters clinic name, phone, address
3. Adds staff (doctors, receptionists)
4. System is ready to use
```

### Tenant Settings

| Setting | Required | Notes |
|---------|:--------:|-------|
| Clinic Name | Yes | |
| Phone | Yes | |
| Address | No | Printed on prescription header |
| Logo | No | Printed on prescription header |
| Prescription Header | No | Custom text above Rx |
| Prescription Footer | No | Disclaimer below Rx |

---

## 3. Roles & Permissions

### MVP Roles (3)

| Role | Description |
|------|-------------|
| **Admin** | Clinic owner. Full access. Manages staff, settings, catalogs. |
| **Doctor** | Views patients, writes prescriptions, views billing summary. |
| **Receptionist** | Registers patients, sends to doctor, collects cash payments. |

### Permission Matrix

| Permission | Admin | Doctor | Receptionist |
|------------|:-----:|:------:|:------------:|
| Manage staff & settings | Yes | - | - |
| Register / edit patient | Yes | - | Yes |
| View patient list | Yes | Yes | Yes |
| Send patient to doctor | Yes | - | Yes |
| Write prescription | Yes | Yes | - |
| Print prescription | Yes | Yes | - |
| Manage procedure catalog | Yes | Yes | - |
| Manage medicine catalog | Yes | Yes | - |
| Collect payment (cash) | Yes | - | Yes |
| View patient history | Yes | Yes | Yes |

> **Future roles:** Junior Doctor, Accountant, Patient (self-service portal)

---

## 4. Receptionist Flow — 3 Screens

### Screen 1: Find or Register Patient

Search and register on the **same screen**. Receptionist types phone number — system shows matches or offers to register new patient.

- Search by phone → shows all matches (family members share numbers)
- If no match → inline registration form appears
- Required fields: Full Name + Phone only

### Screen 2: Send to Doctor (one click)

After selecting patient → pick doctor from dropdown → click **Send to Doctor**.

- System auto-creates a visit record behind the scenes
- Optional reason field
- No visit type, no extra configuration

### Screen 3: Collect Payment (all-in-one)

Handles **all billing cases** — new treatment, follow-up payment, consultation. Receptionist never sees "treatment plan" — just: what was done, how much, pay how much.

**Case A — New procedure (first time):**
- Select procedure from catalog → system shows price
- Enter discount (optional)
- Enter paying amount now
- System shows remaining balance
- Print receipt

**Case B — Follow-up payment (returning for same treatment):**
- Screen auto-shows "Pending Balances" section
- Click Pay on the pending item
- Enter amount paying now
- System updates balance

**Case C — Simple consultation (pay in full):**
- Select procedure → enter full amount → done

**Case D — Two procedures in same visit:**
- Select multiple procedures
- Total auto-calculated
- Collect in one transaction

> Behind the scenes: system auto-creates treatment record + payment record. Receptionist doesn't see this complexity.

---

## 5. Doctor Flow — 2 Screens

### Screen 1: Today's Patients

Simple queue view — today's patients waiting, their reason, and status.

- Status: Waiting → In Progress → Done
- Click **[Start]** → status changes to "In Progress"
- Shows completed count vs waiting count

### Screen 2: Write Prescription + Mark Done

One screen to write full prescription and mark patient as done.

**Fields:**
- Chief Complaint (required)
- Diagnosis (required)
- Procedures Done (multi-select from catalog)
- Medicines (name, dosage, frequency, duration, instructions)
- Advice
- Next Visit Date

**Actions:**
- **[Save & Print Prescription]** — saves and prints formatted Rx
- **[Done with Patient]** — marks visit Completed, unlocks payment for receptionist

**Smart features:**
- Patient allergies shown prominently at top
- Medicine defaults auto-fill from catalog (dosage, frequency, duration)
- Doctor can add new medicines on-the-fly

---

## 6. Patient Profile — History View

Read-only view accessible to all roles. Shows complete patient history.

**Sections:**
- Patient info (name, phone, age, gender, allergies)
- Visits tab — every visit with date, doctor, procedures, and [View Rx] link
- Payments tab — every treatment record with full payment breakdown

**Summary line:** Total Paid (all time) + Outstanding balance

---

## 7. Real-World Scenarios Covered

### S1: Multi-visit procedure with partial payments (Root Canal)

```
Visit 1: Register → Send to Dr → Rx written → Pay 15,000 of 38,000 → Receipt
Visit 2: Search patient → Pending balance shown → Pay 13,000 → Receipt
Visit 3: Final payment → Pay 10,000 → Balance = 0 → Auto-completed ✓
```

### S2: Simple consultation (single visit, full payment)

```
Register → Send to Dr → Rx → Pay 500 → Done ✓
```

### S3: Consultation with discount

```
Consultation (500) → Discount 200 → Total 300 → Paid ✓
```

### S4: Single-visit procedure, full payment

```
Register → Send to Dr → Tooth Extraction (1,500) → Paid ✓
```

### S5: Returning patient, new treatment (no pending balance)

```
Rahul returns after 6 months → Search → No pending balance shown
→ New procedure (Teeth Cleaning 2,000) → Paid ✓
→ History shows both Root Canal (paid) + Cleaning (paid)
```

### S6: Two procedures in same visit

```
Consultation (500) + X-Ray (300) → Total 800 → Paid ✓
```

### S7: Family members sharing one phone

```
Search 0300-1234567 → Shows Rahul
→ Register New Patient (same phone, different name/age/gender)
→ Each has own visits, prescriptions, payments
```

### S8: Patient visits but doesn't pay today

```
Visit done → Payment screen → Pays 0
→ Next time: pending balance (500) shown automatically
```

---

## 8. Core Modules

### 8.1 Patient

| Field | Type | Required | Notes |
|-------|------|:--------:|-------|
| Patient ID | Auto | Auto | PAT-XXXXX, unique per tenant |
| Full Name | Text | Yes | |
| Phone | Phone | Yes | NOT unique — family shares |
| Age | Number | No | |
| Gender | Select | No | Male / Female / Other |
| Email | Email | No | |
| Address | Text | No | |
| Known Allergies | Text | No | Shown on Rx screen |
| Notes | Text | No | |
| Status | Auto | Auto | Active / Inactive |

### 8.2 Procedure Catalog

| Field | Type | Required |
|-------|------|:--------:|
| Name | Text | Yes |
| Price | Decimal | Yes |
| Is Active | Boolean | Auto |

**Dental Seed Data:**

| Procedure | Price (PKR) |
|-----------|-------------|
| Consultation | 500 |
| Tooth Extraction (Simple) | 1,500 |
| Tooth Extraction (Surgical) | 5,000 |
| Root Canal Treatment | 8,000 |
| Dental Crown (PFM) | 5,000 |
| Dental Crown (Zirconia) | 12,000 |
| Teeth Cleaning / Scaling | 2,000 |
| Dental Filling | 2,000 |
| Complete Denture | 25,000 |
| Orthodontic Braces | 40,000 |
| Teeth Whitening | 8,000 |
| X-Ray | 300 |

### 8.3 Medicine Catalog

| Field | Type | Required |
|-------|------|:--------:|
| Name | Text | Yes |
| Type | Select | Yes |
| Default Dosage | Text | No |
| Default Duration | Text | No |
| Instructions | Text | No |
| Is Active | Boolean | Auto |

**Types:** Tablet, Capsule, Syrup, Cream, Drops, Other

**Dental Seed Data:**

| Medicine | Type | Default |
|----------|------|---------|
| Amoxicillin 500mg | Capsule | 1 cap, 3x/day, 5 days |
| Metronidazole 400mg | Tablet | 1 tab, 3x/day, 5 days |
| Ibuprofen 400mg | Tablet | 1 tab, 3x/day, 3 days |
| Paracetamol 500mg | Tablet | 1 tab as needed |
| Diclofenac 50mg | Tablet | 1 tab, 2x/day |
| Chlorhexidine Mouthwash | Liquid | Rinse 2x/day |

> Doctors can add new medicines on-the-fly during prescription writing.

### 8.4 Prescription

| Field | Type | Required |
|-------|------|:--------:|
| Visit | Reference | Auto |
| Patient | Reference | Auto |
| Doctor | Reference | Auto |
| Chief Complaint | Text | Yes |
| Diagnosis | Text | Yes |
| Procedures Done | Multi-select | No |
| Medicines | List | No |
| Advice | Text | No |
| Next Visit Date | Date | No |

**Medicine Line Item fields:** Medicine Name (snapshot), Dosage, Frequency, Duration, Instructions

**Key rule:** Medicine and procedure names are **snapshots** — catalog edits never affect past prescriptions.

### 8.5 Billing (Behind the Scenes)

**Treatment Record** (auto-created when receptionist selects a procedure):

| Field | Notes |
|-------|-------|
| Patient | Auto |
| Procedure(s) | Receptionist selection — stored as snapshot |
| Total Amount | Sum of procedure prices |
| Discount | Receptionist input |
| Final Amount | Total - Discount |
| Amount Paid | Running sum |
| Balance Due | Final - Paid |
| Status | Active → Completed (auto when balance = 0) |

**Payment Record** (auto-created on each "Collect Cash"):

| Field | Notes |
|-------|-------|
| Patient | Auto |
| Treatment Record | Reference |
| Amount | Receptionist input |
| Payment Method | Cash (MVP) |
| Date | Auto (today) |
| Receipt Number | PAY-XXXXX |
| Collected By | Logged-in user |

---

## 9. Screens Summary

| Role | Screen | Purpose |
|------|--------|---------|
| Receptionist | Find / Register Patient | Phone search → pick or register |
| Receptionist | Send to Doctor | Pick doctor → one button |
| Receptionist | Collect Payment | Procedure + amount + receipt |
| Doctor | Today's Patients | Queue → click Start |
| Doctor | Write Prescription | Rx form → Print → Done |
| Admin | Staff Management | Add/edit staff |
| Admin | Clinic Settings | Name, logo, Rx header/footer |
| Admin | Procedure Catalog | Add/edit procedures + prices |
| Admin | Medicine Catalog | Add/edit medicines |
| Shared | Login | Everyone |
| Shared | Dashboard | Today's summary |
| Shared | Patient Profile + History | Read-only visits, Rx, payments |

**Total: 12 screens** (3 receptionist + 2 doctor + 4 admin + 3 shared)

---

## 10. Database Schema (12 Tables)

### Entity Relationships

```
Tenant (1) ─── (*) User (staff)
Tenant (1) ─── (*) Patient
Tenant (1) ─── (*) Procedure
Tenant (1) ─── (*) Medicine
Patient (1) ─── (*) Visit
Visit (*) ─── (1) Doctor (User)
Visit (1) ─── (0..1) Prescription
Prescription (1) ─── (*) PrescriptionMedicine
Prescription (1) ─── (*) PrescriptionProcedure
Patient (1) ─── (*) TreatmentRecord
TreatmentRecord (1) ─── (*) TreatmentProcedure
TreatmentRecord (1) ─── (*) Payment
```

### Tables

**tenants** — clinic identity, settings, Rx header/footer, logo
**users** — staff with roles (ADMIN, DOCTOR, RECEPTIONIST), unique per tenant by phone
**patients** — phone NOT unique (family sharing), indexed by (tenant_id, phone)
**procedures** — per-tenant catalog with price
**medicines** — per-tenant catalog with type + defaults
**visits** — one per patient-doctor encounter, status: WAITING → IN_PROGRESS → COMPLETED
**prescriptions** — one per visit, stores complaint/diagnosis/advice/next_visit
**prescription_medicines** — line items with name snapshot
**prescription_procedures** — procedures done, name snapshot
**treatment_records** — billing record: total, discount, final, paid, balance, status
**treatment_procedures** — procedures in a treatment record, price snapshot
**payments** — each cash collection event, links to treatment record

---

## 11. Business Rules

### Patients
- Full Name + Phone are the only required fields
- Phone is NOT unique — family members share phones
- Patient cannot be deleted, only deactivated

### Visits
- Walk-in only (no scheduling in MVP)
- Visit date auto-set to today
- Only doctors can write prescriptions

### Billing
- Cash only in MVP
- Payment cannot exceed balance
- Payment cannot be negative
- Balance auto-updates after every payment
- When balance = 0, treatment record auto-completes
- Receptionist never sees "treatment plan" — just procedure name + amount + remaining

### Prescriptions
- One prescription per visit
- Medicine/procedure names stored as snapshots (immutable history)

### Multi-Tenancy
- Every query filtered by `tenant_id`
- No cross-tenant data access

---

## 12. Out of Scope for MVP

| Feature | Phase |
|---------|-------|
| Appointment scheduling (calendar, time slots) | 2 |
| Patient login / portal | 2 |
| SMS / WhatsApp reminders | 2 |
| Reports & analytics | 2 |
| Prescription templates (reusable) | 2 |
| Multiple payment methods (Card, JazzCash, EasyPaisa) | 2 |
| Refunds | 2 |
| Multi-branch per tenant | 3 |
| Document uploads (X-rays) | 3 |
| Subscription billing (SaaS plans) | 3 |
| Mobile app | 4 |

---

## 13. MVP Summary

| Aspect | Value |
|--------|-------|
| Receptionist screens | 3 |
| Doctor screens | 2 |
| Total screens | 12 |
| Roles | 3 (Admin, Doctor, Receptionist) |
| Required patient fields | Full Name + Phone only |
| Payment method | Cash only |
| Billing | Partial/advance payments, auto-balance tracking |
| History | Full — every visit, Rx, payment preserved |
| Multi-tenant | Yes |
| DB tables | 12 |

---

*End of ClinicOS MVP BRD*
