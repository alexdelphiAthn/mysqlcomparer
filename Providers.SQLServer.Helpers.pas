unit Providers.SQLServer.Helpers;

interface
uses Core.Helpers, Core.Types, System.SysUtils, System.StrUtils,
  System.Classes, Data.DB, Uni;
type
  TSQLServerHelpers = class(TDBHelpers)
  public
    function QuoteIdentifier(const Identifier: string): string; override;
    function GenerateColumnDefinition(const Col: TColumnInfo): string; override;
    function GenerateIndexDefinition(const TableName: string;
                                     const Idx: TIndexInfo): string; override;
    function NormalizeType(const AType: string): string; override;
    function TriggersAreEqual(const Trg1, Trg2: TTriggerInfo): Boolean; override;
    function GenerateCreateTableSQL(const Table: TTableInfo;
                                    const Indexes: TArray<TIndexInfo>): string; override;
    function GenerateAddColumnSQL(const TableName:string;
                                  const ColumnInfo:TColumnInfo): string; override;
    function GenerateDropColumnSQL(const TableName, ColumnName:string): string; override;
    function GenerateModifyColumnSQL(const TableName:string;
                                     const ColumnInfo:TColumnInfo): string; override;
    function GenerateUpdateSQL(const TableName: string;
                                  const SetClause, WhereClause: string): string; override;
    function GenerateDropIndexSQL(const TableName,
                                        IndexName:string): string; override;
    function GenerateDropTableSQL(const TableName:String): string; override;
    function GenerateDropTrigger(const Trigger:string):string; override;
    function GenerateDropProcedure(const Proc:string):string; override;
    function GenerateDropFunction(const FuncName: string): string; override;
    function GenerateDropView(const View:string):string; override;
    function ValueToSQL(const Field: TField): string;
    function GenerateCreateProcedureSQL(const Body: string): string; override;
    function GenerateCreateFunctionSQL(const Body: string): string; override;
    function GenerateDeleteSQL(const TableName, WhereClause: string): string; override;
    function GenerateInsertSQL(const TableName: string;
                           Fields, Values: TStringList;
                           const HasIdentity: Boolean = False): string; override;// Nuevo parámetro
  end;

implementation

function TSQLServerHelpers.ValueToSQL(const Field: TField): string;
  function BytesToHex(const Bytes: TBytes): string;
  var
    i: Integer;
  begin
    Result := '';
    for i := Low(Bytes) to High(Bytes) do
      Result := Result + IntToHex(Bytes[i], 2);
  end;
