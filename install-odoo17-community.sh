#!/bin/bash

# Script de instalación de Odoo 17 Community en Ubuntu
# Autor: JPGA12
# Licencia: MIT License
# GitHub: https://github.com/JPGA12/Script-Odoo-17-Ubuntu-2204
# Ejecutar con privilegios root (sudo)
#
# MIT License
# Copyright (c) 2025 JPGA12
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# Colores para mejor visualización
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Iniciando instalación de Odoo 17 Community ===${NC}"
echo -e "${GREEN}Esta versión instala únicamente Odoo 17 Community Edition${NC}"
echo -e "${GREEN}Compatible con cualquier VPS Ubuntu 22.04 LTS${NC}"
echo ""

# Verificar que estamos en Ubuntu 22.04
if ! grep -q "Ubuntu 22.04" /etc/os-release 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Advertencia: Este script está optimizado para Ubuntu 22.04 LTS${NC}"
    echo -e "${YELLOW}   Versión detectada: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'No detectada')${NC}"
    echo -e "${YELLOW}   ¿Desea continuar de todas formas? (s/N)${NC}"
    read -r continue_response
    if [[ ! "$continue_response" =~ ^([sS][iI]|[sS])$ ]]; then
        echo -e "${YELLOW}Instalación cancelada.${NC}"
        exit 1
    fi
fi

check_status() {
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Error en el paso anterior. Revise los mensajes de error y corrija antes de continuar.${NC}"
        exit 1
    fi
}

# 1. Actualizar sistema
echo -e "${GREEN}[1/9] Actualizando el sistema...${NC}"
apt update
check_status
apt upgrade -y
check_status

# 2. Instalar dependencias
echo -e "${GREEN}[2/9] Instalando dependencias...${NC}"
apt remove -y nodejs npm
apt autoremove -y

curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Instalar Python 3.11
apt install -y software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt update
apt install -y python3.11 python3.11-venv python3.11-dev python3.11-distutils

apt install -y postgresql-server-dev-14 build-essential python3-pil \
    python3-lxml python3-dev python3-pip python3-setuptools \
    git gdebi libldap2-dev libsasl2-dev libxml2-dev python3-wheel python3-venv \
    libxslt1-dev libjpeg-dev
check_status

npm install -g less
check_status

# 2.1. Configurar MOTD personalizado JPGA
echo -e "${GREEN}[2.1/9] Configurando MOTD personalizado JPGA...${NC}"

# Instalar figlet si no está instalado
if ! command -v figlet &> /dev/null; then
    apt install -y figlet
    check_status
fi

# Crear archivo MOTD personalizado
cat > /etc/update-motd.d/00-jpga << 'EOF'
#!/bin/bash
echo -e "\n\033[38;2;155;109;255m$(figlet 'JPGA')\033[0m\n\
\033[97mBienvenido\033[0m\n\
\033[97m$(lsb_release -d | cut -f2)\033[0m\n\
\033[97mUptime: $(uptime -p)\033[0m\n\
\033[97mFecha: $(date)\033[0m\n"
EOF

# Hacer el archivo ejecutable
chmod +x /etc/update-motd.d/00-jpga
check_status

# Actualizar MOTD para que se vea inmediatamente
update-motd

echo -e "${GREEN}MOTD personalizado configurado correctamente${NC}"

# 3. Instalar y configurar PostgreSQL 14
echo -e "${GREEN}[3/9] Instalando y configurando PostgreSQL 14...${NC}"

# Verificar si PostgreSQL 14 está instalado
if ! dpkg -l | grep -q "postgresql-14"; then
    echo "PostgreSQL 14 no está instalado. Instalando..."
    apt install -y postgresql-14 postgresql-client-14 postgresql-contrib-14
    check_status
else
    echo -e "${YELLOW}PostgreSQL 14 ya está instalado.${NC}"
fi

# Verificar y crear cluster si no existe
if ! pg_lsclusters | grep -q "^14.*main.*online"; then
    echo "Creando y arrancando cluster PostgreSQL 14 main..."
    pg_createcluster 14 main --start
    check_status
else
    echo -e "${YELLOW}El cluster PostgreSQL 14 main ya existe y está online.${NC}"
fi

# Iniciar y habilitar el servicio
systemctl start postgresql
systemctl enable postgresql
echo -e "${GREEN}Estado de PostgreSQL:${NC}"
systemctl status postgresql --no-pager -l

# 4. Crear usuario para Odoo
echo -e "${GREEN}[4/9] Creando usuario para Odoo...${NC}"
if id "odoo17" >/dev/null 2>&1; then
    echo -e "${YELLOW}El usuario odoo17 ya existe, continuando...${NC}"
else
    useradd -m -d /opt/odoo17 -U -r -s /bin/bash odoo17
    check_status
fi

if ! su - postgres -c "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='odoo17'\"" | grep -q 1; then
    su - postgres -c "psql -c \"CREATE USER odoo17 WITH LOGIN SUPERUSER PASSWORD 'odoo17';\""
    check_status
