#! /bin/bash

PRGNAME="libassuan"

### libassuan (Interprocess Communication Library for GPG)
# Небольшая библиотека, реализующая так называемый протокол Assuan. Этот
# протокол используется для IPC между большинством компонентов GnuPG.
# Представлена как серверная, так и клиентская часть.

# http://www.linuxfromscratch.org/blfs/view/stable/general/libassuan.html

# Home page: https://gnupg.org/software/libassuan/index.html
# Download:  https://www.gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.3.tar.bz2

# Required: libgpg-error
# Optional: texlive или install-tl-unx (для создания pdf и ps документации)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}/html"

./configure \
    --prefix=/usr || exit 1

make || exit 1

# собираем документацию в формате html и plaintext
make -C doc html
makeinfo --html --no-split -o doc/assuan_nochunks.html doc/assuan.texi
makeinfo --plaintext       -o doc/assuan.txt           doc/assuan.texi

# если в системе установлен texlive или install-tl-unx, можно создать
# документацию в форматах pdf и ps
PDF_PS_DOC=""
command -v texdoc &>/dev/null && PDF_PS_DOC="true"
[ -n "${PDF_PS_DOC}" ] && make -C doc pdf ps

# make check
make install
make install DESTDIR="${TMP_DIR}"

install -v -dm755 "${DOCS}/html"
install -v -m644  doc/assuan.html/* "${DOCS}/html"
install -v -m644  doc/assuan.html/* "${TMP_DIR}${DOCS}/html"

install -v -m644 doc/assuan_nochunks.html "${DOCS}"
install -v -m644 doc/assuan_nochunks.html "${TMP_DIR}${DOCS}"

install -v -m644 doc/assuan.{txt,texi} "${DOCS}"
install -v -m644 doc/assuan.{txt,texi} "${TMP_DIR}${DOCS}"

# если мы собирали документацию в pdf и ps форматах
if [ -n "${PDF_PS_DOC}" ]; then
    install -v -m644  doc/assuan.{pdf,ps,dvi} "${DOCS}"
    install -v -m644  doc/assuan.{pdf,ps,dvi} "${TMP_DIR}${DOCS}"
fi

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Interprocess Communication Library for GPG)
#
# This is a small library implementing the so-called Assuan protocol. This
# protocol is used for IPC between most newer GnuPG components. Both, server
# and client side functions are provided.
#
# Home page: https://gnupg.org/software/${PRGNAME}/index.html
# Download:  https://www.gnupg.org/ftp/gcrypt/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
