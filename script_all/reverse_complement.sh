#!/bin/bash


while getopts ":p:f:r:" opt
do
    case $opt in
        p)
        path=$OPTARG
        ;;
        f)
        F_primer=$OPTARG
        ;;
        r)
        R_primer=$OPTARG
        ;;
        ?)
        echo "未知参数"
        exit 1;;
    esac
done

cd $path
mkdir -p $path"temp/temp_file/"
temp_path=$path"temp/temp_file/"
F_rev=$(echo -e ">seq\n${F_primer}" | seqkit seq -t DNA -r -p -s)
R_rev=$(echo -e ">seq\n${R_primer}" | seqkit seq -t DNA -r -p -s)
F_count=$(echo "$F_primer" | grep -o '[A-Za-z]' | wc -l)
R_count=$(echo "$R_primer" | grep -o '[A-Za-z]' | wc -l)

echo "$F_rev $R_rev $F_count $R_count" > $temp_path'DNA_reverse_complement_output.txt'
