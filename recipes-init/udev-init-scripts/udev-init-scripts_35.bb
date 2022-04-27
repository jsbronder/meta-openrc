SUMMARY = "OpenRC init scripts for udev"
HOMEPAGE = "https://gitweb.gentoo.org/proj/udev-gentoo-scripts.git/"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://init.d/udev;md5=14c7d7d983a7bc708cc23e88e7cdd856;beginline=2;endline=3"

SRC_URI = "https://gitweb.gentoo.org/proj/udev-gentoo-scripts.git/snapshot/udev-gentoo-scripts-${PV}.tar.gz"
SRC_URI[sha256sum] = "51eef30ef99f7f184aa403d190c105c5565e48c1c2d35b1b9f9f052c099fe366"

S = "${WORKDIR}/udev-gentoo-scripts-${PV}"

do_configure[noexec] = "1"

do_install() {
    oe_runmake DESTDIR=${D} install
}

RDEPENDS:${PN} = "openrc"
