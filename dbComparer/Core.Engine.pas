unit Core.Engine;

interface

uses Core.Interfaces, Core.Types, System.Classes, Core.Helpers,
     Generics.Collections, Providers.MySQL.Helpers, Data.DB;

type
  TDBComparerEngine = class
  private
    FSourceDB: IDBMetadataProvider; // Interfaz, no objeto concreto
    FTargetDB: IDBMetadataProvider; // Interfaz
    FWriter: IScriptWriter;
    FOptions: TComparerOptions;
    FHelpers: IDBHelpers;
    procedure CompareTableStructure(const TableName: string);
    procedure CompareTableIndexes(const TableName: string);
    procedure CompareTables;
    procedure CompareViews;
    procedure CompareTriggers;
    procedure CompareProcedures;
    procedure CreateNewTable(const TableName: string);
    procedure CompareData(const TableName: string);
    procedure CopyAllData(const TableName: string);
    function BuildWhereClause(const PKCols: TStringList; DataSet: TDataSet): string;
  public
    constructor Create(Source, Target: IDBMetadataProvider;
                       Writer: IScriptWriter;
                       Helpers: IDBHelpers;
                       Options: TComparerOptions);
    procedure GenerateScript;
  end;

implementation

uses
  System.SysUtils;

constructor TDBComparerEngine.Create(Source, Target: IDBMetadataProvider;
                                     Writer: IScriptWriter;
                                     Helpers: IDBHelpers;
                                     Options: TComparerOptions);
begin
  FSourceDB := Source;
  FTargetDB := Target;
  FWriter := Writer;
  FOptions := Options;
  FHelpers := Helpers;
end;

procedure TDBComparerEngine.CreateNewTable(const TableName: string);
var
  Table: TTableInfo;
  Indexes: TArray<TIndexInfo>;
  i: Integer;
  Idx: TIndexInfo;
  PKList: TStringList;
  ColDef: string;
begin
  FWriter.AddComment('Tabla nueva: ' + TableName);
  Table := FSourceDB.GetTableStructure(TableName);
  PKList := TStringList.Create;
  try
    // Generar CREATE TABLE
    FWriter.AddCommand('CREATE TABLE `' + TableName + '` (');
    // Definiciones de columnas
    for i := 0 to Table.Columns.Count - 1 do
    begin
      // Detectar si es PK
      if SameText(Table.Columns[i].ColumnKey, 'PRI') then
        PKList.Add('`' + Table.Columns[i].ColumnName + '`');
      ColDef := '  ' + FHelpers.GenerateColumnDefinition(Table.Columns[i]);
      // Agregar coma si no es la última columna O si hay PK pendiente
      if (i < Table.Columns.Count - 1) or (PKList.Count > 0) then
        ColDef := ColDef + ',';
      FWriter.AddCommand(ColDef);
    end;
    // Agregar PRIMARY KEY inline si existe
    if PKList.Count > 0 then
      FWriter.AddCommand('  PRIMARY KEY (' + PKList.CommaText + ')');
    FWriter.AddCommand(')');
    FWriter.AddCommand('');
    // Agregar índices secundarios (no PRIMARY)
    Indexes := FSourceDB.GetTableIndexes(TableName);
    for Idx in Indexes do
    begin
      if not Idx.IsPrimary then
      begin
        FWriter.AddComment('Agregar índice: ' + TableName + '.' + Idx.IndexName);
        FWriter.AddCommand(FHelpers.GenerateIndexDefinition(TableName, Idx));
      end;
    end;
  finally
    Table.Free;
    PKList.Free;
  end;
end;

procedure TDBComparerEngine.GenerateScript;
begin
  FWriter.AddComment('========================================');
  FWriter.AddComment('SCRIPT DE SINCRONIZACIÓN');
  FWriter.AddComment('Generado: ' + DateTimeToStr(Now));
  FWriter.AddComment('========================================');
  FWriter.AddCommand('');
  CompareTables;
  CompareViews;
  CompareProcedures;
  if FOptions.WithTriggers then
    CompareTriggers;
end;

procedure TDBComparerEngine.CompareTables;
var
  SourceTables, TargetTables: TStringList;
  i: Integer;
