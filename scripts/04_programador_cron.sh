#!/bin/bash
set -euo pipefail

VERDE='\033[0;32m'
AZUL='\033[0;34m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
NC='\033[0m'

mostrar_tareas_actuales() {
    clear
    echo -e "${AZUL}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${AZUL}║           TAREAS PROGRAMADAS ACTUALMENTE                 ║${NC}"
    echo -e "${AZUL}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    local tareas=$(crontab -l 2>/dev/null)
    if [[ -z "$tareas" ]]; then
        echo -e "${AMARILLO}No hay tareas programadas actualmente${NC}"
    else
        echo "Nº | EXPRESION CRON        | COMANDO"
        echo "---|-----------------------|----------------------------------------"
        local contador=1
        echo "$tareas" | while IFS= read -r linea; do
            local cron_expr=$(echo "$linea" | awk '{print $1, $2, $3, $4, $5}')
            local comando=$(echo "$linea" | awk '{for(i=6;i<=NF;i++) printf "%s ", $i; print ""}')
            printf "%2d | %-21s | %s\n" "$contador" "$cron_expr" "$comando"
            ((contador++))
        done
    fi
    echo ""
    read -p "Presione Enter para continuar..."
}

agregar_tarea() {
    clear
    echo -e "${AZUL}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${AZUL}║              AGREGAR NUEVA TAREA                         ║${NC}"
    echo -e "${AZUL}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${AMARILLO}Paso 1: Comando a ejecutar${NC}"
    echo "Ingrese el comando o ruta del script que desea ejecutar:"
    echo ""
    echo -n "Comando: "
    read -r comando
    if [[ -z "$comando" ]]; then
        echo -e "${ROJO}Error: El comando no puede estar vacio${NC}"
        read -p "Presione Enter para continuar..."
        return
    fi
    echo ""
    echo -e "${AMARILLO}Paso 2: Frecuencia de ejecucion${NC}"
    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ 1) Cada minuto                                             │"
    echo "│ 2) Cada hora                                               │"
    echo "│ 3) Diariamente (todos los dias)                            │"
    echo "│ 4) Semanalmente (un dia especifico de la semana)           │"
    echo "│ 5) Mensualmente (un dia especifico del mes)                │"
    echo "│ 6) Personalizado                                           │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""
    echo -n "Opcion (1-6): "
    read -r frecuencia
    local cron_expr=""
    local descripcion=""
    case $frecuencia in
        1) cron_expr="* * * * *"; descripcion="Cada minuto" ;;
        2) cron_expr="0 * * * *"; descripcion="Cada hora (en punto)" ;;
        3)
            echo -n "¿A que hora? (0-23): "
            read -r hora
            cron_expr="0 $hora * * *"
            descripcion="Diariamente a las ${hora}:00"
            ;;
        4)
            echo "Dias de la semana:"
            echo "0 = Domingo, 1 = Lunes, 2 = Martes, 3 = Miercoles"
            echo "4 = Jueves, 5 = Viernes, 6 = Sabado"
            echo ""
            echo -n "¿Que dia? (0-6): "
            read -r dia
            echo -n "¿A que hora? (0-23): "
            read -r hora
            cron_expr="0 $hora * * $dia"
            descripcion="Semanalmente el dia $dia a las ${hora}:00"
            ;;
        5)
            echo -n "¿Que dia del mes? (1-31): "
            read -r dia_mes
            echo -n "¿A que hora? (0-23): "
            read -r hora
            cron_expr="0 $hora $dia_mes * *"
            descripcion="Mensualmente el dia $dia_mes a las ${hora}:00"
            ;;
        6)
            echo "Formato cron: minuto hora dia_mes mes dia_semana"
            echo "Ejemplo: '30 2 * * *' = Todos los dias a las 2:30 AM"
            echo ""
            echo -n "Ingrese la expresion cron completa: "
            read -r cron_expr
            descripcion="Personalizado: $cron_expr"
            ;;
        *)
            echo -e "${ROJO}Opcion invalida${NC}"
            read -p "Presione Enter para continuar..."
            return
            ;;
    esac
    echo ""
    echo -e "${VERDE}=== RESUMEN DE LA TAREA ===${NC}"
    echo "Comando a ejecutar: $comando"
    echo "Frecuencia: $descripcion"
    echo "Expresion cron: $cron_expr"
    echo ""
    echo -n "¿Desea agregar esta tarea? (s/n): "
    read -r confirmar
    if [[ "$confirmar" == "s" || "$confirmar" == "S" ]]; then
        (crontab -l 2>/dev/null; echo "$cron_expr $comando") | crontab -
        echo ""
        echo -e "${VERDE}Tarea agregada exitosamente${NC}"
        echo -e "${VERDE}La tarea se ejecutara: $descripcion${NC}"
    else
        echo ""
        echo -e "${AMARILLO}Operacion cancelada${NC}"
    fi
    read -p "Presione Enter para continuar..."
}

