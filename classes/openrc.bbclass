# The list of packages that have openrc initd scripts added.  For each entry,
# OPENRC_SERVICES:[package] lists the initd scripts in the package.  If undefined then
# [package].initd is used.
OPENRC_PACKAGES ?= "${PN}"
OPENRC_PACKAGES:class-native ?= ""
OPENRC_PACKAGES:class-nativesdk ?= ""

OPENRC_SERVICES ?= "${PN}"
OPENRC_AUTO_ENABLE ??= "disable"
OPENRC_RUNLEVEL ??= "default"

RDEPENDS:${PN}:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'openrc', '', d)}"

python __anonymous() {
    # Return early if openrc is not in DISTRO_FEATURES
    if not bb.utils.contains('DISTRO_FEATURES', 'openrc', True, False, d):
        return

    # Inhibit update-rc.d from doing anything as the contents of /etc/init.d
    # will be managed by openrc
    d.setVar("INHIBIT_UPDATERCD_BBCLASS", "1")

    # Add vardeps for per-service runlevels
    openrc_packages = d.getVar('OPENRC_PACKAGES')
    for pkg in openrc_packages.split():
        d.appendVarFlag('openrc_populate_packages', 'vardeps', f' OPENRC_SERVICES:{pkg}')
        d.appendVarFlag('openrc_populate_packages', 'vardeps', f' OPENRC_AUTO_ENABLE:{pkg}')
        services = d.getVar(f'OPENRC_SERVICES:{pkg}') or d.getVar('OPENRC_SERVICES') or pkg
        for service in services.split():
            d.appendVarFlag('openrc_populate_packages', 'vardeps', f' OPENRC_RUNLEVEL:{service}')
}

openrc_postinst() {
    if [ "${OPENRC_AUTO_ENABLE}" = "enable" ]; then
        for service_escaped in ${OPENRC_SERVICES_ESCAPED}; do
            # Get unescaped service name and runlevel for this specific
            # service using escaped name
            eval "script=\$OPENRC_SCRIPT_${service_escaped}"
            eval "runlevel=\$OPENRC_RUNLEVEL_${service_escaped}"

            if [ ! -d "$D${sysconfdir}/runlevels/${runlevel}" ]; then
                mkdir -p "$D${sysconfdir}/runlevels/${runlevel}"
            fi

            ln -sf ${OPENRC_INITDIR}/${script} $D${sysconfdir}/runlevels/${runlevel}/
        done
    fi

    if [ -z "$D" ]; then
        for script in ${OPENRC_SERVICES}; do
            rc-service --ifstarted ${script} restart
        done
    fi
}

openrc_prerm() {
    if [ -z "$D" ]; then
        for service_escaped in ${OPENRC_SERVICES_ESCAPED}; do
            # Get unescaped service name and runlevel for this specific
            # service using escaped name
            eval "script=\$OPENRC_SCRIPT_${service_escaped}"
            eval "runlevel=\$OPENRC_RUNLEVEL_${service_escaped}"

            # User may have already disabled this
            rc-update del ${script} ${runlevel} || :
        done

        for script in ${OPENRC_SERVICES}; do
            rc-service --ifexists --ifstarted ${script} stop
        done
    fi
}

openrc_populate_packages[vardeps] += " \
    OPENRC_PACKAGES \
    OPENRC_SERVICES \
    OPENRC_AUTO_ENABLE \
    OPENRC_RUNLEVEL \
    openrc_prerm openrc_postinst \
"
openrc_populate_packages[vardepsexclude] += "OVERRIDES"

