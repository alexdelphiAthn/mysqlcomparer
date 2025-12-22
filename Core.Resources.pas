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
    class var MsgHeaderViews: string;
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

    // Sequences
    class var MsgHeaderSequences: string;
    class var MsgSeqCreate: string;
    class var MsgSeqDrop: string;

    // Específicos de Oracle
    class var UsageOracleCmd: string;
    class var UsageOracleOwner: string;
    class var UsageOracleTNS: string;
    class var HeaderConnFormats: string;
    class var FmtOracleDirect: string;
    class var FmtOracleTNS: string;
    class var FmtOracleDefPort: string;

    // Notas específicas SQL Server
    class var MsgSQLDefInstance: string;
    class var MsgSQLWinAuth: string;
    class var ExSQLNamedInst: string;
    class var ExSQLStd: string;
    class var ExSQLWinAuth: string;
    class var ExSQLFilter: string;

    // Específicos InterBase / Firebird
    class var UsageIBCmd: string;
    class var MsgIBLocal: string;
    class var MsgIBEmbedded: string;
    class var ExIBFull: string;
    class var ExIBServer: string;
    class var ExIBEmbedded: string;
    class var ExIBFilter: string;

    // Específicos PostgreSQL
    class var UsagePGCmd: string;
    class var MsgPGSchema: string;
    class var ExPGFull: string;
    class var ExPGSchema: string;
    class var ExPGSimple: string;
    class var ExPGFilter: string;
  end;

implementation

procedure InitResources;
var
  LangCode: string;
  LangID: Integer;
