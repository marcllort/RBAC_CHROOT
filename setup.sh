#!/bin/bash


#FUNCIONS

function creaDaemonEntorn()
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
    Type=simple
    Restart=always
    RestartSec=5
    ExecStart=/users/config/escolta.sh
    [Install]
    WantedBy=multi-user.target
EOT

    systemctl start dimoniRoot
    systemctl enable dimoniRoot
}

function creaDaemonMail()
{
    systemctl stop dimoniMail
    systemctl disable dimoniMail
    rm /lib/systemd/system/dimoniMail.service
    systemctl daemon-reload
    systemctl reset-failed

    cat <<EOT >> /lib/systemd/system/dimoniMail.service
    [Unit]
    Description=daemon mail service
    After=network.target
    [Service]
    User=root
    Type=simple
    Restart=always
    RestartSec=5
    ExecStart=/users/config/repMail.sh
    [Install]
    WantedBy=multi-user.target
EOT

    systemctl start dimoniMail
    systemctl enable dimoniMail
}

function creaConfigs()
{
    cp /home/marcllort/enviroment /users/config/
    chmod 755 /users/config/enviroment
    cp /home/marcllort/escolta.sh /users/config/
    chmod 755 /users/config/escolta.sh
    cp /home/marcllort/envia.sh /users/config/
    chmod 755 /users/config/envia.sh
    cp /home/marcllort/repMail.sh /users/config/
    chmod 755 /users/config/repMail.sh
    cp /home/marcllort/gestioEntorn /users/config/
    chmod 755 /users/config/gestioEntorn
    cp /home/marcllort/removeEnviroment /users/config/
    chmod 755 /users/config/removeEnviroment

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
    mac12llm@gmail.com
EOT
} 


#SCRIPT

#Afegim grups dels diferents rols
groupadd datastore
groupadd visitor
groupadd basic
groupadd medium
groupadd advanced

rm -rf /users/config
mkdir -p /users/config

#Crea el fitxer de configuracio que te el mail i direccio
creaFitxerBase

#Crea els diferents fitxers de configuració per cada grup, i copia els programes necessaris
creaConfigs

#Crea el dimoni encarregat de executar els borrats de usuaris, homes i entorns
creaDaemonEntorn

#Crea el dimoni encarregat d'enviar el mail amb el request command
creaDaemonMail