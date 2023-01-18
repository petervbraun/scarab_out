#!/bin/bash

unfinished_runs=`find . -mindepth 1 -maxdepth 2 -type d '!' -exec test -e "{}/memory.stat.0.out" ';' -exec echo {} +`
echo $unfinished_runs

if [ "$#" -lt 1 ]; then
    rm -r $unfinished_runs
else
    echo Dry Run
fi

