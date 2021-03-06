#! /bin/bash

PRGNAME="file"

### File (a utility to determine file type)
# Утилита для определения типа файла

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/file.html

# Home page: https://www.darwinsys.com/file/
# Download:  ftp://ftp.astron.com/pub/file/file-5.38.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a utility to determine file type)
#
# This is utility, used to identify files.
#
# Home page: https://www.darwinsys.com/file/
# Download:  ftp://ftp.astron.com/pub/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
