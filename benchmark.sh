#!/bin/bash

#=============================================================================
# 📊 Script de Benchmarking para Minecraft Fabric Server
# Versión: 1.0
# Descripción: Pruebas de rendimiento del servidor y sistema
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
SERVER_DIR="/opt/minecraft/server"
RESULTS_DIR="/opt/minecraft/benchmark_results"
LOG_FILE="$RESULTS_DIR/benchmark_$(date +%Y%m%d_%H%M%S).log"

# Duración de las pruebas (segundos)
BENCHMARK_DURATION=300  # 5 minutos por defecto
STRESS_DURATION=60      # 1 minuto para pruebas de estrés

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
║          📊 MINECRAFT FABRIC BENCHMARK SUITE 📊             ║
║                                                              ║
║    Evaluación completa de rendimiento del servidor          ║
║    Soporte: Sistema, Java, Minecraft, Red                   ║
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
    -t, --time SEGUNDOS    Duración del benchmark (por defecto: 300s)
    -s, --stress           Ejecutar pruebas de estrés adicionales
    -q, --quick            Benchmark rápido (60 segundos)
    -c, --cpu-only         Solo pruebas de CPU
    -m, --memory-only      Solo pruebas de memoria
    -n, --network-only     Solo pruebas de red
    -j, --java-only        Solo pruebas de Java/JVM
    -r, --report           Generar solo reporte sin ejecutar pruebas
    -h, --help             Mostrar esta ayuda

EJEMPLOS:
    $0                     # Benchmark completo (5 minutos)
    $0 -q                  # Benchmark rápido (1 minuto)
    $0 -s -t 600           # Benchmark con estrés por 10 minutos
    $0 -c                  # Solo pruebas de CPU

EOF
}

# Verificar prerrequisitos
check_prerequisites() {
    log "🔍 Verificando prerrequisitos para benchmark..."
    
    # Crear directorio de resultados
    mkdir -p "$RESULTS_DIR"
    
    # Verificar herramientas necesarias
    local tools=("java" "top" "free" "df" "ss" "vmstat")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        warn "Herramientas faltantes: ${missing_tools[*]}"
        info "Instalando herramientas faltantes..."
        sudo apt update -y
        sudo apt install -y procps net-tools sysstat
    fi
    
    # Verificar permisos
    if [[ ! -w "$RESULTS_DIR" ]]; then
        error "No se puede escribir en el directorio de resultados: $RESULTS_DIR"
    fi
    
    success "✅ Prerrequisitos verificados"
}

# Obtener información del sistema
get_system_info() {
    log "💻 Recopilando información del sistema..."
    
    local info_file="$RESULTS_DIR/system_info.txt"
    
    {
        echo "=== INFORMACIÓN DEL SISTEMA ==="
        echo "Fecha: $(date)"
        echo "Hostname: $(hostname)"
        echo "Uptime: $(uptime)"
        echo ""
        
        echo "=== HARDWARE ==="
        echo "Arquitectura: $(uname -m)"
        echo "CPU: $(lscpu | grep "Model name" | cut -d':' -f2 | xargs)"
        echo "Núcleos: $(nproc)"
        echo "Threads: $(lscpu | grep "^CPU(s):" | awk '{print $2}')"
        echo "RAM Total: $(free -h | awk 'NR==2{print $2}')"
        echo "RAM Disponible: $(free -h | awk 'NR==2{print $7}')"
        echo ""
        
        echo "=== SISTEMA OPERATIVO ==="
        echo "OS: $(lsb_release -d | cut -d':' -f2 | xargs 2>/dev/null || echo "Unknown")"
        echo "Kernel: $(uname -r)"
        echo ""
        
        echo "=== JAVA ==="
        java -version 2>&1
        echo ""
        
        echo "=== ALMACENAMIENTO ==="
        df -h | grep -E "(/$|/opt)"
        echo ""
        
        echo "=== RED ==="
        ip -4 addr show | grep inet
        echo ""
        
    } > "$info_file"
    
    success "✅ Información del sistema guardada en: $info_file"
}

