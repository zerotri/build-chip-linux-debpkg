FROM debian:jessie

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt upgrade -y
RUN apt update

RUN apt -y install wget

# standard build environment
RUN apt -y install build-essential

# device tree compiler
RUN apt -y install device-tree-compiler

# debian build tools
RUN apt -y install lzop
RUN apt -y install fakeroot
RUN apt -y install bc
RUN apt -y install libfakeroot
RUN apt -y install debhelper
RUN apt -y install dkms
RUN apt -y install devscripts
RUN apt -y install module-assistant
RUN apt -y install ncurses-dev
RUN apt -y install git
RUN apt -y install locales

RUN locale-gen en_US.UTF-8

# ARM cross compiler toolchain
RUN mkdir -p /opt/arm-toolchain/linaro
RUN wget \
	https://releases.linaro.org/14.11/components/toolchain/binaries/arm-linux-gnueabihf/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf.tar.xz \
	-O /opt/arm-toolchain/toolchain.tar.xz

RUN tar xf /opt/arm-toolchain/toolchain.tar.xz \
	--strip-components 1 \
	--directory /opt/arm-toolchain/linaro

# setup build directories
RUN mkdir -p /opt/build/
RUN git -C /opt/ \
	clone https://github.com/nextthingco/chip-linux.git \
	--branch=nextthing/4.4/next \
	--depth 1
WORKDIR /opt/build