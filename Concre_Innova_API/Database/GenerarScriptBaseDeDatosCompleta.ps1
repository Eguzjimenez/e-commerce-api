[CmdletBinding()]
param(
    [string]$Servidor = '(localdb)\MSSQLLocalDB',
    [string]$BaseDatosOrigen = 'ConcreInnovaDB',
    [string]$BaseDatosDestino = 'ConcreInnovaDB',
    [string]$OrigenEncabezado,
    [string]$DescripcionDatos = 'Incluye los datos existentes de la base de origen.',
    [string]$ArchivoSalida
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ArchivoSalida)) {
    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
    $ArchivoSalida = Join-Path $scriptDirectory '20260823_BaseDeDatosCompleta.sql'
}

if ([string]::IsNullOrWhiteSpace($OrigenEncabezado)) {
    $OrigenEncabezado = $BaseDatosOrigen
}

function ConvertTo-SqlIdentifier {
    param([Parameter(Mandatory = $true)][string]$Valor)

    return '[' + $Valor.Replace(']', ']]') + ']'
}

function ConvertTo-SqlLiteral {
    param([Parameter(Mandatory = $true)][string]$Valor)

    return "N'" + $Valor.Replace("'", "''") + "'"
}

function Add-SqlBatch {
    param(
        [Parameter(Mandatory = $true)][System.Text.StringBuilder]$Builder,
        [AllowEmptyString()][string]$Sql
    )

    if ([string]::IsNullOrWhiteSpace($Sql)) {
        return
    }

    [void]$Builder.AppendLine($Sql.TrimEnd())
    [void]$Builder.AppendLine('GO')
    [void]$Builder.AppendLine()
}

function Add-SqlSection {
    param(
        [Parameter(Mandatory = $true)][System.Text.StringBuilder]$Builder,
        [Parameter(Mandatory = $true)][string]$Titulo
    )

    [void]$Builder.AppendLine('-- ============================================================================')
    [void]$Builder.AppendLine("-- $Titulo")
    [void]$Builder.AppendLine('-- ============================================================================')
    [void]$Builder.AppendLine()
}

function New-DatabaseScripter {
    param(
        [Parameter(Mandatory = $true)]$Server,
        [Parameter(Mandatory = $true)][bool]$IncluirEsquema,
        [Parameter(Mandatory = $true)][bool]$IncluirDatos
    )

    $scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter $Server
    $scripter.Options.ScriptSchema = $IncluirEsquema
    $scripter.Options.ScriptData = $IncluirDatos
    $scripter.Options.WithDependencies = $false
    $scripter.Options.SchemaQualify = $true
    $scripter.Options.IncludeHeaders = $false
    $scripter.Options.IncludeDatabaseContext = $false
    $scripter.Options.ScriptBatchTerminator = $false
    $scripter.Options.AnsiFile = $false
    $scripter.Options.NoCollation = $false
    $scripter.Options.Permissions = $false
    $scripter.Options.ExtendedProperties = $true
    $scripter.Options.AllowSystemObjects = $false
    return $scripter
}

function Add-SmoObjects {
    param(
        [Parameter(Mandatory = $true)][System.Text.StringBuilder]$Builder,
        [Parameter(Mandatory = $true)]$Scripter,
        [AllowEmptyCollection()][object[]]$Objects
    )

    $urns = @(
        $Objects |
            Where-Object { $null -ne $_ } |
            ForEach-Object { $_.Urn }
    )

    if ($urns.Count -eq 0) {
        return
    }

    [Microsoft.SqlServer.Management.Sdk.Sfc.Urn[]]$typedUrns = $urns
    $batches = @($Scripter.EnumScript($typedUrns))
    foreach ($batch in $batches) {
        Add-SqlBatch -Builder $Builder -Sql $batch
    }
}

Import-Module SQLPS -DisableNameChecking

$server = New-Object Microsoft.SqlServer.Management.Smo.Server $Servidor
$database = $server.Databases[$BaseDatosOrigen]
if ($null -eq $database) {
    throw "No se encontro la base de datos '$BaseDatosOrigen' en '$Servidor'."
}

$database.Refresh()
$databaseIdentifier = ConvertTo-SqlIdentifier $BaseDatosDestino
$databaseLiteral = ConvertTo-SqlLiteral $BaseDatosDestino
if ($database.Collation -notmatch '^[A-Za-z0-9_]+$') {
    throw "La intercalacion '$($database.Collation)' no tiene un formato valido."
}
$collationName = $database.Collation
$builder = New-Object System.Text.StringBuilder

