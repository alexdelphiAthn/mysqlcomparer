program DBComparerConsole;

{$APPTYPE CONSOLE}
uses
  System.SysUtils, System.Classes, Data.DB, Uni, MySQLUniProvider,
  System.Generics.Collections, system.StrUtils;

type
  TColumnInfo = record
    ColumnName: string;
    DataType: string;
    IsNullable: string;
    ColumnKey: string;
    Extra: string;
    ColumnDefault: string;
    CharMaxLength: string;
    ColumnComment: string;
  end;

  TIndexColumn = record
    ColumnName: string;
    SeqInIndex: Integer;
  end;

  TIndexInfo = record
    IndexName: string;
    IsUnique: Boolean;
    IsPrimary: Boolean;
    Columns: TArray<TIndexColumn>;
  end;

  TTriggerInfo = record
    TriggerName: string;
    EventManipulation: string;
    ActionTiming: string;
    ActionStatement: string;
    EventObjectTable: string;
  end;

  TTableInfo = class
    TableName: string;
    Columns: TList<TColumnInfo>;
    constructor Create;
    destructor Destroy; override;
  end;

  TCompareOptions = record
    NoDelete: Boolean;
    WithTriggers: Boolean;
    WithData: Boolean;
    WithDataDiff: Boolean;
    ExcludeTables: TStringList;
    IncludeTables: TStringList;
  end;

  TDBComparer = class
  private
    FConn1, FConn2: TUniConnection;
    FScript: TStringList;
    FOptions: TCompareOptions;
    function GetTables(Conn: TUniConnection; const DBName: string): TStringList;
    function GetTableStructure(Conn: TUniConnection;
                               const DBName, TableName: string): TTableInfo;
    function GetTableIndexes(Conn: TUniConnection;
                           const DBName, TableName: string): TArray<TIndexInfo>;
    function GetTriggers(Conn: TUniConnection;
                        const DBName: string): TArray<TTriggerInfo>;
    function GetTriggerDefinition(Conn: TUniConnection;
                                 const DBName, TriggerName: string): string;
    function GetViews(Conn: TUniConnection; const DBName: string): TStringList;
    function GetViewDefinition(Conn: TUniConnection;
                               const DBName, ViewName: string): string;
    function GetProcedures(Conn: TUniConnection;
                           const DBName: string): TStringList;
    function GetProcedureDefinition(Conn: TUniConnection;
                                    const DBName, ProcName: string): string;
    procedure CompareTables(const DB1, DB2: string);
    procedure CompareIndexes(Conn1, Conn2: TUniConnection;
                             const DB1, DB2, TableName: string);
    procedure CompareTriggers(const DB1, DB2: string);
    procedure CompareViews(const DB1, DB2: string);
    procedure CompareProcedures(const DB1, DB2: string);
    procedure CopyData(const DB1, DB2, TableName: string);
    procedure CompareAndSyncData(const DB1, DB2, TableName: string);
    function GetPrimaryKeyColumns(Conn: TUniConnection;
                                  const DBName, TableName: string): TStringList;
    function BuildWhereClause(const PKColumns: TStringList;
                              Query: TUniQuery): string;
    function BuildUpdateStatement(const TableName: string;
                                   const PKColumns: TStringList;
                                   Query: TUniQuery): string;
    function ColumnsAreEqual(const Col1, Col2: TColumnInfo): Boolean;
    function IndexesAreEqual(const Idx1, Idx2: TIndexInfo): Boolean;
    function TriggersAreEqual(const Trg1, Trg2: TTriggerInfo): Boolean;
    function GenerateColumnDefinition(const Col: TColumnInfo): string;
    function GenerateIndexDefinition(const TableName: string;
                                     const Idx: TIndexInfo): string;
    function StripDefiner(const SQL: string): string;
    function BuildUpdateStatementCommon(const TableName: string;
                                        const PKColumns: TStringList;
                                        const CommonFields: TStringList;
                                        Query: TUniQuery): string;
    function BuildInsertStatement(const TableName: string;
                                  const Fields, Values: TStringList): string;
    function EscapeSQL(const Value: string): string;
    function BytesToHex(const Bytes: TBytes): string;
  public
    constructor Create(const Server1, User1, Pass1, Port1, DB1: string;
                       const Server2, User2, Pass2, Port2, DB2: string;
                       const Options: TCompareOptions);
    destructor Destroy; override;
    function GenerateScript(const DB1, DB2: string): string;
  end;

{ TTableInfo }
constructor TTableInfo.Create;
begin
  Columns := TList<TColumnInfo>.Create;
end;
destructor TTableInfo.Destroy;
begin
  Columns.Free;
  inherited;
end;

{ TDBComparer }
constructor TDBComparer.Create(const Server1, User1, Pass1, Port1, DB1: string;
                               const Server2, User2, Pass2, Port2, DB2: string;
                               const Options: TCompareOptions);
begin
  FScript := TStringList.Create;
  FOptions := Options;
  if Options.IncludeTables <> nil then
  begin
    FOptions.IncludeTables := TStringList.Create;
    FOptions.IncludeTables.Assign(Options.IncludeTables);
    FOptions.IncludeTables.CaseSensitive := False; // Importante para SQL
  end
  else
    FOptions.IncludeTables := nil;
  // NUEVA: Crear una copia de la lista de exclusión si existe
  if (Options.ExcludeTables <> nil) then
  begin
    FOptions.ExcludeTables := TStringList.Create;
    FOptions.ExcludeTables.Assign(Options.ExcludeTables);
    FOptions.ExcludeTables.CaseSensitive := False;
    // MySQL no es case-sensitive por defecto
  end
  else
    FOptions.ExcludeTables := nil;
  // Conexión 1
  FConn1 := TUniConnection.Create(nil);
  FConn1.ProviderName := 'MySQL';
  FConn1.Server := Server1;
  FConn1.Port := StrToIntDef(Port1, 3306);
  FConn1.Username := User1;
  FConn1.Password := Pass1;
  FConn1.Database := 'information_schema';
  FConn1.Connected := True;
  // Conexión 2
  FConn2 := TUniConnection.Create(nil);
  FConn2.ProviderName := 'MySQL';
  FConn2.Server := Server2;
  FConn2.Port := StrToIntDef(Port2, 3306);
  FConn2.Username := User2;
  FConn2.Password := Pass2;
  FConn2.Database := 'information_schema';
  FConn2.Connected := True;
end;

destructor TDBComparer.Destroy;
begin
  FConn1.Free;
  FConn2.Free;
  FScript.Free;
  if (FOptions.ExcludeTables <> nil) then
    FOptions.ExcludeTables.Free;
  if (FOptions.IncludeTables <> nil) then
    FOptions.IncludeTables.Free;
  inherited;
end;

function TDBComparer.BuildInsertStatement(const TableName: string;
                                         const Fields, Values: TStringList): string;
var
  i: Integer;
  FieldList, ValueList: string;
begin
  // Construir lista de campos
  FieldList := '';
  for i := 0 to Fields.Count - 1 do
  begin
    if (i > 0) then
      FieldList := FieldList + ', ';
    FieldList := FieldList + Fields[i];  // Ya tienen los backticks
  end;
  // Construir lista de valores
  ValueList := '';
  for i := 0 to Values.Count - 1 do
  begin
    if (i > 0) then
      ValueList := ValueList + ', ';
    ValueList := ValueList + Values[i];  // Ya tienen las comillas necesarias
  end;
  Result := 'INSERT INTO `' + TableName + '` (' + FieldList +
            ') VALUES (' + ValueList + ')';
