#!/bin/bash

while [ true ]; do
    comanda=$(netcat -l 4444)
    
    #tractem els parametres rebuts

    IFS='-' read -r -a arrayParametres <<< "$comanda"
    
    user="${arrayParametres[0]}"
    funcio="${arrayParametres[1]}"
    fraseGroups="groups $user"
    grups="$($fraseGroups)"
    array=( $grups )
    rol="${array[3]}"


    #echo "User: $user, Rol: $rol, Funcio: $funcio"

    #rebo si vol crear o borrar, i nom dusuari, faig groups per saber el seu rol, i faig la comanda enviroment


    #CAL ENVIAR AL BACKGROUND AMB & AL FINAL DE LA FUNCIO

    echo "FUNCIO: $funcio"
    case $funcio in
        reset)
            bash /users/config/removeEnviroment remove $user userenviroment
            
            bash /users/config/enviroment "$user" &
            ;;
        borraHomeCon)
            #Mata proces bin bash de user i fa el bash
            pkill -U $user
            bash /users/config/removeEnviroment remove $user userhome &
            ;;
        borraEntorn)
            bash /users/config/removeEnviroment remove $user userenviroment &
            ;;
        borraHome)
            bash /users/config/removeEnviroment remove $user userhome &
            ;;
    esac
    
done