[void]$builder.AppendLine('/*')
[void]$builder.AppendLine('    Concre Innova - base de datos completa')
[void]$builder.AppendLine("    Origen: $OrigenEncabezado")
[void]$builder.AppendLine("    Generado: $([DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss'))")
[void]$builder.AppendLine()
[void]$builder.AppendLine('    Contenido:')
[void]$builder.AppendLine('      - tablas, columnas, claves, restricciones e indices;')
[void]$builder.AppendLine('      - tipos de tabla definidos por el usuario;')
[void]$builder.AppendLine('      - datos existentes, conservando valores identity;')
[void]$builder.AppendLine('      - procedimientos almacenados y triggers.')
[void]$builder.AppendLine()
[void]$builder.AppendLine("    Datos: $DescripcionDatos")
[void]$builder.AppendLine()
[void]$builder.AppendLine('    Ejecute este archivo sobre una instancia de SQL Server con permisos para')
[void]$builder.AppendLine('    crear bases de datos. Por seguridad, el archivo no elimina ni reemplaza')
[void]$builder.AppendLine('    una base existente. Se recomienda ejecutarlo sobre una instancia limpia.')
[void]$builder.AppendLine('*/')
[void]$builder.AppendLine()

Add-SqlSection -Builder $builder -Titulo 'Creacion y seleccion de la base de datos'
Add-SqlBatch -Builder $builder -Sql 'USE [master];'
Add-SqlBatch -Builder $builder -Sql @"
IF DB_ID($databaseLiteral) IS NULL
BEGIN
    CREATE DATABASE $databaseIdentifier COLLATE $collationName;
END;
"@
Add-SqlBatch -Builder $builder -Sql "USE $databaseIdentifier;"
Add-SqlBatch -Builder $builder -Sql @'
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
SET XACT_ABORT ON;
'@

$schemaScripter = New-DatabaseScripter -Server $server -IncluirEsquema $true -IncluirDatos $false
$schemaScripter.Options.DriPrimaryKey = $true
$schemaScripter.Options.DriUniqueKeys = $true
$schemaScripter.Options.DriDefaults = $true
$schemaScripter.Options.DriChecks = $true
$schemaScripter.Options.DriForeignKeys = $false
$schemaScripter.Options.Indexes = $true
$schemaScripter.Options.Triggers = $false
$schemaScripter.Options.FullTextIndexes = $true

Add-SqlSection -Builder $builder -Titulo 'Tipos definidos por el usuario'
Add-SmoObjects -Builder $builder -Scripter $schemaScripter -Objects @(
    $database.UserDefinedDataTypes | Where-Object { -not $_.IsSystemObject } | Sort-Object Schema, Name
)
Add-SmoObjects -Builder $builder -Scripter $schemaScripter -Objects @(
    $database.UserDefinedTableTypes | Where-Object { -not $_.IsSystemObject } | Sort-Object Schema, Name
)

Add-SqlSection -Builder $builder -Titulo 'Secuencias'
Add-SmoObjects -Builder $builder -Scripter $schemaScripter -Objects @(
    $database.Sequences | Sort-Object Schema, Name
)

Add-SqlSection -Builder $builder -Titulo 'Tablas, restricciones locales e indices'
$tables = @($database.Tables | Where-Object { -not $_.IsSystemObject } | Sort-Object Schema, Name)
Add-SmoObjects -Builder $builder -Scripter $schemaScripter -Objects $tables

Add-SqlSection -Builder $builder -Titulo 'Datos'
$dataScripter = New-DatabaseScripter -Server $server -IncluirEsquema $false -IncluirDatos $true
$dataScripter.Options.Triggers = $false
foreach ($table in $tables) {
    Add-SmoObjects -Builder $builder -Scripter $dataScripter -Objects @($table)
}

