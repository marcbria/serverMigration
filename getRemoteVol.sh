#!/bin/bash

journal=${1:-"demo"}

echo "Gets the volumes of the specified journal from the remote server"

# Verificar si se ejecuta con sudo
if [ "$EUID" -ne 0 ]; then
    echo "This script needs sudo privileges. Run as follows 'sudo ./getRemoteVol.sh'"
    exit 1
fi

startTime=$(date +%s)

## CONFIG VARIABLES

# Remote user (need the proper privileges in the remote machine)
remoteUsr=marc

privateKeyPath=/home/${remoteUsr}/.ssh/id_rsa

# Setting local folders:
srcBackups=/srv/backup/duplicati/db-dump/*${journal}*
srcAll=/srv/volumes/${journal}
srcDb=/srv/volumes/${journal}/db
srcLogs=/srv/volumes/${journal}/logs
srcFiles=/srv/volumes/${journal}/files
srcFilesPublic=/srv/volumes/${journal}/public
srcFilesPrivate=/srv/volumes/${journal}/private
srcFilesConfigs=/srv/volumes/${journal}/config

destBackups=/srv/backups/${journal}
destAll=/srv/volumes/all/${journal}
destDb=/srv/volumes/db/${journal}
destLogs=/srv/volumes/logs/${journal}
destFiles=/srv/volumes/files
destFilesPublic=${destFiles}/public/${journal}
destFilesPrivate=${destFiles}/private/${journal}
destFilesConfigs=${destFiles}/config/${journal}

# Debug:
## rm $destBackups/${journal} -Rf
## rm $destDb/${journal} -Rf
## rm $destLogs/${journal} -Rf
## rm $destFiles/${journal} -Rf
## rm $destConfigs/${journal} -Rf
## rm $destAll/${journal} -Rf

echo "Ensures the required folder structure exists"
mkdir ${destBackups}        > /dev/null 2>&1
mkdir ${destAll}            > /dev/null 2>&1
mkdir ${destDb}             > /dev/null 2>&1
mkdir ${destLogs}           > /dev/null 2>&1
mkdir ${destFiles}          > /dev/null 2>&1
mkdir ${destFilesPublic}    > /dev/null 2>&1
mkdir ${destFilesPrivate}   > /dev/null 2>&1
mkdir ${destFilesConfigs}   > /dev/null 2>&1

# Pulls the DB dumps and place them on migration folder
# Notice:
# Locally this script need to be sudoer. Not asked here because the script is.
# Remotelly rsync needs sudo to reach all files. rsync-path parameter adds sudo privileges.
# We need to exchange keys to avoid asking passwords all the time.
# Final slash in srcVars indicate we like to copy the content (not the folder).

echo "--> Rsyncing: ${srcBackups}"
rsync -avzh -e "ssh -i ${privateKeyPath}" --rsync-path="sudo rsync" ${remoteUsr}@adacar:${srcBackups} ${destBackups}
unlink ${destAll}/migration
ln -s ${destBackups} ${destAll}/migration

# Pulls the db/Log/files
echo "--> Rsyncing: ${srcDb}"
rsync -avzh -e "ssh -i ${privateKeyPath}" --rsync-path="sudo rsync" ${remoteUsr}@adacar:${srcDb}/ ${destDb}
unlink ${destAll}/db
ln -s ${destDb} ${destAll}/db

echo "--> Rsyncing ${srcLogs}"
rsync -avzh -e "ssh -i ${privateKeyPath}" --rsync-path="sudo rsync" ${remoteUsr}@adacar:${srcLogs}/ ${destLogs}
unlink ${destAll}/logs
ln -s ${destLogs} ${destAll}/logs

echo "--> Rsyncing ${srcFilesPublic}"
echo "rsync -avzh -e \"ssh -i ${privateKeyPath}\" --rsync-path=\"sudo rsync\" ${remoteUsr}@adacar:${srcFilesPublic}/ ${destFilesPublic}"
rsync -avzh -e "ssh -i ${privateKeyPath}" --rsync-path="sudo rsync" ${remoteUsr}@adacar:${srcFilesPublic}/ ${destFilesPublic}
unlink ${destAll}/public
ln -s ${destFilesPublic} ${destAll}/public

echo "--> Rsyncing ${srcFilesPrivate}"
rsync -avzh -e "ssh -i ${privateKeyPath}" --rsync-path="sudo rsync" ${remoteUsr}@adacar:${srcFilesPrivate}/ ${destFilesPrivate}
unlink ${destAll}/private
ln -s ${destFilesPrivate} ${destAll}/private

echo "--> Rsyncing ${srcFilesConfig}"
rsync -avzh -e "ssh -i ${privateKeyPath}" --rsync-path="sudo rsync" ${remoteUsr}@adacar:${srcFilesConfigs}/ ${destFilesConfigs}
unlink ${destAll}/config
ln -s ${destFilesConfigs} ${destAll}/config

endTime=$(date +%s)

# Calcula el tiempo transcurrido
elapsedTime=$((endTime - startTime))
formattedTime=$(date -u -d @"$elapsedTime" +'%H:%M:%S')

echo ">>>> La còpia de los volúmenes de $journal ha tardado: $formattedTime"
