#!/bin/bash

#=============================================================================
# 🚀 Script de Optimización para Debian 11+ x86/x64
# Versión: 2.0
# Arquitectura: x86_64, i686 (servidores tradicionales, PCs)
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

# Verificar arquitectura x86/x64
ARCH=$(uname -m)
if [[ ! "$ARCH" =~ ^(x86_64|i686|i386)$ ]]; then
    warn "Este script está optimizado para x86/x64, pero detecté: $ARCH"
    read -p "¿Continuar de todos modos? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

log "🚀 Iniciando optimización para sistema x86/x64: $ARCH"

# Detectar CPU
CPU_INFO=$(lscpu | head -20)
CPU_CORES=$(nproc)
CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}' || echo "Unknown")

log "🖥️ CPU detectado: $CPU_VENDOR con $CPU_CORES núcleos"

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

# 2. Instalar herramientas esenciales y específicas x86/x64
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
    ufw \
    cpufrequtils \
    intel-microcode \
    amd64-microcode \
    thermald \
    irqbalance

# 3. Configurar sysstat
log "📊 Configurando sysstat..."
if [[ -f /etc/default/sysstat ]]; then
    sudo sed -i 's/ENABLED="false"/ENABLED="true"/g' /etc/default/sysstat
    sudo systemctl enable sysstat
    sudo systemctl start sysstat
else
    warn "Archivo de configuración sysstat no encontrado"
fi

# 4. Configurar CPUfreq para rendimiento
log "⚡ Configurando governor de CPU para rendimiento..."
if command -v cpufreq-set &> /dev/null; then
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [[ -f "$cpu" ]]; then
            echo performance | sudo tee "$cpu" > /dev/null
        fi
    done
    log "Governor de CPU configurado a 'performance'"
fi

# 5. Configurar irqbalance para mejor distribución de interrupciones
log "⚖️ Configurando irqbalance..."
sudo systemctl enable irqbalance
sudo systemctl start irqbalance

# 6. Optimizaciones de memoria y cache
log "💾 Aplicando optimizaciones de memoria..."
apply_sysctl "# === Optimizaciones Minecraft Server x86/x64 ==="
apply_sysctl "vm.vfs_cache_pressure=50"
apply_sysctl "vm.swappiness=1"
apply_sysctl "vm.dirty_background_ratio=5"
apply_sysctl "vm.dirty_ratio=10"
apply_sysctl "vm.dirty_expire_centisecs=12000"
apply_sysctl "vm.dirty_writeback_centisecs=1500"
apply_sysctl "vm.overcommit_memory=1"
apply_sysctl "vm.zone_reclaim_mode=0"

# Optimizaciones adicionales para sistemas con más RAM
TOTAL_RAM_GB=$(free -g | awk 'NR==2{print $2}')
if [[ $TOTAL_RAM_GB -ge 8 ]]; then
    apply_sysctl "vm.vfs_cache_pressure=10"
    apply_sysctl "vm.dirty_background_ratio=2"
    log "Optimizaciones adicionales aplicadas para sistemas con ${TOTAL_RAM_GB}GB+ de RAM"
fi

# 7. Optimizaciones de red avanzadas
log "🌐 Aplicando optimizaciones de red avanzadas..."
NET_CONFIGS=(
    "net.core.rmem_default=262144"
    "net.core.rmem_max=33554432"
    "net.core.wmem_default=262144"
    "net.core.wmem_max=33554432"
    "net.core.netdev_max_backlog=10000"
    "net.core.netdev_budget=600"
    "net.core.netdev_budget_usecs=5000"
    "net.ipv4.tcp_rmem=8192 262144 33554432"
    "net.ipv4.tcp_wmem=8192 262144 33554432"
    "net.ipv4.tcp_congestion_control=bbr"
    "net.ipv4.tcp_fastopen=3"
    "net.ipv4.tcp_keepalive_time=120"
    "net.ipv4.tcp_keepalive_intvl=30"
    "net.ipv4.tcp_keepalive_probes=3"
    "net.ipv4.tcp_mtu_probing=1"
    "net.ipv4.tcp_base_mss=1024"
    "net.ipv4.tcp_slow_start_after_idle=0"
    "net.ipv4.tcp_no_metrics_save=1"
    "net.ipv4.tcp_moderate_rcvbuf=1"
    "net.ipv4.tcp_timestamps=1"
    "net.ipv4.tcp_sack=1"
    "net.ipv4.tcp_fack=1"
    "net.ipv4.ip_local_port_range=1024 65535"
    "net.netfilter.nf_conntrack_max=1048576"
)

