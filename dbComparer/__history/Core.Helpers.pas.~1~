unit Core.Helpers;

interface

uses
  Core.Types, Core.Interfaces, System.SysUtils, System.StrUtils;

type
  TDBHelpers = class(TInterfacedObject, IDBHelpers)
  public
    // Métodos comunes que SÍ son universales
    function ColumnsAreEqual(const Col1, Col2: TColumnInfo): Boolean;
    function IndexesAreEqual(const Idx1, Idx2: TIndexInfo): Boolean; virtual;
    function NormalizeExtra(const AExtra: string): string; virtual;

    // Métodos ABSTRACTOS que cada proveedor debe implementar
    function QuoteIdentifier(const Identifier: string): string; virtual; abstract;
    function GenerateColumnDefinition(const Col: TColumnInfo): string; virtual; abstract;
    function GenerateIndexDefinition(const TableName: string;
                                     const Idx: TIndexInfo): string; virtual; abstract;
    class function NormalizeType(const AType: string): string; virtual; abstract;
    function TriggersAreEqual(const Trg1, Trg2: TTriggerInfo): Boolean; virtual; abstract;
  end;

implementation


function TDBHelpers.NormalizeExtra(const AExtra: string): string;
begin
  Result := LowerCase(Trim(AExtra));
end;

function TDBHelpers.ColumnsAreEqual(const Col1, Col2: TColumnInfo): Boolean;
var
  Typ1, Typ2, Null1, Null2, Key1, Key2, Extra1, Extra2, Def1, Def2: string;
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
  Result := (Typ1 = Typ2) and (Null1 = Null2) and
            (Key1 = Key2) and (Extra1 = Extra2);
  if Result then
  begin
    IsAutoInc := (Pos('auto_increment', Extra1) > 0) or
                 (Pos('auto_increment', Extra2) > 0);
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

function TDBHelpers.IndexesAreEqual(const Idx1, Idx2: TIndexInfo): Boolean;
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
      if not SameText(Idx1.Columns[i].ColumnName, Idx2.Columns[i].ColumnName) or
         (Idx1.Columns[i].SeqInIndex <> Idx2.Columns[i].SeqInIndex) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;

end.
