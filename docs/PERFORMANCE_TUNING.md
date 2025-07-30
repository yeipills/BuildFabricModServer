# ⚡ Guía de Optimización de Rendimiento

Esta guía te ayudará a maximizar el rendimiento de tu servidor Minecraft Fabric.

## 📊 Métricas de Rendimiento

### Objetivos de Rendimiento
- **TPS (Ticks Per Second)**: 20.0 TPS constante
- **MSPT (Milliseconds Per Tick)**: < 50ms
- **Uso de CPU**: < 70% en promedio
- **Uso de RAM**: < 80% de la asignada
- **Latencia de red**: < 100ms para jugadores locales

### Herramientas de Monitoreo
```bash
# Monitoreo en tiempo real (incluido)
/opt/minecraft/monitor.sh

# Benchmark completo
./benchmark.sh

# Herramientas del sistema
htop              # Uso de CPU y RAM
iotop             # I/O de disco
nethogs           # Uso de red por proceso
```

## 🔧 Optimizaciones JVM

### Configuración Óptima de Memoria
```bash
# Para 4GB de RAM total (recomendado 6-8GB sistema)
-Xms2G -Xmx2G

# Para 8GB de RAM total (recomendado 12GB sistema)  
-Xms4G -Xmx4G

# Para 16GB de RAM total (recomendado 20GB sistema)
-Xms8G -Xmx8G

# Regla general: 50-60% de RAM total del sistema
```

### Flags JVM Optimizados (Ya incluidos en el iniciador)
```bash
# Garbage Collector G1 (óptimo para servidores)
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
-XX:MaxTenuringThreshold=1

# Optimizaciones adicionales
-Dusing.aikars.flags=https://mcflags.emc.gs
-Daikars.new.flags=true
```

### Flags Específicos por Hardware

#### Para Sistemas ARM (Raspberry Pi)
```bash
# Flags adicionales optimizados para ARM
-XX:+UseConcMarkSweepGC
-XX:+CMSParallelRemarkEnabled
-XX:CMSInitiatingOccupancyFraction=70
-XX:+CMSClassUnloadingEnabled
-Djava.net.preferIPv4Stack=true
```

#### Para Sistemas x86/x64 de Alto Rendimiento
```bash
# Flags adicionales para servidores potentes
-XX:+UseStringDeduplication
-XX:+UseFastUnorderedTimeStamps
-XX:+UseAES
-XX:+UseAESIntrinsics
-XX:UseAVX=2
-XX:+UseFMA
```

## 🎮 Configuración del Servidor

### server.properties Optimizado
```properties
# === CONFIGURACIONES DE RENDIMIENTO ===

# Distancia de simulación (crítico para rendimiento)
view-distance=8          # Reducir de 10 a 8 para mejor rendimiento
simulation-distance=6    # Reducir de 10 a 6 para mucho mejor rendimiento

# Límites de jugadores y entidades
max-players=20           # Ajustar según hardware
max-world-size=29999984  # Limitar tamaño del mundo

# Configuración de red optimizada
network-compression-threshold=256  # Comprimir paquetes >256 bytes
max-tick-time=60000               # Tiempo máximo por tick (60s)
player-idle-timeout=30            # Desconectar AFK después de 30min

# Optimizaciones de mundo
spawn-protection=0       # Desactivar si no necesitas protección spawn
allow-flight=false       # Desactivar vuelo para prevenir exploits
enforce-secure-profile=false  # Desactivar para mejor compatibilidad

# === CONFIGURACIONES DE GAMEPLAY ===

# Mob spawning (ajustar según necesidades)
spawn-animals=true       # Animales pacíficos
spawn-monsters=true      # Monstruos
spawn-npcs=true         # Aldeanos

# Dificultad y gamemode
difficulty=normal        # easy/normal/hard
gamemode=survival       # survival/creative/adventure/spectator
hardcore=false          # Mundo hardcore

# Configuraciones adicionales de rendimiento
entity-broadcast-range-percentage=100  # Rango de broadcast de entidades
```

### Optimizaciones de Mundo

#### Configuración de Chunks
```bash
# En server.properties
view-distance=8          # Chunks cargados por jugador
simulation-distance=6    # Chunks simulados activamente

# Configuraciones internas (automáticas)
# - Chunk loading: Carga lazy de chunks no activos
# - Chunk unloading: Descarga automática de chunks vacíos
# - Entity cramming: Límite de entidades por bloque
```

