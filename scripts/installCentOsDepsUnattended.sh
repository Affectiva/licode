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
  sudo yum -y install patch git make gcc bzip2-devel libav-devel libnice-devel libsrtp-devel libvpx-devel opus-devel openssl-devel cmake pkgconfig nodejs glib2-devel boost-devel boost-regex boost-thread boost-system log4cxx-devel rabbitmq-server curl boost-test tar xz libffi-devel npm yasm java-1.7.0-openjdk
}

parse_arguments $*

mkdir -p $PREFIX_DIR

install_apt_deps

check_proxy
