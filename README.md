# Galaxy S23 Enter EDL

Kernel module and launcher for rebooting the Samsung Galaxy S23 Ultra into Qualcomm EDL mode.

## Supported build

- Samsung Galaxy S23 Ultra SM-S918B
- Firmware S918BXXUAGZIF
- Kernel `5.15.197-android13-8-34343818-abS918BXXUAGZIF`
- KernelSU Next 3.4.0

## Run

Download `edl_reboot.ko` from the [latest release](https://github.com/soumarcelino/galaxy-s23-enter-edl/releases/latest) and place it in `module/`.

Connect the phone with USB debugging enabled, then run:

```bash
./enter-edl.sh
```

The USB device appears as:

```text
ID 05c6:9008 Qualcomm, Inc. Gobi Wireless Modem (QDL mode)
```

Hold Power and Volume Down for about eight seconds to reboot from EDL.

## Build

```bash
KERNEL_SRC=/path/to/kernel \
KERNEL_OUT=/path/to/kernel-out \
./build.sh
```

Output: `module/edl_reboot.ko`

## How it works

Samsung clears Qualcomm download mode during reboot. The module registers the last reboot notifier and restores EDL when the reboot command is `edl`.

Each kernel build uses its matching module.

License: GPL-2.0-only.
