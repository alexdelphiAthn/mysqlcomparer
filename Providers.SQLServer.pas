unit Providers.SQLServer;

interface

uses
  System.Classes, System.SysUtils, Data.DB, Core.Interfaces, Core.Types, Uni,
  SQLServerUniProvider, System.StrUtils, System.Generics.Collections,
  Providers.SQLServer.Helpers, Core.Helpers;

type
  TSQLServerMetadataProvider = class(TInterfacedObject, IDBMetadataProvider)
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
    function GetViews: TStringList;
    function GetViewDefinition(const ViewName: string): string;
    function GetProcedures: TStringList;
    function GetFunctions: TStringList;
    function GetProcedureDefinition(const ProcedureName: string): string;
    function GetFunctionDefinition(const FunctionName: string): string;
    function GetData(const TableName: string; const Filter: string = ''): TDataSet;
  private
    function QuoteIdentifier(const Identifier: string): string;
  end;

implementation

{ TSQLServerMetadataProvider }

function TSQLServerMetadataProvider.QuoteIdentifier(const Identifier: string): string;
begin
  Result := '[' + StringReplace(Identifier, ']', ']]', [rfReplaceAll]) + ']';
end;

function TSQLServerMetadataProvider.GetData(const TableName: string; 
  const Filter: string = ''): TDataSet;
var
  Query: TUniQuery;
begin
  Query := TUniQuery.Create(nil);
  Query.Connection := FConn;
  Query.SQL.Text := 'SELECT * FROM ' + QuoteIdentifier(TableName);
  if Filter <> '' then
    Query.SQL.Add('WHERE ' + Filter);
  Query.Open;
  Result := Query;
end;

function TSQLServerMetadataProvider.GetFunctionDefinition(
  const FunctionName: string): string;
var
  Query: TUniQuery;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 
      'SELECT OBJECT_DEFINITION(OBJECT_ID(N' + QuotedStr(FunctionName) + ')) AS Definition';
    Query.Open;
    Result := Query.FieldByName('Definition').AsString;
  finally
    Query.Free;
  end;
end;

function TSQLServerMetadataProvider.GetFunctions: TStringList;
var
  Query: TUniQuery;
begin
  Result := TStringList.Create;
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    // Asegurar que estamos en la base de datos correcta
    if FConn.Database <> FDBName then
      FConn.Database := FDBName;
    Query.SQL.Text := 
      'SELECT name ' +
      '  FROM sys.objects ' +
      ' WHERE type IN (''FN'', ''IF'', ''TF'') ' +
      '   AND schema_id = SCHEMA_ID(''dbo'') ' +
      'ORDER BY name';
    Query.Open;
    while not Query.Eof do
    begin
      Result.Add(Query.FieldByName('name').AsString);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

constructor TSQLServerMetadataProvider.Create(Conn: TUniConnection;
  const DBName: string);
begin
  FDBName := DBName;
  FConn := Conn;
  FConn.ProviderName := 'SQL Server';
  FConn.Connected := True;
end;

destructor TSQLServerMetadataProvider.Destroy;
begin
  inherited;
end;

function TSQLServerMetadataProvider.GetProcedureDefinition(
  const ProcedureName: string): string;
var
  Query: TUniQuery;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 
      'SELECT OBJECT_DEFINITION(OBJECT_ID(N' + QuotedStr(ProcedureName) + ')) AS Definition';
    Query.Open;
    Result := Query.FieldByName('Definition').AsString;
  finally
    Query.Free;
  end;
end;

function TSQLServerMetadataProvider.GetProcedures: TStringList;
var
  Query: TUniQuery;
