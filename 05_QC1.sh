#!/bin/bash

set -eu

#flye_dir=/data/zool-ohb/jmunoz/dorado/pod5-test/output/ONT_prmithione/pod5_21_08_2023/flye_6644883
#medaka_dir=/data/zool-ohb/zool2552/ONT_prmithione/output_test/medaka_6651170
flye_dir=/data/biol-covid19-dri/zool2552/burn1_output/flye-output-7553619
medaka_dir=/data/biol-covid19-dri/zool2552/burn1_output/medaka-output-7553619

#
# Create file one with Flye stats
#
QC1=assembly_info_test_`date +'%Y%m%d-%H%M%S'`.tsv
rm -f $QC1
echo -e "barcode\t#seq_name\tlength\tcov.\tcirc.\trepeat\tmult.\talt_group\tgraph_path" > $QC1

#printf "barcode number\tFinished?\tNumber of Contigs\n"
for dir in $flye_dir/barcode*
do
    barcode=`basename $dir`
    assembly_exists=Failed
    number_of_contigs=0
    if [[ -f $dir/assembly_info.txt ]]; then
        assembly_exists=OK
        number_of_contigs=`grep contig $dir/assembly.fasta | wc -l`
        tail -n +2 $dir/assembly_info.txt | sed "s/^/$barcode\\t/" >> $QC1
    fi 

    #printf "%14s\t%9s\t%17d\n" `basename $dir` $assembly_exists $number_of_contigs
done
echo Flye stats saved in $QC1

#
# Create file two with Medaka stats
#
QC1=consensus_info_`date +'%Y%m%d-%H%M%S'`.csv
rm -f $QC1
echo "isolate ID, Genome size (MB), Number of contigs" > $QC1

for dir in `ls -d $medaka_dir/barcode*`
do
    barcode=`basename $dir`
    consensus_exists=Failed
    number_of_contigs=0
    genome_size=0
    file=$dir/${barcode}.consensus.fasta
    if [[ -f $file ]]; then
        consensus_exists=OK
        number_of_contigs=`grep contig $file | wc -l`
        genome_size=`stat --printf="%s" $file`
        genome_size=`echo $(( $( stat -c '%s' $file ) /1024/1024))`
    fi 

    printf "%s,%s,%d\n" $barcode $genome_size $number_of_contigs >> $QC1
done
echo Medaka stats saved in $QC1
