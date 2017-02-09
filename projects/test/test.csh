echo processing project $project run $run file $file
date > outA.dat
date > outB.dat
date > outC.dat
mkdir -p $outputFileDir_typeA
mkdir -p $outputFileDir_typeB
mkdir -p $outputFileDir_typeC
cp -v outA.dat $outputFileDir_typeA/out_A_${run}_${file}.dat
cp -v outB.dat $outputFileDir_typeB/out_B_${run}_${file}.dat
cp -v outC.dat $outputFileDir_typeC/out_C_${run}_${file}.dat
exit
