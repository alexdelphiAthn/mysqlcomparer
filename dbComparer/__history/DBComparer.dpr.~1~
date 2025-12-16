program DBComparerConsole;

uses
  Uni,
  Core.Helpers in 'Core.Helpers.pas',
  Core.Engine in 'Core.Engine.pas',
  Core.Interfaces in 'Core.Interfaces.pas',
  Core.Types in 'Core.Types.pas',
  Providers.MySQL in 'Providers.MySQL.pas',
  ScriptWriters in 'ScriptWriters.pas';

var
  Conn1, Conn2: TUniConnection;
  SourceProvider, TargetProvider: IDBMetadataProvider;
  Writer: IScriptWriter;
  Engine: TDBComparerEngine;
begin
//  try
//    Conn1 := TUniConnection.Create(nil);
//    Conn2 := TUniConnection.Create(nil);

    // 2. Crear los proveedores (puente entre físico y lógico)
    SourceProvider := TMySQLMetadataProvider.Create(Conn1, 'BaseOrigen');
    TargetProvider := TMySQLMetadataProvider.Create(Conn2, 'BaseDestino');

    // 3. Crear escritor
    Writer := TStringListScriptWriter.Create; // Una clase simple que envuelve TStringList

    // 4. Crear e iniciar el motor
    Engine := TDBComparerEngine.Create(SourceProvider,
                                       TargetProvider,
                                       Writer,
                                       Options);
    try
      Engine.GenerateScript;
      Writeln(Writer.GetScript);
    finally
      Engine.Free;
    end;

//  finally
//    Conn1.Free;
//    Conn2.Free;
  end;
end.