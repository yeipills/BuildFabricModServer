# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir a BuildFabricModServer! Esta guía te ayudará a empezar y asegurar que tu contribución sea valiosa para el proyecto.

## 📋 Tabla de Contenidos

- [Código de Conducta](#-código-de-conducta)
- [¿Cómo puedo contribuir?](#-cómo-puedo-contribuir)
- [Proceso de Desarrollo](#-proceso-de-desarrollo)
- [Estilo de Código](#-estilo-de-código)
- [Testing](#-testing)
- [Documentación](#-documentación)
- [Pull Requests](#-pull-requests)
- [Issues](#-issues)

## 📜 Código de Conducta

Este proyecto adhiere al [Código de Conducta](CODE_OF_CONDUCT.md). Al participar, se espera que mantengas este código. Por favor reporta comportamientos inaceptables a [maintainer@example.com].

## 🎯 ¿Cómo puedo contribuir?

### 🐛 Reportando Bugs

Antes de crear un issue:
- ✅ Busca en [issues existentes](../../issues) para evitar duplicados
- ✅ Lee la [documentación](README.md) y [guías de troubleshooting](docs/)
- ✅ Intenta reproducir el problema en una instalación limpia

Usa el [template de bug report](../../issues/new?template=bug_report.yml) que incluye:
- Descripción clara del problema
- Pasos para reproducir
- Comportamiento esperado vs actual
- Información del sistema
- Logs relevantes

### ✨ Sugiriendo Mejoras

Para nuevas características o mejoras:
- ✅ Revisa [issues existentes](../../issues) y [discusiones](../../discussions)
- ✅ Considera si la característica beneficia a la mayoría de usuarios
- ✅ Usa el [template de feature request](../../issues/new?template=feature_request.yml)

### 🔧 Contribuyendo Código

Areas donde necesitamos ayuda:
- **Scripts de optimización**: Mejoras para diferentes distribuciones
- **Documentación**: Guías, tutoriales, traducciones
- **Testing**: Pruebas en diferentes arquitecturas y sistemas
- **Docker**: Optimizaciones de contenedores
- **Monitoreo**: Métricas adicionales y dashboards
- **Seguridad**: Auditorías y mejoras de seguridad

## 🛠️ Proceso de Desarrollo

### 1. Fork y Clone

```bash
# Fork el repositorio en GitHub, luego:
git clone https://github.com/TU_USERNAME/BuildFabricModServer.git
cd BuildFabricModServer

# Agregar upstream remote
git remote add upstream https://github.com/ORIGINAL_USERNAME/BuildFabricModServer.git
```

### 2. Crear Branch

```bash
# Actualizar main
git checkout main
git pull upstream main

# Crear branch para tu feature/fix
git checkout -b feature/nombre-descriptivo
# o
git checkout -b fix/descripcion-del-bug
```

### 3. Hacer Cambios

- ✅ Sigue las [convenciones de estilo](#-estilo-de-código)
- ✅ Agrega tests si es aplicable
- ✅ Actualiza documentación
- ✅ Prueba tus cambios localmente

### 4. Commit

```bash
# Agregar archivos
git add .

# Commit con mensaje descriptivo
git commit -m "tipo(scope): descripción breve

Explicación más detallada si es necesario.

- Cambio específico 1
- Cambio específico 2

Fixes #123"
```

#### Convenciones de Commit

Usar formato: `tipo(scope): descripción`

**Tipos:**
- `feat`: Nueva característica
- `fix`: Corrección de bug
- `docs`: Solo documentación
- `style`: Cambios de formato (no afectan funcionalidad)
- `refactor`: Refactoring de código
- `test`: Agregar o corregir tests
- `chore`: Tareas de mantenimiento

**Scopes:**
- `install`: Script de instalación
- `docker`: Archivos Docker
- `optimize`: Scripts de optimización
- `monitor`: Sistema de monitoreo
- `benchmark`: Suite de benchmarking
- `config`: Configuraciones
- `docs`: Documentación

**Ejemplos:**
```bash
git commit -m "feat(docker): add multi-stage build optimization"
git commit -m "fix(install): resolve Java detection on ARM systems"
git commit -m "docs(api): add configuration examples"
```

### 5. Push y Pull Request

```bash
# Push branch
git push origin feature/nombre-descriptivo

# Crear Pull Request en GitHub
# Usar el template proporcionado
```

## 📝 Estilo de Código

### Shell Scripts

#### Convenciones Generales

```bash
#!/bin/bash

# Header con información del script
#=============================================================================
# 🎯 Nombre del Script
# Versión: X.X
# Descripción: Breve descripción de la funcionalidad
# Autor: Contributor Name
#=============================================================================

# Modo estricto SIEMPRE
set -euo pipefail

# Colores para output consistentes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funciones de logging estándar
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
```

#### Mejores Prácticas

1. **Variables:**
   ```bash
   # Usar mayúsculas para constantes
   readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   readonly DEFAULT_VERSION="1.20.4"
   
   # Usar minúsculas para variables locales
   local user_input=""
   local temp_file="/tmp/script_temp.$$"
   ```

2. **Funciones:**
   ```bash
   # Nombrar descriptivamente
   check_prerequisites() {
       local required_tools=("java" "wget" "curl")
       
       for tool in "${required_tools[@]}"; do
           if ! command -v "$tool" &> /dev/null; then
               error "Required tool not found: $tool"
           fi
       done
   }
   ```

3. **Manejo de Errores:**
   ```bash
   # Siempre verificar códigos de salida
   if ! wget "$url" -O "$output_file"; then
       error "Failed to download: $url"
   fi
   
   # Usar || para alternativas
   java -version || error "Java not installed"
   ```

4. **Documentación:**
   ```bash
   # Documentar funciones complejas
   #
   # Instala Fabric Server con la versión especificada
   # 
   # Args:
   #   $1: Versión de Minecraft
   #   $2: Versión de Fabric
   #   $3: Directorio de instalación
   #
   # Returns:
   #   0: Instalación exitosa
   #   1: Error en descarga
   #   2: Error en instalación
   #
   install_fabric_server() {
       local minecraft_version="$1"
       local fabric_version="$2" 
       local install_dir="$3"
       
       # Implementación...
   }
   ```

### Docker

#### Dockerfile

```dockerfile
# Usar imagen base específica, no 'latest'
FROM openjdk:17-jdk-alpine3.18

# Metadata
LABEL maintainer="BuildFabricModServer"
LABEL description="Optimized Minecraft Fabric Server"
LABEL version="1.0.0"

# Variables de construcción al inicio
ARG MINECRAFT_VERSION=1.20.4
ARG FABRIC_VERSION=0.15.6

# Variables de entorno
ENV MINECRAFT_VERSION=${MINECRAFT_VERSION}
ENV FABRIC_VERSION=${FABRIC_VERSION}

# Crear usuario no-root ANTES de instalar paquetes
RUN addgroup -g 1000 minecraft && \
    adduser -D -s /bin/sh -u 1000 -G minecraft minecraft

# Instalar paquetes en una sola capa
RUN apk add --no-cache \
    curl \
    wget \
    bash \
    && rm -rf /var/cache/apk/*

# Cambiar a usuario no-root temprano
USER minecraft
WORKDIR /opt/minecraft/server

# Copiar y ejecutar scripts
COPY --chown=minecraft:minecraft scripts/ ./scripts/
RUN chmod +x scripts/*.sh

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ./scripts/healthcheck.sh

# Comando por defecto
CMD ["./scripts/start-server.sh"]
```

#### docker-compose.yml

```yaml
version: '3.8'

services:
  minecraft-server:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        MINECRAFT_VERSION: "1.20.4"
        FABRIC_VERSION: "0.15.6"
    
    container_name: minecraft-fabric-server
    hostname: minecraft-server
    
    restart: unless-stopped
    
    environment:
      - EULA=false  # Usuario debe cambiar explícitamente
      - SERVER_PORT=25565
      - MAX_PLAYERS=20
    
    ports:
      - "25565:25565"
    
    volumes:
      # Usar nombres descriptivos
      - minecraft_world_data:/opt/minecraft/server/world
      - minecraft_mods_data:/opt/minecraft/server/mods
    
    # Límites de recursos
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2.0'
        reservations:
          memory: 2G
          cpus: '1.0'
    
    networks:
      - minecraft_network

volumes:
  minecraft_world_data:
    driver: local
  minecraft_mods_data:
    driver: local

networks:
  minecraft_network:
    driver: bridge
```

### Documentación

#### Markdown

1. **Estructura:**
   ```markdown
   # 🎯 Título Principal
   
   Descripción breve y clara.
   
   ## 📋 Tabla de Contenidos
   
   - [Sección 1](#-sección-1)
   - [Sección 2](#-sección-2)
   
   ## 🚀 Sección 1
   
   Contenido...
   
   ### Subsección
   
   Más contenido...
   ```

2. **Ejemplos de Código:**
   ```markdown
   # Usar bloques de código con sintaxis highlighting
   
   ```bash
   # Comentario explicativo
   ./script.sh --option value
   ```
   
   # Para comandos inline usar backticks
   Ejecuta `systemctl status minecraft-fabric` para ver el estado.
   ```

3. **Enlaces y Referencias:**
   ```markdown
   # Enlaces internos
   Ver [Documentación de API](docs/API.md) para más detalles.
   
   # Enlaces externos
   Consulta la [documentación oficial de Fabric](https://fabricmc.net/).
   
   # Imágenes
   ![Diagrama de arquitectura](docs/images/architecture.png)
   ```

## 🧪 Testing

### Pruebas Locales

Antes de enviar un PR, ejecuta:

```bash
# 1. Validar sintaxis de scripts
find . -name "*.sh" -exec shellcheck {} \;

# 2. Validar archivos Docker
hadolint Dockerfile
docker-compose config -q

# 3. Pruebas básicas de instalación
# En una VM o contenedor limpio:
./install.sh --help
./update-server.sh --help
./benchmark.sh --help

# 4. Construir imagen Docker
docker build -t test-image .
docker run --rm test-image --help
```

### Testing en CI

El proyecto usa GitHub Actions para testing automático:
- ✅ Validación de sintaxis (shellcheck, hadolint)
- ✅ Pruebas multi-arquitectura (AMD64, ARM64)
- ✅ Pruebas de instalación en múltiples OS
- ✅ Scans de seguridad
- ✅ Validación de documentación

### Escribir Tests

Para funcionalidades nuevas, considera agregar:

```bash
# tests/test_install.sh
#!/bin/bash

test_prerequisites_check() {
    # Setup
    export PATH="/fake/path:$PATH"
    
    # Test
    if ./install.sh --dry-run 2>&1 | grep -q "Java not found"; then
        echo "✅ Prerequisites check works"
        return 0
    else
        echo "❌ Prerequisites check failed"
        return 1
    fi
}

# Ejecutar test
test_prerequisites_check
```

## 📚 Documentación

### Actualizar Documentación

Al hacer cambios, actualiza:

1. **README.md**: Para cambios en funcionalidad principal
2. **docs/API.md**: Para cambios en interfaces/configuraciones
3. **docs/ARCHITECTURE.md**: Para cambios arquitectónicos
4. **Comentarios en código**: Para lógica compleja
5. **Templates**: Si cambias el proceso de issues/PRs

### Estilo de Documentación

- **Ser claro y conciso**
- **Usar ejemplos prácticos**
- **Incluir casos de error comunes**
- **Mantener actualizada con cambios de código**
- **Usar emojis consistentemente para categorización**

## 🔀 Pull Requests

### Antes de Enviar

Checklist:
- [ ] ✅ Branch actualizado con main
- [ ] ✅ Tests pasan localmente
- [ ] ✅ Documentación actualizada
- [ ] ✅ Commit messages siguiendo convenciones
- [ ] ✅ Sin archivos innecesarios (logs, temporales)
- [ ] ✅ Cambios probados en sistema limpio

### Template de PR

Completa el [template de Pull Request](../../pull_request_template.md):
- **Descripción clara** de los cambios
- **Tipo de cambio** (feature, fix, docs, etc.)
- **Testing realizado**
- **Screenshots** si es relevante
- **Issues relacionados**

### Proceso de Review

1. **Automated checks** deben pasar
2. **Maintainer review** de código y funcionalidad
3. **Testing** en diferentes entornos si es necesario
4. **Approval** y merge

### Después del Merge

- Branch será borrado automáticamente
- Changes aparecerán en próximo release
- Contributor será agregado a credits

## 🐛 Issues

### Triaging

Labels usados:
- **Tipo**: `bug`, `enhancement`, `documentation`, `question`
- **Prioridad**: `priority-high`, `priority-medium`, `priority-low`
- **Estado**: `status-needs-info`, `status-blocked`, `status-ready`
- **Área**: `area-docker`, `area-install`, `area-optimization`

### Lifecycle de Issues

1. **Nuevo issue** → Automatic labeling
2. **Triage** → Maintainer review y labeling
3. **Ready** → Disponible para contributors
4. **In Progress** → Asignado y en desarrollo
5. **Review** → PR creado y en review
6. **Closed** → Completado o resuelto

## 🏆 Reconocimiento

### Contributors

Todos los contributors son reconocidos en:
- **README.md** - Lista de contributors
- **CHANGELOG.md** - Créditos por release
- **GitHub Releases** - Mention en release notes

### Tipos de Contribución

Reconocemos todas las formas de contribución:
- 💻 **Código**
- 📖 **Documentación** 
- 🎨 **Diseño**
- 💡 **Ideas y feedback**
- 🐛 **Bug reports**
- 💬 **Community support**
- 🌍 **Traducción**
- 🧪 **Testing**

## 📞 Contacto

¿Preguntas sobre contribuir?
- 💬 [GitHub Discussions](../../discussions)
- 📧 Email: [maintainer@example.com]
- 🐛 [Issues](../../issues) para bugs y features

## 📖 Recursos Adicionales

- [Guía de Inicio Rápido](docs/QUICK_START.md)
- [Documentación de API](docs/API.md)
- [Arquitectura del Sistema](docs/ARCHITECTURE.md)
- [Fabric Documentation](https://fabricmc.net/wiki/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

¡Gracias por hacer BuildFabricModServer mejor para todos! 🎉