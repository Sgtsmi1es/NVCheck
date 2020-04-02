#!/bin/bash
# This script was created to fix the plex docker not launching when backups or restarts are run
echo "************ "$(date -u)" NVCheck ************" 
echo $(date -u) "Checking if Plex Docker is running..."
if docker inspect -f '{{.State.Running}}' plex | grep -q 'true'; # This loop checks the running status of the plex docker and then re-runs the nvidia tag if it does not find plex running.
    then
        echo $(date -u) "plex already started, script finished." >> ~/logs/NVCheck.log 2>&1
    else
        echo $(date -u) "plex not running, running nvidia ansible tag" >> ~/logs/NVCheck.log 2>&1
        cd ~/cloudbox && sudo ansible-playbook cloudbox.yml --tags nvidia
        docker start plex
        echo $(date -u) "nvidia tag run, plex docker start command sent, checking if plex is running..." >> ~/logs/NVCheck.log 2>&1
        if docker inspect -f '{{.State.Running}}' plex | grep -q 'true'; #This checks to see if the fix worked and outputs the result.
            then
                echo $(date -u) "plex started after the rerun of nvidia Tag, script finished." >> ~/logs/NVCheck.log 2>&1
            else
                echo $(date -u) "WARNING: Plex still not running after re-runniong Nvidia tag, check system for faults." >> ~/logs/NVCheck.log 2>&1
        fi
fi