end;

function TDBComparer.GetTables(Conn: TUniConnection;
                               const DBName: string): TStringList;
var
  Query: TUniQuery;
begin
  Result := TStringList.Create;
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Conn;
    Query.SQL.Text := 'SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES ' +
                      'WHERE TABLE_SCHEMA = ' + QuotedStr(DBName) +
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

function TDBComparer.GetTableStructure(Conn: TUniConnection;
                                       const DBName,
                                             TableName: string): TTableInfo;
var
  Query: TUniQuery;
  Col: TColumnInfo;
begin
  Result := TTableInfo.Create;
  Result.TableName := TableName;
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Conn;
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
                      ' WHERE TABLE_SCHEMA = ' + QuotedStr(DBName) +
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

function TDBComparer.GetTableIndexes(Conn: TUniConnection;
                                     const DBName,
                                     TableName: string): TArray<TIndexInfo>;
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
      Query.Connection := Conn;
      // CORRECCIÓN: Concatenación adecuada
      Query.SQL.Text := 'SELECT INDEX_NAME, ' +
                        '       NON_UNIQUE, ' +
                        '       COLUMN_NAME, ' +
                        '       SEQ_IN_INDEX ' +
                        '  FROM INFORMATION_SCHEMA.STATISTICS ' +
                        ' WHERE TABLE_SCHEMA = ' + QuotedStr(DBName) +
                        '   AND TABLE_NAME = ' + QuotedStr(TableName) + ' ' +
                        'ORDER BY INDEX_NAME, SEQ_IN_INDEX';
      Query.Open;
      // ... (El resto del código dentro de este procedimiento está bien)
      LastIndexName := '';
      while not Query.Eof do
      begin
        if not SameText(Query.FieldByName('INDEX_NAME').AsString,
                        LastIndexName) then
        begin
          if not SameText(LastIndexName, '') then
          begin
            CurrentIndex.Columns := ColList.ToArray;
            IndexList.Add(CurrentIndex);
            ColList.Clear;
          end;
          LastIndexName := Query.FieldByName('INDEX_NAME').AsString;
          CurrentIndex.IndexName := LastIndexName;
          CurrentIndex.IsPrimary := SameText(LastIndexName, 'PRIMARY');
          CurrentIndex.IsUnique :=
                                (Query.FieldByName('NON_UNIQUE').AsInteger = 0);
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

function TDBComparer.GetTriggers(Conn: TUniConnection;
                                 const DBName: string): TArray<TTriggerInfo>;
var
  Query: TUniQuery;
  TriggerList: TList<TTriggerInfo>;
  Trigger: TTriggerInfo;
begin
  TriggerList := TList<TTriggerInfo>.Create;
  try
    Query := TUniQuery.Create(nil);
    try
      Query.Connection := Conn;
      // CORRECCIÓN: Concatenación y espacios
      Query.SQL.Text :=
        'SELECT TRIGGER_NAME, ' +
        '       EVENT_MANIPULATION, ' +
        '       ACTION_TIMING, ' +
        '       ACTION_STATEMENT, ' +
        '       EVENT_OBJECT_TABLE ' +
        '  FROM INFORMATION_SCHEMA.TRIGGERS ' +
        ' WHERE TRIGGER_SCHEMA = ' + QuotedStr(DBName) + ' ' +
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

function TDBComparer.GetTriggerDefinition(Conn: TUniConnection;
                                          const DBName,
                                          TriggerName: string): string;
var
  Query: TUniQuery;
  OldDB: string;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Conn;
    OldDB := Conn.Database;
    Conn.Database := DBName;
    Query.SQL.Text := 'SHOW CREATE TRIGGER `' + TriggerName + '`';
    Query.Open;
    Result := Query.Fields[2].AsString;
    Result := StripDefiner(Result);
    Conn.Database := OldDB;
  finally
    Query.Free;
  end;
end;

function TDBComparer.GetViews(Conn: TUniConnection;
                              const DBName: string): TStringList;
var
  Query: TUniQuery;
begin
  Result := TStringList.Create;
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Conn;
    Query.SQL.Text := 'SELECT TABLE_NAME' +
                      '  FROM INFORMATION_SCHEMA.VIEWS ' +
                      ' WHERE TABLE_SCHEMA = ' + QuotedStr(DBName) + ' ' +
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

function TDBComparer.StripDefiner(const SQL: string): string;
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

function TDBComparer.GetViewDefinition(Conn: TUniConnection;
                                       const DBName, ViewName: string): string;
var
  Query: TUniQuery;
  OldDB: string;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Conn;
    OldDB := Conn.Database;
    Conn.Database := DBName;
    Query.SQL.Text := 'SHOW CREATE VIEW `' + ViewName + '`';
    Query.Open;
    Result := Query.Fields[1].AsString;
    Result := StripDefiner(Result);
    Conn.Database := OldDB;
  finally
    Query.Free;
  end;
end;

function TDBComparer.GetProcedures(Conn: TUniConnection;
                                   const DBName: string): TStringList;
var
  Query: TUniQuery;
begin
  Result := TStringList.Create;
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Conn;
    Query.SQL.Text := 'SELECT ROUTINE_NAME '+
                      '  FROM INFORMATION_SCHEMA.ROUTINES ' +
                      ' WHERE ROUTINE_SCHEMA = ' + QuotedStr(DBName) + ' ' +
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

function TDBComparer.GetProcedureDefinition(Conn: TUniConnection;
                                            const DBName,
                                            ProcName: string): string;
var
  Query: TUniQuery;
  OldDB: string;
begin
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Conn;
    OldDB := Conn.Database;
    Conn.Database := DBName;
    Query.SQL.Text := 'SHOW CREATE PROCEDURE `' + ProcName + '`';
    Query.Open;
    Result := Query.Fields[2].AsString;
    Result := StripDefiner(Result);
    Conn.Database := OldDB;
  finally
    Query.Free;
  end;
end;

function TDBComparer.ColumnsAreEqual(const Col1, Col2: TColumnInfo): Boolean;
  function NormalizeType(const AType: string): string;
  var
    S: string;
    PStart, PEnd: Integer;
  begin
    S := LowerCase(Trim(AType));
    if StartsText('int', S) or
       StartsText('tinyint', S) or
       StartsText('smallint', S) then
    begin
      PStart := Pos('(', S);
      PEnd := Pos(')', S);
      if (PStart > 0) and (PEnd > PStart) then
        S := Copy(S, 1, PStart - 1) + Copy(S, PEnd + 1, MaxInt);
    end;
    Result := StringReplace(S, ' ', '', [rfReplaceAll]);
  end;

  function NormalizeExtra(const AExtra: string): string;
  begin
    Result := LowerCase(Trim(AExtra));
  end;

var
  Typ1, Typ2: string;
  Null1, Null2, Key1, Key2, Extra1, Extra2, Def1, Def2: string;
  IsAutoInc: Boolean;
