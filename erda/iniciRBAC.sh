#!/bin/bash

#cal fer users a un disc apart i canviar path

#rm -rf /users


JAIL=/users/rol
JAIL_BIN=$JAIL/bin/

copy_binary()
{
	BINARY=$(which $1)

	cp $BINARY $JAIL/$BINARY

	copy_dependencies $BINARY
}

copy_dependencies()
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


Visitor()
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
}

Basic()
{
	Visitor

	copy_binary gcc
	copy_binary make
	copy_binary kill
}

Medium()
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

Advanced()
{			#cal posar 2 comandes mes, les que creguem
	Medium

	copy_binary chmod
	copy_binary chown
	copy_binary strace
	copy_binary chroot
	#copy_binary
	#copy_binary
}



function=$1
rol=$2
user=$3

case "$function" in

	add)

		;;

	remove)

		;;

	-help)

		;;

	*)
		echo "Nom de la funció incorrecta. Escriu 'rbac -help' per ajuda"		

esac


add()
{
	case "$rol" in
        datastore)
            creaUser
            ;;
         
        visitor)
            creaUser
            ;;
         
        basic)
            status anacron
            ;;

        medium)
            stop
            start
            ;;

        advanced)
            if test "x`pidof anacron`" != x; then
                stop
                start
            fi
            ;;
         
        *)
            echo $"$rol : No es un tipus d'usuari"
            exit 1
 
	esac

	


}

creaUser()
{
	mkdir -p /users/rol/home/


	mkdir -p /users/rol/{dev,etc,lib,lib64,usr,bin}
	mkdir -p /users/rol/usr/bin

	mknod -m 666 /users/rol/dev/null c 1 3


	cd /users/rol/etc
	cp /etc/ld.so.cache .
	cp /etc/ld.so.conf .
	cp /etc/nsswitch.conf .
	cp /etc/passwd .
	cp /etc/group .
	cp /etc/shadow .
	cp /etc/hosts .
	cp /etc/resolv.conf .

	cp -r /lib /users/rol/

	#cal borrar root i altres users de passwd i group


	cd

	chown root.root /users/rol/



	userdel userJail
	groupdel jailusers

	


	cp -r /etc/skel /users/rol/home/userJail

	groupadd jailusers
	useradd -G jailusers userJail -d /home/userJail
	echo 'userJail:contra' | sudo chpasswd

	chown userJail: /users/rol/home/userJail
}












#mount --bind /bin /users/rol/bin
#mount --bind /lib /users/rol/lib



#aqui caldra un swithc per segons tipus usuair donar uns programes o altres, limitant el bashrc https://unix.stackexchange.com/questions/90998/block-particular-command-in-linux-for-specific-user


#https://allanfeid.com/content/creating-chroot-jail-ssh-access