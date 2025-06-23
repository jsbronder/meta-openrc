LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=18590035fb3f5120d3a5e4b781f9ae25"

SRCREV = "fec22aaac8bad393b372175130d184b74a61d2b2"

SRC_URI = " \
    git://github.com/openrc/openrc.git;nobranch=1;protocol=https \
    file://volatiles.initd \
    file://getty.confd \
    file://getty.initd \
"

DEPENDS += "libcap"

inherit pkgconfig meson

PACKAGECONFIG ??= "${@bb.utils.filter('DISTRO_FEATURES', 'audit pam selinux', d)}"

PACKAGECONFIG[audit] = "-Daudit=enabled,-Daudit=disabled,audit"
PACKAGECONFIG[bash-completions] = "-Dbash-completions=true,-Dbash-completions=false,bash-completion"
PACKAGECONFIG[pam] = "-Dpam=true,-Dpam=false,libpam"
PACKAGECONFIG[selinux] = "-Dselinux=enabled,-Dselinux=disabled,libselinux"
PACKAGECONFIG[zsh-completions] = "-Dzsh-completions=true,-Dzsh-completions=false"

EXTRA_OEMESON += " \
    --bindir ${base_bindir} \
    --sbindir ${base_sbindir} \
    --libdir ${base_libdir} \
    --libexecdir ${libexecdir} \
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
        install -m 755 ${UNPACKDIR}/${svc}.initd ${D}${OPENRC_INITDIR}/${svc}
        sed -i "1s,.*,#\!${base_sbindir}/openrc-run," ${D}${OPENRC_INITDIR}/${svc}
        ! [ -f ${UNPACKDIR}/${svc}.confd ] || install -m 644 ${UNPACKDIR}/${svc}.confd ${D}${OPENRC_CONFDIR}/${svc}
    done
    ln -snf ${OPENRC_INITDIR}/volatiles ${D}${sysconfdir}/runlevels/boot

    if ! ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/openrc
        mv ${D}${OPENRC_INITDIR} ${D}${sysconfdir}/openrc/$(basename ${OPENRC_INITDIR})
    fi

    if ! ${@bb.utils.contains('DISTRO_FEATURES', 'usrmerge', 'true', 'false', d)}; then
        install -d ${D}${libdir}
        mv ${D}${base_libdir}/pkgconfig ${D}${libdir}/

        # Match path used by alternatives: busybox/dpkg
        if [ ! -f ${D}${sbindir}/start-stop-daemon ]; then
            install -d ${D}${sbindir}
            mv ${D}${base_sbindir}/start-stop-daemon ${D}${sbindir}
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
FILES:${PN}:append = " ${libdir}/rc/"
FILES:${PN}-init = " \
    ${base_sbindir}/init \
    ${base_sbindir}/halt \
    ${base_sbindir}/poweroff \
    ${base_sbindir}/reboot \
    ${base_sbindir}/shutdown \
    ${base_sbindir}/openrc-init \
    ${base_sbindir}/openrc-shutdown \
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
ALTERNATIVE_LINK_NAME[start-stop-daemon] = "${sbindir}/start-stop-daemon"
ALTERNATIVE_LINK_NAME[init] = "${base_sbindir}/init"
ALTERNATIVE_LINK_NAME[halt] = "${base_sbindir}/halt"
ALTERNATIVE_LINK_NAME[poweroff] = "${base_sbindir}/poweroff"
ALTERNATIVE_LINK_NAME[reboot] = "${base_sbindir}/reboot"
ALTERNATIVE_LINK_NAME[shutdown] = "${base_sbindir}/shutdown"
