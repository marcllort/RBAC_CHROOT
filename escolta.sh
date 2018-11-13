#!/bin/bash
while [ true ]; do
    comanda=$(netcat -l 4444)
    

    #tractem els parametres rebuts

    IFS='$' read -r -a arrayParamentres <<< "$comanda"
    
    user="${arrayProgrames[0]}"
    funcio="${arrayProgrames[1]}"
    grups="$(groups $user)"
    array=( $grups )
    rol="${array[1]}"


    echo "User: $comanda, Rol: $rol, Funcio: $funcio"

    #rebo si vol crear o borrar, i nom dusuari, faig groups per saber el seu rol, i faig la comanda enviroment
    case $funcio
        crea)
            bash /users/config/enviroment $user $rol
            ;;
        borraEntorn)
            bash /users/config/enviroment remove $user userenviroment
            ;;
        borraHome)
            bash /users/config/enviroment remove $user userhome
            ;;

    esac
    
done
