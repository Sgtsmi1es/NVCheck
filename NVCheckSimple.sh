#!/bin/bash
# This script was created to fix the plex docker not launching when backups or restarts are run
echo "************ "$(date -u)" NVCheck Simple ************"  | tee -a ~/logs/NVCheck.log
echo $(date -u) "Checking if Plex Docker is running..."  | tee -a ~/logs/NVCheck.log
if docker inspect -f '{{.State.Running}}' plex | grep -q 'true'; # This loop checks the running status of the plex docker and then re-runs the nvidia tag if it does not find plex running.
    then
        echo $(date -u) "Plex already started, script finished." | tee -a ~/logs/NVCheck.log
    else
        echo $(date -u) "Plex not running, running nvidia ansible tag" | tee -a ~/logs/NVCheck.log
        cd ~/cloudbox && sudo ansible-playbook cloudbox.yml --tags nvidia
        docker start plex
        echo $(date -u) "Nvidia tag run, Plex Docker start command sent, checking if Plex is running..." | tee -a ~/logs/NVCheck.log
        if docker inspect -f '{{.State.Running}}' plex | grep -q 'true'; #This checks to see if the fix worked and outputs the result.
            then
                echo $(date -u) "Plex started after the rerun of Nvidia Tag, script finished." | tee -a ~/logs/NVCheck.log
            else
                echo $(date -u) "WARNING: Plex still not running after re-running Nvidia tag, check system for faults." | tee -a ~/logs/NVCheck.log
        fi
fi
