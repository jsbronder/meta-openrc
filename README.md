Introduction
------------

This layer adds support for OpenRC to OpenEmbedded similarly to how rc.d
scripts and systemd are supported.  OpenRC can be selected by adding this
layer and adding *openrc* to *DISTRO_FEATURES*.

Both the standard rc.d scripts and those from OpenRC expect to live in
`/etc/init.d`.  When *openrc* is added to *DISTRO_FEATURES*, the former will be
removed from that directory entirely and only OpenRC capable scripts will be
installed [1].  If *openrc* is not added to *DISTRO_FEATURES* this layer will
not have any effect aside from providing the openrc recipe.


1.  This assumes that this layer has an append for the recipe in question.

Dependencies
------------

The meta-openrc layer depends on:

	URI: https://git.openembedded.org/openembedded-core
	layers: meta
	branch: kirkstone

Contributing
------------

Feel free to to use the github pull request UI or to directly send emails to
the maintainer(s) using something like:

`git send-email -M -1 --to=jsbronder@cold-front.org --subject-prefix=meta-openrc][branch][PATCH`

Usage
-----

1. Add the layer to your build:

    `bitbake-layers add-layer /path/to/meta-openrc`

2. Set *INIT_MANAGER* to *openrc* in your distro or local config:

    `INIT_MANAGER = "openrc"`

3. For recipes providing OpenRC services, inherit the `openrc` bbclass and configure services:

    ```bitbake
    SRC_URI:append = " \
        file://mysetupservice.initd \
        file://mysetupservice.confd \
        file://${PN}-init.initd \
        file://${PN}-daemon.initd \
    "

    inherit openrc

    # Define which packages provide OpenRC services, by default OPENRC_PACKAGES = "${PN}"
    OPENRC_PACKAGES = "${PN}-setup ${PN}-daemon"

    # Configure services for each package
    OPENRC_SERVICES:${PN}-setup = "mysetupservice" # Could be also ${PN}-setup for e.g.

    # Services are disabled by default
    # OPENRC_AUTO_ENABLE:${PN}-setup = "disable"

    OPENRC_SERVICES:${PN}-daemon = "${PN}-init ${PN}-daemon"
    OPENRC_AUTO_ENABLE:${PN}-daemon = "enable"
    # All services in ${PN}-daemon package are auto-enabled

    # Override runlevel for specific services (default is 'default')
    OPENRC_RUNLEVEL:${PN}-init = "boot"

    do_install:append() {
        # Install OpenRC conf script
        openrc_install_confd ${UNPACKDIR}/mysetupservice.confd

        # Install OpenRC scripts
        openrc_install_initd ${UNPACKDIR}/mysetupservice.initd
        openrc_install_initd ${UNPACKDIR}/${PN}-init.initd
        openrc_install_initd ${UNPACKDIR}/${PN}-daemon.initd
    }

    FILES:${PN}-setup += " \
        ${OPENRC_INITDIR}/mysetupservice.initd \
        ${OPENRC_CONFDIR}/mysetupservice.confd \
    "

    CONFFILES:${PN}-setup += " \
        ${OPENRC_CONFDIR}/mysetupservice.confd \
    "

    FILES:${PN}-daemon += " \
        ${OPENRC_INITDIR}/${PN}-init.initd \
        ${OPENRC_INITDIR}/${PN}-daemon.initd \
    "
    ```

    **Important:** Each package listed in `OPENRC_PACKAGES` must correspond to an actual package defined in the recipe's `PACKAGES` variable. The build will fail with an error if an OpenRC package doesn't match an existing Yocto package.

    **Available configuration variables:**

    - **OPENRC_PACKAGES**: Space-separated list of packages that provide OpenRC services (defaults to `${PN}`)
    - **OPENRC_SERVICES[:package]**: Space-separated list of service names for a package (defaults to package name)
    - **OPENRC_AUTO_ENABLE[:package]**: Set to "enable" to automatically enable services (defaults to "disable")
    - **OPENRC_RUNLEVEL[:service]**: Target runlevel for a specific service (defaults to "default")

    **Helper functions for installation:**

    - **openrc_install_initd**: Install an OpenRC init script to `/etc/init.d/`
    - **openrc_install_confd**: Install an OpenRC configuration file to `/etc/conf.d/`

4. Update your image to `inherit openrc-image` and set the following as
   necessary (see [openrc-image.bb](recipes-test/openrc-image/openrc-image.bb)
   for an example):

    1. **OPENRC_SERVICES**: Define additional services to add to the paired
       runlevel using a whitespace delimited list of
       *[runlevel]:[service-name]*.

    2. **OPENRC_STACKED_RUNLEVELS**: define runlevels to be stacked on top of
       other runlevels using a whitespace delimited list of *[base
       runlevel]:[stacked runlevel]*

Note on pre-mickledore releases
-------------------------------
Prior to mickledore, this layer did not have the *INIT_MANAGER* configuration
hook.  Instead it was necessary to add *openrc* to *DISTRO_FEATURES*.  See
https://github.com/jsbronder/meta-openrc/pull/24.

Note on pre-kirkstone releases
-------------------------------
Prior to kirkstone, this layer used the quick-and-easy approach of relocating
openrc scripts to `/etc/openrc.d` and supplying a single omnibus recipe for
additional initd scripts.  Images were expected to define their own
*ROOTFS_POSTPROCESS_COMMAND* within which they'd update inittab and add
services to runlevels as necessary.  With kirkstone, that approach was replaced
with a more conventional one following the pattern set by the *update-rc.d* and
*systemd* bbclasses in openembedded-core.

Maintenance
-----------
Maintainer: Justin Bronder <jsbronder@cold-front.org>

