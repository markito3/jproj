#!/bin/sh
project=$1
fill_in_job_details.pl $project
jproj.pl $project update
jproj.pl $project update_output
jproj.pl $project update_silo
jproj.pl $project update_cache
jproj.pl $project status
