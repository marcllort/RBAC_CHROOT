#cal fer users a un dis apart i canviar path

#rm -rf /users

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


chown root.root /users/rol/

JAIL=/users/rol
JAIL_BIN=$JAIL/bin/

copy_binary()
{
	BINARY=$(which $1)

	cp $BINARY $JAIL/$BINARY

	copy_dependencies $BINARY
}

# http://www.cyberciti.biz/files/lighttpd/l2chroot.txt
copy_dependencies()
{
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

copy_binary ls
copy_binary sh
copy_binary bash
copy_binary touch
copy_binary mkdir
copy_binary rm
copy_binary vim
copy_binary nano
copy_binary whoami


copy_binary vi
copy_binary cat



userdel userJail
groupdel jailusers

cp -r /lib /users/rol/

rm -rf /users/rol/home/userJail
cp -r /etc/skel /users/rol/home/userJail

groupadd jailusers
useradd -G jailusers userJail -d /home/userJail
echo 'userJail:contra' | sudo chpasswd

chown userJail: /users/rol/home/userJail









#mount --bind /bin /users/rol/bin
#mount --bind /lib /users/rol/lib



#aqui caldra un swithc per segons tipus usuair donar uns programes o altres, limitant el bashrc https://unix.stackexchange.com/questions/90998/block-particular-command-in-linux-for-specific-user


#https://allanfeid.com/content/creating-chroot-jail-ssh-access