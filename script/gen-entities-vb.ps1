param (
    $invariant = "System.Data.SqlClient", 
    $connectionString = "Data Source=.;Initial Catalog=Soma.Tutorial;Integrated Security=True", 
    $namespace = "Example", 
    $fileHeader = $null,
    $includeSchemaNamePattern = '.*',
    $excludeSchemaNamePattern = '.*\$.*',
    $includeTableNamePattern = '.*',
    $excludeTableNamePattern = '.*\$.*',
    $versionColumnNamePattern = '^VERSION([_]?NO)?$',
    [switch] $isEnclosed,
    [switch] $convert
)

function fromSnakeCaseToCamelCase([string] $text)
{    
    $results  = @()
    $values = $text.Split('_')    
    foreach ($s in $values)
    {
        $s = $s.ToLower()
        $chars = $s.ToCharArray()
        $chars[0] = [char]::ToUpper($chars[0])
        $results += New-Object string (,$chars)
    }
    [string]::Join("", $results)
}

function generate($catalog, $schema, $tableName, $tableType) 
{
    begin
    {
        $typeName = if ($convert) { fromSnakeCaseToCamelCase $tableName } else { $tableName }
        $isEnclosedValue = if ($isEnclosed) { "true" } else { "false" }
        $isTable = $tableType -imatch "BASE TABLE"
        if ($isTable) {
            write-output @"
    <Table(Name:="$tableName", IsEnclosed:=$isEnclosedValue)>
"@
        }
        write-output @"
    Public Partial Class $typeName
"@
    }
    process 
    {
        $row = $_
        if ($isTable)
        {
            if ($row.IsKey) 
            {
                if ($row.IsIdentity) 
                {
                    write-output @"
        <Id(IdKind.Identity)>
"@
                } 
                else 
                {
                    write-output @"
        <Id()>
"@
                }
            } 
            else 
            {
                if ($row.IsRowVersion) 
                {
                    write-output @"
        <Version(VersionKind.Computed)>
"@
                }
                elseif ($row.ColumnName -imatch $versionColumnNamePattern) 
                {
                    write-output @"
        <Version()>
"@
                }
            }
        }
        $propType = if ($row.AllowDBNull -and $row.DataType.IsValueType) { "$($row.DataType.Name)?" } else { $row.DataType.Name }
        $propName = if ($convert) { fromSnakeCaseToCamelCase $row.ColumnName } else { $row.ColumnName }
        write-output @"        
        <Column(Name:="$($row.ColumnName)", IsEnclosed:=$isEnclosedValue)>
        Public Property $propName As $propType
"@
    }
    end 
    {
        write-output @"
    End Class
    
"@
    }
}

if ($fileHeader) {
    write-output @"
$fileHeader
"@
}
write-output  @"
Imports System
Imports Soma.Core

Namespace $namespace
"@
$factory = [System.Data.Common.DbProviderFactories]::GetFactory($invariant)
$connection = $factory.CreateConnection()
try
{
    $connection.ConnectionString = $connectionString
    $connection.Open()
    $schema = $connection.GetSchema("Tables") 
    $schema.Rows | foreach { 
        $catalogName = $_.TABLE_CATALOG 
        $schemaName = $_.TABLE_SCHEMA 
        $tableName = $_.TABLE_NAME    
        $tableType = if ($_.TABLE_TYPE -eq $null) { "BASE TABLE" } else { $_.TABLE_TYPE }
        if ($invariant -eq "Oracle.DataAccess.Client")
        {
            if ($_.TYPE -eq "System" -or $tableName -match "^WWV_.*")
            {
                return
            }
            $schemaName = $_.OWNER    
        }    
        if (($schemaName -imatch $includeSchemaNamePattern) -and 
            ($schemaName -inotmatch $excludeSchemaNamePattern) -and 
            ($tableName -imatch $includeTableNamePattern) -and 
            ($tableName -inotmatch $excludeTableNamePattern)) 
        {        
            $command = $connection.CreateCommand()
            try
            {
                $command.CommandText = "select * from $tableName"
                $reader = $command.ExecuteReader([System.Data.CommandBehavior]::SchemaOnly -bor [System.Data.CommandBehavior]::KeyInfo) 
                try 
                {
                    $table = $reader.GetSchemaTable()
                    $table.Rows | generate $catalogName $schemaName $tableName $tableType
                }
                finally
                {
                    $reader.Dispose()
                }
            }
            finally
            {
                $command.Dispose()            
            }
        }
    }
}
finally
{
    $connection.Dispose()
}
write-output @"
End Namespace
"@