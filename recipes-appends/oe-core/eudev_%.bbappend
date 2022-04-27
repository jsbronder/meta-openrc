inherit openrc

OPENRC_PACKAGES = ""

RDEPENDS:${PN}:append = "${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'udev-init-scripts', '', d)}"
