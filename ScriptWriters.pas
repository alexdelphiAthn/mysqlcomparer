unit ScriptWriters;
interface
uses
  System.Classes, system.SysUtils, Core.Interfaces;
type
  TStringListScriptWriter = class(TInterfacedObject, IScriptWriter)
  private
    FScript: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddComment(const Text: string);
    procedure AddCommand(const SQL: string);
    function GetScript: string;
  end;

implementation

{ TStringListScriptWriter }

procedure TStringListScriptWriter.AddCommand(const SQL: string);
begin
  Fscript.Add(SQL);
  Fscript.Add('');  //añadida linea vacía para mejor legibilidad
end;

procedure TStringListScriptWriter.AddComment(const Text: string);
begin
  if not Text.TrimLeft.StartsWith('--') then
    FScript.Add('-- ' + Text)
  else
    FScript.Add(Text);
end;

constructor TStringListScriptWriter.Create;
begin
  inherited Create;
  Fscript := TStringList.Create;
end;

destructor TStringListScriptWriter.Destroy;
begin
  Fscript.Free;
  inherited;
end;

function TStringListScriptWriter.GetScript: string;
begin
  Result := Fscript.Text;
end;

end.