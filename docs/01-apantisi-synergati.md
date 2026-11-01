# LABORA / fAInd — Απάντηση τεχνολογικού συνεργάτη στο Product Brief v1.0

> Απάντηση στο brief της 21ης Οκτωβρίου 2026 (ενότητα 13). Δεν είναι τελικό συμβόλαιο.
> Είναι η δική μας κατανόηση του προϊόντος, μια συγκεκριμένη πρόταση για τη Φάση 1 και
> χωριστή εκτίμηση για κάθε φάση. Οι αριθμοί θα οριστικοποιηθούν μετά το audit της Φάσης 0
> (δεν έχουμε δει ακόμη το demo ούτε τα datasets).
>
> Συνοδευτικά: [Αρχιτεκτονική](02-architektoniki.md) · [Δεδομένα σχολών](03-dedomena-scholon.md) ·
> [Διαφημίσεις](04-diafimiseis.md) · [Sitemap και content model](05-sitemap-content-model.md) ·
> [Backlog Φάσης 1](06-backlog-fasi-1.md) · [Κίνδυνοι και ανοιχτά θέματα](07-kindynoi-anoixta.md) ·
> [SQL σχήμα](../db/schema.sql)

---

## 1. Πώς καταλαβαίνουμε το προϊόν

Το fAInd δεν είναι εταιρικό site της LABORA. Δεν είναι ούτε SaaS πλατφόρμα με υποχρεωτική εγγραφή. Είναι
**ένα ανοιχτό ενημερωτικό μέσο** που δίνει στην ελληνική οικογένεια λόγο να το ανοίγει κάθε μέρα. Όταν
έρθει η ώρα της απόφασης, το ίδιο περιβάλλον έχει ήδη τις σχολές, τις βάσεις και τον σύμβουλο.

Οι τρεις ρόλοι είναι ισότιμοι, και ο καθένας στηρίζει τους άλλους δύο:

| Ρόλος | Με δικά μας λόγια | Τι πρέπει να αποδείξει η Φάση 1 |
|---|---|---|
| **Ενημερωτικό μέσο** | Ο καθημερινός λόγος επίσκεψης: τι άλλαξε σήμερα, τι λήγει, τι σημαίνει για μένα. | Ότι η LABORA μπορεί να δημοσιεύει κάθε μέρα χωρίς developer και ότι η κίνηση μεγαλώνει οργανικά. |
| **Οικοσύστημα LABORA** | Η γέφυρα από την πληροφορία στην απόφαση και από εκεί στον άνθρωπο (σύμβουλο, event, newsletter). | Ότι η κίνηση φέρνει μετρήσιμα leads και επιστρέφοντες χρήστες. |
| **Διαφημιστική πλατφόρμα** | Ένα αξιόπιστο, καθαρά σημασμένο inventory που ένα πανεπιστήμιο μπορεί να αγοράσει και να μετρήσει. | Ότι μια πραγματική καμπάνια ξεκινά, λήγει και αποδίδει αναφορά χωρίς αλλαγή κώδικα. |

**Η βασική διαδρομή χρήστη:**
είδηση ή προθεσμία (Google, social, newsletter) → «τι σημαίνει για μένα» (άρθρο LABORA) →
σχετικό τμήμα ή βάση (canonical καρτέλα με πηγή και έτος) → ενέργεια (newsletter, εγγραφή σε event, «μίλα με σύμβουλο») →
επιστροφή (newsletter, νέα προθεσμία). Σε κάθε βήμα εμφανίζεται σχετική προβολή με σαφή σήμανση,
ξεχωριστά από το editorial.

Το ανταγωνιστικό πλεονέκτημα δεν είναι ο όγκος. Είναι η **συνέχεια**: κάθε σελίδα έχει
προκαθορισμένο «επόμενο βήμα» (related content, σχολή, σύμβουλος). Αυτό το σχεδιάζουμε ως
δομική ιδιότητα του content model (υποχρεωτικά related πεδία), όχι ως διακόσμηση.

---

## 2. Πρόταση Φάσης 1 — Media and commercial core

### 2.1 Παραδοτέα (in scope)

