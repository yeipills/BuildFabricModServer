# 🧩 Gestión de Mods para Fabric

Guía completa para instalar, configurar y gestionar mods en tu servidor Minecraft Fabric.

## 📋 Conceptos Básicos

### ¿Qué es Fabric?
Fabric es un modloader ligero y modular para Minecraft que permite:
- ✅ Carga rápida y eficiente de mods
- ✅ Compatibilidad con las últimas versiones de Minecraft
- ✅ API estable para desarrolladores
- ✅ Mejor rendimiento que otros modloaders

### Requisitos para Mods
- **Fabric API**: Requerido para la mayoría de mods
- **Versión correcta**: Mod compatible con tu versión de Minecraft
- **Dependencias**: Algunos mods requieren otros mods para funcionar

## 🔧 Instalación de Mods

### Estructura de Directorios
```
/opt/minecraft/server/
├── mods/                    # Mods del servidor (.jar files)
├── config/                  # Configuraciones de mods
├── fabric-server-launch.jar # Launcher de Fabric
└── server.properties       # Configuración del servidor
```

### Método 1: Instalación Manual
```bash
# Navegar al directorio de mods
cd /opt/minecraft/server/mods

# Descargar mod (ejemplo: Fabric API)
wget https://github.com/FabricMC/fabric/releases/download/0.92.2+1.20.4/fabric-api-0.92.2+1.20.4.jar

# Verificar permisos
sudo chown minecraft:minecraft *.jar
sudo chmod 644 *.jar

# Reiniciar servidor para cargar mods
sudo systemctl restart minecraft-fabric
```

### Método 2: Script de Instalación de Mods
```bash
#!/bin/bash
# install-mod.sh - Script para instalar mods

MOD_URL="$1"
MOD_NAME="$2"

if [ -z "$MOD_URL" ] || [ -z "$MOD_NAME" ]; then
    echo "Uso: $0 <URL_DEL_MOD> <NOMBRE_DEL_MOD>"
    exit 1
fi

cd /opt/minecraft/server/mods
sudo -u minecraft wget "$MOD_URL" -O "$MOD_NAME.jar"

if [ $? -eq 0 ]; then
    echo "✅ Mod $MOD_NAME instalado correctamente"
    echo "🔄 Reinicia el servidor para cargar el mod"
else
    echo "❌ Error al descargar el mod"
    exit 1
fi
```

### Método 3: Usando Docker
```bash
# Si usas Docker, copia mods al volumen
cp nuevo-mod.jar ./data/mods/

# O descarga directamente en el volumen
docker exec minecraft-fabric-server wget URL_MOD -O /opt/minecraft/mods/mod-name.jar

# Reiniciar contenedor
./docker-run.sh restart
```

## 📦 Mods Esenciales

### Fabric API (Obligatorio)
```bash
# Fabric API - Base para otros mods
# Versión para Minecraft 1.20.4
wget https://github.com/FabricMC/fabric/releases/download/0.92.2+1.20.4/fabric-api-0.92.2+1.20.4.jar -O fabric-api.jar
```

### Mods de Optimización (Recomendados)
```bash
# Lithium - Optimizaciones generales del servidor
wget https://modrinth.com/mod/lithium/version/mc1.20.4-0.11.2 -O lithium.jar

# Phosphor - Optimización del sistema de iluminación
wget https://modrinth.com/mod/phosphor/version/mc1.20.4-0.8.1 -O phosphor.jar

# Starlight - Motor de iluminación reescrito
wget https://modrinth.com/mod/starlight/version/1.1.2+fabric.dbc156f -O starlight.jar

# FerriteCore - Reducción de uso de memoria
wget https://modrinth.com/mod/ferrite-core/version/6.0.1-fabric -O ferritecore.jar

# LazyDFU - Carga lazy de DataFixerUpper
wget https://modrinth.com/mod/lazydfu/version/0.1.3 -O lazydfu.jar
```

### Mods de Administración
```bash
# LuckPerms - Sistema de permisos avanzado
wget https://luckperms.net/download/fabric -O luckperms.jar

# Carpet - Herramientas de administración y debugging
wget https://github.com/gnembon/fabric-carpet/releases/latest/download/fabric-carpet-1.20.4.jar -O carpet.jar

# Ledger - Sistema de logging de acciones
wget https://modrinth.com/mod/ledger/version/1.3.2 -O ledger.jar
```

### Mods de Gameplay (Opcionales)
```bash
# Roughly Enough Items (REI) - Visualizador de recetas
wget https://modrinth.com/mod/rei/version/12.0.684+fabric -O rei.jar

# JourneyMap - Mapa del mundo
wget https://modrinth.com/mod/journeymap/version/5.9.18-fabric-1.20.4 -O journeymap.jar

# Iron Chests - Cofres mejorados
wget https://modrinth.com/mod/iron-chests/version/14.4.4 -O iron-chests.jar
```

