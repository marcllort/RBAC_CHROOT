#!/bin/bash


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
            
            2)
                PORTroot="$line"
                ;;
            3)
                PORTmail="$line"
                ;;

            *)
                ;;
        esac
        i=$((i+1))
    done < "$CONFIGBASE/configuracio"
}



CONFIGBASE=/users

llegeixDirConfig
echo "$PORTmail"

while [ true ]; do
    mailmessage="$(netcat -l $PORTmail)"

    echo "$mailmessage"

    touch message.txt
    echo "$mailmessage" > message.txt

    admin=$(sed "2q;d" /users/configuracio)

    sendmail $admin < message.txt &

    rm message.txt
done