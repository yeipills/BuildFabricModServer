#!/bin/bash

#=============================================================================
# 🔄 Script de Actualización de Minecraft Fabric Server
# Versión: 1.0
# Descripción: Actualiza Minecraft, Fabric y mods automáticamente
# Soporte: Actualizaciones seguras con backup automático
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
SERVER_DIR="/opt/minecraft/server"
BACKUP_DIR="/opt/minecraft/backups"
SCRIPTS_DIR="/opt/minecraft/scripts"
LOG_FILE="/opt/minecraft/logs/update-$(date +%Y%m%d_%H%M%S).log"

# Versiones por defecto (se pueden sobrescribir con parámetros)
NEW_MINECRAFT_VERSION=""
NEW_FABRIC_VERSION=""
FABRIC_INSTALLER_VERSION="0.11.2"

# Función para logging
log() {
    local message="[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    echo -e "${GREEN}${message}${NC}"
    echo "$message" >> "$LOG_FILE"
}

warn() {
    local message="[WARNING] $1"
    echo -e "${YELLOW}${message}${NC}"
    echo "$message" >> "$LOG_FILE"
}

error() {
    local message="[ERROR] $1"
    echo -e "${RED}${message}${NC}"
    echo "$message" >> "$LOG_FILE"
    exit 1
}

info() {
    local message="[INFO] $1"
    echo -e "${BLUE}${message}${NC}"
    echo "$message" >> "$LOG_FILE"
}

success() {
    local message="[SUCCESS] $1"
    echo -e "${CYAN}${message}${NC}"
    echo "$message" >> "$LOG_FILE"
}

