#!/bin/bash


#FUNCIONS

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
            
            2)
                PORTroot="$line"
                ;;
            3)
                PORTmail="$line"
                ;;

            *)
                ;;
        esac
        i=$((i+1))
    done < "/configuracio"
}

function llegeixConfig()
{
    i=0
    while read -r line; do
        case "$i" in
            0)
                IFS=',' read -r -a arrayProgrames <<< "$line"
                for element in "${arrayProgrames[@]}"
                do
                    echo "$element"
                done
                ;;
            *)  
                exit
                ;;   
        esac
        i=$((i+1))

    done < "/$rol"
}

function confirma {
	read -p "Are you sure? (Y/N)? " option
	case "$option" in
		y|Y ) 
			
			;;
		n|N ) 
			
			exit
			;;
		* ) 
			echo "gestioEntorn: $option is not an option"
			exit
			;;
	esac
}

function confirmaUser {
	read -p "Username? After typing your username you will be loged out!" username
	if [ "$username" != "$user" ];
	then
		echo "gestioEntorn: invalid confirmation."
		exit
	else
		#borra entorn i home i torna a crear entorn nomes?
		echo "Deleting user, enviroment, and home..."

	fi	

}

function clean {
	function="userhome"
	echo "Your home and enviroment will be deleted, and your session will close!"
	confirma
	confirmaUser

	bash /home/$user/.envia.sh clean
}

function reset {
	echo "Your enviroment will be reseted. It will take about 10s."
	confirma

	bash /home/$user/.envia.sh reset
}

function list {
	llegeixConfig
}

function requestCommnad {

	echo "What is your request?"
	read line
	echo -e "Subject: Request from $user \n\n $line" |netcat localhost $PORTmail -w0
	
}

function help {
	echo "Usage: gestioEntorn [COMMAND]"
	echo -e "Manage enviroment.\n"
	echo "-c, --clean-all				remove enviroment and home"
	echo "-r, --reset				remove and reload enviroment"
	echo "-l, --list-commands			show available commands "
	echo "-h, --help				show help"
	echo "--request-command	requestCommand new function, insert text after execution of command"
}	



#CONSTANTS

user="$(whoami)"
grups="$(groups)"
array=( $grups )
rol="${array[1]}"



#SCRIPT

if [ $# -lt 1 ]
then
	echo "Missing operand. Try: 'gestioEntorn --help' for more information."
fi

case "$1" in

	"-c" | "--clean-all")
		clean
		;;
	"-r" | "--reset")
		reset
		;;
	"-h" | "--help")	
		help
		;;
	"-l" | "--list-commands")
		list
		;;
	"--request-command")
		llegeixDirConfig
		requestCommnad
		;;
	*)
		echo "gestioEntorn: invalid command."
		echo "Try: 'gestioEntorn --help' for more information."
esac