begin
  Result := TStringList.Create;
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 
      'SELECT name ' +
      '  FROM sys.procedures ' +
      ' WHERE schema_id = SCHEMA_ID(''dbo'') ' +
      'ORDER BY name';
    Query.Open;
    while not Query.Eof do
    begin
      Result.Add(Query.FieldByName('name').AsString);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TSQLServerMetadataProvider.GetTableIndexes(
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
      Query.SQL.Text :=
        'SELECT i.name AS INDEX_NAME, ' +
        '       i.is_unique AS IS_UNIQUE, ' +
        '       i.is_primary_key AS IS_PRIMARY, ' +
        '       c.name AS COLUMN_NAME, ' +
        '       ic.key_ordinal AS SEQ_IN_INDEX ' +
        '  FROM sys.indexes i ' +
        ' INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id ' +
        '                                 AND i.index_id = ic.index_id ' +
        ' INNER JOIN sys.columns c ON ic.object_id = c.object_id ' +
        '                          AND ic.column_id = c.column_id ' +
        ' WHERE i.object_id = OBJECT_ID(N' + QuotedStr(TableName) + ') ' +
        '   AND i.type IN (1, 2) ' + // Clustered y NonClustered
        'ORDER BY i.name, ic.key_ordinal';
      Query.Open;
      
      LastIndexName := '';
      while not Query.Eof do
      begin
        if not SameText(Query.FieldByName('INDEX_NAME').AsString, LastIndexName) then
        begin
          if not SameText(LastIndexName, '') then
          begin
            CurrentIndex.Columns := ColList.ToArray;
            IndexList.Add(CurrentIndex);
            ColList.Clear;
          end;
          
          LastIndexName := Query.FieldByName('INDEX_NAME').AsString;
          CurrentIndex.IndexName := LastIndexName;
          CurrentIndex.IsPrimary := Query.FieldByName('IS_PRIMARY').AsBoolean;
          CurrentIndex.IsUnique := Query.FieldByName('IS_UNIQUE').AsBoolean;
        end;
        
        IndexCol.ColumnName := Query.FieldByName('COLUMN_NAME').AsString;
        IndexCol.SeqInIndex := Query.FieldByName('SEQ_IN_INDEX').AsInteger;
        ColList.Add(IndexCol);
        Query.Next;
      end;
      
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

function TSQLServerMetadataProvider.GetTables: TStringList;
var
  Query: TUniQuery;
begin
  Result := TStringList.Create;
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    // Asegurar que estamos en la base de datos correcta
    Query.SQL.Text := 
      'SELECT name ' +
      '  FROM sys.tables ' +
      ' WHERE type = ''U'' ' +
      '   AND schema_id = SCHEMA_ID(''dbo'') ' +
      'ORDER BY name';
    Query.Open;
    while not Query.Eof do
    begin
      Result.Add(Query.FieldByName('name').AsString);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TSQLServerMetadataProvider.GetTableStructure(
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
    Query.SQL.Text :=
      'SELECT c.name AS COLUMN_NAME, ' +
      '       t.name + ' +
      '       CASE ' +
      '         WHEN t.name IN (''varchar'', ''nvarchar'', ''char'', ''nchar'') THEN ' +
      '           ''('' + CASE WHEN c.max_length = -1 THEN ''max'' ' +
      '                        ELSE CAST(CASE WHEN t.name LIKE ''n%'' ' +
      '                                       THEN c.max_length/2 ' +
      '                                       ELSE c.max_length END AS VARCHAR) END + '')'' ' +
      '         WHEN t.name IN (''decimal'', ''numeric'') THEN ' +
      '           ''('' + CAST(c.precision AS VARCHAR) + '','' + CAST(c.scale AS VARCHAR) + '')'' ' +
      '         ELSE '''' ' +
      '       END AS DATA_TYPE, ' +
      '       CASE WHEN c.is_nullable = 1 THEN ''YES'' ELSE ''NO'' END AS IS_NULLABLE, ' +
      '       CASE WHEN ic.object_id IS NOT NULL THEN ''PRI'' ELSE '''' END AS COLUMN_KEY, ' +
      '       CASE WHEN c.is_identity = 1 THEN ''IDENTITY'' ELSE '''' END AS EXTRA, ' +
      '       OBJECT_DEFINITION(c.default_object_id) AS COLUMN_DEFAULT, ' +
      '       CAST(c.max_length AS VARCHAR) AS CHARACTER_MAXIMUM_LENGTH, ' +
      '       CAST(ep.value AS NVARCHAR(4000)) AS COLUMN_COMMENT ' +
      '  FROM sys.columns c ' +
      ' INNER JOIN sys.types t ON c.user_type_id = t.user_type_id ' +
      '  LEFT JOIN sys.index_columns ic ON c.object_id = ic.object_id ' +
      '                                 AND c.column_id = ic.column_id ' +
      '  LEFT JOIN sys.indexes i ON ic.object_id = i.object_id ' +
      '                          AND ic.index_id = i.index_id ' +
      '                          AND i.is_primary_key = 1 ' +
      '  LEFT JOIN sys.extended_properties ep ON c.object_id = ep.major_id ' +
      '                                       AND c.column_id = ep.minor_id ' +
      '                                       AND ep.name = ''MS_Description'' ' +
      ' WHERE c.object_id = OBJECT_ID(N' + QuotedStr(TableName) + ') ' +
      'ORDER BY c.column_id';
    Query.Open;
    
    while not Query.Eof do
    begin
      Col.ColumnName := Query.FieldByName('COLUMN_NAME').AsString;
      Col.DataType := Query.FieldByName('DATA_TYPE').AsString;
      Col.IsNullable := Query.FieldByName('IS_NULLABLE').AsString;
      Col.ColumnKey := Query.FieldByName('COLUMN_KEY').AsString;
      Col.Extra := Query.FieldByName('EXTRA').AsString;
      
      if not Query.FieldByName('COLUMN_DEFAULT').IsNull then
        Col.ColumnDefault := Query.FieldByName('COLUMN_DEFAULT').AsString
      else
        Col.ColumnDefault := '';
        
      if not Query.FieldByName('CHARACTER_MAXIMUM_LENGTH').IsNull then
        Col.CharMaxLength := Query.FieldByName('CHARACTER_MAXIMUM_LENGTH').AsString
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

function TSQLServerMetadataProvider.GetTriggerDefinition(
  const TriggerName: string): string;
var
  Query: TUniQuery;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 
      'SELECT OBJECT_DEFINITION(OBJECT_ID(N' + QuotedStr(TriggerName) + ')) AS Definition';
    Query.Open;
    Result := Query.FieldByName('Definition').AsString;
  finally
    Query.Free;
  end;
end;

function TSQLServerMetadataProvider.GetTriggers: TArray<TTriggerInfo>;
var
  Query: TUniQuery;
  TriggerList: TList<TTriggerInfo>;
  Trigger: TTriggerInfo;
begin
  TriggerList := TList<TTriggerInfo>.Create;
  try
    Query := TUniQuery.Create(nil);
    try
      Query.Connection := FConn;
      Query.SQL.Text :=
        'SELECT tr.name AS TRIGGER_NAME, ' +
        '       CASE ' +
        '         WHEN OBJECTPROPERTY(tr.object_id, ''ExecIsInsertTrigger'') = 1 THEN ''INSERT'' ' +
        '         WHEN OBJECTPROPERTY(tr.object_id, ''ExecIsUpdateTrigger'') = 1 THEN ''UPDATE'' ' +
        '         WHEN OBJECTPROPERTY(tr.object_id, ''ExecIsDeleteTrigger'') = 1 THEN ''DELETE'' ' +
        '       END AS EVENT_MANIPULATION, ' +
        '       CASE WHEN tr.is_instead_of_trigger = 1 THEN ''INSTEAD OF'' ELSE ''AFTER'' END AS ACTION_TIMING, ' +
        '       OBJECT_DEFINITION(tr.object_id) AS ACTION_STATEMENT, ' +
        '       OBJECT_NAME(tr.parent_id) AS EVENT_OBJECT_TABLE ' +
        '  FROM sys.triggers tr ' +
        ' WHERE tr.parent_class = 1 ' +
        '   AND SCHEMA_NAME(OBJECTPROPERTY(tr.parent_id, ''SchemaId'')) = ''dbo'' ' +
        'ORDER BY EVENT_OBJECT_TABLE, TRIGGER_NAME';
      Query.Open;
      
      while not Query.Eof do
      begin
        Trigger.TriggerName := Query.FieldByName('TRIGGER_NAME').AsString;
        Trigger.EventManipulation := Query.FieldByName('EVENT_MANIPULATION').AsString;
        Trigger.ActionTiming := Query.FieldByName('ACTION_TIMING').AsString;
        Trigger.ActionStatement := Query.FieldByName('ACTION_STATEMENT').AsString;
        Trigger.EventObjectTable := Query.FieldByName('EVENT_OBJECT_TABLE').AsString;
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

function TSQLServerMetadataProvider.GetViewDefinition(
  const ViewName: string): string;
var
  Query: TUniQuery;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 
      'SELECT OBJECT_DEFINITION(OBJECT_ID(N' + QuotedStr(ViewName) + ')) AS Definition';
    Query.Open;
    Result := Query.FieldByName('Definition').AsString;
  finally
    Query.Free;
  end;
end;

function TSQLServerMetadataProvider.GetViews: TStringList;
var
  Query: TUniQuery;
begin
  Result := TStringList.Create;
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := FConn;
    Query.SQL.Text := 
      'SELECT name ' +
      '  FROM sys.views ' +
      ' WHERE schema_id = SCHEMA_ID(''dbo'') ' +
      'ORDER BY name';
    Query.Open;
    while not Query.Eof do
    begin
      Result.Add(Query.FieldByName('name').AsString);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

end.