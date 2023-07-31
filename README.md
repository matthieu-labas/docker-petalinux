# Generic Petalinux Dockerfile

A somehow generic Xilinx PetaLinux 2020+ docker file, using Ubuntu (though some tweaks might be possible for Windows).

It was successfully tested with version `2022.2`.

>Inspired by [docker-xilinx-petalinux-desktop](https://github.com/JamesAnthonyLow/docker-xilinx-petalinux-desktop) (and some of [petalinux-docker](https://github.com/xaljer/petalinux-docker)).

## Petalinux installer

Download PetaLinux installer from [Xilinx/AMD website](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools.html).

> N.B. Petalinux 2022.2 installer is named `petalinux-v2022.2-10141622-installer.run` so you want to either rename it to `petalinux-v2022.2-final-installer.run` or create a link.

## Build the image

Building the image requires a local HTTP server to serve big resources instead of pushing them to the Docker daemon so make sure the firewall is configured appropriately to allow incoming connections on docker network link tcp:172.17.0.1:8000, e.g.:

    sudo ufw allow from 172.17.0.0/16 to 172.17.0.1

Run:

    ./docker_build.sh <VERSION>

> `<VERSION>` can be `2022.2`, ...
> Corresponding petalinux and SDK files are expected to be found in `resources` directory.

The `docker_build.sh` will automatically spawn a simple HTTP server to serve the installers instead of copying them to the docker images (especially pushing them to the Docker daemon. Big space/time saver).

The image takes a some time to build, but should succeed.

It weighs around 12 GB.

### Parameters

Several arguments can be provided to customize the build, with `--build-arg`:

* `XILVER` for the Xilinx version to install. The `Dockerfile` expects to find `${HTTP_SERVER}/petalinux-v${XILVER}-final-installer.run` for the PetaLinux installer (unless `PETALINUX_INSTALLER` is given).
<br/>Defaults to `2022.2`.

* `PETALINUX_BASE` is the name of the PetaLinux base. Petalinux will be installed in `/opt/${PETALINUX_BASE}` and the installer is expected to be sourced from `resources/${PETALINUX_BASE}-installer.run`.
<br/>Defaults to `petalinux-v${XILVER}-final`.

* `PETALINUX_INSTALLER` is the PetaLinux installer file.
<br/>Defaults to `${PETALINUX_BASE}-installer.run`

* `HTTP_SERV` is the HTTP server serving both SDK and PetaLinux installer.
<br/>Defaults to `http://172.17.0.1:8000/resources`.

You can fully customize the installation by manually running e.g.:

    docker build . -t petalinux:2022.2 \
        --build-arg XILVER=2022.2 \
        --build-arg PETALINUX_INSTALLER=petalinux/petalinux-v2022.2-10141622-installer.run \
        --build-arg HTTP_SERV=https://local.company.com/dockers/petalinux/2022.2/resources

Petalinux at `https://local.company.com/dockers/petalinux/2022.2/resources/petalinux/petalinux-v2022.2-10141622-patched.run`

## Work with a PetaLinux project

A helper script `petalin.sh` is provided that should be run *inside* a petalinux project directory. It basically is a shortcut to:

    docker run -ti -v "$PWD":"$PWD" -w "$PWD" --rm -u petalinux petalinux:<latest version> $@

When run without arguments, a shell will spawn, *with PetaLinux and SDK `settings.sh` already sourced*, so you can directly execute `petalinux-*` commands.

    user@host:/path/to/petalinux_project$ /path/to/petalin.sh
    petalinux@a3ce6f8c:/path/to/petalinux_project$ petalinux-create -t project --template zynq -n <project name>
    petalinux@a3ce6f8c:/path/to/petalinux_project$ petalinux-config --get-hw-description <...>
    petalinux@a3ce6f8c:/path/to/petalinux_project$ petalinux-build

Otherwise, the arguments will be executed as a command.

> N.B. the SDK and PetaLinux `settings.sh` will not be sourced when running commands:

    user@host:/path/to/petalinux_project$ /path/to/petalin.sh petalinux-build

will fail because `petalinux-build` is not part of the path. But you can create your own script and start it instead:

    # mbuild.sh
    . /opt/petalinux-v2018.2-final/settings.sh
    petalinux-build

then:

    user@host:/path/to/petalinux_project$ /path/to/petalin.sh ./mbuild.sh
