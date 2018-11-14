#!/bin/bash

netcat localhost 4444 -w0<<END
$(whoami)-$1
END
user="$(whoami)"

grups="$(groups)"
array=( $grups )
rol="${array[1]}"

chroot --userspec=$user:$rol /users/$rol/$user/ /bin/bash