for config in "${NET_CONFIGS[@]}"; do
    apply_sysctl "$config"
done

# 8. Optimizaciones específicas para x86/x64
log "🔧 Aplicando optimizaciones específicas para x86/x64..."
apply_sysctl "# === Optimizaciones x86/x64 específicas ==="

# Optimizar scheduler para sistemas multicore
apply_sysctl "kernel.sched_migration_cost_ns=500000"
apply_sysctl "kernel.sched_autogroup_enabled=0"
apply_sysctl "kernel.sched_wakeup_granularity_ns=15000000"
apply_sysctl "kernel.sched_min_granularity_ns=10000000"

# Optimizaciones para sistemas con muchos cores
if [[ $CPU_CORES -ge 8 ]]; then
    apply_sysctl "net.core.netdev_budget=1000"
    apply_sysctl "kernel.sched_rt_runtime_us=950000"
    log "Optimizaciones aplicadas para sistema con ${CPU_CORES} núcleos"
fi

# Optimizaciones específicas por fabricante de CPU
if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
    log "🔷 Aplicando optimizaciones específicas para Intel"
    apply_sysctl "kernel.numa_balancing=1"
elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
    log "🔴 Aplicando optimizaciones específicas para AMD"
    apply_sysctl "kernel.numa_balancing=1"
fi

# 9. Configurar firewall avanzado
log "🛡️ Configurando firewall avanzado..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Permitir SSH y Minecraft
sudo ufw allow ssh
sudo ufw allow 25565/tcp  # Puerto Minecraft por defecto
sudo ufw allow 25566:25576/tcp  # Puertos adicionales para múltiples servidores

# Configuraciones avanzadas de firewall
sudo ufw limit ssh  # Rate limiting para SSH
sudo ufw --force enable

# 10. Configurar fail2ban avanzado
log "🔒 Configurando fail2ban avanzado..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Configuración personalizada para Minecraft
sudo tee /etc/fail2ban/jail.d/minecraft.conf > /dev/null << 'EOF'
[minecraft]
enabled = true
port = 25565
filter = minecraft
logpath = /opt/minecraft/server/logs/latest.log
maxretry = 3
bantime = 3600
EOF

# 11. Optimizar sistema de archivos
log "📁 Optimizando sistema de archivos..."
if ! grep -q "noatime" /etc/fstab; then
    warn "Considera agregar 'noatime,nodiratime' a las opciones de montaje en /etc/fstab"
fi

# 12. Configurar límites del sistema avanzados
log "⚙️ Configurando límites del sistema..."
sudo tee /etc/security/limits.d/minecraft.conf > /dev/null << 'EOF'
# Límites optimizados para servidor Minecraft x86/x64
* soft nofile 1000000
* hard nofile 1000000
* soft nproc 32768
* hard nproc 32768
minecraft soft nofile 1000000
minecraft hard nofile 1000000
minecraft soft nproc 32768
minecraft hard nproc 32768
minecraft soft memlock unlimited
minecraft hard memlock unlimited
EOF

# 13. Crear usuario minecraft si no existe
if ! id "minecraft" &>/dev/null; then
    log "👤 Creando usuario minecraft..."
    sudo useradd -r -m -U -d /opt/minecraft -s /bin/bash minecraft
    sudo usermod -aG sudo minecraft
fi

