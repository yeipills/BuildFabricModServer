# ============================================================================
# 🐳 Dockerfile para Minecraft Fabric Server Optimizado
# Versión: 1.0
# Arquitectura: Multi-arch (ARM64, AMD64)
# Base: OpenJDK 17 Alpine para tamaño mínimo
# ============================================================================

# Usar imagen base multi-arquitectura
FROM --platform=$BUILDPLATFORM openjdk:17-jdk-alpine

# Metadatos de la imagen
LABEL maintainer="BuildFabricModServer"
LABEL description="Servidor Minecraft Fabric optimizado con soporte multi-arquitectura"
LABEL version="1.0"

# Variables de construcción
ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG MINECRAFT_VERSION=1.20.4
ARG FABRIC_VERSION=0.15.6
ARG FABRIC_INSTALLER_VERSION=0.11.2

# Variables de entorno
ENV MINECRAFT_VERSION=${MINECRAFT_VERSION}
ENV FABRIC_VERSION=${FABRIC_VERSION}
ENV JAVA_OPTS="-Xmx2G -Xms2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1"
ENV SERVER_PORT=25565
ENV MAX_PLAYERS=20
ENV DIFFICULTY=normal
ENV GAMEMODE=survival
ENV LEVEL_NAME=world
ENV MOTD="Servidor Minecraft Fabric en Docker"

# Crear usuario no-root para seguridad
RUN addgroup -g 1000 minecraft && \
    adduser -D -s /bin/sh -u 1000 -G minecraft minecraft

# Instalar dependencias del sistema
RUN apk add --no-cache \
    curl \
    wget \
    bash \
    screen \
    tzdata \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# Crear directorios necesarios
RUN mkdir -p /opt/minecraft/server \
             /opt/minecraft/backups \
             /opt/minecraft/logs \
             /opt/minecraft/scripts && \
    chown -R minecraft:minecraft /opt/minecraft

# Establecer directorio de trabajo
WORKDIR /opt/minecraft/server

# Cambiar a usuario minecraft
USER minecraft

# Descargar e instalar Fabric Server
RUN echo "Descargando Fabric Installer v${FABRIC_INSTALLER_VERSION}..." && \
    wget -q "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_INSTALLER_VERSION}/fabric-installer-${FABRIC_INSTALLER_VERSION}.jar" \
    -O fabric-installer.jar && \
    echo "Instalando Fabric Server para Minecraft ${MINECRAFT_VERSION}..." && \
    java -jar fabric-installer.jar server \
         -mcversion ${MINECRAFT_VERSION} \
         -loader ${FABRIC_VERSION} \
         -downloadMinecraft && \
    rm fabric-installer.jar && \
    echo "Fabric Server instalado correctamente"

# Crear directorio de mods
RUN mkdir -p mods

# Descargar Fabric API (última versión compatible)
RUN echo "Intentando descargar Fabric API..." && \
    (wget -q "https://github.com/FabricMC/fabric/releases/latest/download/fabric-api-${MINECRAFT_VERSION}.jar" \
     -O mods/fabric-api.jar || \
     echo "Fabric API no disponible para descarga automática - agregar manualmente")

# Copiar configuraciones por defecto
COPY --chown=minecraft:minecraft configs/server.properties.template server.properties

# Crear script de inicio optimizado para contenedor
RUN cat > start-server.sh << 'EOF' && chmod +x start-server.sh
#!/bin/bash

# Script de inicio para contenedor Docker
set -euo pipefail

# Colores para logs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para shutdown limpio
shutdown_handler() {
    log "Recibida señal de shutdown, cerrando servidor..."
    if [[ -n "${SERVER_PID:-}" ]]; then
        kill -TERM "$SERVER_PID" 2>/dev/null || true
        wait "$SERVER_PID" 2>/dev/null || true
    fi
    log "Servidor cerrado correctamente"
    exit 0
}

trap shutdown_handler SIGTERM SIGINT

log "🚀 Iniciando servidor Minecraft Fabric en contenedor Docker"
log "Versión Minecraft: $MINECRAFT_VERSION"
log "Versión Fabric: $FABRIC_VERSION"
log "Java Opts: $JAVA_OPTS"

# Verificar archivos necesarios
if [[ ! -f "fabric-server-launch.jar" ]]; then
    error "fabric-server-launch.jar no encontrado"
    exit 1
fi

# Configurar server.properties con variables de entorno
log "Configurando server.properties..."
sed -i "s/server-port=25565/server-port=${SERVER_PORT}/" server.properties
sed -i "s/max-players=20/max-players=${MAX_PLAYERS}/" server.properties
sed -i "s/difficulty=normal/difficulty=${DIFFICULTY}/" server.properties
sed -i "s/gamemode=survival/gamemode=${GAMEMODE}/" server.properties
sed -i "s/level-name=world/level-name=${LEVEL_NAME}/" server.properties
sed -i "s/motd=.*/motd=${MOTD}/" server.properties

# Aceptar EULA automáticamente si está configurado
if [[ "${EULA:-false}" == "true" ]]; then
    echo "eula=true" > eula.txt
    log "EULA aceptado automáticamente"
else
    if [[ ! -f eula.txt ]] || ! grep -q "eula=true" eula.txt; then
        warn "EULA no aceptado. Configura EULA=true para aceptar automáticamente"
        echo "eula=false" > eula.txt
    fi
fi

# Mostrar información del sistema
log "=== INFORMACIÓN DEL CONTENEDOR ==="
log "Usuario: $(whoami)"
log "Directorio: $(pwd)"
log "Java version: $(java -version 2>&1 | head -1)"
log "Memoria disponible: $(free -h | awk 'NR==2{print $2}')"
log "Arquitectura: $(uname -m)"
log "=================================="

# Listar mods si existen
if [[ -d "mods" ]] && [[ -n "$(ls -A mods 2>/dev/null)" ]]; then
    log "Mods instalados:"
    ls -la mods/
else
    log "No hay mods instalados"
fi

# Iniciar servidor
log "Iniciando servidor Minecraft..."
java $JAVA_OPTS -jar fabric-server-launch.jar nogui &
SERVER_PID=$!

log "Servidor iniciado con PID: $SERVER_PID"
log "Puerto: $SERVER_PORT"
log "Para detener el contenedor: docker stop <container_name>"

# Esperar a que termine el servidor
wait "$SERVER_PID"

log "Servidor terminado"
EOF

# Crear healthcheck script
RUN cat > healthcheck.sh << 'EOF' && chmod +x healthcheck.sh
#!/bin/bash
# Healthcheck para verificar que el servidor está funcionando

# Verificar si el proceso Java está ejecutándose
if ! pgrep -f "fabric-server-launch.jar" > /dev/null; then
    echo "Servidor no está ejecutándose"
    exit 1
fi

# Verificar si el puerto está escuchando
if ! netstat -tuln 2>/dev/null | grep -q ":${SERVER_PORT:-25565} "; then
    echo "Puerto del servidor no está escuchando"
    exit 1
fi

echo "Servidor saludable"
exit 0
EOF

# Volver a root para configuraciones finales
USER root

# Instalar netstat para healthcheck
RUN apk add --no-cache net-tools

# Volver a usuario minecraft
USER minecraft

# Exponer puerto del servidor
EXPOSE 25565

# Configurar volúmenes para persistencia
VOLUME ["/opt/minecraft/server/world", "/opt/minecraft/server/mods", "/opt/minecraft/backups"]

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ./healthcheck.sh

# Comando por defecto
CMD ["./start-server.sh"]