## ⚙️ Configuración de Mods

### Configuraciones Básicas

#### Fabric API Config
```bash
# No requiere configuración adicional
# Se configura automáticamente
```

#### Lithium Config
```bash
# config/lithium.properties
# Optimizaciones específicas (generalmente no necesita cambios)

# Habilitar/deshabilitar optimizaciones específicas
mixin.ai.pathing=true                    # Optimizar pathfinding de mobs
mixin.block.hopper=true                  # Optimizar hoppers
mixin.chunk.serialization=true          # Optimizar carga/guardado de chunks
mixin.entity.collisions=true            # Optimizar colisiones de entidades
mixin.world.block_entity_ticking=true   # Optimizar block entities
```

#### Carpet Config
```bash
# En consola del servidor:
/carpet setDefault optimizedTNT true     # TNT optimizado
/carpet setDefault fastRedstoneDust true # Redstone rápida
/carpet setDefault lagFreeSpawning true  # Spawning sin lag
/carpet setDefault optimizedDespawnRange true # Rango de despawn optimizado

# Guardar configuración
/carpet save
```

#### LuckPerms Config
```bash
# config/luckperms/luckperms.conf
# Configuración básica para SQLite (local)

storage-method = sqlite
data {
    address = "data/luckperms.db"
}

# Configuración para MySQL (servidores grandes)
# storage-method = mysql
# data {
#     address = "localhost:3306"
#     database = "minecraft"
#     username = "luckperms"
#     password = "password"
# }
```

### Configuraciones Avanzadas

#### Optimizaciones de Rendimiento
```bash
# config/starlight.properties
# Configuraciones de iluminación optimizada

chunk.gen.replace-chunk-gen=true         # Reemplazar generador de chunks
chunk.light.replace-chunk-light=true     # Reemplazar sistema de luz
```

#### Configuraciones de Seguridad
```bash
# config/ledger.properties
# Sistema de logging de acciones

# Qué acciones registrar
log-block-break=true
log-block-place=true
log-container-access=true
log-entity-kill=true
log-item-drop=true
log-item-pickup=true

# Duración de logs (días)
purge-days=30

# Base de datos (SQLite por defecto)
database-type=sqlite
database-path=logs/ledger.db
```

## 🔄 Gestión y Mantenimiento

### Actualización de Mods
```bash
#!/bin/bash
# update-mods.sh - Script para actualizar mods

MODS_DIR="/opt/minecraft/server/mods"
BACKUP_DIR="/opt/minecraft/backups/mods-$(date +%Y%m%d)"

echo "🔄 Actualizando mods..."

# Crear backup de mods actuales
mkdir -p "$BACKUP_DIR"
cp "$MODS_DIR"/*.jar "$BACKUP_DIR"/ 2>/dev/null || true

echo "💾 Backup creado en: $BACKUP_DIR"

# Lista de mods a actualizar (personalizar según necesidades)
declare -A MODS=(
    ["fabric-api"]="https://github.com/FabricMC/fabric/releases/latest/download/fabric-api-VERSION.jar"
    ["lithium"]="https://modrinth.com/mod/lithium/version/latest"
    ["phosphor"]="https://modrinth.com/mod/phosphor/version/latest"
)

for MOD_NAME in "${!MODS[@]}"; do
    echo "📦 Actualizando $MOD_NAME..."
    # Lógica de actualización aquí
    # (Implementar según API de cada plataforma)
done

echo "✅ Actualización completada"
echo "🔄 Reinicia el servidor para aplicar cambios"
```

### Compatibilidad de Mods
```bash
# Verificar compatibilidad antes de instalar
# check-mod-compatibility.sh

MOD_FILE="$1"
MC_VERSION="1.20.4"
FABRIC_VERSION="0.15.6"

if [ -z "$MOD_FILE" ]; then
    echo "Uso: $0 <archivo.jar>"
    exit 1
fi

echo "🔍 Verificando compatibilidad de $MOD_FILE..."

# Extraer fabric.mod.json
unzip -p "$MOD_FILE" fabric.mod.json > /tmp/mod_info.json 2>/dev/null

if [ $? -ne 0 ]; then
    echo "❌ No es un mod de Fabric válido"
    exit 1
fi

# Verificar versión de Minecraft
MC_DEPS=$(jq -r '.depends.minecraft // empty' /tmp/mod_info.json)
FABRIC_DEPS=$(jq -r '.depends.fabricloader // empty' /tmp/mod_info.json)

echo "📋 Información del mod:"
echo "  Minecraft: $MC_DEPS"
echo "  Fabric: $FABRIC_DEPS"

# Verificar dependencias adicionales
REQUIRED_MODS=$(jq -r '.depends | keys[] | select(. != "minecraft" and . != "fabricloader" and . != "java")' /tmp/mod_info.json)

if [ ! -z "$REQUIRED_MODS" ]; then
    echo "⚠️  Dependencias requeridas:"
    echo "$REQUIRED_MODS" | while read dep; do
        echo "  - $dep"
    done
fi

rm -f /tmp/mod_info.json
```

