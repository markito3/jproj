#!/bin/sh
jproj.pl dc_03_swif submit 100
fill_in_job_details.pl dc_03_swif
jproj.pl dc_03_swif update_output /volatile/halld/data_challenge/dc_03_swif/rest
jproj.pl dc_03_swif jput /volatile/halld/data_challenge/dc_03_swif/rest /mss/halld/halld-scratch/data_challenge/dc_03_swif/rest2
jproj.pl dc_03_swif update_silo /mss/halld/halld-scratch/data_challenge/dc_03_swif/rest2
