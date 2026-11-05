#!/bin/bash
set -euo pipefail

VERDE='\033[0;32m'
AZUL='\033[0;34m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
NC='\033[0m'

RUTA_REPORTES="./reportes"
ARCHIVO_ALERTAS="${RUTA_REPORTES}/servidores_alerta.txt"
ARCHIVO_REVISION="${RUTA_REPORTES}/servidores_revisados.txt"
ARCHIVO_ANALISIS="${RUTA_REPORTES}/analisis_completo.txt"

inicializar() {
    mkdir -p "$RUTA_REPORTES"
    touch "$ARCHIVO_ALERTAS"
    touch "$ARCHIVO_REVISION"
    touch "$ARCHIVO_ANALISIS"
}

obtener_ip() {
    hostname -I | awk '{print $1}'
}

analizar_sistema() {
    clear
    echo -e "${AZUL}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${AZUL}║              ANALISIS DE SERVIDOR                        ║${NC}"
    echo -e "${AZUL}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${AMARILLO}Analizando sistema...${NC}"
    sleep 1
    
    local ip=$(obtener_ip)
    local hostname=$(hostname)
    local uso_disco=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')
    local uso_cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
    local uso_memoria=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    local fecha_analisis=$(date '+%Y-%m-%d %H:%M:%S')
    
    local estado="NORMAL"
    local criticidad="normal"
    local color_estado="${VERDE}"
    
    if [[ $uso_disco -gt 70 ]]; then
        estado="ALERTA"
        criticidad="CRITICO"
        color_estado="${ROJO}"
    elif [[ $uso_disco -gt 50 ]]; then
        estado="ADVERTENCIA"
        criticidad="medio"
        color_estado="${AMARILLO}"
    fi
    
    echo ""
    echo -e "${AZUL}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${AZUL}│ RESULTADOS DEL ANALISIS                                    │${NC}"
    echo -e "${AZUL}├────────────────────────────────────────────────────────────┤${NC}"
    printf "${AZUL}│${NC} %-20s ${AZUL}│${NC} %-36s ${AZUL}│${NC}\n" "Hostname" "$hostname"
    printf "${AZUL}│${NC} %-20s ${AZUL}│${NC} %-36s ${AZUL}│${NC}\n" "Direccion IP" "$ip"
    printf "${AZUL}│${NC} %-20s ${AZUL}│${NC} %-36s ${AZUL}│${NC}\n" "Fecha Analisis" "$fecha_analisis"
    printf "${AZUL}│${NC} %-20s ${AZUL}│${NC} %-36s ${AZUL}│${NC}\n" "Uso de Disco" "${uso_disco}%"
    printf "${AZUL}│${NC} %-20s ${AZUL}│${NC} %-36s ${AZUL}│${NC}\n" "Uso de CPU" "${uso_cpu}%"
    printf "${AZUL}│${NC} %-20s ${AZUL}│${NC} %-36s ${AZUL}│${NC}\n" "Uso de Memoria" "${uso_memoria}%"
    printf "${AZUL}│${NC} %-20s ${AZUL}│${NC} ${color_estado}%-36s${NC} ${AZUL}│${NC}\n" "Estado" "$estado"
    printf "${AZUL}│${NC} %-20s ${AZUL}│${NC} ${color_estado}%-36s${NC} ${AZUL}│${NC}\n" "Criticidad" "$criticidad"
    echo -e "${AZUL}└────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    echo "${fecha_analisis}|${hostname}|${ip}|${uso_disco}%|${uso_cpu}%|${uso_memoria}%|${estado}|${criticidad}" >> "$ARCHIVO_ANALISIS"
    
    if [[ "$estado" == "ALERTA" ]]; then
        echo "${fecha_analisis}|${hostname}|${ip}|${uso_disco}%|${uso_cpu}%|${uso_memoria}%|${estado}|${criticidad}" >> "$ARCHIVO_ALERTAS"
        echo -e "${ROJO}SERVIDOR EN ESTADO DE ALERTA - Uso de disco mayor al 70%${NC}"
    fi
    
    echo "${fecha_analisis}|${hostname}|${ip}|REVISADO" >> "$ARCHIVO_REVISION"
    echo -e "${VERDE}Analisis completado y registrado${NC}"
    read -p "Presione Enter para continuar..."
}

mostrar_alertas() {
    clear
    echo -e "${ROJO}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${ROJO}║           SERVIDORES EN ESTADO DE ALERTA                 ║${NC}"
    echo -e "${ROJO}║              (Uso de Disco mayor al 70%)                 ║${NC}"
    echo -e "${ROJO}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    if [[ ! -s "$ARCHIVO_ALERTAS" ]]; then
        echo -e "${VERDE}No hay servidores en estado de alerta${NC}"
    else
        echo "FECHA                | HOSTNAME          | IP              | DISCO | CPU   | MEM   | ESTADO"
        echo "---------------------|-------------------|-----------------|-------|-------|-------|--------"
        while IFS='|' read -r fecha hostname ip disco cpu memoria estado criticidad; do
            printf "%-21s| %-18s| %-16s| %-6s| %-6s| %-6s| %s\n" "$fecha" "$hostname" "$ip" "$disco" "$cpu" "$memoria" "$estado"
        done < "$ARCHIVO_ALERTAS"
    fi
    echo ""
    read -p "Presione Enter para continuar..."
}

mostrar_revisiones() {
    clear
    echo -e "${VERDE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${VERDE}║           HISTORIAL DE REVISIONES                        ║${NC}"
    echo -e "${VERDE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    if [[ ! -s "$ARCHIVO_REVISION" ]]; then
        echo "No hay revisiones registradas"
    else
        echo "FECHA Y HORA          | HOSTNAME          | IP              | ESTADO"
        echo "---------------------|-------------------|-----------------|--------"
        tail -20 "$ARCHIVO_REVISION" | while IFS='|' read -r fecha hostname ip estado; do
            printf "%-21s| %-18s| %-16s| %s\n" "$fecha" "$hostname" "$ip" "$estado"
        done
    fi
    echo ""
    read -p "Presione Enter para continuar..."
}

mostrar_menu() {
    clear
    echo -e "${AZUL}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${AZUL}║        ANALISIS Y MONITOREO DE SERVIDORES                ║${NC}"
    echo -e "${AZUL}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "┌─────────────────────────────────────────┐"
    echo "│ 1) Analizar servidor actual             │"
    echo "│ 2) Ver servidores en alerta (>70%)      │"
    echo "│ 3) Ver historial de revisiones          │"
    echo "│ 4) Salir                                │"
    echo "└─────────────────────────────────────────┘"
    echo ""
    echo -n "Seleccione una opcion (1-4): "
}

main() {
    inicializar
    while true; do
        mostrar_menu
        read -r opcion
        case $opcion in
            1) analizar_sistema ;;
            2) mostrar_alertas ;;
            3) mostrar_revisiones ;;
            4) 
                echo ""
                echo -e "${VERDE}Saliendo del sistema de analisis...${NC}"
                sleep 1
                exit 0 
                ;;
            *) 
                echo -e "${ROJO}Opcion invalida${NC}"
                sleep 1
                ;;
        esac
    done
}

main
