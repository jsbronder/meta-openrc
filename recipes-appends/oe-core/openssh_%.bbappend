FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://sshd.initd file://sshd.confd"

inherit openrc

OPENRC_PACKAGES = "openssh-sshd"
OPENRC_SERVICES:openssh-sshd = "sshd"

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/sshd.initd
    openrc_install_confd ${UNPACKDIR}/sshd.confd
}
