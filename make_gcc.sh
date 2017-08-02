#!/usr/bin/env bash

GCC_INSTALL_DIR=/local/gcc
GCC_SUFFIX=6.3
GCC_VERSION=$GCC_SUFFIX.0
GMP_VERSION=6.1.0
MPFR_VERSION=3.1.4
MPC_VERSION=1.0.3
ISL_VERSION=0.16.1

WDIR=$GCC_SUFFIX
PREREQ_DIR=prereq


GMP=gmp-$GMP_VERSION
GMP_ARCHIVE=$GMP.tar.bz2
GMP_DOWNLOAD=$PREREQ_DIR/$GMP.tar.bz2

echo "GMP: $GMP  ARCHIVE: $GMP_ARCHIVE DOWNLOAD: $GMP_DOWNLOAD"

MPFR=mpfr-$MPFR_VERSION
MPFR_ARCHIVE=$MPFR.tar.bz2
MPFR_DOWNLOAD=$PREREQ_DIR/$MPFR.tar.bz2

echo "MPFR: $MPFR ARCHIVE: $MPFR_ARCHIVE DOWNLOAD: $MPFR_DOWNLOAD"

MPC=mpc-$MPC_VERSION
MPC_ARCHIVE=$MPC.tar.gz
MPC_DOWNLOAD=$PREREQ_DIR/$MPC.tar.gz

echo "MPC: $MPC ARCHIVE: $MPC_ARCHIVE DOWNLOAD: $MPC_DOWNLOAD"

ISL=isl-$ISL_VERSION
ISL_ARCHIVE=$ISL.tar.bz2
ISL_DOWNLOAD=$PREREQ_DIR/$ISL.tar.bz2

echo "ISL: $ISL ARCHIVE: $ISL_ARCHIVE DOWNLOAD: $ISL_DOWNLOAD"

GNUGCC=gcc-$GCC_VERSION
GNUGCC_ARCHIVE=$GNUGCC.tar.bz2
GNUGCC_DOWNLOAD=$WDIR/$GNUGCC.tar.bz2

echo "GCC: $GNUGCC ARCHIVE: $GNUGCC_ARCHIVE DOWNLOAD: $GNUGCC_ARCHIVE"

GNU_PREREQ_MIRROR=ftp://gcc.gnu.org/pub/gcc/infrastructure
GNU_GCC_MIRROR=ftp://gcc.gnu.org/pub/gcc/releases/$GNUGCC

CURL_GMP=$GNU_PREREQ_MIRROR/$GMP_ARCHIVE
CURL_MPFR=$GNU_PREREQ_MIRROR/$MPFR_ARCHIVE
CURL_MPC=$GNU_PREREQ_MIRROR/$MPC_ARCHIVE
CURL_ISL=$GNU_PREREQ_MIRROR/$ISL_ARCHIVE
CURL_GNUGCC=$GNU_GCC_MIRROR/$GNUGCC_ARCHIVE

echo $CURL_GMP
echo $CURL_MPFR
echo $CURL_MPC
echo $CURL_ISL
echo $CURL_GNUGCC

INSTALL_PREFIX=$HOME$GCC_INSTALL_DIR

echo $INSTALL_PREFIX


#
# clean up all old dirs
#
rm -rf $PREREQ_DIR/
rm -rf $WDIR/

#
# create the environment
#
mkdir $WDIR
mkdir $PREREQ_DIR

echo "curl $CURL_GMP -o $GMP_DOWNLOAD"
curl $CURL_GMP -o $GMP_DOWNLOAD
echo "curl $CURL_MPFR -o $MPFR_DOWNLOAD"
curl $CURL_MPFR -o $MPFR_DOWNLOAD
echo "curl $CURL_MPC  -o $MPC_DOWNLOAD"
curl $CURL_MPC  -o $MPC_DOWNLOAD
echo "curl $CURL_ISL -o $ISL_DOWNLOAD"
curl $CURL_ISL -o $ISL_DOWNLOAD
echo "curl $CURL_GNUGCC -o $GNUGCC_DOWNLOAD"
curl $CURL_GNUGCC -o $GNUGCC_DOWNLOAD


#
# unpack all the downloaded libraries
#
cd $PREREQ_DIR
tar -zxf $GMP_ARCHIVE
tar -zxf $MPFR_ARCHIVE
tar -zxf $MPC_ARCHIVE
tar -zxf $ISL_ARCHIVE
cd ../
cd $WDIR
tar -zxf $GNUGCC_ARCHIVE
cd ../
# check for error messages from stdin??

#
# GMP Library
#

cd $PREREQ_DIR/$GMP/
mkdir build && cd build
../configure --prefix=$INSTALL_PREFIX --enable-cxx > config_$GMP.log
make -j 4 > build_$GMP.log

cat build_$GMP.log | grep error

make check > test_$GMP.log
cat test_$GMP.log | grep error

make install > install_$GMP.log
cd ../../../

#
# MPRF library
#

cd $PREREQ_DIR/$MPFR/
mkdir build && cd build
../configure --prefix=$INSTALL_PREFIX --with-gmp=$INSTALL_PREFIX > config_$MPFR.log
make -j 4 > build_$MPFR.log
cat build_$MPFR.log | grep error

make check > test_$MPFR.log
cat test_$MPFR.log | grep error

make install > install_$MPFR.log
cd ../../../

#
# mpc library
#

cd $PREREQ_DIR/$MPC/
mkdir build && cd build
../configure --prefix=$INSTALL_PREFIX --with-gmp=$INSTALL_PREFIX --with-mpfr=$INSTALL_PREFIX --enable-valgrind-tests > config_$MPC.log
make -j 4 > build_$MPC.log
cat build_$MPC.log | grep error

make check > test_$MPC.log
cat test_$MPC.log | grep error

make install > install_$MPC.log
cd ../../../

#
# isl library
#

cd $PREREQ_DIR/$ISL
mkdir build && cd build
../configure --prefix=$INSTALL_PREFIX --with-gmp-prefix=$INSTALL_PREFIX > config_$ISL.log
make -j 4 > build_$ISL.log
cat build_$ISL.log | grep error

make check > test_$ISL.log

make install > install_$ISL.log
cd ../../../

#
# GCC
#

cd $WDIR/$GNUGCC
mkdir build && cd build
../configure --prefix=$INSTALL_PREFIX --enable-checking=release --with-gmp=$INSTALL_PREFIX --with-mpfr=$INSTALL_PREFIX --enable-language=default --with-isl=$INSTALL_PREFIX --program-suffix=-$GCC_SUFFIX > config_$GNUGCC.log
make -j 4 > build_$GNUGCC.log
cat build_$GNUGCC.log | grep error

make check-gcc RUNTESTFLAGS="execute.exp other-options" > test_$GNUGCC.log
cat test_$GNUGCC.log | grep error

make install > install_$GNUGCC.log
cd ../../../

echo "add $INSTALL_PREFIX to PATH"
