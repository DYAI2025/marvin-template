#!/usr/bin/env python3
"""
MARVIN - Nexus Immunsystem
Läuft auf Google Gemini 2.5 Pro (kostenlos via OpenRouter oder direkt)
"""

import os
import sys
import json
import subprocess
import requests
from datetime import datetime
from pathlib import Path

# Konfiguration
MARVIN_DIR = Path(__file__).parent
STATE_FILE = MARVIN_DIR / "state" / "current.md"
LOG_FILE = MARVIN_DIR / "sessions" / "marvin-gemini.log"
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")
GEMINI_MODEL = "gemini-2.5-pro"  # Stärkstes Gemini Modell

# Health Check Definitionen
HEALTH_CHECKS = {
    "nexus": {
        "name": "Nexus (OpenClaw)",
        "port": 18789,
        "check": "curl -s --max-time 3 localhost:18789/ > /dev/null",
        "start": "pkill -f 'openclaw gateway' 2>/dev/null; sudo -u moltbot screen -X -S nexus quit 2>/dev/null; sleep 2; sudo -u moltbot screen -dmS nexus bash -c 'cd /home/moltbot && openclaw gateway --verbose --port 18789'"
    },
    "perr00bot": {
        "name": "Perr00bot (Nanobot)",
        "port": 0,  # Telegram-Bot
        "check": "pgrep -u moltbot -f 'nanobot gateway' > /dev/null && sudo -u moltbot screen -ls 2>/dev/null | grep -q perr00bot",
        "start": "pkill -9 -f 'nanobot gateway' 2>/dev/null; sleep 2; sudo -u moltbot screen -dmS perr00bot bash -c 'source /home/moltbot/.venv/bin/activate && cd /home/moltbot && nanobot gateway --verbose'"
    },
    "agent_zero": {
        "name": "Agent Zero",
        "port": 5000,
        "check": "docker ps --format '{{.Names}}' | grep -q agent-zero",
        "start": "docker start agent-zero"
    },
    "whisper_stt": {
        "name": "Whisper STT",
        "port": 8002,
        "check": "curl -s --max-time 2 localhost:8002/health",
        "start": "cd /home/moltbot/whisper-service && screen -dmS whisper uvicorn api:app --port 8002"
    },
    "claude_overload": {
        "name": "Claude Prozesse",
        "port": 0,
        "check": "test $(pgrep -u moltbot -c claude 2>/dev/null || echo 0) -le 10",  # Normal: ~6-8 (Sessions + Mem + MCP)
        "start": "echo 'Zu viele Claude-Prozesse (>10) - manuell prüfen'"
    }
}

def log(msg: str):
    """Log mit Timestamp"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{timestamp}] {msg}"
    print(line)
    with open(LOG_FILE, "a") as f:
        f.write(line + "\n")

def run_cmd(cmd: str) -> tuple[bool, str]:
    """Shell-Befehl ausführen"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
        return result.returncode == 0, result.stdout + result.stderr
    except subprocess.TimeoutExpired:
        return False, "Timeout"
    except Exception as e:
        return False, str(e)

def check_health() -> dict:
    """Alle Services prüfen"""
    status = {}
    for key, svc in HEALTH_CHECKS.items():
        ok, output = run_cmd(svc["check"])
        status[key] = {
            "name": svc["name"],
            "up": ok,
            "port": svc["port"]
        }
    return status

def get_system_resources() -> dict:
    """RAM, Disk, Load"""
    resources = {}

    # RAM
    ok, out = run_cmd("free -m | awk '/^Mem:/ {printf \"%.1f/%.1f\", $3/1024, $2/1024}'")
    resources["ram_gb"] = out.strip() if ok else "?"

    # Disk
    ok, out = run_cmd("df -h / | awk 'NR==2 {print $3\"/\"$2\" (\"$5\")\"}'")
    resources["disk"] = out.strip() if ok else "?"

    # Load
    ok, out = run_cmd("cat /proc/loadavg | awk '{print $1\", \"$2\", \"$3}'")
    resources["load"] = out.strip() if ok else "?"

    return resources

