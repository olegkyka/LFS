#! /bin/bash

source "$(pwd)/check_environment.sh" || exit 1

# исполняемые файлы и библиотеки, созданные до сих пор, содержат не нужную нам
# отладочную информацию, поэтому можно ее удалить
echo "strip --strip-debug /tools/lib/* ..."
strip --strip-debug /tools/lib/*
echo "/usr/bin/strip --strip-unneeded /tools/{,s}bin/* ..."
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*
# в выводе этих команд будут  присутствовать сообщения о том, что не
# распознается формат файлов. В основном это оносится к скриптам, а не бинарным
# файлам. Так же используем команду strip хоста (/usr/bin/strip), чтобы удалить
# отладочную информацию с бинарника /tools/bin/strip

# Note:
# Нельзя использовать --strip-unneeded для библиотек. Статические данные будут
# уничтожены, и пакеты придется пересобирать заново.

# удалим документацию
echo "rm -rf /tools/{,share}/{info,man,doc} ..."
rm -rf /tools/{,share}/{info,man,doc}

# удалим не нужные *.la файлы (libtool-архивы), устанавливаемые с библиотеками
echo "find /tools/{lib,libexec} -name "*.la" -delete ..."
find /tools/{lib,libexec} -name "*.la" -delete
