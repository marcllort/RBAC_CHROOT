#!/bin/bash

#cal fer users a un disc apart i canviar path


function=$1
rol=$3
user=$2


function creaUser()
{
	#mirar si ja existeix usuari
	if getent passwd $user > /dev/null 2>&1; then
		echo "User already exists!"
	else
		
		useradd -G $rol $user -d /home/$user
		echo "$user:contra" | sudo chpasswd      #cal fer KEY
		mkdir -p /users/$rol/$user/
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
				echo "userdel $user && rm -rf $direccio" >> "$direccio/.bash_logout"
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