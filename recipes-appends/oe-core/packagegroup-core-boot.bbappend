RDEPENDS:${PN}:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'modutils-initscripts', '', d)}"
