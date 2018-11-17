
JAIL=/users/$rol/$user


echo "crea" |netcat localhost 4444 -w0


netcat 127.0.0.1 4444 -w0<<END
$(whoami)-$1
END



PARTICIO= https://www.howtogeek.com/106873/how-to-use-fdisk-to-manage-partitions-on-linux/
Hem mostra que tinc tot el espai ple i no puc fer una particio per els usuaris.
Comanda= sudo fdisk /dev/sda i despres p.



SSH: Afegeix la key, pero segueix demanant la contrasneya, cal afegirla al client?
Com puc automatitzar que safegeixi sola despres de crearla, ja que si ho poso a rbac hu fa amb sudo i no marcllort
https://www.youtube.com/watch?v=vpk_1gldOAE

2FA= 
Ara falla perque tinc posats metodes auotritzacio el public key i no el tinc creat
Find the line @include common-auth and comment it out by adding a '#' character as the first character on the line. This tells PAM not to prompt for a password.


S’utilitzara nomes 2FA per al rol DataStore i la Key nom´es pel Visitor. Tots els altres, utilitzaran
els dos metodes.????????

https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04

https://systemoverlord.com/2018/03/03/openssh-two-factor-authentication-but-not-service-accounts.html

https://www.techrepublic.com/article/how-to-combine-ssh-key-authentication-and-two-factor-authentication-on-linux/

auth required pam_google_authenticator.so user=root allowed_perm=0666 secret=/users/config/.google_authenticator



find . -maxdepth 1 ! -iname home -exec rm -rf {} \;
