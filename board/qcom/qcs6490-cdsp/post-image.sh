#!/bin/sh
# SPDX-License-Identifier: BSD-3-Clause
#
# Assemble the four artifacts consumed by the QCS6490 CDSP workflow:
# vmlinux, initrd, DTB, and an H2/loadlinux combined ELF named .mbn.
# mkheximg deliberately emits an ELF (rather than Qualcomm's signed MBN
# container).  This is useful to QEMU and to development devices with secure
# boot disabled; production devices still require the platform signing flow.

set -eu

images_dir=$1
build_dir=$(dirname "$images_dir")/build
linux_dir=$(find "$build_dir" -maxdepth 1 -name 'linux-*' -type d \
	-exec test -f '{}/vmlinux' ';' -printf '%T@ %p\n' | sort -rn | head -n 1 | cut -d' ' -f2-)

if [ -z "$linux_dir" ]; then
	echo "qcs6490-cdsp: cannot locate the Linux build directory" >&2
	exit 1
fi

cp -f "$linux_dir/vmlinux" "$images_dir/vmlinux"
cp -f "$images_dir/rootfs.cpio.gz" "$images_dir/initrd"

dtb="$images_dir/qcs6490-cdsp.dtb"
if [ ! -f "$dtb" ]; then
	echo "qcs6490-cdsp: missing $dtb" >&2
	exit 1
fi

# H2 is hardware/platform firmware, not Buildroot output.  For the matching
# QEMU machine it is pc-bios/hexagon_loadlinux_qcs6490_cdsp.  Requiring an
# explicit path prevents accidentally shipping an H2 built for another DSP.
: "${QCS6490_CDSP_H2:?Set QCS6490_CDSP_H2 to the qcs6490 CDSP loadlinux ELF}"
if [ ! -f "$QCS6490_CDSP_H2" ]; then
	echo "qcs6490-cdsp: H2 loader not found: $QCS6490_CDSP_H2" >&2
	exit 1
fi

"$linux_dir/scripts/hexagon/mkheximg" \
	--h2 "$QCS6490_CDSP_H2" \
	--linux "$images_dir/vmlinux" \
	--dtb "$dtb" \
	--initramfs "$images_dir/initrd" \
	--linux-addr 0xa1000000 \
	--initramfs-addr 0xa8000000 \
	--zero 0xd7c00000:0x20000 \
	--region-end 0x8a700000 \
	-o "$images_dir/qcs6490-cdsp.mbn"
