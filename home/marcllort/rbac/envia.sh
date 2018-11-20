#!/bin/bash

netcat 127.0.0.1 4444 -w0<<END
$(whoami)-$1
END