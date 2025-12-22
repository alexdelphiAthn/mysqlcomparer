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
  end;
end;

initialization
  InitResources;

end.