#!/bin/bash

#cal fer users a un disc apart i canviar path

#rm -rf /users




function=$1
rol=$3
user=$2

JAIL=/users/$rol
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

function actualitzaDades()
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

	chmod 700 /users/$rol/home/*
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
	Visitor

	copy_binary gcc
	copy_binary make
	copy_binary kill
}

function medium()
{
	Basic

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
	Medium

	copy_binary chmod
	copy_binary chown
	copy_binary strace
	copy_binary chroot
	#copy_binary
	#copy_binary
}


function creaUser()
{
	#mirar si ja existeix usuari
	if getent passwd $user > /dev/null 2>&1; then
		echo "User already exists!"
	else
		rm -rf /users/$rol/home/$user
		cp -r /etc/skel /users/$rol/home/$user
		
		useradd -G $rol $user -d /home/$user
		echo "$user:contra" | sudo chpasswd      #cal fer KEY

		actualitzaDades

		chown $user: /users/$rol/home/$user
	fi
	
}

function add()
{
	case "$rol" in
        datastore)
            creaUser
            ;;
         
        visitor)
            visitor
            creaUser
            ;;
         
        basic)
            basic
            creaUser
            ;;

        medium)
            medium
            creaUser
            ;;

        advanced)
            advanced
            creaUser
            ;;
         
        *)
            echo $"$rol : No es un tipus d'usuari"
            exit 1
 
	esac

}

function remove()
{
    userdel $user
}




function help {
	echo "Usage: rbac [COMMAND]"
	echo "Add and remove users.\n"
	echo "-a, --add			add user. Must specify user type. Ex: rbac -a foo visitor"
	echo "-r, --remove			remove user. Ex: rbac -r foo"
	echo "-h, --help			help info"
}


#Execucio script

if [ $# -lt 1 ]
then
	"Missing operand. Try: 'rbac --help' for more information."
fi

case "$function" in

	"-a" | "--add")
		add
		;;
	"-r" | "--remove")
		remove
		;;
	"-h" | "--help")	
		help
		;;
	*)
		echo "rbac: invalid command."
		echo "Try: 'rbac --help' for more information."
esac













#mount --bind /bin /users/rol/bin
#mount --bind /lib /users/rol/lib



#aqui caldra un swithc per segons tipus usuair donar uns programes o altres, limitant el bashrc https://unix.stackexchange.com/questions/90998/block-particular-command-in-linux-for-specific-user


#https://allanfeid.com/content/creating-chroot-jail-ssh-access