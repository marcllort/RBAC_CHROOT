#!/bin/bash

echo "$(whoami)-$1" | netcat localhost 4444 -w0
#sleep 1000
#/bin/bash