begin
  SourceTables := FSourceDB.GetTables;
  TargetTables := FTargetDB.GetTables;
  try
    // 1. Tablas eliminadas (si no está --nodelete)
    if not FOptions.NoDelete then
    begin
      for i := 0 to TargetTables.Count - 1 do
      begin
        if SourceTables.IndexOf(TargetTables[i]) = -1 then
        begin
          FWriter.AddComment('Tabla eliminada: ' + TargetTables[i]);
          FWriter.AddCommand(FHelpers.GenerateDropTableSQL(TargetTables[i]));
        end;
      end;
    end;
    // 2. Tablas nuevas o modificadas
    for i := 0 to SourceTables.Count - 1 do
    begin
      if TargetTables.IndexOf(SourceTables[i]) = -1 then
      begin
        // Tabla nueva - Crear completa
        CreateNewTable(SourceTables[i]);
      end
      else
      begin
        // Tabla existente - Comparar estructura
        CompareTableStructure(SourceTables[i]);
      end;
    end;
    // --- INTEGRACIÓN DE DATOS ---
    if FOptions.WithData or FOptions.WithDataDiff then
    begin
       for i := 0 to SourceTables.Count - 1 do
       begin
         // Lógica de Filtro (Include/Exclude Tables)
         var SkipData := False;
         if (FOptions.IncludeTables.Count > 0) and
            (FOptions.IncludeTables.IndexOf(SourceTables[i]) = -1) then
           SkipData := True;
         if (FOptions.ExcludeTables.IndexOf(SourceTables[i]) >= 0) then
           SkipData := True;
         if not SkipData then
         begin
           if FOptions.WithData then
             CopyAllData(SourceTables[i])
           else if FOptions.WithDataDiff then
           begin
             // Solo comparamos si la tabla existe en ambos lados, si es nueva
             // ya se habría creado vacía, así que podríamos llenarla,
             // pero WithDataDiff asume sincronización.
             if TargetTables.IndexOf(SourceTables[i]) > -1 then
               CompareData(SourceTables[i]);
           end;
         end;
       end;
    end;
  finally
    SourceTables.Free;
    TargetTables.Free;
  end;
end;

procedure TDBComparerEngine.CompareTableStructure(const TableName: string);
var
  Table1, Table2: TTableInfo;
  Col1, Col2: TColumnInfo;
  FoundIdx: Integer;

  function FindColumn(List: TList<TColumnInfo>; const Name: string): Integer;
  var
    k: Integer;
  begin
    Result := -1;
    for k := 0 to List.Count - 1 do
      if SameText(List[k].ColumnName, Name) then
        Exit(k);
  end;

begin
  Table1 := FSourceDB.GetTableStructure(TableName);
  Table2 := FTargetDB.GetTableStructure(TableName);
  try
    // ---------------------------------------------------------
    // 1. Recorrer Origen (Table1) para buscar NUEVAS o MODIFICADAS
    // ---------------------------------------------------------
    for var i := 0 to Table1.Columns.Count - 1 do
    begin
      Col1 := Table1.Columns[i];
      FoundIdx := FindColumn(Table2.Columns, Col1.ColumnName);
      if FoundIdx = -1 then
      begin
        // CASO A: La columna no existe en Destino -> CREAR
        FWriter.AddComment('Agregar columna: ' + TableName + '.' +
                           Col1.ColumnName);
        // El Helper se encarga del dialecto SQL (ADD COLUMN vs ADD ...)
        FWriter.AddCommand(FHelpers.GenerateAddColumnSQL(TableName, Col1));
      end
      else
      begin
        // CASO B: La columna existe -> COMPARAR
        Col2 := Table2.Columns[FoundIdx];
        // Usamos la lógica universal del Helper abstracto
        if not FHelpers.ColumnsAreEqual(Col1, Col2) then
        begin
          FWriter.AddComment('Modificar columna: ' + TableName + '.' +
                              Col1.ColumnName);
          FWriter.AddCommand(FHelpers.GenerateModifyColumnSQL(TableName, Col1));
        end;
      end;
    end;
    // ---------------------------------------------------------
    // 2. Recorrer Destino (Table2) para buscar ELIMINADAS
    // ---------------------------------------------------------
    if not FOptions.NoDelete then
    begin
      for var i := 0 to Table2.Columns.Count - 1 do
      begin
        Col2 := Table2.Columns[i];
        FoundIdx := FindColumn(Table1.Columns, Col2.ColumnName);
        if FoundIdx = -1 then
        begin
          // CASO C: La columna sobra en destino -> BORRAR
          FWriter.AddComment('Eliminar columna: ' + TableName + '.' +
                             Col2.ColumnName);
          // El Helper sabe cómo borrar (DROP COLUMN)
          FWriter.AddCommand(FHelpers.GenerateDropColumnSQL(TableName,
                                                            Col2.ColumnName));
        end;
      end;
    end;
    // ---------------------------------------------------------
    // 3. Comparar Índices (Llamada separada)
    // ---------------------------------------------------------
    CompareTableIndexes(TableName);
  finally
    Table1.Free;
    Table2.Free;
  end;