eliminar_tarea() {
    clear
    echo -e "${AZUL}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${AZUL}║                   ELIMINAR TAREA                         ║${NC}"
    echo -e "${AZUL}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    crontab -l > /tmp/crontab_actual 2>/dev/null || touch /tmp/crontab_actual
    if [[ ! -s /tmp/crontab_actual ]]; then
        echo -e "${AMARILLO}No hay tareas para eliminar${NC}"
        read -p "Presione Enter para continuar..."
        return
    fi
    echo "Tareas programadas actualmente:"
    echo ""
    echo "Nº | EXPRESION CRON        | COMANDO"
    echo "---|-----------------------|----------------------------------------"
    local contador=1
    while IFS= read -r linea; do
        local cron_expr=$(echo "$linea" | awk '{print $1, $2, $3, $4, $5}')
        local comando=$(echo "$linea" | awk '{for(i=6;i<=NF;i++) printf "%s ", $i; print ""}')
        printf "%2d | %-21s | %s\n" "$contador" "$cron_expr" "$comando"
        ((contador++))
    done < /tmp/crontab_actual
    echo ""
    echo -n "Ingrese el numero de la tarea a eliminar (0 para cancelar): "
    read -r numero
    if [[ "$numero" -eq 0 ]]; then
        echo -e "${AMARILLO}Operacion cancelada${NC}"
        rm /tmp/crontab_actual
        read -p "Presione Enter para continuar..."
        return
    fi
    if ! [[ "$numero" =~ ^[0-9]+$ ]] || [[ "$numero" -lt 1 ]] || [[ "$numero" -ge "$contador" ]]; then
        echo -e "${ROJO}Error: Numero invalido${NC}"
        rm /tmp/crontab_actual
        read -p "Presione Enter para continuar..."
        return
    fi
    echo ""
    echo -n "¿Esta seguro de eliminar esta tarea? (s/n): "
    read -r confirmar
    if [[ "$confirmar" == "s" || "$confirmar" == "S" ]]; then
        sed -i "${numero}d" /tmp/crontab_actual
        crontab /tmp/crontab_actual
        rm /tmp/crontab_actual
        echo ""
        echo -e "${VERDE}Tarea eliminada exitosamente${NC}"
    else
        echo -e "${AMARILLO}Operacion cancelada${NC}"
        rm /tmp/crontab_actual
    fi
    read -p "Presione Enter para continuar..."
}

mostrar_menu() {
    clear
    echo -e "${AZUL}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${AZUL}║          PROGRAMADOR DE TAREAS (CRON)                    ║${NC}"
    echo -e "${AZUL}║          Interfaz Amigable para Usuarios                 ║${NC}"
    echo -e "${AZUL}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "┌─────────────────────────────────────────┐"
    echo "│ 1) Ver tareas programadas               │"
    echo "│ 2) Agregar nueva tarea                  │"
    echo "│ 3) Eliminar tarea                       │"
    echo "│ 4) Salir                                │"
    echo "└─────────────────────────────────────────┘"
    echo ""
    echo -n "Seleccione una opcion (1-4): "
}

main() {
    while true; do
        mostrar_menu
        read -r opcion
        case $opcion in
            1) mostrar_tareas_actuales ;;
            2) agregar_tarea ;;
            3) eliminar_tarea ;;
            4) 
                echo ""
                echo -e "${VERDE}Saliendo del programador de tareas...${NC}"
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
