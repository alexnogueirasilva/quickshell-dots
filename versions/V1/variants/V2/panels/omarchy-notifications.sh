#!/usr/bin/env bash
# Print Rise's notification poll payload.
# Mako wins when it is the running daemon. Omarchy 4 owns
# org.freedesktop.Notifications inside omarchy-shell, and keeps one JSON file
# per toast under $XDG_STATE_HOME/omarchy/notifications/.
set -euo pipefail

if command -v makoctl >/dev/null 2>&1 && pidof mako >/dev/null 2>&1; then
  pid="$(pidof mako | awk '{print $1}')"
  bid="$(cat /proc/sys/kernel/random/boot_id 2>/dev/null || true)"
  st="$(awk '{print $22}' "/proc/$pid/stat" 2>/dev/null || true)"
  tok="$bid-$pid-$st"
  lst="$(makoctl list -j 2>/dev/null || true)"
  his="$(makoctl history -j 2>/dev/null || true)"
  [ -n "$lst" ] || lst='[]'
  [ -n "$his" ] || his='[]'
  printf '{"token":"%s","list":%s,"history":%s}\n' "$tok" "$lst" "$his"
  exit 0
fi

python3 - << 'PY'
import glob, json, os

home = os.environ.get("HOME", "")
root = os.path.join(home, ".local", "state", "omarchy", "notifications")
history = os.path.join(root, "history")

def load(path):
    try:
        with open(path, encoding="utf-8") as handle:
            data = json.load(handle)
    except (OSError, json.JSONDecodeError):
        return None
    if not isinstance(data, dict) or "summary" not in data:
        return None
    return {
        "id": int(data.get("id") or 0),
        "app_name": data.get("app") or data.get("app_name") or "",
        "summary": data.get("summary") or "",
        "body": data.get("body") or "",
    }

live = []
past = []
for path in glob.glob(os.path.join(root, "*.json")):
    row = load(path)
    if row:
        live.append(row)
for path in glob.glob(os.path.join(history, "*.json")):
    row = load(path)
    if row:
        past.append(row)

print(json.dumps({"token": "omarchy", "list": live, "history": past}, ensure_ascii=False))
PY
