#!/bin/bash

user=$1
rol=$2

JAIL=/users/$rol/$user
JAIL_BIN=$JAIL/bin/
CONFIG=/users/config
CONFIGBASE=/users

arrayProgrames=0
direccioBashrc=0
tempsEntorn="connexio"
tempsHome="persistent"

function remove()
{
	case $1 in
		userenviroment)
			echo "Deleting enviroment..."
			userdel $user
			
			funciona=$?
			if [ $funciona -eq 0 ]; then
				cd /users/$rol/$user
				rm -rf !home
				echo "User deleted"
			else
				echo "User is logged in. After he logs out, user will be deleted."
				direccio="$(locate $user | head -n 1)"
				updatedb
				echo "La direccio de user es: $direccio/.bash_logout"
				echo "userdel $user && rm -rf $direccio !home" >> "$direccio/.bash_logout"
			fi
			;;

		userhome)
			echo "Deleting home..."
			userdel $user
			
			funciona=$?
			if [ $funciona -eq 0 ]; then
				rm -rf /users/$rol/$user/home/$user
				echo "User deleted"
			else
				echo "User is logged in. After he logs out, user will be deleted."
				direccio="$(locate $user | head -n 1)"
				updatedb
				echo "La direccio de user es: $direccio/.bash_logout"
				echo "userdel $user && rm -rf $direccio" >> "$direccio/.bash_logout"
			fi
			;;

		*)
			echo "Deleting user..."
			userdel $user
			funciona=$?
			if [ $funciona -eq 0 ]; then
				echo "User deleted"
			else
				echo "User is logged in. After he logs out, user will be deleted."
				direccio="$(locate $user | head -n 1)"
				updatedb
				echo "La direccio de user es: $direccio/.bash_logout"
				echo "userdel $user && rm -rf $direccio" >> "$direccio/.bash_logout"
			fi
			;;
		
	esac
}

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

            *)
                ;;
        esac
        i=$((i+1))
    done < "$CONFIGBASE/configuracio"
}

function llegeixConfig()
{
    i=0
    while read -r line; do
        case "$i" in
            0)
                echo "Linia: $line"
                IFS=',' read -r -a arrayProgrames <<< "$line"
                for element in "${arrayProgrames[@]}"
                do
                    echo "$element"
                done
                ;;
            1)
                direccioBashrc="$line"
                echo "Direccio: $line"
                ;;
            2)
                tempsEntorn="$line"
                echo "Temps Entorn: $line"
                ;;
            3)
                tempsHome="$line"
                echo "Temps home: $line"
                ;;
            *)  
                
                ;;   
        esac
        i=$((i+1))

    done < "$CONFIG/$rol"
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

function actualitzaDades() #en teoria ja no caldra
{
	cd /users/$rol/etc

    cp /etc/ld.so.cache .
    cp /etc/ld.so.conf .
    cp /etc/nsswitch.conf .
    cp /etc/passwd .
    cp /etc/group .
    cp /etc/shadow .
    cp /etc/hosts .
    cp /etc/resolv.conf .

	chmod 755 /users/$rol/$user/home/*

}

function copiaProgrames()
{   
    mkdir -p $JAIL/home/$user>/mail/inbox/{tmp,new,cur}
    chmod -R 700 $JAIL/home/$user>/mail

    copy_binary whoami
    copy_binary groups
	copy_binary vi
	copy_binary cat
	copy_binary clear
	copy_binary rm
	copy_binary rmdir
    copy_binary mutt
    
    for element in "${arrayProgrames[@]}"
    do
        copy_binary "$element"
    done


    
}

function limitatempsEntorn()
{
    if [ "$tempsEntorn" != "persistent" ]; then
cat <<EOF | at now + $tempsHome
bash rbac -r $user $rol userenviroment
EOF
    fi
    if [ "$tempsEntorn" != "connexio" ]; then
        echo "userdel $user && rm -rf /users/$rol/$user !home" >> "/users/$rol/$user/.bash_logout"
    fi
}
    
function limitatempsHome()
{
    if [ "$tempsHome" != "persistent" ]; then
cat <<EOF | at now + $tempsHome 
bash rbac -r $user $rol userhome
EOF
    fi
}

function creaEnviroment()
{
    #mkdir -p /users/$rol/$user/home/$user
    mkdir -p /users/$rol/$user/
    mkdir -p /users/$rol/$user/{dev,etc,lib,lib64,usr/bin,usr/sbin,bin}
    mknod -m 666 /users/$rol/$user/dev/null c 1 3

    cd /users/$rol/$user/etc
    cp /etc/ld.so.cache .
    cp /etc/ld.so.conf .
    cp /etc/nsswitch.conf .
    cp /etc/passwd .
    cp /etc/group .
    cp /etc/shadow .
    cp /etc/hosts .
    cp /etc/resolv.conf .

    cp -r /lib /users/$rol/$user/

    
    
    
    if [ -d /users/$rol/$user/home/$user/.ssh ]; then          #pel cas on no s'aguanta el home
        cp -r /users/$rol/$user/home/$user/.ssh /users/$rol/$user
        mkdir -p /users/$rol/$user/.ssh
        rm -rf /users/$rol/$user/home
    fi

    echo "Copying skel files..."
    mkdir -p /users/$rol/$user/home/
    cp -r $direccioBashrc /users/$rol/$user/home/$user
    cp -r /users/$rol/$user/.ssh /users/$rol/$user/home/$user
    chown $user: /users/$rol/$user/home/$user/.* !ssh

    cp $CONFIG/gestioEntorn /users/$rol/$user/home/$user
    cp $CONFIG/$rol /users/$rol/$user/
    cp $CONFIGBASE/configuracio /users/$rol/$user/

    chown root.root /users/$rol/$user/
	chown $user: /users/$rol/$user/home/$user


    case "$rol" in
        datastore)
            limitatempsEntorn
            limitatempsHome
            ;;
         
        *)
            copiaProgrames
            limitatempsEntorn
            limitatempsHome
 
	esac

}






if [ "$1" = "remove" ]
then
    user="$2"
    function="$3"

    remove $user $function
else
    llegeixDirConfig    
    llegeixConfig
    creaEnviroment
    chroot /users/$rol/$user/
fi