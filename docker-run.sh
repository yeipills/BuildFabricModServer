#!/bin/bash

#=============================================================================
# 🐳 Docker Runner para Minecraft Fabric Server
# Versión: 1.0
# Descripción: Script para facilitar el manejo del servidor en Docker
# Comandos: build, start, stop, restart, logs, backup, clean
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
COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME="minecraft-fabric"
CONTAINER_NAME="minecraft-fabric-server"

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
║        🐳 MINECRAFT FABRIC DOCKER MANAGER 🐳                ║
║                                                              ║
║    Gestión simplificada del servidor en contenedores        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Función de ayuda
show_help() {
    cat << EOF
Uso: $0 [COMANDO] [OPCIONES]

COMANDOS:
    build                  Construir la imagen del servidor
    start                  Iniciar el servidor
    stop                   Detener el servidor
    restart                Reiniciar el servidor
    logs                   Ver logs del servidor
    status                 Ver estado de los servicios
    backup                 Crear backup manual
    restore [ARCHIVO]      Restaurar desde backup
    clean                  Limpiar contenedores y volúmenes
    update                 Actualizar imagen y reiniciar
    shell                  Abrir shell en el contenedor
    console                Conectar a la consola del servidor

OPCIONES:
    -f, --follow           Seguir logs en tiempo real
    -h, --help             Mostrar esta ayuda

EJEMPLOS:
    $0 build               # Construir imagen
    $0 start               # Iniciar servidor
    $0 logs -f             # Ver logs en tiempo real
    $0 backup              # Crear backup manual
    $0 clean               # Limpiar todo

EOF
}

# Verificar prerrequisitos
check_prerequisites() {
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        error "Docker no está instalado"
    fi
    
    # Verificar Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        error "Docker Compose no está instalado"
    fi
    
    # Verificar archivo compose
    if [[ ! -f "$COMPOSE_FILE" ]]; then
        error "Archivo $COMPOSE_FILE no encontrado"
    fi
    
    # Crear directorios de datos si no existen
    mkdir -p data/{world,mods,backups,config,logs}
    
    success "✅ Prerrequisitos verificados"
}

# Obtener comando de docker compose
get_compose_cmd() {
    if command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    else
        echo "docker compose"
    fi
}

# Construir imagen
build_image() {
    log "🔨 Construyendo imagen del servidor Minecraft Fabric..."
    
    local compose_cmd=$(get_compose_cmd)
    
    if $compose_cmd -p "$PROJECT_NAME" build --no-cache; then
        success "✅ Imagen construida exitosamente"
    else
        error "Error al construir la imagen"
    fi
}

# Iniciar servidor
start_server() {
    log "🚀 Iniciando servidor Minecraft Fabric..."
    
    local compose_cmd=$(get_compose_cmd)
    
    # Verificar si ya está ejecutándose
    if $compose_cmd -p "$PROJECT_NAME" ps -q minecraft-server | grep -q .; then
        warn "El servidor ya está ejecutándose"
        return
    fi
    
    if $compose_cmd -p "$PROJECT_NAME" up -d; then
        success "✅ Servidor iniciado exitosamente"
        info "Usa '$0 logs -f' para ver los logs en tiempo real"
        info "Usa '$0 console' para conectar a la consola del servidor"
    else
        error "Error al iniciar el servidor"
    fi
}

# Detener servidor
stop_server() {
    log "🛑 Deteniendo servidor Minecraft Fabric..."
    
    local compose_cmd=$(get_compose_cmd)
    
    if $compose_cmd -p "$PROJECT_NAME" down; then
        success "✅ Servidor detenido exitosamente"
    else
        error "Error al detener el servidor"
    fi
}

# Reiniciar servidor
restart_server() {
    log "🔄 Reiniciando servidor Minecraft Fabric..."
    
    stop_server
    sleep 5
    start_server
}

# Ver logs
show_logs() {
    local follow_flag=""
    
    if [[ "${1:-}" == "-f" ]] || [[ "${1:-}" == "--follow" ]]; then
        follow_flag="-f"
        log "📋 Mostrando logs en tiempo real (Ctrl+C para salir)..."
    else
        log "📋 Mostrando logs del servidor..."
    fi
    
    local compose_cmd=$(get_compose_cmd)
    $compose_cmd -p "$PROJECT_NAME" logs $follow_flag minecraft-server
}

# Ver estado
show_status() {
    log "📊 Estado de los servicios:"
    
    local compose_cmd=$(get_compose_cmd)
    $compose_cmd -p "$PROJECT_NAME" ps
    
    echo ""
    info "Estado detallado:"
    
    # Verificar si el contenedor está ejecutándose
    if docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -q "$CONTAINER_NAME"; then
        success "✅ Servidor ejecutándose"
        
        # Mostrar uso de recursos
        echo ""
        info "Uso de recursos:"
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" "$CONTAINER_NAME" 2>/dev/null || true
    else
        warn "❌ Servidor no está ejecutándose"
    fi
}

