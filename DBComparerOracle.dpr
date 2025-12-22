program DBComparerOracle;
{$APPTYPE CONSOLE}
uses
  Uni,
  Core.Helpers in 'Core.Helpers.pas',
  Core.Engine in 'Core.Engine.pas',
  Core.Interfaces in 'Core.Interfaces.pas',
  Core.Types in 'Core.Types.pas',
  Providers.Oracle in 'Providers.Oracle.pas',
  ScriptWriters in 'ScriptWriters.pas',
  Providers.Oracle.Helpers in 'Providers.Oracle.Helpers.pas',
  System.SysUtils,
  system.StrUtils,
  Core.Resources in 'Core.Resources.pas';

procedure ShowUsage;
begin
  Writeln(TRes.UsageHeader);
  Writeln('  DBComparerOracle servidor1:puerto1/sid1 usuario1/password1 '+
          'servidor2:puerto2/sid2 usuario2/password2 [opciones]');
  Writeln('');
  Writeln(Format(TRes.UsageNotePort, [1521]));

  // Notas específicas de Oracle
  Writeln(TRes.UsageOracleOwner);
  Writeln(TRes.UsageOracleTNS);

  Writeln('');
  Writeln(TRes.HeaderConnFormats); // "Formatos de conexión:"
  Writeln(TRes.FmtOracleDirect);
  Writeln(TRes.FmtOracleTNS);
  Writeln(TRes.FmtOracleDefPort);

  Writeln('');
  Writeln(TRes.OptionsHeader); // "Opciones:"
  Writeln('  --nodelete           ' + TRes.OptNoDelete);
  Writeln('  --with-triggers      ' + TRes.OptTriggers);
  Writeln('  --with-data          ' + TRes.OptWithData);
  Writeln('  --with-data-diff     ' + TRes.OptDataDiff);
  Writeln('  --exclude-tables=T1,T2... ' + TRes.OptExclude);
  Writeln('                            ' + TRes.OptExcludeDesc);
  Writeln('  --include-tables=T1,T2...  '+ TRes.OptInclude);
  Writeln('                             '+ TRes.OptIncludeDesc);
  Writeln('');
  Writeln('');
  Writeln(TRes.ExamplesHeader);
  Writeln('  DBComparerOracle localhost:1521/ORCL hr/password123 '+
          'localhost:1521/ORCLDEV hr/password456 --nodelete --with-triggers');
  Writeln('');
  Writeln('  DBComparerOracle servidor1/XE system/pass '+
          'servidor2/XE system/pass --with-data-diff --nodelete');
  Writeln('');
  Writeln('  DBComparerOracle //PROD_TNS app_user/pass '+
          '//DEV_TNS app_user/pass --with-data-diff');
  Writeln('');
  Writeln('  DBComparerOracle ... --with-data-diff --include-tables=CUSTOMERS,ORDERS');
  Writeln('');
  Writeln(TRes.FooterFile);
  Writeln('  DBComparerOracle ... > script.sql');
  Writeln('');
  Halt(1);
end;

function ParseOracleConnection(const ConnStr, UserPass: string;
  out Server, Port, SID, Username, Password, Owner: string): Boolean;
var
  TempStr: string;
  AtPos, SlashPos, ColonPos: Integer;