begin
  if Field.IsNull then
    Exit('NULL');

  case Field.DataType of
    ftString, ftWideString, ftMemo, ftWideMemo, ftFmtMemo:
      Result := 'N' + QuotedStr(StringReplace(Field.AsString, '''', '''''', [rfReplaceAll]));
    ftDate:
      // ISO 8601 compact format 'YYYYMMDD' is safest for dates
      Result := QuotedStr(FormatDateTime('yyyymmdd', Field.AsDateTime));
    ftDateTime, ftTimeStamp:
      // ISO 8601 combined format
      Result := QuotedStr(FormatDateTime('yyyy-mm-ddThh:nn:ss.zzz', Field.AsDateTime));
    ftTime:
      Result := QuotedStr(FormatDateTime('hh:nn:ss', Field.AsDateTime));
    ftBoolean:
      Result := IntToStr(Ord(Field.AsBoolean));
    ftBlob, ftGraphic, ftVarBytes, ftBytes:
      Result := '0x' + BytesToHex(Field.AsBytes);
    else
      Result := Field.AsString;
  end;
end;

function TSQLServerHelpers.GenerateInsertSQL(const TableName: string;
                           Fields, Values: TStringList;
                           const HasIdentity: Boolean = False): string; // Nuevo parámetro
var
  i: Integer;
  FieldList, ValueList: string;
  SQLInsert:string;
begin
  FieldList := '';
  ValueList := '';
  for i := 0 to Fields.Count - 1 do
  begin
    if i > 0 then FieldList := FieldList + ', ';
    FieldList := FieldList + Fields[i];
  end;
  for i := 0 to Values.Count - 1 do
  begin
    if i > 0 then ValueList := ValueList + ', ';
    ValueList := ValueList + Values[i];
  end;
  SQLInsert := 'INSERT INTO ' + QuoteIdentifier(TableName) + ' (' +
            FieldList + ') VALUES (' + ValueList + ');';
  if HasIdentity then
  begin
    Result := 'SET IDENTITY_INSERT ' + QuoteIdentifier(TableName) + ' ON;' + sLineBreak +
              SqlInsert + sLineBreak +
              'SET IDENTITY_INSERT ' + QuoteIdentifier(TableName) + ' OFF;';
  end
  else
  begin
    Result := SqlInsert;
  end;
end;

function TSQLServerHelpers.GenerateUpdateSQL(const TableName: string;
  const SetClause, WhereClause: string): string;
begin
  Result := 'UPDATE ' + QuoteIdentifier(TableName) + ' SET ' + SetClause +
            ' WHERE ' + WhereClause + ';';
end;

function TSQLServerHelpers.TriggersAreEqual(const Trg1,
                                                   Trg2: TTriggerInfo): Boolean;
begin
  Result := SameText(Trg1.TriggerName, Trg2.TriggerName) and
            (Trg1.EventManipulation = Trg2.EventManipulation) and
            (Trg1.ActionTiming = Trg2.ActionTiming) and
            (Trim(Trg1.ActionStatement) = Trim(Trg2.ActionStatement));
end;

function TSQLServerHelpers.QuoteIdentifier(const Identifier: string): string;
begin
  Result := '[' + StringReplace(Identifier, ']', ']]', [rfReplaceAll]) + ']';
end;

function TSQLServerHelpers.NormalizeType(const AType: string): string;
var
  S: string;
begin
  S := LowerCase(Trim(AType));
  // SQL Server normalización
  S := StringReplace(S, ' ', '', [rfReplaceAll]);
  // Normalizar tipos comunes
  if StartsText('nvarchar(max)', S) then
    S := 'nvarchar(max)'
  else if StartsText('varchar(max)', S) then
    S := 'varchar(max)'
  else if StartsText('varbinary(max)', S) then
    S := 'varbinary(max)';
  Result := S;
end;

function TSQLServerHelpers.GenerateAddColumnSQL(const TableName: string;
  const ColumnInfo: TColumnInfo): string;
begin
  Result := 'ALTER TABLE ' + QuoteIdentifier(TableName) +
            ' ADD ' + GenerateColumnDefinition(ColumnInfo) + ';' + sLineBreak + 'GO';
end;

function TSQLServerHelpers.GenerateColumnDefinition(const Col: TColumnInfo): string;
var
  DefVal: string;
begin
  Result := QuoteIdentifier(Col.ColumnName) + ' ' + Col.DataType;
  
  // Identity (auto-increment en SQL Server)
  if Pos('identity', LowerCase(Col.Extra)) > 0 then
    Result := Result + ' IDENTITY(1,1)';
  
  // Nullability
  if SameText(Col.IsNullable, 'NO') then
    Result := Result + ' NOT NULL'
  else
    Result := Result + ' NULL';
  
  // Default value
  if (not SameText(Col.ColumnDefault, '')) and
     (not SameText(Col.ColumnDefault, 'NULL')) then
  begin
    if (Pos('GETDATE()', UpperCase(Col.ColumnDefault)) > 0) or
       (Pos('CURRENT_TIMESTAMP', UpperCase(Col.ColumnDefault)) > 0) or
       (Pos('NEWID()', UpperCase(Col.ColumnDefault)) > 0) then
    begin
      Result := Result + ' DEFAULT ' + Col.ColumnDefault;
    end
    else
    begin
      DefVal := Col.ColumnDefault;
      // Eliminar paréntesis externos si existen (SQL Server los incluye)
      if (Length(DefVal) >= 2) and (DefVal[1] = '(') and
         (DefVal[Length(DefVal)] = ')') then
        DefVal := Copy(DefVal, 2, Length(DefVal) - 2);
      // Eliminar comillas si ya las tiene
      if (Length(DefVal) >= 2) and (DefVal[1] = '''') and
         (DefVal[Length(DefVal)] = '''') then
        DefVal := Copy(DefVal, 2, Length(DefVal) - 2);
      Result := Result + ' DEFAULT ' + QuotedStr(DefVal);
    end;
  end
  else if SameText(Col.ColumnDefault, 'NULL') then
    Result := Result + ' DEFAULT NULL';
end;

function TSQLServerHelpers.GenerateCreateProcedureSQL(const Body: string): string;
begin
  // SQL Server usa GO como delimitador de lotes
  Result := Body + sLineBreak + 'GO';
end;

function TSQLServerHelpers.GenerateCreateFunctionSQL(const Body: string): string;
begin
  // SQL Server usa GO como delimitador de lotes
  Result := Body + sLineBreak + 'GO';
end;

function TSQLServerHelpers.GenerateCreateTableSQL(const Table: TTableInfo;
  const Indexes: TArray<TIndexInfo>): string;
var
  i: Integer;
  PKList: TStringList;
  ColDef: string;
begin
  Result := 'CREATE TABLE ' + QuoteIdentifier(Table.TableName) + ' (' + sLineBreak;
  PKList := TStringList.Create;
  try
    for i := 0 to Table.Columns.Count - 1 do
    begin
      ColDef := '  ' + GenerateColumnDefinition(Table.Columns[i]);
      // Detectar Primary Key
      if SameText(Table.Columns[i].ColumnKey, 'PRI') or 
         (Pos('primary key', LowerCase(Table.Columns[i].Extra)) > 0) then
        PKList.Add(QuoteIdentifier(Table.Columns[i].ColumnName));
      if (i < Table.Columns.Count - 1) or (PKList.Count > 0) then
        ColDef := ColDef + ',';
      Result := Result + ColDef + sLineBreak;
    end;
    // Agregar Primary Key constraint
    if PKList.Count > 0 then
    begin
      Result := Result + '  CONSTRAINT PK_' + Table.TableName + 
                ' PRIMARY KEY CLUSTERED (' + PKList.CommaText + ')' + sLineBreak;
    end;
    Result := Result + ');' + sLineBreak + 'GO';
  finally
    PKList.Free;
  end;
end;

function TSQLServerHelpers.GenerateDeleteSQL(const TableName,
  WhereClause: string): string;
begin
  Result := 'DELETE FROM ' + QuoteIdentifier(TableName) +
            ' WHERE ' + WhereClause + ';';
end;

function TSQLServerHelpers.GenerateDropColumnSQL(const TableName,
  ColumnName: string): string;
begin
  Result := 'ALTER TABLE ' + QuoteIdentifier(TableName) +
            ' DROP COLUMN ' + QuoteIdentifier(ColumnName) + ';' + sLineBreak + 'GO';
end;

function TSQLServerHelpers.GenerateDropFunction(const FuncName: string): string;
begin
  Result := 'IF OBJECT_ID(N' + QuotedStr(FuncName) + 
            ', N''FN'') IS NOT NULL DROP FUNCTION ' + QuoteIdentifier(FuncName) + ';' + sLineBreak + 'GO';
end;

function TSQLServerHelpers.GenerateDropTableSQL(const TableName:String): string;
begin
  Result := 'IF OBJECT_ID(N' + QuotedStr(TableName) + 
            ', N''U'') IS NOT NULL DROP TABLE ' + QuoteIdentifier(TableName) + ';' + sLineBreak + 'GO';
end;

function TSQLServerHelpers.GenerateDropTrigger(const Trigger: string): string;
begin
  Result := 'IF OBJECT_ID(N' + QuotedStr(Trigger) + 
            ', N''TR'') IS NOT NULL DROP TRIGGER ' + QuoteIdentifier(Trigger) + ';' + sLineBreak + 'GO';
end;

function TSQLServerHelpers.GenerateDropView(const View: string): string;
begin
  Result := 'IF OBJECT_ID(N' + QuotedStr(View) + 
            ', N''V'') IS NOT NULL DROP VIEW ' + QuoteIdentifier(View) + ';' + sLineBreak + 'GO';
end;

function TSQLServerHelpers.GenerateDropIndexSQL(const TableName,
  IndexName: string): string;
begin
  if StartsText('PK_', IndexName) then
    Result := 'ALTER TABLE ' + QuoteIdentifier(TableName) + 
              ' DROP CONSTRAINT ' + QuoteIdentifier(IndexName) + ';' + sLineBreak + 'GO'
  else
    Result := 'DROP INDEX ' + QuoteIdentifier(IndexName) + 
              ' ON ' + QuoteIdentifier(TableName) + ';' + sLineBreak + 'GO';
end;

function TSQLServerHelpers.GenerateDropProcedure(const Proc: string): string;
begin
  Result := 'IF OBJECT_ID(N' + QuotedStr(Proc) + 
            ', N''P'') IS NOT NULL DROP PROCEDURE ' + QuoteIdentifier(Proc) + ';' + sLineBreak + 'GO';
end;

function TSQLServerHelpers.GenerateIndexDefinition(const TableName: string;
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
    ColNames := ColNames + QuoteIdentifier(Idx.Columns[i].ColumnName);
  end;
  
  if Idx.IsPrimary then
    Result := 'ALTER TABLE ' + QuoteIdentifier(TableName) +
              ' ADD CONSTRAINT PK_' + TableName +
              ' PRIMARY KEY CLUSTERED (' + ColNames + ');' + sLineBreak + 'GO'
  else if Idx.IsUnique then
    Result := 'CREATE UNIQUE NONCLUSTERED INDEX ' + QuoteIdentifier(Idx.IndexName) +
              ' ON ' + QuoteIdentifier(TableName) +
              ' (' + ColNames + ');' + sLineBreak + 'GO'
  else
    Result := 'CREATE NONCLUSTERED INDEX ' + QuoteIdentifier(Idx.IndexName) +
              ' ON ' + QuoteIdentifier(TableName) +
              ' (' + ColNames + ');' + sLineBreak + 'GO';
end;

function TSQLServerHelpers.GenerateModifyColumnSQL(const TableName: string;
  const ColumnInfo: TColumnInfo): string;
begin
  Result := 'ALTER TABLE ' + QuoteIdentifier(TableName) +
            ' ALTER COLUMN ' + GenerateColumnDefinition(ColumnInfo) + ';' + sLineBreak + 'GO';
end;

end.