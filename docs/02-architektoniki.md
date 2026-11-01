# Αρχιτεκτονική — πρόταση και trade-offs

## 1. Επισκόπηση

```
                    ┌────────────────────────── Next.js app (ένα deployable) ─────────────────────────┐
  Επισκέπτης ──CDN──▶  Public site (SSG/ISR)   │  /admin Payload CMS   │  Route handlers (API)        │
                    │  - homepage, λίστες      │  - content types      │  - /api/ads/event (beacon)   │
                    │  - άρθρα, events         │  - campaigns/creatives│  - /go/[creative] (click)    │
                    │  - σχολές/βάσεις         │  - leads (read)       │  - /api/leads, /api/search   │
                    │  - αναζήτηση             │  - source inbox       │  - cron: rollups, inbox poll │
                    └──────────────┬───────────┴───────────┬───────────┴──────────────┬──────────────┘
                                   │                       │                          │
                         PostgreSQL 16 (EU) ── schemas: cms (Payload) · edu · ads · ops
                                   │
              Object storage (R2/S3) για media · Brevo (newsletter) · Plausible (analytics) · Sentry
```

**Modular monolith**: μία εφαρμογή, ένα repository, μία βάση, με σαφή όρια ανάμεσα στα modules:

| Module | Ευθύνη | Δεν γνωρίζει |
|---|---|---|
| `content` | Νέα, Άρθρα, Προθεσμίες, Events, Updates, Sponsored, Authors, Topics | ads internals |
| `edu` | Canonical τμήματα, ετήσια δεδομένα, imports, καρτέλες | content, ads |
| `ads` | Placements, campaigns, creatives, delivery, metrics, reports | ποιος είναι ο χρήστης |
| `leads` | Newsletter, advisor, consent log, export / webhook | ads |
| `search` | Ενοποιημένο index πάνω σε content και edu | — |
| `platform` | Auth (1B), analytics wrapper, SEO, redirects, observability | — |

Τα modules επικοινωνούν μόνο μέσω exported service functions (όχι απευθείας queries σε ξένους πίνακες).
Αυτό ελέγχεται με lint rule (`eslint-plugin-boundaries`).

## 2. Επιλογές και αιτιολόγηση

| Απόφαση | Επιλογή | Γιατί | Εναλλακτικές που απορρίψαμε |
|---|---|---|---|
| Framework | **Next.js (App Router, TS)** | SSG/ISR για SEO και ταχύτητα, server components, μεγάλο hiring pool | Astro (λιγότερο κατάλληλο για τα interactive εργαλεία της Φάσης 2) |
| CMS | **Payload CMS 3** | Open source (MIT), τρέχει μέσα στο Next.js, PostgreSQL, structured types, access control ανά ρόλο, drafts, versions, scheduled publish, live preview, custom collections για ads. Χωρίς license και χωρίς SaaS lock-in | Strapi (ξεχωριστή υπηρεσία), Sanity/Contentful (SaaS, δεδομένα εκτός LABORA, κόστος ανά seat), WordPress (plugins για ads και structured data, θέματα security) |
| Βάση | **PostgreSQL 16** | Relational constraints για τα canonical δεδομένα, FTS, ένα σύστημα για όλα | — |
| Αναζήτηση | **Postgres FTS + unaccent + pg_trgm** | Αρκεί για < 50k έγγραφα, η ελληνική αναζήτηση χωρίς τόνους δουλεύει. Ελέγχθηκε στο `db/schema.sql` | Meilisearch/Typesense: θα μπουν όταν τα analytics δείξουν ανάγκη |
| Hosting | **Vercel (fra1) + Neon/Supabase EU** | Μηδενικό DevOps, preview deployments ανά PR για UAT | Self-hosted Docker σε Hetzner (φθηνότερο, λίγο περισσότερη συντήρηση). Ο κώδικας είναι ίδιος |
| Media | **S3-compatible (R2)** + Next/Image | Φθηνό egress, responsive output, crops από Payload | — |
| Email | **Brevo** | EU, double opt-in, API για segments στη Φάση 3 | Mailchimp (US) |
| Analytics | **Plausible** + first-party ad metrics | Cookieless, άρα δεν χρειάζεται consent για βασική μέτρηση. Κατάλληλο για ανήλικους | GA4 μόνο ως opt-in επιλογή |
| Auth (1B) | **Better Auth / Auth.js** στην ίδια βάση | Google και magic link ή OTP, οι χρήστες μένουν στη βάση της LABORA | Clerk/Auth0 (lock-in, κόστος ανά MAU) |
| Error tracking | Sentry | Standard | — |

