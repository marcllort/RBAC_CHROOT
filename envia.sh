#!/bin/bash


#cal mirar si ja he fet login

netcat 127.0.0.1 4444 -w0<<END
$(whoami)-$1
END

missatge="$(whoami)-$1"
echo "$missatge" |netcat localhost 4444 -w0

user="$(whoami)"


if [ -f "/configuracio" ]
then
    echo "Benvingut $user!"
    /bin/bash
else
    echo "Loading enviroment... Try to log in again."
    exit
fi