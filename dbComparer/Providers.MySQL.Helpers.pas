unit Providers.MySQL.Helpers;

interface
uses Core.Helpers, Core.Types, System.SysUtils, System.StrUtils,
  System.Classes, Data.DB, Uni;
type
  TMySQLHelpers = class(TDBHelpers)
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
    function GenerateInsertSQL(const TableName: string; Fields,
                                                        Values: TStringList): string; override;

  end;

implementation

// Añadir en uses: Data.DB, System.SysUtils, System.Classes, System.StrUtils

function TMySQLHelpers.ValueToSQL(const Field: TField): string;
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
      Result := QuotedStr(Field.AsString);
    ftDate, ftTime, ftDateTime, ftTimeStamp:
      // MySQL prefiere formato estándar 'YYYY-MM-DD HH:MM:SS'
      Result := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Field.AsDateTime));
    ftBoolean:
      Result := IntToStr(Ord(Field.AsBoolean));
    ftBlob, ftGraphic, ftVarBytes, ftBytes:
      Result := '0x' + BytesToHex(Field.AsBytes);
    else
      // Números y otros
      Result := Field.AsString;
  end;
end;

function TMySQLHelpers.GenerateInsertSQL(const TableName: string;
  Fields, Values: TStringList): string;
var
  i: Integer;
  FieldList, ValueList: string;
begin
  // Unimos manualmente para evitar que CommaText escape cosas que no debe
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
  Result := 'INSERT INTO ' + QuoteIdentifier(TableName) + ' (' +
            FieldList + ') VALUES (' + ValueList + ');';
end;

function TMySQLHelpers.GenerateUpdateSQL(const TableName: string;
  const SetClause, WhereClause: string): string;
begin
  Result := 'UPDATE ' + QuoteIdentifier(TableName) + ' SET ' + SetClause +
            ' WHERE ' + WhereClause + ';';
end;

function TMySQLHelpers.TriggersAreEqual(const Trg1,
                                                   Trg2: TTriggerInfo): Boolean;
begin
  Result := SameText(Trg1.TriggerName, Trg2.TriggerName) and
            (Trg1.EventManipulation = Trg2.EventManipulation) and
            (Trg1.ActionTiming = Trg2.ActionTiming) and
            (Trim(Trg1.ActionStatement) = Trim(Trg2.ActionStatement));
end;

function TMySQLHelpers.QuoteIdentifier(const Identifier: string): string;
begin
  Result := '`' + Identifier + '`';
end;

function TMySQLHelpers.NormalizeType(const AType: string): string;
var
  S: string;
  PStart, PEnd: Integer;
begin
  S := LowerCase(Trim(AType));
  // ESPECÍFICO MYSQL: Eliminar display width de INT(11)
  if StartsText('int', S) or StartsText('tinyint', S) then
  begin
    PStart := Pos('(', S);
    PEnd := Pos(')', S);
    if (PStart > 0) and (PEnd > PStart) then
      S := Copy(S, 1, PStart - 1) + Copy(S, PEnd + 1, MaxInt);
  end;
  Result := StringReplace(S, ' ', '', [rfReplaceAll]);
end;

function TMySQLHelpers.GenerateAddColumnSQL(const TableName: string;
  const ColumnInfo: TColumnInfo): string;
begin
  Result := 'ALTER TABLE ' + QuoteIdentifier(TableName) +
            ' ADD COLUMN ' + GenerateColumnDefinition(ColumnInfo);
end;

function TMySQLHelpers.GenerateColumnDefinition(const Col: TColumnInfo): string;
var
  DefVal: string;