### Resolución de Conflictos
```bash
# detect-mod-conflicts.sh - Detectar conflictos entre mods

MODS_DIR="/opt/minecraft/server/mods"
TEMP_DIR="/tmp/mod_analysis"

mkdir -p "$TEMP_DIR"

echo "🔍 Analizando mods para conflictos..."

for mod in "$MODS_DIR"/*.jar; do
    mod_name=$(basename "$mod" .jar)
    
    # Extraer información del mod
    unzip -p "$mod" fabric.mod.json > "$TEMP_DIR/$mod_name.json" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        # Verificar mixins
        mixins=$(jq -r '.mixins[]? // empty' "$TEMP_DIR/$mod_name.json")
        
        if [ ! -z "$mixins" ]; then
            echo "$mod_name: $mixins" >> "$TEMP_DIR/mixins.txt"
        fi
    fi
done

# Buscar mixins duplicados (posibles conflictos)
if [ -f "$TEMP_DIR/mixins.txt" ]; then
    echo "⚠️  Posibles conflictos de mixins:"
    sort "$TEMP_DIR/mixins.txt" | uniq -d
fi

rm -rf "$TEMP_DIR"
```

## 🎯 Casos de Uso Específicos

### Servidor de Supervivencia Vanilla+
```bash
# Mods recomendados para experiencia vanilla mejorada
mods_survival=(
    "fabric-api.jar"
    "lithium.jar"
    "phosphor.jar"
    "starlight.jar"
    "carpet.jar"           # Herramientas de admin
    "ledger.jar"           # Logging
    "minimap.jar"          # Minimapa opcional
)
```

### Servidor Técnico/Redstone
```bash
# Mods para jugadores técnicos
mods_technical=(
    "fabric-api.jar"
    "carpet.jar"           # Esencial para mecánicas técnicas
    "carpet-extra.jar"     # Funciones adicionales
    "litematica.jar"       # Esquemas de construcciones
    "worldedit.jar"        # Edición de mundo
    "rei.jar"              # Recetas y información
)
```

### Servidor de Aventura/RPG
```bash
# Mods para experiencia RPG
mods_rpg=(
    "fabric-api.jar"
    "lithium.jar"
    "origins.jar"          # Razas/orígenes
    "pehkui.jar"           # Escalado de entidades
    "trinkets.jar"         # Sistema de accesorios
    "rpg-stats.jar"        # Sistema de estadísticas
    "custom-npcs.jar"      # NPCs personalizados
)
```

### Servidor Creativo
```bash
# Mods para construcción creativa
mods_creative=(
    "fabric-api.jar"
    "worldedit.jar"        # Edición de mundo
    "litematica.jar"       # Esquemas
    "tweakeroo.jar"        # Herramientas de construcción
    "building-gadgets.jar" # Gadgets de construcción
    "chisels-bits.jar"     # Bloques detallados
)
```

## 🔧 Herramientas de Desarrollo

### Crear Mod Pack Personalizado
```bash
#!/bin/bash
# create-modpack.sh - Crear pack de mods personalizado

PACK_NAME="$1"
PACK_VERSION="$2"
MINECRAFT_VERSION="1.20.4"

if [ -z "$PACK_NAME" ] || [ -z "$PACK_VERSION" ]; then
    echo "Uso: $0 <nombre_pack> <version>"
    exit 1
fi

PACK_DIR="modpacks/$PACK_NAME-$PACK_VERSION"
mkdir -p "$PACK_DIR"

# Crear estructura del modpack
mkdir -p "$PACK_DIR"/{mods,config,resourcepacks,datapacks}

# Copiar mods actuales
cp /opt/minecraft/server/mods/*.jar "$PACK_DIR/mods/"

# Copiar configuraciones
cp -r /opt/minecraft/server/config/* "$PACK_DIR/config/" 2>/dev/null || true

# Crear manifiesto del modpack
cat > "$PACK_DIR/modpack.json" << EOF
{
    "name": "$PACK_NAME",
    "version": "$PACK_VERSION",
    "minecraft_version": "$MINECRAFT_VERSION",
    "created": "$(date -Iseconds)",
    "mods": []
}
EOF

# Listar mods en el manifiesto
for mod in "$PACK_DIR/mods"/*.jar; do
    mod_name=$(basename "$mod" .jar)
    # Extraer información del mod y agregarla al JSON
done

echo "✅ Modpack creado en: $PACK_DIR"
```

