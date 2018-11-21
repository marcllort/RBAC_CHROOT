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
    done < "/configuracio"
}


llegeixDirConfig

netcat 127.0.0.1 $PORTroot -w0<<END
$(whoami)-$1
END