DBComparer

DBComparer es una herramienta de línea de comandos potente y modular escrita en Delphi para comparar y sincronizar esquemas y datos entre bases de datos heterogéneas.

Diseñado para DBAs y desarrolladores que necesitan desplegar cambios o mantener entornos sincronizados (Desarrollo ➡️ Producción) de forma automatizada.

⚠️ Requisito Importante (Dependencias)

Este proyecto utiliza Devart UniDAC para la conectividad universal de bases de datos.

    Nota sobre Licencias: El código fuente de DBComparer se distribuye bajo la licencia MIT, lo que te permite modificarlo y usarlo libremente.

    Sin embargo, para compilar este proyecto necesitas tener una licencia válida comercial de Devart UniDAC instalada en tu entorno Delphi. Los archivos fuente de UniDAC no se incluyen en este repositorio.

 🚀 Características

    Multi-Motor: Arquitectura modular que soporta:

        MySQL / MariaDB

        PostgreSQL

        Microsoft SQL Server

        Oracle Database

        Firebird / InterBase

    Sincronización de Estructura (Schema Diff):

        Tablas (Creación, nuevas columnas, modificación de tipos).

        Índices (PK, Unique, índices secundarios).

        Vistas, Procedimientos Almacenados, Funciones y Triggers.

        Secuencias y Generadores.

    Sincronización de Datos (Data Diff):

        Copia masiva de datos (INSERT).

        Sincronización inteligente (INSERT / UPDATE / DELETE) basada en Primary Keys.

    Seguridad: Opciones para evitar borrados accidentales (--nodelete).

    Filtrado: Listas blancas (--include-tables) y negras (--exclude-tables) para control granular.

🛠️ Compilación

    Abre el proyecto en Delphi (Probado en versiones recientes como 10.4 Sydney, 11 Alexandria o 12 Athens).

    Asegúrate de tener los componentes UniDAC instalados.

    Selecciona el archivo .dpr correspondiente a tu motor (o el genérico si unificas):

        DBComparer.dpr (MySQL)

        DBComparerSQLServer.dpr

        DBComparerOracle.dpr

        DBComparerPostGre.dpr

        DBComparerInterbase.dpr

    Compila en modo Release.

📖 Uso

La sintaxis general es:
Bash

DBComparer.exe Origen Destino [Opciones]

Formato de Conexión

    Origen/Destino: servidor:puerto\base_datos usuario\password

Ejemplos por Motor

MySQL / MariaDB:

DBComparer.exe localhost:3306\db_prod root\pass localhost:3306\db_dev root\pass --with-data-diff

PostgreSQL: (Soporta esquemas)
Bash

# Formato: servidor:puerto\base\schema
DBComparerPostGre.exe localhost:5432\ventas\public postgres\pass localhost:5432\ventas\test postgres\pass

Oracle: (Soporta TNS y Owner explícito)
Bash

# Conexión directa: host:port/SID user/pass@Owner
DBComparerOracle.exe 192.168.1.10:1521/ORCL system/pass@HR 192.168.1.20:1521/ORCL system/pass@HR_TEST

# Usando TNS Names: //TNSName user/pass
DBComparerOracle.exe //PROD_DB system/pass //TEST_DB system/pass

SQL Server:
Bash

DBComparerSQLServer.exe sqlserver:1433\Produccion sa\pass sqlserver:1433\Desarrollo sa\pass

Opciones Disponibles
Opción	Descripción
--nodelete	Seguridad: No elimina tablas, columnas ni índices en el destino, incluso si no existen en el origen.
--with-triggers	Incluye la comparación y sincronización de Triggers.
--with-data	Realiza una copia masiva de datos (ideal para tablas vacías en destino).
--with-data-diff	Sincronización inteligente: Compara registros por PK para hacer INSERT, UPDATE o DELETE.
--include-tables=t1,t2	Solo procesa las tablas especificadas (separadas por comas).
--exclude-tables=t1,t2	Procesa todo excepto las tablas especificadas.

📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.

⚠️ Disclaimer

Este software se proporciona "tal cual", sin garantía de ningún tipo. Úsalo bajo tu propia responsabilidad. Se recomienda encarecidamente realizar copias de seguridad de la base de datos de destino antes de ejecutar cualquier script de sincronización en entornos de producción.
