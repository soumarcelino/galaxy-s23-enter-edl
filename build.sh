#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${KERNEL_SRC:?Set KERNEL_SRC to the matching kernel source directory}"
KERNEL_OUT="${KERNEL_OUT:-$KERNEL_SRC}"
DEVICE_RELEASE="${DEVICE_RELEASE:-5.15.197-android13-8-34343818-abS918BXXUAGZIF}"
UTS_HEADER="$KERNEL_OUT/include/generated/utsrelease.h"
KBUILD_SYMBOLS="$ROOT/module/.Module.symvers.gzi.kbuild"

case "$KERNEL_SRC:$KERNEL_OUT" in
    *" "*) echo "Kernel paths cannot contain spaces." >&2; exit 1 ;;
esac

[[ -f "$KERNEL_OUT/Module.symvers" ]] || {
    echo "Missing $KERNEL_OUT/Module.symvers" >&2
    exit 1
}

[[ -f "$UTS_HEADER" ]] || {
    echo "Missing $UTS_HEADER" >&2
    exit 1
}

original_uts="$(cat "$UTS_HEADER")"
cleanup() {
    printf '%s\n' "$original_uts" > "$UTS_HEADER"
    rm -f "$KBUILD_SYMBOLS"
}
trap cleanup EXIT
printf '#define UTS_RELEASE "%s"\n' "$DEVICE_RELEASE" > "$UTS_HEADER"
awk '{ print $0 "\t" }' "$ROOT/module/Module.symvers.gzi" > "$KBUILD_SYMBOLS"

make -C "$KERNEL_SRC" O="$KERNEL_OUT" \
    ARCH=arm64 LLVM=1 LLVM_IAS=1 \
    M="$ROOT/module" \
    KBUILD_EXTRA_SYMBOLS="$KBUILD_SYMBOLS" \
    modules

llvm-strip --strip-debug "$ROOT/module/edl_reboot.ko"
modinfo "$ROOT/module/edl_reboot.ko" | grep -E 'description|vermagic|depends'
