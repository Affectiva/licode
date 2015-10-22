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
    esac
    shift
  done
}

install_openssl(){
  if [ -d $LIB_DIR ]; then
    cd $LIB_DIR
    curl -O http://www.openssl.org/source/openssl-1.0.1g.tar.gz
    tar -zxvf openssl-1.0.1g.tar.gz > /dev/null 2> /dev/null
    cd openssl-1.0.1g
    ./config --prefix=$PREFIX_DIR -fPIC
    make -s V=0
    make install
    cd $CURRENT_DIR
  else
    mkdir -p $LIB_DIR
    install_openssl
  fi
}

install_libnice(){
  if [ -d $LIB_DIR ]; then
    cd $LIB_DIR
    curl -O http://nice.freedesktop.org/releases/libnice-0.1.4.tar.gz
    tar -zxvf libnice-0.1.4.tar.gz > /dev/null 2> /dev/null
    cd libnice-0.1.4
    ./configure --prefix=$PREFIX_DIR
    make -s V=0
    make install
    cd $CURRENT_DIR
  else
    mkdir -p $LIB_DIR
    install_libnice
  fi
}

install_mediadeps(){
  if [ -d $LIB_DIR ]; then
    cd $LIB_DIR
    curl -O https://www.libav.org/releases/libav-11.1.tar.gz
    tar -zxvf libav-11.1.tar.gz > /dev/null 2> /dev/null
    cd libav-11.1
    ./configure --prefix=$PREFIX_DIR --enable-shared --enable-gpl --enable-libvpx --enable-libx264
    make -s V=0
    make install
    cd $CURRENT_DIR
  else
    mkdir -p $LIB_DIR
    install_mediadeps
  fi

}

install_mediadeps_nogpl(){
  if [ -d $LIB_DIR ]; then
    cd $LIB_DIR
    curl -O https://www.libav.org/releases/libav-11.1.tar.gz
    tar -zxvf libav-11.1.tar.gz > /dev/null 2> /dev/null
    cd libav-11.1
    ./configure --prefix=$PREFIX_DIR --enable-shared --enable-libvpx
    make -s V=0
    make install
    cd $CURRENT_DIR
  else
    mkdir -p $LIB_DIR
    install_mediadeps_nogpl
  fi
}

install_libsrtp(){
  curl -O -L https://github.com/cisco/libsrtp/archive/v1.5.2.tar.gz
  tar -zxvf v1.5.2.tar.gz > /dev/null 2> /dev/null
  cd libsrtp-1.5.2
  CFLAGS="-fPIC" ./configure --prefix=$PREFIX_DIR
  make -s V=0
  make install
  cd $CURRENT_DIR
}

parse_arguments $*

mkdir -p $PREFIX_DIR

echo "Installing openssl library..."
install_openssl

echo "Installing libnice library..."
install_libnice

echo "Installing libsrtp library..."
install_libsrtp

if [ "$ENABLE_GPL" = "true" ]; then
  echo "GPL libraries enabled"
  install_mediadeps
else
  echo "No GPL libraries enabled, this disables h264 transcoding, to enable gpl please use the --enable-gpl option"
  install_mediadeps_nogpl
fi
