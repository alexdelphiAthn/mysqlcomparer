program DBComparerConsole;

uses
  Uni,
  Core.Helpers in 'Core.Helpers.pas',
  Core.Engine in 'Core.Engine.pas',
  Core.Interfaces in 'Core.Interfaces.pas',
  Core.Types in 'Core.Types.pas',
  Providers.MySQL in 'Providers.MySQL.pas',
  ScriptWriters in 'ScriptWriters.pas',
  Providers.MySQL.Helpers in 'Providers.MySQL.Helpers.pas', System.SysUtils;

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

var
  SourceProvider, TargetProvider: IDBMetadataProvider;
  SourceConn, TargetConn:TUniConnection;
  SourceConfig, TargetConfig: TConnectionConfig;
  Writer: IScriptWriter;
  Engine: TDBComparerEngine;
  Options:TComparerOptions;
begin
  try
    if ParamCount < 4 then
    begin
      ShowUsage;
      Exit;
    end;
    Options := TComparerOptions.ParseFromCLI;
    // 2. Crear los proveedores (puente entre físico y lógico)
    SourceConfig := TConnectionConfig.Parse(ParamStr(1), ParamStr(2));
    TargetConfig := TConnectionConfig.Parse(ParamStr(3), ParamStr(4));
    try
      // ---------------------------------------------------------
      // 2. CONEXIÓN (Usando los Configs parseados)
      // ---------------------------------------------------------
      SourceConn := TUniConnection.Create(nil);
      SourceConn.ProviderName := 'MySQL';
      SourceConn.Server := SourceConfig.Server;
      SourceConn.Port := SourceConfig.Port;
      SourceConn.Username := SourceConfig.Username;
      SourceConn.Password := SourceConfig.Password;
      SourceProvider := TMySQLMetadataProvider.Create(SourceConn,
                                                    SourceConfig.Database);
      TargetConn := TUniConnection.Create(nil);
      TargetConn.ProviderName := 'MySQL';
      TargetConn.Server := TargetConfig.Server;
      TargetConn.Port := TargetConfig.Port;
      TargetConn.Username := TargetConfig.Username;
      TargetConn.Password := TargetConfig.Password;
      TargetProvider := TMySQLMetadataProvider.Create(TargetConn,
                                                      TargetConfig.Database);
      // 3. Crear escritor
      Writer := TStringListScriptWriter.Create;
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

    finally
      Options.Free; // Importante liberar la clase de opciones
      SourceConn.Free;
      TargetConn.Free;
    end;
  except
    on E: Exception do
      Writeln(ErrOutput, 'ERROR: ', E.Message);
  end;
end.
