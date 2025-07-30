# 🛡️ Guía de Seguridad para Servidor Minecraft

Esta guía cubre las mejores prácticas de seguridad para proteger tu servidor Minecraft Fabric.

## 📋 Tabla de Contenidos

- [Configuración Básica de Seguridad](#-configuración-básica-de-seguridad)
- [Configuración de Firewall](#-configuración-de-firewall)
- [Autenticación y Autorización](#-autenticación-y-autorización)
- [Protección contra Ataques](#-protección-contra-ataques)
- [Monitoreo y Logging](#-monitoreo-y-logging)
- [Configuración de Red](#-configuración-de-red)
- [Backups Seguros](#-backups-seguros)
- [Actualizaciones y Parches](#-actualizaciones-y-parches)

## 🔒 Configuración Básica de Seguridad

### Usuario Dedicado (Ya implementado)
```bash
# Verificar que el servidor NO ejecute como root
ps aux | grep java | grep minecraft
# Debe mostrar usuario 'minecraft', NO 'root'

# Si necesitas crear usuario manualmente:
sudo useradd -r -m -d /opt/minecraft -s /bin/bash minecraft
sudo chown -R minecraft:minecraft /opt/minecraft
```

### Permisos de Archivos
```bash
# Configurar permisos correctos
sudo chown -R minecraft:minecraft /opt/minecraft/
sudo find /opt/minecraft/ -type d -exec chmod 755 {} \;
sudo find /opt/minecraft/ -type f -exec chmod 644 {} \;
sudo chmod +x /opt/minecraft/server/iniciador_optimizado_de_minecraft.sh
sudo chmod +x /opt/minecraft/*.sh

# Verificar permisos
ls -la /opt/minecraft/server/
```

### Configuración del Servidor
```bash
# server.properties - Configuraciones de seguridad
sudo -u minecraft nano /opt/minecraft/server/server.properties
```

```properties
# === CONFIGURACIONES DE SEGURIDAD ===

# Autenticación online (CRÍTICO)
online-mode=true                    # Verificar cuentas oficiales de Minecraft
enforce-secure-profile=true        # Perfiles seguros (1.19.1+)

# Configuraciones de acceso
white-list=true                     # Solo jugadores en whitelist
enforce-whitelist=true              # Forzar whitelist siempre

# Configuraciones de mundo
spawn-protection=16                 # Proteger spawn (16 bloques)
allow-flight=false                  # Desactivar vuelo (anti-cheat básico)
max-players=20                      # Limitar jugadores conectados

# Configuraciones de chat y comandos
enable-command-block=false          # Desactivar command blocks
function-permission-level=2         # Nivel mínimo para functions
op-permission-level=4               # Nivel máximo de operadores

# RCON (solo si es necesario)
enable-rcon=false                   # Desactivar por defecto
# rcon.port=25575                   # Cambiar puerto por defecto
# rcon.password=PASSWORD_SEGURO     # Contraseña fuerte si habilitado

# Query (información del servidor)
enable-query=false                  # Desactivar query público
query.port=25565                    # Puerto de query

# Configuraciones de red
server-ip=                          # Vacío = escuchar en todas las interfaces
# server-ip=192.168.1.100          # O IP específica para más seguridad
network-compression-threshold=256   # Comprimir paquetes grandes
max-tick-time=60000                # Tiempo máximo por tick
```

## 🔥 Configuración de Firewall

### UFW (Ubuntu/Debian) - Ya configurado por scripts
```bash
# Verificar estado actual
sudo ufw status verbose

# Configuración básica si no está configurada
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Permitir SSH (ajustar puerto si es diferente)
sudo ufw allow 22/tcp

# Permitir Minecraft
sudo ufw allow 25565/tcp comment 'Minecraft Server'

# RCON solo desde IPs específicas (si es necesario)
# sudo ufw allow from 192.168.1.0/24 to any port 25575 comment 'RCON LAN only'

# Habilitar firewall
sudo ufw enable
```

### iptables (Configuración avanzada)
```bash
# Script de firewall avanzado
sudo nano /opt/minecraft/scripts/firewall-advanced.sh
```

```bash
#!/bin/bash
# firewall-advanced.sh - Configuración avanzada de iptables

# Limpiar reglas existentes
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Políticas por defecto
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitir loopback
iptables -A INPUT -i lo -j ACCEPT

# Permitir conexiones establecidas
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# SSH (cambiar puerto si es diferente)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Minecraft Server
iptables -A INPUT -p tcp --dport 25565 -j ACCEPT

# Limitar conexiones concurrentes por IP (anti-DDoS básico)
iptables -A INPUT -p tcp --dport 25565 -m connlimit --connlimit-above 3 -j DROP

# Rate limiting para nuevas conexiones
iptables -A INPUT -p tcp --dport 25565 -m recent --set --name minecraft
iptables -A INPUT -p tcp --dport 25565 -m recent --update --seconds 60 --hitcount 10 --name minecraft -j DROP

# Bloquear paquetes inválidos
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Protección contra port scans
iptables -A INPUT -m recent --name portscan --rcheck --seconds 86400 -j DROP
iptables -A INPUT -m recent --name portscan --remove
iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP

# Log de conexiones rechazadas (opcional)
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

# Guardar reglas
iptables-save > /etc/iptables/rules.v4
```

### Fail2Ban - Protección contra Brute Force
```bash
# Instalar Fail2Ban
sudo apt update
sudo apt install fail2ban -y

# Configurar filtro para Minecraft
sudo nano /etc/fail2ban/filter.d/minecraft.conf
```

```ini
# Fail2Ban filter for Minecraft
[Definition]
failregex = ^.*\[Server thread/WARN\]: Can't keep up! Is the server overloaded\? Running .* behind, skipping .* tick.*$
            ^.*\[Server thread/INFO\]: <HOST> lost connection: Disconnected$
            ^.*\[Server thread/INFO\]: <HOST>/.*: Disconnected$
            ^.*\[User Authenticator.*\]: UUID of player .* is <HOST>$

ignoreregex =

[Init]
datepattern = ^\[(?P<date>\d{2}:\d{2}:\d{2})\]
```

```bash
# Configurar jail para Minecraft
sudo nano /etc/fail2ban/jail.d/minecraft.conf
```

```ini
[minecraft]
enabled = true
port = 25565
protocol = tcp
filter = minecraft
logpath = /opt/minecraft/server/logs/latest.log
maxretry = 5
bantime = 3600
findtime = 600
action = iptables-allports
```

```bash
# Reiniciar Fail2Ban
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban

# Verificar estado
sudo fail2ban-client status minecraft
```

## 👤 Autenticación y Autorización

### Whitelist Management
```bash
# Habilitar whitelist
sudo -u minecraft nano /opt/minecraft/server/server.properties
# white-list=true
# enforce-whitelist=true

# Gestionar whitelist desde consola del servidor
# (Conectar a consola: sudo -u minecraft screen -r minecraft)

# Agregar jugadores a whitelist
/whitelist add NombreJugador

# Ver whitelist actual
/whitelist list

# Remover de whitelist
/whitelist remove NombreJugador

# Recargar whitelist
/whitelist reload

# Expulsar jugadores no autorizados
/whitelist on
```

### Sistema de Permisos con LuckPerms
```bash
# Instalar LuckPerms
cd /opt/minecraft/server/mods
sudo -u minecraft wget https://luckperms.net/download/fabric -O luckperms.jar

# Configurar base de datos
sudo -u minecraft nano /opt/minecraft/server/config/luckperms/luckperms.conf
```

```conf
# Configuración básica de LuckPerms
storage-method = sqlite
data {
    address = "luckperms-sqlite.db"
}

# Configuración de grupos por defecto
group-name-rewrite {
    default = "jugador"
    admin = "administrador"
    moderator = "moderador"
}

# Auto-op para administradores
auto-op = true
```

```bash
# Comandos básicos de LuckPerms (en consola del servidor)
# Crear grupos
/lp creategroup moderador
/lp creategroup administrador

# Asignar permisos básicos
/lp group moderador permission set minecraft.command.kick true
/lp group moderador permission set minecraft.command.ban true
/lp group administrador parent add moderador
/lp group administrador permission set "*" true

# Asignar jugadores a grupos
/lp user NombreJugador parent add moderador
/lp user NombreAdmin parent add administrador
```

### Configuración de OPs
```bash
# Gestionar operadores (nivel de permisos)
# Nivel 1: Puede ignorar spawn protection
# Nivel 2: Puede usar /clear, /difficulty, /effect, etc.
# Nivel 3: Puede usar /ban, /deop, /kick, /op
# Nivel 4: Puede usar /stop

# En consola del servidor:
/op NombreJugador                    # OP nivel 4 (completo)
/deop NombreJugador                  # Remover OP

# Configurar en ops.json (archivo)
sudo -u minecraft nano /opt/minecraft/server/ops.json
```

```json
[
  {
    "uuid": "UUID-DEL-JUGADOR",
    "name": "NombreJugador",
    "level": 4,
    "bypassesPlayerLimit": false
  }
]
```

## 🛡️ Protección contra Ataques

### Configuraciones Anti-DDoS
```bash
# Ya incluidas en scripts de optimización del sistema
# Verificar configuraciones:

# SYN flood protection
sysctl net.ipv4.tcp_syncookies

# Rate limiting
sysctl net.ipv4.tcp_max_syn_backlog
sysctl net.ipv4.tcp_synack_retries

# Connection tracking
sysctl net.netfilter.nf_conntrack_max
```

### Mods de Seguridad
```bash
# Instalar mods de protección
cd /opt/minecraft/server/mods

# Ledger - Sistema de logging avanzado
sudo -u minecraft wget https://modrinth.com/mod/ledger/version/1.3.2 -O ledger.jar

# No Grief - Protección básica contra griefing
sudo -u minecraft wget [URL] -O no-grief.jar

# WorldGuard para Fabric (si está disponible)
# sudo -u minecraft wget [URL] -O worldguard.jar
```

### Configuración de Ledger (Logging)
```bash
# Configurar Ledger
sudo -u minecraft nano /opt/minecraft/server/config/ledger.conf
```

```toml
# Configuración de Ledger
[database]
type = "mysql"  # o "sqlite" para base local
host = "localhost"
port = 3306
name = "minecraft_logs"
username = "ledger_user"
password = "PASSWORD_SEGURO"

[logging]
# Acciones a registrar
block_break = true
block_place = true
container_access = true
entity_kill = true
item_drop = true
item_pickup = true
player_join = true
player_leave = true

# Duración de logs (días)
purge_days = 90

# Ubicaciones específicas a monitorear
monitor_regions = ["spawn", "admin_area"]
```

### Configuraciones Anti-Cheat
```bash
# server.properties - Configuraciones anti-cheat básicas
allow-flight=false                   # Prevenir vuelo no autorizado
max-player-idle-time=30             # Desconectar AFKs
player-idle-timeout=0               # 0 = sin timeout, >0 = minutos

# Configuraciones adicionales en Fabric
# (Muchos mods anti-cheat están disponibles)
```

## 📊 Monitoreo y Logging

### Configuración de Logs
```bash
# Configurar rotación de logs
sudo nano /etc/logrotate.d/minecraft
```

```
/opt/minecraft/server/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    copytruncate
    create 644 minecraft minecraft
}
```

### Monitoreo de Seguridad
```bash
# Script de monitoreo de seguridad
sudo nano /opt/minecraft/scripts/security-monitor.sh
```

```bash
#!/bin/bash
# security-monitor.sh - Monitoreo de seguridad

LOG_FILE="/var/log/minecraft-security.log"
MINECRAFT_LOG="/opt/minecraft/server/logs/latest.log"

# Función de logging
log_security() {
    echo "[$(date)] $1" | tee -a "$LOG_FILE"
}

# Verificar intentos de conexión sospechosos
check_suspicious_connections() {
    # Múltiples intentos de conexión desde la misma IP
    suspicious_ips=$(tail -1000 "$MINECRAFT_LOG" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort | uniq -c | awk '$1 > 20 {print $2}')
    
    if [ ! -z "$suspicious_ips" ]; then
        log_security "ALERTA: IPs con conexiones sospechosas: $suspicious_ips"
    fi
}

# Verificar jugadores no autorizados
check_unauthorized_players() {
    unauthorized=$(tail -100 "$MINECRAFT_LOG" | grep -i "not white-listed\|not on the white-list")
    
    if [ ! -z "$unauthorized" ]; then
        log_security "ALERTA: Intentos de conexión no autorizados detectados"
    fi
}

# Verificar uso excesivo de comandos
check_command_spam() {
    command_spam=$(tail -500 "$MINECRAFT_LOG" | grep "issued server command" | cut -d' ' -f4 | sort | uniq -c | awk '$1 > 50 {print $2 ": " $1}')
    
    if [ ! -z "$command_spam" ]; then
        log_security "ALERTA: Posible spam de comandos: $command_spam"
    fi
}

# Ejecutar verificaciones
check_suspicious_connections
check_unauthorized_players
check_command_spam

# Verificar estado de Fail2Ban
if systemctl is-active --quiet fail2ban; then
    banned_ips=$(sudo fail2ban-client status minecraft | grep "Banned IP list" | cut -d: -f2)
    if [ ! -z "$banned_ips" ]; then
        log_security "INFO: IPs baneadas por Fail2Ban: $banned_ips"
    fi
fi

log_security "Verificación de seguridad completada"
```

```bash
# Hacer ejecutable y programar
sudo chmod +x /opt/minecraft/scripts/security-monitor.sh

# Agregar a crontab para ejecutar cada 10 minutos
(crontab -l 2>/dev/null; echo "*/10 * * * * /opt/minecraft/scripts/security-monitor.sh") | crontab -
```

### Alertas por Email (Opcional)
```bash
# Instalar herramientas de email
sudo apt install mailutils ssmtp -y

# Configurar SSMTP
sudo nano /etc/ssmtp/ssmtp.conf
```

```conf
root=admin@tudominio.com
mailhub=smtp.gmail.com:587
AuthUser=tu-email@gmail.com
AuthPass=tu-password-de-aplicacion
UseSTARTTLS=YES
```

```bash
# Script para enviar alertas
sudo nano /opt/minecraft/scripts/send-security-alert.sh
```

```bash
#!/bin/bash
# send-security-alert.sh - Enviar alertas de seguridad

ALERT_EMAIL="admin@tudominio.com"
SUBJECT="[MINECRAFT] Alerta de Seguridad"

if [ ! -z "$1" ]; then
    echo "$1" | mail -s "$SUBJECT" "$ALERT_EMAIL"
    echo "[$(date)] Alerta enviada: $1" >> /var/log/minecraft-alerts.log
fi
```

## 🌐 Configuración de Red

### Proxy/CDN (Para servidores públicos)
```bash
# Configurar detrás de proxy (Cloudflare, etc.)
# Obtener IP real del jugador

# server.properties
# network-compression-threshold=256
# prevent-proxy-connections=false

# Si usas Cloudflare, configurar:
# - Tipo de registro: A (para subdomain.tudominio.com)
# - TTL: Auto
# - Proxy status: DNS only (nube gris, no naranja)
```

### VPN/Túnel Seguro
```bash
# Para administración remota segura, configurar túnel SSH
# En tu máquina local:
ssh -L 25575:localhost:25575 usuario@servidor-minecraft.com

# Habilitar RCON solo para localhost
# server.properties:
# rcon.port=25575
# rcon.password=PASSWORD_SEGURO
# enable-rcon=true

# Firewall solo permitir RCON desde localhost
sudo ufw deny 25575
# El túnel SSH redirigirá el tráfico de forma segura
```

### Configuraciones de DNS
```bash
# Configurar DNS seguro en el servidor
sudo nano /etc/systemd/resolved.conf
```

```conf
[Resolve]
DNS=1.1.1.1 8.8.8.8
FallbackDNS=1.0.0.1 8.8.4.4
DNSOverTLS=yes
```

```bash
sudo systemctl restart systemd-resolved
```

## 💾 Backups Seguros

### Configuración de Backups Encriptados
```bash
# Script de backup seguro
sudo nano /opt/minecraft/scripts/secure-backup.sh
```

```bash
#!/bin/bash
# secure-backup.sh - Backup encriptado del servidor

BACKUP_DIR="/opt/minecraft/backups"
BACKUP_NAME="minecraft-backup-$(date +%Y%m%d-%H%M%S)"
WORLD_DIR="/opt/minecraft/server"
ENCRYPTION_PASSWORD_FILE="/opt/minecraft/.backup-password"

# Crear directorio de backups si no existe
mkdir -p "$BACKUP_DIR"

# Generar password de encriptación si no existe
if [ ! -f "$ENCRYPTION_PASSWORD_FILE" ]; then
    openssl rand -base64 32 > "$ENCRYPTION_PASSWORD_FILE"
    chmod 600 "$ENCRYPTION_PASSWORD_FILE"
    chown minecraft:minecraft "$ENCRYPTION_PASSWORD_FILE"
fi

# Crear backup comprimido y encriptado
tar czf - -C "$WORLD_DIR" world world_nether world_the_end server.properties ops.json whitelist.json banned-players.json banned-ips.json | \
    openssl enc -aes-256-cbc -salt -pass file:"$ENCRYPTION_PASSWORD_FILE" > "$BACKUP_DIR/$BACKUP_NAME.tar.gz.enc"

# Verificar que el backup se creó correctamente
if [ $? -eq 0 ]; then
    echo "[$(date)] Backup seguro creado: $BACKUP_NAME.tar.gz.enc"
    
    # Limpiar backups antiguos (mantener solo 7 días)
    find "$BACKUP_DIR" -name "*.tar.gz.enc" -mtime +7 -delete
else
    echo "[$(date)] ERROR: Falló la creación del backup"
    exit 1
fi
```

### Backup a Ubicación Remota
```bash
# Configurar backup remoto con rsync
sudo nano /opt/minecraft/scripts/remote-backup.sh
```

```bash
#!/bin/bash
# remote-backup.sh - Sincronizar backups a ubicación remota

LOCAL_BACKUP_DIR="/opt/minecraft/backups"
REMOTE_USER="backup-user"
REMOTE_HOST="backup-server.com"
REMOTE_DIR="/backups/minecraft"

# Sincronizar backups encriptados
rsync -avz --delete \
    -e "ssh -i /opt/minecraft/.ssh/backup_key" \
    "$LOCAL_BACKUP_DIR/" \
    "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"

if [ $? -eq 0 ]; then
    echo "[$(date)] Backup remoto completado"
else
    echo "[$(date)] ERROR: Falló el backup remoto"
fi
```

## 🔄 Actualizaciones y Parches

### Automatización de Actualizaciones de Seguridad
```bash
# Configurar actualizaciones automáticas de seguridad
sudo apt install unattended-upgrades -y

# Configurar
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

```
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";

// Enviar email de notificación
Unattended-Upgrade::Mail "admin@tudominio.com";
```

### Monitoreo de Vulnerabilidades
```bash
# Script para verificar vulnerabilidades conocidas
sudo nano /opt/minecraft/scripts/vulnerability-check.sh
```

```bash
#!/bin/bash
# vulnerability-check.sh - Verificar vulnerabilidades conocidas

# Verificar actualizaciones de seguridad disponibles
SECURITY_UPDATES=$(apt list --upgradable 2>/dev/null | grep -i security | wc -l)

if [ $SECURITY_UPDATES -gt 0 ]; then
    echo "[$(date)] ALERTA: $SECURITY_UPDATES actualizaciones de seguridad disponibles"
    apt list --upgradable 2>/dev/null | grep -i security
fi

# Verificar versión de Java
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
echo "[$(date)] Versión de Java: $JAVA_VERSION"

# Verificar versión de Minecraft/Fabric
if [ -f "/opt/minecraft/server/fabric-server-launch.jar" ]; then
    # Extraer versión de Fabric (si es posible)
    echo "[$(date)] Verificando versión de Fabric..."
fi

# Verificar puertos abiertos
OPEN_PORTS=$(nmap -sT localhost 2>/dev/null | grep open | wc -l)
echo "[$(date)] Puertos abiertos en localhost: $OPEN_PORTS"
```

## 🚨 Plan de Respuesta a Incidentes

### Protocolo de Respuesta
```bash
# Script de respuesta a incidentes
sudo nano /opt/minecraft/scripts/incident-response.sh
```

```bash
#!/bin/bash
# incident-response.sh - Respuesta automática a incidentes

INCIDENT_TYPE="$1"
INCIDENT_DETAILS="$2"

case "$INCIDENT_TYPE" in
    "ddos")
        # Activar protección anti-DDoS más agresiva
        iptables -A INPUT -p tcp --dport 25565 -m recent --update --seconds 30 --hitcount 5 --name minecraft -j DROP
        echo "[$(date)] Protección anti-DDoS activada"
        ;;
    
    "griefing")
        # Hacer backup inmediato antes de restaurar
        /opt/minecraft/scripts/secure-backup.sh
        echo "[$(date)] Backup de emergencia creado debido a griefing"
        ;;
    
    "hack_attempt")
        # Activar logging más detallado
        echo "[$(date)] Intento de hack detectado: $INCIDENT_DETAILS"
        # Notificar administradores
        ;;
    
    *)
        echo "Tipo de incidente no reconocido: $INCIDENT_TYPE"
        ;;
esac
```

### Contactos de Emergencia
```bash
# Lista de contactos y procedimientos
sudo nano /opt/minecraft/docs/emergency-contacts.txt
```

```
CONTACTOS DE EMERGENCIA - SERVIDOR MINECRAFT

Administrador Principal:
- Nombre: [Tu Nombre]
- Email: admin@tudominio.com
- Teléfono: +XX XXX XXX XXXX
- Discord: usuario#1234

Administrador Técnico:
- Nombre: [Nombre]
- Email: tech@tudominio.com
- Teléfono: +XX XXX XXX XXXX

Proveedor de Hosting:
- Empresa: [Nombre del Proveedor]
- Soporte: support@proveedor.com
- Teléfono: +XX XXX XXX XXXX

PROCEDIMIENTOS DE EMERGENCIA:

1. Ataque DDoS:
   - Ejecutar: /opt/minecraft/scripts/incident-response.sh ddos
   - Contactar proveedor de hosting
   - Activar Cloudflare DDoS protection si disponible

2. Griefing Masivo:
   - Detener servidor inmediatamente
   - Ejecutar: /opt/minecraft/scripts/incident-response.sh griefing
   - Restaurar último backup limpio
   - Investigar logs con Ledger

3. Compromiso de Seguridad:
   - Cambiar todas las contraseñas
   - Revisar logs de acceso
   - Notificar a todos los administradores
   - Ejecutar análisis de seguridad completo

4. Caída del Servidor:
   - Verificar logs: journalctl -u minecraft-fabric
   - Verificar recursos: htop, df -h
   - Reiniciar servicios si es necesario
   - Contactar soporte técnico si persiste
```

## 📋 Checklist de Seguridad

### Verificación Diaria
- [ ] ✅ **Servidor funcionando correctamente**
- [ ] ✅ **Logs sin errores críticos**
- [ ] ✅ **Backups automáticos funcionando**
- [ ] ✅ **Fail2Ban activo y sin alertas**
- [ ] ✅ **Uso de recursos normal**

### Verificación Semanal
- [ ] ✅ **Revisar logs de seguridad**
- [ ] ✅ **Verificar actualizaciones disponibles**
- [ ] ✅ **Probar restauración de backup**
- [ ] ✅ **Revisar lista de jugadores activos**
- [ ] ✅ **Verificar configuraciones de firewall**

### Verificación Mensual
- [ ] ✅ **Actualizar sistema operativo**
- [ ] ✅ **Actualizar Java si hay nuevas versiones**
- [ ] ✅ **Revisar y actualizar mods**
- [ ] ✅ **Cambiar contraseñas de administración**
- [ ] ✅ **Revisar políticas de acceso**
- [ ] ✅ **Auditoría completa de seguridad**

---

La seguridad es un proceso continuo. Mantén siempre actualizado tu servidor y mantente informado sobre las mejores prácticas de seguridad para Minecraft.

¿Tienes dudas específicas sobre seguridad? [Crea un issue](../../issues/new/choose) o consulta la [documentación adicional](WIKI_HOME.md).