begin
  Typ1 := NormalizeType(Col1.DataType);
  Typ2 := NormalizeType(Col2.DataType);
  Null1 := LowerCase(Trim(Col1.IsNullable));
  Null2 := LowerCase(Trim(Col2.IsNullable));
  Key1 := LowerCase(Trim(Col1.ColumnKey));
  Key2 := LowerCase(Trim(Col2.ColumnKey));
  Extra1 := NormalizeExtra(Col1.Extra);
  Extra2 := NormalizeExtra(Col2.Extra);
  Def1 := Trim(Col1.ColumnDefault);
  Def2 := Trim(Col2.ColumnDefault);
  Result := (Typ1 = Typ2) and
            (Null1 = Null2) and
            (Key1 = Key2) and
            (Extra1 = Extra2);
  if Result then
  begin
    IsAutoInc := (Pos('auto_increment', Extra1) > 0)
                  or (Pos('auto_increment', Extra2) > 0);
    if not IsAutoInc then
    begin
      if SameText(Def1, 'NULL') then Def1 := '';
      if SameText(Def2, 'NULL') then Def2 := '';
      if not SameText(Def1, Def2) then
        Result := False;
    end;
  end;
  if Result then
    Result := SameText(Col1.ColumnComment, Col2.ColumnComment);
end;

function TDBComparer.IndexesAreEqual(const Idx1, Idx2: TIndexInfo): Boolean;
var
  i: Integer;
begin
  Result := SameText(Idx1.IndexName, Idx2.IndexName) and
            (Idx1.IsUnique = Idx2.IsUnique) and
            (Idx1.IsPrimary = Idx2.IsPrimary) and
            (Length(Idx1.Columns) = Length(Idx2.Columns));
  if Result then
  begin
    for i := 0 to High(Idx1.Columns) do
    begin
      if not(SameText(Idx1.Columns[i].ColumnName, Idx2.Columns[i].ColumnName))
         or (Idx1.Columns[i].SeqInIndex <> Idx2.Columns[i].SeqInIndex) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;

function TDBComparer.TriggersAreEqual(const Trg1, Trg2: TTriggerInfo): Boolean;
begin
  Result := SameText(Trg1.TriggerName, Trg2.TriggerName) and
            (Trg1.EventManipulation = Trg2.EventManipulation) and
            (Trg1.ActionTiming = Trg2.ActionTiming) and
            (Trim(Trg1.ActionStatement) = Trim(Trg2.ActionStatement));
end;

function TDBComparer.GenerateColumnDefinition(const Col: TColumnInfo): string;
var
  DefVal: string;
