#!/usr/bin/env bash
#
# status-report.sh - Viikkotehtävä 3: palvelimen tilaraportti
#
# Kerää palvelimen perustiedot ja kirjoittaa ne HTML-sivuksi.
# systemd-timer ajaa tämän skriptin minuutin välein.
#
# Käyttö:
#   ./status-report.sh             -> generoi raportin
#   ./status-report.sh --test 90   -> testaa levytilalogiikkaa annetulla prosentilla
#
set -euo pipefail

# --- Asetukset ----------------------------------------------------------------
OUTPUT_DIR="${OUTPUT_DIR:-/var/www/viikko3}"   # voi ohittaa testatessa: OUTPUT_DIR=/tmp ./status-report.sh
OUTPUT_FILE="${OUTPUT_DIR}/index.html"
TMP_FILE="${OUTPUT_FILE}.tmp"
WARN_LIMIT=80                                   # varoitusraja prosentteina
GITHUB_URL="https://github.com/KAYTTAJA/viikko3-status"   # TODO 0: vaihda oma repo-osoite

# --- Funktiot -----------------------------------------------------------------

# disk_status <käyttöprosentti>
# Tulostaa "OK", jos käyttö on alle WARN_LIMIT, muuten "WARNING".
disk_status() {
    local usage="$1"

    # TODO 5: Kirjoita if-lause tähän ja poista alla oleva echo "TODO".
    #   - jos usage on vähintään WARN_LIMIT -> echo "WARNING"
    #   - muuten                            -> echo "OK"
    #   Vihje: kokonaislukujen vertailu [ "$a" -ge "$b" ]   (-ge = greater or equal)
    echo "TODO"
}

# write_html: kirjoittaa raportin väliaikaistiedostoon ja siirtää sen paikalleen.
# mv saman hakemiston sisällä on atominen -> selain ei koskaan näe puolivalmista sivua.
write_html() {
    cat > "$TMP_FILE" <<EOF
<!DOCTYPE html>
<html lang="fi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="refresh" content="60">
  <title>Palvelimen tilaraportti</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
<main>
  <header>
    <p class="prompt">$ ./status-report.sh</p>
    <h1>Palvelimen tilaraportti</h1>
    <p class="meta">Raportti generoitu: <strong>${GENERATED}</strong></p>
  </header>

  <section class="cards">
    <div class="card">
      <h2>Käynnissäoloaika</h2>
      <p class="value">${UPTIME}</p>
    </div>
    <div class="card">
      <h2>Juurilevyn (/) käyttö</h2>
      <p class="value">${DISK_USAGE} %</p>
      <div class="bar"><span style="width: ${DISK_USAGE}%"></span></div>
    </div>
    <div class="card status ${STATUS_CLASS}">
      <h2>Levytilan tila</h2>
      <p class="value">${DISK_STATUS}</p>
      <p class="hint">OK kun käyttö &lt; ${WARN_LIMIT} %, WARNING kun &ge; ${WARN_LIMIT} %</p>
    </div>
    <div class="card">
      <h2>RAM yhteensä</h2>
      <p class="value">${RAM_TOTAL} MiB</p>
    </div>
    <div class="card">
      <h2>RAM käytettävissä</h2>
      <p class="value">${RAM_AVAILABLE} MiB</p>
    </div>
  </section>

  <nav>
    <a href="docs.html">Dokumentaatio</a>
    <a href="${GITHUB_URL}">GitHub-repositorio</a>
  </nav>
  <footer>Raportti päivittyy automaattisesti minuutin välein (systemd-timer). Sivu lataa itsensä uudelleen 60 s välein.</footer>
</main>
</body>
</html>
EOF
    mv "$TMP_FILE" "$OUTPUT_FILE"
}

# --- Testitila (tehtävän kohta 5) --------------------------------------------
# Testaa tilalogiikan arvoilla 50, 80 ja 90 ilman että levyä tarvitsee täyttää.
# Raporttia ei kirjoiteta, joten oikea käyttöaste pysyy sivulla koko ajan.
if [[ "${1:-}" == "--test" ]]; then
    test_value="${2:?Anna prosentti, esim. --test 90}"
    echo "Levyn käyttö ${test_value} % -> $(disk_status "$test_value")"
    exit 0
fi

# --- Tietojen keruu -----------------------------------------------------------
# Korvaa jokainen "TODO" komentokorvauksella $( ... ).
# Kokeile komento ensin terminaalissa ja kopioi vasta toimiva versio tänne.

# TODO 1: Päivämäärä, kellonaika ja aikavyöhyke, esim. "16.11.2026 08:42:10 EET"
#   Vihje: date + muotoilumerkkijono. Katso `man date`: %d %m %Y %H %M %S %Z
GENERATED="TODO"

# TODO 2: Palvelimen käynnissäoloaika, esim. "up 3 days, 4 hours, 12 minutes"
#   Vihje: uptime-komennolla on valitsin "pretty"-muodolle (`uptime --help`)
UPTIME="TODO"

# TODO 3: Juurilevyn (/) käyttöaste PELKKÄNÄ NUMERONA, esim. 23
#   Vihje: `df /` tulostaa otsikkorivin ja datarivin. Tarvitset datarivin
#   Use%-sarakkeen ilman %-merkkia. Rakenne: df / | awk '...' | tr ...
#   awk: NR==2 valitsee 2. rivin, $5 viidennen sarakkeen. tr -d poistaa merkin.
DISK_USAGE="TODO"

# TODO 4: RAM yhteensä ja käytettävissä megatavuina (MiB), pelkät numerot
#   Vihje: `free -m`, rivi joka alkaa "Mem:". Sarakkeet total ja available.
#   awk '/^Mem:/ {print $N}' - selvitä oikeat sarakenumerot itse.
RAM_TOTAL="TODO"
RAM_AVAILABLE="TODO"

# --- Tila ja raportti ---------------------------------------------------------
DISK_STATUS=$(disk_status "$DISK_USAGE")
STATUS_CLASS="${DISK_STATUS,,}"   # OK -> ok, WARNING -> warning (CSS-luokka värille)

write_html
echo "Raportti kirjoitettu: ${OUTPUT_FILE} (${GENERATED})"
