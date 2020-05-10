#!/bin/bash
# This script was created to fix the plex docker not launching when backups or restarts are run
echo "************ "$(date -u)" Backup starting ************" | tee -a ~/logs/NVCheck.log
echo $(date -u) "Running backup script" | tee -a ~/logs/NVCheck.log # This states that the backup script is running
cd ~/cloudbox && sudo ansible-playbook cloudbox.yml --tags backup 
echo $(date -u) "Backup Complete, checking if Plex Docker is running..." | tee -a ~/logs/NVCheck.log
if docker inspect -f '{{.State.Running}}' plex | grep -q 'true'; # This loop checks the running status of the plex docker and then re-runs the nvidia tag if it does not find plex running.
    then
        echo $(date -u) "plex already started, script finished." | tee -a ~/logs/NVCheck.log
    else
        echo $(date -u) "plex not running, running nvidia ansible tag" | tee -a ~/logs/NVCheck.log
        cd ~/cloudbox && sudo ansible-playbook cloudbox.yml --tags nvidia
        docker start plex
        echo $(date -u) "nvidia tag run, plex docker start command sent, checking if plex is running..." | tee -a ~/logs/NVCheck.log
        if docker inspect -f '{{.State.Running}}' plex | grep -q 'true'; #This checks to see if the fix worked and outputs the result.
            then
                echo $(date -u) "plex started after the rerun of nvidia Tag, script finished." | tee -a ~/logs/NVCheck.log
            else
                echo $(date -u) "WARNING: Plex not running, check system for faults." | tee -a ~/logs/NVCheck.log
        fi
fi
