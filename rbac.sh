#!/bin/bash

#Cal fer users a un disc apart i canviar path



#FUNCIONS


function llegeixConfig()
{
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

    done < "$CONFIG/$rol"
}


function creaUser()
{
	#Miro si ja existeix usuari
	if getent passwd $user > /dev/null 2>&1; then
		echo "User already exists!"
	else
		
		useradd -G $rol $user -d /home/$user
		echo "$user:contra" | sudo chpasswd      #Cal fer key sense passphrase ni password
		
		#Poso skel a la home
		mkdir -p $JAIL/home
		cp -r $direccioBashrc $JAIL/home/$user
		

		#Poso ssh a la home
		mkdir -p $JAIL/home/$user/.ssh
		chown $user $JAIL/home/$user/.ssh		#Cal fer per quan es crei el ssh key
		chmod 755 $JAIL/home/$user/.ssh			#prova

		runuser -l $user -s /bin/sh -c "ssh-keygen -t rsa -b 2048 -f $JAIL/home/$user/.ssh/$user-key -N ''"
		#ssh-keygen -t rsa -b 2048 -f ~/.ssh/$user-key -P "$CONTRA"
		#sudo runuser -l visitor2 -s /bin/sh -c 'ssh-keygen -b 2048 -f /users/visitor/visitor2/home/visitor2/.ssh/visitor2-key -P "prova"'

		#Donem propietat del home al usuari
		chown $user: $JAIL/home/$user

		#Posem fitxer de configuració del rol determinat
		cp $CONFIG/$rol $JAIL/

		#Posem fitxer de enviar comandes al dimoniRoot
		cp /users/config/envia.sh $JAIL/home/$user
		chmod 755 $JAIL/home/$user/envia.sh

	fi
	
}


function remove()
{
	case $function in
		userenviroment)
			echo "Deleting enviroment..."
			userdel $user
			
			funciona=$?
			if [ $funciona -eq 0 ]; then
				cd $JAIL
				rm -rf !home
				echo "User deleted"
			else
				echo "User is logged in. After he logs out, user will be deleted."
				
				echo "bash envia.sh borraEntornCon" >> "$JAIL/home/$user/.bash_logout"
			fi
			;;

		userhome)
			echo "Deleting home..."
			userdel $user
			
			funciona=$?
			if [ $funciona -eq 0 ]; then
				rm -rf $JAIL/home/$user
				echo "User deleted"
			else
				echo "User is logged in. After he logs out, user will be deleted."
			
				echo "bash envia.sh borraHomeCon" >> "$JAIL/home/$user/.bash_logout"
			fi
			;;

		*)
			echo "Deleting user..."
			userdel $user
			funciona=$?
			if [ $funciona -eq 0 ]; then
				echo "User deleted"
			else
				echo "User is logged in."
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



#CONSTANTS


function=$1
user=$2
rol=$3
deleteTipus=$4
direccioBashrc=0

JAIL=/users/$rol/$user
JAIL_BIN=$JAIL/bin/
CONFIG=/users/config



#SCRIPT

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
		remove $deleteTipus
		;;
	"-h" | "--help")	
		help
		;;
	*)
		echo "rbac: invalid command."
		echo "Try: 'rbac --help' for more information."

esac