begin
  Result := '`' + Col.ColumnName + '` ' + Col.DataType;
  if SameText(Col.IsNullable, 'NO') then
    Result := Result + ' NOT NULL'
  else
    Result := Result + ' NULL';
  if ((not SameText(Col.ColumnDefault, '')) and
      (not SameText(Col.ColumnDefault, 'NULL'))) then
  begin
    // Caso especial para funciones de fecha
    if (Pos('CURRENT_TIMESTAMP', UpperCase(Col.ColumnDefault)) > 0) or
       (Pos('NOW()', UpperCase(Col.ColumnDefault)) > 0) then
    begin
      Result := Result + ' DEFAULT ' + Col.ColumnDefault;
    end
    else
    begin
      // CORRECCIÓN CRÍTICA:
      // Algunos drivers/versiones de MySQL devuelven
      // el default ya con comillas (ej: 'N').
      // Si aplicamos QuotedStr sobre 'N', obtenemos '''N'''
      //(3 caracteres), lo cual rompe varchar(1).
      DefVal := Col.ColumnDefault;
      // Si empieza y termina con comilla simple, se las quitamos antes de procesar
      if ((Length(DefVal) >= 2) and
          (DefVal[1] = '''') and
          (DefVal[Length(DefVal)] = '''')) then
        DefVal := Copy(DefVal, 2, Length(DefVal) - 2);
      Result := Result + ' DEFAULT ' + QuotedStr(DefVal);
    end;
  end
  else if Col.ColumnDefault = 'NULL' then
    Result := Result + ' DEFAULT NULL';
  if Pos('auto_increment', LowerCase(Col.Extra)) > 0 then
    Result := Result + ' AUTO_INCREMENT';
  if Pos('on update', LowerCase(Col.Extra)) > 0 then
    Result := Result + ' ON UPDATE CURRENT_TIMESTAMP';
  if not SameText(Col.ColumnComment, '') then
    Result := Result + ' COMMENT ' + QuotedStr(Col.ColumnComment);
end;

function TDBComparer.GenerateIndexDefinition(const TableName: string;
                                             const Idx: TIndexInfo): string;
var
  i: Integer;
  ColNames: string;
begin
  ColNames := '';
  for i := 0 to High(Idx.Columns) do
  begin
    if i > 0 then
      ColNames := ColNames + ', ';
    ColNames := ColNames + '`' + Idx.Columns[i].ColumnName + '`';
  end;
  if Idx.IsPrimary then
    Result := 'ALTER TABLE `' + TableName +
              '` ADD PRIMARY KEY (' + ColNames + ')'
  else if Idx.IsUnique then
    Result := 'ALTER TABLE `' + TableName +
              '` ADD UNIQUE INDEX `' + Idx.IndexName + '` (' + ColNames + ')'
  else
    Result := 'ALTER TABLE `' + TableName +
              '` ADD INDEX `' + Idx.IndexName + '` (' + ColNames + ')';
end;

procedure TDBComparer.CompareIndexes(Conn1, Conn2: TUniConnection;
                                     const DB1, DB2, TableName: string);
var
  Indexes1, Indexes2: TArray<TIndexInfo>;
  i, j: Integer;
  Found: Boolean;
begin
  Indexes1 := GetTableIndexes(Conn1, DB1, TableName);
  Indexes2 := GetTableIndexes(Conn2, DB2, TableName);
  // 1. Índices que existen en DB2 pero no en DB1 (ELIMINAR)
  if not FOptions.NoDelete then
  begin
    for i := 0 to High(Indexes2) do
    begin
      // Nota: Normalmente no eliminamos la PK
      //aquí si vamos a recrearla después,
      // pero por seguridad saltamos la PK aquí
      //y dejamos que la lógica de modificación la maneje.
      if Indexes2[i].IsPrimary then
        Continue;
      Found := False;
      for j := 0 to High(Indexes1) do
      begin
        if Indexes1[j].IndexName = Indexes2[i].IndexName then
        begin
          Found := True;
          Break;
        end;
      end;
      if not Found then
      begin
        FScript.Add('-- Eliminar índice: ' + TableName + '.' +
                     Indexes2[i].IndexName);
        FScript.Add('ALTER TABLE `' + TableName +
                    '` DROP INDEX `' + Indexes2[i].IndexName + '`;');
        FScript.Add('');
      end;
    end;
  end;
  // 2. Índices nuevos o modificados (CREAR o RECREAR)
  for i := 0 to High(Indexes1) do
  begin
    Found := False;
    for j := 0 to High(Indexes2) do
    begin
      // Comparamos por nombre (PRIMARY siempre se llama PRIMARY en MySQL)
      if Indexes1[i].IndexName = Indexes2[j].IndexName then
      begin
        Found := True;
        // Si existen pero son diferentes
        //(distintas columnas o tipo), hay que recrear
        if not IndexesAreEqual(Indexes1[i], Indexes2[j]) then
        begin
          FScript.Add('-- Modificar índice: ' + TableName + '.' +
                       Indexes1[i].IndexName);
          // --- CORRECCIÓN AQUÍ ---
          // Antes, el código evitaba borrar si era PRIMARY.
          //Ahora lo gestionamos explícitamente.
          if Indexes1[i].IsPrimary then
            FScript.Add('ALTER TABLE `' + TableName + '` DROP PRIMARY KEY;')
          else
            FScript.Add('ALTER TABLE `' + TableName +
                        '` DROP INDEX `' + Indexes1[i].IndexName + '`;');
          // -----------------------
          FScript.Add(GenerateIndexDefinition(TableName, Indexes1[i]) + ';');
          FScript.Add('');
        end;
        Break;
      end;
    end;
    if not Found then
    begin
      FScript.Add('-- Agregar índice: ' + TableName + '.' + Indexes1[i].IndexName);
      FScript.Add(GenerateIndexDefinition(TableName, Indexes1[i]) + ';');
      FScript.Add('');
    end;
  end;
end;

procedure TDBComparer.CompareTriggers(const DB1, DB2: string);
var
  Triggers1, Triggers2: TArray<TTriggerInfo>;
  i, j: Integer;
  Found: Boolean;
  TriggerDef: string;
begin
  Triggers1 := GetTriggers(FConn1, DB1);
  Triggers2 := GetTriggers(FConn2, DB2);
  FScript.Add('-- ========================================');
  FScript.Add('-- TRIGGERS');
  FScript.Add('-- ========================================');
  FScript.Add('');
  // Triggers que existen en DB2 pero no en DB1 (eliminar solo si NO está --nodelete)
  if not FOptions.NoDelete then
  begin
    for i := 0 to High(Triggers2) do
    begin
      Found := False;
      for j := 0 to High(Triggers1) do
      begin
        if Triggers1[j].TriggerName = Triggers2[i].TriggerName then
        begin
          Found := True;
          Break;
        end;
      end;
      if not Found then
      begin
        FScript.Add('-- Eliminar trigger: ' + Triggers2[i].TriggerName);
        FScript.Add('DROP TRIGGER IF EXISTS `' + Triggers2[i].TriggerName + '`;');
        FScript.Add('');
      end;
    end;
  end;
  // Triggers nuevos o modificados
  for i := 0 to High(Triggers1) do
  begin
    Found := False;
    for j := 0 to High(Triggers2) do
    begin
      if Triggers1[i].TriggerName = Triggers2[j].TriggerName then
      begin
        Found := True;
        // Si son diferentes, recrear
        if not TriggersAreEqual(Triggers1[i], Triggers2[j]) then
        begin
          FScript.Add('-- Modificar trigger: ' + Triggers1[i].TriggerName);
          FScript.Add('DROP TRIGGER IF EXISTS `' + Triggers1[i].TriggerName + '`;');
          FScript.Add('');
          TriggerDef := GetTriggerDefinition(FConn1, DB1, Triggers1[i].TriggerName);
          FScript.Add(TriggerDef + ' $$');
          FScript.Add('');
        end;
        Break;
      end;
    end;
    // Trigger nuevo
    if not Found then
    begin
      FScript.Add('-- Agregar trigger: ' + Triggers1[i].TriggerName);
      TriggerDef := GetTriggerDefinition(FConn1, DB1, Triggers1[i].TriggerName);
      FScript.Add(TriggerDef + ' $$');
      FScript.Add('');
    end;
  end;
end;

function TDBComparer.GetPrimaryKeyColumns(Conn: TUniConnection;
                                          const DBName,
                                          TableName: string): TStringList;
var
  Query: TUniQuery;
begin
  Result := TStringList.Create;
  Query := TUniQuery.Create(nil);
  try
    Query.Connection := Conn;
    Query.SQL.Text :=
      'SELECT COLUMN_NAME ' +
      '  FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE ' +
      ' WHERE TABLE_SCHEMA = ' + QuotedStr(DBName) +
      '   AND TABLE_NAME = ' + QuotedStr(TableName) +
      '   AND CONSTRAINT_NAME = ''PRIMARY'' ' +
      'ORDER BY ORDINAL_POSITION';
    Query.Open;
    while not Query.Eof do
    begin
      Result.Add(Query.FieldByName('COLUMN_NAME').AsString);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TDBComparer.BuildWhereClause(const PKColumns: TStringList;
                                      Query: TUniQuery): string;
var
  i: Integer;
  Value: string;
begin
  Result := '';
  for i := 0 to PKColumns.Count - 1 do
  begin
    if i > 0 then
      Result := Result + ' AND ';
    if Query.FieldByName(PKColumns[i]).IsNull then
      Result := Result + '`' + PKColumns[i] + '` IS NULL'
    else
    begin
      case Query.FieldByName(PKColumns[i]).DataType of
        ftString, ftWideString, ftMemo, ftWideMemo, ftFmtMemo:
          Value := QuotedStr(Query.FieldByName(PKColumns[i]).AsString);
        ftDate, ftTime, ftDateTime, ftTimeStamp:
          Value := '''' + FormatDateTime('yyyy-mm-dd hh:nn:ss',
                            Query.FieldByName(PKColumns[i]).AsDateTime) + '''';
        ftBoolean:
          Value := IntToStr(Ord(Query.FieldByName(PKColumns[i]).AsBoolean));
      else
        Value := Query.FieldByName(PKColumns[i]).AsString;
      end;
      Result := Result + '`' + PKColumns[i] + '` = ' + Value;
    end;
  end;
end;

function TDBComparer.BytesToHex(const Bytes: TBytes): string;
var
  i: Integer;
begin
  Result := '';
  for i := Low(Bytes) to High(Bytes) do
    Result := Result + IntToHex(Bytes[i], 2);
end;

function TDBComparer.BuildUpdateStatement(const TableName: string;
                                          const PKColumns: TStringList;
                                          Query: TUniQuery): string;
var
  i: Integer;
  FieldName, Value: string;
  SetClause: string;
begin
  SetClause := '';
  for i := 0 to Query.FieldCount - 1 do
  begin
    FieldName := Query.Fields[i].FieldName;
    if PKColumns.IndexOf(FieldName) >= 0 then
      Continue;
    if not SameText(SetClause, '') then
      SetClause := SetClause + ', ';
    if Query.Fields[i].IsNull then
      SetClause := SetClause + '`' + FieldName + '` = NULL'
    else
    begin
      case Query.Fields[i].DataType of
        ftString, ftWideString, ftMemo, ftWideMemo, ftFmtMemo:
          Value := QuotedStr(Query.Fields[i].AsString);
        ftDate, ftTime, ftDateTime, ftTimeStamp:
          Value := '''' + FormatDateTime('yyyy-mm-dd hh:nn:ss',
                            Query.Fields[i].AsDateTime) + '''';
        ftBoolean:
          Value := IntToStr(Ord(Query.Fields[i].AsBoolean));
      else
        Value := Query.Fields[i].AsString;
      end;
      SetClause := SetClause + '`' + FieldName + '` = ' + Value;
    end;
  end;

  Result := 'UPDATE `' + TableName + '` SET ' + SetClause +
            ' WHERE ' + BuildWhereClause(PKColumns, Query);
end;

procedure TDBComparer.CompareAndSyncData(const DB1, DB2, TableName: string);
var
  Query1, Query2: TUniQuery;
  PKColumns: TStringList;
  CommonFields: TStringList;  // NUEVA: Lista de campos comunes
  Fields: TStringList;
  Values: TStringList;
  i: Integer;
  FieldName, FieldValue: string;
  WhereClause: string;
  RecordExists: Boolean;
  RecordsDiffer: Boolean;
  InsertedCount, UpdatedCount, DeletedCount: Integer;
begin
  Query1 := TUniQuery.Create(nil);
  Query2 := TUniQuery.Create(nil);
  PKColumns := TStringList.Create;
  CommonFields := TStringList.Create;  // NUEVA
  Fields := TStringList.Create;
  Values := TStringList.Create;
  try
    Query1.Connection := FConn1;
    Query2.Connection := FConn2;
    // Obtener columnas de clave primaria
    PKColumns := GetPrimaryKeyColumns(FConn1, DB1, TableName);
    if PKColumns.Count = 0 then
    begin
      FScript.Add('-- ADVERTENCIA: Tabla ' + TableName +
                  ' no tiene clave primaria. Se omite comparación de datos.');
      FScript.Add('');
      Exit;
    end;
    InsertedCount := 0;
    UpdatedCount := 0;
    DeletedCount := 0;
    FScript.Add('-- ========================================');
    FScript.Add('-- SINCRONIZAR DATOS: ' + TableName);
    FScript.Add('-- Clave primaria: ' + PKColumns.CommaText);
    FScript.Add('-- ========================================');
    FScript.Add('');
    // Cambiar a las bases de datos correspondientes
    FConn1.Database := DB1;
    FConn2.Database := DB2;
    // NUEVO: Identificar campos comunes entre ambas tablas
    Query1.SQL.Text := 'SELECT * FROM `' + TableName + '` LIMIT 0';
    Query1.Open;
    Query2.SQL.Text := 'SELECT * FROM `' + TableName + '` LIMIT 0';
    Query2.Open;
    for i := 0 to Query1.FieldCount - 1 do
    begin
      FieldName := Query1.Fields[i].FieldName;
      // Solo agregar si existe en ambas tablas
      if (Query2.FindField(FieldName) <> nil) then
        CommonFields.Add(FieldName);
    end;
    if (CommonFields.Count = 0) then
    begin
      FScript.Add('-- ADVERTENCIA: No hay campos comunes entre ambas tablas.');
      FScript.Add('');
      Exit;
    end;
    FScript.Add('-- Campos comunes: ' + CommonFields.CommaText);
    FScript.Add('');
    // Obtener todos los registros de origen
    Query1.Close;
    Query1.SQL.Text := 'SELECT * FROM `' + TableName + '`';
    Query1.Open;
    while not Query1.Eof do
    begin
      // Construir WHERE con la clave primaria
      WhereClause := BuildWhereClause(PKColumns, Query1);
      // Verificar si existe en destino
      Query2.Close;
      Query2.SQL.Text := 'SELECT * FROM `' + TableName + '` WHERE ' + WhereClause;
      Query2.Open;
      RecordExists := not Query2.IsEmpty;
      if not RecordExists then
      begin
        // Registro nuevo - INSERT (solo campos comunes)
        Fields.Clear;
        Values.Clear;
        for i := 0 to CommonFields.Count - 1 do
        begin
          FieldName := CommonFields[i];
          Fields.Add('`' + FieldName + '`');
          if Query1.FieldByName(FieldName).IsNull then
            Values.Add('NULL')
          else
          begin
            case Query1.FieldByName(FieldName).DataType of
              ftString, ftWideString:
                Values.Add(QuotedStr(Query1.FieldByName(FieldName).AsString));
                ftMemo, ftWideMemo, ftFmtMemo:
                // Para campos grandes, usar escape manual
                Values.Add(EscapeSQL(Query1.FieldByName(FieldName).AsString));
              ftDate, ftTime, ftDateTime, ftTimeStamp:
                Values.Add(QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',
                                    Query1.FieldByName(FieldName).AsDateTime)));
              ftBoolean:
                Values.Add(IntToStr(Ord(
                                     Query1.FieldByName(FieldName).AsBoolean)));
              ftBlob, ftGraphic, ftVarBytes, ftBytes:
                begin
                  // MySQL acepta hexadecimales como 0xAABBCC...
                  Values.Add('0x' + BytesToHex(Query1.Fields[i].AsBytes));
                end;
            else
              Values.Add(Query1.FieldByName(FieldName).AsString);
            end;
          end;
        end;
        FScript.Add('-- INSERT nuevo registro (PK: ' + WhereClause + ')');
        FScript.Add(BuildInsertStatement(TableName, Fields, Values) + ';');
        FScript.Add('');
        Inc(InsertedCount);
      end
      else
      begin
        // Registro existe - verificar si hay diferencias
        //(solo en campos comunes)
        RecordsDiffer := False;
        for i := 0 to CommonFields.Count - 1 do
        begin
          FieldName := CommonFields[i];
          // Saltar campos de clave primaria
          if PKColumns.IndexOf(FieldName) >= 0 then
            Continue;
          // Comparar valores
          if (Query1.FieldByName(FieldName).IsNull <>
                                      Query2.FieldByName(FieldName).IsNull) then
          begin
            RecordsDiffer := True;
            Break;
          end;
          if not Query1.FieldByName(FieldName).IsNull then
          begin
            if not SameText(Query1.FieldByName(FieldName).AsString,
                                    Query2.FieldByName(FieldName).AsString) then
            begin
              RecordsDiffer := True;
              Break;
            end;
          end;
        end;
        if RecordsDiffer then
        begin
          // Generar UPDATE (usando campos comunes)
          FScript.Add('-- UPDATE registro modificado (PK: ' + WhereClause + ')');
          FScript.Add(BuildUpdateStatementCommon(TableName,
                                                 PKColumns,
                                                 CommonFields,
                                                 Query1) + ';');
          FScript.Add('');
          Inc(UpdatedCount);
        end;
      end;
      Query1.Next;
    end;
    // Verificar registros que están en destino pero no en origen (DELETE)
    if not FOptions.NoDelete then
    begin
      Query2.Close;
      Query2.SQL.Text := 'SELECT * FROM `' + TableName + '`';
      Query2.Open;
      while not Query2.Eof do
      begin
        WhereClause := BuildWhereClause(PKColumns, Query2);
        // Verificar si existe en origen
        Query1.Close;
        Query1.SQL.Text := 'SELECT * FROM `' + TableName +
                           '` WHERE ' + WhereClause;
        Query1.Open;
        if Query1.IsEmpty then
        begin
          FScript.Add('-- DELETE registro eliminado (PK: ' + WhereClause + ')');
          FScript.Add('DELETE FROM `' + TableName +
                      '` WHERE ' + WhereClause + ';');
          FScript.Add('');
          Inc(DeletedCount);
        end;
        Query2.Next;
      end;
    end;
    // Resumen
    FScript.Add('-- Resumen ' + TableName + ': ' +
                IntToStr(InsertedCount) + ' insertados, ' +
                IntToStr(UpdatedCount) + ' actualizados' +
                IfThen(FOptions.NoDelete, '', ', ' +
                       IntToStr(DeletedCount) + ' eliminados'));
    FScript.Add('');
    // Restaurar base de datos
    FConn1.Database := 'information_schema';
    FConn2.Database := 'information_schema';
  finally
    Query1.Free;
    Query2.Free;
    PKColumns.Free;
    CommonFields.Free;  // NUEVA
    Fields.Free;
    Values.Free;
  end;
