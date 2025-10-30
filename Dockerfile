FROM ubuntu:24.04

RUN apt update
RUN apt install -y usbutils nano wget make cmake git stlink-tools openocd astyle cppcheck g++ gdb ninja-build
RUN apt install -y bzip2 xz-utils

#GCC-ARM
RUN wget https://developer.arm.com/-/media/Files/downloads/gnu/14.3.rel1/binrel/arm-gnu-toolchain-14.3.rel1-x86_64-arm-none-eabi.tar.xz -O gcc-arm-none-eabi.tar.xz
RUN mkdir opt/gcc-arm-none-eabi && tar xf gcc-arm-none-eabi.tar.xz -C opt/gcc-arm-none-eabi --strip-components 1
RUN rm gcc-arm-none-eabi.tar.xz
ENV PATH="/opt/gcc-arm-none-eabi/bin:${PATH}"
