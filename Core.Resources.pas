unit Core.Resources;

interface

uses
  System.SysUtils,
  System.Classes
  {$IFDEF MSWINDOWS}
  , Winapi.Windows
  {$ENDIF};

type
  TRes = class
  public
    // Cabeceras y General
    class var UsageHeader: string;
    class var UsageNotePort: string;
    class var UsageFormat: string;
    class var UsageTNS: string;
    class var OptionsHeader: string;
    class var ExamplesHeader: string;
    class var FooterFile: string;
    class var GeneratedHeader: string;
    class var UsageExampleCmd: string;

    // Opciones CLI
    class var OptNoDelete: string;
    class var OptTriggers: string;
    class var OptWithData: string;
    class var OptDataDiff: string;
    class var OptExclude: string;
    class var OptInclude: string;
    class var OptExcludeDesc: string;
    class var OptIncludeDesc: string;

    // Mensajes del Motor (Engine)
    class var MsgCopyAllData: string;
    class var MsgWarnNoPK: string;
    class var MsgNewTable: string;
    class var MsgTableDeleted: string;
    class var MsgAddColumn: string;
    class var MsgModColumn: string;
    class var MsgDelColumn: string;
    class var MsgAddIndex: string;
    class var MsgModIndex: string;
    class var MsgDelIndex: string;
    class var MsgSeqCreated: string;
    class var MsgSeqDeleted: string;
    class var MsgSyncData: string;
    class var MsgInsertNew: string;
    class var MsgUpdateDiff: string;
    class var MsgDeleteObs: string;
    class var MsgHeaderViews:string;
    class var MsgRecreateView: string;
    class var MsgRecreateProc: string;
    class var MsgHeaderFunc: string;
    class var MsgRecreateFunc: string;
    class var MsgWithIdentity: string;
    class var MsgHeaderProcs: string;

    // Triggers
    class var MsgHeaderTrig: string;
    class var MsgTriggerDel: string;
    class var MsgTriggerMod: string;
    class var MsgTriggerNew: string;

    //Sequences
    class var MsgHeaderSequences:string;
    class var MsgSeqCreate: string;
    class var MsgSeqDrop: string;
    // Específicos de Oracle
    class var UsageOracleCmd: string;      // El ejemplo de comando principal
    class var UsageOracleOwner: string;    // Nota sobre owner
    class var UsageOracleTNS: string;      // Nota sobre TNS
    class var HeaderConnFormats: string;   // Cabecera "Formatos de conexión"

    // Líneas de formatos de conexión (Descripción + Ejemplo)
    class var FmtOracleDirect: string;
    class var FmtOracleTNS: string;
    class var FmtOracleDefPort: string;

    // Notas específicas SQL Server
    class var MsgSQLDefInstance: string;
    class var MsgSQLWinAuth: string;

    // Ejemplos específicos SQL Server (Format Strings)
    class var ExSQLNamedInst: string; // Ejemplo SQLEXPRESS
    class var ExSQLStd: string;       // Ejemplo Estándar
    class var ExSQLWinAuth: string;   // Ejemplo Windows Auth
    class var ExSQLFilter: string;    // Ejemplo Include Tables

    // Específicos InterBase / Firebird
    class var UsageIBCmd: string;      // Comando de uso principal
    class var MsgIBLocal: string;      // Nota base local
    class var MsgIBEmbedded: string;   // Nota base embebida

    // Ejemplos InterBase
    class var ExIBFull: string;        // Ejemplo completo (localhost:3050)
    class var ExIBServer: string;      // Ejemplo servidor sin puerto
    class var ExIBEmbedded: string;    // Ejemplo embebido
    class var ExIBFilter: string;      // Ejemplo filtro tablas
  end;

implementation

procedure InitResources;
var
  IsSpanish: Boolean;
  LangID: Integer;