end;

procedure TDBComparerEngine.CompareTriggers;
var
  SourceTriggers, TargetTriggers: TArray<TTriggerInfo>;
  i, j: Integer;
  Found: Boolean;
  TriggerDef: string;
begin
  // Obtener los arrays de triggers (Records)
  SourceTriggers := FSourceDB.GetTriggers;
  TargetTriggers := FTargetDB.GetTriggers;
  FWriter.AddComment('========================================');
  FWriter.AddComment('TRIGGERS');
  FWriter.AddComment('========================================');
  FWriter.AddCommand('');
  // 1. TRIGGERS ELIMINADOS (Existen en Destino, pero no en Origen)
  if not FOptions.NoDelete then
  begin
    for i := Low(TargetTriggers) to High(TargetTriggers) do
    begin
      Found := False;
      // Buscar si el trigger de destino existe en el origen
      for j := Low(SourceTriggers) to High(SourceTriggers) do
      begin
        if SameText(SourceTriggers[j].TriggerName, TargetTriggers[i].TriggerName) then
        begin
          Found := True;
          Break;
        end;
      end;
      if not Found then
      begin
        FWriter.AddComment('Eliminar trigger: ' + TargetTriggers[i].TriggerName);
        FWriter.AddCommand(FHelpers.GenerateDropTrigger(TargetTriggers[i].TriggerName));
      end;
    end;
  end;
  // 2. TRIGGERS NUEVOS O MODIFICADOS
  for i := Low(SourceTriggers) to High(SourceTriggers) do
  begin
    Found := False;
    for j := Low(TargetTriggers) to High(TargetTriggers) do
    begin
      // Comparamos por nombre
      if SameText(SourceTriggers[i].TriggerName, TargetTriggers[j].TriggerName) then
      begin
        Found := True;

        // Si existen en ambos, comparamos su contenido usando el Helper
        if not FHelpers.TriggersAreEqual(SourceTriggers[i], TargetTriggers[j]) then
        begin
          FWriter.AddComment('Modificar trigger: ' + SourceTriggers[i].TriggerName);

          // Para modificar un trigger, generalmente se borra y se crea de nuevo
          FWriter.AddCommand(FHelpers.GenerateDropTrigger(
                                                SourceTriggers[i].TriggerName));
          // Obtenemos el SQL completo del trigger desde la BD origen
          TriggerDef := FSourceDB.GetTriggerDefinition(
                                                 SourceTriggers[i].TriggerName);
          // OJO: En algunos clientes MySQL se necesita 'DELIMITER $$',
          // pero UniDAC/ScriptWriter suelen manejar comandos individuales.
          // Si vas a ejecutar esto en Workbench, podrías necesitar añadir delimitadores.
          FWriter.AddCommand(TriggerDef);
        end;
        Break;
      end;
    end;

    // Si no se encontró en destino, es NUEVO
    if not Found then
    begin
      FWriter.AddComment('Crear trigger: ' + SourceTriggers[i].TriggerName);
      TriggerDef := FSourceDB.GetTriggerDefinition(
                                                 SourceTriggers[i].TriggerName);
      FWriter.AddCommand(TriggerDef);
    end;
  end;
end;

procedure TDBComparerEngine.CompareViews;
var
  SourceViews: TStringList;
  i: Integer;
begin
  SourceViews := FSourceDB.GetViews;
  try
    FWriter.AddComment('=== VISTAS ===');
    for i := 0 to SourceViews.Count - 1 do
    begin
      FWriter.AddComment('Recreando vista: ' + SourceViews[i]);
      // MySQL suele requerir DROP antes de create si cambia la definición
      FWriter.AddCommand(FHelpers.GenerateDropView(SourceViews[i]));
      FWriter.AddCommand(FSourceDB.GetViewDefinition(SourceViews[i]));
    end;
  finally
    SourceViews.Free;
  end;
end;

// En uses añadir: Data.DB

procedure TDBComparerEngine.CopyAllData(const TableName: string);
var
  SourceData: TDataSet;
  Fields, Values: TStringList;
  i: Integer;