| # | Παραδοτέο | Καλύπτει |
|---|---|---|
| D1 | **CMS** (Payload) με τύπους Νέα, Άρθρα, Προθεσμίες, Εκδηλώσεις, LABORA Updates, Χορηγούμενο, Author, Topic, Partner. Ρόλοι Admin / Editor / Sales, drafts, preview, scheduled publish, media library με crops και attribution. | CMS 01, CMS 02 |
| D2 | **Source inbox**: παρακολούθηση whitelisted RSS / σελίδων (π.χ. minedu ανακοινώσεις), dedup, μετατροπή σε draft με ένα κλικ. **Χωρίς αυτόματη δημοσίευση.** Προαιρετική πρόταση περίληψης / tags από AI ως βοήθεια στον editor. | §4.3, §11 |
| D3 | **Δημόσιο site** σε Next.js (SSG/ISR): homepage (hero με έως 3 slides, λωρίδα τελευταίων και προθεσμιών, quick access, ροή), λίστες ανά τύπο και κατηγορία, σελίδες άρθρου, προθεσμίας, event, topic hub, partner spotlight. Sticky header και mobile drawer. | UX 01, UX 02 |
| D4 | **Σχολές και Βάσεις**: canonical κατάλογος (~453 τμήματα), επιλογή ΓΕΛ (4 πεδία) / ΕΠΑΛ (τομείς) / Ένστολα, φίλτρα (πόλη, ίδρυμα, πεδίο/τομέας), ταξινόμηση αλφαβητικά ή κατά βάση, καρτέλα τμήματος με Ταυτότητα, Πρόσβαση, Εισαγωγή (2 έτη), Προϋποθέσεις, Αξιοπιστία (πηγή, έτος, verified date). | DATA 01, DATA 02 |
| D5 | **Import pipeline** για datasets (CSV/XLSX): validation report, idempotency (hash), provenance, rollback ανά batch. | DATA 01, §10 |
| D6 | **Ενιαία αναζήτηση** (PostgreSQL full-text με unaccent για ελληνικά χωρίς τόνους, και trigram για ορθογραφικά λάθη) σε νέα, άρθρα, σχολές, προθεσμίες, events, με ομαδοποίηση ανά τύπο. | SRCH 01 |
| D7 | **Διαφημιστική μονάδα**: 8 placements (AD-01 έως AD-08, ενεργά τουλάχιστον τα 6 web), Campaigns / Creatives (desktop + mobile), ημερομηνίες, status, label, disclaimer, UTM, fallback και house ads, μέτρηση served / viewable / clicks, dashboard ανά campaign και CSV export. | AD 01, AD 02 |
| D8 | **Leads**: newsletter opt-in (double opt-in μέσω ESP), advisor lead form με ρητή συγκατάθεση, consent log, export CSV ή webhook προς CRM/email. | LEAD 01 |
| D9 | **Events** με external registration link, UTM, click tracking και promoted event slot (AD-06). | EVT 01 |
| D10 | **SEO**: canonical URLs, sitemap.xml (με news sitemap), robots, JSON-LD (NewsArticle, Event, EducationalOrganization, BreadcrumbList), OG/Twitter previews, διαχείριση redirects από το CMS. | SEO 01 |
| D11 | **Analytics με επίγνωση συγκατάθεσης**: cookieless analytics (Plausible, EU) για reach και engagement, χωρίς banner για τα βασικά. Προαιρετικό GA4 μόνο με consent. Custom events για utilities, conversion και monetization, χωρίς προσωπικά δεδομένα στα properties. | AN 01 |
| D12 | **Ops**: staging + production, CI (lint, typecheck, tests, Lighthouse budget), ημερήσια backups και **καταγεγραμμένο restore test**, uptime monitoring, error tracking, τεκμηρίωση, runbooks. Όλοι οι λογαριασμοί στο όνομα της LABORA. | OPS 01 |

### 2.2 Εκτός scope Φάσης 1 (ρητά)

