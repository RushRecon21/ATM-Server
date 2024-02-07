#!/bin/bash


function create_server() {          #this function will download and unzip contents of the server in the /srv directory

    if [ ! -d "/config/Minecraft_Server" ]; then

        #wget the current all the mods 9 server from curseforge website
        wget -P /srv/ $downloadlink 
        
        #unzip the server file
        unzip -q /srv/download -d /srv/

        #get the serverfile directory name and store it in a variable
        serverdirectory=$(ls /srv | grep "Server-Files")

        #store the server version for the update function
        echo > /srv/$serverdirectory/version.txt "$serverdirectory"
    
        #rename the unzipped folder to Minecraft_Server
        mv /srv/$serverdirectory /srv/Minecraft_Server/

        #update the serverdirectory variable
        serverdirectory=/config/Minecraft_Server

        #move files into working directory
        mv /srv/Minecraft_Server /config

        #give any .sh file in the server directory execute permissions
        chmod +x $serverdirectory/*.sh

        #cleanup after install 
        cleanup

    else
        echo "server files already exist checking for updates"
        
        #set the server variable for later use
        serverdirectory=/config/Minecraft_Server
        #run the update function
        update
    fi
}

function server_variables() {          #this function will serve the purpose of letting the user change ram alocation, server name, etc...


    if [ -z  "$min_heap" ]; then        #this if statement will use -z to check if the lenth of the string is 0 and if it is, return true and set min_heap to 4

        echo "No minimum heap size is set, defaulting to 4GB"
        min_heap=4

    else

        echo "Minimum heap size is set to "$min_heap"GB"

    fi


    if [ -z  "$max_heap" ]; then       #this if statement will use -z to check if the lenth of the string is 0 and if it is, return true and set mix_heap to 8

        echo "No maximum heap size is set, defaulting to 8GB"
        max_heap=8

    else

        echo "Maximum heap size is set to "$max_heap"GB"

    fi


    if [ -f $serverdirectory/eula.txt ]; then       #if eula exists. then accpet eula and set it to true

        #set eula to true
        echo "eula.txt exists, setting it to true"
        echo > $serverdirectory/eula.txt "eula=true"

    else

        #if file does not exist create it then set it to true
        echo "eula.txt does not exist, creating it and setting it to true"
        touch $serverdirectory/eula.txt
        echo > $serverdirectory/eula.txt "eula=true"

    fi


    if [ -f $serverdirectory/user_jvm_args.txt ]; then   # if user_jvm_args.txt echo in the variables else create it and echo in the variables

        #set the variables for the user_jvm_args file                                                           
        echo "user_jvm_args.txt does exist, setting variables now"    
        # default command arguments for the user_jvm text file within the server directory using the jvm_args function
        jvm_args
        
    else                                            
        echo "user_jvmm_args.txt doesn not exist, creating it and setting variables"
        touch $serverdirectory/user_jvm_args.txt
        # default command arguments for the user_jvm text file within the server directory using the jvm_args function
        jvm_args
    fi
}

function jvm_args(){

    printf "%s\n" \
    "#THIS IS THE ARGUMENTS USED BY ATM 9 IN THE ARG FILE"\
    "# Xmx and Xms set the maximum and minimum RAM usage, respectively."\
    "# They can take any number, followed by an M or a G."\
    "# M means Megabyte, G means Gigabyte."\
    "# For example, to set the maximum to 3GB: -Xmx3G"\
    "# To set the minimum to 2.5GB: -Xms2500M"\
    "# A good default for a modded server is 4GB."\
    ""\
    ""\
    "-Xms"$min_heap"G"\
    "-Xmx"$max_heap"G"\
    "-XX:+UseG1GC"\
    "-XX:+ParallelRefProcEnabled"\
    "-XX:MaxGCPauseMillis=200"\
    "-XX:+UnlockExperimentalVMOptions"\
    "-XX:+DisableExplicitGC"\
    "-XX:+AlwaysPreTouch"\
    "-XX:G1NewSizePercent=30"\
    "-XX:G1MaxNewSizePercent=40"\
    "-XX:G1HeapRegionSize=8M"\
    "-XX:G1ReservePercent=20"\
    "-XX:G1HeapWastePercent=5"\
    "-XX:G1MixedGCCountTarget=4"\
    "-XX:InitiatingHeapOccupancyPercent=15"\
    "-XX:G1MixedGCLiveThresholdPercent=90"\
    "-XX:G1RSetUpdatingPauseTimePercent=5"\
    "-XX:SurvivorRatio=32"\
    "-XX:+PerfDisableSharedMem"\
    "-XX:MaxTenuringThreshold=1"\
    > $serverdirectory/user_jvm_args.txt
}

function update(){

    # set a variable that contains the version of the server from the link using curl and grep
    version=$(curl -s $downloadlink | grep -E -o ".{0}Server-Files.{7}")
    if [ "$version" == $(<$serverdirectory/version.txt) ]; then
        #grab the file name of the current server files and store it?
        echo "server is already running version $version"
    else

        echo "server is not up to date, updating existing server files"
        
        #remove the old files from the /config directory
        rm -r $serverdirectory/config $serverdirectory/defaultconfigs $serverdirectory/mods $serverdirectory/kubejs $serverdirectory/libraries $serverdirectory/startserver.sh

        #use xargs and grep to remove the forge files
        find /config/Minecraft_Server -maxdepth 1 | grep "installer" | xargs rm

        #download updated server files
        wget -P /srv/ $downloadlink

        #unzip the server file
        unzip -q /srv/download -d /srv/

        #get the serverfile directory name and store it in a variable
        updatedirectory=$(ls /srv | grep "Server-Files")

        #store the server version for the update function
        echo > $serverdirectory/version.txt "$updatedirectory"

        #move the updated files to the existing server location
        mv /srv/$updatedirectory/config /srv/$updatedirectory/defaultconfigs /srv/$updatedirectory/mods /srv/$updatedirectory/kubejs /srv/$updatedirectory/startserver.sh /config/Minecraft_Server

        #give any .sh file in the server directory execute permissions
        chmod +x $serverdirectory/*.sh
        
        echo "update complete"

        #cleanup after install
        cleanup

    fi

}

function cleanup(){

    # remove the downloaded file
    if [ -f /srv/download ]; then
        rm -r /srv/download
    fi
    
    # remove update folder if it exists and the variable is set
    if [ -n "$updatedirectory" ]; then
        rm -r /srv/$updatedirectory
    fi
}


#link where the server files are downloaded
downloadlink=https://www.curseforge.com/api/v1/mods/715572/files/5016170/download


# Call the functions and run them
#create the server
create_server
#set the server variables from user
server_variables
#set the arguement files for server customization
jvm_args

#start the minecraft server
$serverdirectory/startserver.sh



# Current implementation will be that the docker container will "update" when I push a update with the link changed, so what should happen is
# the server checks the version of the download link, compares it to the version .txt inside the /config/Server folder
