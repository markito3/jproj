#!/bin/csh
limit stacksize unlimited
set run=$1
set file=$2
echo processing run $run file $file
source /home/gluex/halld/build_scripts/gluex_env_jlab.csh
hd_root --nthreads=Ncores -PPLUGINS=phys_tree,danarest bggen_hdgeant_smeared_${1}_${2}.hddm
echo ls -l
ls -l
echo copy
cp -v hd_root.root /volatile/halld/home/marki/proj/hd_root/hd_root_${run}_${file}.root
echo ==environment==
printenv
exit
