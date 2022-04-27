OPENRC_PACKAGES="avahi-daemon avahi-dnsconfd"

inherit openrc

EXTRA_OECONF:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', '--with-distro=gentoo', '', d)}"
