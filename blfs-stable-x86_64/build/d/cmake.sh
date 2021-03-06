#! /bin/bash

PRGNAME="cmake"

### CMake (cross-platform, open-source make system)
# Современный набор инструментов, используемый для генерации Makefile

# http://www.linuxfromscratch.org/blfs/view/stable/general/cmake.html

# Home page: https://cmake.org/
# Download:  https://cmake.org/files/v3.16/cmake-3.16.4.tar.gz

# Required:    libuv
# Recommended: zlib
#              bzip2
#              expat
#              curl
#              libarchive
# Optional:    qt5        (для Qt-based GUI, см. опцию конфигурации ниже)
#              subversion (для тестов)
#              sphinx     (для сборки документации) https://pypi.org/project/Sphinx/

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# запрещаем приложениям, использующим cmake при сборке устанавливать файлы в
# /usr/lib64/
sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake || exit 1

ZLIB="--no-system-zlib"
BZIP2="--no-system-bzip2"
EXPAT="--no-system-expat"
CURL="--no-system-curl"
LIBARCHIVE="--no-system-libarchive"
QT_GUI="--no-qt-gui"

[ -x /usr/lib/libz.so ]             && ZLIB="--system-zlib"
command -v bzip2        &>/dev/null && BZIP2="--system-bzip2"
command -v xmlwf        &>/dev/null && EXPAT="--system-expat"
command -v curl         &>/dev/null && CURL="--system-curl"
command -v bsdcat       &>/dev/null && LIBARCHIVE="--system-libarchive"
command -v assistant    &>/dev/null && QT_GUI="--qt-gui"

# заставляет CMake связываться с Zlib, Bzip2, cURL, Expat и libarchive которые
# уже установлены в системе
#    --system-libs
# использовать внутреннюю версию библиотеки JSON-C++ вместо системной
#    --no-system-jsoncpp
./bootstrap              \
    --prefix=/usr        \
    --system-libs        \
    --mandir=/share/man  \
    --no-system-jsoncpp  \
    --no-system-librhash \
    "${ZLIB}"            \
    "${BZIP2}"           \
    "${EXPAT}"           \
    "${CURL}"            \
    "${LIBARCHIVE}"      \
    "${QT_GUI}"          \
    --docdir="/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# тесты
# известно что тест RunCMake.CommandLineTar завершается ошибкой, если пакет
# zstd (из lfs) не установлен
# unset LANG
# NUMJOBS="$(($(nproc) + 1))"
# bin/ctest -j"${NUMJOBS}" -O "${PRGNAME}-${VERSION}-test.log"

make install
make install DESTDIR="${TMP_DIR}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (cross-platform, open-source make system)
#
# The CMake package contains a modern toolset used for generating Makefiles. It
# is a successor of the auto-generated configure script and aims to be
# platform- and compiler-independent. CMake generates native makefiles and
# workspaces that can be used in the compiler environment of your choice.
#
# Home page: https://cmake.org/
# Download:  https://cmake.org/files/v${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
