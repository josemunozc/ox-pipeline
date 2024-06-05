#!/bin/bash

set -eu

SOURCEDIR=/data/biol-covid19-dri/zool2552/burn1_output/medaka-output-7553619
DESTDIR=/data/biol-covid19-dri/zool2552/burn1_output/burn1_fasta


for line in `awk 'NR>1{print $1}' 07_rename_fasta.csv`; do 
    original_file=`echo $line | sed 's/,.*//'`
    renamed_file=`echo $line | sed 's/.*,//'`
    renamed_file=$renamed_file.fasta
    echo $original_file $renamed_file
    (find $SOURCEDIR -name "$original_file" -exec cp "{}" $DESTDIR/$renamed_file \;) || (echo Error, file $original_file not found && exit 1)
done