end;
// NUEVA FUNCIÓN: BuildUpdateStatement que solo usa campos comunes
function TDBComparer.BuildUpdateStatementCommon(const TableName: string;
                                          const PKColumns: TStringList;
                                          const CommonFields: TStringList;
                                          Query: TUniQuery): string;
var
  i: Integer;
  FieldName, Value: string;
  SetClause: string;
begin
  SetClause := '';
  // Construir cláusula SET solo con campos comunes, excepto las PKs
  for i := 0 to CommonFields.Count - 1 do
  begin
    FieldName := CommonFields[i];
    // Saltar campos de clave primaria
    if PKColumns.IndexOf(FieldName) >= 0 then
      Continue;
    if not SameText(SetClause, '') then
      SetClause := SetClause + ', ';
    if Query.FieldByName(FieldName).IsNull then
      SetClause := SetClause + '`' + FieldName + '` = NULL'
    else
    begin
      case Query.FieldByName(FieldName).DataType of
        ftString, ftWideString, ftMemo, ftWideMemo, ftFmtMemo:
          Value := QuotedStr(Query.FieldByName(FieldName).AsString);
        ftDate, ftTime, ftDateTime, ftTimeStamp:
          Value := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',
                            Query.FieldByName(FieldName).AsDateTime));
        ftBoolean:
          Value := IntToStr(Ord(Query.FieldByName(FieldName).AsBoolean));
      else
        Value := Query.FieldByName(FieldName).AsString;
      end;
      SetClause := SetClause + '`' + FieldName + '` = ' + Value;
    end;
  end;
  Result := 'UPDATE `' + TableName + '` SET ' + SetClause +
            ' WHERE ' + BuildWhereClause(PKColumns, Query);
