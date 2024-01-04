**Application**

[All the Mods Minecraft Server]

**Description**

All the Mods is a Modpack for the popular game Minecraft. I am attempting to create a docker container that handles application updates and backups with ease as this does not yet exist. In order to update an All the Mods Server there needs to be manual moving of files and I am attempting to automate this process

**Build Notes**

Currently this build is running All the Mods Version 0.2.31 Released on December 12th

**Usage**
```
docker run -d \
    -p <host port>:8222/tcp \
    -p <host port>:25565 \
    -e min_heap=<java min heap size in GB> \
    -e max_heap=<java max heap size in GB> \
    --name <container name> \
    rushrecon21/atm-server
```
