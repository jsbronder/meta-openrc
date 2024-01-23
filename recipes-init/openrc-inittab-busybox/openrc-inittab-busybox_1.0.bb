SUMMARY = "BusyBox configuration for OpenRC"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "file://inittab.in"
S = "${WORKDIR}"
RPROVIDES:${PN} = "${@oe.utils.conditional('VIRTUAL-RUNTIME_init_manager', 'busybox', 'virtual-openrc-inittab', '', d)}"

INHIBIT_DEFAULT_DEPS = "1"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

USE_VT ?= "1"
SYSVINIT_ENABLED_GETTYS ?= "1"

sbindir="${@d.getVar(bb.utils.contains('PACKAGECONFIG', 'usrmerge', 'sbindir', 'base_sbindir', d))}"

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/inittab.in ${D}${sysconfdir}/inittab
}

python update_inittab() {
    import pathlib

    dest = pathlib.Path(d.getVar("D")) / d.getVar("sysconfdir").lstrip('/') / "inittab"
    lines = dest.read_text().split('\n')

    for baud, dev in (x.split(';') for x in d.getVar("SERIAL_CONSOLES").split()):
        lines.append(f"{dev}::askfirst:${{sbindir}}/getty {baud} - vt102")

    if d.getVar("USE_VT") == "1":
        lines.append('')
        for vt in d.getVar("SYSVINIT_ENABLED_GETTYS").split():
            lines.append(f"tty{vt}::respawn:${{sbindir}}/getty 38400 -")

    lines.append('')

    dest.write_text('\n'.join(d.expand(l) for l in lines))
}

do_install[postfuncs] += "update_inittab"

RCONFLICTS:${PN} = "busybox-inittab sysvinit-inittab openrc-inittab-sysvinit"
