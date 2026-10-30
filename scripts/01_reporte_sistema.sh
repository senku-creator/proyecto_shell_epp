#!/bin/bash
set -euo pipefail

VERDE='\033[0;32m'
AZUL='\033[0;34m'
AMARILLO='\033[1;33m'
NC='\033[0m'

RUTA_REPORTES="./reportes"
FECHA=$(date +"%Y%m%d_%H%M%S")
ARCHIVO_REPORTE="${RUTA_REPORTES}/reporte_sistema_${FECHA}.txt"

crear_directorio_reportes() {
    if [[ ! -d "$RUTA_REPORTES" ]]; then
        mkdir -p "$RUTA_REPORTES"
    fi
}

obtener_cpu() {
    local cpu1=($(grep 'cpu ' /proc/stat))
    sleep 1
    local cpu2=($(grep 'cpu ' /proc/stat))
    local total1=0 total2=0 idle1=${cpu1[4]} idle2=${cpu2[4]}
    for i in "${!cpu1[@]}"; do
        if [[ $i -gt 0 ]]; then
            total1=$((total1 + ${cpu1[$i]}))
            total2=$((total2 + ${cpu2[$i]}))
        fi
    done
    local total_diff=$((total2 - total1))
    local idle_diff=$((idle2 - idle1))
    if [[ $total_diff -gt 0 ]]; then
        echo "$(( (total_diff - idle_diff) * 100 / total_diff ))%"
    else
        echo "0%"
    fi
}

obtener_memoria() {
    local mem_total=$(free -m | awk 'NR==2{print $2}')
    local mem_usada=$(free -m | awk 'NR==2{print $3}')
    echo "${mem_usada}MB / ${mem_total}MB ($((mem_usada * 100 / mem_total))%)"
}

obtener_disco() {
    df -h / | awk 'NR==2{printf "%s usado de %s (%s)", $3, $2, $5}'
}

generar_reporte() {
    clear
    echo -e "${AZUL}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${AZUL}║          REPORTE AUTOMATIZADO DEL SISTEMA                ║${NC}"
    echo -e "${AZUL}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${VERDE}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${VERDE}│ PARAMETRO              │ VALOR                             │${NC}"
    echo -e "${VERDE}├────────────────────────────────────────────────────────────┤${NC}"
    printf "${VERDE}│${NC} %-22s ${VERDE}│${NC} %-33s ${VERDE}│${NC}\n" "Usuario Actual" "$(whoami)"
    printf "${VERDE}│${NC} %-22s ${VERDE}│${NC} %-33s ${VERDE}│${NC}\n" "Fecha y Hora" "$(date '+%d/%m/%Y %H:%M:%S')"
    printf "${VERDE}│${NC} %-22s ${VERDE}│${NC} %-33s ${VERDE}│${NC}\n" "Sistema Operativo" "$(lsb_release -d | cut -f2)"
    printf "${VERDE}│${NC} %-22s ${VERDE}│${NC} %-33s ${VERDE}│${NC}\n" "Kernel" "$(uname -r)"
    printf "${VERDE}│${NC} %-22s ${VERDE}│${NC} %-33s ${VERDE}│${NC}\n" "Nombre del Host" "$(hostname)"
    printf "${VERDE}│${NC} %-22s ${VERDE}│${NC} %-33s ${VERDE}│${NC}\n" "Direccion IP" "$(hostname -I | awk '{print $1}')"
    printf "${VERDE}│${NC} %-22s ${VERDE}│${NC} %-33s ${VERDE}│${NC}\n" "Tiempo Activo" "$(uptime -p | sed 's/up //')"
    printf "${VERDE}│${NC} %-22s ${VERDE}│${NC} %-33s ${VERDE}│${NC}\n" "Uso de CPU" "$(obtener_cpu)"
    printf "${VERDE}│${NC} %-22s ${VERDE}│${NC} %-33s ${VERDE}│${NC}\n" "Uso de Memoria" "$(obtener_memoria)"
    printf "${VERDE}│${NC} %-22s ${VERDE}│${NC} %-33s ${VERDE}│${NC}\n" "Uso de Disco" "$(obtener_disco)"
    echo -e "${VERDE}└────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

guardar_reporte_txt() {
    {
        echo "============================================================"
        echo "          REPORTE AUTOMATIZADO DEL SISTEMA"
        echo "============================================================"
        echo "Fecha: $(date '+%d/%m/%Y %H:%M:%S')"
        echo "============================================================"
        echo "Usuario Actual         | $(whoami)"
        echo "Fecha y Hora           | $(date '+%d/%m/%Y %H:%M:%S')"
        echo "Sistema Operativo      | $(lsb_release -d | cut -f2)"
        echo "Kernel                 | $(uname -r)"
        echo "Nombre del Host        | $(hostname)"
        echo "Direccion IP           | $(hostname -I | awk '{print $1}')"
        echo "Tiempo Activo          | $(uptime -p | sed 's/up //')"
        echo "Uso de CPU             | $(obtener_cpu)"
        echo "Uso de Memoria         | $(obtener_memoria)"
        echo "Uso de Disco           | $(obtener_disco)"
        echo "============================================================"
    } > "$ARCHIVO_REPORTE"
    echo -e "${AMARILLO}Reporte guardado en: ${NC}${ARCHIVO_REPORTE}"
}

main() {
    crear_directorio_reportes
    generar_reporte
    guardar_reporte_txt
    echo ""
    echo -e "${VERDE}Proceso completado${NC}"
}

main