#### Pregenerar Mundo (Opcional)
```bash
# Usar plugin WorldBorder para pregenerar
# Esto reduce lag de generación durante el juego

# En consola del servidor:
/worldborder set 5000    # Límite de 5000 bloques
/worldborder fill        # Pregenerar chunks
```

## 🧩 Optimizaciones de Mods

### Mods de Rendimiento Recomendados
```bash
cd /opt/minecraft/server/mods

# Fabric API (requerido)
wget https://github.com/FabricMC/fabric/releases/latest/download/fabric-api-x.x.x.jar

# Mods de optimización
wget [URL] -O lithium.jar          # Optimizaciones generales del servidor
wget [URL] -O phosphor.jar         # Optimización del sistema de iluminación  
wget [URL] -O sodium.jar           # Optimización de rendering (cliente)
wget [URL] -O starlight.jar        # Motor de iluminación mejorado
wget [URL] -O ferritecore.jar      # Reducción de uso de memoria
wget [URL] -O lazydfu.jar          # Carga lazy de DataFixerUpper
```

### Configuración de Mods de Rendimiento

#### Lithium Config
```toml
# config/lithium.properties
mixin.ai.pathing=true                    # Optimizar pathfinding
mixin.block.hopper=true                  # Optimizar hoppers  
mixin.chunk.serialization=true          # Optimizar serialización chunks
mixin.entity.collisions=true            # Optimizar colisiones
mixin.world.block_entity_ticking=true   # Optimizar block entities
```

#### Starlight Config  
```toml
# config/starlight.properties
chunk-relight-on-load=false    # No recalcular luz en chunks existentes
use-vanilla-algorithm=false    # Usar algoritmo optimizado
```

### Mods a Evitar (Alto Consumo)
- ❌ Mods con muchos TileEntities
- ❌ Mods de dimensiones adicionales complejas
- ❌ Mods con muchas entidades (si no son necesarias)
- ❌ Mods de mapas dinámicos grandes
- ❌ Mods con rendering complejo del lado servidor

## 💾 Optimizaciones de Sistema

### I/O de Disco
```bash
# Verificar tipo de almacenamiento
lsblk -d -o name,rota

# Para SSDs - optimizar scheduler
echo noop | sudo tee /sys/block/sda/queue/scheduler

# Para HDDs - mantener scheduler por defecto
echo cfq | sudo tee /sys/block/sda/queue/scheduler

# Optimizar mount options para Minecraft (en /etc/fstab)
# /dev/sda1 /opt/minecraft ext4 defaults,noatime,nodiratime 0 2
```

### Configuraciones de Red
```bash
# Ya incluidas en scripts de optimización
# Verificar que se aplicaron:

# TCP Buffer sizes
sysctl net.core.rmem_default
sysctl net.core.rmem_max
sysctl net.core.wmem_default  
sysctl net.core.wmem_max

# TCP congestion control
sysctl net.ipv4.tcp_congestion_control

# Connection tracking
sysctl net.netfilter.nf_conntrack_max
```

### Configuraciones de Memoria
```bash
# Swappiness (ya optimizado en scripts)
sysctl vm.swappiness

# Memory overcommit
sysctl vm.overcommit_memory

# Dirty ratios (para escritura de archivos)
sysctl vm.dirty_ratio
sysctl vm.dirty_background_ratio
```

## 📈 Monitoreo y Profiling

### Scripts de Monitoreo Incluidos
```bash
# Monitoreo general
/opt/minecraft/monitor.sh

# Logs con timestamps
tail -f /opt/minecraft/server/logs/latest.log | while read line; do echo "$(date): $line"; done
```

### Profiling del Servidor
```bash
# En consola del servidor Minecraft:
/profile start                    # Iniciar profiling
# ... jugar normalmente 30-60 segundos ...
/profile stop                     # Detener y generar reporte

# El reporte se guarda en debug/profile-results-YYYY-MM-DD_HH.mm.ss.txt
```

### Herramientas Externas

#### JProfiler (Avanzado)
```bash
# Agregar a JAVA_OPTS para profiling remoto:
-agentpath:/path/to/jprofiler/bin/linux-x64/libjprofilerti.so=port=8849
```

