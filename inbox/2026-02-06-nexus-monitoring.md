# [LEARN] Nexus & Perr00bot Überwachung

## Nexus (OpenClaw) Identität
- **Was:** Haupt-AI-System
- **Prozess:** `openclaw gateway`
- **User:** moltbot
- **Screen:** `nexus`
- **Port:** 18789
- **Config:** `/home/moltbot/.openclaw/openclaw.json`
- **Dashboard:** http://localhost:18789/

## Perr00bot (Nanobot) Identität
- **Was:** Telegram Agile Coach
- **Prozess:** `nanobot gateway`
- **User:** moltbot
- **Screen:** `perr00bot`
- **Config:** `/home/moltbot/.nanobot/config.json`
- **Sessions:** `/home/moltbot/.nanobot/sessions/`

---

## 🔴 Zeichen dass Nexus (OpenClaw) INAKTIV ist

### 1. Port antwortet nicht
```bash
! curl -s --max-time 3 localhost:18789/ > /dev/null
```
**Bedeutung:** Nexus ist down oder hängt

### 2. Kein Prozess
```bash
! pgrep -f "openclaw gateway"
```
**Bedeutung:** Nexus komplett abgestürzt

### 3. Screen-Session weg
```bash
! sudo -u moltbot screen -ls 2>/dev/null | grep -q nexus
```
**Bedeutung:** Screen gestorben

---

## 🔴 Zeichen dass Perr00bot (Nanobot) INAKTIV ist

### 1. Kein Prozess
```bash
! pgrep -u moltbot -f "nanobot gateway"
```

### 2. Screen-Session weg
```bash
! sudo -u moltbot screen -ls 2>/dev/null | grep -q perr00bot
```

### 3. Telegram-Session nicht aktualisiert (>30 Min)
```bash
find /home/moltbot/.nanobot/sessions/telegram_*.jsonl -mmin +30
```
**Bedeutung:** Perr00bot pollt aber LLM antwortet nicht

---

## 🟢 Zeichen dass Nexus GESUND ist

```bash
# Alle 3 müssen true sein:
pgrep -u moltbot -f "nanobot gateway" > /dev/null &&
sudo -u moltbot screen -ls 2>/dev/null | grep -q nexus &&
find /home/moltbot/.nanobot/sessions/telegram_*.jsonl -mmin -30 | grep -q .
```

---

## 🔧 Heilungs-Aktionen

### Nexus (OpenClaw) heilen:
```bash
# 1. Alte Prozesse aufräumen
pkill -f "openclaw gateway" 2>/dev/null
sudo -u moltbot screen -X -S nexus quit 2>/dev/null
sleep 2

# 2. Neu starten
sudo -u moltbot screen -dmS nexus bash -c 'cd /home/moltbot && openclaw gateway --verbose --port 18789'

# 3. Warten und verifizieren (10 Sek)
sleep 10
curl -s --max-time 3 localhost:18789/ > /dev/null && echo "NEXUS GEHEILT"
```

### Perr00bot (Nanobot) heilen:
```bash
# 1. Alte Prozesse aufräumen
pkill -9 -f "nanobot gateway" 2>/dev/null
sudo -u moltbot screen -X -S perr00bot quit 2>/dev/null
sleep 2

# 2. Neu starten
sudo -u moltbot screen -dmS perr00bot bash -c 'source /home/moltbot/.venv/bin/activate && cd /home/moltbot && nanobot gateway --verbose'

# 3. Warten und verifizieren
sleep 10
pgrep -u moltbot -f "nanobot gateway" && echo "PERR00BOT GEHEILT"
```

### Bei Perr00bot Session zu groß:
```bash
# 1. Backup erstellen
cp /home/moltbot/.nanobot/sessions/telegram_8177545205.jsonl \
   /home/moltbot/.nanobot/sessions/telegram_8177545205.jsonl.backup.$(date +%Y%m%d_%H%M%S)

# 2. Session trimmen (letzte 100 Zeilen)
tail -100 /home/moltbot/.nanobot/sessions/telegram_8177545205.jsonl > /tmp/session-trimmed.jsonl
mv /tmp/session-trimmed.jsonl /home/moltbot/.nanobot/sessions/telegram_8177545205.jsonl
chown moltbot:moltbot /home/moltbot/.nanobot/sessions/telegram_8177545205.jsonl

# 3. Perr00bot neustarten (siehe oben)
```

### Bei Perr00bot API-Key Fehler:
```bash
grep -q "apiKey" /home/moltbot/.nanobot/config.json || echo "OPENROUTER API KEY FEHLT!"
```

---

## 📊 Monitoring Intervall

- **Prozess-Check:** alle 5 Minuten
- **Session-Größe:** alle 30 Minuten
- **Telegram-Aktivität:** alle 30 Minuten

---

## 🚨 Eskalation

Wenn Nexus 3x hintereinander nicht startet:
1. Log schreiben in `/home/moltbot/marvin/memory/ESCALATIONS.md`
2. NICHT weiter versuchen
3. Warten auf manuelles Eingreifen

---

## Root Causes (für Prävention)

| Symptom | Wahrscheinliche Ursache |
|---------|------------------------|
| Kein Prozess nach Start | API-Key fehlt, Model nicht erreichbar |
| Prozess stirbt nach Minuten | RAM voll, OOM-Killer |
| Session wächst schnell | Lange Konversationen, kein Trimming |
| Keine Telegram-Updates | Bot-Token ungültig, Telegram API down |
