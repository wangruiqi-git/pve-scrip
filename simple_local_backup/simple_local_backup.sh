#!/bin/bash

#Directory the script is in (for later use)
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOGFILE="$SCRIPTDIR/backup.log"

# Provides the 'log' command to simultaneously log to
# STDOUT and the log file with a single command
# NOTE: Use "" rather than \n unless you want a COMPLETELY blank line (no timestamp)
log() {
    echo -e "$(date -u +%Y-%m-%d-%H%M)" "$1" >> "${LOGFILE}"
    if [ "$2" != "noecho" ]; then
        echo -e "$1"
    fi
}

Flags="-ahv --delete  --no-whole-file"

STARTTIME=$(date +%s)
log "backup start"
rsync ${Flags} /*                              /media/rootfolder/     --exclude=media --exclude=bak_media --exclude=dev  --exclude=proc --exclude=run --exclude=srv --exclude=tmp --exclude=sys --exclude=var/lib/vz/images/100 --exclude=var/lib/vz/images/102 #--exclude=var/lib/docker/overlay2
rsync ${Flags} /*                              /bak_media/rootfolder/ --exclude=media --exclude=bak_media --exclude=dev  --exclude=proc --exclude=run --exclude=srv --exclude=tmp --exclude=sys --exclude=var/lib/vz/images/100 --exclude=var/lib/vz/images/102 #--exclude=var/lib/docker/overlay2
 
rsync ${Flags} /media/app                      /bak_media/            --exclude=jellyfin 
rsync ${Flags} /media/repo                     /bak_media/
rsync ${Flags} /media/JellyfinMedia/wzy        /bak_media/JellyfinMedia/
rsync ${Flags} /media/*sys-bak.img             /bak_media/
#rsync ${Flags} /media/varlibvz                 /bak_media/

ENDTIME=$(date +%s)
DURATION=$((ENDTIME - STARTTIME))

log "backup end. cost $DURATION seconds"
