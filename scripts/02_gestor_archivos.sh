#!/bin/bash
set -euo pipefail

VERDE='\033[0;32m'
AZUL='\033[0;34m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CARPETA_SEGURA="./gestor_archivos"

inicializar() {
    if [[ ! -d "$CARPETA_SEGURA" ]]; then
        mkdir -p "$CARPETA_SEGURA"
    fi
}

listar_archivos() {
    echo ""
    echo -e "${CYAN}Archivos disponibles en la carpeta:${NC}"
    echo "------------------------------------------"
    ARCHIVOS=()
    local contador=1
    while IFS= read -r archivo; do
        if [[ -n "$archivo" ]]; then
            ARCHIVOS+=("$archivo")
            permisos=$(stat -c "%A" "$CARPETA_SEGURA/$archivo" 2>/dev/null)
            printf "%2d) %-25s [Permisos: %s]\n" "$contador" "$archivo" "$permisos"
            ((contador++))
        fi
    done < <(ls -1 "$CARPETA_SEGURA" 2>/dev/null)
    echo "------------------------------------------"
    if [[ ${#ARCHIVOS[@]} -eq 0 ]]; then
        echo -e "${AMARILLO}No hay archivos en la carpeta.${NC}"
        return 1
    fi
    return 0
}

mostrar_menu() {
    clear
    echo -e "${AZUL}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${AZUL}║              GESTOR DE ARCHIVOS SEGURO                   ║${NC}"
    echo -e "${AZUL}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Carpeta de trabajo: $(pwd)/$CARPETA_SEGURA${NC}"
    echo ""
    echo "┌──────────────────────────────────────────────────────┐"
    echo "│ 1) Crear un nuevo archivo                            │"
    echo "│ 2) Copiar un archivo existente                       │"
    echo "│ 3) Cambiar permisos (Interfaz amigable)              │"
    echo "│ 4) Eliminar un archivo                               │"
    echo "│ 5) Salir del programa                                │"
    echo "└──────────────────────────────────────────────────────┘"
    echo ""
    echo -n "Seleccione una opcion (1-5): "
}

crear_archivo() {
    clear
    echo -e "${AZUL}=== CREAR ARCHIVO ===${NC}"
    echo ""
    echo -n "Ingrese el nombre del archivo (ej: reporte.txt): "
    read -r nombre
    if [[ -z "$nombre" ]]; then
        echo -e "${ROJO}Error: El nombre no puede estar vacio.${NC}"
    elif [[ -f "$CARPETA_SEGURA/$nombre" ]]; then
        echo -e "${ROJO}Error: Ya existe un archivo con ese nombre.${NC}"
    else
        touch "$CARPETA_SEGURA/$nombre"
        echo -e "${VERDE}Archivo '$nombre' creado exitosamente.${NC}"
    fi
    echo ""
    read -p "Presione Enter para volver al menu..."
}

copiar_archivo() {
    clear
    echo -e "${AZUL}=== COPIAR ARCHIVO ===${NC}"
    if ! listar_archivos; then
        read -p "Presione Enter para volver al menu..."
        return
    fi
    echo ""
    echo -n "Ingrese el NUMERO del archivo a copiar: "
    read -r num
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [[ "$num" -lt 1 ]] || [[ "$num" -gt ${#ARCHIVOS[@]} ]]; then
        echo -e "${ROJO}Error: Numero invalido.${NC}"
        read -p "Presione Enter para volver al menu..."
        return
    fi
    origen="${ARCHIVOS[$((num-1))]}"
    echo -n "Ingrese el nombre para la COPIA (ej: copia.txt): "
    read -r destino
    if [[ -z "$destino" ]]; then
        echo -e "${ROJO}Error: El nombre de la copia no puede estar vacio.${NC}"
    elif [[ -f "$CARPETA_SEGURA/$destino" ]]; then
        echo -e "${ROJO}Error: Ya existe un archivo con ese nombre de destino.${NC}"
    else
        cp "$CARPETA_SEGURA/$origen" "$CARPETA_SEGURA/$destino"
        echo -e "${VERDE}Archivo copiado: '$origen' -> '$destino'${NC}"
    fi
    echo ""
    read -p "Presione Enter para volver al menu..."
}

cambiar_permisos() {
    clear
    echo -e "${AZUL}=== CAMBIAR PERMISOS (FACIL) ===${NC}"
    echo ""
    echo -e "${AMARILLO}Los permisos controlan quien puede leer, escribir o ejecutar${NC}"
    echo -e "${AMARILLO}un archivo. Elija una opcion segun lo que necesite:${NC}"
    echo ""
    if ! listar_archivos; then
        read -p "Presione Enter para volver al menu..."
        return
    fi
    echo ""
    echo -n "Ingrese el NUMERO del archivo a modificar: "
    read -r num
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [[ "$num" -lt 1 ]] || [[ "$num" -gt ${#ARCHIVOS[@]} ]]; then
        echo -e "${ROJO}Error: Numero invalido.${NC}"
        read -p "Presione Enter para volver al menu..."
        return
    fi
    archivo="${ARCHIVOS[$((num-1))]}"
    ruta="$CARPETA_SEGURA/$archivo"
    clear
    echo -e "${AZUL}Archivo seleccionado: ${CYAN}$archivo${NC}"
    echo ""
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│ ¿Que permisos desea asignar?                                    │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    echo "│ 1) Solo Lectura (444)                                           │"
    echo "│    Nadie puede modificar ni borrar el archivo. Solo ver.        │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    echo "│ 2) Lectura y Escritura para el dueño (644) [RECOMENDADO]        │"
    echo "│    Usted puede editar, los demas solo pueden leer.              │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    echo "│ 3) Ejecutable (755)                                             │"
    echo "│    Para scripts o programas. Todos pueden ejecutar.             │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    echo "│ 4) Acceso Total (777) [NO SEGURO]                               │"
    echo "│    CUALQUIER persona puede leer, modificar y ejecutar.          │"
    echo "└─────────────────────────────────────────────────────────────────┘"
    echo ""
    echo -n "Seleccione el tipo de permiso (1-4): "
    read -r opcion
    case $opcion in
        1) chmod 444 "$ruta"; perm="444 (Solo Lectura)" ;;
        2) chmod 644 "$ruta"; perm="644 (Lectura/Escritura dueño)" ;;
        3) chmod 755 "$ruta"; perm="755 (Ejecutable)" ;;
        4) chmod 777 "$ruta"; perm="777 (Acceso Total - Inseguro)" ;;
        *) echo -e "${ROJO}Opcion invalida.${NC}"; read -p "Presione Enter..."; return ;;
    esac
    echo -e "${VERDE}Permisos de '$archivo' cambiados a: $perm${NC}"
    read -p "Presione Enter para volver al menu..."
}

eliminar_archivo() {
    clear
    echo -e "${AZUL}=== ELIMINAR ARCHIVO ===${NC}"
    echo ""
    if ! listar_archivos; then
        read -p "Presione Enter para volver al menu..."
        return
    fi
    echo ""
    echo -n "Ingrese el NUMERO del archivo a ELIMINAR: "
    read -r num
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [[ "$num" -lt 1 ]] || [[ "$num" -gt ${#ARCHIVOS[@]} ]]; then
        echo -e "${ROJO}Error: Numero invalido.${NC}"
        read -p "Presione Enter para volver al menu..."
        return
    fi
    archivo="${ARCHIVOS[$((num-1))]}"
    ruta="$CARPETA_SEGURA/$archivo"
    ruta_absoluta=$(realpath "$ruta")
    carpeta_absoluta=$(realpath "$CARPETA_SEGURA")
    if [[ "$ruta_absoluta" != "$carpeta_absoluta"/* ]]; then
        echo -e "${ROJO}ERROR DE SEGURIDAD: El archivo no pertenece a la carpeta segura.${NC}"
        read -p "Presione Enter para volver al menu..."
        return
    fi
    echo ""
    echo -e "${ROJO}ADVERTENCIA: Esta a punto de eliminar '$archivo'${NC}"
    echo -e "${ROJO}Esta accion NO se puede deshacer.${NC}"
    echo ""
    echo -n "¿Esta seguro? Escriba 'SI' para confirmar: "
    read -r confirmacion
    if [[ "$confirmacion" == "SI" ]]; then
        rm "$ruta"
        echo -e "${VERDE}Archivo '$archivo' eliminado correctamente.${NC}"
    else
        echo -e "${AMARILLO}Operacion cancelada por el usuario.${NC}"
    fi
    read -p "Presione Enter para volver al menu..."
}

main() {
    inicializar
    while true; do
        mostrar_menu
        read -r opcion
        case $opcion in
            1) crear_archivo ;;
            2) copiar_archivo ;;
            3) cambiar_permisos ;;
            4) eliminar_archivo ;;
            5) 
                echo ""
                echo -e "${VERDE}Saliendo del Gestor de Archivos.${NC}"
                sleep 1
                exit 0
                ;;
            *) 
                echo -e "${ROJO}Opcion invalida. Ingrese un numero del 1 al 5.${NC}"
                sleep 2
                ;;
        esac
    done
}

main
set -euo pipefail

VERDE='\033[0;32m'
AZUL='\033[0;34m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CARPETA_SEGURA="./gestor_archivos"

inicializar() {
    if [[ ! -d "$CARPETA_SEGURA" ]]; then
        mkdir -p "$CARPETA_SEGURA"
    fi
}

listar_archivos() {
    echo ""
    echo -e "${CYAN}Archivos disponibles en la carpeta:${NC}"
    echo "------------------------------------------"
    ARCHIVOS=()
    local contador=1
    while IFS= read -r archivo; do
        if [[ -n "$archivo" ]]; then
            ARCHIVOS+=("$archivo")
            permisos=$(stat -c "%A" "$CARPETA_SEGURA/$archivo" 2>/dev/null)
            printf "%2d) %-25s [Permisos: %s]\n" "$contador" "$archivo" "$permisos"
            ((contador++))
        fi
    done < <(ls -1 "$CARPETA_SEGURA" 2>/dev/null)
    echo "------------------------------------------"
    if [[ ${#ARCHIVOS[@]} -eq 0 ]]; then
        echo -e "${AMARILLO}No hay archivos en la carpeta.${NC}"
        return 1
    fi
    return 0
}

mostrar_menu() {
    clear
    echo -e "${AZUL}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${AZUL}║              GESTOR DE ARCHIVOS SEGURO                   ║${NC}"
    echo -e "${AZUL}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Carpeta de trabajo: $(pwd)/$CARPETA_SEGURA${NC}"
    echo ""
    echo "┌──────────────────────────────────────────────────────┐"
    echo "│ 1) Crear un nuevo archivo                            │"
    echo "│ 2) Copiar un archivo existente                       │"
    echo "│ 3) Cambiar permisos (Interfaz amigable)              │"
    echo "│ 4) Eliminar un archivo                               │"
    echo "│ 5) Salir del programa                                │"
    echo "└──────────────────────────────────────────────────────┘"
    echo ""
    echo -n "Seleccione una opcion (1-5): "
}

crear_archivo() {
    clear
    echo -e "${AZUL}=== CREAR ARCHIVO ===${NC}"
    echo ""
    echo -n "Ingrese el nombre del archivo (ej: reporte.txt): "
    read -r nombre
    if [[ -z "$nombre" ]]; then
        echo -e "${ROJO}Error: El nombre no puede estar vacio.${NC}"
    elif [[ -f "$CARPETA_SEGURA/$nombre" ]]; then
        echo -e "${ROJO}Error: Ya existe un archivo con ese nombre.${NC}"
    else
        touch "$CARPETA_SEGURA/$nombre"
        echo -e "${VERDE}Archivo '$nombre' creado exitosamente.${NC}"
    fi
    echo ""
    read -p "Presione Enter para volver al menu..."
}

copiar_archivo() {
    clear
    echo -e "${AZUL}=== COPIAR ARCHIVO ===${NC}"
    if ! listar_archivos; then
        read -p "Presione Enter para volver al menu..."
        return
    fi
    echo ""
    echo -n "Ingrese el NUMERO del archivo a copiar: "
    read -r num
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [[ "$num" -lt 1 ]] || [[ "$num" -gt ${#ARCHIVOS[@]} ]]; then
        echo -e "${ROJO}Error: Numero invalido.${NC}"
        read -p "Presione Enter para volver al menu..."
        return
    fi
    origen="${ARCHIVOS[$((num-1))]}"
    echo -n "Ingrese el nombre para la COPIA (ej: copia.txt): "
    read -r destino
    if [[ -z "$destino" ]]; then
        echo -e "${ROJO}Error: El nombre de la copia no puede estar vacio.${NC}"
    elif [[ -f "$CARPETA_SEGURA/$destino" ]]; then
        echo -e "${ROJO}Error: Ya existe un archivo con ese nombre de destino.${NC}"
    else
        cp "$CARPETA_SEGURA/$origen" "$CARPETA_SEGURA/$destino"
        echo -e "${VERDE}Archivo copiado: '$origen' -> '$destino'${NC}"
    fi
    echo ""
    read -p "Presione Enter para volver al menu..."
}

cambiar_permisos() {
    clear
    echo -e "${AZUL}=== CAMBIAR PERMISOS (FACIL) ===${NC}"
    echo ""
    echo -e "${AMARILLO}Los permisos controlan quien puede leer, escribir o ejecutar${NC}"
    echo -e "${AMARILLO}un archivo. Elija una opcion segun lo que necesite:${NC}"
    echo ""
    if ! listar_archivos; then
        read -p "Presione Enter para volver al menu..."
        return
    fi
    echo ""
    echo -n "Ingrese el NUMERO del archivo a modificar: "
    read -r num
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [[ "$num" -lt 1 ]] || [[ "$num" -gt ${#ARCHIVOS[@]} ]]; then
        echo -e "${ROJO}Error: Numero invalido.${NC}"
        read -p "Presione Enter para volver al menu..."
        return
    fi
    archivo="${ARCHIVOS[$((num-1))]}"
    ruta="$CARPETA_SEGURA/$archivo"
    clear
    echo -e "${AZUL}Archivo seleccionado: ${CYAN}$archivo${NC}"
    echo ""
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│ ¿Que permisos desea asignar?                                    │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    echo "│ 1) Solo Lectura (444)                                           │"
    echo "│    Nadie puede modificar ni borrar el archivo. Solo ver.        │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    echo "│ 2) Lectura y Escritura para el dueño (644) [RECOMENDADO]        │"
    echo "│    Usted puede editar, los demas solo pueden leer.              │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    echo "│ 3) Ejecutable (755)                                             │"
    echo "│    Para scripts o programas. Todos pueden ejecutar.             │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    echo "│ 4) Acceso Total (777) [NO SEGURO]                               │"
    echo "│    CUALQUIER persona puede leer, modificar y ejecutar.          │"
    echo "└─────────────────────────────────────────────────────────────────┘"
    echo ""
    echo -n "Seleccione el tipo de permiso (1-4): "
    read -r opcion
    case $opcion in
        1) chmod 444 "$ruta"; perm="444 (Solo Lectura)" ;;
        2) chmod 644 "$ruta"; perm="644 (Lectura/Escritura dueño)" ;;
        3) chmod 755 "$ruta"; perm="755 (Ejecutable)" ;;
        4) chmod 777 "$ruta"; perm="777 (Acceso Total - Inseguro)" ;;
        *) echo -e "${ROJO}Opcion invalida.${NC}"; read -p "Presione Enter..."; return ;;
    esac
    echo -e "${VERDE}Permisos de '$archivo' cambiados a: $perm${NC}"
    read -p "Presione Enter para volver al menu..."
}

eliminar_archivo() {
    clear
    echo -e "${AZUL}=== ELIMINAR ARCHIVO ===${NC}"
    echo ""
    if ! listar_archivos; then
        read -p "Presione Enter para volver al menu..."
        return
    fi
    echo ""
    echo -n "Ingrese el NUMERO del archivo a ELIMINAR: "
    read -r num
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [[ "$num" -lt 1 ]] || [[ "$num" -gt ${#ARCHIVOS[@]} ]]; then
        echo -e "${ROJO}Error: Numero invalido.${NC}"
        read -p "Presione Enter para volver al menu..."
        return
    fi
    archivo="${ARCHIVOS[$((num-1))]}"
    ruta="$CARPETA_SEGURA/$archivo"
    ruta_absoluta=$(realpath "$ruta")
    carpeta_absoluta=$(realpath "$CARPETA_SEGURA")
    if [[ "$ruta_absoluta" != "$carpeta_absoluta"/* ]]; then
        echo -e "${ROJO}ERROR DE SEGURIDAD: El archivo no pertenece a la carpeta segura.${NC}"
        read -p "Presione Enter para volver al menu..."
        return
    fi
    echo ""
    echo -e "${ROJO}ADVERTENCIA: Esta a punto de eliminar '$archivo'${NC}"
    echo -e "${ROJO}Esta accion NO se puede deshacer.${NC}"
    echo ""
    echo -n "¿Esta seguro? Escriba 'SI' para confirmar: "
    read -r confirmacion
    if [[ "$confirmacion" == "SI" ]]; then
        rm "$ruta"
        echo -e "${VERDE}Archivo '$archivo' eliminado correctamente.${NC}"
    else
        echo -e "${AMARILLO}Operacion cancelada por el usuario.${NC}"
    fi
    read -p "Presione Enter para volver al menu..."
}

main() {
    inicializar
    while true; do
        mostrar_menu
        read -r opcion
        case $opcion in
            1) crear_archivo ;;
            2) copiar_archivo ;;
            3) cambiar_permisos ;;
            4) eliminar_archivo ;;
            5) 
                echo ""
                echo -e "${VERDE}Saliendo del Gestor de Archivos.${NC}"
                sleep 1
                exit 0
                ;;
            *) 
                echo -e "${ROJO}Opcion invalida. Ingrese un numero del 1 al 5.${NC}"
                sleep 2
                ;;
        esac
    done
}

main