begin
  FWriter.AddComment('Copiando datos completos: ' + TableName);
  SourceData := FSourceDB.GetData(TableName);
  Fields := TStringList.Create;
  Values := TStringList.Create;
  try
    // Preparamos lista de campos una vez (asumiendo coincidencia por nombre)
    // Nota: En una versión robusta, verificaríamos que campos existen en destino
    // pero para CopyData asumimos estructura idéntica recién creada o validada.
    while not SourceData.Eof do
    begin
      Fields.Clear;
      Values.Clear;
      for i := 0 to SourceData.FieldCount - 1 do
      begin
        Fields.Add(FHelpers.QuoteIdentifier(SourceData.Fields[i].FieldName));
        Values.Add(FHelpers.ValueToSQL(SourceData.Fields[i]));
      end;
      // Usamos INSERT IGNORE o similar si fuera necesario, aquí INSERT estándar
      FWriter.AddCommand(FHelpers.GenerateInsertSQL(TableName, Fields, Values));
      SourceData.Next;
    end;
  finally
    SourceData.Free; // El provider nos dio el dataset, pero somos dueños de liberarlo
    Fields.Free;
    Values.Free;
  end;
end;

procedure TDBComparerEngine.CompareData(const TableName: string);
var
  SourceData, TargetData, TempSource: TDataSet; // TempSource añadido para deletes
  PKCols: TStringList;
  TableStruct: TTableInfo;
  Col: TColumnInfo;
  WhereClause, SetClause: string;
  Fields, Values: TStringList;
  i: Integer;
  // IsEqual: Boolean; // BORRADO: No se usaba
begin
  // ... (Parte 1: Obtener PKs igual que antes) ...
  TableStruct := FSourceDB.GetTableStructure(TableName);
  PKCols := TStringList.Create;
  try
    for Col in TableStruct.Columns do
      if SameText(Col.ColumnKey, 'PRI') then
        PKCols.Add(Col.ColumnName);
    if PKCols.Count = 0 then
    begin
      FWriter.AddComment('ADVERTENCIA: ' + TableName + ' no tiene PK. Se omite diff de datos.');
      Exit;
    end;
    FWriter.AddComment('Sincronizando datos (INSERT/UPDATE): ' + TableName);
    // -----------------------------------------------------------
    // FASE A: Recorrer ORIGEN -> Buscar en DESTINO (Insert/Update)
    // -----------------------------------------------------------
    SourceData := FSourceDB.GetData(TableName);
    Fields := TStringList.Create;
    Values := TStringList.Create;
    try
      while not SourceData.Eof do
      begin
        WhereClause := BuildWhereClause(PKCols, SourceData);
        TargetData := FTargetDB.GetData(TableName, WhereClause);
        try
          if TargetData.IsEmpty then
          begin
             // INSERT
             Fields.Clear;
             Values.Clear;
             for i := 0 to SourceData.FieldCount - 1 do
             begin
               Fields.Add(FHelpers.QuoteIdentifier(SourceData.Fields[i].FieldName));
               Values.Add(FHelpers.ValueToSQL(SourceData.Fields[i]));
             end;
             FWriter.AddComment('Insertar registro faltante (PK: ' + WhereClause + ')');
             FWriter.AddCommand(FHelpers.GenerateInsertSQL(TableName, Fields, Values));
          end
          else
          begin
            // UPDATE
            SetClause := '';
            for i := 0 to SourceData.FieldCount - 1 do
            begin
              // Ignorar PKs
              if PKCols.IndexOf(SourceData.Fields[i].FieldName) >= 0 then Continue;

              if TargetData.FindField(SourceData.Fields[i].FieldName) <> nil then
              begin
                 if SourceData.Fields[i].AsString <> TargetData.FieldByName(SourceData.Fields[i].FieldName).AsString then
                 begin
                   if SetClause <> '' then SetClause := SetClause + ', ';
                   SetClause := SetClause + FHelpers.QuoteIdentifier(SourceData.Fields[i].FieldName) +
                                ' = ' + FHelpers.ValueToSQL(SourceData.Fields[i]);
                 end;
              end;
            end;
            if SetClause <> '' then
            begin
              FWriter.AddComment('Actualizar registro modificado (PK: ' + WhereClause + ')');
              FWriter.AddCommand(FHelpers.GenerateUpdateSQL(TableName, SetClause, WhereClause));
            end;
          end;
        finally
          TargetData.Free;
        end;
        SourceData.Next;
      end;
    finally
      SourceData.Free;
      Fields.Free;
      Values.Free;
    end;
    // -----------------------------------------------------------
    // FASE B: Recorrer DESTINO -> Buscar en ORIGEN (Delete)
    // -----------------------------------------------------------
    if not FOptions.NoDelete then
    begin
      FWriter.AddComment('Verificando eliminaciones en: ' + TableName);
      // Traemos tabla completa de destino (Optimización: Podría ser lento en tablas gigantes)
      TargetData := FTargetDB.GetData(TableName);
      try
        while not TargetData.Eof do
        begin
          WhereClause := BuildWhereClause(PKCols, TargetData);
          // Verificamos si existe en origen
          TempSource := FSourceDB.GetData(TableName, WhereClause);
          try
            if TempSource.IsEmpty then
            begin
              FWriter.AddComment('Eliminar registro obsoleto (PK: ' + WhereClause + ')');
              FWriter.AddCommand(FHelpers.GenerateDeleteSQL(TableName, WhereClause));
            end;
          finally
            TempSource.Free;
          end;
          TargetData.Next;
        end;
      finally
        TargetData.Free;
      end;
    end;
  finally
    TableStruct.Free;
    PKCols.Free;
  end;
