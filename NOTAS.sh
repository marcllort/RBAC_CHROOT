

PARTICIO= https://www.howtogeek.com/106873/how-to-use-fdisk-to-manage-partitions-on-linux/
Hem mostra que tinc tot el espai ple i no puc fer una particio per els usuaris.
Comanda= sudo fdisk /dev/sda i despres p.
https://www.crucial.com.au/blog/2009/11/18/how-to-create-a-new-partition-on-a-linux-server/



2FA= 
Ara falla perque tinc posats metodes auotritzacio el public key i no el tinc creat
Find the line @include common-auth and comment it out by adding a '#' character as the first character on the line. This tells PAM not to prompt for a password.
Entra correctament si el entorn esta creat manualment.


SSH i 2FA=
Faig servir el mateix pubkey i el mateix fitxer .google_authenticator per tots, per no tenir que fer un setup cada cop que creo un usuari.



GestioEntorn=
Com ha de funcionar el clean-all: Demoment el faig fora i borro tot, ja es creara quan faci login


Enunviat diu indicar problema en cas derror alhora de crear entorn, com hu faig si hu executa el pam?


Fallen comandes: vim, ps, awk, strace


cp -r /usr/lib /users/medium/medium1/usr/lib/








ALTRES


JAIL=/users/$rol/$user


echo "borraEntorn" |netcat localhost 4444 -w0


netcat 127.0.0.1 4444 -w0<<END
$(whoami)-$1
END




echo "echo "basic1-borraEntorn" |netcat localhost 4444 -w0" >> "/users/basic/basic1/home/basic1/.bash_logout"



S’utilitzara nomes 2FA per al rol DataStore i la Key nom´es pel Visitor. Tots els altres, utilitzaran
els dos metodes.????????

https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04

https://systemoverlord.com/2018/03/03/openssh-two-factor-authentication-but-not-service-accounts.html

https://www.techrepublic.com/article/how-to-combine-ssh-key-authentication-and-two-factor-authentication-on-linux/

auth required pam_google_authenticator.so user=root allowed_perm=0666 secret=/users/config/.google_authenticator



