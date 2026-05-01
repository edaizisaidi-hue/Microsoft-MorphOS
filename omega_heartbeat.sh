#!/bin/bash
# OMEGA HEARTBEAT - Auto-Recovery & Sentinel Service
# Target: Project MORPHOS

SERVICE_NAME="uvicorn"
LOG_FILE="/home/tsa_architect/heartbeat.log"

echo "[$(date)] Scanning system health..." >> $LOG_FILE

# 1. Semakan Servis
if ! pgrep -x "$SERVICE_NAME" > /dev/null
then
    echo "[ALERT] $SERVICE_NAME is DOWN. Re-initiating..." >> $LOG_FILE
    # Ganti path ini dengan lokasi skrip start Tuan nanti
    nohup uvicorn main:app --host 0.0.0.0 --port 8000 > output.log 2>&1 &
else
    echo "[OK] $SERVICE_NAME is pulsing." >> $LOG_FILE
fi

# 2. Pembersihan Cache (Zon Murni)
sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
