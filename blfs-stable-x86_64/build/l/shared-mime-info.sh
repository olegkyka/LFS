#! /bin/bash

PRGNAME="shared-mime-info"

### shared-mime-info (MIME database)
# База данных MIME

# http://www.linuxfromscratch.org/blfs/view/stable/general/shared-mime-info.html

# Home page: https://freedesktop.org/wiki/Software/shared-mime-info/
# Download:  https://gitlab.freedesktop.org/xdg/shared-mime-info/uploads/b27eb88e4155d8fccb8bb3cd12025d5b/shared-mime-info-1.15.tar.xz

# Required: glib
#           itstool
#           libxml2
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (MIME database)
#
# This package contains:
# The freedesktop.org shared MIME database spec.
# The merged GNOME and KDE databases, in the new format.
# The update-mime-database command, used to install new MIME data.
#
# Home page: https://freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://gitlab.freedesktop.org/xdg/${PRGNAME}/uploads/b27eb88e4155d8fccb8bb3cd12025d5b/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
