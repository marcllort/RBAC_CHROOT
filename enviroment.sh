#!/bin/bash

user=$rol
rol=$2

JAIL=/users/$rol/$user
JAIL_BIN=$JAIL/bin/

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

function limitatemps()
{
cat <<EOF | at midnight 
bash sudo rbac -r $user $rol $1
EOF
}

function creaEnviroment()
{
    mkdir -p /users/$rol/$user/
    mkdir -p /users/$rol/$user/{dev,etc,lib,lib64,usr,bin}
    mknod -m 666 /users/$rol/$user/dev/null c rol 3

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
    

    chown root.root /users/$rol/$user/
	chown $user: /users/$rol/home/$user


    case "$rol" in
        datastore)
            limitatemps userhome
            ;;
         
        visitor)
            visitor
            limitatemps userhome
            ;;
         
        basic)
            basic
            limitatemps
            ;;

        medium)
            medium
            limitatemps
            ;;

        advanced)
            advanced
            
            ;;
         
        *)
            echo $"$rol : No es un tipus d'usuari"
            exit 1
 
	esac

}


creaEnviroment
if [ ! -d /users/$rol/$user/home/$user ]; then          #pel cas on no s'aguanta el home
			echo "Copying skel files..."
			cp -r /etc/skel /users/$rol/$user/home/$user
fi