# Función para mostrar banner
show_banner() {
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║         🔄 MINECRAFT FABRIC SERVER UPDATER 🔄               ║
║                                                              ║
║    Actualización segura con backup automático               ║
║    Soporte: Minecraft, Fabric Loader, Mods                  ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Función de ayuda
show_help() {
    cat << EOF
Uso: $0 [OPCIONES]

OPCIONES:
    -m, --minecraft VERSION    Versión de Minecraft a instalar (ej: 1.20.4)
    -f, --fabric VERSION       Versión de Fabric Loader (ej: 0.15.6)
    -b, --backup-only          Solo crear backup, no actualizar
    -c, --check-versions       Solo verificar versiones disponibles
    -r, --restore BACKUP       Restaurar desde un backup específico
    -h, --help                 Mostrar esta ayuda

EJEMPLOS:
    $0 -m 1.20.4 -f 0.15.6     # Actualizar a Minecraft 1.20.4 y Fabric 0.15.6
    $0 -b                       # Solo crear backup
    $0 -c                       # Verificar versiones
    $0 -r minecraft_backup_20240101_120000.tar.gz  # Restaurar backup

EOF
}

# Verificar prerrequisitos
check_prerequisites() {
    log "🔍 Verificando prerrequisitos..."
    
    # Verificar si el directorio del servidor existe
    if [[ ! -d "$SERVER_DIR" ]]; then
        error "Directorio del servidor no encontrado: $SERVER_DIR"
    fi
    
    # Verificar permisos
    if [[ $EUID -eq 0 ]]; then
        error "No ejecutes este script como root. Usará sudo cuando sea necesario."
    fi
    
    # Verificar si el servidor está corriendo
    if pgrep -f "fabric-server-launch.jar" > /dev/null; then
        warn "⚠️  El servidor parece estar ejecutándose"
        read -p "¿Quieres detener el servidor antes de continuar? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            stop_server
        else
            error "No se puede actualizar con el servidor ejecutándose"
        fi
    fi
    
    # Crear directorio de logs si no existe
    mkdir -p "$(dirname "$LOG_FILE")"
    
    success "✅ Prerrequisitos verificados"
}

# Detener servidor
stop_server() {
    log "🛑 Deteniendo servidor..."
    
    if systemctl is-active --quiet minecraft-fabric 2>/dev/null; then
        sudo systemctl stop minecraft-fabric
        log "Servidor detenido via systemd"
    else
        # Intentar detener procesos Java relacionados con Minecraft
        pkill -f "fabric-server-launch.jar" || true
        log "Procesos del servidor detenidos"
    fi
    
    # Esperar a que se detenga completamente
    sleep 5
    
    if ! pgrep -f "fabric-server-launch.jar" > /dev/null; then
        success "✅ Servidor detenido correctamente"
    else
        warn "El servidor sigue ejecutándose, continuando de todos modos..."
    fi
}

# Crear backup
create_backup() {
    log "💾 Creando backup del servidor..."
    
    mkdir -p "$BACKUP_DIR"
    
    local backup_name="minecraft_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    # Crear backup excluyendo archivos temporales y logs
    tar -czf "$backup_path" \
        -C "$SERVER_DIR" \
        --exclude="logs/*.log*" \
        --exclude="crash-reports/*" \
        --exclude="*.tmp" \
        --exclude="*.temp" \
        . 2>/dev/null
    
    if [[ -f "$backup_path" ]]; then
        local backup_size=$(du -h "$backup_path" | cut -f1)
        success "✅ Backup creado: $backup_name ($backup_size)"
        echo "$backup_path"
    else
        error "Error al crear el backup"
    fi
}

# Obtener versión actual
get_current_versions() {
    log "📋 Obteniendo versiones actuales..."
    
    local current_mc_version="Desconocida"
    local current_fabric_version="Desconocida"
    
    # Intentar obtener versión de Minecraft desde server.properties
    if [[ -f "$SERVER_DIR/server.properties" ]]; then
        # Esta información no siempre está disponible en server.properties
        info "Archivo server.properties encontrado"
    fi
    
    # Intentar obtener información de los archivos del servidor
    if [[ -f "$SERVER_DIR/fabric-server-launch.jar" ]]; then
        info "Fabric server encontrado"
    fi
    
    info "Versión actual de Minecraft: $current_mc_version"
    info "Versión actual de Fabric: $current_fabric_version"
}

# Verificar versiones disponibles
check_available_versions() {
    log "🔍 Verificando versiones disponibles..."
    
    # API de Fabric para obtener versiones disponibles
    local fabric_api="https://meta.fabricmc.net/v2/versions"
    
    info "Consultando API de Fabric..."
    
    # Obtener versiones de Minecraft compatibles con Fabric
    if command -v curl &> /dev/null; then
        local mc_versions=$(curl -s "$fabric_api/game" | grep -o '"version":"[^"]*"' | cut -d'"' -f4 | head -10)
        local fabric_versions=$(curl -s "$fabric_api/loader" | grep -o '"version":"[^"]*"' | cut -d'"' -f4 | head -5)
        
        echo -e "${CYAN}Últimas versiones de Minecraft disponibles:${NC}"
        echo "$mc_versions" | head -5
        echo ""
        echo -e "${CYAN}Últimas versiones de Fabric Loader disponibles:${NC}"
        echo "$fabric_versions" | head -3
    else
        warn "curl no está disponible para verificar versiones automáticamente"
        info "Visita https://fabricmc.net/use/server/ para ver versiones disponibles"
    fi
}

# Descargar nueva versión de Fabric
download_fabric() {
    local mc_version="$1"
    local fabric_version="$2"
    
    log "⬇️ Descargando Fabric Server v$fabric_version para Minecraft $mc_version..."
    
    cd "$SERVER_DIR"
    
    # Respaldar archivos actuales
    if [[ -f "fabric-server-launch.jar" ]]; then
        mv "fabric-server-launch.jar" "fabric-server-launch.jar.backup"
    fi
    
    # Descargar Fabric Installer
    local installer_url="https://maven.fabricmc.net/net/fabricmc/fabric-installer/$FABRIC_INSTALLER_VERSION/fabric-installer-$FABRIC_INSTALLER_VERSION.jar"
    
    if ! sudo -u minecraft wget -q --show-progress "$installer_url" -O fabric-installer.jar; then
        error "Error al descargar Fabric Installer"
    fi
    
    # Instalar nueva versión
    log "Instalando Fabric Server..."
    if sudo -u minecraft java -jar fabric-installer.jar server \
        -mcversion "$mc_version" \
        -loader "$fabric_version" \
        -downloadMinecraft; then
        
        success "✅ Fabric Server $fabric_version instalado para Minecraft $mc_version"
        sudo -u minecraft rm fabric-installer.jar
        
        # Eliminar backup si la instalación fue exitosa
        if [[ -f "fabric-server-launch.jar.backup" ]]; then
            rm "fabric-server-launch.jar.backup"
        fi
    else
        error "Error en la instalación de Fabric Server"
    fi
}

# Actualizar mods
update_mods() {
    log "🔧 Verificando mods para actualizar..."
    
    local mods_dir="$SERVER_DIR/mods"
    
    if [[ ! -d "$mods_dir" ]]; then
        info "Directorio de mods no encontrado, creándolo..."
        sudo -u minecraft mkdir -p "$mods_dir"
        return
    fi
    
    # Contar mods actuales
    local mod_count=$(find "$mods_dir" -name "*.jar" | wc -l)
    info "Mods encontrados: $mod_count"
    
    if [[ $mod_count -gt 0 ]]; then
        warn "⚠️  Actualización manual de mods requerida"
        info "Verifica la compatibilidad de los mods en:"
        info "- CurseForge: https://www.curseforge.com/minecraft/modpacks"
        info "- Modrinth: https://modrinth.com/"
        
        # Crear backup de mods
        log "Creando backup de mods..."
        tar -czf "$BACKUP_DIR/mods_backup_$(date +%Y%m%d_%H%M%S).tar.gz" -C "$mods_dir" . 2>/dev/null
        success "✅ Backup de mods creado"
    fi
}

# Restaurar desde backup
restore_backup() {
    local backup_file="$1"
    
    if [[ ! -f "$backup_file" ]]; then
        # Buscar en el directorio de backups
        if [[ -f "$BACKUP_DIR/$backup_file" ]]; then
            backup_file="$BACKUP_DIR/$backup_file"
        else
            error "Archivo de backup no encontrado: $backup_file"
        fi
    fi
    
    log "🔄 Restaurando desde backup: $(basename "$backup_file")"
    
    # Detener servidor si está ejecutándose
    stop_server
    
    # Crear backup del estado actual antes de restaurar
    local current_backup=$(create_backup)
    log "Backup del estado actual creado: $(basename "$current_backup")"
    
    # Limpiar directorio del servidor
    sudo -u minecraft find "$SERVER_DIR" -mindepth 1 -delete
    
    # Extraer backup
    if tar -xzf "$backup_file" -C "$SERVER_DIR"; then
        sudo chown -R minecraft:minecraft "$SERVER_DIR"
        success "✅ Backup restaurado correctamente"
        
        info "Para iniciar el servidor:"
        info "sudo systemctl start minecraft-fabric"
    else
        error "Error al restaurar el backup"
    fi
}

# Limpiar archivos antiguos
cleanup_old_files() {
    log "🧹 Limpiando archivos antiguos..."
    
    # Limpiar logs antiguos (más de 7 días)
    find "$SERVER_DIR/logs" -name "*.log*" -mtime +7 -delete 2>/dev/null || true
    
    # Limpiar crash reports antiguos (más de 30 días)
    find "$SERVER_DIR/crash-reports" -name "*.txt" -mtime +30 -delete 2>/dev/null || true
    
    # Limpiar backups antiguos (más de 30 días)
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete 2>/dev/null || true
    
    success "✅ Limpieza completada"
}

# Mostrar información final
show_final_info() {
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                 🎉 ACTUALIZACIÓN COMPLETADA 🎉              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${GREEN}=== INFORMACIÓN DE LA ACTUALIZACIÓN ===${NC}"
    if [[ -n "$NEW_MINECRAFT_VERSION" ]]; then
        echo "🎮 Nueva versión de Minecraft: $NEW_MINECRAFT_VERSION"
    fi
    if [[ -n "$NEW_FABRIC_VERSION" ]]; then
        echo "🕸️ Nueva versión de Fabric: $NEW_FABRIC_VERSION"
    fi
    echo "📁 Directorio del servidor: $SERVER_DIR"
    echo "💾 Directorio de backups: $BACKUP_DIR"
    echo "📋 Log de actualización: $LOG_FILE"
    echo ""
    
    echo -e "${YELLOW}=== PRÓXIMOS PASOS ===${NC}"
    echo "1. Verificar que el servidor inicia correctamente:"
    echo "   sudo systemctl start minecraft-fabric"
    echo ""
    echo "2. Monitorear los logs:"
    echo "   sudo journalctl -u minecraft-fabric -f"
    echo ""
    echo "3. Verificar compatibilidad de mods si es necesario"
    echo ""
    
    echo -e "${CYAN}=== COMANDOS ÚTILES ===${NC}"
    echo "• Ver estado: sudo systemctl status minecraft-fabric"
    echo "• Ver logs de actualización: cat $LOG_FILE"
    echo "• Listar backups: ls -la $BACKUP_DIR"
    echo ""
    
    success "🚀 ¡Actualización completada exitosamente!"
}

# Procesamiento de argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--minecraft)
            NEW_MINECRAFT_VERSION="$2"
            shift 2
            ;;
        -f|--fabric)
            NEW_FABRIC_VERSION="$2"
            shift 2
            ;;
        -b|--backup-only)
            BACKUP_ONLY=1
            shift
            ;;
        -c|--check-versions)
            CHECK_VERSIONS=1
            shift
            ;;
        -r|--restore)
            RESTORE_BACKUP="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            error "Opción desconocida: $1"
            ;;
    esac
