FASE 1 RBAC


--INSTALACIÓ

1. Cal instalar openssh-server i libpam-google-authenticator: 
    a) sudo apt install openssh-server
    b) sudo apt-get install libpam-google-authenticator

2. Copiar fitxers:
    a) .bashrc -> /etc/skel/
    b) sshd_config -> /etc/ssh/
    c) sshd -> /etc/pam.d/
    d) (Cal provar) Modificar /etc/default/useradd -> canviar "/bin/sh" per "/bin/bash"

3. Apuntar-nos la adreça inet de la comanda "ifconfig", per posteriorment connectar-nos per ssh

4. Executar: sudo systemctl restart ssh

5. Copiar els seguents scripts a la home del teu usuari/admin del server:
    escolta.sh, .envia.sh, repMail.sh, gestioEntorn, removeEnviroment, enviroment, rbac, test

6. Executa setup amb "sudo bash setup <nomUsuari>", per generar la estructura bàsica del rbac.

7. Preparar metodes d'autentificació:
    a) SSH: Modificar script setup, funcio "creaSSH", i posar la nostra pubkey allà
    b) GoogleAuth: Correr "google-authenticator" desde el admin, configurar com vulguem, escanejar QR, anar a la nostra home/, fer "cat .google_authenticator" i copiar el contingut del fitxer a dins la funció "creaAuth" del script setup.



--EXECUCIÓ

1. Per afegir usuaris es pot fer us de la comanda rbac, seguir les instruccions a help, o el script test, el qual afegeix (amb la comanda rbac) un usuari de cada tipus, cada un anomenat rol1 (ex: visitor1).
Per executar el script: "sudo bash test <nomUsuari>"

2. Connectar-nos a través de terminal o putty amb la ip capturada anteriorment. Posar al davant de la ip el nom del usuari al que volem connectar-nos: "ssh visitor1@192.168.25.1"