begin
  LangCode := 'en'; // Default

  // Detección del idioma del sistema (Windows)
  {$IFDEF MSWINDOWS}
  LangID := GetUserDefaultLangID and $3FF;
  case LangID of
    $0A: LangCode := 'es'; // Español
    $0C: LangCode := 'fr'; // Francés
    $07: LangCode := 'de'; // Alemán
    $04: LangCode := 'zh'; // Chino
    $12: LangCode := 'ko'; // Coreano
    $01: LangCode := 'ar'; // Árabe
    $1A: LangCode := 'hr'; // Croata
  end;
  {$ENDIF}

  // Cross-platform detection override (Linux/macOS)
  if GetEnvironmentVariable('LANG') <> '' then
    LangCode := LowerCase(Copy(GetEnvironmentVariable('LANG'), 1, 2));

  // ============================================================================
  // ESPAÑOL
  // ============================================================================
  if LangCode = 'es' then
  begin
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
    TRes.MsgSyncData := 'Sincronizando datos: ';
    TRes.MsgWithIdentity := ' (Con Identidad)';
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
    TRes.MsgHeaderSequences := '=== SECUENCIAS / GENERADORES ===';
    TRes.MsgSeqCreate := 'Crear secuencia faltante: ';
    TRes.MsgSeqDrop := 'Eliminar secuencia obsoleta: ';
    TRes.UsageOracleCmd := '  %s servidor1:puerto1/sid1 usuario1/password1 ' +
                           'servidor2:puerto2/sid2 usuario2/password2 [opciones]';
    TRes.UsageOracleOwner := '      Para especificar owner/schema: usuario/password@owner';
    TRes.UsageOracleTNS := '      Para TNS: //tnsname usuario/password';
    TRes.HeaderConnFormats := 'Formatos de conexión:';
    TRes.FmtOracleDirect := '  servidor:puerto/sid            Conexión directa (ej: localhost:1521/ORCL)';
    TRes.FmtOracleTNS := '  //tnsname                      Usando TNS Names (ej: //PROD_DB)';
    TRes.FmtOracleDefPort := '  servidor/sid                   Puerto por defecto 1521';
    TRes.MsgSQLDefInstance := 'Nota: Para instancia por defecto, usar solo servidor\database';
    TRes.MsgSQLWinAuth := '      Para autenticación Windows, usar usuario: (vacío) o "Windows"';
    TRes.ExSQLNamedInst := '  %s localhost\SQLEXPRESS\midb_prod sa\pass123 ' +
                           'localhost\SQLEXPRESS\midb_dev sa\pass456 --nodelete --with-triggers';
    TRes.ExSQLStd := '  %s servidor1\midb usuario\pass servidor2\midb usuario\pass --with-data-diff --nodelete';
    TRes.ExSQLWinAuth := '  %s localhost\midb Windows\ localhost\midb_test Windows\ --with-data-diff';
    TRes.ExSQLFilter := '  %s ... --with-data-diff --include-tables=Clientes,Productos';
    TRes.UsageIBCmd := '  %s servidor1:puerto1\database1.gdb usuario1\password1 '+
                       'servidor2:puerto2\database2.gdb usuario2\password2 [opciones]';
    TRes.MsgIBLocal := '      Para base de datos local: localhost\C:\ruta\database.gdb';
    TRes.MsgIBEmbedded := '      Para base de datos embebida: \C:\ruta\database.gdb (sin servidor)';
    TRes.ExIBFull := '  %s localhost:3050\C:\DB\prod.gdb SYSDBA\masterkey '+
                     'localhost:3050\C:\DB\dev.gdb SYSDBA\masterkey --nodelete --with-triggers';
    TRes.ExIBServer := '  %s servidor1\C:\DB\midb.gdb usuario\pass '+
                       'servidor2\C:\DB\midb.gdb usuario\pass --with-data-diff --nodelete';
    TRes.ExIBEmbedded := '  %s \C:\DB\local.gdb SYSDBA\masterkey '+
                         '\C:\DB\local_test.gdb SYSDBA\masterkey --with-data-diff';
    TRes.ExIBFilter := '  %s ... --with-data-diff --include-tables=CLIENTES,PRODUCTOS';
    TRes.UsagePGCmd := '  %s servidor1:puerto1\database1 usuario1\password1 '+
                       'servidor2:puerto2\database2 usuario2\password2 [opciones]';
    TRes.MsgPGSchema := '      Para especificar schema: database\schema (por defecto: public)';
    TRes.ExPGFull := '  %s localhost:5432\midb_prod postgres\pass123 '+
                     'localhost:5432\midb_dev postgres\pass456 --nodelete --with-triggers';
    TRes.ExPGSchema := '  %s servidor1:5432\midb\public usuario\pass '+
                       'servidor2:5432\midb\test_schema usuario\pass --with-data-diff --nodelete';
    TRes.ExPGSimple := '  %s localhost\midb postgres\pass localhost\midb_test postgres\pass --with-data-diff';
    TRes.ExPGFilter := '  %s ... --with-data-diff --include-tables=clientes,productos';
  end
  // ============================================================================
  // FRANÇAIS
  // ============================================================================
  else if LangCode = 'fr' then
  begin
    TRes.UsageHeader := 'Utilisation :';
    TRes.UsageNotePort := 'Note : Le port par défaut est %d si omis';
    TRes.UsageFormat := '      Pour spécifier le schéma : base\schéma (par défaut : public)';
    TRes.UsageTNS := '      Pour TNS : //tnsname utilisateur/motdepasse';
    TRes.OptionsHeader := 'Options :';
    TRes.ExamplesHeader := 'Exemples :';
    TRes.FooterFile := 'Le résultat est affiché sur la sortie standard. Pour l''enregistrer dans un fichier :';
    TRes.GeneratedHeader := 'SCRIPT DE SYNCHRONISATION (Généré : %s)';
    TRes.MsgWarnNoPK := 'AVERTISSEMENT : %s n''a pas de clé primaire. Synchronisation des données ignorée.';
    TRes.UsageExampleCmd := '  %s serveur1:port1\base1 utilisateur1\motdepasse1 ' +
                            'serveur2:port2\base2 utilisateur2\motdepasse2 [options]';
    TRes.OptNoDelete := 'Ne supprime pas les tables, colonnes ou index dans la cible';
    TRes.OptTriggers := 'Inclut la comparaison des déclencheurs';
    TRes.OptWithData := 'Copie toutes les données de la source vers la cible (INSERT)';
    TRes.OptDataDiff := 'Synchronise les données en comparant par clé primaire (INSERT/UPDATE/DELETE)';
    TRes.OptExclude := 'Exclut des tables spécifiques de la synchronisation des données';
    TRes.OptInclude := 'Synchronise uniquement les données de ces tables';
    TRes.OptExcludeDesc := '(Liste noire : Synchronise tout SAUF ceci)';
    TRes.OptIncludeDesc := '(Liste blanche : Synchronise uniquement CECI, ignore le reste)';
    TRes.MsgNewTable := 'Nouvelle table : ';
    TRes.MsgTableDeleted := 'Table supprimée : ';
    TRes.MsgAddColumn := 'Ajouter colonne : ';
    TRes.MsgModColumn := 'Modifier colonne : ';
    TRes.MsgDelColumn := 'Supprimer colonne : ';
    TRes.MsgAddIndex := 'Ajouter index : ';
    TRes.MsgModIndex := 'Modifier index : ';
    TRes.MsgDelIndex := 'Supprimer index : ';
    TRes.MsgSeqCreated := 'Créer séquence manquante : ';
    TRes.MsgSeqDeleted := 'Supprimer séquence obsolète : ';
    TRes.MsgSyncData := 'Synchronisation des données : ';
    TRes.MsgWithIdentity := ' (Avec identité)';
    TRes.MsgCopyAllData := 'Copie complète des données : ';
    TRes.MsgInsertNew := 'Insérer nouvel enregistrement (PK : %s)';
    TRes.MsgUpdateDiff := 'Mettre à jour les différences (PK : %s)';
    TRes.MsgDeleteObs := 'Supprimer enregistrement obsolète (PK : %s)';
    TRes.MsgHeaderViews := '=== VUES ===';
    TRes.MsgRecreateView := 'Recréation de la vue : ';
    TRes.MsgHeaderProcs := '=== PROCÉDURES ===';
    TRes.MsgRecreateProc := 'Recréation de la procédure : ';
    TRes.MsgHeaderFunc := '=== FONCTIONS ===';
    TRes.MsgRecreateFunc := 'Recréation de la fonction : ';
    TRes.MsgHeaderTrig := '=== DÉCLENCHEURS ===';
    TRes.MsgTriggerDel := 'Supprimer déclencheur : ';
    TRes.MsgTriggerMod := 'Modifier déclencheur : ';
    TRes.MsgTriggerNew := 'Créer déclencheur : ';
    TRes.MsgHeaderSequences := '=== SÉQUENCES / GÉNÉRATEURS ===';
    TRes.MsgSeqCreate := 'Créer séquence manquante : ';
    TRes.MsgSeqDrop := 'Supprimer séquence obsolète : ';
    TRes.UsageOracleCmd := '  %s serveur1:port1/sid1 utilisateur1/motdepasse1 ' +
                           'serveur2:port2/sid2 utilisateur2/motdepasse2 [options]';
    TRes.UsageOracleOwner := '      Pour spécifier owner/schéma : utilisateur/motdepasse@owner';
    TRes.UsageOracleTNS := '      Pour TNS : //tnsname utilisateur/motdepasse';
    TRes.HeaderConnFormats := 'Formats de connexion :';
    TRes.FmtOracleDirect := '  serveur:port/sid           Connexion directe (ex : localhost:1521/ORCL)';
    TRes.FmtOracleTNS := '  //tnsname                  Utilisation de TNS Names (ex : //PROD_DB)';
    TRes.FmtOracleDefPort := '  serveur/sid                Port par défaut 1521';
    TRes.MsgSQLDefInstance := 'Note : Pour l''instance par défaut, utiliser uniquement serveur\base';
    TRes.MsgSQLWinAuth := '      Pour l''authentification Windows, utiliser utilisateur : (vide) ou "Windows"';
    TRes.ExSQLNamedInst := '  %s localhost\SQLEXPRESS\mabase_prod sa\pass123 ' +
                           'localhost\SQLEXPRESS\mabase_dev sa\pass456 --nodelete --with-triggers';
    TRes.ExSQLStd := '  %s serveur1\mabase utilisateur\pass serveur2\mabase utilisateur\pass --with-data-diff --nodelete';
    TRes.ExSQLWinAuth := '  %s localhost\mabase Windows\ localhost\mabase_test Windows\ --with-data-diff';
    TRes.ExSQLFilter := '  %s ... --with-data-diff --include-tables=Clients,Produits';
    TRes.UsageIBCmd := '  %s serveur1:port1\base1.gdb utilisateur1\motdepasse1 '+
                       'serveur2:port2\base2.gdb utilisateur2\motdepasse2 [options]';
    TRes.MsgIBLocal := '      Pour base locale : localhost\C:\chemin\base.gdb';
    TRes.MsgIBEmbedded := '      Pour base embarquée : \C:\chemin\base.gdb (sans serveur)';
    TRes.ExIBFull := '  %s localhost:3050\C:\DB\prod.gdb SYSDBA\masterkey '+
                     'localhost:3050\C:\DB\dev.gdb SYSDBA\masterkey --nodelete --with-triggers';
    TRes.ExIBServer := '  %s serveur1\C:\DB\mabase.gdb utilisateur\pass '+
                       'serveur2\C:\DB\mabase.gdb utilisateur\pass --with-data-diff --nodelete';
    TRes.ExIBEmbedded := '  %s \C:\DB\local.gdb SYSDBA\masterkey '+
                         '\C:\DB\local_test.gdb SYSDBA\masterkey --with-data-diff';
    TRes.ExIBFilter := '  %s ... --with-data-diff --include-tables=CLIENTES,PRODUITS';
    TRes.UsagePGCmd := '  %s serveur1:port1\base1 utilisateur1\motdepasse1 '+
                       'serveur2:port2\base2 utilisateur2\motdepasse2 [options]';
    TRes.MsgPGSchema := '      Pour spécifier le schéma : base\schéma (par défaut : public)';
    TRes.ExPGFull := '  %s localhost:5432\mabase_prod postgres\pass123 '+
                     'localhost:5432\mabase_dev postgres\pass456 --nodelete --with-triggers';
    TRes.ExPGSchema := '  %s serveur1:5432\mabase\public utilisateur\pass '+
                       'serveur2:5432\mabase\schema_test utilisateur\pass --with-data-diff --nodelete';
    TRes.ExPGSimple := '  %s localhost\mabase postgres\pass localhost\mabase_test postgres\pass --with-data-diff';
    TRes.ExPGFilter := '  %s ... --with-data-diff --include-tables=clients,produits';
  end
  // ============================================================================
  // DEUTSCH
  // ============================================================================
  else if LangCode = 'de' then
  begin
    TRes.UsageHeader := 'Verwendung:';
    TRes.UsageNotePort := 'Hinweis: Standardport ist %d, wenn nicht angegeben';
    TRes.UsageFormat := '      Um Schema anzugeben: datenbank\schema (Standard: public)';
    TRes.UsageTNS := '      Für TNS: //tnsname benutzer/passwort';
    TRes.OptionsHeader := 'Optionen:';
    TRes.ExamplesHeader := 'Beispiele:';
    TRes.FooterFile := 'Die Ausgabe wird auf der Standardausgabe ausgegeben. Zum Speichern in Datei:';
    TRes.GeneratedHeader := 'SYNCHRONISATIONSSKRIPT (Erstellt: %s)';
    TRes.MsgWarnNoPK := 'WARNUNG: %s hat keinen Primärschlüssel. Datensynchronisation wird übersprungen.';
    TRes.UsageExampleCmd := '  %s server1:port1\datenbank1 benutzer1\passwort1 ' +
                            'server2:port2\datenbank2 benutzer2\passwort2 [optionen]';
    TRes.OptNoDelete := 'Löscht keine Tabellen, Spalten oder Indizes im Ziel';
    TRes.OptTriggers := 'Enthält Trigger-Vergleich';
    TRes.OptWithData := 'Kopiert alle Daten von Quelle zu Ziel (INSERT)';
    TRes.OptDataDiff := 'Synchronisiert Daten durch Vergleich des Primärschlüssels (INSERT/UPDATE/DELETE)';
    TRes.OptExclude := 'Schließt bestimmte Tabellen von der Datensynchronisation aus';
    TRes.OptInclude := 'Synchronisiert nur Daten dieser Tabellen';
    TRes.OptExcludeDesc := '(Schwarze Liste: Alles synchronisieren AUSSER dies)';
    TRes.OptIncludeDesc := '(Weiße Liste: Nur DIES synchronisieren, Rest ignorieren)';
    TRes.MsgNewTable := 'Neue Tabelle: ';
    TRes.MsgTableDeleted := 'Tabelle gelöscht: ';
    TRes.MsgAddColumn := 'Spalte hinzufügen: ';
    TRes.MsgModColumn := 'Spalte ändern: ';
    TRes.MsgDelColumn := 'Spalte löschen: ';
    TRes.MsgAddIndex := 'Index hinzufügen: ';
    TRes.MsgModIndex := 'Index ändern: ';
    TRes.MsgDelIndex := 'Index löschen: ';
    TRes.MsgSeqCreated := 'Fehlende Sequenz erstellen: ';
    TRes.MsgSeqDeleted := 'Veraltete Sequenz löschen: ';
    TRes.MsgSyncData := 'Daten synchronisieren: ';
    TRes.MsgWithIdentity := ' (Mit Identität)';
    TRes.MsgCopyAllData := 'Vollständige Datenkopie: ';
    TRes.MsgInsertNew := 'Neuen Datensatz einfügen (PK: %s)';
    TRes.MsgUpdateDiff := 'Unterschiede aktualisieren (PK: %s)';
    TRes.MsgDeleteObs := 'Veralteten Datensatz löschen (PK: %s)';
    TRes.MsgHeaderViews := '=== ANSICHTEN ===';
    TRes.MsgRecreateView := 'Ansicht neu erstellen: ';
    TRes.MsgHeaderProcs := '=== PROZEDUREN ===';
    TRes.MsgRecreateProc := 'Prozedur neu erstellen: ';
    TRes.MsgHeaderFunc := '=== FUNKTIONEN ===';
    TRes.MsgRecreateFunc := 'Funktion neu erstellen: ';
    TRes.MsgHeaderTrig := '=== TRIGGER ===';
    TRes.MsgTriggerDel := 'Trigger löschen: ';
    TRes.MsgTriggerMod := 'Trigger ändern: ';
    TRes.MsgTriggerNew := 'Trigger erstellen: ';
    TRes.MsgHeaderSequences := '=== SEQUENZEN / GENERATOREN ===';
    TRes.MsgSeqCreate := 'Fehlende Sequenz erstellen: ';
    TRes.MsgSeqDrop := 'Veraltete Sequenz löschen: ';
    TRes.UsageOracleCmd := '  %s server1:port1/sid1 benutzer1/passwort1 ' +
                           'server2:port2/sid2 benutzer2/passwort2 [optionen]';
    TRes.UsageOracleOwner := '      Um Owner/Schema anzugeben: benutzer/passwort@owner';
    TRes.UsageOracleTNS := '      Für TNS: //tnsname benutzer/passwort';
    TRes.HeaderConnFormats := 'Verbindungsformate:';
    TRes.FmtOracleDirect := '  server:port/sid            Direkte Verbindung (z.B.: localhost:1521/ORCL)';
    TRes.FmtOracleTNS := '  //tnsname                  Mit TNS Names (z.B.: //PROD_DB)';
    TRes.FmtOracleDefPort := '  server/sid                 Standardport 1521';
    TRes.MsgSQLDefInstance := 'Hinweis: Für Standardinstanz nur server\datenbank verwenden';
    TRes.MsgSQLWinAuth := '      Für Windows-Authentifizierung benutzer: (leer) oder "Windows" verwenden';
    TRes.ExSQLNamedInst := '  %s localhost\SQLEXPRESS\meinedb_prod sa\pass123 ' +
                           'localhost\SQLEXPRESS\meinedb_dev sa\pass456 --nodelete --with-triggers';
    TRes.ExSQLStd := '  %s server1\meinedb benutzer\pass server2\meinedb benutzer\pass --with-data-diff --nodelete';
    TRes.ExSQLWinAuth := '  %s localhost\meinedb Windows\ localhost\meinedb_test Windows\ --with-data-diff';
    TRes.ExSQLFilter := '  %s ... --with-data-diff --include-tables=Kunden,Produkte';
    TRes.UsageIBCmd := '  %s server1:port1\datenbank1.gdb benutzer1\passwort1 '+
                       'server2:port2\datenbank2.gdb benutzer2\passwort2 [optionen]';
    TRes.MsgIBLocal := '      Für lokale Datenbank: localhost\C:\pfad\datenbank.gdb';
    TRes.MsgIBEmbedded := '      Für eingebettete Datenbank: \C:\pfad\datenbank.gdb (ohne Server)';
    TRes.ExIBFull := '  %s localhost:3050\C:\DB\prod.gdb SYSDBA\masterkey '+
                     'localhost:3050\C:\DB\dev.gdb SYSDBA\masterkey --nodelete --with-triggers';
    TRes.ExIBServer := '  %s server1\C:\DB\meinedb.gdb benutzer\pass '+
                       'server2\C:\DB\meinedb.gdb benutzer\pass --with-data-diff --nodelete';
    TRes.ExIBEmbedded := '  %s \C:\DB\lokal.gdb SYSDBA\masterkey '+
                         '\C:\DB\lokal_test.gdb SYSDBA\masterkey --with-data-diff';
    TRes.ExIBFilter := '  %s ... --with-data-diff --include-tables=KUNDEN,PRODUKTE';
    TRes.UsagePGCmd := '  %s server1:port1\datenbank1 benutzer1\passwort1 '+
                       'server2:port2\datenbank2 benutzer2\passwort2 [optionen]';
    TRes.MsgPGSchema := '      Um Schema anzugeben: datenbank\schema (Standard: public)';
    TRes.ExPGFull := '  %s localhost:5432\meinedb_prod postgres\pass123 '+
                     'localhost:5432\meinedb_dev postgres\pass456 --nodelete --with-triggers';
    TRes.ExPGSchema := '  %s server1:5432\meinedb\public benutzer\pass '+
                       'server2:5432\meinedb\test_schema benutzer\pass --with-data-diff --nodelete';
    TRes.ExPGSimple := '  %s localhost\meinedb postgres\pass localhost\meinedb_test postgres\pass --with-data-diff';
    TRes.ExPGFilter := '  %s ... --with-data-diff --include-tables=kunden,produkte';
  end
  // ============================================================================
  // 中文 (CHINO)
  // ============================================================================
  else if LangCode = 'zh' then
  begin
    TRes.UsageHeader := '用法：';
    TRes.UsageNotePort := '注意：如果省略，默认端口为 %d';
    TRes.UsageFormat := '      指定模式：数据库\模式（默认：public）';
    TRes.UsageTNS := '      TNS连接：//tnsname 用户名/密码';
    TRes.OptionsHeader := '选项：';
    TRes.ExamplesHeader := '示例：';
    TRes.FooterFile := '结果输出到标准输出。保存到文件：';
    TRes.GeneratedHeader := '同步脚本（生成时间：%s）';
    TRes.MsgWarnNoPK := '警告：%s 没有主键。跳过数据同步。';
    TRes.UsageExampleCmd := '  %s 服务器1:端口1\数据库1 用户名1\密码1 ' +
                            '服务器2:端口2\数据库2 用户名2\密码2 [选项]';
    TRes.OptNoDelete := '不删除目标中的表、列或索引';
    TRes.OptTriggers := '包括触发器比较';
    TRes.OptWithData := '从源复制所有数据到目标（INSERT）';
    TRes.OptDataDiff := '通过主键比较同步数据（INSERT/UPDATE/DELETE）';
    TRes.OptExclude := '从数据同步中排除特定表';
    TRes.OptInclude := '仅同步这些表的数据';
    TRes.OptExcludeDesc := '（黑名单：同步除此之外的所有内容）';
    TRes.OptIncludeDesc := '（白名单：仅同步这些，忽略其他）';
    TRes.MsgNewTable := '新表：';
    TRes.MsgTableDeleted := '已删除表：';
    TRes.MsgAddColumn := '添加列：';
    TRes.MsgModColumn := '修改列：';
    TRes.MsgDelColumn := '删除列：';
    TRes.MsgAddIndex := '添加索引：';
    TRes.MsgModIndex := '修改索引：';
    TRes.MsgDelIndex := '删除索引：';
    TRes.MsgSeqCreated := '创建缺失序列：';
    TRes.MsgSeqDeleted := '删除过时序列：';
    TRes.MsgSyncData := '正在同步数据：';
    TRes.MsgWithIdentity := '（带标识）';
    TRes.MsgCopyAllData := '完整数据复制：';
    TRes.MsgInsertNew := '插入新记录（主键：%s）';
    TRes.MsgUpdateDiff := '更新差异（主键：%s）';
    TRes.MsgDeleteObs := '删除过时记录（主键：%s）';
    TRes.MsgHeaderViews := '=== 视图 ===';
    TRes.MsgRecreateView := '重建视图：';
    TRes.MsgHeaderProcs := '=== 存储过程 ===';
    TRes.MsgRecreateProc := '重建存储过程：';
    TRes.MsgHeaderFunc := '=== 函数 ===';
    TRes.MsgRecreateFunc := '重建函数：';
    TRes.MsgHeaderTrig := '=== 触发器 ===';
    TRes.MsgTriggerDel := '删除触发器：';
    TRes.MsgTriggerMod := '修改触发器：';
    TRes.MsgTriggerNew := '创建触发器：';
    TRes.MsgHeaderSequences := '=== 序列/生成器 ===';
    TRes.MsgSeqCreate := '创建缺失序列：';
    TRes.MsgSeqDrop := '删除过时序列：';
    TRes.UsageOracleCmd := '  %s 服务器1:端口1/sid1 用户名1/密码1 ' +
                           '服务器2:端口2/sid2 用户名2/密码2 [选项]';
    TRes.UsageOracleOwner := '      指定所有者/模式：用户名/密码@所有者';
    TRes.UsageOracleTNS := '      TNS连接：//tnsname 用户名/密码';
    TRes.HeaderConnFormats := '连接格式：';
    TRes.FmtOracleDirect := '  服务器:端口/sid            直接连接（例：localhost:1521/ORCL）';
    TRes.FmtOracleTNS := '  //tnsname                  使用TNS名称（例：//PROD_DB）';
    TRes.FmtOracleDefPort := '  服务器/sid                 默认端口1521';
    TRes.MsgSQLDefInstance := '注意：对于默认实例，只使用 服务器\数据库';
    TRes.MsgSQLWinAuth := '      Windows身份验证，使用用户名：（空）或"Windows"';
    TRes.ExSQLNamedInst := '  %s localhost\SQLEXPRESS\mydb_prod sa\pass123 ' +
                           'localhost\SQLEXPRESS\mydb_dev sa\pass456 --nodelete --with-triggers';
    TRes.ExSQLStd := '  %s 服务器1\mydb 用户名\密码 服务器2\mydb 用户名\密码 --with-data-diff --nodelete';
    TRes.ExSQLWinAuth := '  %s localhost\mydb Windows\ localhost\mydb_test Windows\ --with-data-diff';
    TRes.ExSQLFilter := '  %s ... --with-data-diff --include-tables=客户,产品';
    TRes.UsageIBCmd := '  %s 服务器1:端口1\数据库1.gdb 用户名1\密码1 '+
                       '服务器2:端口2\数据库2.gdb 用户名2\密码2 [选项]';
    TRes.MsgIBLocal := '      本地数据库：localhost\C:\路径\数据库.gdb';
    TRes.MsgIBEmbedded := '      嵌入式数据库：\C:\路径\数据库.gdb（无服务器）';
    TRes.ExIBFull := '  %s localhost:3050\C:\DB\prod.gdb SYSDBA\masterkey '+
                     'localhost:3050\C:\DB\dev.gdb SYSDBA\masterkey --nodelete --with-triggers';
    TRes.ExIBServer := '  %s 服务器1\C:\DB\mydb.gdb 用户名\密码 '+
                       '服务器2\C:\DB\mydb.gdb 用户名\密码 --with-data-diff --nodelete';
    TRes.ExIBEmbedded := '  %s \C:\DB\local.gdb SYSDBA\masterkey '+
                         '\C:\DB\local_test.gdb SYSDBA\masterkey --with-data-diff';
    TRes.ExIBFilter := '  %s ... --with-data-diff --include-tables=客户,产品';
    TRes.UsagePGCmd := '  %s 服务器1:端口1\数据库1 用户名1\密码1 '+
                       '服务器2:端口2\数据库2 用户名2\密码2 [选项]';
    TRes.MsgPGSchema := '      指定模式：数据库\模式（默认：public）';
    TRes.ExPGFull := '  %s localhost:5432\mydb_prod postgres\pass123 '+
                     'localhost:5432\mydb_dev postgres\pass456 --nodelete --with-triggers';
    TRes.ExPGSchema := '  %s 服务器1:5432\mydb\public 用户名\密码 '+
                       '服务器2:5432\mydb\test_schema 用户名\密码 --with-data-diff --nodelete';
    TRes.ExPGSimple := '  %s localhost\mydb postgres\密码 localhost\mydb_test postgres\密码 --with-data-diff';
    TRes.ExPGFilter := '  %s ... --with-data-diff --include-tables=客户,产品';
  end
  // ============================================================================
  // 한국어 (COREANO)
  // ============================================================================
  else if LangCode = 'ko' then
  begin
    TRes.UsageHeader := '사용법:';
    TRes.UsageNotePort := '참고: 생략 시 기본 포트는 %d입니다';
    TRes.UsageFormat := '      스키마 지정: 데이터베이스\스키마 (기본값: public)';
    TRes.UsageTNS := '      TNS 연결: //tnsname 사용자/암호';
    TRes.OptionsHeader := '옵션:';
    TRes.ExamplesHeader := '예제:';
    TRes.FooterFile := '결과가 표준 출력으로 출력됩니다. 파일로 저장:';
    TRes.GeneratedHeader := '동기화 스크립트 (생성 시간: %s)';
    TRes.MsgWarnNoPK := '경고: %s에 기본 키가 없습니다. 데이터 동기화를 건너뜁니다.';
    TRes.UsageExampleCmd := '  %s 서버1:포트1\데이터베이스1 사용자1\암호1 ' +
                            '서버2:포트2\데이터베이스2 사용자2\암호2 [옵션]';
    TRes.OptNoDelete := '대상의 테이블, 열 또는 인덱스를 삭제하지 않음';
    TRes.OptTriggers := '트리거 비교 포함';
    TRes.OptWithData := '원본에서 대상으로 모든 데이터 복사 (INSERT)';
    TRes.OptDataDiff := '기본 키로 비교하여 데이터 동기화 (INSERT/UPDATE/DELETE)';
    TRes.OptExclude := '데이터 동기화에서 특정 테이블 제외';
    TRes.OptInclude := '이 테이블의 데이터만 동기화';
    TRes.OptExcludeDesc := '(블랙리스트: 이것을 제외한 모든 것 동기화)';
    TRes.OptIncludeDesc := '(화이트리스트: 이것만 동기화, 나머지 무시)';
    TRes.MsgNewTable := '새 테이블: ';
    TRes.MsgTableDeleted := '테이블 삭제됨: ';
    TRes.MsgAddColumn := '열 추가: ';
    TRes.MsgModColumn := '열 수정: ';
    TRes.MsgDelColumn := '열 삭제: ';
    TRes.MsgAddIndex := '인덱스 추가: ';
    TRes.MsgModIndex := '인덱스 수정: ';
    TRes.MsgDelIndex := '인덱스 삭제: ';
    TRes.MsgSeqCreated := '누락된 시퀀스 생성: ';
    TRes.MsgSeqDeleted := '오래된 시퀀스 삭제: ';
    TRes.MsgSyncData := '데이터 동기화 중: ';
    TRes.MsgWithIdentity := ' (ID 포함)';
    TRes.MsgCopyAllData := '전체 데이터 복사: ';
    TRes.MsgInsertNew := '새 레코드 삽입 (기본 키: %s)';
    TRes.MsgUpdateDiff := '차이점 업데이트 (기본 키: %s)';
    TRes.MsgDeleteObs := '오래된 레코드 삭제 (기본 키: %s)';
    TRes.MsgHeaderViews := '=== 뷰 ===';
    TRes.MsgRecreateView := '뷰 재생성: ';
    TRes.MsgHeaderProcs := '=== 저장 프로시저 ===';
    TRes.MsgRecreateProc := '프로시저 재생성: ';
    TRes.MsgHeaderFunc := '=== 함수 ===';
    TRes.MsgRecreateFunc := '함수 재생성: ';
    TRes.MsgHeaderTrig := '=== 트리거 ===';
    TRes.MsgTriggerDel := '트리거 삭제: ';
    TRes.MsgTriggerMod := '트리거 수정: ';
    TRes.MsgTriggerNew := '트리거 생성: ';
    TRes.MsgHeaderSequences := '=== 시퀀스/생성기 ===';
    TRes.MsgSeqCreate := '누락된 시퀀스 생성: ';
    TRes.MsgSeqDrop := '오래된 시퀀스 삭제: ';
    TRes.UsageOracleCmd := '  %s 서버1:포트1/sid1 사용자1/암호1 ' +
                           '서버2:포트2/sid2 사용자2/암호2 [옵션]';
    TRes.UsageOracleOwner := '      소유자/스키마 지정: 사용자/암호@소유자';
    TRes.UsageOracleTNS := '      TNS 연결: //tnsname 사용자/암호';
    TRes.HeaderConnFormats := '연결 형식:';
    TRes.FmtOracleDirect := '  서버:포트/sid              직접 연결 (예: localhost:1521/ORCL)';
    TRes.FmtOracleTNS := '  //tnsname                  TNS 이름 사용 (예: //PROD_DB)';
    TRes.FmtOracleDefPort := '  서버/sid                   기본 포트 1521';
    TRes.MsgSQLDefInstance := '참고: 기본 인스턴스의 경우 서버\데이터베이스만 사용';
    TRes.MsgSQLWinAuth := '      Windows 인증의 경우 사용자: (비어 있음) 또는 "Windows" 사용';
    TRes.ExSQLNamedInst := '  %s localhost\SQLEXPRESS\mydb_prod sa\pass123 ' +
                           'localhost\SQLEXPRESS\mydb_dev sa\pass456 --nodelete --with-triggers';
    TRes.ExSQLStd := '  %s 서버1\mydb 사용자\암호 서버2\mydb 사용자\암호 --with-data-diff --nodelete';
    TRes.ExSQLWinAuth := '  %s localhost\mydb Windows\ localhost\mydb_test Windows\ --with-data-diff';
    TRes.ExSQLFilter := '  %s ... --with-data-diff --include-tables=고객,제품';
    TRes.UsageIBCmd := '  %s 서버1:포트1\데이터베이스1.gdb 사용자1\암호1 '+
                       '서버2:포트2\데이터베이스2.gdb 사용자2\암호2 [옵션]';
    TRes.MsgIBLocal := '      로컬 데이터베이스: localhost\C:\경로\데이터베이스.gdb';
    TRes.MsgIBEmbedded := '      임베디드 데이터베이스: \C:\경로\데이터베이스.gdb (서버 없음)';
    TRes.ExIBFull := '  %s localhost:3050\C:\DB\prod.gdb SYSDBA\masterkey '+
                     'localhost:3050\C:\DB\dev.gdb SYSDBA\masterkey --nodelete --with-triggers';
    TRes.ExIBServer := '  %s 서버1\C:\DB\mydb.gdb 사용자\암호 '+
                       '서버2\C:\DB\mydb.gdb 사용자\암호 --with-data-diff --nodelete';
    TRes.ExIBEmbedded := '  %s \C:\DB\local.gdb SYSDBA\masterkey '+
                         '\C:\DB\local_test.gdb SYSDBA\masterkey --with-data-diff';
    TRes.ExIBFilter := '  %s ... --with-data-diff --include-tables=고객,제품';
    TRes.UsagePGCmd := '  %s 서버1:포트1\데이터베이스1 사용자1\암호1 '+
                       '서버2:포트2\데이터베이스2 사용자2\암호2 [옵션]';
    TRes.MsgPGSchema := '      스키마 지정: 데이터베이스\스키마 (기본값: public)';
    TRes.ExPGFull := '  %s localhost:5432\mydb_prod postgres\pass123 '+
                     'localhost:5432\mydb_dev postgres\pass456 --nodelete --with-triggers';
    TRes.ExPGSchema := '  %s 서버1:5432\mydb\public 사용자\암호 '+
                       '서버2:5432\mydb\test_schema 사용자\암호 --with-data-diff --nodelete';
    TRes.ExPGSimple := '  %s localhost\mydb postgres\암호 localhost\mydb_test postgres\암호 --with-data-diff';
    TRes.ExPGFilter := '  %s ... --with-data-diff --include-tables=고객,제품';
  end
  // ============================================================================
  // العربية (ÁRABE)
  // ============================================================================
  else if LangCode = 'ar' then
  begin
    TRes.UsageHeader := 'الاستخدام:';
    TRes.UsageNotePort := 'ملاحظة: المنفذ الافتراضي هو %d إذا تم حذفه';
    TRes.UsageFormat := '      لتحديد المخطط: قاعدة_البيانات\المخطط (الافتراضي: public)';
    TRes.UsageTNS := '      لـ TNS: //tnsname اسم_المستخدم/كلمة_المرور';
    TRes.OptionsHeader := 'الخيارات:';
    TRes.ExamplesHeader := 'أمثلة:';
    TRes.FooterFile := 'يتم طباعة النتيجة على الإخراج القياسي. للحفظ في ملف:';
    TRes.GeneratedHeader := 'نص المزامنة (تم الإنشاء: %s)';
    TRes.MsgWarnNoPK := 'تحذير: %s ليس له مفتاح أساسي. تخطي مزامنة البيانات.';
    TRes.UsageExampleCmd := '  %s الخادم1:المنفذ1\قاعدة_البيانات1 المستخدم1\كلمة_المرور1 ' +
                            'الخادم2:المنفذ2\قاعدة_البيانات2 المستخدم2\كلمة_المرور2 [خيارات]';
    TRes.OptNoDelete := 'لا يحذف الجداول أو الأعمدة أو الفهارس في الهدف';
    TRes.OptTriggers := 'تضمين مقارنة المشغلات';
    TRes.OptWithData := 'نسخ جميع البيانات من المصدر إلى الهدف (INSERT)';
    TRes.OptDataDiff := 'مزامنة البيانات بالمقارنة بالمفتاح الأساسي (INSERT/UPDATE/DELETE)';
    TRes.OptExclude := 'استبعاد جداول محددة من مزامنة البيانات';
    TRes.OptInclude := 'مزامنة بيانات هذه الجداول فقط';
    TRes.OptExcludeDesc := '(القائمة السوداء: مزامنة كل شيء باستثناء هذا)';
    TRes.OptIncludeDesc := '(القائمة البيضاء: مزامنة هذا فقط، تجاهل الباقي)';
    TRes.MsgNewTable := 'جدول جديد: ';
    TRes.MsgTableDeleted := 'حذف الجدول: ';
    TRes.MsgAddColumn := 'إضافة عمود: ';
    TRes.MsgModColumn := 'تعديل عمود: ';
    TRes.MsgDelColumn := 'حذف عمود: ';
    TRes.MsgAddIndex := 'إضافة فهرس: ';
    TRes.MsgModIndex := 'تعديل فهرس: ';
    TRes.MsgDelIndex := 'حذف فهرس: ';
    TRes.MsgSeqCreated := 'إنشاء تسلسل مفقود: ';
    TRes.MsgSeqDeleted := 'حذف تسلسل قديم: ';
    TRes.MsgSyncData := 'مزامنة البيانات: ';
    TRes.MsgWithIdentity := ' (مع الهوية)';
    TRes.MsgCopyAllData := 'نسخ البيانات الكاملة: ';
    TRes.MsgInsertNew := 'إدراج سجل جديد (المفتاح الأساسي: %s)';
    TRes.MsgUpdateDiff := 'تحديث الاختلافات (المفتاح الأساسي: %s)';
    TRes.MsgDeleteObs := 'حذف سجل قديم (المفتاح الأساسي: %s)';
    TRes.MsgHeaderViews := '=== العروض ===';
    TRes.MsgRecreateView := 'إعادة إنشاء العرض: ';
    TRes.MsgHeaderProcs := '=== الإجراءات المخزنة ===';
    TRes.MsgRecreateProc := 'إعادة إنشاء الإجراء: ';
    TRes.MsgHeaderFunc := '=== الدوال ===';
    TRes.MsgRecreateFunc := 'إعادة إنشاء الدالة: ';
    TRes.MsgHeaderTrig := '=== المشغلات ===';
    TRes.MsgTriggerDel := 'حذف المشغل: ';
    TRes.MsgTriggerMod := 'تعديل المشغل: ';
    TRes.MsgTriggerNew := 'إنشاء مشغل: ';
    TRes.MsgHeaderSequences := '=== التسلسلات / المولدات ===';
    TRes.MsgSeqCreate := 'إنشاء تسلسل مفقود: ';
    TRes.MsgSeqDrop := 'حذف تسلسل قديم: ';
    TRes.UsageOracleCmd := '  %s الخادم1:المنفذ1/sid1 المستخدم1/كلمة_المرور1 ' +
                           'الخادم2:المنفذ2/sid2 المستخدم2/كلمة_المرور2 [خيارات]';
    TRes.UsageOracleOwner := '      لتحديد المالك/المخطط: المستخدم/كلمة_المرور@المالك';
    TRes.UsageOracleTNS := '      لـ TNS: //tnsname المستخدم/كلمة_المرور';
    TRes.HeaderConnFormats := 'تنسيقات الاتصال:';
    TRes.FmtOracleDirect := '  الخادم:المنفذ/sid          اتصال مباشر (مثال: localhost:1521/ORCL)';
    TRes.FmtOracleTNS := '  //tnsname                  استخدام أسماء TNS (مثال: //PROD_DB)';
    TRes.FmtOracleDefPort := '  الخادم/sid                 المنفذ الافتراضي 1521';
    TRes.MsgSQLDefInstance := 'ملاحظة: للنسخة الافتراضية، استخدم الخادم\قاعدة_البيانات فقط';
    TRes.MsgSQLWinAuth := '      لمصادقة Windows، استخدم المستخدم: (فارغ) أو "Windows"';
    TRes.ExSQLNamedInst := '  %s localhost\SQLEXPRESS\mydb_prod sa\pass123 ' +
                           'localhost\SQLEXPRESS\mydb_dev sa\pass456 --nodelete --with-triggers';
    TRes.ExSQLStd := '  %s الخادم1\mydb المستخدم\كلمة_المرور الخادم2\mydb المستخدم\كلمة_المرور --with-data-diff --nodelete';
    TRes.ExSQLWinAuth := '  %s localhost\mydb Windows\ localhost\mydb_test Windows\ --with-data-diff';
    TRes.ExSQLFilter := '  %s ... --with-data-diff --include-tables=العملاء,المنتجات';
    TRes.UsageIBCmd := '  %s الخادم1:المنفذ1\قاعدة_البيانات1.gdb المستخدم1\كلمة_المرور1 '+
                       'الخادم2:المنفذ2\قاعدة_البيانات2.gdb المستخدم2\كلمة_المرور2 [خيارات]';
    TRes.MsgIBLocal := '      لقاعدة بيانات محلية: localhost\C:\المسار\قاعدة_البيانات.gdb';
    TRes.MsgIBEmbedded := '      لقاعدة بيانات مدمجة: \C:\المسار\قاعدة_البيانات.gdb (بدون خادم)';
    TRes.ExIBFull := '  %s localhost:3050\C:\DB\prod.gdb SYSDBA\masterkey '+
                     'localhost:3050\C:\DB\dev.gdb SYSDBA\masterkey --nodelete --with-triggers';
    TRes.ExIBServer := '  %s الخادم1\C:\DB\mydb.gdb المستخدم\كلمة_المرور '+
                       'الخادم2\C:\DB\mydb.gdb المستخدم\كلمة_المرور --with-data-diff --nodelete';
    TRes.ExIBEmbedded := '  %s \C:\DB\local.gdb SYSDBA\masterkey '+
                         '\C:\DB\local_test.gdb SYSDBA\masterkey --with-data-diff';
    TRes.ExIBFilter := '  %s ... --with-data-diff --include-tables=العملاء,المنتجات';
    TRes.UsagePGCmd := '  %s الخادم1:المنفذ1\قاعدة_البيانات1 المستخدم1\كلمة_المرور1 '+
                       'الخادم2:المنفذ2\قاعدة_البيانات2 المستخدم2\كلمة_المرور2 [خيارات]';
    TRes.MsgPGSchema := '      لتحديد المخطط: قاعدة_البيانات\المخطط (الافتراضي: public)';
    TRes.ExPGFull := '  %s localhost:5432\mydb_prod postgres\pass123 '+
                     'localhost:5432\mydb_dev postgres\pass456 --nodelete --with-triggers';
    TRes.ExPGSchema := '  %s الخادم1:5432\mydb\public المستخدم\كلمة_المرور '+
                       'الخادم2:5432\mydb\test_schema المستخدم\كلمة_المرور --with-data-diff --nodelete';
    TRes.ExPGSimple := '  %s localhost\mydb postgres\pass localhost\mydb_test postgres\pass --with-data-diff';
    TRes.ExPGFilter := '  %s ... --with-data-diff --include-tables=العملاء,المنتجات';
  end
  // ============================================================================
  // HRVATSKI (CROATA)
  // ============================================================================
  else if LangCode = 'hr' then
  begin
    TRes.UsageHeader := 'Upotreba:';
    TRes.UsageNotePort := 'Napomena: Zadani port je %d ako se izostavi';
    TRes.UsageFormat := '      Za određivanje sheme: baza\shema (zadano: public)';
    TRes.UsageTNS := '      Za TNS: //tnsname korisnik/lozinka';
    TRes.OptionsHeader := 'Opcije:';
    TRes.ExamplesHeader := 'Primjeri:';
    TRes.FooterFile := 'Rezultat se ispisuje na standardni izlaz. Za spremanje u datoteku:';
    TRes.GeneratedHeader := 'SKRIPT ZA SINKRONIZACIJU (Generirano: %s)';
    TRes.MsgWarnNoPK := 'UPOZORENJE: %s nema PK. Sinkronizacija podataka se preskače.';
    TRes.UsageExampleCmd := '  %s poslužitelj1:port1\baza1 korisnik1\lozinka1 ' +
                            'poslužitelj2:port2\baza2 korisnik2\lozinka2 [opcije]';
    TRes.OptNoDelete := 'Ne briše tablice, stupce niti indekse u odredištu';
    TRes.OptTriggers := 'Uključuje usporedbu okidača (triggers)';
    TRes.OptWithData := 'Kopira sve podatke iz izvora u odredište (INSERT)';
    TRes.OptDataDiff := 'Sinkronizira podatke usporedbom primarnog ključa (INSERT/UPDATE/DELETE)';
    TRes.OptExclude := 'Isključuje određene tablice iz sinkronizacije podataka';
    TRes.OptInclude := 'Sinkronizira samo podatke ovih tablica';
    TRes.OptExcludeDesc := '(Crna lista: Sinkroniziraj sve OSIM ovoga)';
    TRes.OptIncludeDesc := '(Bijela lista: Sinkroniziraj samo OVO, zanemari ostalo)';
    TRes.MsgNewTable := 'Nova tablica: ';
    TRes.MsgTableDeleted := 'Tablica obrisana: ';
    TRes.MsgAddColumn := 'Dodaj stupac: ';
    TRes.MsgModColumn := 'Izmjeni stupac: ';
    TRes.MsgDelColumn := 'Obriši stupac: ';
    TRes.MsgAddIndex := 'Dodaj indeks: ';
    TRes.MsgModIndex := 'Izmjeni indeks: ';
    TRes.MsgDelIndex := 'Obriši indeks: ';
    TRes.MsgSeqCreated := 'Kreiraj nedostajuću sekvencu: ';
    TRes.MsgSeqDeleted := 'Obriši zastarjelu sekvencu: ';
    TRes.MsgSyncData := 'Sinkronizacija podataka: ';
    TRes.MsgWithIdentity := ' (S identitetom)';
    TRes.MsgCopyAllData := 'Potpuno kopiranje podataka: ';
    TRes.MsgInsertNew := 'Umetni novi zapis (PK: %s)';
    TRes.MsgUpdateDiff := 'Ažuriraj razlike (PK: %s)';
    TRes.MsgDeleteObs := 'Obriši zastarjeli zapis (PK: %s)';
    TRes.MsgHeaderViews := '=== POGLEDI ===';
    TRes.MsgRecreateView := 'Ponovno kreiranje pogleda: ';
    TRes.MsgHeaderProcs := '=== PROCEDURE ===';
    TRes.MsgRecreateProc := 'Ponovno kreiranje procedure: ';
    TRes.MsgHeaderFunc := '=== FUNKCIJE ===';
    TRes.MsgRecreateFunc := 'Ponovno kreiranje funkcije: ';
    TRes.MsgHeaderTrig := '=== OKIDAČI (TRIGGERS) ===';
    TRes.MsgTriggerDel := 'Obriši okidač: ';
    TRes.MsgTriggerMod := 'Izmjeni okidač: ';
    TRes.MsgTriggerNew := 'Kreiraj okidač: ';
    TRes.MsgHeaderSequences := '=== SEKVENCE / GENERATORI ===';
    TRes.MsgSeqCreate := 'Kreiraj nedostajuću sekvencu: ';
    TRes.MsgSeqDrop := 'Obriši zastarjelu sekvencu: ';
    TRes.UsageOracleCmd := '  %s poslužitelj1:port1/sid1 korisnik1/lozinka1 ' +
                           'poslužitelj2:port2/sid2 korisnik2/lozinka2 [opcije]';
    TRes.UsageOracleOwner := '      Za određivanje vlasnika/sheme: korisnik/lozinka@vlasnik';
    TRes.UsageOracleTNS := '      Za TNS: //tnsname korisnik/lozinka';
    TRes.HeaderConnFormats := 'Formati povezivanja:';
    TRes.FmtOracleDirect := '  poslužitelj:port/sid       Izravna veza (npr: localhost:1521/ORCL)';
    TRes.FmtOracleTNS := '  //tnsname                  Korištenje TNS imena (npr: //PROD_DB)';
    TRes.FmtOracleDefPort := '  poslužitelj/sid            Zadani port 1521';
    TRes.MsgSQLDefInstance := 'Napomena: Za zadanu instancu, koristiti samo poslužitelj\baza';
    TRes.MsgSQLWinAuth := '      Za Windows autentifikaciju, koristiti korisnik: (prazno) ili "Windows"';
    TRes.ExSQLNamedInst := '  %s localhost\SQLEXPRESS\mojabaza_prod sa\pass123 ' +
                           'localhost\SQLEXPRESS\mojabaza_dev sa\pass456 --nodelete --with-triggers';
    TRes.ExSQLStd := '  %s poslužitelj1\mojabaza korisnik\pass poslužitelj2\mojabaza korisnik\pass --with-data-diff --nodelete';
    TRes.ExSQLWinAuth := '  %s localhost\mojabaza Windows\ localhost\mojabaza_test Windows\ --with-data-diff';
    TRes.ExSQLFilter := '  %s ... --with-data-diff --include-tables=Klijenti,Proizvodi';
    TRes.UsageIBCmd := '  %s poslužitelj1:port1\baza1.gdb korisnik1\lozinka1 '+
                       'poslužitelj2:port2\baza2.gdb korisnik2\lozinka2 [opcije]';
    TRes.MsgIBLocal := '      Za lokalnu bazu: localhost\C:\putanja\baza.gdb';
    TRes.MsgIBEmbedded := '      Za ugrađenu bazu: \C:\putanja\baza.gdb (bez poslužitelja)';
    TRes.ExIBFull := '  %s localhost:3050\C:\DB\prod.gdb SYSDBA\masterkey '+
                     'localhost:3050\C:\DB\dev.gdb SYSDBA\masterkey --nodelete --with-triggers';
    TRes.ExIBServer := '  %s poslužitelj1\C:\DB\mojabaza.gdb korisnik\pass '+
                       'poslužitelj2\C:\DB\mojabaza.gdb korisnik\pass --with-data-diff --nodelete';
    TRes.ExIBEmbedded := '  %s \C:\DB\local.gdb SYSDBA\masterkey '+
                         '\C:\DB\local_test.gdb SYSDBA\masterkey --with-data-diff';
    TRes.ExIBFilter := '  %s ... --with-data-diff --include-tables=KLIJENTI,PROIZVODI';
    TRes.UsagePGCmd := '  %s poslužitelj1:port1\baza1 korisnik1\lozinka1 '+
                       'poslužitelj2:port2\baza2 korisnik2\lozinka2 [opcije]';
    TRes.MsgPGSchema := '      Za određivanje sheme: baza\shema (zadano: public)';
    TRes.ExPGFull := '  %s localhost:5432\mojabaza_prod postgres\pass123 '+
                     'localhost:5432\mojabaza_dev postgres\pass456 --nodelete --with-triggers';
    TRes.ExPGSchema := '  %s poslužitelj1:5432\mojabaza\public korisnik\pass '+
                       'poslužitelj2:5432\mojabaza\test_schema korisnik\pass --with-data-diff --nodelete';
    TRes.ExPGSimple := '  %s localhost\mojabaza postgres\pass localhost\mojabaza_test postgres\pass --with-data-diff';
    TRes.ExPGFilter := '  %s ... --with-data-diff --include-tables=klijenti,proizvodi';
  end
  // ============================================================================
  // DEFAULT / ENGLISH
  // ============================================================================
  else
  begin
    TRes.UsageHeader := 'Usage:';
    TRes.UsageNotePort := 'Note: Default port is %d if omitted';
    TRes.UsageFormat := '      To specify schema: database\schema (default: public)';
    TRes.UsageTNS := '      For TNS: //tnsname user/password';
    TRes.OptionsHeader := 'Options:';
    TRes.ExamplesHeader := 'Examples:';
    TRes.FooterFile := 'Result is printed to standard output. To save to file:';
    TRes.GeneratedHeader := 'SYNCHRONIZATION SCRIPT (Generated: %s)';
    TRes.MsgWarnNoPK := 'WARNING: %s has no PK. Data synchronization skipped.';
    TRes.UsageExampleCmd := '  %s server1:port1\database1 user1\password1 ' +
                            'server2:port2\database2 user2\password2 [options]';
    TRes.OptNoDelete := 'Do not delete tables, columns, or indexes in target';
    TRes.OptTriggers := 'Include trigger comparison';
    TRes.OptWithData := 'Copy all data from source to target (INSERT)';
    TRes.OptDataDiff := 'Sync data by comparing primary key (INSERT/UPDATE/DELETE)';
    TRes.OptExclude := 'Exclude specific tables from data sync';
    TRes.OptInclude := 'Only sync data from these tables';
    TRes.OptExcludeDesc := '(Blacklist: Sync everything EXCEPT this)';
    TRes.OptIncludeDesc := '(Whitelist: Only sync THIS, ignore rest)';
    TRes.MsgNewTable := 'New table: ';
    TRes.MsgTableDeleted := 'Table deleted: ';
    TRes.MsgAddColumn := 'Add column: ';
    TRes.MsgModColumn := 'Modify column: ';
    TRes.MsgDelColumn := 'Delete column: ';
    TRes.MsgAddIndex := 'Add index: ';
    TRes.MsgModIndex := 'Modify index: ';
    TRes.MsgDelIndex := 'Delete index: ';
    TRes.MsgSeqCreated := 'Create missing sequence: ';
    TRes.MsgSeqDeleted := 'Delete obsolete sequence: ';
    TRes.MsgSyncData := 'Syncing data: ';
    TRes.MsgWithIdentity := ' (With Identity)';
    TRes.MsgCopyAllData := 'Full data copy: ';
    TRes.MsgInsertNew := 'Insert new record (PK: %s)';
    TRes.MsgUpdateDiff := 'Update differences (PK: %s)';
    TRes.MsgDeleteObs := 'Delete obsolete record (PK: %s)';
    TRes.MsgHeaderViews := '=== VIEWS ===';
    TRes.MsgRecreateView := 'Recreating view: ';
    TRes.MsgHeaderProcs := '=== PROCEDURES ===';
    TRes.MsgRecreateProc := 'Recreating procedure: ';
    TRes.MsgHeaderFunc := '=== FUNCTIONS ===';
    TRes.MsgRecreateFunc := 'Recreating function: ';
    TRes.MsgHeaderTrig := '=== TRIGGERS ===';
    TRes.MsgTriggerDel := 'Delete trigger: ';
    TRes.MsgTriggerMod := 'Modify trigger: ';
    TRes.MsgTriggerNew := 'Create trigger: ';
    TRes.MsgHeaderSequences := '=== SEQUENCES / GENERATORS ===';
    TRes.MsgSeqCreate := 'Create missing sequence: ';
    TRes.MsgSeqDrop := 'Delete obsolete sequence: ';
    TRes.UsageOracleCmd := '  %s server1:port1/sid1 user1/password1 ' +
                           'server2:port2/sid2 user2/password2 [options]';
    TRes.UsageOracleOwner := '      To specify owner/schema: user/password@owner';
    TRes.UsageOracleTNS := '      For TNS: //tnsname user/password';
    TRes.HeaderConnFormats := 'Connection formats:';
    TRes.FmtOracleDirect := '  server:port/sid            Direct connection (e.g.: localhost:1521/ORCL)';
    TRes.FmtOracleTNS := '  //tnsname                  Using TNS Names (e.g.: //PROD_DB)';
    TRes.FmtOracleDefPort := '  server/sid                 Default port 1521';
    TRes.MsgSQLDefInstance := 'Note: For default instance, use only server\database';
    TRes.MsgSQLWinAuth := '      For Windows authentication, use user: (empty) or "Windows"';
    TRes.ExSQLNamedInst := '  %s localhost\SQLEXPRESS\mydb_prod sa\pass123 ' +
                           'localhost\SQLEXPRESS\mydb_dev sa\pass456 --nodelete --with-triggers';
    TRes.ExSQLStd := '  %s server1\mydb user\pass server2\mydb user\pass --with-data-diff --nodelete';
    TRes.ExSQLWinAuth := '  %s localhost\mydb Windows\ localhost\mydb_test Windows\ --with-data-diff';
    TRes.ExSQLFilter := '  %s ... --with-data-diff --include-tables=Customers,Products';
    TRes.UsageIBCmd := '  %s server1:port1\database1.gdb user1\password1 '+
                       'server2:port2\database2.gdb user2\password2 [options]';
    TRes.MsgIBLocal := '      For local database: localhost\C:\path\database.gdb';
    TRes.MsgIBEmbedded := '      For embedded database: \C:\path\database.gdb (no server)';
    TRes.ExIBFull := '  %s localhost:3050\C:\DB\prod.gdb SYSDBA\masterkey '+
                     'localhost:3050\C:\DB\dev.gdb SYSDBA\masterkey --nodelete --with-triggers';
    TRes.ExIBServer := '  %s server1\C:\DB\mydb.gdb user\pass '+
                       'server2\C:\DB\mydb.gdb user\pass --with-data-diff --nodelete';
    TRes.ExIBEmbedded := '  %s \C:\DB\local.gdb SYSDBA\masterkey '+
                         '\C:\DB\local_test.gdb SYSDBA\masterkey --with-data-diff';
    TRes.ExIBFilter := '  %s ... --with-data-diff --include-tables=CUSTOMERS,PRODUCTS';
    TRes.UsagePGCmd := '  %s server1:port1\database1 user1\password1 '+
                       'server2:port2\database2 user2\password2 [options]';
    TRes.MsgPGSchema := '      To specify schema: database\schema (default: public)';
    TRes.ExPGFull := '  %s localhost:5432\mydb_prod postgres\pass123 '+
                     'localhost:5432\mydb_dev postgres\pass456 --nodelete --with-triggers';
    TRes.ExPGSchema := '  %s server1:5432\mydb\public user\pass '+
                       'server2:5432\mydb\test_schema user\pass --with-data-diff --nodelete';
    TRes.ExPGSimple := '  %s localhost\mydb postgres\pass localhost\mydb_test postgres\pass --with-data-diff';
    TRes.ExPGFilter := '  %s ... --with-data-diff --include-tables=customers,products';
  end;
end;

initialization
  InitResources;

end.
