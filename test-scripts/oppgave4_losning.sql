-- ============================================================
-- Oppgave 4 - Losning (RLS + Views + Policies + Audit)
-- Paste into: test-scripts/oppgave4_losning.sql
-- Run with:
-- docker-compose exec postgres psql -U admin -d data1500_db -f test-scripts/oppgave4_losning.sql
-- ============================================================

-- ------------------------------------------------------------
-- A) Setup: student_role + student users + mapping table
-- (Skip/keep: safe if already exists)
-- ------------------------------------------------------------

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'student_role') THEN
CREATE ROLE student_role;
END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'student_1') THEN
    CREATE USER student_1 WITH PASSWORD 'student123';
END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'student_2') THEN
    CREATE USER student_2 WITH PASSWORD 'student123';
END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'student_3') THEN
    CREATE USER student_3 WITH PASSWORD 'student123';
END IF;
END $$;

GRANT student_role TO student_1;
GRANT student_role TO student_2;
GRANT student_role TO student_3;

CREATE TABLE IF NOT EXISTS bruker_student_mapping (
                                                      brukernavn TEXT PRIMARY KEY,
                                                      student_id INT REFERENCES studenter(student_id)
    );

-- Ensure mappings exist (insert only if missing)
INSERT INTO bruker_student_mapping (brukernavn, student_id)
SELECT 'student_1', 1
    WHERE NOT EXISTS (SELECT 1 FROM bruker_student_mapping WHERE brukernavn = 'student_1');

INSERT INTO bruker_student_mapping (brukernavn, student_id)
SELECT 'student_2', 2
    WHERE NOT EXISTS (SELECT 1 FROM bruker_student_mapping WHERE brukernavn = 'student_2');

INSERT INTO bruker_student_mapping (brukernavn, student_id)
SELECT 'student_3', 3
    WHERE NOT EXISTS (SELECT 1 FROM bruker_student_mapping WHERE brukernavn = 'student_3');

-- Grants (schema + select)
GRANT USAGE ON SCHEMA public TO student_role;

GRANT SELECT ON emneregistreringer TO student_role;
GRANT SELECT ON bruker_student_mapping TO student_role;
GRANT SELECT ON studenter TO student_role;
GRANT SELECT ON emner TO student_role;
GRANT SELECT ON programmer TO student_role;


-- ------------------------------------------------------------
-- B) RLS on emneregistreringer: students see own grades only
-- ------------------------------------------------------------

ALTER TABLE emneregistreringer ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS student_see_own_grades ON emneregistreringer;

CREATE POLICY student_see_own_grades
ON emneregistreringer
FOR SELECT
                    TO student_role
                    USING (
                    student_id = (
                    SELECT bsm.student_id
                    FROM bruker_student_mapping bsm
                    WHERE bsm.brukernavn = current_user
                    )
                    );


-- ------------------------------------------------------------
-- C) Task 1: RLS on studenter: students see own student row only
-- ------------------------------------------------------------

ALTER TABLE studenter ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS student_see_own_data ON studenter;

CREATE POLICY student_see_own_data
ON studenter
FOR SELECT
                    TO student_role
                    USING (
                    student_id = (
                    SELECT bsm.student_id
                    FROM bruker_student_mapping bsm
                    WHERE bsm.brukernavn = current_user
                    )
                    );


-- ------------------------------------------------------------
-- D) Setup foreleser_role + foreleser user
-- (safe if already exists)
-- ------------------------------------------------------------

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'foreleser_role') THEN
CREATE ROLE foreleser_role;
END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'foreleser_1') THEN
    CREATE USER foreleser_1 WITH PASSWORD 'foreleser123';
END IF;
END $$;

GRANT foreleser_role TO foreleser_1;

GRANT USAGE ON SCHEMA public TO foreleser_role;
GRANT SELECT ON emneregistreringer TO foreleser_role;
GRANT UPDATE ON emneregistreringer TO foreleser_role;
GRANT SELECT ON studenter TO foreleser_role;
GRANT SELECT ON emner TO foreleser_role;
GRANT SELECT ON programmer TO foreleser_role;


-- ------------------------------------------------------------
-- E) Task 2: Policy for foreleser_role to see ALL grades
-- ------------------------------------------------------------

DROP POLICY IF EXISTS foreleser_see_all_grades ON emneregistreringer;

CREATE POLICY foreleser_see_all_grades
ON emneregistreringer
FOR SELECT
                    TO foreleser_role
                    USING (true);


-- ------------------------------------------------------------
-- F) Task 3: View foreleser_karakteroversikt (JOIN)
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW foreleser_karakteroversikt AS
SELECT
    s.student_id,
    s.fornavn,
    s.etternavn,
    e.emne_kode,
    e.emne_navn,
    er.karakter,
    er.semester
FROM emneregistreringer er
         JOIN studenter s ON s.student_id = er.student_id
         JOIN emner e ON e.emne_id = er.emne_id;

GRANT SELECT ON foreleser_karakteroversikt TO foreleser_role;


-- ------------------------------------------------------------
-- G) Task 4: Prevent DELETE of grades (only admin can delete)
-- ------------------------------------------------------------

DROP POLICY IF EXISTS only_admin_can_delete_grades ON emneregistreringer;

CREATE POLICY only_admin_can_delete_grades
ON emneregistreringer
FOR DELETE
USING (current_user = 'admin');


-- ------------------------------------------------------------
-- H) Del 4: Column-limited view for students (hide epost)
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW student_info_limited AS
SELECT
    student_id,
    fornavn,
    etternavn,
    program_id
FROM studenter;

GRANT SELECT ON student_info_limited TO student_role;

-- remove access to base table (students must use the limited view)
REVOKE SELECT ON studenter FROM student_role;


-- ------------------------------------------------------------
-- I) Task 5: Audit logging (table + trigger)
-- Logs INSERT/UPDATE/DELETE on emneregistreringer
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS audit_log (
                                         log_id SERIAL PRIMARY KEY,
                                         tabell_navn TEXT NOT NULL,
                                         operasjon TEXT NOT NULL,
                                         bruker TEXT NOT NULL,
                                         gammel_data JSONB,
                                         ny_data JSONB,
                                         endret_tid TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_grade_changes()
RETURNS TRIGGER AS $$
BEGIN
INSERT INTO audit_log (tabell_navn, operasjon, bruker, gammel_data, ny_data)
VALUES (
           TG_TABLE_NAME,
           TG_OP,
           current_user,
           to_jsonb(OLD),
           to_jsonb(NEW)
       );

IF TG_OP = 'DELETE' THEN
    RETURN OLD;
ELSE
    RETURN NEW;
END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS emneregistreringer_audit ON emneregistreringer;

CREATE TRIGGER emneregistreringer_audit
    AFTER INSERT OR UPDATE OR DELETE ON emneregistreringer
    FOR EACH ROW
    EXECUTE FUNCTION log_grade_changes();


-- ------------------------------------------------------------
-- J) Quick verification queries (optional)
-- ------------------------------------------------------------

-- Show policies
SELECT policyname, tablename, roles, cmd
FROM pg_policies
WHERE tablename IN ('studenter','emneregistreringer')
ORDER BY tablename, policyname;

-- Show views
SELECT schemaname, viewname
FROM pg_views
WHERE schemaname = 'public'
  AND viewname IN ('student_info_limited','foreleser_karakteroversikt')
ORDER BY viewname;
