# 🚀 Servidor Minecraft Fabric Optimizado

[![Version](https://img.shields.io/badge/version-2.0-blue.svg)](https://github.com/user/BuildFabricModServer/releases)
[![Minecraft](https://img.shields.io/badge/minecraft-1.20.4-green.svg)](https://minecraft.net)
[![Fabric](https://img.shields.io/badge/fabric-0.15.6-purple.svg)](https://fabricmc.net)
[![License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-supported-blue.svg)](https://hub.docker.com)
[![CI](https://github.com/user/BuildFabricModServer/workflows/CI/badge.svg)](https://github.com/user/BuildFabricModServer/actions)
[![Security](https://github.com/user/BuildFabricModServer/workflows/Security/badge.svg)](https://github.com/user/BuildFabricModServer/security)

[![Stars](https://img.shields.io/github/stars/user/BuildFabricModServer?style=social)](https://github.com/user/BuildFabricModServer/stargazers)
[![Forks](https://img.shields.io/github/forks/user/BuildFabricModServer?style=social)](https://github.com/user/BuildFabricModServer/network/members)
[![Issues](https://img.shields.io/github/issues/user/BuildFabricModServer)](https://github.com/user/BuildFabricModServer/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/user/BuildFabricModServer)](https://github.com/user/BuildFabricModServer/pulls)

Una solución completa para configurar y optimizar servidores de Minecraft con Fabric ModLoader en sistemas Linux (ARM y x86/x64).

## 📋 Características

- ✅ Instalación automatizada de dependencias
- ⚡ Scripts de optimización del sistema específicos por arquitectura
- 🎯 Iniciador optimizado con flags JVM de alto rendimiento
- 🔧 Configuraciones de red y memoria optimizadas
- 📊 Monitoreo de rendimiento integrado
- 🛡️ Configuraciones de seguridad básicas

## 🖥️ Arquitecturas Soportadas

- **ARM** (Raspberry Pi, servidores ARM)
- **x86/x64** (servidores tradicionales)

## 📦 Requisitos del Sistema

### Requisitos Mínimos
- **CPU**: 2 núcleos
- **RAM**: 2GB (recomendado 4GB+)
- **Almacenamiento**: 5GB libres
- **SO**: Debian 11/12, Ubuntu 20.04+

### Software Requerido
- Java Development Kit (JDK) 17 o superior
- [Fabric Mod Loader](https://fabricmc.net/use/server/)
- [Fabric API](https://www.curseforge.com/minecraft/mc-mods/fabric-api)

## 🔧 Instalación Rápida

### 1. Instalación de Java 17

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar OpenJDK 17
sudo apt install openjdk-17-jdk -y

# Verificar instalación
java -version
```

**Salida esperada:**
```
openjdk version "17.0.x" 2024-xx-xx
OpenJDK Runtime Environment (build 17.0.x+xx-Debian-x)
OpenJDK 64-Bit Server VM (build 17.0.x+xx-Debian-x, mixed mode, sharing)
```

### 2. Configuración del Servidor Fabric

```bash
# Crear directorio del servidor
mkdir minecraft-server && cd minecraft-server

# Descargar Fabric Installer (reemplazar con la última versión)
wget https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.11.2/fabric-installer-0.11.2.jar

# Instalar Fabric Server
java -jar fabric-installer-0.11.2.jar server -mcversion 1.20.4 -downloadMinecraft

# Crear carpeta de mods
mkdir mods

# Descargar Fabric API (ir a CurseForge y obtener el enlace directo)
# wget -O mods/fabric-api.jar [URL_FABRIC_API]
```

### 3. Optimización del Sistema

Ejecutar el script de optimización correspondiente a tu arquitectura:

```bash
# Para sistemas ARM
./script_optimizacion_debian_11_ARM.sh

# Para sistemas x86/x64
./script_optimizacion_debian_11_x86-x86_64.sh
```

### 4. Iniciar el Servidor

```bash
# Usar el iniciador optimizado
./iniciador_optimizado_de_minecraft.sh
```

## 📊 Scripts Incluidos

### `script_optimizacion_debian_11_ARM.sh`
Optimizaciones específicas para sistemas ARM:
- Actualización del sistema
- Configuración de sysstat para monitoreo
- Optimizaciones de red y memoria
- Configuraciones específicas para ARM

### `script_optimizacion_debian_11_x86-x86_64.sh`
Optimizaciones específicas para sistemas x86/x64:
- Todas las optimizaciones ARM
- Configuraciones adicionales para x86/x64
- Optimizaciones de rendimiento específicas

### `iniciador_optimizado_de_minecraft.sh`
Iniciador del servidor con flags JVM optimizados:
- Garbage Collector G1 optimizado
- Flags de Aikar para máximo rendimiento
- Configuración automática de memoria
- Argumentos optimizados para servidores

## ⚙️ Configuración Avanzada

### Personalizar Memoria RAM

Editar el archivo `iniciador_optimizado_de_minecraft.sh`:

```bash
# Para 4GB de RAM
JAVA_OPTS="-Xmx4G -Xms4G ..."

# Para 8GB de RAM
JAVA_OPTS="-Xmx8G -Xms8G ..."
```

### Monitoreo del Servidor

```bash
# Ver uso de recursos
htop

# Monitorear red
sudo netstat -tuln

# Ver logs del servidor
tail -f logs/latest.log
```

## 🔧 Solución de Problemas

### Errores Comunes

**"Cannot allocate memory"**
```bash
# Reducir RAM asignada
JAVA_OPTS="-Xmx1G -Xms1G ..."
```

**Puerto en uso**
```bash
# Cambiar puerto en server.properties
server-port=25566
```

**Mods incompatibles**
- Verificar versiones de Minecraft y Fabric
- Comprobar dependencias de mods
- Revisar logs para errores específicos

### Logs Útiles
```bash
# Logs del sistema
journalctl -f

# Logs de red
dmesg | grep -i network

# Uso de memoria
free -h
```

## 📝 Notas Importantes

- ✅ Todos los mods deben ser compatibles con Fabric
- ✅ Los jugadores necesitan los mismos mods instalados
- ✅ Verificar compatibilidad Java/Minecraft/Fabric
- ✅ Hacer backups regulares del mundo
- ✅ Monitorear uso de recursos regularmente

## 🤝 Contribuir

¿Encontraste un problema o tienes una mejora? ¡Las contribuciones son bienvenidas!

1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver `LICENSE` para más detalles.

## 🆘 Soporte

Si necesitas ayuda:
- Revisa la sección de Solución de Problemas
- Consulta la documentación oficial de Fabric
- Abre un issue en este repositorio
