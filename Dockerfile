FROM ubuntu:18.04

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y vim
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y tzdata
RUN apt-get install -y wget
RUN apt-get install -y cmake
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libdbus-glib-1-dev
RUN apt-get install -y build-essential
RUN apt-get install -y manpages-dev
RUN apt-get install -y gcc
RUN apt-get install -y g++
RUN apt-get install -y libboost-all-dev
RUN apt-get install -y binutils
RUN apt-get install -y cmake
RUN apt-get install -y curl
RUN apt-get install -y libtool
RUN apt-get install -y make
RUN apt-get install -y tar
RUN apt-get install -y git
RUN apt-get install -y asciidoc
RUN apt-get install -y source-highlight
RUN apt-get install -y doxygen
RUN apt-get install -y graphviz
RUN apt-get install -y libsystemd-dev
RUN apt-get install -y libssl-dev
RUN apt-get install -y openssh-server

WORKDIR /root

# install GENIVI/dlt-daemon
RUN git clone https://github.com/GENIVI/dlt-daemon.git
WORKDIR /root/dlt-daemon
RUN mkdir build
WORKDIR /root/dlt-daemon/build
RUN cmake ..
RUN make
RUN make install
RUN ldconfig

WORKDIR /root

# install GTEST
RUN wget https://github.com/google/googletest/archive/release-1.8.0.tar.gz
RUN tar xf release-1.8.0.tar.gz
WORKDIR /root/googletest-release-1.8.0
RUN cmake -DBUILD_SHARED_LIBS=ON .
RUN make
RUN make install

RUN cp -a googletest/include/gtest /usr/include
RUN cp -a googlemock/gtest/libgtest_main.so googlemock/gtest/libgtest.so /usr/lib/
RUN ldconfig -v | grep gtest

WORKDIR /root

# clone secure-vsomeip
RUN git clone https://github.com/netgroup-polito/secure-vsomeip.git
