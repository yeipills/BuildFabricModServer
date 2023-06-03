#!/bin/bash

# Establecer variables para la JVM
JAVA_OPTS="-Xmx2G -Xms2G -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=200 -XX:+DisableExplicitGC -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"

# Define el directorio del servidor
SERVER_DIR="/ruta/del/servidor"

# Define la ruta del archivo jar del servidor de Minecraft
SERVER_JAR="$SERVER_DIR/fabric-server-launch.jar"

# Define los argumentos del servidor
SERVER_ARGS="nogui"

# Inicia el servidor
exec java $JAVA_OPTS -jar "$SERVER_JAR" $SERVER_ARGS