end;

function TDBComparerEngine.BuildWhereClause(const PKCols: TStringList;
                                            DataSet: TDataSet): string;
var
  i: Integer;
  Field: TField;
begin
  Result := '';
  for i := 0 to PKCols.Count - 1 do
  begin
    if i > 0 then Result := Result + ' AND ';
    Field := DataSet.FieldByName(PKCols[i]);
    Result := Result + FHelpers.QuoteIdentifier(PKCols[i]) + ' = ' +
              FHelpers.ValueToSQL(Field);
  end;
end;

procedure TDBComparerEngine.CompareProcedures;
var
  SourceProcs: TStringList;
  i: Integer;
begin
  SourceProcs := FSourceDB.GetProcedures;
  try
    FWriter.AddComment('=== PROCEDIMIENTOS ===');
    for i := 0 to SourceProcs.Count - 1 do
    begin
      FWriter.AddComment('Recreando procedimiento: ' + SourceProcs[i]);
      FWriter.AddCommand(FHelpers.GenerateDropProcedure(SourceProcs[i]));
      FWriter.AddCommand(FSourceDB.GetProcedureDefinition(SourceProcs[i]));
    end;
  finally
    SourceProcs.Free;
  end;
end;

procedure TDBComparerEngine.CompareTableIndexes(const TableName: string);
var
  SourceIndexes, TargetIndexes: TArray<TIndexInfo>;
  Found: Boolean;
begin
  SourceIndexes := FSourceDB.GetTableIndexes(TableName);
  TargetIndexes := FTargetDB.GetTableIndexes(TableName);
  // 1. Eliminar índices que ya no existen
  if not FOptions.NoDelete then
  begin
    for var i := 0 to High(TargetIndexes) do
    begin
      // No borrar PRIMARY KEY aquí (se maneja diferente)
      if TargetIndexes[i].IsPrimary then
        Continue;
      Found := False;
      for var j := 0 to High(SourceIndexes) do
      begin
        if SameText(SourceIndexes[j].IndexName, TargetIndexes[i].IndexName) then
        begin
          Found := True;
          Break;
        end;
      end;
      if not Found then
      begin
        FWriter.AddComment('Eliminar índice: ' + TableName + '.' +
                          TargetIndexes[i].IndexName);
        FWriter.AddCommand(FHelpers.GenerateDropIndexSQL(TableName,
                                                   TargetIndexes[i].IndexName));
      end;
    end;
  end;
  // 2. Crear o modificar índices
  for var i := 0 to High(SourceIndexes) do
  begin
    Found := False;
    for var j := 0 to High(TargetIndexes) do
    begin
      if SameText(SourceIndexes[i].IndexName, TargetIndexes[j].IndexName) then
      begin
        Found := True;
        // Si son diferentes, recrear
        if not FHelpers.IndexesAreEqual(SourceIndexes[i], TargetIndexes[j]) then
        begin
          FWriter.AddComment('Modificar índice: ' + TableName + '.' +
                            SourceIndexes[i].IndexName);
          FWriter.AddCommand(FHelpers.GenerateDropIndexSQL(TableName,
                                                             SourceIndexes[i].IndexName));
          FWriter.AddCommand(FHelpers.GenerateIndexDefinition(TableName,
                                                              SourceIndexes[i]));
        end;
        Break;
      end;
    end;
    // Índice nuevo
    if not Found then
    begin
      FWriter.AddComment('Agregar índice: ' + TableName + '.' +
                        SourceIndexes[i].IndexName);
      FWriter.AddCommand(FHelpers.GenerateIndexDefinition(TableName,
                                                          SourceIndexes[i]));
    end;
  end;
end;

end.