# Crear backup manual
create_backup() {
    log "💾 Creando backup manual..."
    
    local backup_name="manual_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="./data/backups/$backup_name"
    
    if [[ -d "./data/world" ]]; then
        tar -czf "$backup_path" -C "./data" world mods config 2>/dev/null
        
        if [[ -f "$backup_path" ]]; then
            local backup_size=$(du -h "$backup_path" | cut -f1)
            success "✅ Backup creado: $backup_name ($backup_size)"
            info "Ubicación: $backup_path"
        else
            error "Error al crear el backup"
        fi
    else
        warn "No hay datos para hacer backup"
    fi
}

# Restaurar backup
restore_backup() {
    local backup_file="$1"
    
    if [[ ! -f "$backup_file" ]]; then
        # Buscar en el directorio de backups
        if [[ -f "./data/backups/$backup_file" ]]; then
            backup_file="./data/backups/$backup_file"
        else
            error "Archivo de backup no encontrado: $backup_file"
        fi
    fi
    
    log "🔄 Restaurando desde backup: $(basename "$backup_file")"
    
    # Detener servidor si está ejecutándose
    local compose_cmd=$(get_compose_cmd)
    if $compose_cmd -p "$PROJECT_NAME" ps -q minecraft-server | grep -q .; then
        warn "Deteniendo servidor para restaurar..."
        stop_server
        sleep 5
    fi
    
    # Crear backup del estado actual
    if [[ -d "./data/world" ]]; then
        local current_backup="pre_restore_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
        tar -czf "./data/backups/$current_backup" -C "./data" world mods config 2>/dev/null
        info "Backup del estado actual creado: $current_backup"
    fi
    
    # Restaurar backup
    if tar -xzf "$backup_file" -C "./data/"; then
        success "✅ Backup restaurado correctamente"
        info "Puedes iniciar el servidor con: $0 start"
    else
        error "Error al restaurar el backup"
    fi
}

# Limpiar contenedores y volúmenes
clean_all() {
    warn "⚠️  Esta operación eliminará todos los contenedores y datos"
    read -p "¿Estás seguro de continuar? (escriba 'confirmar'): " -r
    
    if [[ $REPLY != "confirmar" ]]; then
        log "Operación cancelada"
        return
    fi
    
    log "🧹 Limpiando contenedores y volúmenes..."
    
    local compose_cmd=$(get_compose_cmd)
    
    # Detener y eliminar contenedores
    $compose_cmd -p "$PROJECT_NAME" down -v --remove-orphans
    
    # Eliminar imágenes del proyecto
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}" | grep "$PROJECT_NAME" | awk '{print $3}' | xargs -r docker rmi
    
    # Limpiar datos locales
    if [[ -d "./data" ]]; then
        rm -rf ./data/*
        mkdir -p data/{world,mods,backups,config,logs}
    fi
    
    success "✅ Limpieza completada"
}

# Actualizar imagen
update_server() {
    log "⬆️ Actualizando servidor..."
    
    # Crear backup antes de actualizar
    create_backup
    
    # Reconstruir imagen
    build_image
    
    # Reiniciar servicios
    restart_server
    
    success "✅ Servidor actualizado"
}

# Abrir shell en el contenedor
open_shell() {
    log "🐚 Abriendo shell en el contenedor..."
    
    if ! docker ps --format "{{.Names}}" | grep -q "$CONTAINER_NAME"; then
        error "El contenedor no está ejecutándose"
    fi
    
    docker exec -it "$CONTAINER_NAME" /bin/bash
}

# Conectar a la consola del servidor
connect_console() {
    log "🎮 Conectando a la consola del servidor..."
    
    if ! docker ps --format "{{.Names}}" | grep -q "$CONTAINER_NAME"; then
        error "El contenedor no está ejecutándose"
    fi
    
    info "Usa 'Ctrl+A, D' para desconectar de screen sin cerrar el servidor"
    docker exec -it "$CONTAINER_NAME" screen -r minecraft 2>/dev/null || {
        warn "No se pudo conectar a screen, intentando con logs interactivos..."
        docker logs -f "$CONTAINER_NAME"
    }
}

# Función principal
main() {
    show_banner
    check_prerequisites
    
    case "${1:-help}" in
        build)
            build_image
            ;;
        start)
            start_server
            ;;
        stop)
            stop_server
            ;;
        restart)
            restart_server
            ;;
        logs)
            show_logs "${2:-}"
            ;;
        status)
            show_status
            ;;
        backup)
            create_backup
            ;;
        restore)
            if [[ -n "${2:-}" ]]; then
                restore_backup "$2"
            else
                error "Especifica el archivo de backup para restaurar"
            fi
            ;;
        clean)
            clean_all
            ;;
        update)
            update_server
            ;;
        shell)
            open_shell
            ;;
        console)
            connect_console
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Comando desconocido: ${1:-}. Usa '$0 help' para ver los comandos disponibles"
            ;;
    esac
}

# Ejecutar función principal
main "$@"