else
    echo -e "${YELLOW}El usuario odoo17 ya existe en PostgreSQL, actualizando contraseña...${NC}"
    su - postgres -c "psql -c \"ALTER USER odoo17 WITH PASSWORD 'odoo17';\""
    check_status
fi

# 5. Crear directorios y permisos
echo -e "${GREEN}[5/9] Creando directorios necesarios...${NC}"
mkdir -p /opt/odoo17
chown -R odoo17:odoo17 /opt/odoo17
chmod -R 755 /opt/odoo17

# 6. Instalar wkhtmltopdf
echo -e "${GREEN}[6/9] Instalando wkhtmltopdf...${NC}"
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
check_status
apt install -y ./wkhtmltox_0.12.6.1-3.jammy_amd64.deb
check_status
rm wkhtmltox_0.12.6.1-3.jammy_amd64.deb

# 7. Clonar repositorio Odoo 17 Community
echo -e "${GREEN}[7/9] Clonando Odoo 17 Community desde GitHub...${NC}"
if [ -d "/opt/odoo17/odoo" ]; then
    echo -e "${YELLOW}El directorio /opt/odoo17/odoo ya existe. ¿Desea eliminarlo y volver a clonar? (s/N)${NC}"
    read -r response
    if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
        rm -rf /opt/odoo17/odoo
        su - odoo17 -c "git clone https://github.com/odoo/odoo --depth 1 --branch 17.0 /opt/odoo17/odoo"
        check_status
    else
        echo -e "${YELLOW}Continuando con el directorio existente...${NC}"
    fi
else
    su - odoo17 -c "git clone https://github.com/odoo/odoo --depth 1 --branch 17.0 /opt/odoo17/odoo"
    check_status
fi

echo -e "${GREEN}Odoo 17 Community clonado correctamente - Solo módulos oficiales${NC}"

# Establecer permisos
echo -e "${GREEN}Estableciendo permisos correctos...${NC}"
chown -R odoo17:odoo17 /opt/odoo17
chmod -R 755 /opt/odoo17

# 7.1 Configurar entorno virtual Python 3.11
echo -e "${GREEN}[7.1/9] Configurando entorno virtual Python 3.11...${NC}"
su - odoo17 -c "python3.11 -m venv /opt/odoo17/odoo/odoo-venv"
su - odoo17 -c "source /opt/odoo17/odoo/odoo-venv/bin/activate && pip install --upgrade pip wheel setuptools"
check_status

su - odoo17 -c "source /opt/odoo17/odoo/odoo-venv/bin/activate && pip install -r /opt/odoo17/odoo/requirements.txt"
check_status

# 8. Configurar archivo de configuración
echo -e "${GREEN}[8/9] Configurando archivo de configuración de Odoo...${NC}"

echo -e "${GREEN}Configurando solo con módulos Community...${NC}"

cat > /etc/odoo17.conf << EOF
[options]
admin_passwd = admin_password
db_host = localhost
db_port = 5432
db_user = odoo17
db_password = odoo17
addons_path = /opt/odoo17/odoo/addons
xmlrpc_port = 8069
longpolling_port = 8072
workers = 2
proxy_mode = True
EOF

chown odoo17:odoo17 /etc/odoo17.conf
chmod 640 /etc/odoo17.conf

# 9. Crear archivo systemd para Odoo
echo -e "${GREEN}[9/9] Configurando servicio systemd para Odoo...${NC}"
cat > /etc/systemd/system/odoo17.service << EOF
[Unit]
Description=Odoo 17 Community
After=network.target postgresql.service

[Service]
User=odoo17
Group=odoo17
ExecStart=/opt/odoo17/odoo/odoo-venv/bin/python /opt/odoo17/odoo/odoo-bin -c /etc/odoo17.conf
Restart=on-failure
KillMode=mixed
TimeoutSec=120

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable odoo17

# 10. Reiniciar y verificar Odoo
echo -e "${GREEN}[10/9] Iniciando servicio Odoo...${NC}"
systemctl restart odoo17
systemctl status odoo17

# 11. Mostrar MOTD personalizado JPGA
echo -e "${GREEN}[11/9] Mostrando MOTD personalizado JPGA...${NC}"
echo -e "${GREEN}============================================${NC}"
/etc/update-motd.d/00-jpga
echo -e "${GREEN}============================================${NC}"

echo -e "${GREEN}=== Instalación completada ===${NC}"

echo -e "${GREEN}✅ Odoo 17 Community instalado correctamente${NC}"
echo -e "${GREEN}✅ Solo módulos oficiales de Odoo disponibles${NC}"
echo -e "${GREEN}✅ Versión limpia y estable para producción${NC}"

echo -e "📊 Para ver los logs: ${YELLOW}sudo journalctl -u odoo17 -f${NC}"
echo -e "🌐 Acceda a Odoo desde su navegador: ${YELLOW}http://localhost:8069${NC}"
echo -e "🔐 IMPORTANTE: Recuerde cambiar 'admin_password' en /etc/odoo17.conf por una contraseña segura"
echo -e "${YELLOW}📦 Esta instalación incluye solo los módulos Community de Odoo${NC}"