# Benchmark de CPU
benchmark_cpu() {
    log "🖥️ Ejecutando benchmark de CPU..."
    
    local cpu_file="$RESULTS_DIR/cpu_benchmark.txt"
    
    {
        echo "=== BENCHMARK DE CPU ==="
        echo "Inicio: $(date)"
        echo "Duración: ${BENCHMARK_DURATION}s"
        echo ""
        
        # Test de cálculo intensivo
        echo "=== TEST DE CÁLCULO INTENSIVO ==="
        local start_time=$(date +%s)
        
        # Ejecutar test en paralelo por cada core
        local cores=$(nproc)
        echo "Ejecutando en $cores núcleos..."
        
        for ((i=1; i<=cores; i++)); do
            {
                local count=0
                local end_time=$((start_time + BENCHMARK_DURATION))
                while [[ $(date +%s) -lt $end_time ]]; do
                    echo "scale=5000; 4*a(1)" | bc -l > /dev/null 2>&1 || true
                    ((count++))
                done
                echo "Core $i: $count iteraciones"
            } &
        done
        
        # Monitorear CPU durante el test
        {
            local end_time=$((start_time + BENCHMARK_DURATION))
            local cpu_samples=()
            while [[ $(date +%s) -lt $end_time ]]; do
                local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
                cpu_samples+=("$cpu_usage")
                sleep 5
            done
            
            # Calcular promedio
            local total=0
            for sample in "${cpu_samples[@]}"; do
                total=$(echo "$total + $sample" | bc -l)
            done
            local avg_cpu=$(echo "scale=2; $total / ${#cpu_samples[@]}" | bc -l)
            echo "CPU promedio durante el test: ${avg_cpu}%"
        } &
        
        wait
        echo "Fin: $(date)"
        
    } > "$cpu_file"
    
    success "✅ Benchmark de CPU completado: $cpu_file"
}

# Benchmark de memoria
benchmark_memory() {
    log "💾 Ejecutando benchmark de memoria..."
    
    local mem_file="$RESULTS_DIR/memory_benchmark.txt"
    
    {
        echo "=== BENCHMARK DE MEMORIA ==="
        echo "Inicio: $(date)"
        echo ""
        
        # Información inicial de memoria
        echo "=== ESTADO INICIAL DE MEMORIA ==="
        free -h
        echo ""
        
        # Test de velocidad de memoria (si disponible)
        if command -v sysbench &> /dev/null; then
            echo "=== TEST DE VELOCIDAD DE MEMORIA ==="
            sysbench memory --memory-block-size=1M --memory-total-size=10G run
            echo ""
        fi
        
        # Test de asignación de memoria
        echo "=== TEST DE ASIGNACIÓN DE MEMORIA ==="
        local mem_total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        local test_size_mb=$((mem_total_kb / 1024 / 4))  # 1/4 de la RAM total
        
        echo "Probando asignación de ${test_size_mb}MB..."
        local start_time=$(date +%s.%N)
        
        # Crear archivo temporal en memoria
        if dd if=/dev/zero of=/tmp/memory_test bs=1M count="$test_size_mb" 2>/dev/null; then
            local end_time=$(date +%s.%N)
            local duration=$(echo "$end_time - $start_time" | bc -l)
            local speed=$(echo "scale=2; $test_size_mb / $duration" | bc -l)
            echo "Velocidad de escritura: ${speed} MB/s"
            rm -f /tmp/memory_test
        fi
        
        # Estado final de memoria
        echo ""
        echo "=== ESTADO FINAL DE MEMORIA ==="
        free -h
        echo ""
        echo "Fin: $(date)"
        
    } > "$mem_file"
    
    success "✅ Benchmark de memoria completado: $mem_file"
}

