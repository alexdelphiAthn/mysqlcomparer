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
  System.SysUtils,
  Core.Resources in 'Core.Resources.pas';

procedure ShowUsage;
begin
  Writeln(TRes.UsageHeader);
  Writeln(Format(TRes.UsageExampleCmd, ['DBComparerSQLServer']));
  Writeln('');
  Writeln(TRes.MsgSQLDefInstance);
  Writeln(TRes.MsgSQLWinAuth);
  Writeln('');
  Writeln(TRes.OptionsHeader);
  Writeln('  --nodelete           ' + TRes.OptNoDelete);
  Writeln('  --with-triggers      ' + TRes.OptTriggers);
  Writeln('  --with-data          ' + TRes.OptWithData);
  Writeln('  --with-data-diff     ' + TRes.OptDataDiff);
  Writeln('  --exclude-tables=T1,T2... ' + TRes.OptExclude);
  Writeln('                            ' + TRes.OptExcludeDesc);
  Writeln('  --include-tables=T1,T2...  '+ TRes.OptInclude);
  Writeln('                             '+ TRes.OptIncludeDesc);
  Writeln('');
  Writeln(TRes.ExamplesHeader);
// Ejemplos específicos SQL Server
  Writeln(TRes.ExamplesHeader); // "Ejemplos:"
  Writeln(Format(TRes.ExSQLNamedInst, ['DBComparerSQLServer']));
  Writeln('');
  Writeln(Format(TRes.ExSQLStd, ['DBComparerSQLServer']));
  Writeln('');
  Writeln(Format(TRes.ExSQLWinAuth, ['DBComparerSQLServer']));
  Writeln('');
  Writeln(Format(TRes.ExSQLFilter, ['DBComparerSQLServer']));
  Writeln('');
  Writeln(TRes.FooterFile);
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