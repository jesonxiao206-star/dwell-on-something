#!/usr/bin/env bash
# dwell 后端启动脚本：口令从环境变量 DWELL_KEY 或同目录 .key 文件读，
# nohup 常驻，日志追加到 server/server.log，pid 由 server.js 写 server/server.pid。
set -euo pipefail

cd "$(dirname "$0")"

if [ -z "${DWELL_KEY:-}" ] && [ -f .key ]; then
  DWELL_KEY="$(tr -d '[:space:]' < .key)"
fi
if [ -z "${DWELL_KEY:-}" ]; then
  echo "DWELL_KEY 未设置且 server/.key 不存在，拒绝启动" >&2
  exit 1
fi
export DWELL_KEY
export PORT="${PORT:-8377}"

if [ -f server.pid ]; then
  oldpid="$(cat server.pid 2>/dev/null || true)"
  if [ -n "$oldpid" ] && kill -0 "$oldpid" 2>/dev/null; then
    echo "dwell 已在运行 pid=$oldpid"
    exit 0
  fi
fi

nohup node server.js >> server.log 2>&1 &
echo "dwell 已启动 pid=$! port=$PORT"
