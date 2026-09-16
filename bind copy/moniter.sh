#!/bin/bash

export AGENT_HOME=/home/agent-admin/agent-app
export AGENT_PORT=15034
export AGENT_UPLOAD_DIR=$AGENT_HOME/upload_files
export AGENT_KEY_PATH=$AGENT_HOME/api_keys
export AGENT_LOG_DIR=/var/log/agent-app

APP_NAME="agent-app-linux-x86"
LOG_FILE="/var/log/agent-app/moniter.log"

PID=$(pgrep -f "$APP_NAME" | head -n 1)

if [ -n "$PID" ]; then
    CPU=$(ps -p "$PID" -o %cpu= | xargs)
    MEM=$(ps -p "$PID" -o %mem= | xargs)
else
    PID="N/A"
    CPU="0.0"
    MEM="0.0"
fi

DISK_USED=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')

echo "[$(date '+%Y-%m-%d %H:%M:%S')] PID:$PID CPU:${CPU}% MEM:${MEM}% DISK_USED:${DISK_USED}%" >> "$LOG_FILE"