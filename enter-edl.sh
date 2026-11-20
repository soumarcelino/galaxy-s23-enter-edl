#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KO="${1:-$ROOT/module/edl_reboot.ko}"
ADB_BIN="${ADB:-adb}"
ADB_ARGS=()

if [[ -n "${ADB_SERIAL:-}" ]]; then
    ADB_ARGS=(-s "$ADB_SERIAL")
fi

adb_cmd() {
    "$ADB_BIN" "${ADB_ARGS[@]}" "$@"
}

if lsusb -d 05c6:9008 >/dev/null 2>&1; then
    echo "Device is already in EDL (05c6:9008)."
    exit 0
fi

[[ -f "$KO" ]] || {
    echo "Missing module: $KO" >&2
    exit 1
}

[[ "$(adb_cmd get-state 2>/dev/null)" == "device" ]] || {
    echo "No authorized ADB device found." >&2
    exit 1
}

device_release="$(adb_cmd shell uname -r | tr -d '\r')"
module_release="$(modinfo -F vermagic "$KO" | awk '{print $1}')"

[[ "$device_release" == "$module_release" ]] || {
    echo "Kernel mismatch." >&2
    echo "Device: $device_release" >&2
    echo "Module: $module_release" >&2
    exit 1
}

adb_cmd push "$KO" /data/local/tmp/edl_reboot.ko >/dev/null
adb_cmd shell su -c \
    'grep -q "^edl_reboot " /proc/modules || /data/adb/ksu/bin/ksud insmod /data/local/tmp/edl_reboot.ko'

echo "Rebooting to EDL..."
adb_cmd shell su -c 'reboot edl' >/dev/null 2>&1 || true

for _ in $(seq 1 30); do
    if lsusb -d 05c6:9008; then
        exit 0
    fi
    sleep 1
done

echo "Device did not appear as 05c6:9008 within 30 seconds." >&2
exit 1
