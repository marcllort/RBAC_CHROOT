#!/bin/bash


user=$1
rol=$2
JAIL=/users/$rol/$user

JAIL_BIN=$JAIL/bin/
CONFIG=/users/config
CONFIGBASE=/users

arrayProgrames=0
direccioBashrc=0
tempsEntorn="connexio"
tempsHome="persistent"

function remove()
{
    JAIL=/users/$rol/$user
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
				
				echo "bash envia.sh borraEntorn" >> "$JAIL/home/$user/.bash_logout"
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
				#direccio="$(locate $user | head -n 1)"
				#updatedb
				#echo "La direccio de user es: $direccio/.bash_logout"
				echo "bash envia.sh borraHome" >> "$JAIL/home/$user/.bash_logout"
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
				
			fi
			;;
		
	esac
}

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

            *)
                ;;
        esac
        i=$((i+1))
    done < "$CONFIGBASE/configuracio"
}

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



function copiaProgrames()
{   
    mkdir -p $JAIL/home/$user>/mail/inbox/{tmp,new,cur}
    chmod -R 755 $JAIL/home/$user>/mail

    copy_binary whoami
    copy_binary groups
	copy_binary vi
	copy_binary cat
	copy_binary clear
	copy_binary rm
	copy_binary rmdir
    copy_binary netcat
    
    for element in "${arrayProgrames[@]}"
    do
        copy_binary "$element"
    done


    
}

function limitatempsEntorn() 
{
    if [ "$tempsEntorn" != "persistent" ]; then
        bash envia.sh "borraEntorn" | at 00:00 AM today + $tempsEntorn
    fi

    if [ "$tempsEntorn" != "connexio" ]; then
        echo "bash envia.sh borraEntorn" >> "$JAIL/home/$user/.bash_logout"
    fi
}
    
function limitatempsHome()
{
    if [ "$tempsHome" != "persistent" ]; then
        bash rbac -r $user $rol userhome | at 00:00 AM today + $tempsHome
    fi
}

function creaEnviroment()
{
    #mkdir -p $JAIL/home/$user
    mkdir -p $JAIL/
    mkdir -p $JAIL/{dev,etc,lib,lib64,usr/bin,usr/sbin,bin}
    mknod -m 666 $JAIL/dev/null c 1 3

    cd $JAIL/etc
    cp /etc/ld.so.cache .
    cp /etc/ld.so.conf .
    cp /etc/nsswitch.conf .
    cp /etc/passwd .
    cp /etc/group .
    cp /etc/shadow .
    cp /etc/hosts .
    cp /etc/resolv.conf .

    cp -r /lib $JAIL/

    
    
    
    #if [ -d $JAIL/home/$user/.ssh ]; then          #pel cas on no s'aguanta el home
     #   cp -r $JAIL/home/$user/.ssh $JAIL
      #  mkdir -p $JAIL/.ssh
       # rm -rf $JAIL/home
    #fi

    #echo "Copying skel files..."
    #mkdir -p $JAIL/home/
    #cp -r $direccioBashrc $JAIL/home/$user
    #cp -r $JAIL/.ssh $JAIL/home/$user
    #chown $user: $JAIL/home/$user/.* ! ssh

    cp $CONFIG/gestioEntorn $JAIL/home/$user
    cp $CONFIG/$rol $JAIL/
    cp $CONFIGBASE/configuracio $JAIL/

    chown root.root $JAIL/
	chown $user: $JAIL/home/$user
    chmod 755 $JAIL/home/$user/gestioEntorn

    case "$rol" in
        datastore)
            limitatempsEntorn
            limitatempsHome
            ;;
        
        advanced)
            copiaProgrames
            ;;
         
        *)
            copiaProgrames
            limitatempsEntorn
            limitatempsHome
 
	esac

}




if [ -f "$JAIL/configuracio" ]
then
    echo "$JAIL/configuracio"
	echo "Loading existing environment..."
else
	
	
    if [ "$1" = "remove" ]
    then
        user="$2"
        function="$3"
        fraseGroups="groups $user"
        grups="$($fraseGroups)"
        array=( $grups )
        rol="${array[3]}"
        echo "Deleting environment... USER: $user - $rol function: $function"


        remove
    else
        user=$1
        rol=$2
        echo "Creating environment..."
        llegeixDirConfig    
        llegeixConfig
        creaEnviroment

        #chroot --userspec=$user:$rol $JAIL/
    fi
fi