#!/bin/bash

set -eux

PGROONGA_VERSION=$1
GROONGA_VERSION=$2

MECAB_VERSION=0.996

mkdir build
pushd build

wget https://packages.groonga.org/source/groonga/groonga-${GROONGA_VERSION}.tar.gz
tar xf groonga-${GROONGA_VERSION}.tar.gz
pushd groonga-${GROONGA_VERSION}

pushd vendor
ruby download_mecab.rb
popd

mkdir -p /target

cmake \
  -G"Unix Makefiles" \
  -S . \
  -B ../groonga.build \
  -DCMAKE_C_FLAGS="$CFLAGS" \
  -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
  --preset=release-maximum \
  -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build ../groonga.build -j
(cd ../groonga.build && make install && make install DESTDIR=/target)
popd

wget https://packages.groonga.org/source/pgroonga/pgroonga-${PGROONGA_VERSION}.tar.gz
tar xf pgroonga-${PGROONGA_VERSION}.tar.gz
pushd pgroonga-${PGROONGA_VERSION}
make PGRN_DEBUG=R{PGRN_DEBUG} HAVE_MSGPACK=1 MSGPACK_PACKAGE_NAME=msgpack-c -j$(nproc)
make install && make install DESTDIR=/target
popd

popd
rm -rf build
