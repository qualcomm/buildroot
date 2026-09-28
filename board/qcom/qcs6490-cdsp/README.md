# QCS6490 CDSP

This defconfig builds a small static BusyBox initramfs for the QCS6490 CDSP
(Hexagon v68) and the `bcain-qcs6490-sept27-2026` kernel tag.  Its outputs are:

* `images/vmlinux`
* `images/initrd` (gzip-compressed cpio)
* `images/qcs6490-cdsp.dtb`

The platform-specific H2/loadlinux bootloader and the combined firmware image
are intentionally outside Buildroot's scope.  In particular, Buildroot does
not build `hexagon-hypervisor` or invoke `mkheximg`; a platform integration
must package or sign these three artifacts as appropriate.

```
make qcom_qcs6490_cdsp_defconfig
make
```
