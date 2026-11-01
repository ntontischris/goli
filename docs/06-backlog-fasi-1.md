# Backlog Φάσης 1 — epics, stories, acceptance criteria

Εκτιμήσεις σε ανθρωποημέρες (ΑΗ). Σύνολο ≈ 68 ΑΗ (εύρος 60–75). Αντιστοίχιση με τα IDs του brief §9.

## E0 — Θεμέλια και Ops (8 ΑΗ) · OPS 01

| Story | AC | ΑΗ |
|---|---|---|
| Repository, CI (lint, typecheck, unit, e2e, Lighthouse budget) | Το PR δεν γίνεται merge αν αποτύχει κάποιο check | 2 |
| Environments staging και production, preview ανά PR | Το URL του staging δοθεί στη LABORA. Η production είναι σε λογαριασμό LABORA | 2 |
| Backups, restore test, uptime, Sentry | Υπάρχει καταγεγραμμένο restore σε staging με χρόνο ανάκτησης | 2 |
| Design tokens και βασικά components (από το brand και το demo) | Το contrast περνά AA. Τα λογότυπα δεν παραμορφώνονται σε κανένα breakpoint | 2 |

## E1 — CMS και editorial (12 ΑΗ) · CMS 01, CMS 02

| Story | AC | ΑΗ |
|---|---|---|
| Content types: News, Article, Deadline, Event, LaboraUpdate, Sponsored, Author, Topic, Partner | Όλα τα πεδία της [05](05-sitemap-content-model.md) υπάρχουν, με validation | 4 |
| Ρόλοι admin, editor, sales, viewer | Ο sales δεν δημοσιεύει editorial. Ο editor δεν βλέπει leads | 1 |
| Drafts, live preview, scheduled publish και unpublish | Ένα item με προγραμματισμένη ώρα εμφανίζεται ± 5 λεπτά | 2 |
| Media library με crops, alt, attribution και πεδίο δικαιωμάτων | Δεν γίνεται publish εικόνας χωρίς alt και attribution | 2 |
| Source inbox (RSS και σελίδες, dedup, convert to draft, προαιρετική πρόταση AI) | Καμία αυτόματη δημοσίευση. Η πρόταση AI φέρει σήμανση | 3 |

## E2 — Δημόσιο site και UX (16 ΑΗ) · UX 01, UX 02, BR 01

| Story | AC | ΑΗ |
|---|---|---|
| Header sticky και mobile drawer | ≤ 2 taps σε Νέα, Βάσεις, Σύμβουλο (Playwright). Focus trap και Esc στο drawer | 2 |
| Homepage (blocks, hero ≤ 3 slides, λωρίδα τελευταίων) | Είναι διαμορφώσιμη από το CMS. CLS < 0.1 | 4 |
| Λίστες ανά τύπο με φίλτρα κατηγορίας μέσα στη λίστα | Το φίλτρο αλλάζει το URL (shareable) χωρίς back | 2 |
| Templates σελίδων (νέο, άρθρο, προθεσμία, event, update, sponsored, topic, partner, author) | Κάθε template έχει related και «επόμενο βήμα» | 5 |
| Καταστάσεις loading, empty, error, success | Υπάρχουν σε κάθε διαδραστικό component | 1 |
| Responsive QA στα 360, 768, 1280 και 1440 | Καμία οριζόντια κύλιση. Οι πίνακες γίνονται cards στο mobile | 2 |

## E3 — Σχολές και Βάσεις (10 ΑΗ) · DATA 01, DATA 02

| Story | AC | ΑΗ |
|---|---|---|
| Migrations του schema `edu` και seed διαδρομών πρόσβασης | Constraints όπως στο `db/schema.sql` | 1 |
| Import CLI και admin upload (validate, dry-run, apply, rollback) | Το ίδιο αρχείο δεύτερη φορά δεν αλλάζει τίποτα. Ο rollback επαναφέρει | 4 |
| Σελίδα `/vaseis` με ΓΕΛ, ΕΠΑΛ και Ένστολα, φίλτρα και ταξινόμηση | Αλφαβητικά ή κατά βάση. Mobile cards | 2 |
| Καρτέλα τμήματος | Ενότητες Ταυτότητα, Πρόσβαση, Εισαγωγή (2 έτη), Προϋποθέσεις, Αξιοπιστία. Το 100% των καρτελών έχει πηγή και έτος (CI test) | 2 |
| CTA σύμβουλου και slot AD-05 στην καρτέλα | Το partner block είναι οπτικά ξεχωριστό από τα επίσημα δεδομένα | 1 |

## E4 — Αναζήτηση (4 ΑΗ) · SRCH 01

| Story | AC | ΑΗ |
|---|---|---|
| Ενιαίο index (content και departments), unaccent και trigram | Το «πληροφορικης» βρίσκει το «Πληροφορικής». Ένα τυπογραφικό λάθος επιστρέφει αποτέλεσμα | 2 |
| UI με ομαδοποίηση ανά τύπο, κενή κατάσταση με προτάσεις | p95 < 300 ms | 2 |

## E5 — Διαφημίσεις (8 ΑΗ) · AD 01, AD 02

| Story | AC | ΑΗ |
|---|---|---|
| Collections Advertiser, Campaign, Creative, Placement, House ad | Δείτε το [04](04-diafimiseis.md). Validation διαστάσεων και label | 2 |
| AdSlot component (δεσμευμένο μέγεθος, label, fallback) | CLS 0 με και χωρίς καμπάνια | 2 |
| Delivery (priority, weight, ημερομηνίες, topic) και click redirect με UTM | Η καμπάνια ενεργοποιείται και λήγει χωρίς deploy | 2 |
| Beacons (served, viewable, click), rollup, report και CSV | Τα νούμερα του report συμφωνούν με δοκιμαστικό σενάριο | 2 |

## E6 — Leads, Events, SEO, Analytics (5 ΑΗ) · LEAD 01, EVT 01, SEO 01, AN 01

| Story | AC | ΑΗ |
|---|---|---|
| Newsletter (double opt-in μέσω Brevo) και advisor form με consent log | Αποθηκεύονται κείμενο συγκατάθεσης (version), ώρα και πηγή. Export ή webhook | 2 |
| Events με external registration και UTM | Το click στην εγγραφή καταγράφεται | 0.5 |
| SEO: sitemaps (και news), JSON-LD, OG, redirects από το CMS | Έγκυρο στο Rich Results Test | 1.5 |
| Analytics wrapper με allow-list και τα events του brief §12 | Δεν μπαίνει PII ή ελεύθερο κείμενο στα properties (unit test) | 1 |

## E7 — QA, a11y, UAT, launch (5 ΑΗ)

| Story | AC | ΑΗ |
|---|---|---|
| Accessibility pass (axe και πληκτρολόγιο) | 0 critical. Ορατό focus | 1.5 |
| Performance pass | LCP < 2.5 s p75 4G, CLS < 0.1 | 1 |
| UAT με editors, διορθώσεις | Sign-off στα κριτήρια της §2.4 της απάντησης | 1.5 |
| Launch checklist, DNS, εκπαίδευση, handover | Ownership checklist υπογεγραμμένο | 1 |
