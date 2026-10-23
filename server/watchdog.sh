#!/usr/bin/env bash
# dwell 后端看门狗：进程不在就拉起来。仿 wechat-bridge watchdog 的写法，
# 可挂 cron 每 5 分钟调用一次。
set -uo pipefail

SERVER="$HOME/workspace/dwell-on-something/server"
PIDFILE="$SERVER/server.pid"
LOG="$SERVER/watchdog.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; }

alive=0
if [ -f "$PIDFILE" ]; then
  pid="$(cat "$PIDFILE" 2>/dev/null || true)"
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    alive=1
  fi
fi

if [ "$alive" -eq 1 ]; then
  echo "DWELL_ALIVE"
  exit 0
fi

log "dwell 未运行，尝试拉起"
bash "$SERVER/run.sh" >> "$LOG" 2>&1
sleep 2

if [ -f "$PIDFILE" ]; then
  newpid="$(cat "$PIDFILE" 2>/dev/null || true)"
  if [ -n "$newpid" ] && kill -0 "$newpid" 2>/dev/null; then
    log "dwell 拉起成功 pid=$newpid"
    echo "DWELL_RESTARTED"
    exit 0
  fi
fi
log "dwell 拉起失败"
echo "DWELL_RESTART_FAILED"
exit 0
