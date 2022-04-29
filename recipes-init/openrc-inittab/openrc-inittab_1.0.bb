SUMMARY = "Inittab configuration for OpenRC"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "file://inittab"
S = "${WORKDIR}"

INHIBIT_DEFAULT_DEPS = "1"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

USE_VT ?= "1"
SYSVINIT_ENABLED_GETTYS ?= "1"

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/inittab ${D}${sysconfdir}/inittab
}

python update_inittab() {
    import pathlib

    lines = []

    for i, baud, dev in ((i, *x.split(';')) for i, x in enumerate(d.getVar("SERIAL_CONSOLES").split())):
        lines.append(f"s{i}:12345:respawn:/sbin/getty {baud} {dev} vt102")

    if d.getVar("USE_VT") == "1":
        lines.append('')
        for vt in d.getVar("SYSVINIT_ENABLED_GETTYS").split():
            lines.append(f"{vt}:12345:respawn:/sbin/getty 38400 tty{vt}")

    lines.append('')

    dest = pathlib.Path(d.getVar("D")) / d.getVar("sysconfdir").lstrip('/') / "inittab"
    with dest.open('a') as fp:
        fp.write('\n'.join(lines))
}

do_install[postfuncs] += "update_inittab"

RCONFLICTS:${PN} = "busybox-inittab sysvinit-inittab"
