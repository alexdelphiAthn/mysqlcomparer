unit Core.Types;

interface

uses System.Classes, Generics.Collections, system.SysUtils;

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

  TComparerOptions = record
    NoDelete: Boolean;
    WithTriggers: Boolean;
    WithData: Boolean;
    WithDataDiff: Boolean;
    ExcludeTables: TStringList;
    IncludeTables: TStringList;
  end;

implementation

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

end.