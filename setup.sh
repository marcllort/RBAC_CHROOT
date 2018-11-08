#!/bin/bash

"Match group datastore
          ChrootDirectory /users/datastore/
          X11Forwarding no
          AllowTcpForwarding no

Match group visitor
          ChrootDirectory /users/visitor/
          X11Forwarding no
          AllowTcpForwarding no

Match group basic
          ChrootDirectory /users/basic/
          X11Forwarding no
          AllowTcpForwarding no

Match group medium
          ChrootDirectory /users/medium/
          X11Forwarding no
          AllowTcpForwarding no

Match group advanced
          ChrootDirectory /users/advanced/
          X11Forwarding no
          AllowTcpForwarding no"

#fer funcions per fer un setup desde 0


#Primera execució creacio carpetes
function creaRol()
{
    mkdir -p /users/$1/home/


    mkdir -p /users/$1/{dev,etc,lib,lib64,usr,bin}
    mkdir -p /users/$1/usr/bin

    mknod -m 666 /users/$1/dev/null c 1 3


    cd /users/$1/etc

    cp /etc/ld.so.cache .
    cp /etc/ld.so.conf .
    cp /etc/nsswitch.conf .
    cp /etc/passwd .
    cp /etc/group .
    cp /etc/shadow .
    cp /etc/hosts .
    cp /etc/resolv.conf .

    cp -r /lib /users/$1/

    cd

    chown root.root /users/$1/

    groupadd $1
}

creaRol datastore
creaRol visitor
creaRol basic
creaRol medium
creaRol advanced