#!/bin/sh
# sync_to_git.sh

# Configuración de Git (se establecerá con secretos de Fly.io)
git config --global user.email "action@github.com"
git config --global user.name "GitHub Action"

# Navegar a la carpeta donde se guardan los workflows
cd /home/node/.n8n/

# Exportar todos los workflows de la base de datos a archivos .json en la carpeta workflows/
# Esto sobrescribirá los archivos existentes con la versión más reciente de la UI de n8n
n8n export:workflow --all --output=./workflows/

# Añadir cambios, hacer commit y push
# El comando "git status --porcelain" devuelve una salida si hay cambios.
if [ -n "$(git status --porcelain)" ]; then
  echo "Cambios detectados en los workflows. Sincronizando con el repositorio."
  git add workflows/*.json
  # Usamos [skip ci] en el mensaje de commit para evitar un bucle de despliegue infinito!
  git commit -m "chore: Sincronización automática de workflows desde n8n [skip ci]"
  git push origin main
else
  echo "No hay cambios en los workflows."
fi