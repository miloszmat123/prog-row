#!/bin/bash

for i in {1..100}
do
    ./radix-openmp.exe | while IFS= read -r line
    do
        if [ -z "$out1" ]; then
            out1="$line"
            echo "$out1" >> radix-sequential-random.txt
        elif [ -z "$out2" ]; then
            out2="$line"
            echo "$out2" >> radix-openmp-random.txt
        elif [ -z "$out3" ]; then
            out3="$line"
            echo "$out3" >> radix-sequential-descendnig.txt
        elif [ -z "$out4" ]; then
            out4="$line"
            echo "$out4" >> radix-openmp-descendnig.txt
        elif [ -z "$out5" ]; then
            out5="$line"
            echo "$out5" >> radix-sequential-ascending.txt
        else
            out6="$line"
            echo "$out6" >> radix-openmp-ascending.txt
        fi
    done
    unset out1 out2 out3 out4 out5 out6
done

