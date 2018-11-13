#!/bin/bash



function confirma {
	read -p "Continue (Y/N)? " option
	case "$option" in
		y|Y ) 
			echo "yes"
			if [ "$function" = "userenviroment" ];
			then
				echo "remove $function"
				#enviroment remove $user $function
				echo "creaEnviroment" #cal cridar dimoni de crear envirmoment
				#environment $user $rol
			fi
			;;
		n|N ) 
			echo "no"
			exit
			;;
		* ) 
			echo "gestioEntorn: $option is not an option"
			exit
			;;
	esac
}

function confirmaUser {
	read -p "Username? " username
	if [ "$username" != "$user" ];
	then
		echo "gestioEntorn: invalid confirmation."
		exit
	else
		#borra entorn i home i torna a crear entorn nomes?
		echo "remove $function"
		#enviroment remove $user $function
	fi	

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

function clean {
	function="userhome"
	confirma
	confirmaUser
	echo "clean"
}

function reset {
	function="userenviroment"
	confirma
	echo "reset"
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

function list {
	llegeixConfig
	echo "list"
}

function requestCommnad {
	echo "What is your request?"
	read line
	echo "Subject: Request from $user /n $line" | netcat localhost 5555 -w0 
}


user="$(whoami)"

grups="$(groups)"
array=( $grups )
rol="${array[1]}"

echo "User: $user	Group: $rol"

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
		requestCommnad
		;;
	*)
		echo "gestioEntorn: invalid command."
		echo "Try: 'gestioEntorn --help' for more information."
esac