begin
  Result := False;
  Server := '';
  Port := '1521'; // Puerto por defecto
  SID := '';
  Owner := '';
  
  // Parsear usuario/password[@owner]
  AtPos := Pos('@', UserPass);
  if AtPos > 0 then
  begin
    Owner := Copy(UserPass, AtPos + 1, Length(UserPass));
    TempStr := Copy(UserPass, 1, AtPos - 1);
  end
  else
    TempStr := UserPass;
  
  SlashPos := Pos('/', TempStr);
  if SlashPos > 0 then
  begin
    Username := Copy(TempStr, 1, SlashPos - 1);
    Password := Copy(TempStr, SlashPos + 1, Length(TempStr));
  end
  else
    Exit;
  
  // Parsear cadena de conexión
  // Formato: servidor:puerto/sid o //tnsname o servidor/sid
  if StartsStr('//', ConnStr) then
  begin
    // TNS Name
    SID := Copy(ConnStr, 3, Length(ConnStr));
    Result := True;
  end
  else
  begin
    ColonPos := Pos(':', ConnStr);
    SlashPos := Pos('/', ConnStr);
    
    if (ColonPos > 0) and (SlashPos > ColonPos) then
    begin
      // Formato: servidor:puerto/sid
      Server := Copy(ConnStr, 1, ColonPos - 1);
      Port := Copy(ConnStr, ColonPos + 1, SlashPos - ColonPos - 1);
      SID := Copy(ConnStr, SlashPos + 1, Length(ConnStr));
      Result := True;
    end
    else if (SlashPos > 0) then
    begin
      // Formato: servidor/sid (puerto por defecto)
      Server := Copy(ConnStr, 1, SlashPos - 1);
      SID := Copy(ConnStr, SlashPos + 1, Length(ConnStr));
      Result := True;
    end;
  end;
end;

var
  SourceProvider, TargetProvider: IDBMetadataProvider;
  SourceConn, TargetConn: TUniConnection;
  Writer: IScriptWriter;
  Engine: TDBComparerEngine;
  Options: TComparerOptions;
  SourceHelpers: IDBHelpers;
  SrcServer, SrcPort, SrcSID, SrcUser, SrcPass, SrcOwner: string;
  TgtServer, TgtPort, TgtSID, TgtUser, TgtPass, TgtOwner: string;
begin
  try
    if (ParamCount < 4) then
    begin
      ShowUsage;
      Exit;
    end;
    
    Options := TComparerOptions.ParseFromCLI;
    
    // Parsear configuraciones Oracle
    if not ParseOracleConnection(ParamStr(1), ParamStr(2), 
                                 SrcServer, SrcPort, SrcSID, 
                                 SrcUser, SrcPass, SrcOwner) then
    begin
      Writeln(ErrOutput, 'ERROR: Formato de conexión origen inválido');
      ShowUsage;
      Exit;
    end;
    
    if not ParseOracleConnection(ParamStr(3), ParamStr(4), 
                                 TgtServer, TgtPort, TgtSID, 
                                 TgtUser, TgtPass, TgtOwner) then
    begin
      Writeln(ErrOutput, 'ERROR: Formato de conexión destino inválido');
      ShowUsage;
      Exit;
    end;
    
    try
      // ---------------------------------------------------------
      // CONEXIÓN ORACLE
      // ---------------------------------------------------------
      SourceConn := TUniConnection.Create(nil);
      SourceConn.ProviderName := 'Oracle';
      SourceConn.Server := SrcServer;
      if SrcPort <> '' then
        SourceConn.SpecificOptions.Values['Port'] := SrcPort;
      SourceConn.Database := SrcSID;
      SourceConn.Username := SrcUser;
      SourceConn.Password := SrcPass;
      
      // Si no se especifica Owner, usar el usuario
      if SrcOwner = '' then
        SrcOwner := UpperCase(SrcUser);
      
      SourceProvider := TOracleMetadataProvider.Create(SourceConn,
                                                       SrcSID,
                                                       SrcOwner);
      
      TargetConn := TUniConnection.Create(nil);
      TargetConn.ProviderName := 'Oracle';
      TargetConn.Server := TgtServer;
      if TgtPort <> '' then
        TargetConn.SpecificOptions.Values['Port'] := TgtPort;
      TargetConn.Database := TgtSID;
      TargetConn.Username := TgtUser;
      TargetConn.Password := TgtPass;
      
      if TgtOwner = '' then
        TgtOwner := UpperCase(TgtUser);
      
      TargetProvider := TOracleMetadataProvider.Create(TargetConn,
                                                       TgtSID,
                                                       TgtOwner);
      
      // Crear escritor y helpers
      Writer := TStringListScriptWriter.Create;
      SourceHelpers := TOracleHelpers.Create;
      
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