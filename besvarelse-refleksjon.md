# Besvarelse av refleksjonsspørsmål - DATA1500 Oppgavesett 1.3

Skriv dine svar på refleksjonsspørsmålene fra hver oppgave her.

---

## Oppgave 1: Docker-oppsett og PostgreSQL-tilkobling

### Spørsmål 1: Hva er fordelen med å bruke Docker i stedet for å installere PostgreSQL direkte på maskinen?

**Ditt svar:**

Fordelen med å bruke Docker er at PostgreSQL kjører i en isolert container uavhengig av operativsystemet.
Alle studenter får nøyaktig samme versjon og konfigurasjon av databasen, noe som reduserer problemer knyttet til ulike OS, versjoner og lokale installasjoner.
Docker gjør det også enkelt å starte, stoppe og slette databasen uten å påvirke resten av systemet.

---

### Spørsmål 2: Hva betyr "persistent volum" i docker-compose.yml? Hvorfor er det viktig?

**Ditt svar:**

Et persistent volum betyr at dataene lagres utenfor selve containeren, slik at de ikke forsvinner når containeren stoppes eller slettes. Dette er viktig fordi databasedata ellers ville blitt borte hver gang containeren restartes.

---

### Spørsmål 3: Hva skjer når du kjører `docker-compose down`? Mister du dataene?

**Ditt svar:**

Når man kjører docker-compose down, stoppes og fjernes containerne, men dataene beholdes så lenge de er lagret i et persistent volum.
Dataene slettes bare hvis man eksplisitt bruker docker-compose down -v.

---

### Spørsmål 4: Forklar hva som skjer når du kjører `docker-compose up -d` første gang vs. andre gang.

**Ditt svar:**

Første gang docker-compose up -d kjøres, laster Docker ned nødvendige images, oppretter containere, setter opp nettverk og kjører init-skriptene som initialiserer databasen med testdata.
Andre gang brukes allerede eksisterende images, containere og volum, og databasen starter raskere uten å bli initialisert på nytt.

---

### Spørsmål 5: Hvordan ville du delt docker-compose.yml-filen med en annen student? Hvilke sikkerhetshensyn må du ta?

Docker-compose.yml-filen kan deles via GitHub som en del av et repository. Det er viktig å passe på at sensitive opplysninger som passord, brukernavn eller hemmelige nøkler ikke eksponeres. I stedet bør slike verdier lagres i miljøvariabler eller i en .env-fil som ikke pushes til GitHub.

[Skriv ditt svar her]

---

## Oppgave 2: SQL-spørringer og databaseskjema

### Spørsmål 1: Hva er forskjellen mellom INNER JOIN og LEFT JOIN? Når bruker du hver av dem?

**Ditt svar:**

INNER JOIN returnerer bare rader med treff i begge tabeller, mens LEFT JOIN også tar med rader uten treff fra venstre tabell.

---

### Spørsmål 2: Hvorfor bruker vi fremmednøkler? Hva skjer hvis du prøver å slette et program som har studenter?

**Ditt svar:**

Fremmednøkler sikrer referanseintegritet, og sletting vil feile (eller kaskadere) hvis studenter fortsatt er knyttet til programmet.

---

### Spørsmål 3: Forklar hva `GROUP BY` gjør og hvorfor det er nødvendig når du bruker aggregatfunksjoner.

**Ditt svar:**

GROUP BY grupperer rader slik at aggregatfunksjoner som COUNT og AVG kan beregnes per gruppe.
---

### Spørsmål 4: Hva er en indeks og hvorfor er den viktig for ytelse?

**Ditt svar:**

En indeks gjør oppslag raskere ved å redusere hvor mye data databasen må lese.

---

### Spørsmål 5: Hvordan ville du optimalisert en spørring som er veldig treg?

**Ditt svar:**

Jeg ville analysert spørringen med EXPLAIN og lagt til riktige indekser.
---

## Oppgave 3: Brukeradministrasjon og GRANT

### Spørsmål 1: Hva er prinsippet om minste rettighet? Hvorfor er det viktig?

**Ditt svar:**

Prinsippet betyr at brukere kun får rettigheter de trenger, noe som reduserer sikkerhetsrisiko.
---

### Spørsmål 2: Hva er forskjellen mellom en bruker og en rolle i PostgreSQL?

**Ditt svar:**

En bruker er en rolle som kan logge inn, mens en rolle brukes til å samle rettigheter.
---

### Spørsmål 3: Hvorfor er det bedre å bruke roller enn å gi rettigheter direkte til brukere?

**Ditt svar:**

Roller gjør rettighetsstyring enklere og mer oversiktlig.
---

### Spørsmål 4: Hva skjer hvis du gir en bruker `DROP` rettighet? Hvilke sikkerhetsproblemer kan det skape?

**Ditt svar:**

Brukeren kan slette tabeller eller databaser, noe som kan føre til datatap.
---

### Spørsmål 5: Hvordan ville du implementert at en student bare kan se sine egne karakterer, ikke andres?

**Ditt svar:**

Jeg ville brukt Row-Level Security med en policy basert på studentens ID.
---

## Notater og observasjoner

Bruk denne delen til å dokumentere interessante funn, problemer du møtte, eller andre observasjoner:

[Skriv dine notater her]


## Oppgave 4: Brukeradministrasjon og GRANT

1. **Hva er Row-Level Security og hvorfor er det viktig?**
    - RLS begrenser hvilke rader en bruker kan se, noe som gir bedre datasikkerhet.

2. **Hva er forskjellen mellom RLS og kolonnebegrenset tilgang?**
    - RLS styrer hvilke rader som er synlige, mens kolonnebegrensning styrer hvilke felt som er tilgjengelige.

3. **Hvordan ville du implementert at en student bare kan se karakterer for sitt eget program?**
    - Jeg ville brukt en RLS-policy som filtrerer på program_id

4. **Hva er sikkerhetsproblemene ved å bruke views i stedet for RLS?**
    - Views kan omgås ved direkte tilgang til tabeller hvis rettigheter er feil satt.

5. **Hvordan ville du testet at RLS-policyer fungerer korrekt?**
    - Jeg ville logget inn som ulike brukere og verifisert hvilke rader som er synlige.
---

## Referanser

- PostgreSQL dokumentasjon: https://www.postgresql.org/docs/
- Docker dokumentasjon: https://docs.docker.com/