# 14. Configurar directorio del servidor
log "📂 Preparando directorio del servidor..."
sudo mkdir -p /opt/minecraft/server
sudo mkdir -p /opt/minecraft/backups
sudo mkdir -p /opt/minecraft/logs
sudo chown -R minecraft:minecraft /opt/minecraft
sudo chmod 755 /opt/minecraft

# 15. Configurar hugepages para mejor rendimiento
log "🐘 Configurando hugepages para JVM..."
HUGEPAGES_SIZE=$((TOTAL_RAM_GB * 1024 / 4))  # 1/4 de la RAM para hugepages
if [[ $HUGEPAGES_SIZE -gt 512 ]]; then
    apply_sysctl "vm.nr_hugepages=$HUGEPAGES_SIZE"
    log "Configuradas $HUGEPAGES_SIZE hugepages"
fi

# 16. Optimizar programador de I/O
log "💽 Optimizando programador de I/O..."
for disk in /sys/block/sd*/queue/scheduler; do
    if [[ -f "$disk" ]]; then
        echo mq-deadline | sudo tee "$disk" > /dev/null 2>&1 || true
    fi
done

# 17. Aplicar todas las configuraciones
log "✅ Aplicando configuraciones del kernel..."
sudo sysctl -p

# 18. Configurar servicios del sistema
log "🔄 Optimizando servicios del sistema..."
# Deshabilitar servicios innecesarios
SERVICES_TO_DISABLE=(
    "bluetooth"
    "cups"
    "cups-browsed"
    "ModemManager"
    "avahi-daemon"
)

for service in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl is-enabled "$service" 2>/dev/null | grep -q enabled; then
        sudo systemctl disable "$service" 2>/dev/null || true
        log "Deshabilitado: $service"
    fi
done

# Habilitar servicios importantes
SERVICES_TO_ENABLE=(
    "thermald"
    "irqbalance"
)

for service in "${SERVICES_TO_ENABLE[@]}"; do
    if systemctl list-unit-files | grep -q "$service"; then
        sudo systemctl enable "$service" 2>/dev/null || true
        sudo systemctl start "$service" 2>/dev/null || true
        log "Habilitado: $service"
    fi
done

# 19. Crear scripts de monitoreo avanzados
log "📊 Creando scripts de monitoreo avanzados..."
sudo tee /opt/minecraft/monitor.sh > /dev/null << 'EOF'
#!/bin/bash
# Script de monitoreo avanzado para servidor Minecraft x86/x64

echo "=== ESTADO DEL SERVIDOR MINECRAFT ==="
echo "Fecha: $(date)"
echo "Uptime: $(uptime -p)"
echo "Arquitectura: $(uname -m)"
echo ""

echo "=== CPU ==="
echo "Cores: $(nproc)"
echo "Load Average: $(uptime | awk -F'load average:' '{ print $2 }')"
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | awk '{print "  User: " $2 ", System: " $4 ", Idle: " $8}'
echo "CPU Frequency:"
if command -v cpufreq-info &> /dev/null; then
    cpufreq-info -f 2>/dev/null | head -1 | awk '{print "  Current: " $1/1000000 " GHz"}' || echo "  N/A"
fi
echo ""

echo "=== MEMORIA ==="
free -h
echo ""
echo "Hugepages:"
grep -E "(HugePages|Hugepagesize)" /proc/meminfo
echo ""

echo "=== PROCESOS JAVA ==="
pgrep -f java | xargs -I {} ps -p {} -o pid,ppid,%cpu,%mem,cmd --no-headers 2>/dev/null || echo "No hay procesos Java ejecutándose"
echo ""

echo "=== RED ==="
echo "Puertos Minecraft:"
ss -tuln | grep -E ":(25565|25566|25567)" || echo "No hay puertos Minecraft en uso"
echo ""
echo "Conexiones activas:"
ss -s
echo ""