done

# Función principal
main() {
    show_banner
    check_prerequisites
    
    # Crear log inicial
    mkdir -p "$(dirname "$LOG_FILE")"
    log "Iniciando actualización del servidor Minecraft Fabric"
    
    # Procesar diferentes modos
    if [[ "${CHECK_VERSIONS:-}" == "1" ]]; then
        check_available_versions
        exit 0
    fi
    
    if [[ -n "${RESTORE_BACKUP:-}" ]]; then
        restore_backup "$RESTORE_BACKUP"
        exit 0
    fi
    
    # Obtener versiones actuales
    get_current_versions
    
    # Crear backup siempre
    local backup_path=$(create_backup)
    
    if [[ "${BACKUP_ONLY:-}" == "1" ]]; then
        success "✅ Backup creado: $(basename "$backup_path")"
        exit 0
    fi
    
    # Verificar si se especificaron versiones para actualizar
    if [[ -z "$NEW_MINECRAFT_VERSION" ]] && [[ -z "$NEW_FABRIC_VERSION" ]]; then
        warn "No se especificaron versiones para actualizar"
        info "Usa -m para Minecraft y -f para Fabric Loader"
        info "Ejemplo: $0 -m 1.20.4 -f 0.15.6"
        check_available_versions
        exit 0
    fi
    
    # Actualizar Fabric si se especificó
    if [[ -n "$NEW_MINECRAFT_VERSION" ]] && [[ -n "$NEW_FABRIC_VERSION" ]]; then
        download_fabric "$NEW_MINECRAFT_VERSION" "$NEW_FABRIC_VERSION"
    else
        warn "Se requieren ambas versiones (-m y -f) para actualizar"
        exit 1
    fi
    
    # Actualizar mods
    update_mods
    
    # Limpieza
    cleanup_old_files
    
    # Información final
    show_final_info
}

# Ejecutar función principal
main "$@"