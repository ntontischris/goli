# LABORA / fAInd — Φάση 0: απάντηση στο Product Brief v1.0

Ενημερωτικό μέσο, οικοσύστημα υπηρεσιών LABORA και διαφημιστική πλατφόρμα για μαθητές, γονείς και φοιτητές.

Αυτό το repository περιέχει την απάντηση του τεχνολογικού συνεργάτη στο brief (ενότητα 13) και τα πρώτα
παραδοτέα της Φάσης 0. Ο κώδικας της Φάσης 1 θα προστεθεί εδώ μετά την έγκριση.

| Έγγραφο | Περιεχόμενο |
|---|---|
| [docs/01-apantisi-synergati.md](docs/01-apantisi-synergati.md) | **Κύρια απάντηση**: κατανόηση, scope Φάσης 1, εξαρτήσεις, acceptance criteria, demo audit, χρονοδιάγραμμα, κοστολόγηση ανά φάση, ομάδα, recurring κόστη, handover |
| [docs/02-architektoniki.md](docs/02-architektoniki.md) | Stack, modules, trade-offs, cache, security, privacy για ανήλικους |
| [docs/03-dedomena-scholon.md](docs/03-dedomena-scholon.md) | Canonical data model, import pipeline, σειρά seed, ετήσια διαδικασία |
| [docs/04-diafimiseis.md](docs/04-diafimiseis.md) | Ad inventory AD-01…AD-08, CMS model, delivery, μέτρηση (viewable), reporting |
| [docs/05-sitemap-content-model.md](docs/05-sitemap-content-model.md) | URLs, navigation, content types, homepage blocks |
| [docs/06-backlog-fasi-1.md](docs/06-backlog-fasi-1.md) | Epics και stories με AC και εκτίμηση (≈ 68 ΑΗ) |
| [docs/07-kindynoi-anoixta.md](docs/07-kindynoi-anoixta.md) | Κίνδυνοι, παραδοχές, αποφάσεις που χρειάζονται από τη LABORA |
| [db/schema.sql](db/schema.sql) | PostgreSQL schema (edu / ads / ops), ελεγμένο σε PostgreSQL 16 |

Δοκιμή του schema σε τοπικό PostgreSQL:

```bash
createdb faind && psql -d faind -v ON_ERROR_STOP=1 -f db/schema.sql
```
