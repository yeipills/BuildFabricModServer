# Añadiendo mods a un servidor de Minecraft usando Fabric ModLoader

Este README te ayudará a añadir mods a tu servidor de Minecraft utilizando Fabric, un popular mod loader.

## Requisitos Previos

- [Java 8](https://www.oracle.com/java/technologies/javase-jdk8-downloads.html) o una versión superior.
- [Minecraft Server](https://www.minecraft.net/es-es/download/server) con la versión que corresponda con el Mod Loader Fabric.
- [Fabric Mod Loader](https://fabricmc.net/use/)
- [Fabric API](https://www.curseforge.com/minecraft/mc-mods/fabric-api)

## Pasos para Windows 10

1. Descargar la versión de [Fabric Installer](https://fabricmc.net/use/) adecuada para el servidor.

2. Ejecuta el instalador de Fabric. Selecciona la opción 'Server' y luego especifica la ubicación donde deseas que se instale el servidor de Fabric. Haz clic en 'Install' para iniciar la instalación.

3. Descarga la [Fabric API](https://www.curseforge.com/minecraft/mc-mods/fabric-api) y mueve el archivo .jar a la carpeta 'mods' que se creó en el paso anterior.

4. Mueve también los mods que deseas instalar en tu servidor a la carpeta 'mods'. Si no puedes encontrar la carpeta 'mods', puedes crearla tú mismo en el directorio del servidor.

5. Una vez que hayas movido todos los mods y la Fabric API a la carpeta 'mods', ejecuta el servidor utilizando el archivo .jar de Fabric que se creó durante la instalación. Haz clic derecho en el archivo .jar y selecciona "Abrir con Java(TM) Platform SE binary". Asegúrate de tener la cantidad adecuada de RAM asignada a tu servidor.

6. Verifica que todos los mods se carguen correctamente en el arranque del servidor. Si hay algún problema con los mods, el servidor proporcionará un error en el registro de la consola.

## Pasos para Linux

1. Descarga la versión de [Fabric Installer](https://fabricmc.net/use/) adecuada para el servidor.

2. Ejecuta el instalador de Fabric con el comando `java -jar fabric-installer.jar --installServer`. Asegúrate de estar en el directorio donde deseas que se instale el servidor de Fabric.

3. Descarga la [Fabric API](https://www.curseforge.com/minecraft/mc-mods/fabric-api) y mueve el archivo .jar a la carpeta 'mods' que se creó en el paso anterior.

4. Mueve también los mods que deseas instalar en tu servidor a la carpeta 'mods'. Si no puedes encontrar la carpeta 'mods', puedes crearla tú mismo en el directorio del servidor con `mkdir mods`.

5. Una vez que hayas movido todos los mods y la Fabric API a la carpeta 'mods', inicia el servidor utilizando el archivo .jar de Fabric que se creó durante la instalación con el comando `java -Xmx1024M -Xms1024M -jar fabric-server-launch.jar nogui`. Asegúrate de tener la cantidad adecuada de RAM asignada a tu servidor.

6. Verifica que todos los mods se carguen correctamente en el arranque del servidor. Si hay algún problema con los mods, el servidor proporcionará un error en el registro de la consola.

## Notas

- Todos los mods que se instalen en el servidor deben ser compatibles con Fabric.
- Todos los jugadores necesitarán tener los mismos mods (y las mismas versiones de estos mods) instalados en sus propios clientes de Minecraft para poder unirse al servidor.
- Asegúrate de que estás utilizando la versión correcta de Java para tu servidor. Algunos mods pueden requerir versiones específicas de Java.
