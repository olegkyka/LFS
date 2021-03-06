#! /bin/bash

SRC_ARCH_NAME="$1"
SOURCES="${LFS}/sources"
VERSION=$(echo "${SOURCES}/${SRC_ARCH_NAME}"-*.tar.?z* | rev | \
    cut -f 3- -d . | cut -f 1 -d - | rev)
BUILD_DIR="${SOURCES}/build"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${SRC_ARCH_NAME}-${VERSION}"

tar xvf "${SOURCES}/${SRC_ARCH_NAME}-${VERSION}".tar.?z* || exit 1
cd "${SRC_ARCH_NAME}-${VERSION}" || exit 1
