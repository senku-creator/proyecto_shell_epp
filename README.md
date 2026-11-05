Conjunto de scripts Bash desarrollados para automatizar tareas básicas de administración en servidores Linux. Este proyecto resuelve la necesidad del área de TI de una empresa mediana de optimizar procesos manuales como revisar el uso de disco, organizar archivos y generar reportes simples.

INTEGRANTES: 
- Huaman Laime, Brayan Jack 
- Quijandria Chavez Fabrizio Farid 

proyecto_shell_epp/
├── scripts/
│   ├── 01_reporte_sistema.sh      # Reporte completo del sistema
│   ├── 02_gestor_archivos.sh      # Gestor seguro de archivos
│   ├── 03_analisis_servidores.sh  # Análisis y monitoreo
│   └── 04_programador_cron.sh     # Programador de tareas
├── reportes/                       # Reportes generados automáticamente
│   ├── reporte_sistema_*.txt
│   ├── servidores_alerta.txt
│   ├── servidores_revisados.txt
│   └── analisis_completo.txt
├── gestor_archivos/                # Carpeta segura de trabajo
└── README.md                       # Este archivo

git clone https://github.com/senku-creator/proyecto_shell_epp.git

cd proyecto_shell_epp

chmod +x scripts/*.sh

./scripts/01_reporte_sistema.sh
