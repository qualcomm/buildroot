# QCS6490 CDSP

This defconfig builds a small static BusyBox initramfs for the QCS6490 CDSP
(Hexagon v68) and the `bcain-qcs6490-sept27-2026` kernel tag.  Its outputs are:

* `images/vmlinux`
* `images/initrd` (gzip-compressed cpio)
* `images/qcs6490-cdsp.dtb`
* `images/qcs6490-cdsp.mbn` (the H2/loadlinux + kernel + DTB + initrd ELF)

`mkheximg` needs the H2 `loadlinux` ELF, which is platform firmware and is
therefore intentionally not embedded in Buildroot.  Build with the matching
loader selected explicitly:

```
make qcom_qcs6490_cdsp_defconfig
QCS6490_CDSP_H2=/path/to/hexagon_loadlinux_qcs6490_cdsp make
```

For the checked-out QEMU tree used during bring-up, that path is
`/home/brian/src/qemu/pc-bios/hexagon_loadlinux_qcs6490_cdsp`.

The combined `.mbn` is an ELF payload, not a Qualcomm-authenticated MBN.
`mkheximg` constrains it to the RubikPi CDSP PIL region and clears the GLINK
shared-memory window before Linux starts, so it is suitable input to an image
signer.  It is also accepted directly by the matching QEMU machine.

The physical RubikPi Peripheral Image Loader does require a Qualcomm-style
hash/signature container even though secure boot is disabled: unsigned ELF
payloads are rejected before H2 can run.  During bring-up, the generated file
was wrapped with the board-proven `qtestsign -v6 cdsp` flow.  Buildroot does not
perform that signing step and must not replace production DSP firmware.
