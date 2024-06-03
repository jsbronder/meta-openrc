FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

URI_ID = "id=ee9f408582a8f94577446f39b1ae3f8c85dd621b"
SRC_URI += " \
    https://gitweb.gentoo.org/repo/gentoo.git/plain/net-fs/nfs-utils/files/nfs.confd?${URI_ID};name=nfs.confd;downloadfilename=nfs.confd \
    https://gitweb.gentoo.org/repo/gentoo.git/plain/net-fs/nfs-utils/files/nfs.initd?${URI_ID};name=nfs.initd;downloadfilename=nfs.initd \
    https://gitweb.gentoo.org/repo/gentoo.git/plain/net-fs/nfs-utils/files/nfsclient.confd?${URI_ID};name=nfsclient.confd;downloadfilename=nfsclient.confd \
    https://gitweb.gentoo.org/repo/gentoo.git/plain/net-fs/nfs-utils/files/nfsclient.initd?${URI_ID};name=nfsclient.initd;downloadfilename=nfsclient.initd \
    https://gitweb.gentoo.org/repo/gentoo.git/plain/net-fs/nfs-utils/files/rpc.gssd.initd?${URI_ID};name=rpc.gssd;downloadfilename=rpc.gssd.initd \
    https://gitweb.gentoo.org/repo/gentoo.git/plain/net-fs/nfs-utils/files/rpc.idmapd.initd?${URI_ID};name=rpc.idmapd;downloadfilename=rpc.idmapd.initd \
    https://gitweb.gentoo.org/repo/gentoo.git/plain/net-fs/nfs-utils/files/rpc.pipefs.initd?${URI_ID};name=rpc.pipefs;downloadfilename=rpc.pipefs.initd \
    https://gitweb.gentoo.org/repo/gentoo.git/plain/net-fs/nfs-utils/files/rpc.statd.initd?${URI_ID};name=rpc.statd;downloadfilename=rpc.statd.initd \
    https://gitweb.gentoo.org/repo/gentoo.git/plain/net-fs/nfs-utils/files/rpc.svcgssd.initd?${URI_ID};name=rpc.svcgssd;downloadfilename=rpc.svcgssd.initd \
"
SRC_URI[nfs.confd.sha256sum] = "c652a4fe8a43dc68a818345db2b3acc560663b5b6c969324d4f23afb0fb96a94"
SRC_URI[nfs.initd.sha256sum] = "4faf15ba93a61b5da95555544c1f84bb128ac7642471808bf6670900a23ad7cf"
SRC_URI[nfsclient.initd.sha256sum] = "56973f5c8196b4227114d94a1d3c8c95518be5a02c6b5dc97da243d0b6086843"
SRC_URI[nfsclient.confd.sha256sum] = "e8842fca856eae598fb8fe15ed8d3cef13e61851217be66b8cc4087af8cee8ad"
SRC_URI[rpc.gssd.sha256sum] = "83c318a7502718a3e1693869297b95db1c32270b37d45b26b2bc151ec06f3c08"
SRC_URI[rpc.idmapd.sha256sum] = "dc21ce6ba28f45eb450d5d0dbe7e5ea706b1547c8bece4ddb6836a5433427bd6"
SRC_URI[rpc.pipefs.sha256sum] = "04102bff9b13d2e7c4e30603e7c98fe412d5f6c907a37dcea95f420f153c29ae"
SRC_URI[rpc.statd.sha256sum] = "6f3d93442db0c17436547a16155e0d61dd5cd17f49fd3a642a9a5de833411d51"
SRC_URI[rpc.svcgssd.sha256sum] = "272905335a7c82034c6bac007bd4477aae21d8ce49e82355c48301db771ba77e"

LICENSE += "${@bb.utils.contains('DISTRO_FEATURES', 'openrc', '& GPL-2.0-only', '', d)}"

inherit openrc

OPENRC_PACKAGES = "${PN} ${PN}-client"
OPENRC_SERVICES:${PN} = "nfs rpc.svcgssd"
OPENRC_SERVICES:${PN}-client = "nfsclient rpc.statd rpc.idmapd rpc.gssd rpc.pipefs"

do_install:append() {
    openrc_install_initd ${UNPACKDIR}/nfs.initd
    openrc_install_confd ${UNPACKDIR}/nfs.confd
    openrc_install_initd ${UNPACKDIR}/rpc.svcgssd.initd

    openrc_install_initd ${UNPACKDIR}/nfsclient.initd
    openrc_install_confd ${UNPACKDIR}/nfsclient.confd
    openrc_install_initd ${UNPACKDIR}/rpc.statd.initd
    openrc_install_initd ${UNPACKDIR}/rpc.idmapd.initd
    openrc_install_initd ${UNPACKDIR}/rpc.gssd.initd
    openrc_install_initd ${UNPACKDIR}/rpc.pipefs.initd

    if ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'true', 'false', d)}; then
        sed -i "s,=/sbin/rpc.statd,=${sbindir}/rpc.statd," ${D}${OPENRC_INITDIR}/rpc.statd
    fi

    if ! ${@bb.utils.contains_any('PACKAGECONFIG', ['nfsv41', 'nfsv4'], 'true', 'false', d)}; then
        sed -i "s, rpc.idmapd,," ${D}${OPENRC_INITDIR}/nfsclient
    fi
}
