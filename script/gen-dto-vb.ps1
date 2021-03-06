param (
    $invariant = "System.Data.SqlClient", 
    $connectionString = "Data Source=.;Initial Catalog=Soma.Tutorial;Integrated Security=True", 
    $fileHeader = $null,
    $namespace = "Example", 
    [Parameter(Mandatory=$true, Position=0)]
    $typeName,
    [Parameter(Mandatory=$true, Position=1)]
    $sql,
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

function generate() 
{
    begin 
    {
        $propNameDict = @{}
        if ($fileHeader) {
            write-output @"
$fileHeader
"@
        }
        write-output  @"
Imports System
Imports Soma.Core

Namespace $namespace

    Public Partial Class $typeName
"@
    }
    process 
    {
        $row = $_
        $propType = if ($row.AllowDBNull -and $row.DataType.IsValueType) { "$($row.DataType.Name)?" } else { $row.DataType.Name }
        $propName = if ($convert) { fromSnakeCaseToCamelCase $row.ColumnName } else { $row.ColumnName }
        if (-not $propNameDict.Contains($propName)) {
            $propNameDict[$propName] = $propName
            write-output @"
        <Column(Name:="$($row.ColumnName)")>
        Public Property $propName As $propType
"@
        }
    }
    end 
    {
        write-output @"
    End Class

End Namespace
"@
    }
}

$factory = [System.Data.Common.DbProviderFactories]::GetFactory($invariant)
$connection = $factory.CreateConnection()
try
{
    $connection.ConnectionString = $connectionString
    $connection.Open()
    $command = $connection.CreateCommand()
    try
    {
        $command.CommandText = $sql
        $reader = $command.ExecuteReader([System.Data.CommandBehavior]::SchemaOnly)
        try
        {
            $table = $reader.GetSchemaTable()
            $table.Rows | generate
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
finally
{
    $connection.Dispose()
}