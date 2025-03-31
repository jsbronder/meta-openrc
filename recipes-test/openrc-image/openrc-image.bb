DESCRIPTION = "Minimal image using openrc"

IMAGE_FEATURES += "ssh-server-dropbear"

IMAGE_INSTALL += " \
    openrc \
    packagegroup-core-boot \
"

# In styhead, packagegroup-core-boot is fixed to not unilaterally set
# VIRTUAL-RUNTIME_dev_manager to udev locally, but here we need to add the
# dependency in case it's not udev.
IMAGE_INSTALL += "${@oe.utils.conditional('VIRTUAL-RUNTIME_dev_manager', 'busybox-mdev', 'busybox-mdev', '', d)}"

IMAGE_BASENAME := "openrc"

inherit core-image openrc-image

# The logging runlevel is just an example that serves to make sure that
# runlevel stacking and adding of services is functioning correctly.
OPENRC_STACKED_RUNLEVELS += "logging:default"
OPENRC_SERVICES += " \
    sysinit:udev-trigger \
    default:udev-settle \
    logging:busybox-klogd \
    logging:busybox-syslogd \
"

boot_to_logging() {
    local mgr=${@d.getVar('VIRTUAL-RUNTIME_init_manager')}

    if [ "${mgr}" = "sysvinit" ]; then
        sed -i '/^l[345]/s,default,logging,' ${IMAGE_ROOTFS}${sysconfdir}/inittab
    elif [ "${mgr}" = "busybox" ]; then
        sed -i 's/openrc default/openrc logging/' ${IMAGE_ROOTFS}${sysconfdir}/inittab
    elif [ "${mgr}" = "openrc-init" ]; then
        sed -i 's/^#\(rc_default_runlevel="\).*/\1logging"/' ${IMAGE_ROOTFS}${sysconfdir}/rc.conf
    fi
}
ROOTFS_POSTPROCESS_COMMAND += "${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'boot_to_logging; ', '', d)}"

# vim: ft=bitbake
