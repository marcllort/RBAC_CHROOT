#!/bin/bash

#Cal fer users a un disc apart i canviar path



#FUNCIONS


function creaSSH()
{
    
    #mkdir -p /users/config/ssh/
    #cd /users/config/ssh
    cat <<EOT >> /users/config/ssh/$user/authorized_keys
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkl/f8igvh7Ab6SpHjR4sK6ksKmkdPPOtxcBxIFTqx/vtAX0Ohdj4GOtEUy9xsu08VajKksRTIckCyN/ByWS1nbRX8GGj4l3gFCHC+lLQPwXrvBJlSJTPRh5EjVG1ZgPmhzSMEg8V0EJHclPE5yUFF6JMvstAJ1D3Hxr18WikGxQ68G6SQ/8SuTtV2qeyEw/tLWk14WNHn02YmH7vPG1feaj6qNkWLuAJA2ygtuDN8gyjC3+IKqeWpH6TKNioNhb8TSGviwzY4AiO1cpWLhHAqN221Bafzhizt45IZjyMRaSHWeqnh+a8u+PQ6B6kW74oGl5zQxipliqrGhwEK1kc9 $userhome@MBP-de-Marc
EOT

    #chmod 755 /users/config/ssh
    #chmod 755 /users/config/ssh/authorized_keys
}


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

function afegeixConfig()
{
	cat <<EOT >> /etc/ssh/sshd_config
	
Match group $rol
        ChrootDirectory /users/$rol/%u/
        PubkeyAuthentication yes
        AuthenticationMethods publickey,keyboard-interactive
EOT

	systemctl restart ssh
}


function checkGroup()
{

	if grep -q $rol /etc/group
	then
		echo "Rol existent..."
	else
		echo "Rol NO existent..."
		
		if [ -f "/users/config/$rol" ]
		then
			echo "Vols crear aquest rol? Respon amb 'y' o 'n'"
			read resposta

			case "$resposta" in
				y|Y)
					groupadd "$rol"
					#cal afegir el match group a /etc/ssh/sshd_config
					afegeixConfig
					;;

				n|N)
					exit 1
					;;

				*)
					echo "La resposta no es possible, respon amb 'y' o 'n'"

			esac
		else
			exit 1
		fi

	fi

}

function creaUser()
{
	#Miro si ja existeix usuari
	if getent passwd $user > /dev/null 2>&1; then
		echo "User already exists!"
	else
		
		useradd -G $rol $user -d /home/$user		

		mkdir -p /users/config/ssh/$user/
		chown $user /users/config/ssh/$user
		touch /users/config/ssh/$user/authorized_keys

		mkdir -p /users/config/googleauth/$user
		


		#Poso ssh a la home
		mkdir -p $JAIL
		#chown $user $JAIL/home/$user/.ssh		#Cal fer per quan es crei el ssh key
		#chmod 755 $JAIL/home/$user/.ssh			#prova

		runuser -l $user -s /bin/sh -c "ssh-keygen -t rsa -b 2048 -f /users/config/ssh/$user/$user-key -N ''"


		google-authenticator -s /users/config/googleauth/$user/.google_authenticator -t -q -d -f -u -w 3


		cat /users/config/ssh/$user/$user-key.pub >> /users/config/ssh/$user/authorized_keys

		#Donem propietat del home al usuari
		

		#Posem fitxer de configuració del rol determinat
		cp $CONFIG/$rol $JAIL/

		

	fi
	
}


function remove()
{
    JAIL=/users/$rol/$user
	case $function in
		userenviroment)
			echo "Deleting enviroment..."
			#userdel $user
			
			cd $JAIL
			find . -maxdepth 1 ! -iname "$rol" ! -iname home -exec rm -rf {} \;
			echo "User deleted"
			
			;;

		userhome)
			echo "Deleting home..."
			#userdel $user
			who | grep "$user"
			funciona=$?
			if [ $funciona -eq 1 ]; then
				rm -rf $JAIL/home/$user
				echo "User deleted"
			else
				echo "User is logged in. After he logs out, user will be deleted."
				#direccio="$(locate $user | head -n 1)"
				#updatedb
				#echo "La direccio de user es: $direccio/.bash_logout"
				echo "bash /home/$user/.envia.sh borraHomeCon" >> "$JAIL/home/$user/.bash_logout"
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
		checkGroup
		llegeixConfig
		creaUser
		creaSSH
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