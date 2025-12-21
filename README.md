# 🔄 DBComparer

<div align="center">

**Herramienta profesional de sincronización de bases de datos heterogéneas**

[![Delphi](https://img.shields.io/badge/Delphi-10.4%2B-red?style=flat-square&logo=delphi)](https://www.embarcadero.com/products/delphi)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![UniDAC](https://img.shields.io/badge/Devart-UniDAC-green?style=flat-square)](https://www.devart.com/unidac/)

*Compara, sincroniza y migra esquemas y datos entre diferentes motores de bases de datos con un solo comando.*

[Características](#-características) • [Instalación](#-compilación) • [Uso](#-uso-rápido) • [Ejemplos](#-ejemplos-por-motor) • [Licencia](#-licencia)

</div>

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características](#-características)
- [Bases de Datos Soportadas](#-bases-de-datos-soportadas)
- [Requisitos](#-requisitos-importantes)
- [Compilación](#-compilación)
- [Uso Rápido](#-uso-rápido)
- [Ejemplos por Motor](#-ejemplos-por-motor)
- [Opciones Avanzadas](#-opciones-de-línea-de-comandos)
- [Casos de Uso](#-casos-de-uso-comunes)
- [Licencia](#-licencia)
- [Disclaimer](#-disclaimer)

---

## 🎯 Descripción

**DBComparer** es una suite de herramientas de línea de comandos desarrollada en **Delphi** que permite a DBAs y desarrolladores:

- ✅ Comparar esquemas entre bases de datos heterogéneas
- ✅ Generar scripts DDL de sincronización automática
- ✅ Sincronizar datos de forma inteligente (INSERT/UPDATE/DELETE)
- ✅ Mantener entornos (Dev ➡️ QA ➡️ Prod) actualizados
- ✅ Automatizar despliegues con seguridad y control

---

## ✨ Características

### 🏗️ **Sincronización de Estructura (Schema Diff)**

| Elemento | Funcionalidad |
|----------|---------------|
| **Tablas** | Creación, nuevas columnas, modificación de tipos y nulabilidad |
| **Índices** | Primary Keys, Unique, índices secundarios |
| **Vistas** | Comparación y recreación automática |
| **Procedimientos** | Stored Procedures y Funciones |
| **Triggers** | Sincronización opcional con `--with-triggers` |
| **Secuencias** | Generadores y Secuencias (estrategia "crear si no existe") |

### 📊 **Sincronización de Datos (Data Diff)**

| Modo | Descripción | Opción |
|------|-------------|--------|
| **Copia Simple** | Volcado masivo de datos (`INSERT`) | `--with-data` |
| **Sincronización Inteligente** | Comparación por PK: `INSERT` + `UPDATE` + `DELETE` | `--with-data-diff` |

### 🔒 **Seguridad y Control**

- 🛡️ **Modo Seguro** (`--nodelete`): Evita borrados accidentales
- 🎯 **Lista Blanca** (`--include-tables`): Sincroniza solo tablas específicas
- 🚫 **Lista Negra** (`--exclude-tables`): Excluye tablas del proceso
- 📝 **Scripts SQL**: Genera archivos `.sql` para revisión antes de ejecutar

---

## 🗄️ Bases de Datos Soportadas

<div align="center">

| Motor | Versión | Ejecutable | Características Especiales |
|-------|---------|------------|---------------------------|
| ![MySQL](https://img.shields.io/badge/MySQL-005C84?style=flat-square&logo=mysql&logoColor=white) | 5.7+ / MariaDB 10+ | `DBComparer.exe` | Full support |
| ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat-square&logo=postgresql&logoColor=white) | 9.6+ | `DBComparerPostGre.exe` | Soporte de esquemas |
| ![Oracle](https://img.shields.io/badge/Oracle-F80000?style=flat-square&logo=oracle&logoColor=white) | 11g+ | `DBComparerOracle.exe` | TNS Names, Owners |
| ![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=flat-square&logo=microsoft-sql-server&logoColor=white) | 2012+ | `DBComparerSQLServer.exe` | Columnas Identity |
| ![Firebird](https://img.shields.io/badge/Firebird-FF6600?style=flat-square&logo=firebird&logoColor=white) | 2.5+ / InterBase | `DBComparerInterbase.exe` | Generadores, Dialectos |

</div>

---

## ⚠️ Requisitos Importantes

### 📦 Dependencias

Este proyecto utiliza **[Devart UniDAC](https://www.devart.com/unidac/)** para conectividad universal.

> **⚖️ Nota sobre Licencias:**
> 
> - El código fuente de **DBComparer** se distribuye bajo licencia **MIT** (uso libre).
> - Para **compilar** el proyecto necesitas una **licencia comercial válida de Devart UniDAC**.
> - Los archivos fuente de UniDAC (`.dcu`, `.pas`) **NO** están incluidos en este repositorio.

### 🖥️ Requisitos de Sistema

- **Delphi**: 10.4 Sydney o superior (11 Alexandria, 12 Athens)
- **Devart UniDAC**: Instalado en el IDE de Delphi
- **Windows**: 7/8/10/11 (32-bit o 64-bit)

---

## 🛠️ Compilación

1. **Clona el repositorio:**
   ```bash
   git clone https://github.com/tuusuario/DBComparer.git
   cd DBComparer
   ```

2. **Abre el proyecto en Delphi:**
   - Selecciona el archivo `.dpr` del motor deseado:
     - `DBComparer.dpr` → MySQL/MariaDB
     - `DBComparerPostGre.dpr` → PostgreSQL
     - `DBComparerOracle.dpr` → Oracle
     - `DBComparerSQLServer.dpr` → SQL Server
     - `DBComparerInterbase.dpr` → InterBase/Firebird

3. **Compila el proyecto:**
   - Modo: **Release**
   - Plataforma: **Win32** o **Win64**

4. **Ejecutable generado:**
   ```
   DBComparer\Win32\Release\DBComparer.exe
   ```

---

## 🚀 Uso Rápido

### Sintaxis General

```bash
Ejecutable.exe <Origen> <Destino> [Opciones]
```

### Formato de Conexión

```
servidor:puerto\base_datos usuario\password
```

### Ejemplo Básico

```bash
# Sincronizar solo estructura
DBComparer.exe localhost:3306\produccion root\pass localhost:3306\desarrollo root\pass

# Sincronizar estructura + datos
DBComparer.exe localhost:3306\produccion root\pass localhost:3306\desarrollo root\pass --with-data-diff
```

---

## 💡 Ejemplos por Motor

### 🐬 MySQL / MariaDB

```bash
# Sincronización completa con datos
DBComparer.exe localhost:3306\db_prod root\pass localhost:3306\db_dev root\pass --with-data-diff

# Solo tablas específicas
DBComparer.exe localhost:3306\db_prod root\pass localhost:3306\db_dev root\pass --include-tables=usuarios,productos

# Excluir tablas de logs
DBComparer.exe localhost:3306\db_prod root\pass localhost:3306\db_dev root\pass --exclude-tables=logs,auditoria
```

### 🐘 PostgreSQL

```bash
# Formato: servidor:puerto\base\esquema
DBComparerPostGre.exe localhost:5432\ventas\public postgres\pass localhost:5432\ventas\test postgres\pass

# Esquema personalizado
DBComparerPostGre.exe prod-server:5432\erp\contabilidad admin\pass dev-server:5432\erp\contabilidad admin\pass
```

### 🔴 Oracle Database

```bash
# Conexión directa: host:port/SID user/pass@Owner
DBComparerOracle.exe 192.168.1.10:1521/ORCL system/pass@HR 192.168.1.20:1521/ORCL system/pass@HR_TEST

# Usando TNS Names
DBComparerOracle.exe //PROD_DB system/pass //TEST_DB system/pass

# Con Owner específico
DBComparerOracle.exe //PROD_DB system/pass@APP_OWNER //TEST_DB system/pass@APP_OWNER
```

### 🟦 Microsoft SQL Server

```bash
# Modo seguro (sin borrados)
DBComparerSQLServer.exe sqlserver:1433\Produccion sa\pass sqlserver:1433\Desarrollo sa\pass --nodelete

# Con triggers y datos
DBComparerSQLServer.exe sqlserver:1433\Produccion sa\pass sqlserver:1433\Desarrollo sa\pass --with-triggers --with-data-diff
```

### 🔥 InterBase / Firebird

```bash
# Servidor remoto
DBComparerInterbase.exe 192.168.1.50:3050\C:\Data\prod.gdb sysdba\masterkey 192.168.1.50:3050\C:\Data\test.gdb sysdba\masterkey

# Archivo local (embebido)
DBComparerInterbase.exe localhost\C:\Data\prod.gdb sysdba\masterkey localhost\C:\Data\test.gdb sysdba\masterkey
```

---

## ⚙️ Opciones de Línea de Comandos

| Opción | Descripción |
|--------|-------------|
| `--nodelete` | 🛡️ **Modo Seguro**: No elimina tablas, columnas, índices ni registros en destino |
| `--with-triggers` | 🔫 Incluye comparación y recreación de Triggers |
| `--with-data` | 📥 Copia masiva de datos (solo `INSERT`) |
| `--with-data-diff` | 🔄 Sincronización inteligente por PK (`INSERT`/`UPDATE`/`DELETE`) |
| `--include-tables=t1,t2` | ✅ **Lista Blanca**: Solo procesa las tablas especificadas |
| `--exclude-tables=t1,t2` | ❌ **Lista Negra**: Excluye las tablas especificadas |

### Combinaciones Útiles

```bash
# Modo ultraprotegido (solo agregar, nunca eliminar)
--nodelete --with-data-diff

# Sincronización completa con triggers
--with-triggers --with-data-diff

# Solo migrar datos de tablas maestras
--include-tables=clientes,productos,categorias --with-data
```

---

## 🎯 Casos de Uso Comunes

### 1. **Despliegue Dev ➡️ Producción**
```bash
DBComparer.exe dev-server:3306\myapp root\pass prod-server:3306\myapp root\pass --nodelete
```

### 2. **Clonar Estructura sin Datos**
```bash
DBComparer.exe source:3306\db user\pass target:3306\db user\pass
```

### 3. **Replicar Tablas Maestras**
```bash
DBComparer.exe prod:3306\erp user\pass dev:3306\erp user\pass --include-tables=paises,provincias,categorias --with-data
```

### 4. **Sincronización Continua (CI/CD)**
```bash
# En un script de Jenkins/GitLab CI
DBComparerPostGre.exe prod-db:5432\app\public admin\pass stage-db:5432\app\public admin\pass --with-data-diff --nodelete
```

### 5. **Migración entre Motores Diferentes**
```bash
# MySQL ➡️ PostgreSQL (requiere exportar/importar manualmente)
# DBComparer genera los scripts DDL compatibles
```

---

## 📄 Licencia

Este proyecto está licenciado bajo la **Licencia MIT**.

```
Copyright (c) 2025 Alejandro Laorden Hidalgo

Se concede permiso, de forma gratuita, a cualquier persona que obtenga una copia
de este software y archivos de documentación asociados (el "Software"), para 
utilizar el Software sin restricción...
```

Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

## ⚠️ Disclaimer

> **Este software se proporciona "TAL CUAL", sin garantía de ningún tipo**, expresa o implícita, incluyendo, pero no limitándose a, las garantías de comercialización, idoneidad para un propósito particular y no infracción.
>
> **⚠️ RECOMENDACIÓN CRÍTICA:**
> 
> Realiza **copias de seguridad completas** de tu base de datos de destino antes de ejecutar cualquier script de sincronización en **entornos de producción**.

---

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📞 Soporte

- 🐛 **Issues**: [GitHub Issues](https://github.com/tuusuario/DBComparer/issues)
- 📧 **Email**: alejandro.laorden@protonmail.com
- 💬 **Discusiones**: [GitHub Discussions](https://github.com/tuusuario/DBComparer/discussions)

---

<div align="center">

**Hecho con ❤️ usando Delphi y Devart UniDAC**

⭐ Si este proyecto te resulta útil, ¡considera darle una estrella en GitHub!

</div>
