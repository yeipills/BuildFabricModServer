#!/bin/bash

# Antes de ejecutar este script, asegúrate de tener los permisos de superusuario necesarios (sudo).

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update -y && sudo apt upgrade -y

# Instalar y configurar sysstat para monitorear el rendimiento del sistema
echo "Instalando y configurando sysstat..."
sudo apt install -y sysstat
sudo sed -i 's/false/true/g' /etc/default/sysstat

# Habilitar el uso de cache de la memoria RAM para acelerar la lectura de disco
echo "Habilitando cache de RAM..."
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf

# Configurar el kernel para gestionar mejor la carga de red pesada
echo "Optimizando la gestión de la red..."
echo "net.core.rmem_max=12582912" | sudo tee -a /etc/sysctl.conf
echo "net.core.wmem_max=12582912" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_rmem=4096 87380 12582912" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_wmem=4096 87380 12582912" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=cubic" | sudo tee -a /etc/sysctl.conf

# Reducir el uso de SWAP para mejorar el rendimiento general
echo "Reduciendo el uso de SWAP..."
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf

# Reiniciar sysctl para aplicar las nuevas configuraciones
echo "Aplicando nuevas configuraciones..."
sudo sysctl -p

echo "¡Optimización completada!"
