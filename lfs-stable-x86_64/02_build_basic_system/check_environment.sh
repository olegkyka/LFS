#! /bin/bash

if [[ "$(id -u)" != "0" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

# мы в chroot окружении?
ID1="$(awk '$5=="/" {print $1}' < /proc/1/mountinfo)"
ID2="$(awk '$5=="/" {print $1}' < /proc/$$/mountinfo)"
if [[ "${ID1}" == "${ID2}" ]]; then
    echo "You must enter chroot environment."
    echo "Run 003_entering_chroot.sh script in this directory."
    exit 1
fi

if [[ "${PATH}" != "/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin" ]]; then
    echo -n "Environment variable PATH musb be: "
    echo "/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin"
    echo "Now PATH=${PATH}"
    echo -e "\nWhy? Check script 003_entering_chroot.sh"
    echo "It must be set to a variable:"
    echo "PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin"
    exit 1
fi