python openrc_populate_packages() {
    import pathlib

    def get_package_var(d, var, pkg):
        if val := (d.getVar(f"{var}:{pkg}") or "").strip():
            return val
        return (d.getVar(f"{var}") or "").strip()

    def get_openrc_services(pkg):
        localdata = d.createCopy()
        localdata.prependVar("OVERRIDES", f"{pkg}:")

        services = localdata.getVar(f"OPENRC_SERVICES:{pkg}")
        if services is None:
            if pkg == localdata.getVar("BPN"):
                services = localdata.getVar("OPENRC_SERVICES")

            if services is None:
                services = pkg

        return services.split()

    def check_and_update_installed_files(pkg, services):
        destdir = d.getVar("D")
        initdir = pathlib.Path(d.getVar("D")) / d.getVar("OPENRC_INITDIR").lstrip('/')
        confdir = pathlib.Path(d.getVar("D")) / d.getVar("OPENRC_CONFDIR").lstrip('/')
        for service in services:
            initd_path = initdir / service
            if not initd_path.exists():
                bb.fatal(f"Missing initd script '{service}', specified in OPENRC_SERVICES:{pkg}")

            d.appendVar(f"FILES:{pkg}", f" {initd_path.relative_to(destdir)}")

            confd_path = confdir / service
            if confd_path.exists():
                d.appendVar(f"FILES:{pkg}", f" {confd_path.relative_to(destdir)}")

    def generate_package_scripts(pkg, services):
        bb.debug(1, f"adding openrc calls to postinst/prerm for {pkg}")

        localdata = d.createCopy()
        localdata.prependVar("OVERRIDES", f"{pkg}:")
        localdata.setVar(f"OPENRC_SERVICES:{pkg}", " ".join(services))

        # Prepare per-service runlevel variables and escaped service names for shell scripts
        script_vars = ""
        runlevel_vars = ""
        services_escaped = ""

        for service in services:
            runlevel = d.getVar(f"OPENRC_RUNLEVEL:{service}")
            # if runlevel is not specified for a particular service, use the default
            if runlevel is None:
                runlevel = localdata.getVar("OPENRC_RUNLEVEL") or "default"

            # Create escaped version of service name for shell variables
            service_escaped = service.replace('-', '_')
            if services_escaped:
                services_escaped += " "
            services_escaped += service_escaped

            if script_vars:
                script_vars += "; "
            script_vars += f"OPENRC_SCRIPT_{service_escaped}={service}"

            if runlevel_vars:
                runlevel_vars += "; "
            runlevel_vars += f"OPENRC_RUNLEVEL_{service_escaped}={runlevel}"

        localdata.setVar("OPENRC_SERVICES_ESCAPED", services_escaped)

        for func in ("postinst", "prerm"):
            imp = d.getVar(f"pkg_{func}:{pkg}")
            if not imp:
                imp = "#!/bin/sh\n"

            # Add the script name (unescaped service name) to the script
            if script_vars:
                imp += f"{script_vars}\n"

            # Add the runlevel variables to the script
            if runlevel_vars:
                imp += f"{runlevel_vars}\n"

            imp += localdata.getVar(f"openrc_{func}")
            d.setVar(f"pkg_{func}:{pkg}", imp)

        mlprefix = d.getVar('MLPREFIX') or ""
        d.appendVar(f"RDEPENDS:{pkg}", f" {mlprefix}openrc")


    if not bb.utils.contains('DISTRO_FEATURES', 'openrc', True, False, d):
        return

    # - ensure each entry in OPENRC_PACKAGES is in PACKAGES
    # - add pkg_postinst/pkg_prerm
    # - ensure init script is installed
    # - update FILES:[package] with initd (and confd if it exists)
    recipe_packages = d.getVar("PACKAGES").split()
    for pkg in d.getVar("OPENRC_PACKAGES").split():
        if pkg not in recipe_packages:
            bb.error(f"{pkg} does not appear in the package list, please add it")

        auto_enable = get_package_var(d, "OPENRC_AUTO_ENABLE", pkg)
        if auto_enable not in ("enable", "disable"):
            bb.fatal(f"OPENRC_AUTO_ENABLE for {pkg} must be 'enable' or 'disable', got '{auto_enable}'")

        services = get_openrc_services(pkg)
        check_and_update_installed_files(pkg, services)
        generate_package_scripts(pkg, services)
}

PACKAGESPLITFUNCS:prepend = "openrc_populate_packages "

python clean_initd() {
    import pathlib
    import shutil

    if not bb.utils.contains('DISTRO_FEATURES', 'openrc', True, False, d):
        return

    openrc_initdir = pathlib.Path(d.getVar("D")) / d.getVar("OPENRC_INITDIR").lstrip('/')
    if not openrc_initdir.is_dir():
        return

    req_shebang = "#!%s/openrc-run" % (d.getVar("base_sbindir"),)
    for path in openrc_initdir.iterdir():
        if path.name == "functions.sh":
            continue

        with path.open() as fp:
            shebang = fp.readline().strip()

        if shebang != req_shebang:
            bb.debug(1, f"Removing {path} from openrc's initdir")
            path.unlink()
}

do_install[postfuncs] += "${CLEAN_INITD} "
CLEAN_INITD:class-target = " clean_initd "
CLEAN_INITD:class-nativesdk = " clean_initd "
CLEAN_INITD = ""

# Convenience wrapper for installing openrc init scripts that installs each
# path passed as an argument to openrc's init-dir.  Automatically strips
# '.initd' from the end of each path.
openrc_install_initd() {
    if ! ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'true', 'false', d)}; then
        return
    fi

    local svc
    local path

    [ ! -d ${D}${OPENRC_INITDIR} ] && install -d ${D}${OPENRC_INITDIR}

    for path in $*; do
        svc=$(basename ${path%\.initd})
        install -m 755 ${path} ${D}${OPENRC_INITDIR}/${svc}
        sed -i "1s,.*,#\!${base_sbindir}/openrc-run," ${D}${OPENRC_INITDIR}/${svc}
    done
}

# Convenience wrapper for installing openrc config files that installs each
# path passed as an argument to openrc's conf-dir.  Automatically strips
# '.confd' from the end of each path.
openrc_install_confd() {
    if ! ${@bb.utils.contains('DISTRO_FEATURES', 'openrc', 'true', 'false', d)}; then
        return
    fi

    local svc
    local path

    [ ! -d ${D}${OPENRC_CONFDIR} ] && install -d ${D}${OPENRC_CONFDIR}

    for path in $*; do
        svc=$(basename ${path%\.confd})
        install -m 644 ${path} ${D}${OPENRC_CONFDIR}/${svc}
    done
}
