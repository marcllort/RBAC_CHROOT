#!/bin/bash
while [ true ]; do
    mailmessage="$(netcat -l 5555)"

    touch message.txt
    echo "$mailmessage" > message.txt

    admin=$(cat /users/configuracio | tail -n1)

    sendmail $admin < message.txt

    rm message.txt
done