unit Providers.MySQL;

interface

uses
  System.Classes, System.SysUtils, Data.DB, Core.Interfaces, Core.Types, Uni,
  MySQLUniProvider, system.StrUtils, System.Generics.Collections,
  Providers.MySQL.Helpers, Core.Helpers;

const
    SCHEMADB = 'information_schema';
type
  TMySQLMetadataProvider = class(TInterfacedObject, IDBMetadataProvider)
  private
    FConn: TUniConnection;
    FDBName: string;
  public
    constructor Create(Conn: TUniConnection; const DBName: string);
    destructor Destroy; override;
    // Implementación de la interfaz
    function GetTables: TStringList;
    function GetTableStructure(const TableName: string): TTableInfo;
    function GetTableIndexes(const TableName: string): TArray<TIndexInfo>;
    function GetTriggers: TArray<TTriggerInfo>;
    function GetTriggerDefinition(const TriggerName: string): string;
    function GetViews:TStringList;
    function GetViewDefinition(const ViewName:string):string;
    function GetProcedures:TStringList;
    function GetProcedureDefinition(const ProcedureName:string):string;
    function GetData(const TableName: string; const Filter: string = ''): TDataSet;
  private
    function StripDefiner(const SQL: string): string;
  end;

implementation

{ TMySQLMetadataProvider }

function TMySQLMetadataProvider.GetData(const TableName: string; const Filter: string = ''): TDataSet;
var
  Query: TUniQuery;
  function QuoteIdentifier(const Identifier: string): string;
begin
  Result := '`' + Identifier + '`';
end;
begin
  Query := TUniQuery.Create(nil);
  Query.Connection := FConn;
  Query.SQL.Text := 'SELECT * FROM ' + QuoteIdentifier(TableName);
  if Filter <> '' then
    Query.SQL.Add('WHERE ' + Filter);
  Query.Open;
  Result := Query; // El Engine será responsable de liberarlo
end;


constructor TMySQLMetadataProvider.Create(Conn: TUniConnection;
  const DBName: string);
begin
//  FConn := TUniConnection.Create(nil);
  FDBName := DBName;
  Fconn := Conn;
  FConn.ProviderName := 'MySQL';
  FConn.Connected := True;
end;

destructor TMySQLMetadataProvider.Destroy;
begin
  Fconn.Free;
  inherited;
end;

function TMySQLMetadataProvider.GetProcedureDefinition(
  const ProcedureName:string): string;
var
  Query: TUniQuery;
  OldDB: string;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.Connection.Database := FDBName;
    Query.SQL.Text := 'SHOW CREATE PROCEDURE `' + ProcedureName + '`';
    Query.Open;
    Result := Query.Fields[2].AsString;
    Result := StripDefiner(Result);
  finally
    Query.Free;
  end;
end;

function TMySQLMetadataProvider.GetProcedures: TStringList;
var
  Query: TUniQuery;
begin
  Result := TStringList.Create;
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    FConn.Database := SCHEMADB;
    Query.SQL.Text := 'SELECT ROUTINE_NAME '+
                      '  FROM INFORMATION_SCHEMA.ROUTINES ' +
                      ' WHERE ROUTINE_SCHEMA = ' + QuotedStr(FDBName) + ' ' +
                      'ORDER BY ROUTINE_NAME';
    Query.Open;
    while not Query.Eof do
    begin
      Result.Add(Query.FieldByName('ROUTINE_NAME').AsString);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TMySQLMetadataProvider.GetTableIndexes(
  const TableName: string): TArray<TIndexInfo>;
var
  Query: TUniQuery;
  IndexList: TList<TIndexInfo>;
  CurrentIndex: TIndexInfo;
  LastIndexName: string;
  ColList: TList<TIndexColumn>;
  IndexCol: TIndexColumn;
