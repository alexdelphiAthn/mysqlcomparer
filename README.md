# DBComparer

**DBComparer** es una herramienta de línea de comandos potente y modular escrita en **Delphi** para comparar y sincronizar esquemas y datos entre bases de datos heterogéneas.

Diseñada para DBAs y desarrolladores que necesitan desplegar cambios, migrar estructuras o mantener entornos sincronizados (Desarrollo ➡️ Producción) de forma automatizada y segura.

---

## ⚠️ Requisito Importante (Dependencias)

Este proyecto utiliza **[Devart UniDAC](https://www.devart.com/unidac/)** para la conectividad universal de bases de datos.

> **Nota sobre Licencias:**
> El código fuente de *DBComparer* se distribuye bajo la licencia **MIT**, lo que te permite modificarlo y usarlo libremente.
>
> Sin embargo, **para compilar este proyecto necesitas tener una licencia válida comercial de Devart UniDAC** instalada en tu entorno Delphi. Los archivos fuente de UniDAC (`.dcu`, `.pas`) **no** se incluyen en este repositorio.

---

## 🚀 Características

* **Multi-Motor:** Arquitectura modular que soporta:
    * **MySQL / MariaDB**
    * **PostgreSQL** (Soporte de esquemas)
    * **Oracle Database** (Soporte de TNS y Owners)
    * **Microsoft SQL Server** (Manejo de columnas Identity)
    * **Firebird / InterBase** (Soporte de Generadores y Dialectos)
* **Sincronización de Estructura (Schema Diff):**
    * Tablas (Creación, nuevas columnas, modificación de tipos, nulabilidad).
    * Índices (PK, Unique, índices secundarios).
    * Vistas, Procedimientos Almacenados, Funciones y Triggers.
    * Secuencias y Generadores (con estrategia de "crear si no existe").
* **Sincronización de Datos (Data Diff):**
    * **Modo Copia (`--with-data`):** Volcado masivo de datos (`INSERT`).
    * **Modo Sincronización (`--with-data-diff`):** Comparación inteligente registro a registro basada en Primary Keys para generar `INSERT`, `UPDATE` o `DELETE`.
* **Seguridad y Control:**
    * Opción `--nodelete` para evitar borrados accidentales en destino.
    * Listas blancas (`--include-tables`) y negras (`--exclude-tables`) para sincronizar solo lo que necesitas.

---

## 🛠️ Compilación

1.  Abre el proyecto en **Delphi** (Compatible con versiones recientes: 10.4, 11, 12).
2.  Asegúrate de tener los componentes **Devart UniDAC** instalados en el IDE.
3.  Selecciona el archivo `.dpr` correspondiente al motor que deseas compilar:
    * `DBComparer.dpr` (MySQL/MariaDB)
    * `DBComparerSQLServer.dpr` (SQL Server)
    * `DBComparerOracle.dpr` (Oracle)
    * `DBComparerPostGre.dpr` (PostgreSQL)
    * `DBComparerInterbase.dpr` (InterBase/Firebird)
4.  Compila el proyecto en modo **Release** (Win32 o Win64).

---

## 📖 Uso y Ejemplos

La sintaxis general es:
bash
Ejecutable.exe Origen Destino [Opciones]

Formato de conexión estándar: servidor:puerto\base_datos usuario\password
🐬 MySQL / MariaDB
Bash

DBComparer.exe localhost:3306\db_prod root\pass localhost:3306\db_dev root\pass --with-data-diff

🐘 PostgreSQL

Soporta especificar el esquema (por defecto public).
Bash

# Formato: servidor:puerto\base\esquema
DBComparerPostGre.exe localhost:5432\ventas\public postgres\pass localhost:5432\ventas\test postgres\pass

🔴 Oracle Database

Soporta conexión directa, TNS Names y separación de Usuario vs Owner.
Bash

# Conexión directa: host:port/SID user/pass@Owner
DBComparerOracle.exe 192.168.1.10:1521/ORCL system/pass@HR 192.168.1.20:1521/ORCL system/pass@HR_TEST

# Usando TNS Names: //TNSName user/pass (Owner se asume igual al user si se omite)
DBComparerOracle.exe //PROD_DB system/pass //TEST_DB system/pass

🔥 InterBase / Firebird

Soporta rutas locales y servidores remotos.
Bash

# Servidor remoto
DBComparerInterbase.exe 192.168.1.50:3050\C:\Data\prod.gdb sysdba\masterkey 192.168.1.50:3050\C:\Data\test.gdb sysdba\masterkey

# Archivo local (modo embebido o local)
DBComparerInterbase.exe localhost\C:\Data\prod.gdb sysdba\masterkey localhost\C:\Data\test.gdb sysdba\masterkey

🟦 SQL Server
Bash

DBComparerSQLServer.exe sqlserver:1433\Produccion sa\pass sqlserver:1433\Desarrollo sa\pass --nodelete

⚙️ Opciones de Línea de Comandos
Opción	Descripción
--nodelete	Modo Seguro: No elimina tablas, columnas, índices ni registros en el destino, incluso si no existen en el origen.
--with-triggers	Incluye la comparación y recreación de Triggers.
--with-data	Realiza una copia de datos (INSERT). Útil para poblar tablas vacías.
--with-data-diff	Sincronización bidireccional inteligente: compara por PK. Realiza INSERT para nuevos, UPDATE para cambiados y DELETE para obsoletos (salvo si usas --nodelete).
--include-tables=t1,t2	Lista Blanca: Solo procesa las tablas especificadas.
--exclude-tables=t1,t2	Lista Negra: Procesa todo excepto las tablas especificadas.

📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.

⚠️ Disclaimer

Este software se proporciona "tal cual", sin garantía de ningún tipo, expresa o implícita. Úsalo bajo tu propia responsabilidad. Se recomienda encarecidamente realizar copias de seguridad de la base de datos de destino antes de ejecutar cualquier script de sincronización en entornos de producción críticos.
