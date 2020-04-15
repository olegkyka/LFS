#! /bin/bash

PRGNAME="cyrus-sasl"

### Cyrus SASL (Simple Authentication and Security Layer)
# Библиотека Cyrus SASL используется почтовыми программами на клиентской или
# серверной стороне для предоставления услуг аутентификации и авторизации.

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/cyrus-sasl.html

# Home page: https://github.com/cyrusimap/cyrus-sasl/
# Download:  https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-2.1.27/cyrus-sasl-2.1.27.tar.gz

# Required:    no
# Recommended: berkeley-db
# Optional:    linux-pam
#              mit-kerberos-v5
#              mariadb или mysql (https://www.mysql.com/)
#              openjdk
#              openldap (см. опции конфигурации ниже)
#              postgresql
#              sqlite
#              krb4              (https://stuff.mit.edu/afs/net.mit.edu/project/attic/krb4/)
#              dmalloc           (https://dmalloc.com/)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}/html"

# включает сервер аутентификации SASLDB
#    --enable-auth-sasldb
# база данных sasldb создается в /var/lib/sasl вместо /etc
#    --with-dbpath=/var/lib/sasl/sasldb2
# saslauthd использует FHS-совместимый каталог /var/run/saslauthd
#    --with-saslauthd=/var/run/saslauthd
./configure                             \
    --prefix=/usr                       \
    --sysconfdir=/etc                   \
    --enable-auth-sasldb                \
    --with-dbpath=/var/lib/sasl/sasldb2 \
    --with-saslauthd=/var/run/saslauthd || exit 1

###
# включение поддержки OpenLDAP
#    --with-ldap
###

# пакет не поддерживаем сборку в несколько потоков, поэтому явно указываем -j1
make -j1 || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

# документация
install -v -dm755 "${DOCS}/html"

install -v -m644  saslauthd/LDAP_SASLAUTHD "${DOCS}"
install -v -m644  saslauthd/LDAP_SASLAUTHD "${TMP_DIR}${DOCS}"

install -v -m644  doc/legacy/*.html "${DOCS}/html"
install -v -m644  doc/legacy/*.html "${TMP_DIR}${DOCS}/html"

install -v -dm700 /var/lib/sasl
install -v -dm700 "${TMP_DIR}/var/lib/sasl"

# init script: /etc/rc.d/init.d/saslauthd
(
    cd /root/blfs-bootscripts || exit 1
    make install-saslauthd
    make install-saslauthd DESTDIR="${TMP_DIR}"
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Simple Authentication and Security Layer)
#
# This is the Cyrus SASL library. Cyrus SASL is used by mail programs on the
# client or server side to provide authentication and authorization services.
#
# Home page: https://github.com/cyrusimap/${PRGNAME}/
# Download:  https://github.com/cyrusimap/${PRGNAME}/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
