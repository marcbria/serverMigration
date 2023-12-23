#!/bin/bash

journal=${1:-"demo"}

# Verificar si se ejecuta con sudo
if [ "$EUID" -ne 0 ]; then
    echo "This script needs sudo privileges. Run as follows 'sudo ./getRemoteVol.sh'"
    exit 1
fi


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
destFiles=/srv/volumes/files/${journal}
destFilesPublic=/srv/volumes/files/${journal}/public
destFilesPrivate=/srv/volumes/files/${journal}/private
destFilesConfigs=/srv/volumes/files/${journal}/config

# Testing:
# rm $destBackups -Rf
# rm $destAll -Rf
# rm $destDb -Rf
# rm $destLogs -Rf
# rm $destFiles -Rf
# rm $destConfigs -Rf

# Create the required folder structure:
mkdir ${destBackups} 		&& \
mkdir ${destAll} 			&& \
mkdir ${destDb} 			&& \
mkdir ${destLogs} 			&& \
mkdir ${destFiles} 			&& \
mkdir ${destFilesPublic} 	&& \
mkdir ${destFilesPrivate} 	&& \
mkdir ${destFilesConfigs} 

# Pulls the DB dumps and place them on migration folder
## rsync -avzh -e ssh ${remoteUsr}@adacar:/srv/volumes/${journal}/logs ${destLogs}
echo "rsync -avzh --rsync-path='sudo rsync' ${remoteUsr}@adacar:${srcBackups} ${destBackups}"
rsync -avzh -e "ssh -i ${privateKeyPath}" --rsync-path="sudo rsync" ${remoteUsr}@adacar:${srcBackups} ${destBackups}
ln -s ${destBackups} ${destAll}/migration

# Pulls the files
rsync -avzh -e "ssh -i ${privateKeyPath}" --rsync-path="sudo rsync" ${remoteUsr}@adacar:${srcDb} ${destDb}
ln -s ${destDb} ${destAll}/db

rsync -avzh -e "ssh -i ${privateKeyPath}" --rsync-path="sudo rsync" ${remoteUsr}@adacar:${srcLogs} ${destLogs}
ln -s ${destLogs} ${destAll}/logs

rsync -avzh -e "ssh -i ${privateKeyPath}" --rsync-path="sudo rsync" ${remoteUsr}@adacar:${srcFilesPublic} ${destFilesPublic}
ln -s ${destFilesPublic} ${destAll}/public

rsync -avzh -e "ssh -i ${privateKeyPath}" --rsync-path="sudo rsync" ${remoteUsr}@adacar:${srcFilesPrivate} ${destFilesPrivate}
ln -s ${destFilesPrivate} ${destAll}/private

rsync -avzh -e "ssh -i ${privateKeyPath}" --rsync-path="sudo rsync" ${remoteUsr}@adacar:${srcFilesConfigs} ${destFilesConfigs}
ln -s ${destFilesConfigs} ${destAll}/config
