
JAIL=/users/$rol/$user


echo "crea" |netcat localhost 4444 -w0


netcat 127.0.0.1 4444 -w0<<END
$(whoami)-$1
END



PARTICIO= https://www.howtogeek.com/106873/how-to-use-fdisk-to-manage-partitions-on-linux/