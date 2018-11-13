#!/bin/bash

#echo "visitor2-crea" | netcat localhost 4444 -w0
#echo "$(whoami)-$1"
netcat localhost 4444 -w0<<END
$(whoami)-$1
END


netcat localhost 4444 -w0<<END
$(whoami)-chroot
END

/bin/bash