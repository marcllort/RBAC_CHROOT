#!/bin/bash


#FUNCIONS

function llegeixDirConfig()
{
    if [ ! -f "$CONFIGBASE/configuracio" ]        #si no esta configuracio, entorn no existeix i cal crearlo
    then
        echo "Fixer de configuració base inexistent"
    fi

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

    fi

    if [ -f "$CONFIG/$conf" ]       #si no esta configuracio, entorn no existeix i cal crearlo
    then

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
    else
        echo "Error, no existeix el fitxer configuracio del rol: $conf"
        exit
    fi
}

function copy_binary()
{
	BINARY=$(which $1)

	cp $BINARY $JAIL/$BINARY &>/dev/null

	copy_dependencies $BINARY
}

function copy_dependencies()
{
	# http://www.cyberciti.biz/files/lighttpd/l2chroot.txt

	FILES="$(ldd $1 &>/dev/null | awk '{ print $3 }' |egrep -v ^'\(')" 

	for i in $FILES
	do
		d="$(dirname $i &>/dev/null)" 

		[ ! -d $JAIL$d ] && mkdir -p $JAIL$d || :

		/bin/cp $i $JAIL$d &>/dev/null
	done

	sldl="$(ldd $1 &>/dev/null | grep 'ld-linux' | awk '{ print $1}')" 

	sldlsubdir="$(dirname $sldl &>/dev/null)" 

	if [ ! -f $JAIL$sldl ];
	then
		/bin/cp $sldl $JAIL$sldlsubdir &>/dev/null
	else
		:
	fi
}


function copiaProgrames()
{
    #Fitxers que cal copiar sempre
    copy_binary whoami
    copy_binary groups
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
            bash $JAIL/home/$user/.envia.sh borraEntorn &>/dev/null | at 00:00 AM today + $tempsEntorn &>/dev/null
            ;;

    esac
}
    
function limitatempsHome()
{
    if [ "$tempsHome" != "persistent" ]; then
        bash $JAIL/home/$user/.envia.sh borraHome &>/dev/null | at 00:00 AM today + $tempsHome &>/dev/null
    fi
}

function copiaFitxers()
{

    
    if [ ! -f "$JAIL/home" ]
    then
        #Poso skel a la home
        mkdir -p $JAIL/home
        cp -r $direccioBashrc $JAIL/home/$user
        chown $user: $JAIL/home/$user
        
    fi

    
    if [ $rol != "datastore" ]
    then
        mkdir -p $JAIL/
        mkdir -p $JAIL/{dev,etc,lib,lib64,usr/bin,usr/sbin,usr/lib,bin}
        mknod -m 666 $JAIL/dev/null c 1 3

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
        cp -r /usr/lib $JAIL/usr/

        cp $CONFIG/gestioEntorn $JAIL/home/$user
        chmod 755 $JAIL/home/$user/gestioEntorn

        mkdir -p $JAIL/proc
        mount -t proc proc $JAIL/proc
    fi

    #Posem fitxer de enviar comandes al dimoniRoot
	cp /users/config/.envia.sh $JAIL/home/$user/ 
	chmod 755 $JAIL/home/$user/.envia.sh

    cp $CONFIG/$rol $JAIL/
    cp $CONFIGBASE/configuracio $JAIL/

    chown root.root $JAIL/
	chown $user: $JAIL/home/$user

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
            
            chown -R $user /users/$rol/$user/* &>/dev/null
 
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
        
        llegeixDirConfig    
        llegeixConfig

        creaEnviroment
    else

        if [ ! -f "$JAIL/home/$user" ]
        then
            llegeixDirConfig    
            llegeixConfig
                        
            cp -r $direccioBashrc $JAIL/home/$user
            
            chown $user: $JAIL/home/$user

            if [ $rol != "datastore" ]
            then
                cp $CONFIG/gestioEntorn $JAIL/home/$user/
            fi

            #Posem fitxer de enviar comandes al dimoniRoot
            cp /users/config/.envia.sh $JAIL/home/$user/ 
            chmod 755 $JAIL/home/$user/.envia.sh

            chown $user: $JAIL/home/$user
            chmod 755 $JAIL/home/$user/gestioEntorn

        fi

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
    #echo "NO ES PAM"
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
    #echo "enviroment creat"
else
    #echo "Funcio enviroment"
    enviroment
fi