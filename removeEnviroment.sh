#!/bin/bash


#FUNCIONS

function remove()
{
    JAIL=/users/$rol/$user
	case $function in
		userenviroment)
			echo "Deleting enviroment..."
			#userdel $user
			who | grep "$user"
			funciona=$?
			if [ $funciona -eq 1 ]; then
				cd $JAIL
				find . -maxdepth 1 ! -iname "$rol" ! -iname home -exec rm -rf {} \;
				echo "User deleted"
			else
				echo "User is logged in. After he logs out, user will be deleted."
				
				echo "bash /home/$user/.envia.sh borraEntornCon" >> "$JAIL/home/$user/.bash_logout"
			fi
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



#CONSTANTS

user="$2"
function="$3"

fraseGroups="groups $user"
grups="$($fraseGroups)"
array=( $grups )

rol="${array[3]}"

JAIL=/users/$rol/$user
JAIL_BIN=$JAIL/bin/


#SCRIPT

if [ "$1" = "remove" ]
then

    echo "Deleting environment... USER: $user - $rol function: $function"

    remove

fi