Login και προφίλ (Φάση 1B), υπολογιστής μορίων, Holland test, λίστα προτίμησης (Φάση 2), Fainder AI / chatbot,
programmatic, ad exchange ή targeting ανά χρήστη, πληρωμές, συνδρομές, ticketing, native app, πλήρες ιστορικό
βάσεων πέρα από 2 έτη, μετεγγραφές και πρόγραμμα σπουδών στην καρτέλα (μόνο το schema είναι έτοιμο), το
περιεχόμενο καθαυτό (συγγραφή άρθρων), νομικά κείμενα, rate card, φωτογραφίες και stock.

### 2.3 Εξαρτήσεις από τη LABORA

| Εξάρτηση | Πότε χρειάζεται | Επίπτωση αν καθυστερήσει |
|---|---|---|
| Πρόσβαση στο demo (source) και σε όλα τα datasets | Ημέρα 1 της Φάσης 0 | Δεν ολοκληρώνεται το audit |
| Απόφαση για όνομα και domain (ή αποδοχή launch σε προσωρινό) | Τέλος Φάσης 0 | Καθυστερεί το SEO setup, όχι την ανάπτυξη |
| Brand assets σε vector (λογότυπα, χρώματα, γραμματοσειρές) | Εβδομάδα 1 | Καθυστερεί το UI |
| Επαληθευμένα datasets βάσεων και ΕΒΕ 2025 και 2026 από επίσημες πηγές | Εβδομάδα 4 | Οι καρτέλες βγαίνουν με «υπό επαλήθευση» ή χωρίς δεδομένα |
| Λίστα πηγών για το source inbox | Εβδομάδα 3 | Το inbox ξεκινά με λιγότερες πηγές |
| Νομικά κείμενα (όροι, privacy, cookies, ανήλικοι, sponsored policy) | Εβδομάδα 8 | **Μπλοκάρει το launch** |
| Λογαριασμοί (hosting, DB, ESP, analytics, domain) στο όνομα της LABORA | Εβδομάδα 2 | Δουλεύουμε σε προσωρινούς και κάνουμε transfer |
| Editor για UAT και αρχικό περιεχόμενο (≥ 20 items) | Εβδομάδες 9–10 | Η homepage βγαίνει άδεια |
| Μία πιλοτική καμπάνια (ακόμη και house ad ή φιλικός συνεργάτης) | Εβδομάδα 10 | Το AD 02 δεν δοκιμάζεται σε πραγματικές συνθήκες |
| Ένας υπεύθυνος απόφασης με χρόνο απάντησης ≤ 2 εργάσιμες | Όλη τη διάρκεια | Μετατοπίζονται τα milestones |

### 2.4 Κριτήρια αποδοχής

Υιοθετούμε αυτούσια τα κριτήρια της §9.1 του brief και τα κάνουμε μετρήσιμα:

1. Ένας editor χωρίς τεχνικές γνώσεις δημοσιεύει (και προγραμματίζει) 1 νέο, 1 άρθρο, 1 προθεσμία, 1 event και 1 χορηγούμενο item **σε ≤ 20 λεπτά συνολικά**, χωρίς developer.
2. Σε mobile (360×800) κάθε κύρια σελίδα οδηγεί σε Νέα, Βάσεις ή Σύμβουλο με **≤ 2 taps**. Αυτό ελέγχεται με αυτοματοποιημένο Playwright test.
3. **Το 100% των τμημάτων** στις λίστες ανοίγει καρτέλα με source URL, έτος δεδομένων και verified date. Ο έλεγχος γίνεται αυτόματα στο CI.
4. Μια καμπάνια με ημερομηνίες στο μέλλον **ενεργοποιείται και λήγει αυτόματα** και η αναφορά της εξάγεται σε CSV, χωρίς deploy.
5. Newsletter και advisor leads αποθηκεύονται με timestamp, κείμενο συγκατάθεσης (version) και πηγή σελίδας, και φτάνουν στη LABORA (export ή webhook).
6. **CLS < 0.1** και καμία οριζόντια κύλιση στα 360 / 768 / 1280 / 1440 px, σε όλα τα templates και με ενεργές διαφημίσεις. LCP < 2.5 s σε 4G (p75).
7. Repository, domain, βάση, storage, analytics, ESP και production accounts ανήκουν στη LABORA, όπως φαίνεται σε checklist παράδοσης.
8. WCAG 2.2 AA για navigation, φόρμες, focus και contrast. Ελέγχεται με axe (0 critical) και χειροκίνητο keyboard test.
9. Επιτυχημένο restore test από backup σε staging, με χρόνο ανάκτησης καταγεγραμμένο.