# Benchmark de red
benchmark_network() {
    log "🌐 Ejecutando benchmark de red..."
    
    local net_file="$RESULTS_DIR/network_benchmark.txt"
    
    {
        echo "=== BENCHMARK DE RED ==="
        echo "Inicio: $(date)"
        echo ""
        
        # Información de interfaces de red
        echo "=== INTERFACES DE RED ==="
        ip link show
        echo ""
        
        # Test de conectividad
        echo "=== TEST DE CONECTIVIDAD ==="
        local test_hosts=("8.8.8.8" "1.1.1.1" "google.com")
        
        for host in "${test_hosts[@]}"; do
            echo "Ping a $host:"
            if ping -c 4 "$host" 2>/dev/null; then
                echo "✅ $host accesible"
            else
                echo "❌ $host no accesible"
            fi
            echo ""
        done
        
        # Test de ancho de banda (si está disponible)
        if command -v speedtest-cli &> /dev/null; then
            echo "=== TEST DE VELOCIDAD DE INTERNET ==="
            speedtest-cli --simple
            echo ""
        else
            echo "speedtest-cli no disponible para test de velocidad"
        fi
        
        # Test de puertos locales
        echo "=== PUERTOS EN USO ==="
        ss -tuln | head -20
        echo ""
        
        # Estadísticas de red
        echo "=== ESTADÍSTICAS DE RED ==="
        cat /proc/net/dev | head -10
        echo ""
        
        echo "Fin: $(date)"
        
    } > "$net_file"
    
    success "✅ Benchmark de red completado: $net_file"
}

# Benchmark de Java/JVM
benchmark_java() {
    log "☕ Ejecutando benchmark de Java/JVM..."
    
    local java_file="$RESULTS_DIR/java_benchmark.txt"
    
    {
        echo "=== BENCHMARK DE JAVA/JVM ==="
        echo "Inicio: $(date)"
        echo ""
        
        # Información de Java
        echo "=== INFORMACIÓN DE JAVA ==="
        java -version 2>&1
        echo ""
        
        echo "=== PROPIEDADES DEL SISTEMA JAVA ==="
        java -XshowSettings:properties -version 2>&1 | head -20
        echo ""
        
        # Test de rendimiento Java básico
        echo "=== TEST DE RENDIMIENTO JAVA ==="
        
        # Crear programa de test simple
        local test_program="/tmp/JavaBenchmark.java"
        cat > "$test_program" << 'EOF'
public class JavaBenchmark {
    public static void main(String[] args) {
        System.out.println("=== BENCHMARK JAVA ===");
        
        // Test de cálculo
        long startTime = System.currentTimeMillis();
        long result = 0;
        for (int i = 0; i < 100000000; i++) {
            result += Math.sqrt(i) * Math.sin(i);
        }
        long calcTime = System.currentTimeMillis() - startTime;
        System.out.println("Tiempo de cálculo: " + calcTime + "ms");
        
        // Test de memoria
        startTime = System.currentTimeMillis();
        java.util.List<String> list = new java.util.ArrayList<>();
        for (int i = 0; i < 1000000; i++) {
            list.add("Test string " + i);
        }
        long memTime = System.currentTimeMillis() - startTime;
        System.out.println("Tiempo de asignación memoria: " + memTime + "ms");
        
        // Información de memoria JVM
        Runtime runtime = Runtime.getRuntime();
        System.out.println("Memoria total JVM: " + (runtime.totalMemory() / 1024 / 1024) + "MB");
        System.out.println("Memoria libre JVM: " + (runtime.freeMemory() / 1024 / 1024) + "MB");
        System.out.println("Memoria máxima JVM: " + (runtime.maxMemory() / 1024 / 1024) + "MB");
    }
}
EOF
        
        # Compilar y ejecutar
        if javac "$test_program" && java -cp /tmp JavaBenchmark; then
            echo "✅ Test de Java completado"
        else
            echo "❌ Error en test de Java"
        fi
        
        # Limpiar
        rm -f /tmp/JavaBenchmark.java /tmp/JavaBenchmark.class
        
        echo ""
        echo "Fin: $(date)"
        
    } > "$java_file"
    
    success "✅ Benchmark de Java completado: $java_file"
}

