-- =====================================================================
-- LABORA / fAInd — Canonical education data schema (Phase 0 proposal)
-- PostgreSQL 16+
--
-- Αρχές:
--  * Ένα σταθερό canonical record ανά τμήμα (department) — δεν αλλάζει ανά έτος.
--  * Τα ετήσια δεδομένα (κωδικός μηχανογραφικού, βάσεις, ΕΒΕ, συντελεστές)
--    ζουν σε πίνακες με admission_year.
--  * Ένα τμήμα μπορεί να ανήκει σε πολλές διαδρομές πρόσβασης
--    (ΓΕΛ πεδία, ΕΠΑΛ τομείς, ειδικές κατηγορίες).
--  * Κάθε κρίσιμη τιμή συνδέεται με source_record (provenance, verified date).
--  * Τα editorial / ads / leads δεδομένα διαχειρίζονται από το CMS
--    (Payload) στο ίδιο PostgreSQL, σε ξεχωριστό schema "cms".
--    Εδώ περιγράφονται μόνο οι πίνακες που δεν παράγει το CMS αυτόματα
--    ή που απαιτούν αυστηρά constraints.
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE SCHEMA IF NOT EXISTS edu;
CREATE SCHEMA IF NOT EXISTS ads;
CREATE SCHEMA IF NOT EXISTS ops;

-- ---------------------------------------------------------------------
-- Provenance
-- ---------------------------------------------------------------------
CREATE TABLE ops.import_batch (
  id              bigserial PRIMARY KEY,
  dataset         text        NOT NULL,          -- π.χ. 'bases', 'ebe', 'coefficients', 'transfers'
  admission_year  smallint,
  file_name       text        NOT NULL,
  file_sha256     char(64)    NOT NULL,
  started_at      timestamptz NOT NULL DEFAULT now(),
  finished_at     timestamptz,
  status          text        NOT NULL DEFAULT 'running'
                  CHECK (status IN ('running','validated','applied','failed','rolled_back')),
  rows_total      int,
  rows_inserted   int,
  rows_updated    int,
  rows_rejected   int,
  report          jsonb,                          -- validation report (errors / warnings ανά γραμμή)
  created_by      text        NOT NULL,
  UNIQUE (dataset, file_sha256)                   -- idempotency: ίδιο αρχείο δεν εφαρμόζεται δύο φορές
);

CREATE TABLE edu.source_record (
  id              bigserial PRIMARY KEY,
  title           text        NOT NULL,           -- π.χ. 'Βάσεις εισαγωγής 2026 — minedu.gov.gr'
  url             text        NOT NULL,
  publisher       text        NOT NULL,           -- π.χ. 'Υπουργείο Παιδείας'
  document_year   smallint,
  retrieved_at    date        NOT NULL,
  verified_at     date,                           -- τελευταία επιβεβαίωση από editor LABORA
  verified_by     text,
  notes           text
);

-- ---------------------------------------------------------------------
-- Σταθερές οντότητες
-- ---------------------------------------------------------------------
CREATE TABLE edu.city (
  id    serial PRIMARY KEY,
  name  text NOT NULL UNIQUE,
  slug  text NOT NULL UNIQUE
);

CREATE TABLE edu.institution (
  id           serial PRIMARY KEY,
  name         text NOT NULL UNIQUE,
  short_name   text,
  slug         text NOT NULL UNIQUE,
  kind         text NOT NULL CHECK (kind IN ('university','military','police','fire','coast_guard','merchant_navy','other')),
  website_url  text
);

-- Οικογένεια ομοειδών τμημάτων (κοινή περιγραφή, π.χ. "Πληροφορική")
CREATE TABLE edu.department_family (
  id           serial PRIMARY KEY,
  name         text NOT NULL UNIQUE,
  slug         text NOT NULL UNIQUE,
  description  text
);

-- Canonical τμήμα — ένα record, σταθερό URL, ανεξάρτητο από έτος
CREATE TABLE edu.department (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  legacy_id         text UNIQUE,                  -- ID από το demo dataset (453 εγγραφές)
  slug              text NOT NULL UNIQUE,         -- σταθερό URL: /sxoles/{slug}
  title             text NOT NULL,
  institution_id    int  NOT NULL REFERENCES edu.institution(id),
  city_id           int  NOT NULL REFERENCES edu.city(id),
  family_id         int  REFERENCES edu.department_family(id),
  is_uniformed      boolean NOT NULL DEFAULT false,  -- Ένστολα
  official_url      text,
  curriculum_url    text,
  summary           text,                         -- σύντομη περιγραφή αντικειμένου (editorial)
  status            text NOT NULL DEFAULT 'active' CHECK (status IN ('active','merged','discontinued')),
  merged_into_id    uuid REFERENCES edu.department(id),
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  search_tsv        tsvector,
  CHECK (status <> 'merged' OR merged_into_id IS NOT NULL)
);
CREATE INDEX department_search_idx ON edu.department USING gin (search_tsv);
CREATE INDEX department_title_trgm  ON edu.department USING gin (title gin_trgm_ops);

