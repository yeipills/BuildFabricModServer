# 🔌 API Documentation

Esta documentación describe todas las interfaces, scripts y configuraciones disponibles en BuildFabricModServer.

## 📋 Tabla de Contenidos

- [Scripts API](#-scripts-api)
- [Configuration API](#-configuration-api)
- [Docker API](#-docker-api)
- [Monitoring API](#-monitoring-api)
- [Examples](#-examples)

## 🛠️ Scripts API

### `install.sh` - Instalador Principal

#### Sintaxis
```bash
./install.sh [OPTIONS]
```

#### Opciones
| Opción | Descripción | Valor por Defecto |
|--------|-------------|-------------------|
| `--minecraft-version VERSION` | Versión de Minecraft | 1.20.4 |
| `--fabric-version VERSION` | Versión de Fabric | 0.15.6 |
| `--install-dir PATH` | Directorio de instalación | /opt/minecraft |
| `--user USERNAME` | Usuario del servidor | minecraft |
| `--no-optimization` | Saltar optimizaciones del sistema | false |
| `--docker-only` | Solo preparar para Docker | false |
| `--help` | Mostrar ayuda | - |

#### Códigos de Salida
- `0`: Instalación exitosa
- `1`: Error en prerrequisitos
- `2`: Error en descarga de archivos
- `3`: Error en configuración
- `4`: Error en permisos

#### Ejemplo
```bash
# Instalación básica
./install.sh

# Instalación con versiones específicas
./install.sh --minecraft-version 1.20.1 --fabric-version 0.15.0

# Instalación en directorio personalizado
./install.sh --install-dir /home/minecraft --user mc-server
```

---

### `update-server.sh` - Actualizador del Servidor

#### Sintaxis
```bash
./update-server.sh [OPTIONS]
```

#### Opciones
| Opción | Descripción | Requerido |
|--------|-------------|-----------|
| `-m, --minecraft VERSION` | Nueva versión de Minecraft | Sí |
| `-f, --fabric VERSION` | Nueva versión de Fabric | Sí |
| `-b, --backup-only` | Solo crear backup | No |
| `-c, --check-versions` | Ver versiones disponibles | No |
| `-r, --restore BACKUP` | Restaurar desde backup | No |
| `--no-backup` | Saltar creación de backup | No |
| `--force` | Forzar actualización sin confirmación | No |

#### Códigos de Salida
- `0`: Actualización exitosa
- `1`: Error en parámetros
- `2`: Error en backup
- `3`: Error en descarga
- `4`: Error en instalación
- `5`: Servidor no se pudo detener

#### Ejemplo
```bash
# Actualización completa
./update-server.sh -m 1.20.4 -f 0.15.6

# Solo crear backup
./update-server.sh -b

# Verificar versiones disponibles
./update-server.sh -c

# Restaurar desde backup
./update-server.sh -r minecraft_backup_20240130_120000.tar.gz
```

---

### `benchmark.sh` - Suite de Benchmarking

#### Sintaxis
```bash
./benchmark.sh [OPTIONS]
```

#### Opciones
| Opción | Descripción | Duración por Defecto |
|--------|-------------|---------------------|
| `-t, --time SEGUNDOS` | Duración del benchmark | 300s |
| `-q, --quick` | Benchmark rápido | 60s |
| `-s, --stress` | Incluir pruebas de estrés | - |
| `-c, --cpu-only` | Solo pruebas de CPU | - |
| `-m, --memory-only` | Solo pruebas de memoria | - |
| `-n, --network-only` | Solo pruebas de red | - |
| `-j, --java-only` | Solo pruebas de Java | - |
| `-r, --report` | Solo generar reporte | - |

#### Salidas
- **Archivos de resultados**: `/opt/minecraft/benchmark_results/`
- **Reporte HTML**: `benchmark_report.html`
- **Logs completos**: `benchmark_YYYYMMDD_HHMMSS.log`

#### Ejemplo
```bash
# Benchmark completo
./benchmark.sh

# Benchmark rápido con estrés
./benchmark.sh -q -s

# Solo pruebas de CPU por 10 minutos
./benchmark.sh -c -t 600

# Generar solo reporte de resultados anteriores
./benchmark.sh -r
```

---

### `docker-run.sh` - Gestor Docker

#### Sintaxis
```bash
./docker-run.sh [COMMAND] [OPTIONS]
```

#### Comandos
| Comando | Descripción | Opciones |
|---------|-------------|----------|
| `build` | Construir imagen | `--no-cache` |
| `start` | Iniciar servicios | - |
| `stop` | Detener servicios | - |
| `restart` | Reiniciar servicios | - |
| `logs` | Ver logs | `-f, --follow` |
| `status` | Ver estado | - |
| `backup` | Crear backup manual | - |
| `restore ARCHIVO` | Restaurar backup | - |
| `clean` | Limpiar todo | - |
| `update` | Actualizar y reiniciar | - |
| `shell` | Abrir shell en contenedor | - |
| `console` | Conectar a consola del servidor | - |

#### Ejemplo
```bash
# Construir e iniciar
./docker-run.sh build
./docker-run.sh start

# Ver logs en tiempo real
./docker-run.sh logs -f

# Crear backup y actualizar
./docker-run.sh backup
./docker-run.sh update

# Conectar a consola del servidor
./docker-run.sh console
```

---

## ⚙️ Configuration API

### server.properties

#### Configuraciones Críticas de Rendimiento

```properties
# === RENDIMIENTO ===
view-distance=10                    # Distancia de render (8-16)
simulation-distance=10              # Distancia de simulación (6-12)
max-players=20                      # Jugadores máximos
network-compression-threshold=256   # Compresión de red (256-512)
max-tick-time=60000                # Timeout de tick (60000ms)
use-native-transport=true          # Transporte nativo

# === MUNDO ===
level-type=minecraft:normal        # Tipo de mundo
generate-structures=true           # Generar estructuras
spawn-protection=16               # Protección del spawn

# === JUGABILIDAD ===
gamemode=survival                 # Modo de juego
difficulty=normal                 # Dificultad
pvp=true                         # PvP habilitado
hardcore=false                   # Modo hardcore
```

#### Configuraciones por RAM Disponible

**2GB RAM:**
```properties
max-players=10
view-distance=8
simulation-distance=6
network-compression-threshold=512
```

**4GB RAM:**
```properties
max-players=20
view-distance=10
simulation-distance=8
network-compression-threshold=256
```

**8GB+ RAM:**
```properties
max-players=50
view-distance=12
simulation-distance=10
network-compression-threshold=-1
```

### fabric-server-launcher.properties

#### Configuraciones de Fabric

```properties
# === FABRIC CORE ===
fabricVersion=0.15.6              # Versión del loader
minecraftVersion=1.20.4           # Versión de Minecraft
serverJar=server.jar              # JAR del servidor

# === OPTIMIZACIÓN ===
fabric.skipMcProvider=true         # Saltar provider de MC
fabric.development=false           # Modo desarrollo
fabric.gameJarProcessing.publishDependencies=false

# === MODS ===
fabric.modsDir=mods               # Directorio de mods
fabric.loadNestedJars=true        # Cargar JARs anidados

# === CACHE ===
fabric.cacheDir=.fabric/cache     # Directorio de cache
fabric.clearCache=false           # Limpiar cache en inicio
```

---

## 🐳 Docker API

### docker-compose.yml

#### Servicios Disponibles

```yaml
services:
  minecraft-server:    # Servidor principal
    environment:
      - EULA=true       # Aceptar EULA automáticamente
      - SERVER_PORT=25565
      - MAX_PLAYERS=20
      - DIFFICULTY=normal
      - GAMEMODE=survival
      - JAVA_OPTS=...   # Configuración JVM
    
  minecraft-backup:    # Servicio de backup
    environment:
      - BACKUP_INTERVAL=24h
      - BACKUP_RETENTION=7
    
  minecraft-monitor:   # Monitoreo
    environment:
      - MONITOR_INTERVAL=60s
```

#### Variables de Entorno

| Variable | Servicio | Descripción | Valor por Defecto |
|----------|----------|-------------|-------------------|
| `EULA` | minecraft-server | Aceptar EULA | false |
| `SERVER_PORT` | minecraft-server | Puerto del servidor | 25565 |
| `MAX_PLAYERS` | minecraft-server | Jugadores máximos | 20 |
| `DIFFICULTY` | minecraft-server | Dificultad | normal |
| `GAMEMODE` | minecraft-server | Modo de juego | survival |
| `LEVEL_NAME` | minecraft-server | Nombre del mundo | world |
| `MOTD` | minecraft-server | Mensaje del día | "Servidor Fabric" |
| `JAVA_OPTS` | minecraft-server | Opciones JVM | Auto |
| `BACKUP_INTERVAL` | minecraft-backup | Intervalo de backup | 24h |
| `BACKUP_RETENTION` | minecraft-backup | Días de retención | 7 |
| `MONITOR_INTERVAL` | minecraft-monitor | Intervalo de monitoreo | 60s |

#### Volúmenes

| Volumen | Ruta en Contenedor | Descripción |
|---------|-------------------|-------------|
| `minecraft_world` | `/opt/minecraft/server/world` | Mundo del servidor |
| `minecraft_mods` | `/opt/minecraft/server/mods` | Mods instalados |
| `minecraft_backups` | `/opt/minecraft/backups` | Backups automáticos |
| `minecraft_config` | `/opt/minecraft/server/config` | Configuraciones |
| `minecraft_logs` | `/opt/minecraft/server/logs` | Logs del servidor |

---

## 📊 Monitoring API

### Scripts de Monitoreo

#### `monitor.sh` (Generado automáticamente)

```bash
# Información del sistema
/opt/minecraft/monitor.sh

# Salida esperada:
=== ESTADO DEL SERVIDOR MINECRAFT ===
Fecha: 2024-01-30 12:00:00
Uptime: up 2 days, 4 hours, 30 minutes
Arquitectura: x86_64

=== CPU ===
Cores: 4
Load Average: 0.25, 0.30, 0.28
CPU Usage: User: 15.2%, System: 5.8%, Idle: 79.0%

=== MEMORIA ===
               total    used    free  shared  buff/cache   available
Mem:           7.8Gi   2.1Gi   3.2Gi   105Mi       2.5Gi       5.4Gi
Swap:          2.0Gi      0B   2.0Gi

=== PROCESOS JAVA ===
12345  1234  25.5  12.8  java -Xmx4G -jar fabric-server-launch.jar

=== RED ===
Puertos Minecraft:
LISTEN    0    128    *:25565    *:*

=== DISCO ===
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        98G   45G   49G  48% /
/dev/sda2       100G   12G   83G  13% /opt
```

#### Métricas JSON (Disponible programáticamente)

```bash
# Generar métricas en formato JSON
/opt/minecraft/monitor.sh --json

# Salida:
{
  "timestamp": "2024-01-30T12:00:00Z",
  "system": {
    "architecture": "x86_64",
    "uptime_seconds": 183000,
    "load_average": [0.25, 0.30, 0.28]
  },
  "cpu": {
    "cores": 4,
    "usage_percent": {
      "user": 15.2,
      "system": 5.8,
      "idle": 79.0
    }
  },
  "memory": {
    "total_mb": 8192,
    "used_mb": 2150,
    "free_mb": 3276,
    "available_mb": 5530
  },
  "minecraft": {
    "process_id": 12345,
    "cpu_percent": 25.5,
    "memory_percent": 12.8,
    "port_active": true
  },
  "disk": {
    "root_usage_percent": 48,
    "opt_usage_percent": 13
  }
}
```

### Benchmark API

#### Resultados de Benchmark

```bash
# Estructura de archivos de resultado
benchmark_results/
├── system_info.txt           # Información del sistema
├── cpu_benchmark.txt         # Resultados de CPU
├── memory_benchmark.txt      # Resultados de memoria  
├── network_benchmark.txt     # Resultados de red
├── java_benchmark.txt        # Resultados de Java
├── minecraft_benchmark.txt   # Resultados específicos MC
├── benchmark_YYYYMMDD_HHMMSS.log  # Log completo
└── benchmark_report.html     # Reporte HTML
```

#### Métricas de Benchmark

```json
{
  "benchmark_id": "20240130_120000",
  "duration_seconds": 300,
  "system_info": {
    "architecture": "x86_64",
    "cpu_cores": 4,
    "total_ram_gb": 8,
    "java_version": "17.0.2"
  },
  "results": {
    "cpu": {
      "score": 850,
      "multi_thread_score": 3200,
      "average_usage_percent": 85.5
    },
    "memory": {
      "read_speed_mbps": 2400,
      "write_speed_mbps": 1800,
      "latency_ns": 120
    },
    "network": {
      "ping_google_ms": 15,
      "ping_cloudflare_ms": 12,
      "connectivity_score": 95
    },
    "java": {
      "calculation_time_ms": 1250,
      "memory_allocation_time_ms": 890,
      "gc_performance_score": 88
    }
  }
}
```

---

## 💡 Examples

### Instalación Completa Automatizada

```bash
#!/bin/bash
# Instalación completa con optimizaciones

# 1. Clonar repositorio
git clone https://github.com/user/BuildFabricModServer.git
cd BuildFabricModServer

# 2. Ejecutar instalación
./install.sh --minecraft-version 1.20.4 --fabric-version 0.15.6

# 3. Aplicar optimizaciones del sistema
if [[ $(uname -m) =~ ^(arm|aarch64) ]]; then
    ./script_optimizacion_debian_11_ARM.sh
else
    ./script_optimizacion_debian_11_x86-x86_64.sh
fi

# 4. Configurar servidor
sudo -u minecraft nano /opt/minecraft/server/server.properties
# Cambiar configuraciones necesarias

# 5. Aceptar EULA
sudo -u minecraft sed -i 's/eula=false/eula=true/' /opt/minecraft/server/eula.txt

# 6. Iniciar servidor
sudo systemctl start minecraft-fabric
sudo systemctl enable minecraft-fabric

# 7. Verificar estado
sudo systemctl status minecraft-fabric
```

### Despliegue con Docker

```bash
#!/bin/bash
# Despliegue completo con Docker

# 1. Preparar archivos
git clone https://github.com/user/BuildFabricModServer.git
cd BuildFabricModServer

# 2. Configurar Docker Compose
cp docker-compose.yml docker-compose.local.yml
sed -i 's/EULA=false/EULA=true/' docker-compose.local.yml

# 3. Construir e iniciar
./docker-run.sh build
./docker-run.sh start

# 4. Monitorear inicio
./docker-run.sh logs -f

# 5. Verificar estado
./docker-run.sh status

# 6. Crear primer backup
./docker-run.sh backup
```

### Automatización de Actualizaciones

```bash
#!/bin/bash
# Script para automatizar actualizaciones semanales

# Configuración
MINECRAFT_VERSION="1.20.4"
FABRIC_VERSION="0.15.6"
LOG_FILE="/var/log/minecraft-update.log"

# Función de logging
log() {
    echo "[$(date)] $1" | tee -a "$LOG_FILE"
}

# Actualización
log "Iniciando actualización automática"

# Crear backup pre-actualización
if ./update-server.sh -b; then
    log "Backup creado exitosamente"
else
    log "ERROR: Falló la creación del backup"
    exit 1
fi

# Actualizar servidor
if ./update-server.sh -m "$MINECRAFT_VERSION" -f "$FABRIC_VERSION"; then
    log "Actualización completada exitosamente"
    
    # Ejecutar benchmark post-actualización
    ./benchmark.sh -q
    log "Benchmark post-actualización completado"
    
else
    log "ERROR: Falló la actualización"
    
    # Restaurar desde backup más reciente
    LATEST_BACKUP=$(ls -t /opt/minecraft/backups/*.tar.gz | head -1)
    if ./update-server.sh -r "$LATEST_BACKUP"; then
        log "Restauración desde backup exitosa"
    else
        log "ERROR: Falló la restauración"
    fi
fi

log "Proceso de actualización finalizado"
```

### Monitoreo Avanzado

```bash
#!/bin/bash
# Script de monitoreo avanzado con alertas

# Configuración
ALERT_EMAIL="admin@example.com"
ALERT_DISCORD_WEBHOOK="https://discord.com/api/webhooks/..."
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90

# Obtener métricas
METRICS=$(/opt/minecraft/monitor.sh --json)
CPU_USAGE=$(echo "$METRICS" | jq -r '.cpu.usage_percent.user + .cpu.usage_percent.system')
MEMORY_USAGE=$(echo "$METRICS" | jq -r '.memory.used_mb * 100 / .memory.total_mb')
DISK_USAGE=$(echo "$METRICS" | jq -r '.disk.root_usage_percent')

# Función de alerta
send_alert() {
    local message="$1"
    
    # Email
    echo "$message" | mail -s "Alerta Minecraft Server" "$ALERT_EMAIL"
    
    # Discord
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"🚨 **Alerta Minecraft Server**\n$message\"}" \
         "$ALERT_DISCORD_WEBHOOK"
}

# Verificar umbrales
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    send_alert "CPU usage alto: ${CPU_USAGE}% (threshold: ${CPU_THRESHOLD}%)"
fi

if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
    send_alert "Memoria usage alto: ${MEMORY_USAGE}% (threshold: ${MEMORY_THRESHOLD}%)"
fi

if (( DISK_USAGE > DISK_THRESHOLD )); then
    send_alert "Disco usage alto: ${DISK_USAGE}% (threshold: ${DISK_THRESHOLD}%)"
fi

# Verificar que el servidor esté respondiendo
if ! nc -z localhost 25565; then
    send_alert "Servidor Minecraft no está respondiendo en puerto 25565"
fi
```

### Integración con CI/CD

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    tags: ['v*']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Deploy to server
      run: |
        # Conectar a servidor y actualizar
        ssh ${{ secrets.SERVER_USER }}@${{ secrets.SERVER_HOST }} << 'EOF'
          cd /opt/BuildFabricModServer
          git pull origin main
          
          # Actualizar con nueva versión
          ./update-server.sh -m ${{ env.MINECRAFT_VERSION }} -f ${{ env.FABRIC_VERSION }}
          
          # Ejecutar benchmark post-deploy
          ./benchmark.sh -q
          
          # Verificar estado
          systemctl status minecraft-fabric
        EOF
```

Esta documentación de API proporciona una referencia completa para todos los aspectos programáticos y de configuración del sistema BuildFabricModServer.