---

## 3. Demo audit — μέθοδος (Φάση 0)

Δεν έχουμε ακόμη πρόσβαση στο demo, γι' αυτό **δεν προκαταλαμβάνουμε reuse ή rebuild**. Στη Φάση 0
αξιολογούμε κάθε module με τα ίδια κριτήρια και δίνουμε γραπτή αιτιολόγηση:

| Module του demo | Πιθανή απόφαση (υπόθεση) | Κριτήριο |
|---|---|---|
| UX flows, IA, interactions | **Reuse ως spec**: γίνονται acceptance tests | Αξία ως reference ανεξάρτητα από τον κώδικα |
| Visual components | Reuse αν είναι component-based, προσβάσιμα και χωρίς hardcoded δεδομένα, αλλιώς rebuild στο design system | Τεχνικό χρέος, a11y, CLS |
| Datasets (453 canonical, 766 εγγραφές ΓΕΛ, 454 συντελεστές, 43 ειδικές ΕΒΕ, 453 μετεγγραφές) | **Reuse ως seed** μέσω του import pipeline | Συνέπεια IDs, πηγές, έτη |
| Calculator και test | Αρχειοθέτηση ως reference για τη Φάση 2 | Δεν είναι στο scope της Φάσης 1 |
| Περιεχόμενο (11 άρθρα, νέα, προθεσμίες, events) | Migration ως πρώτη δοκιμή του content model | Δικαιώματα εικόνων |

**Πρώτες παρατηρήσεις από τους αριθμούς του Παραρτήματος Α:**
- Οι κατάλογοι ΓΕΛ έχουν 144 + 258 + 167 + 197 = **766 εγγραφές** για 453 canonical τμήματα. Αυτό δείχνει ότι τα τμήματα επαναλαμβάνονται σε πολλά πεδία, και το schema το καλύπτει ρητά (`offering` ανά τμήμα, έτος και διαδρομή). Θα ελέγξουμε ότι κάθε μία από τις 766 εγγραφές αντιστοιχίζεται σε ακριβώς ένα canonical ID.
- Οι συντελεστές είναι **454 records ενώ τα τμήματα 453**. Υπάρχει δηλαδή ένα πλεονάζον ή διπλό record, που πρέπει να εξηγηθεί πριν φτιαχτεί ο calculator.
- Τα ΕΠΑΛ datasets δεν αναφέρονται στο παράρτημα. Πρέπει να επιβεβαιωθεί αν υπάρχουν, γιατί είναι Must για το DATA 02.

Παραδοτέο του audit: αναφορά 8–12 σελίδων με πίνακα reuse ή rebuild, data quality report ανά dataset (διπλότυπα, ορφανά IDs, κενά πηγής ή έτους) και επικαιροποιημένη εκτίμηση.

---

## 4. Αρχιτεκτονική (σύνοψη)

Λεπτομέρειες στο [02-architektoniki.md](02-architektoniki.md).

- **Modular monolith**: Next.js (App Router, TypeScript) με ενσωματωμένο **Payload CMS 3** (open source, MIT, τρέχει στην ίδια εφαρμογή).
- **PostgreSQL 16** (EU region): content (Payload), canonical εκπαιδευτικά δεδομένα (schema `edu`), μετρήσεις διαφημίσεων (schema `ads`).
- **Αναζήτηση**: Postgres FTS με unaccent και pg_trgm. Δεν χρειάζεται εξωτερικό cluster.
- **Hosting**: Vercel (region Frankfurt) και managed Postgres EU (Neon ή Supabase), object storage S3-compatible (π.χ. Cloudflare R2) για media. Εναλλακτικά, self-hosted σε Hetzner (Docker) αν προτιμάται χαμηλότερο recurring κόστος. Η εφαρμογή είναι ίδια, χωρίς lock-in.
- **Email / newsletter**: Brevo (EU) με double opt-in.
- **Auth (Φάση 1B)**: Better Auth ή Auth.js μέσα στην ίδια εφαρμογή και βάση (Google και magic link ή OTP), χωρίς εξωτερικό identity lock-in.
- **Analytics**: Plausible (cookieless, EU) και first-party ad metrics.

