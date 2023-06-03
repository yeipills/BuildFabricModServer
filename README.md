# Añadiendo mods a un servidor de Minecraft usando Fabric ModLoader

Este README te ayudará a añadir mods a tu servidor de Minecraft utilizando Fabric, un popular mod loader.

## Requisitos Previos

- Java Development Kit (JDK) 17 (Los pasos estan mas abajo)
- [Fabric Mod Loader](https://fabricmc.net/use/server/)
- [Fabric API](https://www.curseforge.com/minecraft/mc-mods/fabric-api)
- Un sistema Debian 11 ARM con al menos 2 núcleos y 2GB de RAM.

## Para instalar OpenJDK 17 en Debian, puedes seguir estos pasos:

1. Actualiza el sistema: Antes de instalar cualquier paquete, siempre es recomendable actualizar el sistema. Puedes hacerlo con el siguiente comando:

```bash
sudo apt update
sudo apt upgrade
```

2. Instala OpenJDK 17: Después de actualizar el sistema, puedes instalar OpenJDK 17 con el siguiente comando:

```bash
sudo apt install openjdk-17-jdk
```

3. Verifica la instalación: Una vez que la instalación esté completa, puedes verificar que OpenJDK 17 se instaló correctamente con el siguiente comando:

```bash
java -version
```

Deberías ver algo como esto:

```bash
openjdk version "17.0.0" 2023-06-03
OpenJDK Runtime Environment (build 17.0.0+35-Debian-1)
OpenJDK 64-Bit Server VM (build 17.0.0+35-Debian-1, mixed mode, sharing)
```

Esto indica que OpenJDK 17 está instalado correctamente en tu sistema.

## Pasos para Linux (Debian 11 ARM)

1. Descarga la versión de [Fabric Installer](https://fabricmc.net/use/) adecuada para el servidor.

2. Ejecuta el instalador de Fabric con el comando `java -jar fabric-installer.jar --installServer`. Asegúrate de estar en el directorio donde deseas que se instale el servidor de Fabric.

3. Descarga la [Fabric API](https://www.curseforge.com/minecraft/mc-mods/fabric-api) y mueve el archivo .jar a la carpeta 'mods' que se creó en el paso anterior.

4. Mueve también los mods que deseas instalar en tu servidor a la carpeta 'mods'. Si no puedes encontrar la carpeta 'mods', puedes crearla tú mismo en el directorio del servidor con `mkdir mods`.

5. Una vez que hayas movido todos los mods y la Fabric API a la carpeta 'mods', inicia el servidor utilizando el archivo .jar de Fabric que se creó durante la instalación con el comando `java -Xmx2G -Xms2G -jar fabric-server-launch.jar nogui`. Asegúrate de tener la cantidad adecuada de RAM asignada a tu servidor.

6. Verifica que todos los mods se carguen correctamente en el arranque del servidor. Si hay algún problema con los mods, el servidor proporcionará un error en el registro de la consola.

## Optimización del Servidor

A continuación, te presentamos un script para optimizar tu servidor de Minecraft. Este script actualiza tu sistema, instala sysstat para el monitoreo del rendimiento, configura el kernel para manejar mejor la carga de la red, y reduce el uso de SWAP para mejorar el rendimiento general.

```bash
#!/bin/bash

# Antes de ejecutar este script, asegúrate de tener los permisos de superusuario necesarios (sudo).

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update -y && sudo apt upgrade -y

# Instalar y configurar sysstat para monitorear el rendimiento del sistema
echo "Instalando y configurando sysstat..."
sudo apt install -y sysstat
sudo sed -i 's/false/true/g' /etc/default/sysstat

# Habilitar el uso de cache de la memoria RAM para acelerar la lectura de disco
echo "Habilitando cache de RAM..."
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf

# Configurar el kernel para gestionar mejor la carga de red pesada
echo "Optimizando la gestión de la red..."
echo "net.core.rmem_max=12582912" | sudo tee -a /etc/sysctl.conf
echo "net.core.wmem_max=12582912" | sudo tee -a /etc/sysctl.conf


echo "net.ipv4.tcp_rmem=4096 87380 12582912" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_wmem=4096 87380 12582912" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=cubic" | sudo tee -a /etc/sysctl.conf

# Reducir el uso de SWAP para mejorar el rendimiento general
echo "Reduciendo el uso de SWAP..."
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf

# Reiniciar sysctl para aplicar las nuevas configuraciones
echo "Aplicando nuevas configuraciones..."
sudo sysctl -p

echo "¡Optimización completada!"
```

## Además, este es un script para iniciar tu servidor de Minecraft con opciones de JVM personalizadas para un rendimiento óptimo.

```bash
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
```

Por favor, recuerda ejecutar este último script desde dentro del directorio del servidor, o donde quiera que se encuentre el ejecutable del servidor de Minecraft.

## Notas

- Todos los mods que se instalen en el servidor deben ser compatibles con Fabric.
- Todos los jugadores necesitarán tener los mismos mods (y las mismas versiones de estos mods) instalados en sus propios clientes de Minecraft para poder unirse al servidor.
- Asegúrate de que estás utilizando la versión correcta de Java para tu servidor. Algunos mods pueden requerir versiones específicas de Java.
