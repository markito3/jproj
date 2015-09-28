#!/bin/csh
limit stacksize unlimited
set project=$1
set run=$2
set file=$3
echo processing project $project run $run file $file
date > out.dat
set out_dir=/volatile/halld/home/marki/proj/$project/out
mkdir -p $out_dir
cp -v out.dat $out_dir/out_${run}_${file}.dat
exit
