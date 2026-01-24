-- ============================================================================
-- SVAR OPPGAVE 2
-- ============================================================================

-- 1. Hent alle studenter som ikke har noen emneregistreringer
SELECT
    s.fornavn,
    s.etternavn,
    COUNT(er.registrering_id) as antall_emner
FROM studenter s
         LEFT JOIN emneregistreringer er
                   ON s.student_id = er.student_id
GROUP BY s.student_id, s.fornavn, s.etternavn
HAVING COUNT(er.registrering_id) < 1
ORDER BY antall_emner DESC;

-- 2. Hent alle emner som ingen studenter er registrert på

SELECT
    e.emne_id,
    e.emne_kode,
    e.emne_navn
FROM emner e
         LEFT JOIN emneregistreringer er
                   ON e.emne_id = er.emne_id
WHERE er.emne_id IS NULL;

-- 3.Hent studentene med høyeste karakter per emne

SELECT                              -- Shows the subject name, studnets name, the grade
    e.emne_navn,
    s.fornavn,
    s.etternavn,
    er.karakter
FROM emneregistreringer er          -- From the registration table that has the grade
         JOIN (                     -- Highest grade anyone got per each subject
    SELECT
        emne_id,
        MAX(karakter) AS maks_karakter
    FROM emneregistreringer
    WHERE karakter IS NOT NULL
    GROUP BY emne_id
) topp                              -- Filters out not the top grade and fetches student names
              ON er.emne_id = topp.emne_id
                  AND er.karakter = topp.maks_karakter
         JOIN studenter s ON er.student_id = s.student_id
         JOIN emner e ON er.emne_id = e.emne_id
ORDER BY e.emne_navn, s.etternavn;

-- 4.Lag en rapport som viser hver student, deres program, og antall emner de er registrert på

SELECT                              -- Show student name, program name and amount of subjects they're in
    s.fornavn,
    s.etternavn,
    s.program_navn,
    COUNT(er.registrering_id) AS antall_emner
FROM studenter s                    -- Begins with all students
JOIN programmer p                   -- Find which program each student belongs to
    ON s.program_id = p.program_id
LEFT JOIN emneregistreringer er     -- Attach registration if they exist
    ON s.student_id = er.student_id
GROUP BY                            -- Groups rows per student
    s.student_id,
    s.fornavn,
    s.etternavn,
    p.program_navn
ORDER BY                            -- Studnets with most emners appear first
    antall_emner DESC,
    s.etternavn,
    s.fornavn;



-- 5. Hent alle studenter som er registrert på både DATA1500 og DATA1100

SELECT
    s.student_id,
    s.fornavn,
    s.etternavn
FROM studenter s                    -- Joins the table so we can see all the studnets subjects
JOIN emneregistreringer er
    ON s.student_id = er.student_id
JOIN emner e
    ON er.emne_id = e.emne_id
WHERE e.emne_kode IN ('DATA1500', 'DATA1100')       -- Keeps only rows that have these subjects
GROUP BY s.student_id, s.fornavn, s.etternavn
HAVING COUNT(DISTINCT e.emne_kode) = 2              -- Keeps only student that have both
ORDER BY s.etternavn, s.fornavn;                    -- Group everything per student
