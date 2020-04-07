#! /bin/bash

PRGNAME="grep"

### Grep
# Программы для поиска по файлам

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/grep.html

# Home page: http://www.gnu.org/software/grep/
# Download:  http://ftp.gnu.org/gnu/grep/grep-3.3.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure       \
    --prefix=/usr \
    --bindir=/bin || exit 1

make || exit 1
make -k check
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (print lines matching a pattern)
#
# This is GNU grep, the "fastest grep in the west" (we hope). Grep searches
# through textual input for lines which contain a match to a specified pattern
# and then prints the matching lines.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"