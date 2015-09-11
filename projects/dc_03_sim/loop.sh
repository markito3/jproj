#!/bin/sh
jproj.pl dc_03_sim submit 200
fill_in_job_details.pl dc_03_sim
jproj.pl dc_03_sim update_output /volatile/halld/data_challenge/dc_03_sim/smeared
jproj.pl dc_03_sim jput /volatile/halld/data_challenge/dc_03_sim/smeared /mss/halld/halld-scratch/data_challenge/dc_03_sim/smeared4
jproj.pl dc_03_sim update_silo /mss/halld/halld-scratch/data_challenge/dc_03_sim/smeared4
