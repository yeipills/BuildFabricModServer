#!/bin/bash

#=============================================================================
# 🚀 Script de Optimización para Debian 11+ ARM
# Versión: 2.0
# Arquitectura: ARM/ARM64 (Raspberry Pi, servidores ARM)
# Propósito: Optimizar sistema para servidor Minecraft Fabric
#=============================================================================

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Verificar permisos de root
if [[ $EUID -eq 0 ]]; then
    error "No ejecutes este script como root. Usa sudo cuando sea necesario."
fi

# Verificar distribución
if ! command -v apt &> /dev/null; then
    error "Este script es solo para sistemas basados en Debian/Ubuntu"
fi

# Verificar arquitectura ARM
ARCH=$(uname -m)
if [[ ! "$ARCH" =~ ^(arm|aarch64|armv7l|armv6l).*$ ]]; then
    warn "Este script está optimizado para ARM, pero detecté: $ARCH"
    read -p "¿Continuar de todos modos? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

log "🚀 Iniciando optimización para sistema ARM: $ARCH"

# Función para aplicar configuración sysctl de forma segura
apply_sysctl() {
    local config="$1"
    if ! grep -q "^${config}" /etc/sysctl.conf; then
        echo "$config" | sudo tee -a /etc/sysctl.conf > /dev/null
        log "Aplicado: $config"
    else
        log "Ya configurado: $config"
    fi
}

# Crear backup de configuraciones
BACKUP_DIR="/tmp/minecraft_optimization_backup_$(date +%Y%m%d_%H%M%S)"
sudo mkdir -p "$BACKUP_DIR"
sudo cp /etc/sysctl.conf "$BACKUP_DIR/" 2>/dev/null || true
log "Backup creado en: $BACKUP_DIR"

# 1. Actualizar sistema
log "📦 Actualizando sistema..."
sudo apt update -y
sudo apt upgrade -y

# 2. Instalar herramientas esenciales
log "🛠️ Instalando herramientas de monitoreo y optimización..."
sudo apt install -y \
    sysstat \
    htop \
    iotop \
    net-tools \
    curl \
    wget \
    unzip \
    screen \
    tmux \
    fail2ban \
    ufw

# 3. Configurar sysstat
log "📊 Configurando sysstat..."
if [[ -f /etc/default/sysstat ]]; then
    sudo sed -i 's/ENABLED="false"/ENABLED="true"/g' /etc/default/sysstat
    sudo systemctl enable sysstat
    sudo systemctl start sysstat
else
    warn "Archivo de configuración sysstat no encontrado"
fi

# 4. Optimizaciones de memoria y cache
log "💾 Aplicando optimizaciones de memoria..."
apply_sysctl "# === Optimizaciones Minecraft Server ARM ==="
apply_sysctl "vm.vfs_cache_pressure=50"
apply_sysctl "vm.swappiness=1"
apply_sysctl "vm.dirty_background_ratio=5"
apply_sysctl "vm.dirty_ratio=10"
apply_sysctl "vm.dirty_expire_centisecs=12000"
apply_sysctl "vm.dirty_writeback_centisecs=1500"
apply_sysctl "vm.overcommit_memory=1"

# 5. Optimizaciones de red
log "🌐 Aplicando optimizaciones de red..."
NET_CONFIGS=(
    "net.core.rmem_default=262144"
    "net.core.rmem_max=16777216"
    "net.core.wmem_default=262144"
    "net.core.wmem_max=16777216"
    "net.core.netdev_max_backlog=5000"
    "net.core.netdev_budget=600"
    "net.ipv4.tcp_rmem=8192 262144 16777216"
    "net.ipv4.tcp_wmem=8192 262144 16777216"
    "net.ipv4.tcp_congestion_control=bbr"
    "net.ipv4.tcp_fastopen=3"
    "net.ipv4.tcp_keepalive_time=120"
    "net.ipv4.tcp_keepalive_intvl=30"
    "net.ipv4.tcp_keepalive_probes=3"
    "net.ipv4.tcp_mtu_probing=1"
    "net.ipv4.tcp_base_mss=1024"
    "net.ipv4.tcp_slow_start_after_idle=0"
    "net.ipv4.tcp_no_metrics_save=1"
    "net.ipv4.ip_local_port_range=1024 65535"
)

for config in "${NET_CONFIGS[@]}"; do
    apply_sysctl "$config"
done

# 6. Optimizaciones específicas para ARM
log "🔧 Aplicando optimizaciones específicas para ARM..."
apply_sysctl "# === Optimizaciones ARM específicas ==="

# Optimizar scheduler para ARM
apply_sysctl "kernel.sched_migration_cost_ns=5000000"
apply_sysctl "kernel.sched_autogroup_enabled=0"

# Optimizar para sistemas con menos cores
if [[ $(nproc) -le 4 ]]; then
    apply_sysctl "net.core.netdev_budget=300"
    apply_sysctl "vm.vfs_cache_pressure=75"
fi

# 7. Configurar firewall básico
log "🛡️ Configurando firewall básico..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 25565/tcp  # Puerto Minecraft por defecto
sudo ufw --force enable