-- Διαδρομές πρόσβασης: ΓΕΛ πεδία (1–4), ΕΠΑΛ τομείς, ειδικές κατηγορίες
CREATE TABLE edu.access_route (
  id           serial PRIMARY KEY,
  track        text NOT NULL CHECK (track IN ('GEL','EPAL')),
  code         text NOT NULL,                     -- 'GEL-1'..'GEL-4', 'EPAL-<τομέας>'
  name         text NOT NULL,                     -- 'Ανθρωπιστικών, Νομικών και Κοινωνικών Επιστημών'
  sort_order   smallint NOT NULL DEFAULT 0,
  UNIQUE (track, code)
);

-- ---------------------------------------------------------------------
-- Ετήσια δεδομένα
-- ---------------------------------------------------------------------
CREATE TABLE edu.admission_year (
  year        smallint PRIMARY KEY CHECK (year BETWEEN 2000 AND 2100),
  status      text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published','archived')),
  published_at timestamptz
);

-- Προσφορά τμήματος σε συγκεκριμένο έτος & διαδρομή (π.χ. κωδικός μηχανογραφικού).
-- Ένα τμήμα μπορεί να έχει πολλές προσφορές το ίδιο έτος (ΓΕΛ πεδία, ΕΠΑΛ τομείς).
CREATE TABLE edu.offering (
  id               bigserial PRIMARY KEY,
  department_id    uuid     NOT NULL REFERENCES edu.department(id),
  admission_year   smallint NOT NULL REFERENCES edu.admission_year(year),
  access_route_id  int      NOT NULL REFERENCES edu.access_route(id),
  program_code     text,                          -- κωδικός μηχανογραφικού για το έτος/διαδρομή
  source_id        bigint   NOT NULL REFERENCES edu.source_record(id),
  import_batch_id  bigint   REFERENCES ops.import_batch(id),
  UNIQUE (department_id, admission_year, access_route_id)
);
CREATE INDEX offering_route_year_idx ON edu.offering (access_route_id, admission_year);

-- Αποτελέσματα εισαγωγής ανά προσφορά και κατηγορία υποψηφίων
CREATE TABLE edu.admission_result (
  id               bigserial PRIMARY KEY,
  offering_id      bigint   NOT NULL REFERENCES edu.offering(id) ON DELETE CASCADE,
  candidate_group  text     NOT NULL DEFAULT 'general'
                   CHECK (candidate_group IN ('general','10_percent','special','other')),
  base_score       int      CHECK (base_score BETWEEN 0 AND 20000), -- μόρια τελευταίου εισαχθέντα
  no_base          boolean  NOT NULL DEFAULT false,                  -- 'χωρίς βάση' / ελάχιστοι εισαχθέντες
  seats            int      CHECK (seats >= 0),
  source_id        bigint   NOT NULL REFERENCES edu.source_record(id),
  import_batch_id  bigint   REFERENCES ops.import_batch(id),
  UNIQUE (offering_id, candidate_group),
  CHECK (no_base OR base_score IS NOT NULL)
);

-- ΕΒΕ: συντελεστής ανά τμήμα/έτος (ορίζεται από ίδρυμα) + ελάχιστη βάση ανά πεδίο
CREATE TABLE edu.ebe (
  id               bigserial PRIMARY KEY,
  department_id    uuid     NOT NULL REFERENCES edu.department(id),
  admission_year   smallint NOT NULL REFERENCES edu.admission_year(year),
  access_route_id  int      REFERENCES edu.access_route(id),   -- NULL αν ισχύει για όλες τις διαδρομές
  ebe_coefficient  numeric(3,2) CHECK (ebe_coefficient BETWEEN 0.80 AND 1.20),
  min_score        numeric(6,3),                                -- ΕΒΕ σε κλίμακα 0–20 όπου εφαρμόζεται
  is_special       boolean  NOT NULL DEFAULT false,             -- ειδική ΕΒΕ (π.χ. ειδικά μαθήματα)
  special_subject  text,
  source_id        bigint   NOT NULL REFERENCES edu.source_record(id),
  import_batch_id  bigint   REFERENCES ops.import_batch(id),
  UNIQUE NULLS NOT DISTINCT (department_id, admission_year, access_route_id, is_special, special_subject)
);

-- Συντελεστές βαρύτητας (Phase 2 calculator) — μόνο μετά από επίσημο έλεγχο
CREATE TABLE edu.coefficient (
  id               bigserial PRIMARY KEY,
  offering_id      bigint   NOT NULL REFERENCES edu.offering(id) ON DELETE CASCADE,
  subject          text     NOT NULL,
  weight           numeric(4,2) NOT NULL CHECK (weight > 0),
  source_id        bigint   NOT NULL REFERENCES edu.source_record(id),
  UNIQUE (offering_id, subject)
);

