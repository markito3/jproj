#!/bin/sh
jproj.pl dc_03_recon submit 100
fill_in_job_details.pl dc_03_recon
jproj.pl dc_03_recon update_output /volatile/halld/data_challenge/dc_03_recon/rest
jproj.pl dc_03_recon jput /volatile/halld/data_challenge/dc_03_recon/rest /mss/halld/halld-scratch/data_challenge/dc_03_recon/rest2
jproj.pl dc_03_recon update_silo /mss/halld/halld-scratch/data_challenge/dc_03_recon/rest2
