unit Core.Types;

interface

uses System.Classes, Generics.Collections, system.SysUtils, System.StrUtils;

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
  TConnectionConfig = record
    Server: string;
    Port: Integer;
    Database: string;
    Username: string;
    Password: string;

    // Método estático para convertir los argumentos de consola en configuración
    class function Parse(const ConnStr, CredStr: string): TConnectionConfig; static;
  end;

  TComparerOptions = class
  public
    NoDelete: Boolean;
    WithTriggers: Boolean;
    WithData: Boolean;
    WithDataDiff: Boolean;
    ExcludeTables: TStringList;
    IncludeTables: TStringList;

    constructor Create;
    destructor Destroy; override;

    // MÉTODO ELEGANTE: La clase sabe cómo crearse a sí misma desde la consola
    class function ParseFromCLI: TComparerOptions;
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

{ TComparerOptions }

constructor TComparerOptions.Create;
begin
  ExcludeTables := TStringList.Create;
  ExcludeTables.CaseSensitive := False;
  IncludeTables := TStringList.Create;
  IncludeTables.CaseSensitive := False;
end;

destructor TComparerOptions.Destroy;
begin
  ExcludeTables.Free;
  IncludeTables.Free;
  inherited;
end;

class function TComparerOptions.ParseFromCLI: TComparerOptions;
var
  i: Integer;
  Param, Value: string;
begin
  Result := TComparerOptions.Create;
  // Empezamos desde 5 porque 1..4 son conexión
  for i := 5 to ParamCount do
  begin
    Param := LowerCase(ParamStr(i));
    if Param = '--nodelete' then
      Result.NoDelete := True
    else if Param = '--with-triggers' then
      Result.WithTriggers := True
    else if Param = '--with-data' then
      Result.WithData := True
    else if Param = '--with-data-diff' then
      Result.WithDataDiff := True
    else if StartsText('--exclude-tables=', Param) then
    begin
      Value := Copy(ParamStr(i), Length('--exclude-tables=') + 1, MaxInt);
      Result.ExcludeTables.CommaText := Value;
    end
    else if StartsText('--include-tables=', Param) then
    begin
      Value := Copy(ParamStr(i), Length('--include-tables=') + 1, MaxInt);
      Result.IncludeTables.CommaText := Value;
    end;
  end;
  // Validación básica
  if Result.WithData and Result.WithDataDiff then
    raise Exception.Create('Error: No puedes usar --with-data y ' +
                           '--with-data-diff a la vez.');
end;

{ TConnectionConfig }

class function TConnectionConfig.Parse(const ConnStr, CredStr: string): TConnectionConfig;
var
  PartsConn, PartsCred, PartsServer: TArray<string>;
begin
  // 1. Parsear "Servidor:Puerto\BaseDeDatos"
  PartsConn := ConnStr.Split(['\']);
  if Length(PartsConn) <> 2 then
    raise Exception.CreateFmt('Formato de conexión incorrecto: "%s". '+
                                    'Use: servidor:puerto\database', [ConnStr]);
  Result.Database := PartsConn[1];
  // Separar Servidor y Puerto
  PartsServer := PartsConn[0].Split([':']);
  if Length(PartsServer) = 2 then
  begin
    Result.Server := PartsServer[0];
    Result.Port := StrToIntDef(PartsServer[1], 3306);
  end
  else
  begin
    Result.Server := PartsConn[0];
    Result.Port := 3306; // Puerto por defecto MySQL
  end;
  // 2. Parsear "Usuario\Password"
  PartsCred := CredStr.Split(['\']);
  if Length(PartsCred) <> 2 then
    raise Exception.CreateFmt('Formato de credenciales incorrecto: "%s".'+
                              ' Use: usuario\password', [CredStr]);
  Result.Username := PartsCred[0];
  Result.Password := PartsCred[1];
end;

end.