#### VisualVM (Gratuito)
```bash
# Agregar a JAVA_OPTS:
-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.port=9999
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false
```

## 🎯 Configuraciones por Escenario

### Servidor Pequeño (2-10 jugadores)
```properties
# server.properties
max-players=10
view-distance=6
simulation-distance=4
network-compression-threshold=64

# JVM (2-4GB RAM)
-Xms2G -Xmx2G
```

### Servidor Mediano (10-30 jugadores)
```properties  
# server.properties
max-players=30
view-distance=8
simulation-distance=6
network-compression-threshold=256

# JVM (4-8GB RAM)
-Xms4G -Xmx4G
```

### Servidor Grande (30+ jugadores)
```properties
# server.properties  
max-players=50
view-distance=10
simulation-distance=8
network-compression-threshold=512

# JVM (8-16GB RAM)
-Xms8G -Xmx8G

# Considerar múltiples servidores con BungeeCord
```

### Servidor de Alto Rendimiento (Competitivo)
```properties
# server.properties - configuración agresiva
max-players=100
view-distance=12
simulation-distance=10
network-compression-threshold=1024

# JVM (16-32GB RAM)
-Xms16G -Xmx16G

# Hardware recomendado:
# - CPU: Ryzen 9 / Intel i9 con alta frecuencia single-core
# - RAM: 32GB DDR4-3200+
# - Storage: NVMe SSD
# - Network: Gigabit+ con baja latencia
```

## 🔍 Diagnóstico de Problemas de Rendimiento

### TPS Bajo (< 20.0)
```bash
# 1. Verificar uso de CPU
htop

# 2. Profiling del servidor
# /profile start en consola Minecraft

# 3. Verificar mods problemáticos
# Quitar mods de uno en uno

# 4. Reducir configuraciones
# view-distance, simulation-distance, max-players
```

### Alto Uso de Memoria
```bash
# 1. Verificar memory leaks
jmap -histo PID_JAVA | head -20

# 2. Análizar heap dump
jmap -dump:live,format=b,file=heap.hprof PID_JAVA

# 3. Optimizar GC
# Verificar logs de GC agregando: -Xloggc:gc.log
```

### Lag de Red
```bash
# 1. Verificar latencia
ping servidor.com

# 2. Verificar ancho de banda
iperf3 -c servidor.com

# 3. Optimizar compresión
# Aumentar network-compression-threshold
```

## 📊 Benchmarking

### Benchmark Automatizado
```bash
# Benchmark rápido (5 minutos)
./benchmark.sh -q

# Benchmark completo (30 minutos)
./benchmark.sh

# Benchmark específico
./benchmark.sh --cpu --memory --network --java
```

### Interpretar Resultados
```bash
# Resultados en: /tmp/benchmark_results_YYYY-MM-DD_HH-MM-SS.html

# Métricas importantes:
# - CPU single-core: >2000 points (mínimo para Minecraft)
# - Memory throughput: >10GB/s
# - Disk I/O: >100 MB/s para HDD, >500 MB/s para SSD
# - Network: <10ms latencia local, >100 Mbps throughput
```

## 🎛️ Configuraciones Avanzadas

### Configuración de Kernel
```bash
# Para servidores dedicados (requiere reinicio)
sudo nano /etc/sysctl.conf

# Agregar:
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_notsent_lowat = 16384
vm.max_map_count = 262144
kernel.sched_autogroup_enabled = 0
```

### Configuraciones de CPU
```bash
# Verificar frecuencia de CPU
cat /proc/cpuinfo | grep MHz

# Configurar governor de CPU para rendimiento
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Verificar
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

### Configuraciones de Memoria
```bash
# Huge Pages (para servidores con >16GB RAM)
echo always | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
echo always | sudo tee /sys/kernel/mm/transparent_hugepage/defrag

# NUMA (para servidores multi-CPU)
numactl --hardware  # Ver configuración NUMA
# Usar numactl para bind Java a un nodo NUMA específico
```

---

¿Necesitas ayuda específica con algún aspecto del rendimiento? Consulta la [Guía de Troubleshooting](TROUBLESHOOTING.md) o [crea un issue](../../issues/new/choose) con detalles de tu configuración.