---

## 5. Χρονοδιάγραμμα

| Εβδομάδα | Milestone | Demo / έλεγχος |
|---|---|---|
| 0–2 | **Φάση 0**: audit, sitemap, content model, schema, ad inventory, backlog, οριστική προσφορά | Παρουσίαση ευρημάτων και απόφαση για Go |
| 1–2 (Φ1) | Θεμέλια: repo, CI, environments, Payload, design tokens, header και drawer | Clickable shell σε staging |
| 3–4 | Content types, editorial workflow, homepage, λίστες, άρθρο | **Demo 1**: ο editor δημοσιεύει |
| 5–6 | Import pipeline, Σχολές και Βάσεις, καρτέλα τμήματος, αναζήτηση | **Demo 2**: τμήματα και βάσεις με πηγές |
| 7–8 | Διαφημιστική μονάδα, metrics, leads, events, source inbox | **Demo 3**: πιλοτική καμπάνια από άκρη σε άκρη |
| 9 | SEO, analytics, a11y και performance hardening, legal pages | Lighthouse και axe report |
| 10 | **UAT** με editors LABORA, διορθώσεις | Sign-off στα κριτήρια της §2.4 |
| 11 | Content loading, launch, monitoring | **Go-live** |
| 12–15 | Hypercare (εγγύηση), Φάση 1B αν εγκριθεί | — |

Σύνολο: **~2 εβδομάδες Φάση 0 και ~11 εβδομάδες Φάση 1 μέχρι το launch**, με την προϋπόθεση ότι η LABORA απαντά στις εξαρτήσεις στον χρόνο τους.

---

## 6. Οικονομική πρόταση (ενδεικτική)

> **Σημαντική παραδοχή:** οι τιμές υπολογίζονται με ενδεικτικό blended rate **€400 / ανθρωποημέρα**. Ο αριθμός
> ημερών είναι η ουσία της εκτίμησης. Το τελικό κόστος οριστικοποιείται ως **capped** ανά φάση
> στο τέλος της Φάσης 0.

| Φάση | Effort (ανθρωποημέρες) | Ενδεικτικό κόστος | Μοντέλο |
|---|---|---|---|
| **Φάση 0** Audit και ευθυγράμμιση | 8–10 | €3.200–4.000 | Fixed. **Πιστώνεται 100%** αν ακολουθήσει Φάση 1 |
| **Φάση 1** Media and commercial core | 60–75 | €24.000–30.000 | Capped, πληρωμή ανά milestone (30/30/30/10) |
| **Φάση 1B** Ταυτότητα και retention | 15–20 | €6.000–8.000 | Capped. Μπορεί να ενταχθεί στη Φάση 1 χωρίς να μετακινηθεί το launch μόνο αν εγκριθεί έως την εβδομάδα 4 |
| **Φάση 2** Εργαλεία απόφασης | 40–55 | €16.000–22.000 | Capped, μετά από νέο change request |
| Επιλογή: Newsletter templates και αυτοματισμοί | 4–6 | €1.600–2.400 | Fixed |
| Επιλογή: Sponsor dashboard (read-only login για διαφημιζόμενο) | 6–8 | €2.400–3.200 | Fixed |
| Επιλογή: Πλήρεις καρτέλες με μετεγγραφές στη Φάση 1 | 5–7 | €2.000–2.800 | Fixed |
| Συντήρηση μετά την εγγύηση | — | Retainer 2–4 ημέρες / μήνα | Μηνιαίο |

**Κατανομή effort Φάσης 1 (ενδεικτικά, μέσο σενάριο 68 ημέρες):** θεμέλια και DevOps 8, CMS και content types 12,
δημόσιο site και UX 16, σχολές, βάσεις και imports 10, αναζήτηση 4, διαφημίσεις και metrics 8, leads, events και SEO 5,
QA, a11y, performance και UAT 5.

