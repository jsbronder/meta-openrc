# Use OpenRC for system initialization
DISTRO_FEATURES:append = " openrc"
DISTRO_FEATURES_BACKFILL_CONSIDERED:append = " sysvinit systemd"
VIRTUAL-RUNTIME_init_manager ??= "openrc-init"
VIRTUAL-RUNTIME_initscripts ??= "openrc"
VIRTUAL-RUNTIME_login_manager ??= "busybox"
VIRTUAL-RUNTIME_dev_manager ??= "busybox-mdev"
VIRTUAL-RUNTIME_keymaps ??= "openrc"

# Direct assignment as this is loaded after oe-core's default-providers.inc
VIRTUAL-RUNTIME_base-utils-hwclock = "openrc"
