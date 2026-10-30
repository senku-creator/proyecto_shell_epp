# 🐧 Proyecto Shell Scripting - EPP

## 📋 Descripción
Conjunto de scripts Bash desarrollados para automatizar tareas básicas de administración en servidores Linux. Este proyecto resuelve la necesidad del área de TI de una empresa mediana de optimizar procesos manuales como revisar el uso de disco, organizar archivos y generar reportes simples.

## 👥 Integrantes
- Huaman Laime, Brayan Jack 
- Quijandria Chavez Fabrizio Farid 

## 📁 Scripts Incluidos

### 1️⃣ Reporte del Sistema (`01_reporte_sistema.sh`)
Genera un reporte completo del sistema en formato tabla visual y lo guarda en un archivo TXT.

**Información que muestra:**
- Usuario actual, fecha y hora
- Sistema operativo y kernel
- Dirección IP y hostname
- Uso real de CPU, memoria y disco

**Ejecutar:**
```bash
./scripts/01_reporte_sistema.sh
./scripts/02_gestor_archivos.sh
/scripts/03_analisis_servidores.sh
./scripts/04_programador_cron.sh

# 1. Clonar el repositorio
git clone https://github.com/senku-creator/proyecto_shell_epp.git

# 2. Entrar a la carpeta del proyecto
cd proyecto_shell_epp

# 3. Dar permisos de ejecución a todos los scripts
chmod +x scripts/*.sh

# 4. Ejecutar cualquier script
./scripts/01_reporte_sistema.sh
