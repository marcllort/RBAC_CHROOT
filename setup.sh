#!/bin/bash

function creaDaemon()
{
systemctl stop dimoniRoot
systemctl disable dimoniRoot
rm /lib/systemd/system/dimoniRoot.service
systemctl daemon-reload
systemctl reset-failed

cat <<EOT >> /lib/systemd/system/dimoniRoot.service
[Unit]
Description=daemon root service
After=network.target
[Service]
User=root
Type=simple
Restart=always
RestartSec=5
ExecStart=/users/config/escolta.sh
[Install]
WantedBy=multi-user.target
EOT

#systemctl daemon-reload
#systemctl start dimoniRoot
#systemctl enable dimoniRoot
}

function creaConfigs()
{
    cd /users/config
cat <<EOT >> datastore

/etc/skel
0
0
EOT

cat <<EOT >> visitor
bash,touch,mkdir,rm,ls,vim,nano
/etc/skel
1 day
1 day
EOT

cat <<EOT >> basic
bash,touch,mkdir,rm,ls,vim,nano,gcc,make,kill
/etc/skel
1 day
persistent
EOT

cat <<EOT >> medium
bash,touch,mkdir,rm,ls,vim,nano,gcc,make,kill,java,ln,ps,python,pip,valgrind,grep,awk,sed
/etc/skel
1 day
persistent
EOT

#cal afegir dos mes al advanced

cat <<EOT >> advanced
bash,touch,mkdir,rm,ls,vim,nano,gcc,make,kill,java,ln,ps,python,pip,valgrind,grep,awk,sed,chmod,chown,strace,chroot
/etc/skel
persistent
persistent
EOT
}

function creaFitxerBase()
{
    cd /users
cat <<EOT >> configuracio
/users/config
marc.llort@students.salleurl.edu
EOT
} 


#sudo add-apt-repository universe
#sudo apt-get install mailutils

groupadd datastore
groupadd visitor
groupadd basic
groupadd medium
groupadd advanced

rm -rf /users/config
mkdir -p /users/config

creaFitxerBase
creaConfigs
cp /home/marcllort/enviroment .
chmod 777 enviroment

cp /home/marcllort/escolta.sh /users/config/
chmod 755 /users/config/escolta.sh
cp /home/marcllort/envia.sh /users/config/
chmod 755 /users/config/envia.sh


creaDaemon

echo "Cal insertar a /users/config els scripts gestioEntorn i enviroment!"

#systemctl start dimoniRoot
#systemctl enable dimoniRoot