### Testing de Mods
```bash
#!/bin/bash
# test-mod.sh - Probar mod en servidor de testing

MOD_FILE="$1"
TEST_PORT="25566"

if [ -z "$MOD_FILE" ]; then
    echo "Uso: $0 <archivo.jar>"
    exit 1
fi

echo "🧪 Iniciando test del mod: $MOD_FILE"

# Crear servidor de testing temporal
TEST_DIR="/tmp/minecraft-test-$(date +%s)"
mkdir -p "$TEST_DIR"/{mods,config}

# Copiar archivos base
cp /opt/minecraft/server/fabric-server-launch.jar "$TEST_DIR/"
cp /opt/minecraft/server/server.properties "$TEST_DIR/"

# Configurar puerto diferente
sed -i "s/server-port=25565/server-port=$TEST_PORT/" "$TEST_DIR/server.properties"

# Copiar mods esenciales
cp /opt/minecraft/server/mods/fabric-api.jar "$TEST_DIR/mods/"

# Copiar mod a testear
cp "$MOD_FILE" "$TEST_DIR/mods/"

# Aceptar EULA automáticamente
echo "eula=true" > "$TEST_DIR/eula.txt"

echo "🚀 Iniciando servidor de test en puerto $TEST_PORT..."
cd "$TEST_DIR"

# Iniciar servidor con configuración básica
java -Xms1G -Xmx2G -jar fabric-server-launch.jar nogui &
TEST_PID=$!

echo "📝 PID del servidor de test: $TEST_PID"
echo "⏱️  Esperando 30 segundos para verificar estabilidad..."

sleep 30

if kill -0 $TEST_PID 2>/dev/null; then
    echo "✅ Mod parece estable después de 30 segundos"
    echo "🎮 Conecta a localhost:$TEST_PORT para probar"
    echo "❌ Presiona Ctrl+C para detener el test"
    wait $TEST_PID
else
    echo "❌ El servidor se cerró, revisa los logs"
    cat logs/latest.log | tail -20
fi

# Limpiar
kill $TEST_PID 2>/dev/null || true
rm -rf "$TEST_DIR"
```

## 🔍 Resolución de Problemas

### Mods No Cargan
```bash
# Verificar logs del servidor
tail -100 /opt/minecraft/server/logs/latest.log | grep -i "mod\|fabric\|error"

# Verificar estructura del mod
unzip -l archivo-mod.jar | grep -E "(fabric.mod.json|mixins)"

# Verificar dependencias
jq '.depends' archivo-mod-extraido/fabric.mod.json
```

### Conflictos de Mods
```bash
# Buscar conflictos en logs
grep -i "conflict\|mixin.*failed\|duplicate" /opt/minecraft/server/logs/latest.log

# Método de eliminación binaria
# 1. Quitar la mitad de los mods
# 2. Probar servidor
# 3. Si funciona, el problema está en los mods removidos
# 4. Repetir hasta encontrar el mod problemático
```

### Rendimiento con Mods
```bash
# Profiling con mods
# En consola del servidor:
/profile start
# ... esperar 60 segundos ...
/profile stop

# Verificar uso de memoria por mod
jmap -histo PID_JAVA | grep -i mod

# Benchmark comparativo
./benchmark.sh --before-mods
# Instalar mods
./benchmark.sh --after-mods
```

## 📚 Recursos Adicionales

### Sitios de Descarga de Mods
- **[Modrinth](https://modrinth.com/)** - Plataforma moderna de mods
- **[CurseForge](https://www.curseforge.com/minecraft/modpacks)** - Plataforma tradicional
- **[GitHub](https://github.com/)** - Mods open source

### Herramientas Útiles
- **[Fabric API Docs](https://fabricmc.net/wiki/)** - Documentación oficial
- **[ModMenu](https://modrinth.com/mod/modmenu)** - Menu de mods en cliente
- **[Mod Compatibility Checker](https://fabricmc.net/wiki/tutorial:updating_yarn)** - Verificar compatibilidad

### Comunidades
- **[Fabric Discord](https://discord.gg/v6v4pMv)** - Soporte oficial
- **[r/feedthebeast](https://reddit.com/r/feedthebeast)** - Comunidad de modding
- **[r/fabricmc](https://reddit.com/r/fabricmc)** - Comunidad específica de Fabric

---

¿Tienes problemas específicos con algún mod? Consulta la [Guía de Troubleshooting](TROUBLESHOOTING.md) o [crea un issue](../../issues/new/choose) con detalles del mod y error.