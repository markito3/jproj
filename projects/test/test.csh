#!/bin/csh
limit stacksize unlimited
set project=$1
set run=$2
set file=$3
echo processing project $project run $run file $file
date > outA.dat
date > outB.dat
date > outC.dat
set out_dir_A=/volatile/halld/home/marki/proj/$project/typeA
set out_dir_B=/volatile/halld/home/marki/proj/$project/typeB
set out_dir_C=/volatile/halld/home/marki/proj/$project/typeC
mkdir -p $out_dir_A
mkdir -p $out_dir_B
mkdir -p $out_dir_C
cp -v outA.dat $out_dir_A/out_A_${run}_${file}.dat
cp -v outB.dat $out_dir_B/out_B_${run}_${file}.dat
cp -v outC.dat $out_dir_C/out_C_${run}_${file}.dat
exit