Add-SqlSection -Builder $builder -Titulo 'Estado de columnas identity'
$identityState = $database.ExecuteWithResults(@'
SELECT
    S.name AS SchemaName,
    T.name AS TableName,
    CONVERT(decimal(38, 0), IC.last_value) AS LastValue,
    CONVERT(decimal(38, 0), IC.increment_value) AS IncrementValue,
    ISNULL
    (
        (
            SELECT SUM(P.rows)
            FROM sys.partitions P
            WHERE P.object_id = T.object_id
              AND P.index_id IN (0, 1)
        ),
        0
    ) AS SourceRowCount
FROM sys.identity_columns IC
INNER JOIN sys.tables T
    ON T.object_id = IC.object_id
INNER JOIN sys.schemas S
    ON S.schema_id = T.schema_id
WHERE T.is_ms_shipped = 0
  AND IC.last_value IS NOT NULL
ORDER BY S.name, T.name;
'@).Tables[0]

foreach ($identityRow in $identityState.Rows) {
    $qualifiedTable =
        (ConvertTo-SqlIdentifier ([string]$identityRow.SchemaName)) + '.' +
        (ConvertTo-SqlIdentifier ([string]$identityRow.TableName))
    $lastValue = [decimal]$identityRow.LastValue
    $incrementValue = [decimal]$identityRow.IncrementValue
    $rowCount = [long]$identityRow.SourceRowCount

    # En una tabla recien creada y vacia, CHECKIDENT usa exactamente el valor
    # indicado en la primera insercion. Se adelanta un incremento para conservar
    # el siguiente identity que produciria la base de origen despues de DELETE.
    $reseedValue = if ($rowCount -eq 0) {
        $lastValue + $incrementValue
    }
    else {
        $lastValue
    }

    $reseedLiteral = $reseedValue.ToString([System.Globalization.CultureInfo]::InvariantCulture)
    Add-SqlBatch -Builder $builder -Sql "DBCC CHECKIDENT (N'$qualifiedTable', RESEED, $reseedLiteral) WITH NO_INFOMSGS;"
}

Add-SqlSection -Builder $builder -Titulo 'Claves foraneas'
$foreignKeyScripter = New-DatabaseScripter -Server $server -IncluirEsquema $true -IncluirDatos $false
$foreignKeyScripter.Options.DriForeignKeys = $true
$foreignKeys = @(
    $tables |
        ForEach-Object { $_.ForeignKeys } |
        Where-Object { -not $_.IsSystemObject } |
        Sort-Object Parent.Schema, Parent.Name, Name
)
Add-SmoObjects -Builder $builder -Scripter $foreignKeyScripter -Objects $foreignKeys

Add-SqlSection -Builder $builder -Titulo 'Funciones y vistas'
$programmabilityScripter = New-DatabaseScripter -Server $server -IncluirEsquema $true -IncluirDatos $false
Add-SmoObjects -Builder $builder -Scripter $programmabilityScripter -Objects @(
    $database.UserDefinedFunctions | Where-Object { -not $_.IsSystemObject } | Sort-Object Schema, Name
)
Add-SmoObjects -Builder $builder -Scripter $programmabilityScripter -Objects @(
    $database.Views | Where-Object { -not $_.IsSystemObject } | Sort-Object Schema, Name
)

Add-SqlSection -Builder $builder -Titulo 'Procedimientos almacenados'
Add-SmoObjects -Builder $builder -Scripter $programmabilityScripter -Objects @(
    $database.StoredProcedures | Where-Object { -not $_.IsSystemObject } | Sort-Object Schema, Name
)

Add-SqlSection -Builder $builder -Titulo 'Triggers'
$triggerScripter = New-DatabaseScripter -Server $server -IncluirEsquema $true -IncluirDatos $false
$triggerScripter.Options.Triggers = $true
$triggers = @(
    $tables |
        ForEach-Object { $_.Triggers } |
        Where-Object { -not $_.IsSystemObject } |
        Sort-Object Parent.Schema, Parent.Name, Name
)
Add-SmoObjects -Builder $builder -Scripter $triggerScripter -Objects $triggers

Add-SqlSection -Builder $builder -Titulo 'Finalizacion'
Add-SqlBatch -Builder $builder -Sql @"
PRINT N'Base de datos $($BaseDatosDestino.Replace("'", "''")) creada correctamente.';
"@

$outputDirectory = Split-Path -Parent $ArchivoSalida
if (-not [string]::IsNullOrWhiteSpace($outputDirectory)) {
    [System.IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
}

$utf8WithBom = New-Object System.Text.UTF8Encoding $true
$normalizedSql = [System.Text.RegularExpressions.Regex]::Replace(
    $builder.ToString(),
    '[\t ]+(?=\r?$)',
    '',
    [System.Text.RegularExpressions.RegexOptions]::Multiline)
$normalizedSql = $normalizedSql.TrimEnd() + [Environment]::NewLine
[System.IO.File]::WriteAllText($ArchivoSalida, $normalizedSql, $utf8WithBom)

Write-Output "Script generado: $ArchivoSalida"
Write-Output "Tablas: $($tables.Count)"
Write-Output "Procedimientos: $(@($database.StoredProcedures | Where-Object { -not $_.IsSystemObject }).Count)"
Write-Output "Triggers: $($triggers.Count)"
