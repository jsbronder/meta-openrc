LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=18590035fb3f5120d3a5e4b781f9ae25"

SRCREV = "ca55b66fb0feaa1cd7b89c89a83339b58ec5f4bd"

SRC_URI = " \
    git://github.com/openrc/openrc.git;nobranch=1;protocol=https \
    file://volatiles.initd \
    file://getty.confd \
    file://getty.initd \
"

S = "${WORKDIR}/git"

inherit pkgconfig meson

PACKAGECONFIG ??= "${@bb.utils.filter('DISTRO_FEATURES', 'audit pam selinux usrmerge', d)}"

PACKAGECONFIG[audit] = "-Daudit=enabled,-Daudit=disabled,audit"
PACKAGECONFIG[bash-completions] = "-Dbash-completions=true,-Dbash-completions=false,bash-completion"
PACKAGECONFIG[capabilities] = "-Dcapabilities=enabled,-Dcapabilities=disabled,libcap"
PACKAGECONFIG[pam] = "-Dpam=true,-Dpam=false,libpam"
PACKAGECONFIG[selinux] = "-Dselinux=enabled,-Dselinux=disabled,libselinux"
PACKAGECONFIG[usrmerge] = "-Drootprefix=/usr,-Drootprefix=/"
PACKAGECONFIG[zsh-completions] = "-Dzsh-completions=true,-Dzsh-completions=false"

openrc_sbindir = "${@bb.utils.contains('PACKAGECONFIG', 'usrmerge', '${sbindir}', '${base_sbindir}', d)}"
openrc_libdir = "${@bb.utils.contains('PACKAGECONFIG', 'usrmerge', '${libdir}', '${base_libdir}', d)}"

EXTRA_OEMESON += " \
    -Dos=Linux \
    -Dpkg_prefix=${prefix} \
    -Dsysvinit=true \
"

USE_VT ?= "1"
SYSVINIT_ENABLED_GETTYS ?= "1"

add_getty() {
    local dev="$1"
    local baud="$2"
    local term="$3"
    ln -snf getty ${D}${OPENRC_INITDIR}/getty.${dev}
    ln -snf ${OPENRC_INITDIR}/getty.${dev} ${D}${sysconfdir}/runlevels/default
    echo "baud=${baud}" > ${D}${OPENRC_CONFDIR}/getty.${dev}
    if [ -n "${term}" ]; then
        echo "term_type=${term}" >> ${D}${OPENRC_CONFDIR}/getty.${dev}
    fi
}

do_install:append() {
    # Default sysvinit doesn't do anything with keymaps on a minimal install so
    # we're not going to either.
    rm ${D}${sysconfdir}/runlevels/*/keymaps

    for svc in getty volatiles; do
        install -m 755 ${WORKDIR}/${svc}.initd ${D}${OPENRC_INITDIR}/${svc}
        ! [ -f ${WORKDIR}/${svc}.confd ] || install -m 644 ${WORKDIR}/${svc}.confd ${D}${OPENRC_CONFDIR}/${svc}
        sed -i "s|/sbin/openrc-run|${openrc_sbindir}/openrc-run|" ${D}${OPENRC_INITDIR}/${svc}
    done
    ln -snf ${OPENRC_INITDIR}/volatiles ${D}${sysconfdir}/runlevels/boot

    if ! ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/openrc
        mv ${D}${OPENRC_INITDIR} ${D}${sysconfdir}/openrc/$(basename ${OPENRC_INITDIR})
    fi

    if ${@bb.utils.contains('PACKAGECONFIG', 'usrmerge', 'true', 'false', d)}; then
        if [ -f ${D}${openrc_sbindir}/start-stop-daemon ]; then
            mv ${D}${openrc_sbindir}/start-stop-daemon ${D}${openrc_sbindir}/start-stop-daemon.openrc
        fi
    fi

    # Remove bonus TTY scripts installed when -Dsysvinit=true is selected, and add the correct ones.
    for x in 1 2 3 4 5 6; do
        rm ${D}${OPENRC_INITDIR}/agetty.tty${x} ${D}${sysconfdir}/runlevels/default/agetty.tty${x}
    done
    consoles="$(echo "${SERIAL_CONSOLES}" | tr ';' ',')"
    for entry in ${consoles}; do
        dev="$(echo "${entry}" | cut -d, -f2-)"
        baud="$(echo "${entry}" | cut -d, -f1)"
        add_getty ${dev} ${baud} vt102
    done
    if [ "${USE_VT}" = 1 ]; then
        for vt in ${SYSVINIT_ENABLED_GETTYS}; do
            add_getty "tty${vt}" 38400
        done
    fi
}

PACKAGES =+ "${PN}-init"

RDEPENDS:${PN} = " \
    kbd \
    ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'virtual-openrc-inittab', '', d)} \
    procps-sysctl \
    ${VIRTUAL-RUNTIME_init_manager} \
    util-linux-fsck \
    util-linux-mount \
    util-linux-umount \
"

RCONFLICTS:${PN} = " \
    init-ifupdown \
    modutils-initscripts \
"
RCONFLICTS:${PN}-init = " \
    ${@oe.utils.str_filter_out(d.expand('${PN}-init'), d.getVar('VIRTUAL-RUNTIME_init_manager'), d)} \
"

RPROVIDES:${PN}-init = " \
    ${@oe.utils.conditional('VIRTUAL-RUNTIME_init_manager', d.expand('${PN}-init'), 'virtual-openrc-inittab', '', d)} \
"

FILES:${PN}-doc:append = " ${datadir}/${BPN}/support"
FILES:${PN}:append = " ${openrc_libdir}/rc/"
FILES:${PN}-init = " \
    ${openrc_sbindir}/init \
    ${openrc_sbindir}/halt \
    ${openrc_sbindir}/poweroff \
    ${openrc_sbindir}/reboot \
    ${openrc_sbindir}/shutdown \
    ${openrc_sbindir}/openrc-init \
    ${openrc_sbindir}/openrc-shutdown \
    ${OPENRC_CONFDIR}/getty \
    ${OPENRC_CONFDIR}/getty.* \
    ${OPENRC_INITDIR}/getty \
    ${OPENRC_INITDIR}/getty.* \
    ${sysconfdir}/runlevels/default/getty.* \
"

inherit update-alternatives

ALTERNATIVE_PRIORITY = "100"
ALTERNATIVE:${PN} = "start-stop-daemon"
ALTERNATIVE:${PN}-init = "init halt poweroff reboot shutdown"
ALTERNATIVE_LINK_NAME[start-stop-daemon] = "${openrc_sbindir}/start-stop-daemon"
ALTERNATIVE_LINK_NAME[init] = "${openrc_sbindir}/init"
ALTERNATIVE_LINK_NAME[halt] = "${openrc_sbindir}/halt"
ALTERNATIVE_LINK_NAME[poweroff] = "${openrc_sbindir}/poweroff"
ALTERNATIVE_LINK_NAME[reboot] = "${openrc_sbindir}/reboot"
ALTERNATIVE_LINK_NAME[shutdown] = "${openrc_sbindir}/shutdown"
