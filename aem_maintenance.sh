#!/bin/bash
current="$(date +'%d-%m-%Y')"
logfile="compact-$current.log"
homefolder="/data/cq/"
crxfolder="$installfolder/crx-quickstart"
oakrun="$installfolder/oak-run.jar"
PROJECT="MYPROJECT"
Env="Development"
ADMIN_EMAIL="abc@company.com, xxx@company.com"

# Shutdown AEM
printf "Shutting down AEM.\n"
$crxfolder/bin/stop
stoptime="$(date)"
echo "AEM Shutdown at: $stoptime" > $crxfolder/logs/$logfile

sleep 60

# Identifying the old checkpoints
printf "Finding old checkpoints.\n"

java -Dtar.memoryMapped=true -Xmx4g -jar $oakrun checkpoints $crxfolder/repository/segmentstore >> $crxfolder/logs/$logfile

# Delete unreferenced checkpoints
printf "Deleting the unreferenced checkpoints.\n"
j
ava -Dtar.memoryMapped=true -Xmx4g -jar $oakrun checkpoints $crxfolder/repository/segmentstore rm-unreferenced >> $crxfolder/logs/$logfile

# Executing offline compaction
printf "Running Offline compaction. Completion time depends on the size of the segmentstore.\n"

java -Dtar.memoryMapped=true -Xmx4g -jar $oakrun compact $crxfolder/repository/segmentstore >> $crxfolder/logs/$logfile


sleep 60

## Offline Copaction Completed
printf "Offline Compaction completed. Please check below for the more information:\n"
printf "$crxfolder/logs/$logfile\n"

## Start AEM
starttime="$(date)"
printf "AEM Startup in Progress.\n"
$aemfolder/bin/start
echo "AEM Startup at: $starttime" >> $crxfolder/logs/$logfile

now=`date '+%d/%m/%Y_%H:%M:%S'`

#Send Report to the people
mail -r aem-compaction@comapany.com -s "${PROJECT}: ${Env} | ${now}" "${ADMIN_EMAIL}" < ${logfile}
