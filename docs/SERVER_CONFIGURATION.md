# ⚙️ Configuración Completa del Servidor

Guía detallada para configurar todos los aspectos de tu servidor Minecraft Fabric.

## 📋 Tabla de Contenidos

- [Configuración Básica](#-configuración-básica)
- [Configuración de Mundo](#-configuración-de-mundo)
- [Configuración de Jugadores](#-configuración-de-jugadores)
- [Configuración de Red](#-configuración-de-red)
- [Configuración de Rendimiento](#-configuración-de-rendimiento)
- [Configuración de Mods](#-configuración-de-mods)
- [Configuración Avanzada](#-configuración-avanzada)

## 🎯 Configuración Básica

### server.properties - Configuración Principal
```bash
# Editar archivo principal de configuración
sudo -u minecraft nano /opt/minecraft/server/server.properties
```

```properties
# ====== CONFIGURACIÓN BÁSICA DEL SERVIDOR ======

# Información del servidor
server-name=Mi Servidor Fabric
motd=¡Bienvenido a nuestro servidor Minecraft con Fabric!
server-ip=
server-port=25565

# Configuración del mundo
level-name=world
level-type=minecraft\:normal
# Tipos disponibles: normal, flat, large_biomes, amplified, single_biome_surface
level-seed=
generator-settings={}

# Gamemode y dificultad
gamemode=survival
# survival, creative, adventure, spectator
difficulty=normal
# peaceful, easy, normal, hard
hardcore=false

# Configuración de spawn
spawn-protection=16
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
force-gamemode=false

# ====== CONFIGURACIÓN DE JUGADORES ======

# Límites de jugadores
max-players=20
player-idle-timeout=0
# 0 = sin timeout, >0 = minutos para desconectar AFK

# Whitelist y permisos
white-list=false
enforce-whitelist=false
op-permission-level=4
function-permission-level=2

# Autenticación
online-mode=true
# true = verificar cuentas oficiales (RECOMENDADO)
# false = permitir cuentas no premium (SOLO PARA TESTING)

# ====== CONFIGURACIÓN DE MUNDO ======

# Generación de estructuras
generate-structures=true
max-world-size=29999984

# Configuración de chunks y vista
view-distance=10
simulation-distance=10
# Reducir estos valores mejora el rendimiento

# Altura del mundo (1.18+)
max-build-height=320
# 64-320 en incrementos de 16

# ====== CONFIGURACIÓN DE RED ======

# Compresión de red
network-compression-threshold=256
# 0 = desactivar, 256 = comprimir paquetes >256 bytes

# Configuración de query
enable-query=false
query.port=25565

# RCON (administración remota)
enable-rcon=false
rcon.port=25575
rcon.password=

# ====== CONFIGURACIÓN DE RENDIMIENTO ======

# Tick settings
max-tick-time=60000
# Tiempo máximo por tick en ms

# Entity settings
entity-broadcast-range-percentage=100
# 10-1000, controla rango de actualización de entidades

# Configuración de memoria y recursos
sync-chunk-writes=true
# true = escritura síncrona (más estable)
# false = escritura asíncrona (más rápido)

# ====== CONFIGURACIÓN DE GAMEPLAY ======

# PvP y combate
pvp=true
allow-flight=false

# Commandos y funciones
enable-command-block=false
# Habilitar solo si necesitas command blocks

# Chat y comunicación
enforce-secure-profile=true
# Perfiles seguros (1.19.1+)

# Configuración de recursos
resource-pack=
resource-pack-prompt=
resource-pack-sha1=
require-resource-pack=false

# ====== CONFIGURACIÓN ADICIONAL ======

# Configuraciones experimentales
enable-jmx-monitoring=false
enable-status=true
hide-online-players=false

# Configuración de texto
text-filtering-config=
```

## 🌍 Configuración de Mundo

### Generación de Mundo Personalizada
```bash
# Para mundos personalizados, editar generator-settings
# Ejemplo para mundo súper plano:
generator-settings={"layers":[{"block":"minecraft:grass_block","height":1},{"block":"minecraft:dirt","height":2},{"block":"minecraft:stone","height":1}],"biome":"minecraft:plains"}
level-type=minecraft\:flat
```

### Configuración de Biomas
```bash
# Para mundos con bioma único
level-type=minecraft\:single_biome_surface
generator-settings={"biome":"minecraft:plains"}
# Biomas disponibles: plains, desert, forest, ocean, etc.
```

### Configuración de Datapacks
```bash
# Directorio para datapacks personalizados
mkdir -p /opt/minecraft/server/world/datapacks

# Ejemplo: Instalar datapack
cd /opt/minecraft/server/world/datapacks
sudo -u minecraft wget URL_DATAPACK.zip

# Recargar en el servidor (consola)
/reload
```

### Configuración de Gamerules
```bash
# Configurar reglas del juego (en consola del servidor)
# Comandos básicos:

# Configuración de tiempo
/gamerule doDaylightCycle true        # Ciclo día/noche
/gamerule doWeatherCycle true         # Cambios climáticos

# Configuración de mobs
/gamerule doMobSpawning true          # Spawn de mobs
/gamerule doMobLoot true              # Drops de mobs
/gamerule mobGriefing true            # Mobs pueden romper bloques

# Configuración de jugadores
/gamerule keepInventory false         # Mantener inventario al morir
/gamerule doImmediateRespawn false    # Respawn inmediato
/gamerule showDeathMessages true      # Mostrar mensajes de muerte

# Configuración de fuego y explosiones
/gamerule doFireTick true             # Propagación de fuego
/gamerule doTNTExplode true           # Explosiones de TNT

# Configuración de comandos
/gamerule sendCommandFeedback true    # Feedback de comandos
/gamerule commandBlockOutput true     # Output de command blocks

# Configuración de spawn
/gamerule spawnRadius 10              # Radio de spawn aleatorio
/gamerule spectatorsGenerateChunks true # Spectators generan chunks

# Configuraciones avanzadas
/gamerule randomTickSpeed 3           # Velocidad de ticks aleatorios
/gamerule maxEntityCramming 24        # Máximo de entidades por bloque
/gamerule playersSleepingPercentage 100 # % jugadores que deben dormir
```

## 👥 Configuración de Jugadores

### Gestión de Whitelist
```bash
# Archivo de configuración de whitelist
sudo -u minecraft nano /opt/minecraft/server/whitelist.json
```

```json
[
  {
    "uuid": "UUID-DEL-JUGADOR-1",
    "name": "Jugador1"
  },
  {
    "uuid": "UUID-DEL-JUGADOR-2", 
    "name": "Jugador2"
  }
]
```

```bash
# Comandos de whitelist (en consola del servidor)
/whitelist add NombreJugador          # Agregar jugador
/whitelist remove NombreJugador       # Remover jugador
/whitelist list                       # Ver lista
/whitelist on                         # Activar whitelist
/whitelist off                        # Desactivar whitelist
/whitelist reload                     # Recargar desde archivo
```

### Configuración de Operadores
```bash
# Archivo de configuración de OPs
sudo -u minecraft nano /opt/minecraft/server/ops.json
```

```json
[
  {
    "uuid": "UUID-DEL-ADMINISTRADOR",
    "name": "Administrador",
    "level": 4,
    "bypassesPlayerLimit": true
  },
  {
    "uuid": "UUID-DEL-MODERADOR",
    "name": "Moderador", 
    "level": 3,
    "bypassesPlayerLimit": false
  }
]
```

```bash
# Niveles de OP:
# 1: Pueden ignorar spawn protection
# 2: Pueden usar comandos básicos (/clear, /difficulty, /effect, etc.)
# 3: Pueden usar comandos de moderación (/ban, /kick, /op, etc.)
# 4: Pueden usar todos los comandos (/stop, configuraciones, etc.)

# Comandos de OP (en consola del servidor)
/op NombreJugador                     # Dar OP nivel 4
/deop NombreJugador                   # Remover OP
```

### Configuración de Bans
```bash
# Bans de jugadores
sudo -u minecraft nano /opt/minecraft/server/banned-players.json

# Bans de IPs
sudo -u minecraft nano /opt/minecraft/server/banned-ips.json

# Comandos de ban (en consola del servidor)
/ban NombreJugador Razón del ban      # Banear jugador
/ban-ip 192.168.1.100 Razón          # Banear IP
/pardon NombreJugador                 # Desbanear jugador
/pardon-ip 192.168.1.100              # Desbanear IP
/banlist players                      # Ver jugadores baneados
/banlist ips                          # Ver IPs baneadas
```

## 🌐 Configuración de Red

### Configuración de Puertos
```bash
# Puertos utilizados por Minecraft
# 25565 - Puerto principal del servidor
# 25575 - Puerto RCON (administración)
# 19132 - Puerto Bedrock (si usas Geyser)

# Verificar puertos en uso
sudo ss -tulpn | grep -E ":(25565|25575|19132)"

# Configurar firewall
sudo ufw allow 25565/tcp comment 'Minecraft Java'
sudo ufw allow 25575/tcp comment 'Minecraft RCON'
```

### Configuración de RCON
```bash
# Habilitar RCON en server.properties
enable-rcon=true
rcon.port=25575
rcon.password=TU_PASSWORD_SEGURO

# Cliente RCON desde terminal
sudo apt install mcrcon -y

# Conectar con RCON
mcrcon -H localhost -P 25575 -p TU_PASSWORD_SEGURO

# Ejemplo de uso
mcrcon -H localhost -P 25575 -p password "list"
mcrcon -H localhost -P 25575 -p password "save-all"
```

### Configuración de Proxy (BungeeCord/Velocity)
```bash
# Para servidores múltiples con proxy
# server.properties para servidor detrás de proxy:

# Desactivar autenticación online (el proxy la maneja)
online-mode=false

# Configurar IP específica del servidor
server-ip=127.0.0.1
server-port=25566  # Puerto interno diferente

# Habilitar modo proxy
# (Requiere plugin/mod compatible)
```

## ⚡ Configuración de Rendimiento

### Optimizaciones de JVM
```bash
# Editar iniciador optimizado
sudo -u minecraft nano /opt/minecraft/server/iniciador_optimizado_de_minecraft.sh

# Configuraciones de memoria por hardware:

# Para 2-4GB RAM total:
JAVA_OPTS="-Xms1G -Xmx2G"

# Para 4-8GB RAM total:
JAVA_OPTS="-Xms2G -Xmx4G"

# Para 8-16GB RAM total:
JAVA_OPTS="-Xms4G -Xmx8G"

# Para 16GB+ RAM total:
JAVA_OPTS="-Xms8G -Xmx12G"
```

### Configuraciones de Rendimiento del Servidor
```bash
# server.properties - Optimizaciones de rendimiento

# Reducir distancia de vista para mejor rendimiento
view-distance=8                       # En lugar de 10
simulation-distance=6                 # En lugar de 10

# Optimizar compresión de red
network-compression-threshold=256     # Comprimir paquetes >256 bytes

# Limitar jugadores según hardware
max-players=20                        # Ajustar según CPU/RAM

# Optimizar entity broadcast
entity-broadcast-range-percentage=80  # Reducir de 100 a 80

# Configuración de chunks
sync-chunk-writes=true                # true = más estable, false = más rápido
```

### Configuraciones de Sistema
```bash
# Ya aplicadas por scripts de optimización
# Verificar que estén activas:

# Configuraciones de red
sysctl net.ipv4.tcp_keepalive_time
sysctl net.ipv4.tcp_keepalive_intvl
sysctl net.core.rmem_max
sysctl net.core.wmem_max

# Configuraciones de memoria  
sysctl vm.swappiness
sysctl vm.dirty_ratio
sysctl vm.overcommit_memory

# Configuraciones de I/O
cat /sys/block/sda/queue/scheduler
```

## 🧩 Configuración de Mods

### Configuración de Fabric
```bash
# Archivo de configuración de Fabric
sudo -u minecraft nano /opt/minecraft/server/.fabric/remappedJars.txt

# Configuración de dependencias
sudo -u minecraft nano /opt/minecraft/server/config/fabric_loader_dependencies.json
```

### Configuración de Mods Específicos

#### Lithium (Optimización)
```bash
sudo -u minecraft nano /opt/minecraft/server/config/lithium.properties
```

```properties
# Configuración de optimizaciones Lithium
# true = habilitar optimización, false = deshabilitar

# Optimizaciones de IA y pathfinding
mixin.ai.pathing=true
mixin.ai.nearby_entity_tracking=true

# Optimizaciones de bloques
mixin.block.hopper=true
mixin.block.redstone=true

# Optimizaciones de chunks
mixin.chunk.serialization=true
mixin.chunk.fast_chunk_serialization=true

# Optimizaciones de entidades
mixin.entity.collisions=true
mixin.entity.fast_entity_movement=true

# Optimizaciones de mundo
mixin.world.block_entity_ticking=true
mixin.world.chunk_ticking=true
```

#### Carpet (Herramientas técnicas)
```bash
# Configuración desde consola del servidor
# Optimizaciones de rendimiento
/carpet setDefault lagFreeSpawning true
/carpet setDefault optimizedTNT true
/carpet setDefault fastRedstoneDust true

# Funciones técnicas
/carpet setDefault stackableShulkerBoxes true
/carpet setDefault pushLimit 12
/carpet setDefault fillLimit 32768

# Configuraciones de spawn
/carpet setDefault spawnChunksSize 2
/carpet setDefault desertShrubs true

# Guardar configuración
/carpet save
```

#### LuckPerms (Permisos)
```bash
sudo -u minecraft nano /opt/minecraft/server/config/luckperms/luckperms.conf
```

```conf
# Configuración básica de LuckPerms

# Método de almacenamiento
storage-method = sqlite

# Configuración de base de datos SQLite
data {
    address = "luckperms-sqlite.db"
}

# Para MySQL (servidores grandes):
# storage-method = mysql
# data {
#     address = "localhost:3306"
#     database = "minecraft"
#     username = "luckperms_user"  
#     password = "password_seguro"
# }

# Configuración de servidor
server = "server"
include-global = true
include-global-world = true

# Configuración de grupos
group-name-rewrite {
    default = "jugador"
    admin = "administrador"
    mod = "moderador"
}

# Configuraciones adicionales
primary-group-calculation = stored
argument-based-command-permissions = false
log-notify = true
auto-op = true
commands-allow-op = true
```

## 🔧 Configuración Avanzada

### Configuración de Base de Datos
```bash
# Para servidores grandes, configurar MySQL
sudo apt install mysql-server -y

# Configurar base de datos
sudo mysql -u root -p
```

```sql
-- Crear base de datos para Minecraft
CREATE DATABASE minecraft_server;

-- Crear usuario específico
CREATE USER 'minecraft_user'@'localhost' IDENTIFIED BY 'password_seguro';

-- Otorgar permisos
GRANT ALL PRIVILEGES ON minecraft_server.* TO 'minecraft_user'@'localhost';
FLUSH PRIVILEGES;

-- Crear tablas para plugins que las necesiten
USE minecraft_server;

-- Tabla para LuckPerms
CREATE TABLE luckperms_actions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    time BIGINT NOT NULL,
    actor_uuid CHAR(36) NOT NULL,
    actor_name VARCHAR(100) NOT NULL,
    type CHAR(1) NOT NULL,
    acted_uuid CHAR(36),
    acted_name VARCHAR(36),
    action VARCHAR(300) NOT NULL
);
```

### Configuración de Monitoreo
```bash
# Configurar monitoreo con Prometheus (opcional)
sudo nano /opt/minecraft/config/prometheus.yml
```

```yaml
global:
  scrape_interval: 15s

rule_files:
  - "minecraft_rules.yml"

scrape_configs:
  - job_name: 'minecraft-server'
    static_configs:
      - targets: ['localhost:9225']
    scrape_interval: 5s
```

### Configuración de Logging Avanzado
```bash
# Configurar log4j2 personalizado
sudo -u minecraft nano /opt/minecraft/server/log4j2.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN">
    <Appenders>
        <!-- Consola -->
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout pattern="[%d{HH:mm:ss}] [%t/%level]: %msg%n"/>
        </Console>
        
        <!-- Archivo de logs -->
        <RollingFile name="File" fileName="logs/latest.log" 
                     filePattern="logs/%d{yyyy-MM-dd}-%i.log.gz">
            <PatternLayout pattern="[%d{HH:mm:ss}] [%t/%level]: %msg%n"/>
            <Policies>
                <TimeBasedTriggeringPolicy/>
                <SizeBasedTriggeringPolicy size="100 MB"/>
            </Policies>
            <DefaultRolloverStrategy max="30"/>
        </RollingFile>
        
        <!-- Logs de seguridad separados -->
        <RollingFile name="SecurityFile" fileName="logs/security.log"
                     filePattern="logs/security-%d{yyyy-MM-dd}-%i.log.gz">
            <PatternLayout pattern="[%d{HH:mm:ss}] [SECURITY]: %msg%n"/>
            <Policies>
                <TimeBasedTriggeringPolicy/>
                <SizeBasedTriggeringPolicy size="50 MB"/>
            </Policies>
        </RollingFile>
    </Appenders>
    
    <Loggers>
        <!-- Logger específico para eventos de seguridad -->
        <Logger name="minecraft.security" level="INFO" additivity="false">
            <AppenderRef ref="SecurityFile"/>
        </Logger>
        
        <!-- Logger principal -->
        <Root level="INFO">
            <AppenderRef ref="Console"/>
            <AppenderRef ref="File"/>
        </Root>
    </Loggers>
</Configuration>
```

### Scripts de Configuración Automatizada
```bash
# Script para configuración rápida
sudo nano /opt/minecraft/scripts/quick-config.sh
```

```bash
#!/bin/bash
# quick-config.sh - Configuración rápida del servidor

SERVER_NAME="$1"
MAX_PLAYERS="$2"
DIFFICULTY="$3"
GAMEMODE="$4"

if [ $# -lt 4 ]; then
    echo "Uso: $0 'Nombre del Servidor' <max_players> <difficulty> <gamemode>"
    echo "Ejemplo: $0 'Mi Servidor' 20 normal survival"
    exit 1
fi

CONFIG_FILE="/opt/minecraft/server/server.properties"

echo "🔧 Configurando servidor: $SERVER_NAME"

# Backup de configuración actual
cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%Y%m%d-%H%M%S)"

# Aplicar configuraciones básicas
sed -i "s/motd=.*/motd=$SERVER_NAME/" "$CONFIG_FILE"
sed -i "s/max-players=.*/max-players=$MAX_PLAYERS/" "$CONFIG_FILE"
sed -i "s/difficulty=.*/difficulty=$DIFFICULTY/" "$CONFIG_FILE"
sed -i "s/gamemode=.*/gamemode=$GAMEMODE/" "$CONFIG_FILE"

# Configuraciones de rendimiento automáticas
RAM_TOTAL=$(free -g | awk 'NR==2{printf "%.0f", $2}')

if [ $RAM_TOTAL -ge 8 ]; then
    sed -i "s/view-distance=.*/view-distance=10/" "$CONFIG_FILE"
    sed -i "s/simulation-distance=.*/simulation-distance=8/" "$CONFIG_FILE"
elif [ $RAM_TOTAL -ge 4 ]; then
    sed -i "s/view-distance=.*/view-distance=8/" "$CONFIG_FILE"
    sed -i "s/simulation-distance=.*/simulation-distance=6/" "$CONFIG_FILE"
else
    sed -i "s/view-distance=.*/view-distance=6/" "$CONFIG_FILE"
    sed -i "s/simulation-distance=.*/simulation-distance=4/" "$CONFIG_FILE"
fi

# Configuraciones de seguridad
sed -i "s/online-mode=.*/online-mode=true/" "$CONFIG_FILE"
sed -i "s/white-list=.*/white-list=false/" "$CONFIG_FILE"

echo "✅ Configuración completada"
echo "📝 Backup guardado como: $CONFIG_FILE.backup.*"
echo "🔄 Reinicia el servidor para aplicar cambios"
```

## 📊 Configuraciones por Tipo de Servidor

### Servidor de Supervivencia Vanilla
```properties
# Configuración para servidor survival clásico
gamemode=survival
difficulty=normal
spawn-protection=16
pvp=true
allow-flight=false
enable-command-block=false
generate-structures=true
spawn-monsters=true
spawn-animals=true
max-players=20
view-distance=10
```

### Servidor Creativo
```properties
# Configuración para servidor creativo
gamemode=creative
difficulty=peaceful
spawn-protection=0
pvp=false
allow-flight=true
enable-command-block=true
generate-structures=true
spawn-monsters=false
spawn-animals=true
max-players=30
view-distance=12
max-build-height=320
```

### Servidor Técnico/Redstone
```properties
# Configuración para servidor técnico
gamemode=survival
difficulty=normal
spawn-protection=0
pvp=false
allow-flight=true
enable-command-block=true
generate-structures=false
spawn-monsters=true
spawn-animals=false
max-players=15
view-distance=12
simulation-distance=10

# Gamerules adicionales (configurar en consola):
# /gamerule mobGriefing false
# /gamerule doFireTick false
# /gamerule randomTickSpeed 0
```

### Servidor PvP
```properties
# Configuración para servidor PvP
gamemode=survival
difficulty=hard
spawn-protection=0
pvp=true
allow-flight=false
enable-command-block=false
generate-structures=true
spawn-monsters=true
spawn-animals=true
max-players=50
view-distance=8
simulation-distance=6
network-compression-threshold=128

# Configurar respawn rápido:
# /gamerule doImmediateRespawn true
```

---

¿Necesitas ayuda con alguna configuración específica? Consulta la [documentación completa](WIKI_HOME.md) o [crea un issue](../../issues/new/choose) con tu pregunta.