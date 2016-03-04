#!/bin/bash
project=$1
date
echo === jproj.pl $project add ===
jproj.pl $project add
date
echo === jproj.pl $project update_auger ===
jproj.pl $project update_auger
date
echo === fill_in_job_details.pl $project ===
fill_in_job_details.pl $project
date
echo === jproj.pl $project update_output ===
jproj.pl $project update_output
date
echo === jproj.pl $project jput ===
jproj.pl $project jput
date
echo === jproj.pl $project update_silo ===
jproj.pl $project update_silo
date
echo === jproj.pl $project jcache ===
jproj.pl $project jcache
date
echo === jproj.pl $project update_cache ===
jproj.pl $project update_cache
date
echo === jproj.pl $project status ===
jproj.pl $project status
