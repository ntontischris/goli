# Sitemap και content model (Φάση 1)

## 1. Sitemap και URLs

Τα URLs είναι σε greeklish για αναγνωσιμότητα και αντοχή στα share. Μένουν σταθερά, και κάθε αλλαγή slug δημιουργεί αυτόματα 301.

| URL | Σελίδα | Rendering |
|---|---|---|
| `/` | Homepage | ISR |
| `/nea`, `/nea/{slug}` | Νέα (λίστα με φίλτρο κατηγορίας, σελίδα) | ISR |
| `/arthra`, `/arthra/{slug}` | Άρθρα LABORA | ISR |
| `/prothesmies`, `/prothesmies/{slug}` | Προθεσμίες (ενεργές, επερχόμενες, έληξαν) | ISR (ανά ώρα λόγω status) |
| `/ekdiloseis`, `/ekdiloseis/{slug}` | Εκδηλώσεις και webinars | ISR |
| `/labora`, `/labora/{slug}` | LABORA Updates | ISR |
| `/chorigoumeno/{slug}` | Χορηγούμενο περιεχόμενο | ISR |
| `/vaseis` | Βάσεις: επιλογή ΓΕΛ / ΕΠΑΛ / Ένστολα | SSG |
| `/vaseis/gel/{pedio}`, `/vaseis/epal/{tomeas}`, `/vaseis/enstola` | Λίστες με φίλτρα και ταξινόμηση | SSG + client filters |
| `/sxoles/{slug}` | Καρτέλα τμήματος (canonical) | SSG |
| `/thema/{slug}` | Θεματικό hub (π.χ. πληροφορική, υγεία) | ISR |
| `/synergates/{slug}` | Partner spotlight | ISR |
| `/symvoulos` | Advisor lead form και περιγραφή υπηρεσίας | SSG |
| `/anazitisi?q=` | Ενιαία αναζήτηση | SSR |
| `/newsletter` | Εγγραφή και θεματικές επιλογές | SSG |
| `/syntaktes/{slug}` | Σελίδα συντάκτη (E-E-A-T) | ISR |
| `/oroi`, `/aporrito`, `/cookies`, `/diafimisi` | Νομικά και πολιτική διαφήμισης | SSG |

Header (desktop, sticky): **Νέα · Άρθρα · Βάσεις · Προθεσμίες · Εκδηλώσεις** · αναζήτηση · [Προφίλ, Φάση 1B] · **Σύμβουλος** (κύριο CTA).
Mobile: logo, αναζήτηση, Σύμβουλος, ☰ (drawer με τα ίδια destinations και quick links «Σχολές και Βάσεις», «Τελευταία νέα»). Κάθε στόχος είναι προσβάσιμος σε ≤ 2 taps.

## 2. Content types

Κοινά πεδία όλων (το CMS 02): `title`, `slug`, `summary`, `hero_image` (με attribution και δικαιώματα), `published_at`, `updated_at`,
`status` (draft, scheduled, published, archived), `category`, `topics[]`, `author`, `sources[]` (τίτλος, URL, ημερομηνία), `related_items[]` (χειροκίνητα, με αυτόματο συμπλήρωμα ανά topic), `related_departments[]`, `seo` (meta title, description, OG image, canonical override, noindex).

| Τύπος | Επιπλέον πεδία |
|---|---|
| **News** | `source_kind` (επίσημη, μέσο, LABORA), `is_breaking`, `featured_until` (για τα hero slides) |
| **Article** | `body` (rich text με blocks: callout, πίνακας, CTA σύμβουλου, ενσωμάτωση τμήματος), `reading_time` (υπολογίζεται αυτόματα), `audience[]` |
| **Deadline** | `opens_at`, `closes_at`, `status` (υπολογίζεται: upcoming, open, closing_soon (< 7 ημέρες), closed), `official_url`, `audience[]` (Β/Γ Λυκείου, γονείς, φοιτητές…), `action_label` |
| **Event** | `starts_at`, `ends_at`, `format` (φυσικό, online, υβριδικό), `venue`, `audience[]`, `programme`, `registration_url`, `organizer` (LABORA ή Partner), `is_promoted` |
| **LaboraUpdate** | `kind` (έργο, σεμινάριο, υπηρεσία, συνεργασία, ανακοίνωση) και πάντα label «LABORA» |
| **Sponsored** | `sponsor` (Advertiser), `disclosure`, `campaign_start`, `campaign_end`, `editor_approved_by` |
| **Author**, **Topic**, **Partner** | Partner: λογότυπο, περιγραφή, προγράμματα (links), σχετικά events και άρθρα, advertiser link |
| **SourceInboxItem** | URL, πηγή, fetched_at, εξαγόμενο κείμενο, hash για dedup, προτεινόμενα (περίληψη, tags) **με σήμανση «πρόταση AI»**, status (new, dismissed, converted → draft) |
| **Lead** | type (newsletter, advisor), email, όνομα, τηλέφωνο, ρόλος (μαθητής, γονέας, φοιτητής), τάξη, μήνυμα, consents[] (purpose, text_version, granted_at), source_page, utm. **Ορατό μόνο σε admin και ρόλο advisor** |

## 3. Homepage — blocks (σειρά)

1. Header και AD-01
2. Hero: έως 3 slides από News/Article με `featured_until`, με swipe και κουμπιά (χωρίς αυτόματο rotation που ενοχλεί την ανάγνωση)
3. Λωρίδα «Τελευταία»: 5 νέα και οι 3 πιο κοντινές ανοιχτές προθεσμίες, συμπαγής
4. Quick access: Σχολές και Βάσεις · Τελευταία νέα · Σύμβουλος
5. AD-02
6. Δύο στήλες: τελευταίο άρθρο και επόμενο event/webinar, μαζί με την επιλεγμένη λειτουργία LABORA (από το CMS)
7. Ροή νέων με AD-03 και newsletter block δίπλα στο σχετικό topic
8. LABORA Updates (με σήμανση)
9. Footer

Η σειρά και η επιλογή των blocks είναι **ρυθμιζόμενες από το CMS** (global «Homepage layout»), όχι hardcoded.
