#!/bin/sh

#set packages to download in order to run the minecraft server
apk_packages="openjdk17 bash curl"

#command to add the packages to the machine
apk add $apk_packages