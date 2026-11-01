# Advertising plan — placements, campaigns, μετρήσεις

## 1. Αρχή

Κάθε πώληση γίνεται **μόνο από το CMS**. Ο κώδικας γνωρίζει placements, όχι καμπάνιες. Μια νέα καμπάνια, ένα
νέο creative, μια ημερομηνία ή μια αλλαγή label δεν χρειάζονται deploy.

## 2. Inventory (Φάση 1)

| Κωδικός | Θέση | Desktop | Mobile | Τύποι creative | Κανόνες |
|---|---|---|---|---|---|
| AD-01 | Κάτω από header | 970×90 / 728×90 | 320×100 | display | Δεσμευμένο ύψος, εκτός sticky header |
| AD-02 | Homepage, μετά το 1ο editorial block | 300×250 tile ή native card | ίδιο | display, native | Ένα ανά viewport |
| AD-03 | Λίστες Νέων και Άρθρων (in-feed) | native card | native card | native | Κάθε 6 items, μέγιστο 2 ανά σελίδα |
| AD-04 | Μέσα ή μετά από άρθρο | 728×90 ή native | 300×250 | display, native | Μπαίνει μόνο μετά από παράγραφο ≥ 3 και ποτέ πριν από πίνακα ή λίστα |
| AD-05 | Βάσεις και καρτέλες τμημάτων | partner block | partner block | native («Προβεβλημένος συνεργάτης») | Οπτικά διαχωρισμένο από τα επίσημα δεδομένα, ποτέ μέσα στον πίνακα βάσεων |
| AD-06 | Προθεσμίες και Εκδηλώσεις | promoted event card | ίδιο | promoted event | Ξεχωριστή ενότητα από τις επίσημες προθεσμίες |
| AD-07 | Newsletter | header sponsor ή section | — | image + link | Campaign tagging (UTM) ανά έκδοση |
| AD-08 | Mobile content flow | — | 300×250 inline | display | Όχι overlay, όχι sticky |

Όλα τα slots έχουν **δεσμευμένες διαστάσεις** (CSS `aspect-ratio` ανά breakpoint). Όταν δεν υπάρχει ενεργή καμπάνια, εμφανίζεται
fallback ή house ad της LABORA, ώστε **να μη μένει ποτέ κενό ή να συμπτύσσεται το layout**. Αυτό εξασφαλίζει CLS ≈ 0.

## 3. Μοντέλο στο CMS (Payload collections)

**Advertiser**: όνομα, τύπος (πανεπιστήμιο, κολέγιο, οργανισμός, φορέας, φοιτητική πρωτοβουλία), επαφή, σύνδεση με Partner page.

**Campaign**: όνομα, advertiser, `starts_at`, `ends_at`, status (draft, scheduled, active, paused, ended, υπολογίζεται από τις ημερομηνίες),
priority (1–10), placements (πολλαπλά), προαιρετικά topics/sections (θεματική στόχευση **ανά περιεχόμενο, όχι ανά χρήστη**),
label (`Διαφήμιση`, `Χορηγούμενο`, `Προβεβλημένος συνεργάτης`, υποχρεωτικό), disclaimer, UTM defaults, προαιρετικό στόχο impressions, σημειώσεις.

**Creative**: campaign, format, εικόνα desktop, εικόνα mobile, alt text (υποχρεωτικό), τίτλος/κείμενο/CTA για native, target URL, UTM overrides, weight.

**Placement**: κωδικός (AD-01…), όνομα, επιτρεπτά formats, διαστάσεις, fallback creative, enabled.

**House ad**: creatives της LABORA (σύμβουλος, newsletter, events) που χρησιμοποιούνται ως fallback.

Validation στην αποθήκευση: διαστάσεις creative ανάλογες με το placement, υποχρεωτικό label και alt, `ends_at > starts_at`, προειδοποίηση επικάλυψης με άλλη καμπάνια ίδιας προτεραιότητας.

## 4. Delivery

1. Server-side: για κάθε placement στη σελίδα, επιλέγονται οι ενεργές καμπάνιες (ημερομηνίες, status, ταίριασμα topic). Επικρατεί η υψηλότερη priority και μεταξύ ίσων γίνεται rotation κατά weight.
2. Τα επιλεγμένα creatives ενσωματώνονται στο cached HTML. Το cache ανανεώνεται κάθε 5 λεπτά και σε κάθε αλλαγή καμπάνιας.
3. Το click περνά από `/go/{creativeId}?p=AD-03`, που καταγράφει το click και κάνει 302 στο target URL με UTM (`utm_source=faind&utm_medium=display&utm_campaign={slug}&utm_content={placement}`).
4. Όλα τα links έχουν `rel="sponsored noopener"`.

## 5. Μέτρηση

| Μετρική | Ορισμός |
|---|---|
| **Served** | Το creative αποδόθηκε στη σελίδα (beacon κατά το mount) |
| **Viewable impression** | ≥ 50% του creative ορατό για ≥ 1 συνεχές δευτερόλεπτο (IAB/MRC) μέσω IntersectionObserver |
| **Click** | Πέρασμα από το `/go/` redirect, με dedup ίδιου visitor hash μέσα σε 10 δευτερόλεπτα |
| **CTR** | clicks / viewable impressions |

Ροή: τα beacons γράφονται batched μέσω `navigator.sendBeacon` στο `ads.event_raw`. Ένα ωριαίο rollup γεμίζει το `ads.daily_stats`, και τα raw διαγράφονται μετά από 30 ημέρες. Bot filtering γίνεται με user-agent list και αποκλεισμό prefetch.

Τα ad metrics είναι first-party και cookieless, άρα δεν χρειάζονται cookie consent. Η ορατότητα μετριέται με τον ίδιο τρόπο για όλους τους διαφημιζόμενους.

## 6. Reporting

- Admin view ανά καμπάνια: ημερήσιο γράφημα, πίνακας ανά placement και device, σύνολα, CTR, pacing σε σχέση με τον στόχο.
- **Export CSV** και printable report (PDF μέσω browser print) για αποστολή στον διαφημιζόμενο.
- Leads από promoted events: μετριούνται τα clicks προς το external registration. Τα πραγματικά leads μόνο εφόσον ο partner επιστρέψει δεδομένα ή χρησιμοποιηθεί φόρμα LABORA με consent (Φάση 3).

## 7. Χορηγούμενο περιεχόμενο

Ξεχωριστός τύπος `Sponsored` (όχι flag πάνω στο άρθρο): sponsor (Advertiser), disclosure text, campaign period, author.
Φαίνεται με διακριτό label σε κάρτες και σελίδα, έχει `rel="sponsored"` και JSON-LD χωρίς σήμανση NewsArticle. Μπαίνει στο feed μόνο μέσω AD-02 και AD-03 ή στο θεματικό hub του sponsor. Ο editor πρέπει να το εγκρίνει πριν δημοσιευτεί.
