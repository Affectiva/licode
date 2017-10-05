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
  # install epel which enables the repo that contains some of
  # the packages that we need
  sudo yum -y install epel-release
  # now that yum knows about epel it can install the rest of the packages
  sudo yum -y install patch git make gcc bzip2-devel x264-devel libav-devel libnice-devel libsrtp-devel libvpx-devel opus-devel cmake pkgconfig glib2-devel boost-devel boost-regex boost-thread boost-system log4cxx-devel rabbitmq-server curl boost-test tar xz libffi-devel yasm java-1.7.0-openjdk
}

install_node(){
    # we used to use epel packages but they upgraded to a version of
    # nodejs that's incompatible with licode so now we get it from the
    # upstream source
    wget http://nodejs.org/dist/v0.10.36/node-v0.10.36-linux-x64.tar.gz
    sudo tar --strip-components 1 -xzf node-v* -C /usr/local
    sudo npm install -g node-gyp@0.10.6 request@2.25.0
}

download_openssl() {
  OPENSSL_VERSION=$1
  OPENSSL_MAJOR="${OPENSSL_VERSION%?}"
  echo "Downloading OpenSSL from https://www.openssl.org/source/$OPENSSL_MAJOR/openssl-$OPENSSL_VERSION.tar.gz"
  curl -OL https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
  tar -zxvf openssl-$OPENSSL_VERSION.tar.gz || DOWNLOAD_SUCCESS=$?
  if [ "$DOWNLOAD_SUCCESS" -eq 1 ]
  then
    echo "Downloading OpenSSL from https://www.openssl.org/source/old/$OPENSSL_MAJOR/openssl-$OPENSSL_VERSION.tar.gz"
    curl -OL https://www.openssl.org/source/old/$OPENSSL_MAJOR/openssl-$OPENSSL_VERSION.tar.gz
    tar -zxvf openssl-$OPENSSL_VERSION.tar.gz
  fi
}

install_openssl(){
  if [ -d $LIB_DIR ]; then
    cd $LIB_DIR
    OPENSSL_VERSION=`node -pe process.versions.openssl`
    if [ ! -f ./openssl-$OPENSSL_VERSION.tar.gz ]; then
      download_openssl $OPENSSL_VERSION
      cd openssl-$OPENSSL_VERSION
      ./config --prefix=$PREFIX_DIR --openssldir=$PREFIX_DIR -fPIC
      make $FAST_MAKE -s V=0
      make install_sw
    else
      echo "openssl already installed"
    fi
    cd $CURRENT_DIR
  else
    mkdir -p $LIB_DIR
    install_openssl
  fi
}

parse_arguments $*

mkdir -p $PREFIX_DIR

install_apt_deps
install_node
install_openssl

check_proxy
