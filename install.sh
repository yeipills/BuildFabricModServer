#!/bin/bash

#=============================================================================
# 🚀 Instalador Automático de Minecraft Fabric Server
# Versión: 1.0
# Descripción: Instalación completa y automatizada
# Soporte: ARM y x86/x64
#=============================================================================

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables de configuración
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/opt/minecraft"
SERVER_DIR="$INSTALL_DIR/server"
MINECRAFT_VERSION="1.20.4"
FABRIC_VERSION="0.15.6"
FABRIC_INSTALLER_VERSION="0.11.2"

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

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${CYAN}[SUCCESS]${NC} $1"
}

# Función para mostrar banner
show_banner() {
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        🚀 MINECRAFT FABRIC SERVER INSTALLER 🚀              ║
║                                                              ║
║    Instalación automática y optimizada para Fabric          ║
║    Soporte: ARM, x86_64, Debian/Ubuntu                      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Verificar prerrequisitos
check_prerequisites() {
    log "🔍 Verificando prerrequisitos del sistema..."
    
    # Verificar distribución
    if ! command -v apt &> /dev/null; then
        error "Este instalador solo funciona en sistemas Debian/Ubuntu"
    fi
    
    # Verificar permisos
    if [[ $EUID -eq 0 ]]; then
        error "No ejecutes este script como root. Usará sudo cuando sea necesario."
    fi
    
    # Verificar conexión a internet
    if ! ping -c 1 google.com &> /dev/null; then
        error "Se requiere conexión a internet para la instalación"
    fi
    
    # Detectar arquitectura
    ARCH=$(uname -m)
    log "Arquitectura detectada: $ARCH"
    
    # Verificar espacio en disco (mínimo 5GB)
    AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')
    REQUIRED_SPACE=$((5 * 1024 * 1024)) # 5GB en KB
    
    if [[ $AVAILABLE_SPACE -lt $REQUIRED_SPACE ]]; then
        error "Se requieren al menos 5GB de espacio libre en disco"
    fi
    
    success "✅ Todos los prerrequisitos verificados"
}

# Mostrar menú de configuración
show_menu() {
    echo -e "${CYAN}"
    echo "═══════════════════════════════════════════════════════════"
    echo "              CONFIGURACIÓN DE INSTALACIÓN"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "${NC}"
    
    echo "Configuración actual:"
    echo "• Minecraft Version: $MINECRAFT_VERSION"
    echo "• Fabric Loader: $FABRIC_VERSION"
    echo "• Directorio de instalación: $INSTALL_DIR"
    echo "• Arquitectura: $ARCH"
    echo ""
    
    read -p "¿Proceder con la instalación? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        log "Instalación cancelada por el usuario"
        exit 0
    fi
}

# Instalar dependencias
install_dependencies() {
    log "📦 Instalando dependencias del sistema..."
    
    sudo apt update -y
    sudo apt install -y \
        openjdk-17-jdk \
        wget \
        curl \
        unzip \
        screen \
        htop \
        nano \
        git \
        rsync
    
    # Verificar Java
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
        if [[ $JAVA_VERSION -ge 17 ]]; then
            success "✅ Java $JAVA_VERSION instalado correctamente"
        else
            error "Se requiere Java 17 o superior"
        fi
    else
        error "Error al instalar Java"
    fi
}

# Crear usuario y directorios
setup_user_and_directories() {
    log "👤 Configurando usuario y directorios..."
    
    # Crear usuario minecraft si no existe
    if ! id "minecraft" &>/dev/null; then
        sudo useradd -r -m -U -d "$INSTALL_DIR" -s /bin/bash minecraft
        sudo usermod -aG sudo minecraft
        log "Usuario 'minecraft' creado"
    else
        log "Usuario 'minecraft' ya existe"
    fi
    
    # Crear directorios
    sudo mkdir -p "$SERVER_DIR"
    sudo mkdir -p "$INSTALL_DIR/backups"
    sudo mkdir -p "$INSTALL_DIR/logs"
    sudo mkdir -p "$INSTALL_DIR/scripts"
    
    # Establecer permisos
    sudo chown -R minecraft:minecraft "$INSTALL_DIR"
    sudo chmod 755 "$INSTALL_DIR"
    
    success "✅ Usuario y directorios configurados"
}

# Descargar e instalar Fabric
install_fabric() {
    log "🕸️ Descargando e instalando Fabric Server..."
    
    cd "$SERVER_DIR"
    
    # Descargar Fabric Installer
    FABRIC_INSTALLER_URL="https://maven.fabricmc.net/net/fabricmc/fabric-installer/$FABRIC_INSTALLER_VERSION/fabric-installer-$FABRIC_INSTALLER_VERSION.jar"
    
    log "Descargando Fabric Installer..."
    sudo -u minecraft wget -q --show-progress "$FABRIC_INSTALLER_URL" -O fabric-installer.jar
    
    if [[ ! -f "fabric-installer.jar" ]]; then
        error "Error al descargar Fabric Installer"
    fi
    
    # Instalar Fabric Server
    log "Instalando Fabric Server para Minecraft $MINECRAFT_VERSION..."
    sudo -u minecraft java -jar fabric-installer.jar server \
        -mcversion "$MINECRAFT_VERSION" \
        -loader "$FABRIC_VERSION" \
        -downloadMinecraft
    
    # Verificar instalación
    if [[ -f "fabric-server-launch.jar" ]]; then
        success "✅ Fabric Server instalado correctamente"
        sudo -u minecraft rm fabric-installer.jar
    else
        error "Error en la instalación de Fabric Server"
    fi
}

# Descargar Fabric API
install_fabric_api() {
    log "🔧 Descargando Fabric API..."
    
    sudo -u minecraft mkdir -p "$SERVER_DIR/mods"
    
    # URL de Fabric API (versión más reciente compatible)
    FABRIC_API_URL="https://github.com/FabricMC/fabric/releases/latest/download/fabric-api-${MINECRAFT_VERSION}.jar"
    
    # Intentar descargar Fabric API
    if sudo -u minecraft wget -q --show-progress "$FABRIC_API_URL" -O "$SERVER_DIR/mods/fabric-api.jar" 2>/dev/null; then
        success "✅ Fabric API descargado"
    else
        warn "No se pudo descargar Fabric API automáticamente"
        info "Descarga manualmente desde: https://www.curseforge.com/minecraft/mc-mods/fabric-api"
    fi
}

# Copiar scripts de optimización
copy_optimization_scripts() {
    log "📋 Copiando scripts de optimización..."
    
    # Copiar scripts al directorio del servidor
    if [[ -f "$SCRIPT_DIR/iniciador_optimizado_de_minecraft.sh" ]]; then
        sudo cp "$SCRIPT_DIR/iniciador_optimizado_de_minecraft.sh" "$SERVER_DIR/"
        sudo chown minecraft:minecraft "$SERVER_DIR/iniciador_optimizado_de_minecraft.sh"
        sudo chmod +x "$SERVER_DIR/iniciador_optimizado_de_minecraft.sh"
    fi
    
    # Copiar script de optimización apropiado
    if [[ "$ARCH" =~ ^(arm|aarch64|armv7l|armv6l).*$ ]]; then
        OPTIMIZATION_SCRIPT="script_optimizacion_debian_11_ARM.sh"
    else
        OPTIMIZATION_SCRIPT="script_optimizacion_debian_11_x86-x86_64.sh"
    fi
    
    if [[ -f "$SCRIPT_DIR/$OPTIMIZATION_SCRIPT" ]]; then
        sudo cp "$SCRIPT_DIR/$OPTIMIZATION_SCRIPT" "$INSTALL_DIR/scripts/"
        sudo chown minecraft:minecraft "$INSTALL_DIR/scripts/$OPTIMIZATION_SCRIPT"
        sudo chmod +x "$INSTALL_DIR/scripts/$OPTIMIZATION_SCRIPT"
        
        log "Script de optimización copiado: $OPTIMIZATION_SCRIPT"
    fi
    
    success "✅ Scripts copiados"
}

# Crear configuraciones básicas
create_configurations() {
    log "⚙️ Creando configuraciones básicas..."
    
    # server.properties básico
    sudo -u minecraft tee "$SERVER_DIR/server.properties" > /dev/null << EOF
# Configuración básica del servidor Minecraft Fabric
# Generado automáticamente por el instalador

# Configuración del servidor
server-name=Fabric Server
server-port=25565
max-players=20
gamemode=survival
difficulty=normal
hardcore=false
white-list=false
enforce-whitelist=false
pvp=true
spawn-protection=16
max-world-size=29999984
view-distance=10
simulation-distance=10

# Configuración de rendimiento
network-compression-threshold=256
max-tick-time=60000
use-native-transport=true

# Configuración del mundo
level-name=world
level-type=minecraft\:normal
level-seed=
generator-settings={}
generate-structures=true
spawn-animals=true
spawn-monsters=true
spawn-npcs=true

# Configuración RCON (deshabilitado por defecto)
enable-rcon=false
rcon.port=25575
rcon.password=

# Configuración de logs
enable-query=false
query.port=25565
enable-status=true

# Motd
motd=Un servidor Minecraft con Fabric optimizado
EOF

    # eula.txt
    sudo -u minecraft tee "$SERVER_DIR/eula.txt" > /dev/null << EOF
# Debes aceptar el EULA de Minecraft para usar este servidor
# https://aka.ms/MinecraftEULA
# Cambia 'false' a 'true' para aceptar el EULA
eula=false
EOF

    warn "⚠️  Recuerda cambiar 'eula=false' a 'eula=true' en eula.txt antes de iniciar el servidor"
    
    success "✅ Configuraciones básicas creadas"
}

# Crear servicios systemd
create_systemd_service() {
    log "🔄 Creando servicio systemd..."
    
    sudo tee /etc/systemd/system/minecraft-fabric.service > /dev/null << EOF
[Unit]
Description=Minecraft Fabric Server
After=network.target

[Service]
Type=forking
User=minecraft
Group=minecraft
WorkingDirectory=$SERVER_DIR
ExecStart=/usr/bin/screen -dmS minecraft $SERVER_DIR/iniciador_optimizado_de_minecraft.sh
ExecStop=/usr/local/bin/mcrcon -H 127.0.0.1 -P 25575 -p minecraft "stop"
GuessMainPID=no
TimeoutStartSec=600
TimeoutStopSec=600
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable minecraft-fabric.service
    
    success "✅ Servicio systemd creado y habilitado"
}

# Mostrar información final
show_final_info() {
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                  🎉 INSTALACIÓN COMPLETADA 🎉               ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${GREEN}=== INFORMACIÓN DEL SERVIDOR ===${NC}"
    echo "📁 Directorio del servidor: $SERVER_DIR"
    echo "👤 Usuario del servidor: minecraft"
    echo "🌐 Puerto por defecto: 25565"
    echo "📋 Versión de Minecraft: $MINECRAFT_VERSION"
    echo "🕸️ Versión de Fabric: $FABRIC_VERSION"
    echo ""
    
    echo -e "${YELLOW}=== PRÓXIMOS PASOS ===${NC}"
    echo "1. Acepta el EULA:"
    echo "   sudo -u minecraft nano $SERVER_DIR/eula.txt"
    echo "   (cambia 'eula=false' a 'eula=true')"
    echo ""
    echo "2. Ejecuta el script de optimización del sistema:"
    if [[ "$ARCH" =~ ^(arm|aarch64|armv7l|armv6l).*$ ]]; then
        echo "   $INSTALL_DIR/scripts/script_optimizacion_debian_11_ARM.sh"
    else
        echo "   $INSTALL_DIR/scripts/script_optimizacion_debian_11_x86-x86_64.sh"
    fi
    echo ""
    echo "3. Inicia el servidor:"
    echo "   sudo systemctl start minecraft-fabric"
    echo "   O manualmente: cd $SERVER_DIR && ./iniciador_optimizado_de_minecraft.sh"
    echo ""
    
    echo -e "${CYAN}=== COMANDOS ÚTILES ===${NC}"
    echo "• Iniciar servidor: sudo systemctl start minecraft-fabric"
    echo "• Parar servidor: sudo systemctl stop minecraft-fabric"
    echo "• Estado del servidor: sudo systemctl status minecraft-fabric"
    echo "• Ver logs: sudo journalctl -u minecraft-fabric -f"
    echo "• Conectar a consola: sudo -u minecraft screen -r minecraft"
    echo "• Editar configuración: sudo -u minecraft nano $SERVER_DIR/server.properties"
    echo ""
    
    echo -e "${GREEN}=== DIRECTORIOS IMPORTANTES ===${NC}"
    echo "• Servidor: $SERVER_DIR"
    echo "• Mods: $SERVER_DIR/mods"
    echo "• Mundo: $SERVER_DIR/world"
    echo "• Backups: $INSTALL_DIR/backups"
    echo "• Scripts: $INSTALL_DIR/scripts"
    echo ""
    
    success "🚀 ¡Instalación completada! Disfruta tu servidor Minecraft Fabric"
}

# Función principal
main() {
    show_banner
    check_prerequisites
    show_menu
    install_dependencies
    setup_user_and_directories
    install_fabric
    install_fabric_api
    copy_optimization_scripts
    create_configurations
    create_systemd_service
    show_final_info
}

# Ejecutar función principal
main "$@"