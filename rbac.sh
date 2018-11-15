#!/bin/bash

#cal fer users a un disc apart i canviar path


function=$1
rol=$3
user=$2
direccioBashrc=0



JAIL=/users/$rol/$user
JAIL_BIN=$JAIL/bin/
CONFIG=/users/config


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


function creaUser()
{
	#mirar si ja existeix usuari
	if getent passwd $user > /dev/null 2>&1; then
		echo "User already exists!"
	else
		
		useradd -G $rol $user -d /home/$user

		CONTRA=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)

		echo "$user:contra" | sudo chpasswd      #cal fer KEY
		
		mkdir -p /users/$rol/$user/home
		cp -r $direccioBashrc /users/$rol/$user/home/$user
		ls -a /users/$rol/$user/home/$user

		mkdir -p /users/$rol/$user/home/$user/.ssh
		mkdir -p /users/$rol/$user/bin
		mkdir -p /users/$rol/$user/lib
		mkdir -p /users/$rol/$user/lib64




		cp -r /bin/sh /users/$rol/$user/bin
		cp -r /bin/bash /users/$rol/$user/bin
		cp -r /lib /users/$rol/$user/
		cp -r /lib64 /users/$rol/$user/
		

		#cp -r $direccioBashrc /users/$rol/$user/home/$user
		cp -r /users/$rol/$user/.ssh /users/$rol/$user/home/$user
		chown $user: /users/$rol/$user/home/$user/.* ! ssh

		mkdir -p /users/$rol/$user/{etc,usr/bin}

		cp -r /usr/bin/whoami /users/$rol/$user/usr/bin/

		copy_binary netcat


		cd /users/$rol/$user/etc
		cp /etc/ld.so.cache .
		cp /etc/ld.so.conf .
		cp /etc/nsswitch.conf .
		cp /etc/passwd .
		cp /etc/group .
		cp /etc/shadow .
		cp /etc/hosts .
		cp /etc/resolv.conf .

		chown $user: /users/$rol/$user/home/$user

		chown visitor2 /users/visitor/visitor2/home/visitor2/.ssh
		chmod 755 /users/visitor/visitor2/home/visitor2/.ssh

		cp /home/marcllort/envia.sh /users/$rol/$user/home/$user
		chmod 755 /users/$rol/$user/home/$user/envia.sh

		cp $CONFIG/$rol $JAIL/


		#ssh-keygen -t rsa -b 2048 -f ~/.ssh/$user-key -P "$CONTRA"
		runuser -l $user -s /bin/sh 'ssh-keygen -t rsa -b 2048 -f /users/$rol/$user/home/$user/.ssh/$user-key -P "prova"'


		#sudo runuser -l visitor2 -s /bin/sh -c 'ssh-keygen -b 2048 -f /users/visitor/visitor2/home/visitor2/.ssh/visitor2-key -P "prova"'
		#cp /users/config/enviroment /users/$rol/$user/
		#cp /users/config/rbac /users/$rol/$user/

	fi
	
}



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




function help {
	echo "Usage: rbac [COMMAND]"
	echo "Add and remove users.\n"
	echo "-a, --add			add user. Must specify user type. Ex: rbac -a foo visitor"
	echo "-r, --remove			remove user. If added userhome, home will be deleted to Ex: rbac -r foo visitor userhome"
	echo "-h, --help			help info"
}


#Execucio script

if [ $# -lt 1 ]
then
	echo "Missing operand. Try: 'rbac --help' for more information."
fi

case "$function" in

	"-a" | "--add")
		llegeixConfig
		creaUser
		;;
	"-r" | "--remove")
		remove $4
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