# viikko3-status

Linux Administration, viikkotehtava 3: automaattisesti paivittyva palvelimen tilaraportti (Bash + systemd-timer + nginx), CSC cPouta.

## Tiedostot

| Tiedosto | Tarkoitus |
|---|---|
| `status-report.sh` | Kerää päivämäärän, uptimen, levyn käyttöasteen ja RAM-tiedot ja kirjoittaa HTML-raportin |
| `systemd/status-report.service` | Ajaa skriptin kerran (`Type=oneshot`) |
| `systemd/status-report.timer` | Käynnistää servicen minuutin välein, myös rebootin jälkeen |
| `nginx/viikko3-location.conf` | nginx-lohko, joka julkaisee raportin polussa `/viikko3/` |
| `web/style.css`, `web/docs.html` | Sivun tyyli ja dokumentaatio |

## Asennus

```bash
sudo mkdir -p /var/www/viikko3
sudo chown "$USER":"$USER" /var/www/viikko3
cp web/style.css web/docs.html /var/www/viikko3/
chmod +x status-report.sh && ./status-report.sh

sudo cp systemd/status-report.service systemd/status-report.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now status-report.timer
```

## Testaus

```bash
bash -n status-report.sh          # syntaksi
./status-report.sh --test 50      # -> OK
./status-report.sh --test 80      # -> WARNING
./status-report.sh --test 90      # -> WARNING
systemctl list-timers status-report.timer
journalctl -u status-report.service -n 10
```