begin
  IndexList := TList<TIndexInfo>.Create;
  ColList := TList<TIndexColumn>.Create;
  try
    Query := TUniQuery.Create(nil);
    try
      Query.Connection := FConn;
      FConn.Database := SCHEMADB;
      Query.SQL.Text :=
        'SELECT INDEX_NAME, ' +
        '       NON_UNIQUE, ' +
        '       COLUMN_NAME, ' +
        '       SEQ_IN_INDEX ' +
        '  FROM INFORMATION_SCHEMA.STATISTICS ' +
        ' WHERE TABLE_SCHEMA = ' + QuotedStr(FDBName) +
        '   AND TABLE_NAME = ' + QuotedStr(TableName) + ' ' +
        'ORDER BY INDEX_NAME, SEQ_IN_INDEX';
      Query.Open;
      LastIndexName := '';
      while not Query.Eof do
      begin
        // Nuevo índice detectado
        if not SameText(Query.FieldByName('INDEX_NAME').AsString, LastIndexName) then
        begin
          // Guardar el índice anterior si existe
          if not SameText(LastIndexName, '') then
          begin
            CurrentIndex.Columns := ColList.ToArray;
            IndexList.Add(CurrentIndex);
            ColList.Clear;
          end;
          // Iniciar nuevo índice
          LastIndexName := Query.FieldByName('INDEX_NAME').AsString;
          CurrentIndex.IndexName := LastIndexName;
          CurrentIndex.IsPrimary := SameText(LastIndexName, 'PRIMARY');
          CurrentIndex.IsUnique := (Query.FieldByName('NON_UNIQUE').AsInteger = 0);
        end;
        // Agregar columna al índice actual
        IndexCol.ColumnName := Query.FieldByName('COLUMN_NAME').AsString;
        IndexCol.SeqInIndex := Query.FieldByName('SEQ_IN_INDEX').AsInteger;
        ColList.Add(IndexCol);
        Query.Next;
      end;
      // Guardar el último índice
      if not SameText(LastIndexName, '') then
      begin
        CurrentIndex.Columns := ColList.ToArray;
        IndexList.Add(CurrentIndex);
      end;
    finally
      Query.Free;
    end;
    Result := IndexList.ToArray;
  finally
    IndexList.Free;
    ColList.Free;
  end;
end;

function TMySQLMetadataProvider.GetTables: TStringList;
var
  Query: TUniQuery;
begin
  Result := TStringList.Create;
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 'SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES ' +
                      'WHERE TABLE_SCHEMA = ' + QuotedStr(FDBName) +
                      '  AND TABLE_TYPE = ''BASE TABLE'' ' +
                      'ORDER BY TABLE_NAME';
    Query.Open;
    while (not(Query.Eof)) do
    begin
      Result.Add(Query.FieldByName('TABLE_NAME').AsString);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TMySQLMetadataProvider.GetTableStructure(
  const TableName: string): TTableInfo;
var
  Query: TUniQuery;
  Col: TColumnInfo;
begin
  Result := TTableInfo.Create;
  Result.TableName := TableName;
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    // CORRECCIÓN: Concatenación adecuada de cadenas
    Query.SQL.Text := 'SELECT COLUMN_NAME, ' +
                      '       COLUMN_TYPE, ' +
                      '       IS_NULLABLE, ' +
                      '       COLUMN_KEY, ' +
                      '       EXTRA, ' +
                      '       COLUMN_DEFAULT, ' +
                      '       CHARACTER_MAXIMUM_LENGTH, ' +
                      '       COLUMN_COMMENT ' +
                      '  FROM INFORMATION_SCHEMA.COLUMNS ' +
                      ' WHERE TABLE_SCHEMA = ' + QuotedStr(FDBName) +
                      '   AND TABLE_NAME = ' + QuotedStr(TableName) + ' ' +
                      'ORDER BY ORDINAL_POSITION';
    Query.Open;
    while not Query.Eof do
    begin
      Col.ColumnName := Query.FieldByName('COLUMN_NAME').AsString;
      Col.DataType := Query.FieldByName('COLUMN_TYPE').AsString;
      Col.IsNullable := Query.FieldByName('IS_NULLABLE').AsString;
      Col.ColumnKey := Query.FieldByName('COLUMN_KEY').AsString;
      Col.Extra := Query.FieldByName('EXTRA').AsString;
      if not Query.FieldByName('COLUMN_DEFAULT').IsNull then
        Col.ColumnDefault := Query.FieldByName('COLUMN_DEFAULT').AsString
      else
        Col.ColumnDefault := '';
      if not Query.FieldByName('CHARACTER_MAXIMUM_LENGTH').IsNull then
        Col.CharMaxLength :=
                          Query.FieldByName('CHARACTER_MAXIMUM_LENGTH').AsString
      else
        Col.CharMaxLength := '';
      if not Query.FieldByName('COLUMN_COMMENT').IsNull then
        Col.ColumnComment := Query.FieldByName('COLUMN_COMMENT').AsString
      else
        Col.ColumnComment := '';
      Result.Columns.Add(Col);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TMySQLMetadataProvider.GetTriggerDefinition(
  const TriggerName: string): string;
var
  Query: TUniQuery;
  OldDB: string;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    FConn.Database := FDBName;
    Query.SQL.Text := 'SHOW CREATE TRIGGER `' + TriggerName + '`';
    Query.Open;
    Result := Query.Fields[2].AsString;
    Result := StripDefiner(Result);
  finally
    Query.Free;
  end;
end;

