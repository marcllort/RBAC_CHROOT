#!/bin/bash

groupadd datastore
groupadd visitor
groupadd basic
groupadd medium
groupadd advanced

mkdir -p /users/config
cd /users/config

cat <<EOT >> datastore

/etc/skel
0
0
EOT

cat <<EOT >> visitor
bash,touch,mkdir,rm
/etc/skel
1 day
1 day
EOT

cat <<EOT >> basic
gcc,make, kill
/etc/skel
1 day
persistent
EOT

cat <<EOT >> medium
java,ln,ps,python,pip,valgrind,grep,awk,sed
/etc/skel
1 day
persistent
EOT

#cal afegir dos mes al advanced

cat <<EOT >> advanced
chmod,chown,strace,chroot
/etc/skel
persistent
persistent
EOT

