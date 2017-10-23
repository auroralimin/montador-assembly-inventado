#!/bin/bash

testdir="test"
resultdir="result"
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD=$(tput bold)
OFF='\033[0m'

echo "---------------------------------------------"
for file in ${testdir}/*.mcr; do
    name=`basename ${file} .mcr`".o"
    ./montador $file ${name} > /dev/null
    echo "${BOLD}Montando ${name}:${OFF}"
    if diff ${name} ${resultdir}/${name} 
    then
        echo "${GREEN}>>>> OK ${OFF}"
    else
        echo "${RED}>>>> FALHOU ${OFF}"
    fi
    rm ${name}
    echo "---------------------------------------------"
done