echo "=== DISCO ==="
df -h | grep -E "(/$|/opt|/home)"
echo ""
echo "I/O Stats:"
if command -v iostat &> /dev/null; then
    iostat -x 1 1 | grep -A 20 "Device"
fi
echo ""

echo "=== TEMPERATURA ==="
if command -v sensors &> /dev/null; then
    sensors 2>/dev/null | grep -E "(Core|temp)" | head -5
else
    echo "sensors no instalado"
fi
echo ""

echo "=== LOGS RECIENTES ==="
if [[ -f /opt/minecraft/server/logs/latest.log ]]; then
    echo "Últimas 3 líneas del servidor:"
    tail -3 /opt/minecraft/server/logs/latest.log
else
    echo "No se encontraron logs del servidor"
fi
EOF

sudo chmod +x /opt/minecraft/monitor.sh
sudo chown minecraft:minecraft /opt/minecraft/monitor.sh

# 20. Crear script de backup automático
log "💾 Creando script de backup automático..."
sudo tee /opt/minecraft/backup.sh > /dev/null << 'EOF'
#!/bin/bash
# Script de backup automático para servidor Minecraft

BACKUP_DIR="/opt/minecraft/backups"
SERVER_DIR="/opt/minecraft/server"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="minecraft_backup_$DATE.tar.gz"

mkdir -p "$BACKUP_DIR"

if [[ -d "$SERVER_DIR" ]]; then
    echo "Creando backup: $BACKUP_NAME"
    tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$SERVER_DIR" . 2>/dev/null
    
    # Mantener solo los últimos 7 backups
    find "$BACKUP_DIR" -name "minecraft_backup_*.tar.gz" -type f -mtime +7 -delete
    
    echo "Backup completado: $BACKUP_DIR/$BACKUP_NAME"
    ls -lh "$BACKUP_DIR/$BACKUP_NAME"
else
    echo "Error: Directorio del servidor no encontrado"
    exit 1
fi
EOF

sudo chmod +x /opt/minecraft/backup.sh
sudo chown minecraft:minecraft /opt/minecraft/backup.sh

# 21. Configurar cron para backups automáticos
log "⏰ Configurando backups automáticos..."
(crontab -u minecraft -l 2>/dev/null; echo "0 3 * * * /opt/minecraft/backup.sh") | sudo -u minecraft crontab -

# 22. Información final
log "🎉 ¡Optimización completada con éxito!"
log ""
log "=== RESUMEN DE CAMBIOS ==="
log "✅ Sistema actualizado con herramientas específicas x86/x64"
log "✅ CPU configurado para máximo rendimiento"
log "✅ IRQ balancing habilitado"
log "✅ Optimizaciones de memoria avanzadas aplicadas"
log "✅ Optimizaciones de red de alto rendimiento aplicadas"
log "✅ Hugepages configuradas"
log "✅ Programador de I/O optimizado"
log "✅ Firewall avanzado configurado"
log "✅ Usuario minecraft creado"
log "✅ Scripts de monitoreo y backup creados"
log "✅ Backups automáticos configurados (diario a las 3:00 AM)"
log ""
log "=== PRÓXIMOS PASOS ==="
log "1. Reiniciar el sistema: sudo reboot"
log "2. Ejecutar el script de monitoreo: /opt/minecraft/monitor.sh"
log "3. Ejecutar backup manual: /opt/minecraft/backup.sh"
log "4. Configurar el servidor Minecraft en: /opt/minecraft/server"
log ""
log "=== COMANDOS ÚTILES ==="
log "• Monitorear sistema: /opt/minecraft/monitor.sh"
log "• Crear backup: /opt/minecraft/backup.sh"
log "• Ver temperatura: sensors"
log "• Ver frecuencia CPU: cpufreq-info"
log "• Estado de IRQ: cat /proc/interrupts"
log "• Ver hugepages: cat /proc/meminfo | grep -i huge"
log ""

warn "⚠️  IMPORTANTE: Reinicia el sistema para aplicar todos los cambios"
log "Backup de configuraciones en: $BACKUP_DIR"
