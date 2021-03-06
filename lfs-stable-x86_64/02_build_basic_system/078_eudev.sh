#! /bin/bash

PRGNAME="eudev"

### Eudev (dynamic device directory system)
# программы для динамического создания узлов устройств

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/eudev.html

# Home page: https://wiki.gentoo.org/wiki/Project:Eudev
# Download:  https://dev.gentoo.org/~blueness/eudev/eudev-3.2.9.tar.gz
#            https://github.com/gentoo/eudev/releases
#            http://anduin.linuxfromscratch.org/LFS/udev-lfs-20171102.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}config_file_processing.sh"             || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure                \
    --prefix=/usr          \
    --bindir=/sbin         \
    --sbindir=/sbin        \
    --libdir=/usr/lib      \
    --sysconfdir=/etc      \
    --libexecdir=/lib      \
    --with-rootprefix=     \
    --with-rootlibdir=/lib \
    --enable-manpages      \
    --disable-static || exit 1

make || exit 1

# создадим несколько каталогов, которые необходимы для тестов, а также будут
# использоваться как часть установки системы
mkdir -pv /lib/udev/rules.d
mkdir -pv /etc/udev/rules.d
mkdir -pv "${TMP_DIR}/lib/udev/rules.d"
mkdir -pv "${TMP_DIR}/etc/udev/rules.d"

make check

# бэкапим конфиг /etc/udev/udev.conf перед установкой пакета, если он
# существует
UDEV_CONF="/etc/udev/udev.conf"
if [ -f "${UDEV_CONF}" ]; then
    mv "${UDEV_CONF}" "${UDEV_CONF}.old"
fi

# устанавливаем пакет
make install
make install DESTDIR="${TMP_DIR}"

config_file_processing "${UDEV_CONF}"

# установим некоторые пользовательские правила и файлы поддержки, которые будут
# полезные в среде LFS
# /etc
# └── udev
#     └── rules.d
#         ├── 55-lfs.rules
#         ├── 81-cdrom.rules
#         └── 83-cdrom-symlinks.rules
# /lib
# └── udev
#     ├── rules.d/
#     ├── init-net-rules.sh
#     ├── rule_generator.functions
#     ├── write_cd_rules
#     └── write_net_rules
# /usr
#     └── share
#         └── doc
#             └── udev-${VERSION}
#                 └── lfs
#                     ├── 55-lfs.txt
#                     └── README
UDEV_LFS="udev-lfs"
UDEV_LFS_VERSION="$(echo "${SOURCES}/${UDEV_LFS}"-*.tar.?z* | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"
tar xvf "${SOURCES}/${UDEV_LFS}-${UDEV_LFS_VERSION}".tar.?z* || exit 1
make -f "${UDEV_LFS}-${UDEV_LFS_VERSION}/Makefile.lfs" install
make -f "${UDEV_LFS}-${UDEV_LFS_VERSION}/Makefile.lfs" install \
    DESTDIR="${TMP_DIR}"

### конфигурация Eudev
# информация об аппаратных устройствах хранится в каталогах
#    /etc/udev/hwdb.d/
#    /lib/udev/hwdb.d/
# Для Eudev нужно, чтобы эта информация была собрана в двоичной базе данных
#    /etc/udev/hwdb.bin
# Создадим эту исходную базу данных. Эта команда должна выполняться каждый раз,
# когда обновляется информация об оборудовании
udevadm hwdb --update
cp -v /etc/udev/hwdb.bin "${TMP_DIR}/etc/udev/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (dynamic device directory system)
#
# The Eudev package contains programs for dynamic creation of device nodes and
# provides a dynamic device directory containing only the files for the devices
# which are actually present. It creates or removes device node files usually
# located in the /dev directory. Eudev is a fork of
# https://github.com/systemd/systemd with the aim of isolating udev from any
# particular flavor of system initialization.
#
# Home page: https://wiki.gentoo.org/wiki/Project:Eudev
# Download:  https://dev.gentoo.org/~blueness/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#            https://github.com/gentoo/${PRGNAME}/releases
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
