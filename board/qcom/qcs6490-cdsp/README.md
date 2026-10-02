# QCS6490 CDSP

This defconfig builds a small static BusyBox + dropbear initramfs for the QCS6490 CDSP
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

## Shell and ssh

The initramfs boots to a BusyBox init that brings up `dsp0` (10.42.0.2, peer
10.42.0.1 = the APPS side of the GLINK IP link) in the background and starts
dropbear; log in as `root` with password `root`.  A shell is also offered on
`console` (QEMU's PL011).  The images are built at `-O1` and fully static:
clang-23 `-O2` miscompiles dropbear's crypto, and the initramfs has no dynamic
loader.

BusyBox is built with `-DBB_GLOBAL_CONST=` for every Hexagon target
(`package/busybox/busybox.mk`).  Without it `sh` segfaults (NULL+0x310 in
`ash_main`): BusyBox declares its `ptr_to_globals` as `extern const` and assigns
them through a cast in an out-of-line helper; clang treats the load as invariant
and schedules it in the same VLIW packet as that call, so it reads NULL.
