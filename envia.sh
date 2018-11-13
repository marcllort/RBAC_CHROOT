#!/bin/bash

netcat localhost 4444 <<END
$1
exit
END