## 3. Rendering και cache

- Δημόσιες σελίδες: **ISR** με on-demand revalidation από Payload hooks (`afterChange` → `revalidateTag`). Η δημοσίευση φαίνεται σε δευτερόλεπτα.
- Καρτέλες τμημάτων: στατικές ανά τμήμα (~453 σελίδες), revalidate μετά από import.
- Διαφημίσεις: η **επιλογή creative γίνεται server-side** μέσα στο cached HTML (ανά placement και ενεργή καμπάνια), με revalidate κάθε 5 λεπτά και στην αλλαγή καμπάνιας. Έτσι αποφεύγουμε το client-side ad fetch που προκαλεί CLS. Rotation μεταξύ πολλών ενεργών creatives γίνεται με ελαφρύ client island που επιλέγει μεταξύ προφορτωμένων creatives **ίδιων διαστάσεων**.
- Scheduled start και end καμπανιών και content: cron κάθε 5 λεπτά που κάνει revalidate τα tags που επηρεάζονται.

## 4. Security

- Least privilege ρόλοι στο CMS: `admin`, `editor`, `sales` (μόνο ads, partners, sponsored), `viewer`.
- Validation με Zod σε όλα τα inputs. Rate limiting σε leads, search και ad beacons (ανά IP hash).
- Anti-spam σε φόρμες: honeypot και Cloudflare Turnstile (privacy-friendly).
- Secrets μόνο σε env vars του hosting, ποτέ στο repository.
- CSP headers και sanitization του rich text. Τα creatives είναι εικόνες ή structured native, **όχι αυθαίρετο third-party HTML/JS** στη Φάση 1.
- Backups: Point-in-time recovery του managed Postgres και εβδομαδιαίο logical dump σε storage της LABORA. Restore test πριν το launch και ανά τρίμηνο.

## 5. Privacy by design (ανήλικοι χρήστες)

- Κανένα third-party tracking cookie χωρίς consent. Τα βασικά analytics είναι cookieless.
- Τα ad metrics δεν αποθηκεύουν IP ή cookie, μόνο ημερήσιο salted hash για dedup, και τα raw διαγράφονται μετά από 30 ημέρες.
- Τα analytics events **δεν περιέχουν** βαθμούς, απαντήσεις τεστ ή ελεύθερο κείμενο (σύμφωνα με την §12 του brief). Αυτό επιβάλλεται από typed wrapper `track()` με allow-list properties.
- Το lead form έχει ξεχωριστά checkboxes για επικοινωνία από σύμβουλο και για marketing, και αποθηκεύει την version του κειμένου συγκατάθεσης. Αν ο χρήστης είναι κάτω των 15 ετών, η φόρμα ζητά στοιχεία γονέα (το όριο ηλικίας ψηφιακής συγκατάθεσης στην Ελλάδα είναι 15 ετών, ν. 4624/2019 άρθρο 21). Η τελική διατύπωση έρχεται από τον νομικό της LABORA.
- Δικαιώματα πρόσβασης και διαγραφής: admin action «export / delete by email» για leads και (στη Φάση 1B) για users.

## 6. Repository layout (πρόταση)

```
/app            (site)/…  (payload)/admin  api/…
/src/modules    content/ edu/ ads/ leads/ search/ platform/
/src/ui         design system (tokens, components, AdSlot)
/db             schema.sql (edu/ads/ops), migrations/
/scripts/import CLI: validate → dry-run → apply → rollback
/tests          unit (vitest), e2e (playwright), a11y (axe)
/docs           ADRs, runbooks, editor & sales guides
```