Τι **δεν** περιλαμβάνουν οι τιμές: τρίτες υπηρεσίες (§8), νομικά κείμενα, συγγραφή περιεχομένου, επαλήθευση
datasets από επίσημες πηγές (ευθύνη LABORA, εμείς παρέχουμε τα validation reports), φωτογραφίες.
Η χρήση AI ως εργαλείο παραγωγικότητας μας **δεν χρεώνεται** χωριστά (§11 του brief).

---

## 7. Ομάδα

| Ρόλος | Ευθύνη | Κατανομή |
|---|---|---|
| Tech lead / full-stack | Αρχιτεκτονική, data model, imports, ads module, code review | ~60% |
| Full-stack / frontend | Δημόσιο site, components, a11y, performance | ~100% στις εβδομάδες 3–10 |
| UX/UI designer | Design system βασισμένο στο demo, templates, ad slot specs | ~30% στις εβδομάδες 1–6 |
| QA | Test plan, Playwright, cross-device, UAT support | ~25% στις εβδομάδες 7–11 |
| DevOps | Environments, backups, monitoring (μέρος του tech lead) | — |
| Project owner (πλευρά συνεργάτη) | Backlog, εβδομαδιαίο status, demos, change requests | ~10% |

Από την πλευρά της LABORA χρειαζόμαστε **product owner** (αποφάσεις, προτεραιότητες) και **editor** (UAT, περιεχόμενο).

---

## 8. Recurring κόστη (εκτιμήσεις στο launch, τιμές 2026, χωρίς ΦΠΑ)

| Υπηρεσία | Επιλογή | Ενδεικτικό μηνιαίο |
|---|---|---|
| Hosting εφαρμογής | Vercel Pro (1 seat) | ~$20 + usage |
| PostgreSQL | Neon Launch ή Supabase Pro (EU) | ~$20–25 |
| Media storage και CDN | Cloudflare R2 | < $5 |
| Newsletter / transactional email | Brevo Starter (ανάλογα με επαφές και αποστολές) | ~€10–30 |
| Analytics | Plausible (ανάλογα με pageviews) | ~€10–20 |
| Error tracking | Sentry Developer (δωρεάν) ή Team | €0–26 |
| Uptime | Better Stack ή UptimeRobot (δωρεάν tier) | €0–10 |
| Domain | .gr | ~€15–30 / έτος |
| AI βοήθεια στο source inbox (προαιρετικό) | Claude API, χρήση μόνο από editors | ~€5–20 |
| **Σύνολο** | | **~€70–160 / μήνα** |

Εναλλακτική με self-hosting (Hetzner VPS, managed Postgres και backups): ~€30–50 / μήνα, με λίγο περισσότερο effort συντήρησης.
Δεν απαιτούνται άδειες λογισμικού (Payload, Next.js και PostgreSQL είναι open source).

---

## 9. Handover και ιδιοκτησία

- Repository στον οργανισμό GitHub της LABORA από την ημέρα 1. Εμείς είμαστε collaborators.
- Όλοι οι λογαριασμοί (hosting, DB, storage, ESP, analytics, domain, Sentry) ανοίγουν με email της LABORA, κι εμείς έχουμε πρόσβαση με least privilege.
- Παραδίδουμε: πηγαίο κώδικα, migrations, import scripts με παραδείγματα αρχείων, seed, αυτοματοποιημένα tests, README για setup, architecture decision records, runbooks (deploy, rollback, restore, import νέου έτους, νέα καμπάνια), εγχειρίδιο editor και sales.
- Εκπαίδευση: 2 sessions (editors, sales/ads) με καταγραφή.
- **Εγγύηση 60 ημερών** μετά το go-live για defects που αποκλίνουν από τα συμφωνημένα acceptance criteria.

---

## 10. Επόμενα βήματα

1. Αποστολή demo (source), datasets και brand assets.
2. Ένταξη της Φάσης 0 (fixed, πιστώνεται) και kickoff workshop 2 ωρών.
3. Στο τέλος της Φάσης 0: audit report, οριστικό backlog και **capped** προσφορά Φάσης 1, απόφαση Go / No-go.