function TMySQLMetadataProvider.GetTriggers: TArray<TTriggerInfo>;
var
  Query: TUniQuery;
  TriggerList: TList<TTriggerInfo>;
  Trigger: TTriggerInfo;
begin
  TriggerList := TList<TTriggerInfo>.Create;
  try
    Query := TUniQuery.Create(nil);
    try
      FConn.Database := SCHEMADB;
      Query.Connection := FConn;
      // CORRECCIÓN: Concatenación y espacios
      Query.SQL.Text :=
        'SELECT TRIGGER_NAME, ' +
        '       EVENT_MANIPULATION, ' +
        '       ACTION_TIMING, ' +
        '       ACTION_STATEMENT, ' +
        '       EVENT_OBJECT_TABLE ' +
        '  FROM INFORMATION_SCHEMA.TRIGGERS ' +
        ' WHERE TRIGGER_SCHEMA = ' + QuotedStr(FDBName) + ' ' +
        'ORDER BY EVENT_OBJECT_TABLE, TRIGGER_NAME';
      Query.Open;
      while not Query.Eof do
      begin
        Trigger.TriggerName := Query.FieldByName('TRIGGER_NAME').AsString;
        Trigger.EventManipulation :=
                               Query.FieldByName('EVENT_MANIPULATION').AsString;
        Trigger.ActionTiming := Query.FieldByName('ACTION_TIMING').AsString;
        Trigger.ActionStatement :=
                                 Query.FieldByName('ACTION_STATEMENT').AsString;
        Trigger.EventObjectTable :=
                               Query.FieldByName('EVENT_OBJECT_TABLE').AsString;
        TriggerList.Add(Trigger);
        Query.Next;
      end;
    finally
      Query.Free;
    end;
    Result := TriggerList.ToArray;
  finally
    TriggerList.Free;
  end;
end;

function TMySQLMetadataProvider.GetViewDefinition(
  const ViewName: string): string;
var
  Query: TUniQuery;
  OldDB: string;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    FConn.Database := FDBName;
    Query.SQL.Text := 'SHOW CREATE VIEW `' + ViewName + '`';
    Query.Open;
    Result := Query.Fields[1].AsString;
    Result := StripDefiner(Result);
  finally
    Query.Free;
  end;
end;

function TMySQLMetadataProvider.GetViews: TStringList;
var
  Query: TUniQuery;
begin
  Result := TStringList.Create;
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    Fconn.Database := SCHEMADB;
    Query.SQL.Text := 'SELECT TABLE_NAME' +
                      '  FROM INFORMATION_SCHEMA.VIEWS ' +
                      ' WHERE TABLE_SCHEMA = ' + QuotedStr(FDBName) + ' ' +
                      'ORDER BY TABLE_NAME';
    Query.Open;
    while not Query.Eof do
    begin
      Result.Add(Query.FieldByName('TABLE_NAME').AsString);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TMySQLMetadataProvider.StripDefiner(const SQL: string): string;
var
  PosDefiner, PosEnd: Integer;
  UpperSQL: string;
begin
  Result := SQL;
  UpperSQL := UpperCase(SQL);
  PosDefiner := Pos('DEFINER=', UpperSQL);
  if PosDefiner > 0 then
  begin
    PosEnd := 0;
    // 1. Buscar PROCEDURE (Prioridad alta para evitar error
    //    con SQLEXCEPTION en el cuerpo)
    if (PosEnd = 0) then PosEnd := PosEx('PROCEDURE', UpperSQL, PosDefiner);
    // 2. Buscar TRIGGER
    if (PosEnd = 0) then PosEnd := PosEx('TRIGGER', UpperSQL, PosDefiner);
    // 3. Buscar FUNCTION
    if (PosEnd = 0) then PosEnd := PosEx('FUNCTION', UpperSQL, PosDefiner);
    // 4. Buscar VIEW (Esto limpiará también el
    //    'SQL SECURITY' si está antes del VIEW)
    if (PosEnd = 0) then PosEnd := PosEx('VIEW', UpperSQL, PosDefiner);
    // NOTA: Hemos eliminado la búsqueda genérica de 'SQL' porque causaba
    // falsos positivos con variables o handlers como 'SQLEXCEPTION'.
    if (PosEnd > 0) then
    begin
      // Cortamos desde el inicio del DEFINER hasta justo antes del
      // tipo de objeto Y Agregamos un espacio por seguridad para evitar
      // concatenaciones tipo "UNDEFINEDVIEW"
      Result := Trim(Copy(Result, 1, PosDefiner - 1) + ' ' +
                     Copy(Result, PosEnd, Length(Result)));
    end;
  end;
end;


end.
