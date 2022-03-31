#!/bin/bash

cd $(dirname $0)

export LDFLAGS="-L$(brew --prefix openssl)/lib" 
export CFLAGS="-I$(brew --prefix openssl)/include" 
export CCFLAGS="-I$(brew --prefix openssl)/include" 

echo $LDFLAGS
echo $CFLAGS

make
