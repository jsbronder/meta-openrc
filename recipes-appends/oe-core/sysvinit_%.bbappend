RDEPENDS:${PN}:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'sysvinit-inittab', '', d)}"
