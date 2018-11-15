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
        bash envia.sh borraEntorn | at 00:00 AM today + $tempsEntorn
    fi

    if [ "$tempsEntorn" = "connexio" ]; then
        echo "bash envia.sh borraEntorn" >> "$JAIL/home/$user/.bash_logout"
    fi
}
    
function limitatempsHome()
{
    if [ "$tempsHome" != "persistent" ]; then
        bash envia.sh borraHome | at 00:00 AM today + $tempsHome
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

function enviroment(){
    user="$1"
    fraseGroups="groups $user"
    grups="$($fraseGroups)"
    array=( $grups )
    rol="${array[3]}"
    JAIL=/users/$rol/$user
    JAIL_BIN=$JAIL/bin/



    if [ ! -f "$JAIL/configuracio" ]
    then
        
        user="$1"
        fraseGroups="groups $user"
        grups="$($fraseGroups)"
        array=( $grups )
        rol="${array[3]}"
        echo "Creating environment... USER: $user - $rol"

        JAIL=/users/$rol/$user
        JAIL_BIN=$JAIL/bin/

        llegeixDirConfig    
        llegeixConfig
        creaEnviroment

    fi
}


if [ "$PAM_USER" = "marcllort" ]
then
  /bin/bash
else
    echo "Funcio enviroment"
    enviroment $PAM_USER
fi
exit 0