#!/bin/bash

#=============================================================================
# 🚀 Iniciador Optimizado de Minecraft Fabric Server
# Versión: 2.0
# Soporte: ARM y x86/x64
# Autor: Optimizado para máximo rendimiento
#=============================================================================

set -euo pipefail  # Modo estricto para mejor manejo de errores

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Verificar si estamos en el directorio correcto
if [[ ! -f "fabric-server-launch.jar" ]]; then
    error "No se encontró fabric-server-launch.jar en el directorio actual"
fi

# Detectar RAM disponible
AVAILABLE_RAM=$(free -m | awk 'NR==2{printf "%.0f", $7/1024}')
log "RAM disponible: ${AVAILABLE_RAM}GB"

# Configurar RAM automáticamente (70% de la RAM disponible)
if [[ $AVAILABLE_RAM -ge 8 ]]; then
    RAM_SIZE="6G"
elif [[ $AVAILABLE_RAM -ge 4 ]]; then
    RAM_SIZE="3G"
elif [[ $AVAILABLE_RAM -ge 2 ]]; then
    RAM_SIZE="1G"
else
    warn "RAM insuficiente detectada. Usando 512M"
    RAM_SIZE="512M"
fi

log "Asignando ${RAM_SIZE} de RAM al servidor"

# Detectar arquitectura
ARCH=$(uname -m)
log "Arquitectura detectada: ${ARCH}"

# Flags JVM optimizados (Aikar's flags + optimizaciones adicionales)
JAVA_OPTS="-Xmx${RAM_SIZE} -Xms${RAM_SIZE}"
JAVA_OPTS+=" -XX:+UseG1GC"
JAVA_OPTS+=" -XX:+ParallelRefProcEnabled"
JAVA_OPTS+=" -XX:MaxGCPauseMillis=200"
JAVA_OPTS+=" -XX:+UnlockExperimentalVMOptions"
JAVA_OPTS+=" -XX:+DisableExplicitGC"
JAVA_OPTS+=" -XX:+AlwaysPreTouch"
JAVA_OPTS+=" -XX:G1NewSizePercent=30"
JAVA_OPTS+=" -XX:G1MaxNewSizePercent=40"
JAVA_OPTS+=" -XX:G1HeapRegionSize=8M"
JAVA_OPTS+=" -XX:G1ReservePercent=20"
JAVA_OPTS+=" -XX:G1HeapWastePercent=5"
JAVA_OPTS+=" -XX:G1MixedGCCountTarget=4"
JAVA_OPTS+=" -XX:InitiatingHeapOccupancyPercent=15"
JAVA_OPTS+=" -XX:G1MixedGCLiveThresholdPercent=90"
JAVA_OPTS+=" -XX:G1RSetUpdatingPauseTimePercent=5"
JAVA_OPTS+=" -XX:SurvivorRatio=32"
JAVA_OPTS+=" -XX:+PerfDisableSharedMem"
JAVA_OPTS+=" -XX:MaxTenuringThreshold=1"
JAVA_OPTS+=" -Dusing.aikars.flags=https://mcflags.emc.gs"
JAVA_OPTS+=" -Daikars.new.flags=true"
JAVA_OPTS+=" -Dfabric.skipMcProvider=true"

# Optimizaciones específicas por arquitectura
if [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
    log "Aplicando optimizaciones para ARM64"
    JAVA_OPTS+=" -XX:+UseStringDeduplication"
elif [[ "$ARCH" == "x86_64" ]]; then
    log "Aplicando optimizaciones para x86_64"
    JAVA_OPTS+=" -XX:+UseStringDeduplication"
    JAVA_OPTS+=" -XX:+UseFastUnorderedTimeStamps"
fi

# Crear directorio de logs si no existe
mkdir -p logs

# Función para limpiar al salir
cleanup() {
    log "Cerrando servidor de forma segura..."
    exit 0
}

trap cleanup SIGINT SIGTERM

# Mostrar configuración
log "=== CONFIGURACIÓN DEL SERVIDOR ==="
log "Archivo JAR: fabric-server-launch.jar"
log "RAM asignada: ${RAM_SIZE}"
log "Arquitectura: ${ARCH}"
log "Java flags: ${JAVA_OPTS}"
log "=================================="

# Verificar Java
if ! command -v java &> /dev/null; then
    error "Java no está instalado o no está en el PATH"
fi

JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
if [[ $JAVA_VERSION -lt 17 ]]; then
    error "Se requiere Java 17 o superior. Versión actual: $JAVA_VERSION"
fi

log "Java versión: $JAVA_VERSION ✓"

# Crear archivo de inicio de emergencia
cat > start_emergency.sh << 'EOF'
#!/bin/bash
# Script de emergencia con configuración mínima
java -Xmx1G -Xms1G -jar fabric-server-launch.jar nogui
EOF
chmod +x start_emergency.sh

log "Archivo de emergencia creado: start_emergency.sh"

# Iniciar servidor
log "🚀 Iniciando servidor Minecraft Fabric..."
log "Presiona Ctrl+C para cerrar de forma segura"

exec java $JAVA_OPTS -jar fabric-server-launch.jar nogui