begin
  Result := '`' + Col.ColumnName + '` ' + Col.DataType;
  if SameText(Col.IsNullable, 'NO') then
    Result := Result + ' NOT NULL'
  else
    Result := Result + ' NULL';
  if (not SameText(Col.ColumnDefault, '')) and
     (not SameText(Col.ColumnDefault, 'NULL')) then
  begin
    if (Pos('CURRENT_TIMESTAMP', UpperCase(Col.ColumnDefault)) > 0) or
       (Pos('NOW()', UpperCase(Col.ColumnDefault)) > 0) then
    begin
      Result := Result + ' DEFAULT ' + Col.ColumnDefault;
    end
    else
    begin
      DefVal := Col.ColumnDefault;
      // Eliminar comillas duplicadas si ya las tiene
      if (Length(DefVal) >= 2) and (DefVal[1] = '''') and
         (DefVal[Length(DefVal)] = '''') then
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

function TMySQLHelpers.GenerateCreateProcedureSQL(const Body: string): string;
begin
  // MySQL necesita cambiar el delimitador para que no corte en el primer ';'
  Result := 'DELIMITER $$' + sLineBreak +
            Body + ' $$' + sLineBreak +
            'DELIMITER ;';
end;

function TMySQLHelpers.GenerateCreateFunctionSQL(const Body: string): string;
begin
  // Exactamente igual para funciones en MySQL
  Result := 'DELIMITER $$' + sLineBreak +
            Body + ' $$' + sLineBreak +
            'DELIMITER ;';
end;

function TMySQLHelpers.GenerateCreateTableSQL(const Table: TTableInfo;
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
      // Usar tu método existente
      ColDef := '  ' + GenerateColumnDefinition(Table.Columns[i]);
      // Detectar PK para añadirla al final
      if SameText(Table.Columns[i].ColumnKey, 'PRI') then
        PKList.Add(QuoteIdentifier(Table.Columns[i].ColumnName));
      if i < Table.Columns.Count - 1 then
        ColDef := ColDef + ',';
      Result := Result + ColDef + sLineBreak;
    end;
    // Agregar PK inline
    if PKList.Count > 0 then
      Result := Result + '  PRIMARY KEY (' + PKList.CommaText + ')' + sLineBreak;
    Result := Result + ');';
  finally
    PKList.Free;
  end;
end;

function TMySQLHelpers.GenerateDeleteSQL(const TableName,
  WhereClause: string): string;
begin
  Result := 'DELETE FROM ' + QuoteIdentifier(TableName) +
            ' WHERE ' + WhereClause + ';';
end;

function TMySQLHelpers.GenerateDropColumnSQL(const TableName,
  ColumnName: string): string;
begin
  Result := 'ALTER TABLE ' + QuoteIdentifier(TableName) +
            ' DROP COLUMN ' + QuoteIdentifier(ColumnName);
end;

function TMySQLHelpers.GenerateDropFunction(const FuncName: string): string;
begin
  Result:= 'DROP FUNCTION IF EXISTS ' + QuoteIdentifier(FuncName);
end;

function TMySQLHelpers.GenerateDropTableSQL(const TableName:String): string;
begin
  Result := 'DROP TABLE IF EXISTS ' + QuoteIdentifier(TableName);
end;

function TMySQLHelpers.GenerateDropTrigger(const Trigger: string): string;
begin
  Result := 'DROP TRIGGER IF EXISTS ' + QuoteIdentifier(Trigger);
end;

function TMySQLHelpers.GenerateDropView(const View: string): string;
begin
  Result := 'DROP VIEW IF EXISTS ' + QuoteIdentifier(View);
end;

function TMySQLHelpers.GenerateDropIndexSQL(const TableName,
  IndexName: string): string;
begin
  if SameText(IndexName, 'PRIMARY') then
    Result := 'ALTER TABLE ' + QuoteIdentifier(TableName) + ' DROP PRIMARY KEY'
  else
    Result := 'ALTER TABLE ' + QuoteIdentifier(TableName) +
              ' DROP INDEX ' + QuoteIdentifier(IndexName);
end;

function TMySQLHelpers.GenerateDropProcedure(const Proc: string): string;
begin
  Result:= 'DROP PROCEDURE IF EXISTS ' + QuoteIdentifier(Proc);
end;

function TMySQLHelpers.GenerateIndexDefinition(const TableName: string;
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
              ' ADD PRIMARY KEY (' + ColNames + ')'
  else if Idx.IsUnique then
    Result := 'ALTER TABLE ' + QuoteIdentifier(TableName) +
              ' ADD UNIQUE INDEX ' + QuoteIdentifier(Idx.IndexName) +
              ' (' + ColNames + ')'
  else
    Result := 'ALTER TABLE ' + QuoteIdentifier(TableName) +
              ' ADD INDEX ' + QuoteIdentifier(Idx.IndexName) +
              ' (' + ColNames + ')';
end;

function TMySQLHelpers.GenerateModifyColumnSQL(const TableName: string;
  const ColumnInfo: TColumnInfo): string;
begin
  Result := 'ALTER TABLE ' + QuoteIdentifier(TableName) +
            ' MODIFY COLUMN ' + GenerateColumnDefinition(ColumnInfo);
end;


end.
