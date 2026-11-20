# Galaxy S23 Enter EDL

Enter Qualcomm Emergency Download mode on the Samsung Galaxy S23 Ultra without opening the phone or writing a partition.

Tested on:

- Device: SM-S918B
- Firmware: S918BXXUAGZIF
- Kernel: `5.15.197-android13-8-34343818-abS918BXXUAGZIF`
- Root: KernelSU Next 3.4.0

## Run

Requirements: Linux, `adb`, `lsusb`, USB debugging, KernelSU Next, and a matching `edl_reboot.ko`.

For the tested GZIF kernel, download `edl_reboot.ko` from the latest release and place it in `module/`.

```bash
./enter-edl.sh
```

Success:

```text
ID 05c6:9008 Qualcomm, Inc. Gobi Wireless Modem (QDL mode)
```

To leave EDL, hold Power and Volume Down for about eight seconds.

## Build

The kernel source and prepared output directory must match the running kernel. Their paths cannot contain spaces.

```bash
KERNEL_SRC=/path/to/kernel \
KERNEL_OUT=/path/to/kernel-out \
./build.sh
```

The module is written to `module/edl_reboot.ko`.

## Notes

Samsung clears Qualcomm download mode during reboot. The module registers the last reboot notifier and restores EDL when the reboot command is `edl`.

The module is kernel-specific. Do not load it on a different kernel build.

This repository does not include a Firehose programmer and does not flash the device.

License: GPL-2.0-only.
