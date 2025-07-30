# 🚀 Guía de Inicio Rápido

Esta guía te ayudará a tener tu servidor Minecraft Fabric funcionando en menos de 10 minutos.

## 📋 Opción 1: Instalación Automática

### Paso 1: Descargar e Instalar
```bash
# Clonar el repositorio
git clone <repository-url>
cd BuildFabricModServer

# Ejecutar instalador automático
./install.sh
```

### Paso 2: Optimizar Sistema
```bash
# Para sistemas ARM (Raspberry Pi, etc.)
./script_optimizacion_debian_11_ARM.sh

# Para sistemas x86/x64 (PCs, servidores)
./script_optimizacion_debian_11_x86-x86_64.sh
```

### Paso 3: Aceptar EULA
```bash
# Editar archivo EULA
sudo -u minecraft nano /opt/minecraft/server/eula.txt
# Cambiar "eula=false" a "eula=true"
```

### Paso 4: Iniciar Servidor
```bash
# Iniciar con systemd
sudo systemctl start minecraft-fabric

# O manualmente
cd /opt/minecraft/server
./iniciador_optimizado_de_minecraft.sh
```

## 🐳 Opción 2: Docker (Recomendado)

### Paso 1: Preparar Docker
```bash
# Construir imagen
./docker-run.sh build

# Configurar EULA (cambiar a true)
nano docker-compose.yml
# Buscar: EULA=false
# Cambiar a: EULA=true
```

### Paso 2: Iniciar Servidor
```bash
# Iniciar todos los servicios
./docker-run.sh start

# Ver logs en tiempo real
./docker-run.sh logs -f
```

## ⚡ Comandos Esenciales

### Gestión del Servidor
```bash
# Iniciar servidor
sudo systemctl start minecraft-fabric
# O: ./docker-run.sh start

# Detener servidor
sudo systemctl stop minecraft-fabric
# O: ./docker-run.sh stop

# Ver estado
sudo systemctl status minecraft-fabric
# O: ./docker-run.sh status

# Ver logs
sudo journalctl -u minecraft-fabric -f
# O: ./docker-run.sh logs -f
```

### Backup y Mantenimiento
```bash
# Crear backup manual
/opt/minecraft/backup.sh
# O: ./docker-run.sh backup

# Actualizar servidor
./update-server.sh -m 1.20.4 -f 0.15.6
# O: ./docker-run.sh update

# Benchmark del sistema
./benchmark.sh -q  # Benchmark rápido
```

### Monitoreo
```bash
# Estado del sistema
/opt/minecraft/monitor.sh

# Conectar a consola del servidor
sudo -u minecraft screen -r minecraft
# O: ./docker-run.sh console
```

## 🎮 Conectarse al Servidor

1. **IP del servidor**: Tu dirección IP pública
2. **Puerto**: 25565 (por defecto)
3. **Versión**: Minecraft 1.20.4 con Fabric

## 🔧 Configuración Rápida

### Cambiar Configuración Básica
```bash
# Editar configuración principal
sudo -u minecraft nano /opt/minecraft/server/server.properties

# Configuraciones importantes:
# max-players=20          # Máximo de jugadores
# difficulty=normal       # Dificultad del juego
# gamemode=survival       # Modo de juego
# pvp=true               # PvP habilitado
# view-distance=10       # Distancia de render
```

### Agregar Mods
```bash
# Directorio de mods
cd /opt/minecraft/server/mods

# Descargar mods compatibles con Fabric 1.20.4
wget URL_DEL_MOD.jar

# Reiniciar servidor para cargar mods
sudo systemctl restart minecraft-fabric
```

### Gestionar Jugadores
```bash
# Conectar a consola del servidor
sudo -u minecraft screen -r minecraft

# Comandos en la consola:
# /op JUGADOR              # Dar permisos de admin
# /whitelist add JUGADOR   # Agregar a whitelist
# /kick JUGADOR           # Expulsar jugador
# /ban JUGADOR            # Banear jugador
```

## 🛠️ Solución de Problemas Rápida

### El servidor no inicia
```bash
# Verificar logs
sudo journalctl -u minecraft-fabric -n 50

# Verificar Java
java -version

# Verificar permisos
sudo chown -R minecraft:minecraft /opt/minecraft
```

### Rendimiento lento
```bash
# Ejecutar benchmark
./benchmark.sh -q

# Verificar RAM disponible
free -h

# Ajustar memoria en iniciador
nano /opt/minecraft/server/iniciador_optimizado_de_minecraft.sh
```

### Problemas de conexión
```bash
# Verificar puerto
sudo ss -tuln | grep 25565

# Verificar firewall
sudo ufw status

# Abrir puerto si es necesario
sudo ufw allow 25565/tcp
```

## 📚 Recursos Adicionales

- **Documentación completa**: Ver README.md
- **Configuración avanzada**: Revisar archivos en `configs/`
- **Mods recomendados**: [CurseForge Fabric](https://www.curseforge.com/minecraft/modpacks)
- **Comunidad Fabric**: [FabricMC Discord](https://discord.gg/v6v4pMv)

## 🎯 Próximos Pasos

1. ✅ Servidor funcionando
2. 🔧 Personalizar configuración
3. 🎮 Agregar mods favoritos
4. 👥 Invitar amigos
5. 💾 Configurar backups automáticos
6. 📊 Monitorear rendimiento

¡Disfruta tu servidor Minecraft Fabric optimizado! 🎉