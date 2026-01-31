-- =========================
-- Oppgave 3 - Losning
-- =========================

-- 1) program_ansvarlig: SELECT + UPDATE på programmer, men ikke DELETE
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'program_ansvarlig') THEN
CREATE ROLE program_ansvarlig LOGIN PASSWORD 'program_pass';
END IF;
END $$;

GRANT SELECT, UPDATE ON programmer TO program_ansvarlig;


-- 2) student_self_view: VIEW
CREATE OR REPLACE VIEW student_view AS
SELECT student_id, fornavn, etternavn, epost, program_id
FROM studenter;

-- "self"-view (kan gi 0 rader hvis current_user ikke matcher epost)
CREATE OR REPLACE VIEW student_self_view AS
SELECT student_id, fornavn, etternavn, epost, program_id
FROM studenter
WHERE epost = current_user;


-- 3) Gi foreleser_role tilgang til student_view
GRANT SELECT ON student_view TO foreleser_role;


-- 4) backup_bruker: SELECT på alle tabeller
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'backup_bruker') THEN
CREATE ROLE backup_bruker LOGIN PASSWORD 'backup_pass';
END IF;
END $$;

GRANT SELECT ON studenter, programmer, emner, emneregistreringer TO backup_bruker;


-- 5) Oversikt over roller og rettigheter
SELECT rolname
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%'
ORDER BY rolname;
