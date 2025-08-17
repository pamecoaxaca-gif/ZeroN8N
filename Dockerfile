# Dockerfile

# Usar la imagen oficial de n8n como base
FROM n8nio/n8n:latest

# Cambiar al usuario root para instalar paquetes
USER root

RUN echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories
# Instalar Git, cron y un editor de texto (nano)
RUN apk add --no-cache git openssh dcron nano

# Crear directorio para el script de sincronización
RUN mkdir -p /app/scripts
WORKDIR /app/scripts

# Copiar el script de sincronización (lo crearemos a continuación)
COPY sync_to_git.sh .
RUN chmod +x sync_to_git.sh

# Configurar cron para que ejecute nuestro script cada 5 minutos
RUN echo "*/5 * * * * /app/scripts/sync_to_git.sh >> /var/log/cron.log 2>&1" | crontab -

# Copiar los workflows desde el repositorio a la carpeta de n8n
COPY ./workflows/ /home/node/.n8n/workflows/

# Volver al usuario por defecto de n8n
USER node

# El comando de inicio ahora debe iniciar cron Y n8n
CMD ["/bin/sh", "-c", "crond && n8n"]