begin
  IsSpanish := False;

  // Detección del idioma del sistema
  {$IFDEF MSWINDOWS}
  LangID := GetUserDefaultLangID and $3FF; // Máscara para obtener idioma primario
  IsSpanish := (LangID = $0A); // $0A es Español
  {$ENDIF}

  // O usar SysUtils para cross-platform:
  if SameText(Copy(GetEnvironmentVariable('LANG'), 1, 2), 'es') then
    IsSpanish := True;

  if IsSpanish then
  begin
    // --- ESPAÑOL (Tus textos originales) ---
    TRes.UsageHeader := 'Uso:';
    TRes.UsageNotePort := 'Nota: Puerto por defecto es %d si se omite';
    TRes.UsageFormat := '      Para especificar schema: database\schema (por defecto: public)';
    TRes.UsageTNS := '      Para TNS: //tnsname usuario/password';
    TRes.OptionsHeader := 'Opciones:';
    TRes.ExamplesHeader := 'Ejemplos:';
    TRes.FooterFile := 'El resultado se imprime por la salida estándar. Para guardarlo en archivo:';
    TRes.GeneratedHeader := 'SCRIPT DE SINCRONIZACIÓN (Generado: %s)';
    TRes.MsgWarnNoPK := 'ADVERTENCIA: %s no tiene PK. Se omite sincronización de datos.';
    TRes.UsageExampleCmd := '  %s servidor1:puerto1\database1 usuario1\password1 ' +
                            'servidor2:puerto2\database2 usuario2\password2 [opciones]';

    TRes.OptNoDelete := 'No elimina tablas, columnas ni índices en destino';
    TRes.OptTriggers := 'Incluye comparación de triggers';
    TRes.OptWithData := 'Copia todos los datos de origen a destino (INSERT)';
    TRes.OptDataDiff := 'Sincroniza datos comparando por clave primaria (INSERT/UPDATE/DELETE)';
    TRes.OptExclude := 'Excluye tablas específicas de la sincronización de datos';
    TRes.OptInclude := 'Solo sincroniza datos de estas tablas';
    TRes.OptExcludeDesc := '(Lista Negra: Sincroniza todo MENOS esto)';
    TRes.OptIncludeDesc := '(Lista Blanca: Solo sincroniza ESTO, ignora el resto)';

    TRes.MsgNewTable := 'Tabla nueva: ';
    TRes.MsgTableDeleted := 'Tabla eliminada: ';
    TRes.MsgAddColumn := 'Agregar columna: ';
    TRes.MsgModColumn := 'Modificar columna: ';
    TRes.MsgDelColumn := 'Eliminar columna: ';
    TRes.MsgAddIndex := 'Agregar índice: ';
    TRes.MsgModIndex := 'Modificar índice: ';
    TRes.MsgDelIndex := 'Eliminar índice: ';
    TRes.MsgSeqCreated := 'Crear secuencia faltante: ';
    TRes.MsgSeqDeleted := 'Eliminar secuencia obsoleta: ';
    TRes.MsgSyncData     := 'Sincronizando datos: ';
    TRes.MsgWithIdentity := ' (Con Identidad)';

    TRes.MsgSyncData := 'Sincronizando datos: ';
    TRes.MsgCopyAllData := 'Copiando datos completos: ';
    TRes.MsgInsertNew := 'Insertar registro nuevo (PK: %s)';
    TRes.MsgUpdateDiff := 'Actualizar diferencias (PK: %s)';
    TRes.MsgDeleteObs := 'Eliminar registro obsoleto (PK: %s)';

    TRes.MsgHeaderViews := '=== VISTAS ===';
    TRes.MsgRecreateView := 'Recreando vista: ';
    TRes.MsgHeaderProcs := '=== PROCEDIMIENTOS ===';
    TRes.MsgRecreateProc := 'Recreando procedimiento: ';
    TRes.MsgHeaderFunc := '=== FUNCIONES ===';
    TRes.MsgRecreateFunc := 'Recreando función: ';
    TRes.MsgHeaderTrig := '=== TRIGGERS ===';
    TRes.MsgTriggerDel := 'Eliminar trigger: ';
    TRes.MsgTriggerMod := 'Modificar trigger: ';
    TRes.MsgTriggerNew := 'Crear trigger: ';

    TRes.MsgHeaderSequences:= '=== SECUENCIAS / GENERADORES ===';
    TRes.MsgSeqCreate := 'Crear secuencia faltante: ';
    TRes.MsgSeqDrop   := 'Eliminar secuencia obsoleta: ';
    // ORACLE - ESPAÑOL
    TRes.UsageOracleCmd := '  %s servidor1:puerto1/sid1 usuario1/password1 ' +
                           'servidor2:puerto2/sid2 usuario2/password2 [opciones]';

    TRes.UsageOracleOwner := '      Para especificar owner/schema: usuario/password@owner';
    TRes.UsageOracleTNS   := '      Para TNS: //tnsname usuario/password';

    TRes.HeaderConnFormats := 'Formatos de conexión:';

    // Mantenemos el espaciado para que se alinee bonito en consola
    TRes.FmtOracleDirect  := '  servidor:puerto/sid        Conexión directa (ej: localhost:1521/ORCL)';
    TRes.FmtOracleTNS     := '  //tnsname                  Usando TNS Names (ej: //PROD_DB)';
    TRes.FmtOracleDefPort := '  servidor/sid               Puerto por defecto 1521';

    TRes.MsgSQLDefInstance := 'Nota: Para instancia por defecto, usar solo servidor\database';
    TRes.MsgSQLWinAuth     := '      Para autenticación Windows, usar usuario: (vacío) o "Windows"';

    // Ejemplos (Con nombres en español)
    TRes.ExSQLNamedInst := '  %s localhost\SQLEXPRESS\midb_prod sa\pass123 ' +
                           'localhost\SQLEXPRESS\midb_dev sa\pass456 --nodelete --with-triggers';
    TRes.ExSQLStd       := '  %s servidor1\midb usuario\pass ' +
                           'servidor2\midb usuario\pass --with-data-diff --nodelete';
    TRes.ExSQLWinAuth   := '  %s localhost\midb Windows\ ' +
                           'localhost\midb_test Windows\ --with-data-diff';
    TRes.ExSQLFilter    := '  %s ... --with-data-diff --include-tables=Clientes,Productos';
    TRes.UsageIBCmd := '  %s servidor1:puerto1\database1.gdb usuario1\password1 '+
                       'servidor2:puerto2\database2.gdb usuario2\password2 [opciones]';
    TRes.MsgIBLocal    := '      Para base de datos local: localhost\C:\ruta\database.gdb';
    TRes.MsgIBEmbedded := '      Para base de datos embebida: \C:\ruta\database.gdb (sin servidor)';

    // Ejemplos
    TRes.ExIBFull     := '  %s localhost:3050\C:\DB\prod.gdb SYSDBA\masterkey '+
                         'localhost:3050\C:\DB\dev.gdb SYSDBA\masterkey --nodelete --with-triggers';
    TRes.ExIBServer   := '  %s servidor1\C:\DB\midb.gdb usuario\pass '+
                         'servidor2\C:\DB\midb.gdb usuario\pass --with-data-diff --nodelete';
    TRes.ExIBEmbedded := '  %s \C:\DB\local.gdb SYSDBA\masterkey '+
                         '\C:\DB\local_test.gdb SYSDBA\masterkey --with-data-diff';
    TRes.ExIBFilter   := '  %s ... --with-data-diff --include-tables=CLIENTES,PRODUCTOS';
  end
  else
  begin
    // --- ENGLISH (Default) ---
    TRes.UsageHeader := 'Usage:';
    TRes.UsageNotePort := 'Note: Default port is %d if omitted';
    TRes.UsageFormat := '      To specify schema: database\schema (default: public)';
    TRes.UsageTNS := '      For TNS: //tnsname user/password';
    TRes.OptionsHeader := 'Options:';
    TRes.ExamplesHeader := 'Examples:';
    TRes.FooterFile := 'Output is printed to StdOut. To save to file:';
    TRes.GeneratedHeader := 'SYNCHRONIZATION SCRIPT (Generated: %s)';
    TRes.MsgWarnNoPK := 'WARNING: %s has no PK. Skipping data synchronization.';
    TRes.UsageExampleCmd := '  %s server1:port1\database1 user1\password1 ' +
                            'server2:port2\database2 user2\password2 [options]';

    TRes.OptNoDelete := 'Do not drop tables, columns, or indexes in target';
    TRes.OptTriggers := 'Include triggers comparison';
    TRes.OptWithData := 'Copy all data from source to target (INSERT)';
    TRes.OptDataDiff := 'Sync data comparing by Primary Key (INSERT/UPDATE/DELETE)';
    TRes.OptExclude := 'Exclude specific tables from data sync';
    TRes.OptInclude := 'Only sync data for these specific tables';
    TRes.OptExcludeDesc := '(Blacklist: Sync everything EXCEPT these)';
    TRes.OptIncludeDesc := '(Whitelist: Only sync THESE, ignore others)';

    TRes.MsgNewTable := 'New table: ';
    TRes.MsgTableDeleted := 'Table dropped: ';
    TRes.MsgAddColumn := 'Add column: ';
    TRes.MsgModColumn := 'Modify column: ';
    TRes.MsgDelColumn := 'Drop column: ';
    TRes.MsgAddIndex := 'Add index: ';
    TRes.MsgModIndex := 'Modify index: ';
    TRes.MsgDelIndex := 'Drop index: ';
    TRes.MsgSeqCreated := 'Create missing sequence: ';
    TRes.MsgSeqDeleted := 'Drop obsolete sequence: ';

    TRes.MsgCopyAllData := 'Copying all data: ';
    TRes.MsgSyncData := 'Synchronizing data: ';
    TRes.MsgInsertNew := 'Insert new record (PK: %s)';
    TRes.MsgUpdateDiff := 'Update differences (PK: %s)';
    TRes.MsgDeleteObs := 'Delete obsolete record (PK: %s)';
    TRes.MsgSyncData     := 'Synchronizing data: ';
    TRes.MsgWithIdentity := ' (With Identity)';

    TRes.MsgHeaderViews := '=== VIEWS ===';
    TRes.MsgRecreateView := 'Recreating view: ';
    TRes.MsgHeaderProcs := '=== PROCEDURES ===';
    TRes.MsgRecreateProc := 'Recreating procedure: ';
    TRes.MsgHeaderFunc := '=== FUNCTIONS ===';
    TRes.MsgRecreateFunc := 'Recreating function: ';
    TRes.MsgHeaderTrig := '=== TRIGGERS ===';
    TRes.MsgTriggerDel := 'Drop trigger: ';
    TRes.MsgTriggerMod := 'Modify trigger: ';
    TRes.MsgTriggerNew := 'Create trigger: ';

    TRes.MsgHeaderSequences := '=== SEQUENCES / GENERATORS ===';
    TRes.MsgSeqCreate := 'Create missing sequence: ';
    TRes.MsgSeqDrop   := 'Drop obsolete sequence: ';
    // ORACLE - ENGLISH
    TRes.UsageOracleCmd := '  %s server1:port1/sid1 user1/password1 ' +
                           'server2:port2/sid2 user2/password2 [options]';

    TRes.UsageOracleOwner := '      To specify owner/schema: user/password@owner';
    TRes.UsageOracleTNS   := '      For TNS: //tnsname user/password';

    TRes.HeaderConnFormats := 'Connection formats:';

    TRes.FmtOracleDirect  := '  server:port/sid            Direct connection (ex: localhost:1521/ORCL)';
    TRes.FmtOracleTNS     := '  //tnsname                  Using TNS Names (ex: //PROD_DB)';
    TRes.FmtOracleDefPort := '  server/sid                 Default port 1521';

    TRes.MsgSQLDefInstance := 'Note: For default instance, use only server\database';
    TRes.MsgSQLWinAuth     := '      For Windows Authentication, use user: (empty) or "Windows"';

    // Ejemplos (Con nombres en inglés para mayor coherencia)
    TRes.ExSQLNamedInst := '  %s localhost\SQLEXPRESS\midb_prod sa\pass123 ' +
                           'localhost\SQLEXPRESS\midb_dev sa\pass456 --nodelete --with-triggers';
    TRes.ExSQLStd       := '  %s server1\midb user\pass ' +
                           'server2\midb user\pass --with-data-diff --nodelete';
    TRes.ExSQLWinAuth   := '  %s localhost\midb Windows\ ' +
                           'localhost\midb_test Windows\ --with-data-diff';
    TRes.ExSQLFilter    := '  %s ... --with-data-diff --include-tables=Customers,Products';

    TRes.UsageIBCmd := '  %s server1:port1\database1.gdb user1\password1 '+
                       'server2:port2\database2.gdb user2\password2 [options]';

    TRes.MsgIBLocal    := '      For local database: localhost\C:\path\database.gdb';
    TRes.MsgIBEmbedded := '      For embedded database: \C:\path\database.gdb (no server)';

    // Ejemplos (Standard paths and user names adapted)
    TRes.ExIBFull     := '  %s localhost:3050\C:\DB\prod.gdb SYSDBA\masterkey '+
                         'localhost:3050\C:\DB\dev.gdb SYSDBA\masterkey --nodelete --with-triggers';

    TRes.ExIBServer   := '  %s server1\C:\DB\mydb.gdb user\pass '+
                         'server2\C:\DB\mydb.gdb user\pass --with-data-diff --nodelete';

    TRes.ExIBEmbedded := '  %s \C:\DB\local.gdb SYSDBA\masterkey '+
                         '\C:\DB\local_test.gdb SYSDBA\masterkey --with-data-diff';

    TRes.ExIBFilter   := '  %s ... --with-data-diff --include-tables=CUSTOMERS,PRODUCTS';
  end;
end;

initialization
  InitResources;

end.