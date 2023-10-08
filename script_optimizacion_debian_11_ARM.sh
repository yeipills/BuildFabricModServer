#!/bin/bash

# Antes de ejecutar este script, asegúrate de tener los permisos de superusuario necesarios (sudo).

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update -y && sudo apt upgrade -y

# Instalar y configurar sysstat para monitorear el rendimiento del sistema
echo "Instalando y configurando sysstat..."
sudo apt install -y sysstat
if [ -f /etc/default/sysstat ]; then
    sudo sed -i 's/ENABLED="false"/ENABLED="true"/g' /etc/default/sysstat
else
    echo "El archivo de configuración de sysstat no existe. Por favor, verifica la instalación."
fi

# Habilitar el uso de cache de la memoria RAM para acelerar la lectura de disco
echo "Habilitando cache de RAM..."
if ! grep -q "vm.vfs_cache_pressure=50" /etc/sysctl.conf; then
    echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf
fi

# Configurar el kernel para gestionar mejor la carga de red pesada
echo "Optimizando la gestión de la red..."
NET_CONFIGS=("net.core.rmem_max=12582912" "net.core.wmem_max=12582912" "net.ipv4.tcp_rmem=4096 87380 12582912" "net.ipv4.tcp_wmem=4096 87380 12582912" "net.ipv4.tcp_congestion_control=cubic")
for config in "${NET_CONFIGS[@]}"; do
    if ! grep -q "$config" /etc/sysctl.conf; then
        echo "$config" | sudo tee -a /etc/sysctl.conf
    fi
done

# Reducir el uso de SWAP para mejorar el rendimiento general
echo "Reduciendo el uso de SWAP..."
if ! grep -q "vm.swappiness=10" /etc/sysctl.conf; then
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
fi

# Aplicar optimizaciones específicas para ARM si es aplicable
if uname -m | grep -q "arm"; then
    echo "Aplicando optimizaciones específicas para ARM..."
    # Aquí puedes agregar cualquier configuración o instalación de paquete específica para ARM
    # Por ejemplo, instalar bibliotecas optimizadas, ajustar parámetros del kernel, etc.
fi

# Reiniciar sysctl para aplicar las nuevas configuraciones
echo "Aplicando nuevas configuraciones..."
sudo sysctl -p

echo "¡Optimización completada!"