end;

procedure TDBComparer.CopyData(const DB1, DB2, TableName: string);
var
  Query: TUniQuery;
  InsertQuery: TUniQuery;
  Fields: TStringList;
  Values: TStringList;
  i: Integer;
  FieldName: string;
begin
  Query := TUniQuery.Create(nil);
  InsertQuery := TUniQuery.Create(nil);
  Fields := TStringList.Create;
  Values := TStringList.Create;
  try
    Query.Connection := FConn1;
    InsertQuery.Connection := FConn2;
    FConn1.Database := DB1;
    Query.SQL.Text := 'SELECT * FROM `' + TableName + '`';
    Query.Open;
    if Query.RecordCount > 0 then
    begin
      FScript.Add('-- ========================================');
      FScript.Add('-- COPIAR DATOS: ' + TableName);
      FScript.Add('-- ========================================');
      FScript.Add('');
      while not Query.Eof do
      begin
        Fields.Clear;
        Values.Clear;
        for i := 0 to Query.FieldCount - 1 do
        begin
          FieldName := Query.Fields[i].FieldName;
          Fields.Add('`' + FieldName + '`');
          if Query.Fields[i].IsNull then
            Values.Add('NULL')
          else
          begin
            case Query.Fields[i].DataType of
              ftString, ftWideString, ftMemo, ftWideMemo, ftFmtMemo:
                Values.Add(QuotedStr(Query.Fields[i].AsString));
              ftDate, ftTime, ftDateTime, ftTimeStamp:
                // CORREGIDO: Usar comillas simples directamente
                Values.Add('''' + FormatDateTime('yyyy-mm-dd hh:nn:ss',
                                                  Query.Fields[i].AsDateTime) + '''');
              ftBoolean:
                Values.Add(IntToStr(Ord(Query.Fields[i].AsBoolean)));
              ftBlob, ftGraphic, ftVarBytes, ftBytes:
                begin
                  // MySQL acepta hexadecimales como 0xAABBCC...
                  Values.Add('0x' + BytesToHex(Query.Fields[i].AsBytes));
                end;
            else
              Values.Add(Query.Fields[i].AsString);
            end;
          end;
        end;
          FScript.Add(StringReplace(BuildInsertStatement(TableName,
                                                         Fields,
                                                         Values),
                                    'INSERT INTO',
                                    'INSERT IGNORE INTO',
                                    [])
                      + ';');
          Query.Next;
      end;
      FScript.Add('');
    end;

    FConn1.Database := 'information_schema';
  finally
    Query.Free;
    InsertQuery.Free;
    Fields.Free;
    Values.Free;
  end;
end;

procedure TDBComparer.CompareTables(const DB1, DB2: string);
var
  Tables1, Tables2: TStringList;
  PKList: TStringList; // Para recolectar columnas PK
  i, j, k: Integer;
  Table1, Table2: TTableInfo;
  Found: Boolean;
  Col1, Col2: TColumnInfo;
  Indexes: TArray<TIndexInfo>;
  Idx: TIndexInfo;
begin
  Tables1 := GetTables(FConn1, DB1);
  Tables2 := GetTables(FConn2, DB2);
  try
    FScript.Add('-- ========================================');
    FScript.Add('-- COMPARACIÓN DE TABLAS');
    FScript.Add('-- ========================================');
    FScript.Add('');
    // 1. Tablas eliminadas (solo si NO está --nodelete)
    if not FOptions.NoDelete then
    begin
      for i := 0 to Tables2.Count - 1 do
      begin
        if Tables1.IndexOf(Tables2[i]) = -1 then
        begin
          FScript.Add('-- Tabla eliminada: ' + Tables2[i]);
          FScript.Add('DROP TABLE IF EXISTS `' + Tables2[i] + '`;');
          FScript.Add('');
        end;
      end;
    end;
    // 2. Iterar tablas de origen
    for i := 0 to Tables1.Count - 1 do
    begin
      if Tables2.IndexOf(Tables1[i]) = -1 then
      begin
        // ============================================================
        // CASO A: TABLA NUEVA (CREATE TABLE COMPLETO)
        // ============================================================
        FScript.Add('-- Tabla nueva: ' + Tables1[i]);
        Table1 := GetTableStructure(FConn1, DB1, Tables1[i]);
        PKList := TStringList.Create;
        try
          FScript.Add('CREATE TABLE `' + Tables1[i] + '` (');
          // Generar definiciones de columnas
          for j := 0 to Table1.Columns.Count - 1 do
          begin
            Col1 := Table1.Columns[j];
            // Detectar si es parte de la Primary Key
            if Col1.ColumnKey = 'PRI' then
              PKList.Add('`' + Col1.ColumnName + '`');
            // Escribir definición de columna
            // Nota: Si no es la última columna, ponemos coma.
            // PERO, si es la última columna y HAY Primary Key pendiente, también necesitamos coma.
            if j < Table1.Columns.Count - 1 then
              FScript.Add('  ' + GenerateColumnDefinition(Col1) + ',')
            else
            begin
              // Es la última columna
              if PKList.Count > 0 then
                FScript.Add('  ' + GenerateColumnDefinition(Col1) + ',')
              else
                FScript.Add('  ' + GenerateColumnDefinition(Col1));
            end;
          end;
          // Definir PRIMARY KEY inline (Obligatorio para AUTO_INCREMENT)
          if PKList.Count > 0 then
          begin
            FScript.Add('  PRIMARY KEY (' + PKList.CommaText + ')');
          end;
          FScript.Add(');');
          FScript.Add('');
          // Agregar Índices Secundarios (NO Primary, esos ya están)
          Indexes := GetTableIndexes(FConn1, DB1, Tables1[i]);
          for Idx in Indexes do
          begin
            if not Idx.IsPrimary then
            begin
              FScript.Add('-- Agregar índice secundario: ' + Idx.IndexName);
              FScript.Add(GenerateIndexDefinition(Tables1[i], Idx) + ';');
              FScript.Add('');
            end;
          end;
        finally
          Table1.Free;
          PKList.Free;
        end;
      end
      else
      begin
        // ============================================================
        // CASO B: TABLA EXISTENTE (COMPARAR ESTRUCTURA)
        // ============================================================
        Table1 := GetTableStructure(FConn1, DB1, Tables1[i]);
        Table2 := GetTableStructure(FConn2, DB2, Tables1[i]);
        try
          // B.1 Buscar columnas nuevas o modificadas
          for j := 0 to Table1.Columns.Count - 1 do
          begin
            Col1 := Table1.Columns[j];
            Found := False;
            for k := 0 to Table2.Columns.Count - 1 do
            begin
              if Table2.Columns[k].ColumnName = Col1.ColumnName then
              begin
                Found := True;
                Col2 := Table2.Columns[k];
                if not ColumnsAreEqual(Col1, Col2) then
                begin
                  FScript.Add('-- Modificar columna: ' + Tables1[i] + '.' + Col1.ColumnName);
                  FScript.Add('ALTER TABLE `' + Tables1[i] +
                              '` MODIFY COLUMN ' +
                             GenerateColumnDefinition(Col1) + ';');
                  FScript.Add('');
                end;
                Break;
              end;
            end;
            if not Found then
            begin
              FScript.Add('-- Agregar columna: ' + Tables1[i] + '.' + Col1.ColumnName);
              FScript.Add('ALTER TABLE `' + Tables1[i] + '` ADD COLUMN ' +
                         GenerateColumnDefinition(Col1) + ';');
              FScript.Add('');
            end;
          end;
          // B.2 Columnas eliminadas (solo si NO está --nodelete)
          if not FOptions.NoDelete then
          begin
            for j := 0 to Table2.Columns.Count - 1 do
            begin
              Col2 := Table2.Columns[j];
              Found := False;
              for k := 0 to Table1.Columns.Count - 1 do
              begin
                if Table1.Columns[k].ColumnName = Col2.ColumnName then
                begin
                  Found := True;
                  Break;
                end;
              end;
              if not Found then
              begin
                FScript.Add('-- Eliminar columna: ' + Tables1[i] + '.' + Col2.ColumnName);
                FScript.Add('ALTER TABLE `' + Tables1[i] +
                            '` DROP COLUMN `' + Col2.ColumnName + '`;');
                FScript.Add('');
              end;
            end;
          end;
        finally
          Table1.Free;
          Table2.Free;
        end;
        // B.3 Comparar índices (Solo para tablas existentes)
        CompareIndexes(FConn1, FConn2, DB1, DB2, Tables1[i]);
      end;
     // ============================================================
      // 3. SINCRONIZACIÓN DE DATOS
      // ============================================================
      // LOGICA DE FILTRADO:
      // 1. Si hay lista de INCLUSIÓN, la tabla DEBE estar en ella.
      // 2. Si NO hay lista de inclusión, verificamos la de EXCLUSIÓN.
      if ((FOptions.WithData or FOptions.WithDataDiff)) then
      begin
        // Caso A: El usuario definió --include-tables
        if ((FOptions.IncludeTables <> nil) and
            (FOptions.IncludeTables.Count > 0)) then
        begin
          if FOptions.IncludeTables.IndexOf(Tables1[i]) = -1 then
            Continue; // Saltar si la tabla no está en la lista blanca
        end
        // Caso B: No hay whitelist, miramos si está excluida
        else if ((FOptions.ExcludeTables <> nil) and
                 (FOptions.ExcludeTables.IndexOf(Tables1[i]) >= 0)) then
        begin
            Continue; // Saltar si la tabla está en la lista negra
        end;
        // Si pasa los filtros, procesar datos
        if FOptions.WithData then
          CopyData(DB1, DB2, Tables1[i])
        else if FOptions.WithDataDiff then
          CompareAndSyncData(DB1, DB2, Tables1[i]);
      end;
    end; // Fin bucle principal de tablas
  finally
    Tables1.Free;
    Tables2.Free;
  end;
end;

procedure TDBComparer.CompareViews(const DB1, DB2: string);
var
  Views: TStringList;
  i: Integer;
  ViewDef: string;
begin
  Views := GetViews(FConn1, DB1);
  try
    FScript.Add('-- ========================================');
    FScript.Add('-- VISTAS (DROP + CREATE)');
    FScript.Add('-- ========================================');
    FScript.Add('');
    for i := 0 to Views.Count - 1 do
    begin
      FScript.Add('DROP VIEW IF EXISTS `' + Views[i] + '`;');
      FScript.Add('');
      ViewDef := GetViewDefinition(FConn1, DB1, Views[i]);
      FScript.Add(ViewDef + ';');
      FScript.Add('');
    end;
  finally
    Views.Free;
  end;
end;

function TDBComparer.EscapeSQL(const Value: string): string;
var
  i: Integer;
begin
  Result := '''';
  for i := 1 to Length(Value) do
  begin
    if Value[i] = '''' then
      Result := Result + ''''''  // Duplicar comilla simple
    else if Value[i] = '\' then
      Result := Result + '\\'    // Escapar backslash
    else
      Result := Result + Value[i];
  end;
  Result := Result + '''';
end;

procedure TDBComparer.CompareProcedures(const DB1, DB2: string);
var
  Procedures: TStringList;
  i: Integer;
  ProcDef: string;
begin
  Procedures := GetProcedures(FConn1, DB1);
  try
    FScript.Add('-- ========================================');
    FScript.Add('-- PROCEDIMIENTOS (DROP + CREATE)');
    FScript.Add('-- ========================================');
    FScript.Add('');
    for i := 0 to Procedures.Count - 1 do
    begin
      FScript.Add('DROP PROCEDURE IF EXISTS `' + Procedures[i] + '`;');
      FScript.Add('');
      FScript.Add('DELIMITER $');
      FScript.Add('');
      ProcDef := GetProcedureDefinition(FConn1, DB1, Procedures[i]);
      FScript.Add(ProcDef + ' $');
      FScript.Add('');
      FScript.Add('DELIMITER ;');
      FScript.Add('');
    end;
  finally
    Procedures.Free;
  end;
end;

function TDBComparer.GenerateScript(const DB1, DB2: string): string;
begin
  FScript.Clear;
  FScript.Add('-- ========================================');
  FScript.Add('-- SCRIPT DE SINCRONIZACIÓN');
  FScript.Add('-- Base Origen: ' + DB1);
  FScript.Add('-- Base Destino: ' + DB2);
  FScript.Add('-- Generado: ' + DateTimeToStr(Now));
  if FOptions.NoDelete then
    FScript.Add('-- Modo: NO DELETE (sin eliminaciones)');
  if FOptions.WithTriggers then
    FScript.Add('-- Incluye: TRIGGERS');
  if FOptions.WithData then
    FScript.Add('-- Incluye: DATOS (copia completa)');
  if FOptions.WithDataDiff then
    FScript.Add('-- Incluye: DATOS (solo diferencias por PK)');
  FScript.Add('-- ========================================');
  FScript.Add('');
  FScript.Add('USE `' + DB2 + '`;');
  FScript.Add('');
  FScript.Add('SET FOREIGN_KEY_CHECKS = 0;');
  FScript.Add('');
  CompareTables(DB1, DB2);
  CompareViews(DB1, DB2);
  CompareProcedures(DB1, DB2);
  if FOptions.WithTriggers then
  begin
    FScript.Add('DELIMITER $');
    FScript.Add('');
    CompareTriggers(DB1, DB2);
    FScript.Add('DELIMITER ;');
    FScript.Add('');
  end;
  FScript.Add('SET FOREIGN_KEY_CHECKS = 1;');
  FScript.Add('');
  Result := FScript.Text;
end;

procedure ShowUsage;
begin
  Writeln('Uso:');
  Writeln('  DBComparer servidor1:puerto1\database1 usuario1\password1 '+
          'servidor2:puerto2\database2 usuario2\password2 [opciones]');
  Writeln('');
  Writeln('Opciones:');
  Writeln('  --nodelete           No elimina tablas, columnas ni índices en destino');
  Writeln('  --with-triggers      Incluye comparación de triggers');
  Writeln('  --with-data          Copia todos los datos de origen a destino (INSERT)');
  Writeln('  --with-data-diff     Sincroniza datos comparando por clave primaria');
  Writeln('                       (INSERT nuevos, UPDATE modificados, DELETE si no --nodelete)');
  Writeln('  --exclude-tables=T1,T2...  Excluye tablas específicas de la sincronización de datos');
  Writeln('                             (Lista Negra: Sincroniza todo MENOS esto)');
  // --- NUEVA OPCIÓN ---
  Writeln('  --include-tables=T1,T2...  Solo sincroniza datos de estas tablas');
  Writeln('                             (Lista Blanca: Solo sincroniza ESTO, ignora el resto)');
  Writeln('');
  Writeln('Ejemplos:');
  Writeln('  DBComparer localhost:3306\midb_prod root\pass123 '+
          'localhost:3306\midb_dev root\pass456 --nodelete --with-triggers');
  Writeln('');
  Writeln('  DBComparer localhost:3306\prod root\pass '+
          'localhost:3306\dev root\pass --with-data-diff --nodelete');
  Writeln('');
  // --- NUEVO EJEMPLO ---
  Writeln('  DBComparer ... --with-data-diff --include-tables=fza_paises,fza_monedas');
  Writeln('');
  Writeln('El resultado se imprime por la salida estándar. '+
          'Para guardarlo en archivo:');
  Writeln('  DBComparer ... > script.sql');
  Writeln('');
  Halt(1);
end;

procedure ParseConnectionString(const ConnStr: string;
                                out Server, Port, Database: string);
var
  Parts: TArray<string>;
  ServerPort: TArray<string>;
begin
  Parts := ConnStr.Split(['\']);
  if Length(Parts) <> 2 then
    raise Exception.Create('Formato incorrecto. '+
                           'Use: servidor:puerto\database');
  ServerPort := Parts[0].Split([':']);
  if Length(ServerPort) = 2 then
  begin
    Server := ServerPort[0];
    Port := ServerPort[1];
  end
  else
  begin
    Server := Parts[0];
    Port := '3306';
  end;
  Database := Parts[1];
end;

procedure ParseCredentials(const CredStr: string; out User, Password: string);
var
  Parts: TArray<string>;
begin
  Parts := CredStr.Split(['\']);
  if (Length(Parts) <> 2) then
    raise Exception.Create('Formato incorrecto. Use: usuario\password');
  User := Parts[0];
  Password := Parts[1];
end;

function ParseOptions: TCompareOptions;
var
  i: Integer;
  Param: string;
  ExcludePos: Integer;
  ExcludeList: string;
  IncludePos: Integer;
  IncludeList: string;
begin
  Result.NoDelete := False;
  Result.WithTriggers := False;
  Result.WithData := False;
  Result.WithDataDiff := False;
  Result.ExcludeTables := nil;
  Result.IncludeTables := nil;
  for i := 5 to ParamCount do
  begin
    Param := ParamStr(i);
    // Verificar --exclude-tables=tabla1,tabla2,tabla3
    if StartsText('--exclude-tables=', Param) then
    begin
      ExcludePos := Pos('=', Param);
      if ExcludePos > 0 then
      begin
        ExcludeList := Copy(Param, ExcludePos + 1, Length(Param));
        Result.ExcludeTables := TStringList.Create;
        Result.ExcludeTables.CommaText := ExcludeList;
        Result.ExcludeTables.CaseSensitive := False;
      end;
    end
    else if StartsText('--include-tables=', Param) then
    begin
      IncludePos := Pos('=', Param);
      if IncludePos > 0 then
      begin
        IncludeList := Copy(Param, IncludePos + 1, Length(Param));
        Result.IncludeTables := TStringList.Create;
        Result.IncludeTables.CommaText := IncludeList;
        Result.IncludeTables.CaseSensitive := False;
      end;
    end
    else
    begin
      Param := LowerCase(Param);
      if Param = '--nodelete' then
        Result.NoDelete := True
      else if Param = '--with-triggers' then
        Result.WithTriggers := True
      else if Param = '--with-data' then
        Result.WithData := True
      else if Param = '--with-data-diff' then
        Result.WithDataDiff := True;
    end;
  end;
  // Validación: no se pueden usar ambas opciones de datos al mismo tiempo
  if Result.WithData and Result.WithDataDiff then
  begin
    Writeln(ErrOutput, 'ERROR: No puede usar --with-data y --with-data-diff simultáneamente');
    if (Result.ExcludeTables <> nil) then
      Result.ExcludeTables.Free;
    Halt(1);
  end;
end;

var
  Comparer: TDBComparer;
  Server1, Port1, DB1, User1, Pass1: string;
  Server2, Port2, DB2, User2, Pass2: string;
  Script: string;
  Options: TCompareOptions;
begin
  try
    FormatSettings.DecimalSeparator := '.';
    if ParamCount < 4 then
      ShowUsage;
    // Parsear parámetros
    ParseConnectionString(ParamStr(1), Server1, Port1, DB1);
    ParseCredentials(ParamStr(2), User1, Pass1);
    ParseConnectionString(ParamStr(3), Server2, Port2, DB2);
    ParseCredentials(ParamStr(4), User2, Pass2);
    Options := ParseOptions;
    Writeln(ErrOutput, 'Conectando a servidores...');
    Writeln(ErrOutput, 'Origen: ' + Server1 + ':' + Port1 + '\' + DB1);
    Writeln(ErrOutput, 'Destino: ' + Server2 + ':' + Port2 + '\' + DB2);
    if Options.NoDelete then
      Writeln(ErrOutput, 'Modo: NO DELETE');
    if Options.WithTriggers then
      Writeln(ErrOutput, 'Incluye: TRIGGERS');
    if Options.WithData then
      Writeln(ErrOutput, 'Incluye: DATOS (copia completa)');
    if Options.WithDataDiff then
      Writeln(ErrOutput, 'Incluye: DATOS (sincronización por PK)');
    if ((Options.ExcludeTables <> nil) and
        (Options.ExcludeTables.Count > 0)) then
      Writeln(ErrOutput, 'Tablas excluidas de datos: ' +
                                               Options.ExcludeTables.CommaText);
    Writeln(ErrOutput, '');
    // Crear comparador
    Comparer := TDBComparer.Create(
      Server1, User1, Pass1, Port1, DB1,
      Server2, User2, Pass2, Port2, DB2,
      Options
    );
    try
      Writeln(ErrOutput, 'Generando script de comparación...');
      Script := Comparer.GenerateScript(DB1, DB2);
      // Imprimir por salida estándar
      Write(Script);
      Writeln(ErrOutput, '');
      Writeln(ErrOutput, 'Script generado exitosamente.');
    finally
      Comparer.Free;
    end;
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, 'ERROR: ' + E.Message);
      Halt(1);
    end;
  end;
end.
