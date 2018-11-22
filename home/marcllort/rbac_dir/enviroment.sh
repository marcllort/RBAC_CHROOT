#!/bin/bash


#FUNCIONS

function llegeixDirConfig()
{
    i=0
    while read -r line; do
        case "$i" in
            0)
                CONFIG="$line"
                ;;

            1)
                MAIL="$line"
                ;;
            
            2)
                PORTroot="$line"
                ;;
            3)
                PORTmail="$line"
                ;;

            *)
                ;;
        esac
        i=$((i+1))
    done < "$CONFIGBASE/configuracio"
}

function llegeixConfig()
{   
    if [ "$rol"="visitor" ]
    then
        IFS='_' read -r -a arrayRol <<< "$user"
        rolNou="${arrayRol[0]}"

        if [ -f "/users/config/$rolNou" ]
		then
            conf="$rolNou"
        else
            conf="$rol"
        fi

        echo "User=$user    Rol=$rol    RolNou=$rolNou"

    fi

    i=0
    while read -r line; do
        case "$i" in
            0)
                IFS=',' read -r -a arrayProgrames <<< "$line"
                ;;
            1)
                direccioBashrc="$line"
                ;;
            2)
                tempsEntorn="$line"
                ;;
            3)
                tempsHome="$line"
                ;;
            *)  
                ;;   
        esac
        i=$((i+1))

    done < "$CONFIG/$conf"
}

function copy_binary()
{
	BINARY=$(which $1)

	cp $BINARY $JAIL/$BINARY

	copy_dependencies $BINARY
}

function copy_dependencies()
{
	# http://www.cyberciti.biz/files/lighttpd/l2chroot.txt

	FILES="$(ldd $1 | awk '{ print $3 }' |egrep -v ^'\(')"

	echo "Copying shared files/libs to $JAIL..."

	for i in $FILES
	do
		d="$(dirname $i)"

		[ ! -d $JAIL$d ] && mkdir -p $JAIL$d || :

		/bin/cp $i $JAIL$d
	done

	sldl="$(ldd $1 | grep 'ld-linux' | awk '{ print $1}')"

	# now get sub-dir
	sldlsubdir="$(dirname $sldl)"

	if [ ! -f $JAIL$sldl ];
	then
		echo "Copying $sldl $JAIL$sldlsubdir..."
		/bin/cp $sldl $JAIL$sldlsubdir
	else
		:
	fi
}


function copiaProgrames()
{
    #Fitxers que cal copiar sempre
    copy_binary whoami
    copy_binary groups
	copy_binary vi
	copy_binary cat
	copy_binary clear
	copy_binary rm
	copy_binary rmdir
    copy_binary netcat
    
    #Fitxers segons el rol
    for element in "${arrayProgrames[@]}"
    do
        copy_binary "$element"
    done
}

function limitatempsEntorn() 
{
    case "$tempsEntorn" in

        persistent)
            ;;

        connexio)
            echo "bash /home/$user/.envia.sh borraEntorn" >> "$JAIL/home/$user/.bash_logout"
            ;;

        *)
            bash /home/$user/.envia.sh borraEntorn | at 00:00 AM today + $tempsEntorn
            ;;

    esac
}
    
function limitatempsHome()
{
    if [ "$tempsHome" != "persistent" ]; then
        bash /home/$user/.envia.sh borraHome | at 00:00 AM today + $tempsHome
    fi
}

function copiaFitxers()
{

    #Posem fitxer de enviar comandes al dimoniRoot
	cp /users/config/.envia.sh $JAIL/home/$user/
	chmod 755 $JAIL/home/$user/.envia.sh


    mkdir -p $JAIL/
    mkdir -p $JAIL/{dev,etc,lib,lib64,usr/bin,usr/sbin,bin}
    mknod -m 666 $JAIL/dev/null c 1 3

    if [ ! -f "$JAIL/home" ]
    then
        #Poso skel a la home
        mkdir -p $JAIL/home
        cp -r $direccioBashrc $JAIL/home/$user
        chown $user: $JAIL/home/$user
        
    fi

    cd $JAIL/etc
    cp /etc/ld.so.cache .
    cp /etc/ld.so.conf .
    cp /etc/nsswitch.conf .
    cp /etc/passwd .
    cp /etc/group .
    cp /etc/shadow .
    cp /etc/hosts .
    cp /etc/resolv.conf .

    cp -r /bin/sh $JAIL/bin
    cp -r /bin/bash $JAIL/bin
    cp -r /lib $JAIL/
    cp -r /lib64 $JAIL/
    
    if [ $rol != "datastore" ]
    then
        cp $CONFIG/gestioEntorn $JAIL/home/$user
    fi

    cp $CONFIG/$rol $JAIL/
    cp $CONFIGBASE/configuracio $JAIL/

    chown root.root $JAIL/
	chown $user: $JAIL/home/$user
    chmod 755 $JAIL/home/$user/gestioEntorn

}

function creaEnviroment()
{

    copiaFitxers

    case "$rol" in
        datastore)
            limitatempsEntorn
            limitatempsHome
            ;;
        
        advanced)
            copiaProgrames
            ;;
         
        *)
            copiaProgrames
            limitatempsEntorn
            limitatempsHome
 
	esac

}

function enviroment()
{
    if [ ! -f "$JAIL/configuracio" ]        #si no esta configuracio, entorn no existeix i cal crearlo
    then
        
        echo "Creating environment... USER: $user - $rol"

        llegeixDirConfig    
        llegeixConfig

        creaEnviroment

    fi
}



#CONSTANTS

user="$PAM_USER"

fraseGroups="groups $user"      #Comandes per definir el rol
grups="$($fraseGroups)"
array=( $grups )

rol="${array[3]}"

JAIL=/users/$rol/$user
JAIL_BIN=$JAIL/bin/

CONFIG=/users/config
CONFIGBASE=/users

arrayProgrames=0
direccioBashrc=0
tempsEntorn="connexio"
tempsHome="persistent"



#SCRIPT

if [ "$PAM_USER" = "" ]        #per poderme connectar per ssh jo sense carregar enviroment
then
    echo "NO ES PAM"
    user=$1
    fraseGroups="groups $user"      #Comandes per definir el rol
    grups="$($fraseGroups)"
    array=( $grups )

    rol="${array[3]}"

    JAIL=/users/$rol/$user
    JAIL_BIN=$JAIL/bin/

    CONFIG=/users/config
    CONFIGBASE=/users

    arrayProgrames=0
    direccioBashrc=0
    tempsEntorn="connexio"
    tempsHome="persistent"
    enviroment
    echo "enviroment creat"
else
    echo "Funcio enviroment"
    enviroment
fi