#!/bin/bash

set -e

SCRIPT=`pwd`/$0
FILENAME=`basename $SCRIPT`
PATHNAME=`dirname $SCRIPT`
ROOT=$PATHNAME/..
BUILD_DIR=$ROOT/build
CURRENT_DIR=`pwd`

LIB_DIR=$BUILD_DIR/libdeps
PREFIX_DIR=$LIB_DIR/build/

parse_arguments(){
  while [ "$1" != "" ]; do
    case $1 in
      "--enable-gpl")
        ENABLE_GPL=true
        ;;
      "--cleanup")
        CLEANUP=true
        ;;
    esac
    shift
  done
}

check_proxy(){
  if [ -z "$http_proxy" ]; then
    echo "No http proxy set, doing nothing"
  else
    echo "http proxy configured, configuring npm"
    npm config set proxy $http_proxy
  fi  

  if [ -z "$https_proxy" ]; then
    echo "No https proxy set, doing nothing"
  else
    echo "https proxy configured, configuring npm"
    npm config set https-proxy $https_proxy
  fi  
}

install_apt_deps(){
  # install x264 from atrpms
  sudo yum -y --enablerepo=atrpms* install x264-devel
  # install epel which enables the repo that contains some of
  # the packages that we need
  sudo yum -y install epel-release
  # now that yum knows about epel it can install the rest of the packages
  sudo yum -y install patch git make gcc libvpx-devel opus-devel openssl-devel cmake pkgconfig nodejs glib2-devel boost-devel boost-regex boost-thread boost-system log4cxx-devel rabbitmq-server curl boost-test tar xz libffi-devel npm yasm java-1.7.0-openjdk
}

install_libnice(){
  if [ -d $LIB_DIR ]; then
    cd $LIB_DIR
    curl -O http://nice.freedesktop.org/releases/libnice-0.1.4.tar.gz
    tar -xf libnice-0.1.4.tar.gz
    cd libnice-0.1.4
    patch -R ./agent/conncheck.c < $PATHNAME/libnice-014.patch0
    PKG_CONFIG_PATH=${PREFIX_DIR}/lib/pkgconfig ./configure --prefix=$PREFIX_DIR 
    make -s V=0
    make install
    cd $CURRENT_DIR
  else
    mkdir -p $LIB_DIR
    install_libnice
  fi
}

install_mediadeps(){
  cd $LIB_DIR
  curl -O https://www.libav.org/releases/libav-11.1.tar.gz
  tar -xf libav-11.1.tar.gz
  cd libav-11.1
  PKG_CONFIG_PATH=${PREFIX_DIR}/lib/pkgconfig CPATH=${PREFIX_DIR}/include ./configure --prefix=$PREFIX_DIR --enable-shared --enable-gpl --enable-libvpx --enable-libx264 --enable-libopus
  make -s V=0
  make install
}

install_mediadeps_nogpl(){
  if [ -d $LIB_DIR ]; then
    cd $LIB_DIR
    curl -O https://www.libav.org/releases/libav-11.1.tar.gz
    tar -xf libav-11.1.tar.gz
    cd libav-11.1
    PKG_CONFIG_PATH=${PREFIX_DIR}/lib/pkgconfig CPATH=${PREFIX_DIR}/include ./configure --prefix=$PREFIX_DIR --enable-shared --enable-libopus --enable-libvpx
    CPATH=${PREFIX_DIR}/include make -s V=0
    make install
    cd $CURRENT_DIR
  else
    mkdir -p $LIB_DIR
    install_mediadeps_nogpl
  fi
}

install_libsrtp(){
  cd $ROOT/third_party/srtp
  CFLAGS="-fPIC" ./configure --prefix=$PREFIX_DIR
  make -s V=0
  make uninstall
  make install
  cd $CURRENT_DIR
}

cleanup(){  
  if [ -d $LIB_DIR ]; then
    cd $LIB_DIR
    rm -r libnice*
    rm -r libav*
    cd $CURRENT_DIR
  fi
}

parse_arguments $*

mkdir -p $PREFIX_DIR

install_apt_deps

check_proxy

install_libnice

install_libsrtp

if [ "$ENABLE_GPL" = "true" ]; then
  install_mediadeps
else
  install_mediadeps_nogpl
fi

if [ "$CLEANUP" = "true" ]; then
  echo "Cleaning up..."
  cleanup
fi
