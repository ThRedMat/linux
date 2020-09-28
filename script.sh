#!/bin/bash

# DARRIBAU Mathieu
# 27/09/2020
# Backup script

backup_time=$(date +%Y%m%d_%H%M)

saved_folder_path="${1}"

saved_folder="${saved_folder_path##*/}"

backup_name="${saved_folder}_${backup_time}"

tar -czf $backup_name.tar.gz --absolute-names $saved_folder_path

nbr_site1=`ls -l | grep -c site1_`
nbr_site2=`ls -l | grep -c site2_`

echo $nbr_site1
echo $nbr_site2

if [ "$nbr_site1" > 7 ]; then
        echo "ça fonctionne très bien"

fi