-- Ειδικές προϋποθέσεις (ειδικά μαθήματα, αγωνίσματα, υγειονομικά, ύψος, ΠΚΕ ...)
CREATE TABLE edu.special_requirement (
  id               bigserial PRIMARY KEY,
  department_id    uuid     NOT NULL REFERENCES edu.department(id),
  admission_year   smallint REFERENCES edu.admission_year(year),  -- NULL = διαχρονική
  kind             text     NOT NULL CHECK (kind IN ('special_subject','athletic_test','medical','height','pke','other')),
  label            text     NOT NULL,
  details          text,
  source_id        bigint   NOT NULL REFERENCES edu.source_record(id)
);

-- Μετεγγραφές: ομάδες αντιστοιχίας ανά εγκύκλιο
CREATE TABLE edu.transfer_group (
  id               serial PRIMARY KEY,
  circular_label   text     NOT NULL,             -- π.χ. 'Εγκύκλιος 2026–2027'
  academic_year    text     NOT NULL,             -- '2026-2027'
  name             text     NOT NULL,
  source_id        bigint   NOT NULL REFERENCES edu.source_record(id),
  UNIQUE (academic_year, name)
);

CREATE TABLE edu.transfer_membership (
  transfer_group_id int  REFERENCES edu.transfer_group(id) ON DELETE CASCADE,
  department_id     uuid REFERENCES edu.department(id),
  PRIMARY KEY (transfer_group_id, department_id)
);

-- Ρητή ένδειξη "χωρίς αντιστοιχία" για έτος εγκυκλίου
CREATE TABLE edu.transfer_non_equivalent (
  department_id    uuid NOT NULL REFERENCES edu.department(id),
  academic_year    text NOT NULL,
  source_id        bigint NOT NULL REFERENCES edu.source_record(id),
  PRIMARY KEY (department_id, academic_year)
);

-- Full-text: ελληνικά χωρίς τόνους (unaccent) + 'simple' config
CREATE OR REPLACE FUNCTION edu.department_tsv_refresh() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.search_tsv :=
    setweight(to_tsvector('simple', unaccent(coalesce(NEW.title,''))), 'A') ||
    setweight(to_tsvector('simple', unaccent(coalesce(NEW.summary,''))), 'C');
  NEW.updated_at := now();
  RETURN NEW;
END $$;

CREATE TRIGGER department_tsv_trg
BEFORE INSERT OR UPDATE OF title, summary ON edu.department
FOR EACH ROW EXECUTE FUNCTION edu.department_tsv_refresh();

-- View για την καρτέλα τμήματος: τελευταία δύο δημοσιευμένα έτη
CREATE OR REPLACE VIEW edu.department_card_bases AS
SELECT o.department_id,
       ar.track, ar.code AS route_code, ar.name AS route_name,
       o.admission_year, o.program_code,
       r.candidate_group, r.base_score, r.no_base,
       s.url AS source_url, s.verified_at
FROM edu.offering o
JOIN edu.admission_year y ON y.year = o.admission_year AND y.status = 'published'
JOIN edu.access_route ar  ON ar.id = o.access_route_id
LEFT JOIN edu.admission_result r ON r.offering_id = o.id
JOIN edu.source_record s  ON s.id = coalesce(r.source_id, o.source_id);

-- ---------------------------------------------------------------------
-- Διαφημίσεις: μετρήσεις (το CMS διαχειρίζεται campaigns/creatives/placements;
-- εδώ οι πίνακες γεγονότων υψηλού όγκου, εκτός CMS collections)
-- ---------------------------------------------------------------------
CREATE TABLE ads.event_raw (
  id            bigserial PRIMARY KEY,
  occurred_at   timestamptz NOT NULL DEFAULT now(),
  kind          text   NOT NULL CHECK (kind IN ('served','viewable','click')),
  campaign_id   text   NOT NULL,          -- CMS id
  creative_id   text   NOT NULL,
  placement     text   NOT NULL,          -- 'AD-01' .. 'AD-08'
  page_path     text   NOT NULL,
  device        text   NOT NULL CHECK (device IN ('mobile','tablet','desktop')),
  visitor_hash  char(16)                  -- ημερήσιο salted hash, χωρίς IP/cookie — για dedup μόνο
);
CREATE INDEX ad_event_raw_time_idx ON ads.event_raw (occurred_at);

-- Ημερήσια συγκεντρωτικά (rollup job κάθε ώρα). Τα raw διαγράφονται μετά από 30 ημέρες.
CREATE TABLE ads.daily_stats (
  day           date  NOT NULL,
  campaign_id   text  NOT NULL,
  creative_id   text  NOT NULL,
  placement     text  NOT NULL,
  device        text  NOT NULL,
  served        int   NOT NULL DEFAULT 0,
  viewable      int   NOT NULL DEFAULT 0,
  clicks        int   NOT NULL DEFAULT 0,
  PRIMARY KEY (day, campaign_id, creative_id, placement, device)
);
