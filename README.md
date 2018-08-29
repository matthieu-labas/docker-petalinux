# Petalinux Dockerfile

A somehow generic Xilinx PetaLinux+SDK docker file, using Ubuntu (though some tweaks might be possible for Windows).

> **Caution**: some modifications are to be performed on Xilinx files to make it compliant with unattended installation!* Xilinx is supposed to provide better options starting from `2018.3`.
Inspired by [docker-xilinx-petalinux-desktop](https://github.com/JamesAnthonyLow/docker-xilinx-petalinux-desktop) (and some of [petalinux-docker](https://github.com/xaljer/petalinux-docker)).

# Prepare installers

SDK and PetaLinux installers are to be downloaded from [Xilinx website](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools.html). They need to be prepared for unattended installation.

## SDK

You need to get the unattended-install-compliant SDK archive, linked to your Xilinx account:
1. Download the SDK installer `Xilinx_SDK_XXXX.X_YYYY_ZZZZ_Lin64.bin` (e.g. `Xilinx_SDK_2018.2_0614_1954_Lin64.bin`)
2. Run it
3. Click `Next >` to go to `Select install type` page
4. Enter your Xilinx user ID and password
5. Select `Download Full Image (Install Separately)`
6. Select `resources/SDK` directory for the download location
7. Select `Linux` for the `Download files to create full image for selected platform(s)`. **Do not select `Zip archive`!** It will mess up file attributes and the installer will fail.
8. Click `Next >`
9. Click `Download`
10. Go the `SDK` directory and type: `tar -czf ../Xilinx-SDK-vXXXX.X.tgz *`
11. Remove the `SDK` directory

You can modify the `install_config_sdk.txt` to fine-tune the options, but the default is fine.

## PetaLinux

We need to patch the petalinux installer so it does not ask to accept licences.

> N.B. I'm not sure it's completely legal; but I haven't been able to script an `expect` to automatically accept them (which might not be legal as well anyway). So we'll consider your download means you accept those licences (which are available in the petalinux install directory)*

In `resources`, run:

    ./patch_petalinux_installer.sh /path/to/petalinux-vXXX.X-final-installer.run

(that will extract the script header to `/tmp/plsh` and archive to `/tmp/plbin` then merge them back together to `resources/petalinux-vXXX.X-final-installer.run`).


# Build the image

Run:

    ./build.sh <VERSION>

or:

    python -m SimpleHTTPServer &
    docker build . -t petalinux:<VERSION> --build-arg XILVER=<VERSION>

The `build.sh` will automatically spawn a simple HTTP server to server the installers instead of copying them to the docker images (big space saver).

The image should take a long time to build (up to a couple hours, depending on disk space and system use), but should succeed.


# Compile a PetaLinux project

A helper script `petalin` is provided that should be run *inside* a petalinux project:

    docker run -ti -v "$PWD":"$PWD" -u petalinux -w "$PWD" petalinux $@

When run without arguments, a shell will spawn, *with PetaLinux and SDK `settings.sh` sourced*, so you can directly execute `petalinux-*` commands. Otherwise, the arguments will be executed as a command. E.g:

    ./petalin petalinux-build
