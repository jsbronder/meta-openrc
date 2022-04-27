LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2307fb28847883ac2b0b110b1c1f36e0"

SRCREV = "d8e4da5e5d4d77cdd705823aa71990276a872ee1"

SRC_URI = " \
    git://github.com/openrc/openrc.git;nobranch=1;protocol=https \
    file://0001-mk-break-up-long-SED_REPLACE-line.patch \
    file://0002-fix-alternative-conf-and-init-dir-support.patch \
    file://0001-src-rc-rc-logger.h-fix-build-failure-against-gcc-10.patch \
    file://volatiles.initd \
"

S = "${WORKDIR}/git"

EXTRA_OEMAKE = " \
    PKG_PREFIX=${prefix} \
    LIBEXECDIR=${base_libdir}/rc \
    LIBNAME=lib \
    MKTOOLS=no \
    OS=Linux \
    INITDIRNAME=$(basename ${OPENRC_INITDIR}) \
    CONFDIRNAME=$(basename ${OPENRC_CONFDIR}) \
"

openrc_do_patch() {
    # QA[useless-rpaths]: We don't need an rpath to /lib
    sed -i '/-rpath=/d' ${S}/mk/prog.mk

    # Default sysvinit doesn't do anything with keymaps on a minimal install
    # so we're not going to either.
    sed -i -e 's| keymaps | |' ${S}/runlevels/Makefile
}

do_patch:append() {
    bb.build.exec_func('openrc_do_patch', d)
}

do_install() {
    oe_runmake DESTDIR=${D} install

    # Example code that requires perl.
    rm -r ${D}${prefix}/share/${PN}/support/deptree2dot

    install -m 755 ${WORKDIR}/volatiles.initd ${D}${OPENRC_INITDIR}/volatiles
    ln -snf ${OPENRC_INITDIR}/volatiles ${D}${sysconfdir}/runlevels/boot

    if ! ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/openrc
        mv ${D}${OPENRC_INITDIR} ${D}${sysconfdir}/openrc/$(basename ${OPENRC_INITDIR})
    fi
}

RDEPENDS:${PN} = " \
    kbd \
    procps-sysctl \
    sysvinit \
    util-linux-mount \
    util-linux-umount \
"

FILES:${PN}-dbg:append := " \
    ${base_libdir}/rc/bin/.debug \
    ${base_libdir}/rc/sbin/.debug \
"

FILES:${PN}:append := " \
    ${base_libdir}/rc/* \
"

inherit update-alternatives

ALTERNATIVE_PRIORITY = "100"
ALTERNATIVE:${PN} = "start-stop-daemon"
ALTERNATIVE_LINK_NAME[start-stop-daemon] = "${base_sbindir}/start-stop-daemon"
