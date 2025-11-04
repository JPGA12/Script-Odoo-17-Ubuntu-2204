# Script Odoo 17 Ubuntu 22.04

🚀 Script automatizado para instalar Odoo 17 Community Edition en Ubuntu 22.04 LTS

## ✨ Características

- ✅ **Instalación completa** de Odoo 17 Community
- ✅ **Python 3.11** optimizado para mejor rendimiento
- ✅ **PostgreSQL 14** preconfigurado
- ✅ **Entorno virtual** aislado y seguro
- ✅ **MOTD personalizado** con branding JPGA12
- ✅ **Compatible** con cualquier VPS Ubuntu 22.04
- ✅ **Systemd service** configurado automáticamente

## 🖥️ Compatibilidad

Este script funciona en cualquier VPS con Ubuntu 22.04 LTS:

- ☁️ **Hetzner Cloud**
- ☁️ **DigitalOcean**
- ☁️ **AWS EC2**
- ☁️ **Google Cloud**
- ☁️ **Azure**
- ☁️ **Vultr**
- ☁️ **Linode**
- ☁️ Y cualquier otro proveedor

## 📋 Requisitos

- Ubuntu 22.04 LTS
- Acceso root o sudo
- Al menos 2GB de RAM
- Conexión a Internet

## 🚀 Instalación rápida

```bash
# Descargar el script
wget https://raw.githubusercontent.com/JPGA12/Script-Odoo-17-Ubuntu-2204/main/install-odoo17-community.sh

# Dar permisos de ejecución
chmod +x install-odoo17-community.sh

# Ejecutar como root
sudo ./install-odoo17-community.sh
```

## 📦 ¿Qué instala?

- **Odoo 17 Community** (última versión estable)
- **Python 3.11** + entorno virtual
- **PostgreSQL 14** + cluster configurado
- **Node.js 18** + Less CSS compiler
- **wkhtmltopdf** para generación de PDFs
- **Todas las dependencias** necesarias

## 🔧 Configuración post-instalación

Después de la instalación exitosa:

1. **Acceder a Odoo**: http://tu-servidor:8069
2. **Cambiar contraseña**: Editar `admin_password` en `/etc/odoo17.conf`
3. **Ver logs**: `sudo journalctl -u odoo17 -f`

## 📁 Estructura de directorios

```
/opt/odoo17/
├── odoo/                 # Código fuente de Odoo
├── odoo/addons/         # Módulos Community oficiales
└── odoo/odoo-venv/      # Entorno virtual Python
```

## ⚙️ Configuración del servicio

- **Archivo de configuración**: `/etc/odoo17.conf`
- **Servicio systemd**: `odoo17.service`
- **Usuario del sistema**: `odoo17`
- **Puerto por defecto**: `8069`

## 🔒 Seguridad

- Usuario dedicado `odoo17` sin privilegios sudo
- Entorno virtual aislado
- Configuración con permisos restrictivos
- PostgreSQL con usuario específico

## 🤝 Contribuir

¡Las contribuciones son bienvenidas!

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 🙋‍♂️ Autor

**JPGA12** - [@JPGA12](https://github.com/JPGA12)

## ⭐ ¿Te fue útil?

Si este script te ayudó, considera darle una ⭐ al repositorio. ¡Es gratis y me ayuda mucho!

## 📞 Soporte

¿Problemas con la instalación? 

- 🐛 [Reportar un bug](https://github.com/JPGA12/Script-Odoo-17-Ubuntu-2204/issues)
- 💡 [Solicitar una característica](https://github.com/JPGA12/Script-Odoo-17-Ubuntu-2204/issues)

---

<p align="center">
  Hecho con ❤️ por <strong>JPGA12</strong>
</p>
