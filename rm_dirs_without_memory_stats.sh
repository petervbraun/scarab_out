#!/bin/bash

# This ONLY finds folders that follow the format *M_UC*
unfinished_runs=`find . -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*' -path '*M_UC*' '!' -exec test -e "{}/memory.stat.0.out" ';' -exec echo {} +`
echo $unfinished_runs

if [ "$#" -lt 1 ]; then
    rm -r $unfinished_runs
else
    echo Dry Run
fi

