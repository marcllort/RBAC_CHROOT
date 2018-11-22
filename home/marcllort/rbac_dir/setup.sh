#!/bin/bash


#FUNCIONS

function creaDaemonEntorn()
{
    systemctl stop dimoniRoot
    systemctl disable dimoniRoot
    rm /lib/systemd/system/dimoniRoot.service
    systemctl daemon-reloadg
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
    cp /home/$userhome/rbac_dir/enviroment /users/config/
    chmod 755 /users/config/enviroment
    cp /home/$userhome/rbac_dir/escolta.sh /users/config/
    chmod 755 /users/config/escolta.sh
    cp /home/$userhome/rbac_dir/.envia.sh /users/config/
    chmod 755 /users/config/.envia.sh
    cp /home/$userhome/rbac_dir/repMail.sh /users/config/
    chmod 755 /users/config/repMail.sh
    cp /home/$userhome/rbac_dir/gestioEntorn /users/config/
    chmod 755 /users/config/gestioEntorn
    cp /home/$userhome/rbac_dir/removeEnviroment /users/config/
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
    bash,touch,mkdir,rm,ls,vim,nano,gcc,make,kill,java,ln,ps,python3,pip,valgrind,grep,awk,sed,chmod,chown,strace,cat,mv,rm,rmdir,clear
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
    4444
    5555
EOT
} 

#Aqui posem el fitxer de google authenticator que volem fer servir
function creaAuth()
{
    cd /users/config
    cat <<EOT >> .google_authenticator
    QNTOL4UVWHV4S4UKRNG744TK7U
    " RATE_LIMIT 3 30 1542453539
    " WINDOW_SIZE 17
    " TOTP_AUTH
    18455154
    69946224
    52104533
    43050867
    46607396
EOT
    chown root:root /users/config/.google_authenticator
}

function creaSSH()
{
    mkdir -p /users/config/ssh/$user/
    cat <<EOT >> /users/config/ssh/$user/authorized_keys
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkl/f8igvh7Ab6SpHjR4sK6ksKmkdPPOtxcBxIFTqx/vtAX0Ohdj4GOtEUy9xsu08VajKksRTIckCyN/ByWS1nbRX8GGj4l3gFCHC+lLQPwXrvBJlSJTPRh5EjVG1ZgPmhzSMEg8V0EJHclPE5yUFF6JMvstAJ1D3Hxr18WikGxQ68G6SQ/8SuTtV2qeyEw/tLWk14WNHn02YmH7vPG1feaj6qNkWLuAJA2ygtuDN8gyjC3+IKqeWpH6TKNioNhb8TSGviwzY4AiO1cpWLhHAqN221Bafzhizt45IZjyMRaSHWeqnh+a8u+PQ6B6kW74oGl5zQxipliqrGhwEK1kc9 $userhome@MBP-de-Marc
EOT

    chmod 755 /users/config/ssh
    chmod 755 /users/config/ssh/authorized_keys
}



#CONSTANTS

userhome="$1"


#SCRIPT

#Afegim grups dels diferents rols
groupadd datastore
groupadd visitor
groupadd basic
groupadd medium
groupadd advanced

rm -rf /users/config
mkdir -p /users/config/googleauth

#Crea el fitxer de configuracio que te el mail i direccio
creaFitxerBase

#Crea els diferents fitxers de configuració per cada grup, i copia els programes necessaris
creaConfigs

#Crea el dimoni encarregat de executar els borrats de usuaris, homes i entorns
creaDaemonEntorn

#Crea el dimoni encarregat d'enviar el mail amb el request command
creaDaemonMail