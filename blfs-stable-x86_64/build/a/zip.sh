#! /bin/bash

PRGNAME="zip"
ARCH_NAME="${PRGNAME}30"
VERSION="3.0"

### Zip (compressing files into ZIP archives)
# Утилиты для сжатия файлов в ZIP архивы

# http://www.linuxfromscratch.org/blfs/view/stable/general/zip.html

# Home page: https://sourceforge.net/projects/infozip/
# Download:  https://downloads.sourceforge.net/infozip/zip30.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="/root/src"
BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}".tar.?z* || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"
cd "${ARCH_NAME}" || exit 1

make -f unix/Makefile generic_gcc
# пакет не содержит набора тестов
make prefix=/usr MANDIR=/usr/share/man/man1 -f unix/Makefile install
make prefix="${TMP_DIR}/usr" MANDIR="${TMP_DIR}/usr/share/man/man1" \
    -f unix/Makefile install

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (compressing files into ZIP archives)
#
# The Zip package contains Zip utilities. These are useful for compressing
# files into ZIP archives.
#
# Home page: https://sourceforge.net/projects/infozip/
# Download:  https://downloads.sourceforge.net/infozip/${ARCH_NAME}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