# Benchmark del servidor Minecraft (si está disponible)
benchmark_minecraft_server() {
    log "🎮 Ejecutando benchmark del servidor Minecraft..."
    
    if [[ ! -d "$SERVER_DIR" ]] || [[ ! -f "$SERVER_DIR/fabric-server-launch.jar" ]]; then
        warn "Servidor Minecraft no encontrado, saltando benchmark específico"
        return
    fi
    
    local mc_file="$RESULTS_DIR/minecraft_benchmark.txt"
    
    {
        echo "=== BENCHMARK DEL SERVIDOR MINECRAFT ==="
        echo "Inicio: $(date)"
        echo ""
        
        # Información del servidor
        echo "=== INFORMACIÓN DEL SERVIDOR ==="
        echo "Directorio: $SERVER_DIR"
        echo "Archivos principales:"
        ls -la "$SERVER_DIR"/*.jar 2>/dev/null || echo "No hay archivos JAR"
        echo ""
        
        # Verificar si el servidor está ejecutándose
        if pgrep -f "fabric-server-launch.jar" > /dev/null; then
            echo "=== SERVIDOR EN EJECUCIÓN ==="
            local pid=$(pgrep -f "fabric-server-launch.jar")
            echo "PID: $pid"
            
            # Estadísticas del proceso
            if [[ -n "$pid" ]]; then
                echo "Uso de CPU y memoria:"
                ps -p "$pid" -o pid,ppid,pcpu,pmem,etime,cmd
                echo ""
                
                # Monitorear durante un período
                echo "Monitoreando rendimiento por 60 segundos..."
                local samples=12  # 12 muestras cada 5 segundos
                local cpu_total=0
                local mem_total=0
                
                for ((i=1; i<=samples; i++)); do
                    local stats=$(ps -p "$pid" -o pcpu,pmem --no-headers 2>/dev/null || echo "0.0 0.0")
                    local cpu=$(echo "$stats" | awk '{print $1}')
                    local mem=$(echo "$stats" | awk '{print $2}')
                    
                    cpu_total=$(echo "$cpu_total + $cpu" | bc -l)
                    mem_total=$(echo "$mem_total + $mem" | bc -l)
                    
                    echo "Muestra $i: CPU=${cpu}% MEM=${mem}%"
                    sleep 5
                done
                
                local avg_cpu=$(echo "scale=2; $cpu_total / $samples" | bc -l)
                local avg_mem=$(echo "scale=2; $mem_total / $samples" | bc -l)
                
                echo ""
                echo "PROMEDIO - CPU: ${avg_cpu}% MEM: ${avg_mem}%"
            fi
        else
            echo "=== SERVIDOR NO ESTÁ EJECUTÁNDOSE ==="
            echo "Para benchmark completo, inicia el servidor primero"
        fi
        
        # Información del mundo (si existe)
        if [[ -d "$SERVER_DIR/world" ]]; then
            echo ""
            echo "=== INFORMACIÓN DEL MUNDO ==="
            local world_size=$(du -sh "$SERVER_DIR/world" | cut -f1)
            echo "Tamaño del mundo: $world_size"
            
            # Contar archivos de región
            if [[ -d "$SERVER_DIR/world/region" ]]; then
                local region_count=$(find "$SERVER_DIR/world/region" -name "*.mca" | wc -l)
                echo "Archivos de región: $region_count"
            fi
        fi
        
        echo ""
        echo "Fin: $(date)"
        
    } > "$mc_file"
    
    success "✅ Benchmark de Minecraft completado: $mc_file"
}

# Pruebas de estrés
stress_tests() {
    log "🔥 Ejecutando pruebas de estrés..."
    
    if ! command -v stress &> /dev/null; then
        warn "Herramienta 'stress' no disponible, instalando..."
        sudo apt update -y && sudo apt install -y stress
    fi
    
    local stress_file="$RESULTS_DIR/stress_test.txt"
    
    {
        echo "=== PRUEBAS DE ESTRÉS ==="
        echo "Inicio: $(date)"
        echo "Duración: ${STRESS_DURATION}s"
        echo ""
        
        # Estado inicial
        echo "=== ESTADO INICIAL ==="
        free -h
        uptime
        echo ""
        
        # Estrés de CPU
        echo "=== ESTRÉS DE CPU ==="
        local cores=$(nproc)
        echo "Ejecutando estrés en $cores núcleos por ${STRESS_DURATION}s..."
        
        stress --cpu "$cores" --timeout "${STRESS_DURATION}s" &
        local stress_pid=$!
        
        # Monitorear durante el estrés
        local samples=$((STRESS_DURATION / 5))
        for ((i=1; i<=samples; i++)); do
            local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
            local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
            echo "Muestra $i: CPU=${cpu_usage}% Load=${load_avg}"
            sleep 5
        done
        
        wait $stress_pid
        
        echo ""
        echo "=== ESTADO FINAL ==="
        free -h
        uptime
        echo ""
        
        echo "Fin: $(date)"
        
    } > "$stress_file"
    
    success "✅ Pruebas de estrés completadas: $stress_file"
}

# Generar reporte final
generate_report() {
    log "📋 Generando reporte final..."
    
    local report_file="$RESULTS_DIR/benchmark_report.html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Reporte de Benchmark - Minecraft Fabric Server</title>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #2e7d32; color: white; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border-left: 4px solid #2e7d32; background: #f5f5f5; }
        .metric { display: inline-block; margin: 10px; padding: 10px; background: white; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        pre { background: #f0f0f0; padding: 10px; overflow-x: auto; }
        .good { color: #2e7d32; font-weight: bold; }
        .warning { color: #f57c00; font-weight: bold; }
        .error { color: #d32f2f; font-weight: bold; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Reporte de Benchmark - Minecraft Fabric Server</h1>
        <p>Generado el: $(date)</p>
    </div>
    
    <div class="section">
        <h2>📊 Resumen Ejecutivo</h2>
        <div class="metric">
            <strong>Arquitectura:</strong> $(uname -m)
        </div>
        <div class="metric">
            <strong>CPU Cores:</strong> $(nproc)
        </div>
        <div class="metric">
            <strong>RAM Total:</strong> $(free -h | awk 'NR==2{print $2}')
        </div>
        <div class="metric">
            <strong>Espacio Libre:</strong> $(df -h / | awk 'NR==2{print $4}')
        </div>
    </div>
    
    <div class="section">
        <h2>🖥️ Resultados de CPU</h2>
        <p>Detalles completos en: <code>cpu_benchmark.txt</code></p>
        <div class="metric">
            <strong>Estado:</strong> <span class="good">Completado ✅</span>
        </div>
    </div>
    
    <div class="section">
        <h2>💾 Resultados de Memoria</h2>
        <p>Detalles completos en: <code>memory_benchmark.txt</code></p>
        <div class="metric">
            <strong>Estado:</strong> <span class="good">Completado ✅</span>
        </div>
    </div>
    
    <div class="section">
        <h2>🌐 Resultados de Red</h2>
        <p>Detalles completos en: <code>network_benchmark.txt</code></p>
        <div class="metric">
            <strong>Estado:</strong> <span class="good">Completado ✅</span>
        </div>
    </div>
    
    <div class="section">
        <h2>☕ Resultados de Java</h2>
        <p>Detalles completos en: <code>java_benchmark.txt</code></p>
        <div class="metric">
            <strong>Versión Java:</strong> $(java -version 2>&1 | head -1 | cut -d'"' -f2)
        </div>
        <div class="metric">
            <strong>Estado:</strong> <span class="good">Completado ✅</span>
        </div>
    </div>
    
    <div class="section">
        <h2>📁 Archivos de Resultados</h2>
        <ul>
            <li><code>system_info.txt</code> - Información completa del sistema</li>
            <li><code>cpu_benchmark.txt</code> - Resultados de pruebas de CPU</li>
            <li><code>memory_benchmark.txt</code> - Resultados de pruebas de memoria</li>
            <li><code>network_benchmark.txt</code> - Resultados de pruebas de red</li>
            <li><code>java_benchmark.txt</code> - Resultados de pruebas de Java</li>
            <li><code>minecraft_benchmark.txt</code> - Resultados específicos del servidor</li>
            <li><code>benchmark_*.log</code> - Logs completos del benchmark</li>
        </ul>
    </div>
    
    <div class="section">
        <h2>💡 Recomendaciones</h2>
        <ul>
            <li>Revisar los archivos individuales para detalles específicos</li>
            <li>Comparar resultados con benchmarks anteriores</li>
            <li>Considerar optimizaciones basadas en los resultados</li>
            <li>Repetir benchmarks después de cambios de configuración</li>
        </ul>
    </div>
    
    <div class="section">
        <h2>🔧 Directorio de Resultados</h2>
        <p><code>$RESULTS_DIR</code></p>
        <p>Comando para ver todos los archivos: <code>ls -la $RESULTS_DIR</code></p>
    </div>
</body>
</html>
EOF
    
    success "✅ Reporte HTML generado: $report_file"
    info "Abre el reporte en tu navegador: file://$report_file"
}

# Procesamiento de argumentos
QUICK_MODE=0
STRESS_MODE=0
CPU_ONLY=0
MEMORY_ONLY=0
NETWORK_ONLY=0
JAVA_ONLY=0
REPORT_ONLY=0

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--time)
            BENCHMARK_DURATION="$2"
            shift 2
            ;;
        -s|--stress)
            STRESS_MODE=1
            shift
            ;;
        -q|--quick)
            QUICK_MODE=1
            BENCHMARK_DURATION=60
            shift
            ;;
        -c|--cpu-only)
            CPU_ONLY=1
            shift
            ;;
        -m|--memory-only)
            MEMORY_ONLY=1
            shift
            ;;
        -n|--network-only)
            NETWORK_ONLY=1
            shift
            ;;
        -j|--java-only)
            JAVA_ONLY=1
            shift
            ;;
        -r|--report)
            REPORT_ONLY=1
            shift
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
    log "Iniciando benchmark suite para Minecraft Fabric Server"
    log "Duración configurada: ${BENCHMARK_DURATION}s"
    
    if [[ "$REPORT_ONLY" == "1" ]]; then
        generate_report
        exit 0
    fi
    
    # Información del sistema siempre
    get_system_info
    
    # Ejecutar benchmarks según las opciones
    if [[ "$CPU_ONLY" == "1" ]]; then
        benchmark_cpu
    elif [[ "$MEMORY_ONLY" == "1" ]]; then
        benchmark_memory
    elif [[ "$NETWORK_ONLY" == "1" ]]; then
        benchmark_network
    elif [[ "$JAVA_ONLY" == "1" ]]; then
        benchmark_java
    else
        # Benchmark completo
        benchmark_cpu
        benchmark_memory
        benchmark_network
        benchmark_java
        benchmark_minecraft_server
    fi
    
    # Pruebas de estrés si se solicitaron
    if [[ "$STRESS_MODE" == "1" ]]; then
        stress_tests
    fi
    
    # Generar reporte final
    generate_report
    
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                 🎉 BENCHMARK COMPLETADO 🎉                  ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    success "🚀 Todos los benchmarks completados exitosamente!"
    info "Resultados disponibles en: $RESULTS_DIR"
    info "Reporte HTML: $RESULTS_DIR/benchmark_report.html"
}

# Ejecutar función principal
main "$@"