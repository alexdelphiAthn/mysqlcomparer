program DBComparerSQLServer;
{$APPTYPE CONSOLE}
uses
  Uni,
  Core.Helpers in 'Core.Helpers.pas',
  Core.Engine in 'Core.Engine.pas',
  Core.Interfaces in 'Core.Interfaces.pas',
  Core.Types in 'Core.Types.pas',
  Providers.SQLServer in 'Providers.SQLServer.pas',
  ScriptWriters in 'ScriptWriters.pas',
  Providers.SQLServer.Helpers in 'Providers.SQLServer.Helpers.pas',
  System.SysUtils;

procedure ShowUsage;
begin
  Writeln('Uso:');
  Writeln('  DBComparerSQLServer servidor1\instancia1\database1 usuario1\password1 '+
          'servidor2\instancia2\database2 usuario2\password2 [opciones]');
  Writeln('');
  Writeln('Nota: Para instancia por defecto, usar solo servidor\database');
  Writeln('      Para autenticación Windows, usar usuario: (vacío) o "Windows"');
  Writeln('');
  Writeln('Opciones:');
  Writeln('  --nodelete           No elimina tablas, columnas ni índices en destino');
  Writeln('  --with-triggers      Incluye comparación de triggers');
  Writeln('  --with-data          Copia todos los datos de origen a destino (INSERT)');
  Writeln('  --with-data-diff     Sincroniza datos comparando por clave primaria');
  Writeln('                       (INSERT nuevos, UPDATE modificados, DELETE si no --nodelete)');
  Writeln('  --exclude-tables=T1,T2...  Excluye tablas específicas de la sincronización de datos');
  Writeln('                             (Lista Negra: Sincroniza todo MENOS esto)');
  Writeln('  --include-tables=T1,T2...  Solo sincroniza datos de estas tablas');
  Writeln('                             (Lista Blanca: Solo sincroniza ESTO, ignora el resto)');
  Writeln('');
  Writeln('Ejemplos:');
  Writeln('  DBComparerSQLServer localhost\SQLEXPRESS\midb_prod sa\pass123 '+
          'localhost\SQLEXPRESS\midb_dev sa\pass456 --nodelete --with-triggers');
  Writeln('');
  Writeln('  DBComparerSQLServer servidor1\midb usuario\pass '+
          'servidor2\midb usuario\pass --with-data-diff --nodelete');
  Writeln('');
  Writeln('  DBComparerSQLServer localhost\midb Windows\ '+
          'localhost\midb_test Windows\ --with-data-diff');
  Writeln('');
  Writeln('  DBComparerSQLServer ... --with-data-diff --include-tables=Clientes,Productos');
  Writeln('');
  Writeln('El resultado se imprime por la salida estándar. '+
          'Para guardarlo en archivo:');
  Writeln('  DBComparerSQLServer ... > script.sql');
  Writeln('');
  Halt(1);
end;

var
  SourceProvider, TargetProvider: IDBMetadataProvider;
  SourceConn, TargetConn: TUniConnection;
  SourceConfig, TargetConfig: TConnectionConfig;
  Writer: IScriptWriter;
  Engine: TDBComparerEngine;
  Options: TComparerOptions;
  SourceHelpers: IDBHelpers;
begin
  SourceConn := nil;
  TargetConn := nil;
  Options := nil;
  Engine := nil;
  try
    if (ParamCount < 4) then
    begin
      ShowUsage;
      Exit;
    end;
    Options := TComparerOptions.ParseFromCLI;
    
    // Parsear configuraciones
    SourceConfig := TConnectionConfig.Parse(ParamStr(1), ParamStr(2));
    TargetConfig := TConnectionConfig.Parse(ParamStr(3), ParamStr(4));
    
    try
      // ---------------------------------------------------------
      // CONEXIÓN SQL SERVER
      // ---------------------------------------------------------
      SourceConn := TUniConnection.Create(nil);
      SourceConn.ProviderName := 'SQL Server';
      SourceConn.Server := SourceConfig.Server;
      // SQL Server puede tener puerto en el Server o usar instancia nombrada
      // Formato: servidor\instancia o servidor,puerto
      if SourceConfig.Port > 0 then
        SourceConn.Server := SourceConn.Server + ',' + IntToStr(SourceConfig.Port);
      SourceConn.Username := SourceConfig.Username;
      SourceConn.Password := SourceConfig.Password;
      SourceConn.Database := SourceConfig.Database;
      
      // Para autenticación Windows
      if (SourceConfig.Username = '') or 
         SameText(SourceConfig.Username, 'Windows') then
      begin
        SourceConn.SpecificOptions.Values['OSAuthent'] := 'True';
      end;
      
      SourceProvider := TSQLServerMetadataProvider.Create(SourceConn,
                                                          SourceConfig.Database);
      
      TargetConn := TUniConnection.Create(nil);
      TargetConn.ProviderName := 'SQL Server';
      TargetConn.Server := TargetConfig.Server;
      if TargetConfig.Port > 0 then
        TargetConn.Server := TargetConn.Server + ',' + IntToStr(TargetConfig.Port);
      TargetConn.Username := TargetConfig.Username;
      TargetConn.Password := TargetConfig.Password;
      TargetConn.Database := TargetConfig.Database;
      
      // Para autenticación Windows
      if (TargetConfig.Username = '') or 
         SameText(TargetConfig.Username, 'Windows') then
      begin
        TargetConn.SpecificOptions.Values['OSAuthent'] := 'True';
      end;
      
      TargetProvider := TSQLServerMetadataProvider.Create(TargetConn,
                                                          TargetConfig.Database);
      
      // Crear escritor y helpers
      Writer := TStringListScriptWriter.Create;
      SourceHelpers := TSQLServerHelpers.Create;
      
      // Crear e iniciar el motor
      Engine := TDBComparerEngine.Create(SourceProvider,
                                         TargetProvider,
                                         Writer,
                                         SourceHelpers,
                                         Options);
      try
        Engine.GenerateScript;
        Writeln(Writer.GetScript);
      finally
        Engine.Free;
      end;
    finally
      Options.Free;
      SourceConn.Free;
      TargetConn.Free;
    end;
  except
    on E: Exception do
      Writeln(ErrOutput, 'ERROR: ', E.Message);
  end;
end.