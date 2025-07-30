# 🔧 Guía de Solución de Problemas

Esta guía te ayudará a resolver los problemas más comunes que puedes encontrar al usar BuildFabricModServer.

## 📋 Tabla de Contenidos

- [Problemas de Instalación](#-problemas-de-instalación)
- [Problemas del Servidor](#-problemas-del-servidor)
- [Problemas de Docker](#-problemas-de-docker)
- [Problemas de Rendimiento](#-problemas-de-rendimiento)
- [Problemas de Red](#-problemas-de-red)
- [Problemas de Mods](#-problemas-de-mods)
- [Herramientas de Diagnóstico](#-herramientas-de-diagnóstico)

## 🚀 Problemas de Instalación

### ❌ "Java not found" o versión incorrecta

**Síntomas:**
```bash
Error: Java no está instalado o no está en el PATH
Se requiere Java 17 o superior. Versión actual: 8
```

**Soluciones:**

1. **Instalar Java 17:**
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install openjdk-17-jdk
   
   # Verificar instalación
   java -version
   ```

2. **Múltiples versiones de Java:**
   ```bash
   # Ver versiones instaladas
   sudo update-alternatives --list java
   
   # Configurar versión por defecto
   sudo update-alternatives --config java
   ```

3. **Configurar JAVA_HOME:**
   ```bash
   # Encontrar Java
   readlink -f $(which java)
   
   # Agregar a ~/.bashrc
   export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
   export PATH=$JAVA_HOME/bin:$PATH
   
   # Recargar configuración
   source ~/.bashrc
   ```

### ❌ "Permission denied" durante instalación

**Síntomas:**
```bash
chmod: cannot access '/opt/minecraft': Permission denied
mkdir: cannot create directory '/opt/minecraft': Permission denied
```

**Soluciones:**

1. **Verificar que no estés ejecutando como root:**
   ```bash
   whoami  # No debe mostrar 'root'
   ```

2. **Verificar permisos de sudo:**
   ```bash
   sudo -l  # Verificar permisos de sudo
   ```

3. **Crear directorio manualmente:**
   ```bash
   sudo mkdir -p /opt/minecraft
   sudo chown $USER:$USER /opt/minecraft
   ```

### ❌ "Architecture not supported"

**Síntomas:**
```bash
Este script está optimizado para ARM, pero detecté: x86_64
```

**Soluciones:**

1. **Usar script correcto:**
   ```bash
   # Para sistemas ARM
   ./script_optimizacion_debian_11_ARM.sh
   
   # Para sistemas x86/x64
   ./script_optimizacion_debian_11_x86-x86_64.sh
   ```

2. **Verificar arquitectura:**
   ```bash
   uname -m  # Mostrar arquitectura del sistema
   lscpu     # Información detallada de CPU
   ```

### ❌ "Failed to download Fabric"

**Síntomas:**
```bash
Error al descargar Fabric Installer
wget: unable to resolve host address
```

**Soluciones:**

1. **Verificar conectividad:**
   ```bash
   ping google.com
   curl -I https://fabricmc.net
   ```

2. **Verificar proxy:**
   ```bash
   echo $http_proxy
   echo $https_proxy
   
   # Si hay proxy, configurar:
   export http_proxy=http://proxy.company.com:8080
   export https_proxy=http://proxy.company.com:8080
   ```

3. **Descarga manual:**
   ```bash
   # Descargar manualmente desde https://fabricmc.net/use/installer/
   # Luego mover a directorio del servidor
   ```

## 🎮 Problemas del Servidor

### ❌ Servidor no inicia

**Síntomas:**
```bash
# systemctl status minecraft-fabric
Failed to start minecraft-fabric.service
```

**Diagnóstico:**
```bash
# Ver logs completos
sudo journalctl -u minecraft-fabric -n 50

# Verificar archivo JAR
ls -la /opt/minecraft/server/fabric-server-launch.jar

# Verificar configuración
cat /opt/minecraft/server/eula.txt
cat /opt/minecraft/server/server.properties
```

**Soluciones:**

1. **EULA no aceptado:**
   ```bash
   sudo -u minecraft sed -i 's/eula=false/eula=true/' /opt/minecraft/server/eula.txt
   ```

2. **Archivo JAR faltante:**
   ```bash
   cd /opt/minecraft/server
   sudo -u minecraft ./install.sh  # Re-ejecutar instalación
   ```

3. **Permisos incorrectos:**
   ```bash
   sudo chown -R minecraft:minecraft /opt/minecraft
   sudo chmod +x /opt/minecraft/server/iniciador_optimizado_de_minecraft.sh
   ```

### ❌ "Cannot allocate memory"

**Síntomas:**
```bash
Error occurred during initialization of VM
Could not reserve enough space for 2097152KB object heap
```

**Soluciones:**

1. **Verificar RAM disponible:**
   ```bash
   free -h
   cat /proc/meminfo
   ```

2. **Reducir asignación de memoria:**
   ```bash
   # Editar iniciador
   sudo -u minecraft nano /opt/minecraft/server/iniciador_optimizado_de_minecraft.sh
   
   # Cambiar de -Xmx2G a -Xmx1G (o menos)
   ```

3. **Configurar swap:**
   ```bash
   # Ver swap actual
   swapon --show
   
   # Crear swap si no existe
   sudo fallocate -l 2G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   
   # Hacer permanente
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```

### ❌ "Port already in use"

**Síntomas:**
```bash
**** FAILED TO BIND TO PORT!
The exception was: java.net.BindException: Address already in use
```

**Soluciones:**

1. **Verificar qué usa el puerto:**
   ```bash
   sudo ss -tulpn | grep :25565
   sudo lsof -i :25565
   ```

2. **Cambiar puerto del servidor:**
   ```bash
   sudo -u minecraft nano /opt/minecraft/server/server.properties
   # Cambiar: server-port=25565 a server-port=25566
   ```

3. **Matar proceso que usa el puerto:**
   ```bash
   sudo kill -9 $(sudo lsof -t -i:25565)
   ```

### ❌ Servidor se cierra inesperadamente

**Síntomas:**
```bash
Server closed
Process finished with exit code 0
```

**Diagnóstico:**
```bash
# Ver logs detallados
sudo -u minecraft tail -100 /opt/minecraft/server/logs/latest.log

# Verificar crash reports
ls -la /opt/minecraft/server/crash-reports/

# Ver logs del sistema
sudo journalctl -u minecraft-fabric -f
```

**Soluciones:**

1. **Problema de memoria:**
   ```bash
   # Revisar configuración JVM
   /opt/minecraft/monitor.sh
   
   # Reducir view-distance
   sudo -u minecraft nano /opt/minecraft/server/server.properties
   # view-distance=8 (en lugar de 10 o más)
   ```

2. **Mod incompatible:**
   ```bash
   # Mover todos los mods temporalmente
   sudo -u minecraft mkdir /tmp/mods_backup
   sudo -u minecraft mv /opt/minecraft/server/mods/* /tmp/mods_backup/
   
   # Iniciar servidor sin mods
   sudo systemctl start minecraft-fabric
   
   # Agregar mods de uno en uno para identificar el problemático
   ```

## 🐳 Problemas de Docker

### ❌ "Cannot connect to Docker daemon"

**Síntomas:**
```bash
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Soluciones:**

1. **Iniciar Docker:**
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

2. **Agregar usuario al grupo docker:**
   ```bash
   sudo usermod -aG docker $USER
   # Cerrar sesión y volver a entrar
   ```

3. **Verificar instalación:**
   ```bash
   docker --version
   docker run hello-world
   ```

### ❌ "docker-compose command not found"

**Síntomas:**
```bash
./docker-run.sh: line 45: docker-compose: command not found
```

**Soluciones:**

1. **Instalar docker-compose:**
   ```bash
   # Método 1: apt
   sudo apt install docker-compose
   
   # Método 2: pip
   pip install docker-compose
   
   # Método 3: download directo
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

2. **Usar Docker Compose v2:**
   ```bash
   # El script automáticamente detecta si usar 'docker-compose' o 'docker compose'
   docker compose version
   ```

### ❌ Container builds but won't start

**Síntomas:**
```bash
Container minecraft-fabric-server started but exits immediately
```

**Diagnóstico:**
```bash
# Ver logs del contenedor
./docker-run.sh logs

# Logs detallados
docker logs minecraft-fabric-server

# Ejecutar shell en contenedor para debugging
docker run -it --rm minecraft-fabric:latest /bin/bash
```

**Soluciones:**

1. **EULA no aceptado:**
   ```bash
   # Editar docker-compose.yml
   nano docker-compose.yml
   # Cambiar: EULA=false a EULA=true
   ```

2. **Permisos en volúmenes:**
   ```bash
   # Verificar permisos de directorios de datos
   sudo chown -R 1000:1000 ./data/
   ```

3. **Problemas de red:**
   ```bash
   # Verificar que el puerto no esté en uso
   sudo ss -tulpn | grep :25565
   
   # Cambiar puerto en docker-compose.yml si es necesario
   ```

### ❌ "No space left on device"

**Síntomas:**
```bash
Error response from daemon: no space left on device
```

**Soluciones:**

1. **Limpiar imágenes Docker:**
   ```bash
   docker system df  # Ver uso de espacio
   docker system prune -a  # Limpiar todo lo no usado
   docker image prune -a  # Solo imágenes
   ```

2. **Limpiar volúmenes:**
   ```bash
   docker volume ls
   docker volume prune  # Eliminar volúmenes no usados
   ```

3. **Mover Docker a otra partición:**
   ```bash
   # Detener Docker
   sudo systemctl stop docker
   
   # Mover directorio
   sudo mv /var/lib/docker /opt/docker
   
   # Crear symlink
   sudo ln -s /opt/docker /var/lib/docker
   
   # Reiniciar Docker
   sudo systemctl start docker
   ```

## ⚡ Problemas de Rendimiento

### ❌ Lag del servidor (TPS bajo)

**Síntomas:**
- Jugadores experimentan lag
- Bloques tardan en romperse
- Animales/mobs se mueven lentamente

**Diagnóstico:**
```bash
# Ejecutar benchmark
./benchmark.sh -q

# Monitorear recursos en tiempo real
/opt/minecraft/monitor.sh

# Ver estadísticas del servidor (si tienes consola access)
# En consola de Minecraft: /forge tps
```

**Soluciones:**

1. **Optimizar configuración:**
   ```bash
   sudo -u minecraft nano /opt/minecraft/server/server.properties
   
   # Reducir distancias
   view-distance=8
   simulation-distance=6
   
   # Reducir jugadores si es necesario
   max-players=15
   ```

2. **Optimizar JVM:**
   ```bash
   # Verificar configuración actual
   ps aux | grep java
   
   # El script optimizado ya incluye los mejores flags
   # Si tienes más RAM, puedes aumentar asignación
   ```

3. **Identificar mods problemáticos:**
   ```bash
   # Usar profiling tools en consola de Minecraft
   # /profile start
   # (esperar 30 segundos)
   # /profile stop
   ```

### ❌ Alto uso de CPU

**Síntomas:**
```bash
# top muestra java usando >80% CPU constantemente
PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
1234 minecraft 20   0 4567890 123456  78901 S  95.5 15.2   12:34.56 java
```

**Soluciones:**

1. **Verificar configuración de chunks:**
   ```bash
   # En server.properties
   view-distance=6  # Reducir si está muy alto
   simulation-distance=4
   ```

2. **Optimizar garbage collection:**
   ```bash
   # El iniciador optimizado ya incluye los mejores flags G1GC
   # Ver logs de GC agregando a JAVA_OPTS:
   # -Xloggc:gc.log -XX:+PrintGCDetails
   ```

3. **Limitar entidades:**
   ```bash
   # Agregar al server.properties
   spawn-animals=false  # Si hay muchos animales
   spawn-monsters=true  # Mantener para gameplay
   ```

### ❌ Alto uso de memoria

**Síntomas:**
```bash
# Memoria constantemente cerca del límite
# OOM (Out of Memory) errors en logs
```

**Soluciones:**

1. **Aumentar RAM asignada:**
   ```bash
   # Si tienes RAM disponible
   sudo -u minecraft nano /opt/minecraft/server/iniciador_optimizado_de_minecraft.sh
   # Cambiar -Xmx2G a -Xmx4G (por ejemplo)
   ```

2. **Reducir uso de memoria:**
   ```bash
   # server.properties
   view-distance=6
   max-players=10
   
   # Quitar mods que usen mucha memoria
   ```

3. **Configurar swap adecuadamente:**
   ```bash
   # Ver uso actual
   free -h
   swapon --show
   
   # Ajustar swappiness
   echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
   ```

## 🌐 Problemas de Red

### ❌ No se pueden conectar jugadores

**Síntomas:**
- Jugadores reciben "Connection timed out"
- Servidor visible localmente pero no remotamente

**Diagnóstico:**
```bash
# Verificar que el servidor esté escuchando
sudo ss -tulpn | grep :25565

# Verificar firewall
sudo ufw status

# Test de conectividad local
telnet localhost 25565

# Test desde otra máquina
telnet IP_DEL_SERVIDOR 25565
```

**Soluciones:**

1. **Configurar firewall:**
   ```bash
   # Abrir puerto
   sudo ufw allow 25565/tcp
   
   # Verificar reglas
   sudo ufw status numbered
   ```

2. **Verificar configuración del router:**
   - Port forwarding del puerto 25565 a la IP interna
   - DMZ si es necesario (menos seguro)

3. **Verificar server-ip:**
   ```bash
   # En server.properties
   server-ip=  # Debe estar vacío para escuchar en todas las interfaces
   
   # O especificar IP específica
   server-ip=192.168.1.100
   ```

### ❌ "Connection reset" frecuentes

**Síntomas:**
- Jugadores se desconectan frecuentemente
- "Connection reset by peer" en logs

**Soluciones:**

1. **Ajustar configuración de red:**
   ```bash
   # server.properties
   network-compression-threshold=512  # Aumentar si conexión lenta
   max-tick-time=60000  # Aumentar si hay lag
   ```

2. **Verificar MTU:**
   ```bash
   # Encontrar MTU óptimo
   ping -M do -s 1472 google.com
   
   # Ajustar si es necesario
   sudo ip link set dev eth0 mtu 1500
   ```

3. **Optimizaciones TCP:**
   ```bash
   # Los scripts de optimización ya incluyen estas configuraciones
   # Verificar que se aplicaron
   sysctl net.ipv4.tcp_keepalive_time
   ```

## 🧩 Problemas de Mods

### ❌ "Mod incompatible" o crashes

**Síntomas:**
```bash
# En logs del servidor
Incompatible mod set!
net.fabricmc.loader.impl.FormattedException: Mod resolution encountered an incompatible mod set!
```

**Soluciones:**

1. **Verificar compatibilidad:**
   ```bash
   # Verificar versiones
   cat /opt/minecraft/server/fabric-server-launch.jar  # Ver versión Fabric
   
   # Verificar mods en https://www.curseforge.com/minecraft/modpacks
   # Asegurar que sean para Fabric y versión correcta de Minecraft
   ```

2. **Dependency missing:**
   ```bash
   # Instalar Fabric API si no está
   cd /opt/minecraft/server/mods
   wget [URL_FABRIC_API] -O fabric-api.jar
   ```

3. **Conflictos entre mods:**
   ```bash
   # Proceso de eliminación para encontrar conflicto
   mkdir /tmp/mods_test
   mv /opt/minecraft/server/mods/* /tmp/mods_test/
   
   # Agregar mods de uno en uno hasta encontrar el problemático
   ```

### ❌ Mods no cargan

**Síntomas:**
- Mods en carpeta /mods pero no aparecen en juego
- Sin errores en logs

**Soluciones:**

1. **Verificar permisos:**
   ```bash
   sudo chown -R minecraft:minecraft /opt/minecraft/server/mods/
   sudo chmod 644 /opt/minecraft/server/mods/*.jar
   ```

2. **Verificar que sean archivos .jar válidos:**
   ```bash
   file /opt/minecraft/server/mods/*.jar
   # Debe mostrar "Java archive data"
   ```

3. **Verificar lado del mod:**
   - Algunos mods son solo client-side
   - Verificar documentación del mod

## 🔍 Herramientas de Diagnóstico

### Scripts de Diagnóstico Incluidos

```bash
# Monitoreo general del sistema
/opt/minecraft/monitor.sh

# Benchmark completo
./benchmark.sh

# Estado específico de Docker
./docker-run.sh status

# Logs en tiempo real
sudo journalctl -u minecraft-fabric -f
# O para Docker:
./docker-run.sh logs -f
```

### Script de Diagnóstico Automático

Crear un script para recopilar información:

```bash
#!/bin/bash
# diagnóstico.sh - Recopilar información para debug

echo "=== DIAGNÓSTICO AUTOMÁTICO ==="
echo "Fecha: $(date)"
echo "Usuario: $(whoami)"
echo ""

echo "=== SISTEMA ==="
echo "OS: $(lsb_release -d 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME)"
echo "Kernel: $(uname -r)"
echo "Arquitectura: $(uname -m)"
echo "Uptime: $(uptime)"
echo ""

echo "=== JAVA ==="
java -version 2>&1 || echo "Java no encontrado"
echo "JAVA_HOME: $JAVA_HOME"
echo ""

echo "=== MINECRAFT SERVER ==="
echo "Directorio servidor: $(ls -la /opt/minecraft/server/ 2>/dev/null || echo 'No existe')"
echo "Proceso Java:"
ps aux | grep java | grep -v grep || echo "No hay procesos Java"
echo ""

echo "=== RED ==="
echo "Puertos en uso:"
sudo ss -tulpn | grep -E ":(25565|25575)" || echo "Puertos Minecraft no en uso"
echo ""
echo "Firewall:"
sudo ufw status || echo "UFW no disponible"
echo ""

echo "=== RECURSOS ==="
echo "Memoria:"
free -h
echo ""
echo "Disco:"
df -h | grep -E "(/$|/opt)" || df -h
echo""

echo "=== LOGS RECIENTES ==="
echo "SystemD logs (últimas 10 líneas):"
sudo journalctl -u minecraft-fabric -n 10 --no-pager 2>/dev/null || echo "Servicio no encontrado"
echo ""

echo "Logs del servidor (últimas 10 líneas):"
tail -10 /opt/minecraft/server/logs/latest.log 2>/dev/null || echo "Logs no encontrados"
echo ""

echo "=== DOCKER (si aplica) ==="
docker --version 2>/dev/null && {
    echo "Contenedores:"
    docker ps -a | grep minecraft || echo "No hay contenedores Minecraft"
    echo ""
}

echo "=== FIN DEL DIAGNÓSTICO ==="
```

### Checklist de Resolución de Problemas

Antes de pedir ayuda, verifica:

- [ ] ✅ **Java 17+ instalado** y en PATH
- [ ] ✅ **EULA aceptado** (eula=true)
- [ ] ✅ **Permisos correctos** (usuario minecraft)
- [ ] ✅ **Puerto 25565 abierto** en firewall
- [ ] ✅ **RAM suficiente** disponible
- [ ] ✅ **Espacio en disco** suficiente
- [ ] ✅ **Logs revisados** para errores específicos
- [ ] ✅ **Mods compatibles** con versión de Fabric/Minecraft
- [ ] ✅ **Configuración valid** en server.properties

### Cómo Pedir Ayuda

Si necesitas ayuda adicional:

1. **Ejecuta diagnóstico automático**
2. **Recopila logs relevantes**
3. **Crea issue** usando [templates](../../issues/new/choose)
4. **Incluye información del sistema**
5. **Describe pasos para reproducir**

---

¿No encuentras tu problema aquí? [Crea un issue](../../issues/new/choose) con toda la información de diagnóstico y te ayudaremos a resolverlo.