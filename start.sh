#!/bin/sh

#wget the current all the mods 9 server from curseforge website
wget -P /srv/ https://www.curseforge.com/api/v1/mods/715572/files/4953500/download

#unzip the server file
unzip /srv/download -d /srv/

#get the serverfile directory name and store it in a variable
serverdirectory=$(ls /srv | grep "Server-Files")

#give any .sh file in the server directory execute permissions                set the full length of the directory, it is not complete
chmod +x /srv/$serverdirectory/*.sh

# this script will serve to start the server upon conatiner start
#set these as environment variables for docker so user can control ram alocation

min_heapsize=5
max_heapsize=8

#create eula text file    set the full length of the directory, it is not complete

#get the serverfile directory name and store it in a variable
serverdirectory=$(ls /srv | grep "Server-Files")

#create Eula.txt to then later accept
touch /srv/$serverdirectory/eula.txt

#accept eula (maybe)      set the full length of the directory, it is not complete
echo > /srv/$serverdirectory/eula.txt "eula=true"

# default command arguments for the user_jvm text file within the server directory
echo > /srv/$serverdirectory/user_jvm_args.txt \
"#THIS IS THE ARGUMENTS USED BY ATM 9 IN THE ARG FILE


-Xms"$min_heapsize"G
-Xmx"$max_heapsize"G
-XX:+UseG1GC
-XX:+ParallelRefProcEnabled
-XX:MaxGCPauseMillis=200
-XX:+UnlockExperimentalVMOptions
-XX:+DisableExplicitGC
-XX:+AlwaysPreTouch
-XX:G1NewSizePercent=30
-XX:G1MaxNewSizePercent=40
-XX:G1HeapRegionSize=8M
-XX:G1ReservePercent=20
-XX:G1HeapWastePercent=5
-XX:G1MixedGCCountTarget=4
-XX:InitiatingHeapOccupancyPercent=15
-XX:G1MixedGCLiveThresholdPercent=90
-XX:G1RSetUpdatingPauseTimePercent=5
-XX:SurvivorRatio=32
-XX:+PerfDisableSharedMem
-XX:MaxTenuringThreshold=1"

#start the minecraft server
/srv/$serverdirectory/startserver.sh