# 8. Configurar fail2ban
log "🔒 Configurando fail2ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# 9. Optimizar sistema de archivos
log "📁 Optimizando montajes de sistema de archivos..."
if ! grep -q "noatime" /etc/fstab; then
    warn "Considera agregar 'noatime' a las opciones de montaje en /etc/fstab para mejor rendimiento"
fi

# 10. Configurar límites del sistema
log "⚙️ Configurando límites del sistema..."
sudo tee /etc/security/limits.d/minecraft.conf > /dev/null << 'EOF'
# Límites para servidor Minecraft
* soft nofile 65536
* hard nofile 65536
* soft nproc 4096
* hard nproc 4096
minecraft soft nofile 65536
minecraft hard nofile 65536
minecraft soft nproc 4096
minecraft hard nproc 4096
EOF

# 11. Crear usuario minecraft si no existe
if ! id "minecraft" &>/dev/null; then
    log "👤 Creando usuario minecraft..."
    sudo useradd -r -m -U -d /opt/minecraft -s /bin/bash minecraft
    sudo usermod -aG sudo minecraft
fi

# 12. Configurar directorio del servidor
log "📂 Preparando directorio del servidor..."
sudo mkdir -p /opt/minecraft/server
sudo chown -R minecraft:minecraft /opt/minecraft
sudo chmod 755 /opt/minecraft

# 13. Aplicar todas las configuraciones
log "✅ Aplicando configuraciones del kernel..."
sudo sysctl -p

# 14. Configurar servicios del sistema
log "🔄 Optimizando servicios del sistema..."
# Deshabilitar servicios innecesarios para ARM
SERVICES_TO_DISABLE=(
    "bluetooth"
    "cups"
    "cups-browsed" 
)

for service in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl is-enabled "$service" 2>/dev/null | grep -q enabled; then
        sudo systemctl disable "$service" 2>/dev/null || true
        log "Deshabilitado: $service"
    fi
done

# 15. Configurar swap si es necesario
TOTAL_RAM=$(free -m | awk 'NR==2{print $2}')
if [[ $TOTAL_RAM -lt 2048 ]]; then
    warn "RAM disponible: ${TOTAL_RAM}MB. Considera crear un archivo swap."
    read -p "¿Crear archivo swap de 2GB? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [[ ! -f /swapfile ]]; then
            log "📀 Creando archivo swap..."
            sudo fallocate -l 2G /swapfile
            sudo chmod 600 /swapfile
            sudo mkswap /swapfile
            sudo swapon /swapfile
            echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
            log "Swap de 2GB creado y activado"
        fi
    fi
fi

# 16. Crear script de monitoreo
log "📊 Creando script de monitoreo..."
sudo tee /opt/minecraft/monitor.sh > /dev/null << 'EOF'
#!/bin/bash
# Script de monitoreo básico para servidor Minecraft

echo "=== ESTADO DEL SERVIDOR MINECRAFT ==="
echo "Fecha: $(date)"
echo "Uptime: $(uptime -p)"
echo ""

echo "=== MEMORIA ==="
free -h
echo ""

echo "=== CPU ==="
top -bn1 | grep "Cpu(s)" | awk '{print $1 $2}'
echo ""

echo "=== PROCESOS JAVA ==="
pgrep -f java | xargs -I {} ps -p {} -o pid,cmd --no-headers 2>/dev/null || echo "No hay procesos Java ejecutándose"
echo ""

echo "=== RED ==="
ss -tuln | grep :25565 || echo "Puerto 25565 no está en uso"
echo ""

echo "=== DISCO ==="
df -h | grep -E "(/$|/opt)"
EOF

sudo chmod +x /opt/minecraft/monitor.sh
sudo chown minecraft:minecraft /opt/minecraft/monitor.sh

# 17. Información final
log "🎉 ¡Optimización completada con éxito!"
log ""
log "=== RESUMEN DE CAMBIOS ==="
log "✅ Sistema actualizado"
log "✅ Herramientas de monitoreo instaladas"
log "✅ Optimizaciones de memoria aplicadas"
log "✅ Optimizaciones de red aplicadas"
log "✅ Optimizaciones ARM específicas aplicadas"
log "✅ Firewall configurado"
log "✅ Usuario minecraft creado"
log "✅ Directorio del servidor preparado"
log ""
log "=== PRÓXIMOS PASOS ==="
log "1. Reiniciar el sistema: sudo reboot"
log "2. Ejecutar el script de monitoreo: /opt/minecraft/monitor.sh"
log "3. Configurar el servidor Minecraft en: /opt/minecraft/server"
log ""
log "=== COMANDOS ÚTILES ==="
log "• Monitorear sistema: /opt/minecraft/monitor.sh"
log "• Ver configuración sysctl: sysctl -a | grep -E '(vm|net)'"
log "• Estado del firewall: sudo ufw status"
log "• Logs del sistema: journalctl -f"
log ""

warn "⚠️  IMPORTANTE: Reinicia el sistema para aplicar todos los cambios"
log "Backup de configuraciones en: $BACKUP_DIR"
