unit Providers.MySQL.Helpers;

interface

uses Core.Helpers, Core.Types, System.SysUtils, System.StrUtils,
  System.Classes;

type
  TMySQLHelpers = class(TDBHelpers)
  public
    class function QuoteIdentifier(const Identifier: string): string; override;
    class function GenerateColumnDefinition(
                                      const Col: TColumnInfo): string; override;
    class function GenerateIndexDefinition(const TableName: string;
                                       const Idx: TIndexInfo): string; override;
    class function NormalizeType(const AType: string): string; override;
    class function TriggersAreEqual(const Trg1, Trg2: TTriggerInfo): Boolean;
    class function GenerateCreateTableSQL(const Table: TTableInfo;
                                     const Indexes: TArray<TIndexInfo>): string;
    class function GenerateAddColumnSQL(const TableName:string; const ColumnInfo:TColumnInfo): string;
    class function GenerateDropColumnSQL(const TableName, ColumnName:string): string;
    class function GenerateModifyColumnSQL(const TableName:string; const ColumnInfo:TColumnInfo): string;
    class function GenerateDropIndexSQL(const TableName, IndexName:string): string;
  end;

implementation

class function TMySQLHelpers.TriggersAreEqual(const Trg1,
                                                   Trg2: TTriggerInfo): Boolean;
begin
  Result := SameText(Trg1.TriggerName, Trg2.TriggerName) and
            (Trg1.EventManipulation = Trg2.EventManipulation) and
            (Trg1.ActionTiming = Trg2.ActionTiming) and
            (Trim(Trg1.ActionStatement) = Trim(Trg2.ActionStatement));
end;

class function TMySQLHelpers.QuoteIdentifier(const Identifier: string): string;
begin
  Result := '`' + Identifier + '`';
end;

class function TMySQLHelpers.NormalizeType(const AType: string): string;
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

class function TMySQLHelpers.GenerateColumnDefinition(const Col: TColumnInfo): string;
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

class function TMySQLHelpers.GenerateCreateTableSQL(const Table: TTableInfo;
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
class function TMySQLHelpers.GenerateIndexDefinition(const TableName: string;
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

end.
