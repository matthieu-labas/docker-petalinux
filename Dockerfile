FROM ubuntu:16.04

# The Xilinx toolchain version
ARG XILVER=2018.2

# The SDK installer *GENERATED FROM THE WebInstall WITH OPTION "Extract to directory" (and zip)*
# SDK will be installed in /opt/Xilinx/SDK/${XILVER}
# File is expected in the "resources" subdirectory
ARG SDK_FILE=Xilinx-SDK-v${XILVER}.tgz
# The PetaLinux base. We expect ${PETALINUX_BASE}-installer.run to be the patched installer.
# PetaLinux will be installed in /opt/${PETALINX_BASE}
# File is expected in the "resources" subdirectory
ARG PETALINUX_BASE=petalinux-v${XILVER}-final
# The HTTP server to retrieve the files from. It should be accessible by the Docker daemon
ARG host_ip=172.17.0.1

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install -y \ 
	python3.4 \
	tofrodos \
	iproute2 \
	gawk \
	xvfb \
	gcc-4.8 \
	git \
	make \
	net-tools \
	libncurses5-dev \
	tftpd \
	tftp-hpa \
	zlib1g-dev:i386 \
	libssl-dev \
	flex \
	bison \
	libselinux1 \
	gnupg \
	wget \
	diffstat \
	chrpath \
	socat \
	xterm \
	autoconf \
	libtool \
	tar \
	unzip \
	texinfo \
	zlib1g-dev \
	gcc-multilib \
	build-essential \
	libsdl1.2-dev \
	libglib2.0-dev \
	screen \
	expect \
	locales \
	cpio \
	sudo \
	software-properties-common \
	pax \
	gzip \
	vim \
	libgtk2.0-0

RUN echo "%sudo ALL=(ALL:ALL) ALL" >> /etc/sudoers \
	&& echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
	&& ln -fs /bin/bash /bin/sh

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

# Add user 'petalinux' with password 'petalinux' and give it access to install directory /opt
RUN useradd -m -G dialout -p '$6$wiu9XEXx$ITRrMySAw1SXesQcP.Bm3Su2CuaByujc6Pb7Ztf4M9ES2ES7laSRwdcbgG96if4slduUxyjqvpEq2I0OhxKCa1' petalinux \
	&& chmod +w /opt \
	&& chown -R petalinux:petalinux /opt \
	&& mkdir /opt/${PETALINUX_BASE} \
	&& chmod 755 /opt/${PETALINUX_BASE} \
	&& chown petalinux:petalinux /opt/${PETALINUX_BASE}

# Install under /opt, with user petalinux
WORKDIR /opt
USER petalinux

# Install SDK
#COPY resources/install_config_sdk.txt .
RUN mkdir t && cd t && wget -q ${host_ip}:8000/resources/install_config_sdk.txt \
	&& wget -q -O - ${host_ip}:8000/resources/${SDK_FILE} | tar -xz \
	&& ./xsetup -b Install -a XilinxEULA,3rdPartyEULA,WebTalkTerms -c install_config_sdk.txt \
	&& cd .. && rm -rf t \
	&& echo "source /opt/Xilinx/SDK/${XILVER}/settings64.sh" >> ~/.bashrc \
	&& echo "source /opt/${PETALINUX_BASE}/settings.sh" >> ~/.bashrc

# Install PetaLinux
RUN chown -R petalinux:petalinux . \
	&& wget -q ${host_ip}:8000/resources/${PETALINUX_BASE}-installer.run \
	&& chmod a+x ${PETALINUX_BASE}-installer.run \
	&& ./${PETALINUX_FILE}${PETALINUX_BASE}-installer.run /opt/${PETALINUX_BASE} \
	&& rm -f ./${PETALINUX_BASE}-installer.run \
	&& rm -f petalinux_installation_log

# Source settings at login
USER root
RUN echo "source /opt/Xilinx/SDK/${XILVER}/settings64.sh" >> /etc/profile \
	&& echo "source /opt/${PETALINUX_BASE}/settings.sh" >> /etc/profile
