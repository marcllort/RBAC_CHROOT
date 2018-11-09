#!/bin/bash

user=$1
rol=$2

JAIL=/users/$rol/$user
JAIL_BIN=$JAIL/bin/

arrayProgrames=0
direccioBashrc=0
tempsEntorn="connexio"
tempsHome="persistent"

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

    done < "/users/config/$rol"
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

	chmod 700 /users/$rol/$user/home/*

}

function copiaProgrames()
{
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
        bash rbac -r $user $rol userenviroment
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
    mkdir -p /users/$rol/$user/{dev,etc,lib,lib64,usr/bin,bin}
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
    
    if [ ! -d /users/$rol/$user/home/$user ]; then          #pel cas on no s'aguanta el home
        echo "Copying skel files..."
        mkdir -p /users/$rol/$user/home/
        cp -r $direccioBashrc /users/$rol/$user/home/$user
    fi

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

llegeixConfig

creaEnviroment


chroot /users/$rol/$user/

#cd /home/$user









function visitor()
{
	copy_binary bash
	copy_binary touch
	copy_binary mkdir
	copy_binary rm
	#cd va sol
	copy_binary ls
	copy_binary vim
	copy_binary nano

	#en teoria no shan de posar pero no crec q passi res
	copy_binary whoami
	copy_binary vi
	copy_binary cat
	copy_binary clear
	copy_binary rm
	copy_binary rmdir
}

function basic()
{
	visitor

	copy_binary gcc
	copy_binary make
	copy_binary kill
}

function medium()
{
	basic

	copy_binary java
	copy_binary ln
	copy_binary ps
	copy_binary python
	copy_binary	pip #pip3 tmb?
	copy_binary valgrind
	copy_binary grep
	copy_binary awk
	copy_binary sed
}

function advanced()
{			#cal posar 2 comandes mes, les que creguem
	medium

	copy_binary chmod
	copy_binary chown
	copy_binary strace
	copy_binary chroot
	#copy_binary
	#copy_binary
}