FASE 1 RBAC


--INSTALACIÓ

1. Cal instalar openssh-server i libpam-google-authenticator: 
    sudo add-apt-repository universe
    a) sudo apt install openssh-server
    b) sudo apt-get install libpam-google-authenticator
    c) sudo apt install sendmail-bin
    d) sudo apt install gcc
    e) sudo apt install default-jre
    f) sudo apt install python-pip
    g) sudo apt install valgrind

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



--EXPLICACIÓ SCRIPTS

    #Servers-Clients

    .envia.sh)
        Encarregat de enviar comandes per ser executades, al servidor escolta.sh. Sempre s'enviaràn comandes per borrar entorns/home (amb el script removeEnviroment)

    escolta.sh)
        Server que escolta comandes de .envia.sh i les executa segons la comanda i el usuari rebuts. Rebra "user-borraX" i segons això farà una funció o altra.

    gestioEntorn)
        Eina disponible per cada usuari per efectuar el reset del seu entorn, clean-all per borrar entorn i home, request-command per enviar solicitud al admin. Les dos primeres opcions enviaràn al server escolta.sh, mentre que el mail enviarà al server repMail.sh.

    repMail.sh)
        Server encarregat de rebre els request-command dels users i enviar-los mitjançant sendmail.


    #Creacio usuaris/entorns

    rbac)
        Creació d'usuaris segons el rol. Afegeix el usuari, crea un path a /users/rol/userx i posa el fitxer de configuració que haurà de segur durant la creació del seu entorn, quan fagi login.

    enviroment)
        Llegeix arxiu de configuració i segons aquest copia els programes i llibreries necessaris, juntament amb els fitxers indispensables.

    removeEnviroment)
        Encarregat de borrar tant entorns com home's segons les instruccions que li arribin. En cas de no poder realitzar alguna acció de borrat perquè el usuari esta logejat, l'agefirà al seu bash_logout per executar quan faci logout.


    #Scripts de test/automatització

    setup)
        Monta el primer cop els diferents arxius de configuració a les localitzacions configurades, crea els grups dels rols principals, i borra usuaris/carpetes existests a /users en cas d'haver-ne

    test)
        Genera un usuari de test de cada tipus, amb la nomenclatura ex: "datastore1", "visitor1"... També els borra si ja existien anteriorment. Totes aquestes funcions les realitza mitjançant els scripts creats anteriorment, (setup, rbac funcions -a i -r)