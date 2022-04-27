# Add services to the specified runlevel
#
# @param    - Filesystem root
# @param    - Runlevel name
# @params   - Services to add to default runlevel
openrc_add_to_runlevel() {
    local destdir=$1
    local runlevel=$2
    local svc

    if ! echo ${destdir} | grep -q "^/"; then
        bbfatal "Destination '${destdir}' does not look like a path"
    fi

    shift
    shift

    [ ! -d ${destdir}${sysconfdir}/runlevels/${runlevel} ] \
        && install -d ${destdir}${sysconfdir}/runlevels/${runlevel}

    for svc in $*; do
        ln -snf ${OPENRC_INITDIR}/${svc} ${destdir}${sysconfdir}/runlevels/${runlevel}
    done

}

# Add services to the default runlevel
#
# @param    - Filesystem root
# @params   - Services to add to default runlevel
openrc_add_to_default_runlevel() {
    local dest=$1
    shift
    openrc_add_to_runlevel ${dest} default $*
}

# Add services to the boot runlevel
#
# @param    - Filesystem root
# @params   - Services to add to boot runlevel
openrc_add_to_boot_runlevel() {
    local dest=$1
    shift
    openrc_add_to_runlevel ${dest} boot $*
}

# Stack a runlevel inside another
#
# @param    - Filesystem root
# @param    - Parent runlevel
# @param    - Runlevel to add to the parent.
openrc_stack_runlevel() {
    local destdir=$1
    local parent=$2
    local src=$3

    if ! echo ${destdir} | grep -q "^/"; then
        bbfatal "Destination '${destdir}' does not look like a path"
    fi

    if [ ! -d ${destdir}${sysconfdir}/runlevels/${src} ]; then
        bbfatal "Source runlevel '${src}' does not exist"
    fi

    [ ! -d ${destdir}${sysconfdir}/runlevels/${parent} ] \
        && install -d ${destdir}${sysconfdir}/runlevels/${parent}

    ln -snf ../${src} ${destdir}${sysconfdir}/runlevels/${parent}/
}

# Replace the installed inittab with one that uses OpenRC.
#
# @param    - Destination dir where /etc/inittab is already installed.
#             Defaults to ${IMAGE_ROOTFS}.  Note that no consoles are
#             enabled by default, they must be added by appending to
#             etc/inittab.
openrc_replace_inittab() {
    local destdir=${1:-${IMAGE_ROOTFS}}

    if [ -z "${destdir}" ]; then
        bbfatal "No destination specified for inittab replacement and not build an image"
    elif [ ! -s "${destdir}${sysconfdir}/inittab" ]; then
        bbwarn "No inittab installed"
    fi

    cat <<-EOF > ${destdir}${sysconfdir}/inittab
		# Default runlevel.
		id:3:initdefault:

		# System initialization, mount local filesystems, etc.
		si::sysinit:/sbin/openrc sysinit

		# Further system initialization, brings up the boot runlevel.
		rc::bootwait:/sbin/openrc boot

		l0:0:wait:/sbin/openrc shutdown
		l0s:0:wait:/sbin/halt -dhp
		l1:1:wait:/sbin/openrc single
		l2:2:wait:/sbin/openrc nonetwork
		l3:3:wait:/sbin/openrc default
		l4:4:wait:/sbin/openrc default
		l5:5:wait:/sbin/openrc default
		l6:6:wait:/sbin/openrc reboot
		l6r:6:wait:/sbin/reboot -d
		#z6:6:respawn:/sbin/sulogin

		# new-style single-user
		su0:S:wait:/sbin/openrc single
		su1:S:wait:/sbin/sulogin

		# What to do at the "Three Finger Salute".
		ca:12345:ctrlaltdel:/sbin/shutdown -r now

		# TERMINALS
		# c1:12345:respawn:/sbin/agetty 38400 tty1 linux

		# SERIAL CONSOLES
		#s0:12345:respawn:/sbin/agetty -8 --autologin root --login-pause -L 115200 ttyS0 xterm
		#s1:12345:respawn:/sbin/agetty -L 115200 ttyS1 vt100
	EOF
}

# Like oe-core/meta/classes/rootfs-postcommands, allow dropbear to accept
# logins from accounts with an empty password string if debug-tweaks or
# allow-empty-password is enabled.
ROOTFS_POSTPROCESS_COMMAND += "${@bb.utils.contains_any('IMAGE_FEATURES', ['debug-tweaks', 'allow-empty-password'], 'openrc_ssh_allow_empty_password; ', '', d)}"

openrc_ssh_allow_empty_password() {
    local confd=${IMAGE_ROOTFS}${OPENRC_CONFDIR}/dropbear

    if [ ! -s "${confd}" ]; then
        echo 'COMMAND_ARGS="-B"' > ${confd}
    else
        if ! grep '^COMMAND_ARGS=".*-B[ \t"]' ${confd}; then
            # Add -B, Allow blank password logins
            sed -i 's,COMMAND_ARGS="\([^"]*\)",COMMAND_ARGS="\1 -B",' ${confd}
        fi

        # Remove -w, Disallow root logins
        sed -i 's,-w\([ \t"]\),\1,' ${confd}
    fi
}