def ask_gemini(prompt: str, context: str = "") -> str:
    """Gemini API aufrufen"""
    if not GEMINI_API_KEY:
        return "[ERROR] GEMINI_API_KEY nicht gesetzt"

    url = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent"

    headers = {"Content-Type": "application/json"}

    system_prompt = """Du bist MARVIN, das Immunsystem von Nexus.
Deine Aufgabe: Systemgesundheit überwachen, Probleme erkennen und heilen.
Antworte kurz und präzise auf Deutsch. Gib konkrete Aktionen wenn nötig."""

    full_prompt = f"{system_prompt}\n\nKontext:\n{context}\n\nFrage:\n{prompt}"

    data = {
        "contents": [{"parts": [{"text": full_prompt}]}],
        "generationConfig": {
            "temperature": 0.3,
            "maxOutputTokens": 2048  # Erhöht wegen Thinking Tokens
        }
    }

    try:
        resp = requests.post(
            f"{url}?key={GEMINI_API_KEY}",
            headers=headers,
            json=data,
            timeout=60
        )
        resp.raise_for_status()
        result = resp.json()
        # Gemini 2.5 response parsing
        candidates = result.get("candidates", [])
        if candidates:
            content = candidates[0].get("content", {})
            parts = content.get("parts", [])
            if parts:
                return parts[0].get("text", "[keine Antwort]")
        return "[keine Antwort von Gemini]"
    except Exception as e:
        return f"[ERROR] Gemini API: {e}"

def update_state(status: dict, resources: dict, intervention: str = None):
    """State-File aktualisieren"""
    now = datetime.now().strftime("%Y-%m-%d %H:%M UTC")

    lines = [
        "# Current State",
        "",
        f"Last updated: {now}",
        "",
        "## Systemstatus",
        "",
        "| Komponente | Status | Port | Letzter Check |",
        "|------------|--------|------|---------------|"
    ]

    for key, svc in status.items():
        icon = "✅ UP" if svc["up"] else "❌ DOWN"
        lines.append(f"| {svc['name']} | {icon} | {svc['port']} | {now} |")

    lines.extend([
        "",
        "## Ressourcen",
        "",
        f"| RAM | {resources.get('ram_gb', '?')} GB |",
        f"| Disk | {resources.get('disk', '?')} |",
        f"| Load | {resources.get('load', '?')} |"
    ])

    if intervention:
        lines.extend([
            "",
            "## Letzte Intervention",
            "",
            intervention
        ])

    STATE_FILE.write_text("\n".join(lines))

def heal_service(key: str) -> bool:
    """Service heilen (neustarten)"""
    if key not in HEALTH_CHECKS:
        return False

    svc = HEALTH_CHECKS[key]
    log(f"🔧 Heile {svc['name']}...")

    ok, output = run_cmd(svc["start"])
    if ok:
        log(f"✅ {svc['name']} gestartet")
    else:
        log(f"❌ {svc['name']} Start fehlgeschlagen: {output}")

    return ok

def main():
    """Hauptfunktion"""
    log("=== MARVIN Gemini Check ===")

    # Health Check
    status = check_health()
    resources = get_system_resources()

    # Status loggen
    down_services = [s["name"] for s in status.values() if not s["up"]]
    up_services = [s["name"] for s in status.values() if s["up"]]

    log(f"UP: {', '.join(up_services) if up_services else 'keine'}")
    if down_services:
        log(f"DOWN: {', '.join(down_services)}")
    log(f"Resources: RAM {resources['ram_gb']}GB, Load {resources['load']}")

    intervention = None

    # Bei Problemen: Gemini fragen
    if down_services:
        context = f"""
Aktuelle Situation:
- Services UP: {', '.join(up_services)}
- Services DOWN: {', '.join(down_services)}
- RAM: {resources['ram_gb']} GB
- Load: {resources['load']}
"""

        response = ask_gemini(
            f"Diese Services sind down: {', '.join(down_services)}. Soll ich sie automatisch neustarten?",
            context
        )
        log(f"Gemini: {response[:200]}...")

        # Auto-Heal wenn Gemini zustimmt oder "ja" enthält
        if "ja" in response.lower() or "neustart" in response.lower() or "start" in response.lower():
            for key, svc in status.items():
                if not svc["up"]:
                    heal_service(key)

            # Re-check
            new_status = check_health()
            healed = [s["name"] for k, s in new_status.items() if s["up"] and not status[k]["up"]]
            if healed:
                intervention = f"**[{datetime.now().strftime('%Y-%m-%d %H:%M')}]** Auto-Heal: {', '.join(healed)} neugestartet"
                log(intervention)

    # State aktualisieren
    update_state(status, resources, intervention)
    log("=== Check abgeschlossen ===")

if __name__ == "__main__":
    main()
