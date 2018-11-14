#!/bin/bash

netcat 127.0.0.1 4444 -w0<<END
$(whoami)-$1
END

missatge="$(whoami)-$1"
echo "$missatge"
echo "$missatge" |netcat localhost 4444 -w0

user="$(whoami)"
grups="$(groups)"
array=( $grups )
rol="${array[1]}"
JAIL=/users/$rol/$user

if [ -f "/configuracio" ]
then
    
else
    echo "Loading enviroment... Try to log in again."
    exit
fi