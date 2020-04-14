#!/bin/sh
set -o nounset
set -o errexit

TARGET=arm-none-eabi
WORKSPACE=`cd "$(dirname "$0")" && pwd`
PREFIX=${WORKSPACE}/arm-none-eabi-9.3.0

BINUTILS=binutils-2.34
GCC=gcc-9.3.0
GMP=gmp-6.2.0
MPC=mpc-1.1.0
MPFR=mpfr-4.0.2
GDB=gdb-9.1

if [ ! -e ${BINUTILS}.tar.xz ]; then
    echo "Download ${BINUTILS}.tar.xz"
    wget ftp://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.xz
fi
if [ ! -e ${GCC}.tar.xz ]; then
    echo "Download ${GCC}.tar.xz"
    wget ftp://ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.xz
fi
if [ ! -e ${GMP}.tar.xz ]; then
    echo "Download ${GMP}.tar.xz"
    wget ftp://ftp.gnu.org/gnu/gmp/${GMP}.tar.xz
fi
if [ ! -e ${MPC}.tar.gz ]; then
    echo "Download ${MPC}.tar.gz"
    wget ftp://ftp.gnu.org/gnu/mpc/${MPC}.tar.gz
fi
if [ ! -e ${MPFR}.tar.xz ]; then
    echo "Download ${MPFR}.tar.xz"
    wget ftp://ftp.gnu.org/gnu/mpfr/${MPFR}.tar.xz
fi
if [ ! -e ${GDB}.tar.xz ]; then
    echo "Download ${GDB}.tar.xz"
    wget ftp://ftp.gnu.org/gnu/gdb/${GDB}.tar.xz
fi

echo -n "Extracting Binutils... "
tar -Jxf ${BINUTILS}.tar.xz
echo "Done"
echo -n "Extracting GCC... "
tar -Jxf ${GCC}.tar.xz
echo "Done"
echo -n "Extracting GMP... "
tar -Jxf ${GMP}.tar.xz
echo "Done"
echo -n "Extracting MPC... "
tar -xzf ${MPC}.tar.gz
echo "Done"
echo -n "Extracting MPFR... "
tar -Jxf ${MPFR}.tar.xz
echo "Done"
echo -n "Extracting GDB... "
tar -Jxf ${GDB}.tar.xz
echo "Done"

# Build Binutils
mkdir ${WORKSPACE}/binutils-build
cd ${WORKSPACE}/binutils-build
${WORKSPACE}/${BINUTILS}/configure --target=${TARGET} --prefix=${PREFIX} --disable-nls --enable-interwork --enable-multilib --disable-werror
make all install

export PATH=$PATH:${PREFIX}:${PREFIX}/bin

# Build GCC
mv -v ${WORKSPACE}/${GMP} ${WORKSPACE}/${GCC}/gmp
mv -v ${WORKSPACE}/${MPC} ${WORKSPACE}/${GCC}/mpc
mv -v ${WORKSPACE}/${MPFR} ${WORKSPACE}/${GCC}/mpfr
mkdir ${WORKSPACE}/gcc-build
cd ${WORKSPACE}/gcc-build
${WORKSPACE}/${GCC}/configure --target=${TARGET} --prefix=${PREFIX} --with-newlib --with-gnu-as --with-gnu-ld --disable-nls --disable-libssp --disable-gomp --disable-libstcxx-pch --enable-threads --disable-shared --disable-libmudflap --enable-interwork --enable-languages=c
make all install

# Build GDB
mkdir ${WORKSPACE}/gdb-build
cd ${WORKSPACE}/gdb-build
../${GDB}/configure --target=${TARGET} --prefix=${PREFIX} --disable-interwork --enable-multilib --disable-werror
make all install

echo ""
echo "Cross GCC for ${TARGET} installed to ${PREFIX}"
echo ""
