# Set CSV attributes
$csv = ".\customers.csv"
$delimiter = ","

# Set connstring
$connstring = "Data Source=localhost;Integrated Security=true;Initial Catalog=PresentationOptimized;PACKET SIZE=32767;"

# Set batchsize to 2000
$batchsize = 2000
$tableName = "customers"

# Create the datatable
$datatable = New-Object System.Data.DataTable

# Read CSV headers
$columns = (Get-Content $csv -First 1).Split($delimiter)

foreach ($column in $columns) {
    [void]$datatable.Columns.Add($column.Trim())
}

# Function to generate a SQL CREATE TABLE statement dynamically
function Create-SQLTable {
    param (
        [string]$tableName,
        [string[]]$columns
    )

    # Define default column type
    $columnDefs = $columns | ForEach-Object { "[$_] NVARCHAR(255)" }
    $createTableSQL = "IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$tableName') `n"
    $createTableSQL += "BEGIN `n"
    $createTableSQL += "CREATE TABLE [$tableName] (`n" + ($columnDefs -join ",`n") + "`n); `n"
    $createTableSQL += "END"

    return $createTableSQL
}

# Execute the CREATE TABLE statement with error handling
try {
    $createTableSQL = Create-SQLTable -tableName $tableName -columns $columns
    $connection = New-Object System.Data.SqlClient.SqlConnection($connstring)
    $command = $connection.CreateCommand()
    $command.CommandText = $createTableSQL
    $connection.Open()
    $null = $command.ExecuteNonQuery()
    $connection.Close()
    Write-Output "Table [$tableName] checked/created successfully."
}
catch {
    Write-Output "Error creating table: $_"
    exit 1
}

# Setup runspace pool
$pool = [RunspaceFactory]::CreateRunspacePool(1,5)
$pool.ApartmentState = "MTA"
$pool.Open()
$runspaces = @()

# Setup scriptblock for bulk insert with error handling
$scriptblock = {
    param (
        [string]$connstring,
        [object]$dtbatch,
        [int]$batchsize,
        [string]$tableName
    )

    try {
        $bulkcopy = New-Object Data.SqlClient.SqlBulkCopy($connstring, "TableLock")
        $bulkcopy.DestinationTableName = $tableName
        $bulkcopy.BatchSize = $batchsize
        $bulkcopy.WriteToServer($dtbatch)
        $bulkcopy.Close()
        $dtbatch.Clear()
        $bulkcopy.Dispose()
        $dtbatch.Dispose()
    }
    catch {
        Write-Output "Error inserting batch: $_"
    }
}

# Start timer
$time = [System.Diagnostics.Stopwatch]::StartNew()

# Open the text file from disk and process.
$reader = New-Object System.IO.StreamReader($csv)
$null = $reader.ReadLine()  # Skip header row

Write-Output "Starting insert..."
while (($line = $reader.ReadLine()) -ne $null) {
    [void]$datatable.Rows.Add($line.Split($delimiter))

    if ($datatable.Rows.Count % $batchsize -eq 0) {
        $runspace = [PowerShell]::Create()
        [void]$runspace.AddScript($scriptblock)
        [void]$runspace.AddArgument($connstring)
        [void]$runspace.AddArgument($datatable.Clone()) # Clone to prevent race conditions
        [void]$runspace.AddArgument($batchsize)
        [void]$runspace.AddArgument($tableName)
        $runspace.RunspacePool = $pool
        $runspaces += [PSCustomObject]@{ Pipe = $runspace; Status = $runspace.BeginInvoke() }

        $datatable.Clear() # Clear for next batch
    }
}

# Close the file
$reader.Close()

# Wait for runspaces to complete
while ($runspaces.Status.IsCompleted -notcontains $true) {}

# End timer
$secs = $time.Elapsed.TotalSeconds

# Cleanup runspaces
foreach ($runspace in $runspaces) {
    try {
        $null = $runspace.Pipe.EndInvoke($runspace.Status)
        $runspace.Pipe.Dispose()
    }
    catch {
        Write-Output "Error cleaning up runspace: $_"
    }
}

# Cleanup runspace pool
$pool.Close()
$pool.Dispose()

# Cleanup SQL Connections
[System.Data.SqlClient.SqlConnection]::ClearAllPools()

# Done! Format output then display
$totalrows = 1000000  # Adjust if necessary
$rs = "{0:N0}" -f [int]($totalrows / $secs)
$rm = "{0:N0}" -f [int]($totalrows / $secs * 60)
$mill = "{0:N0}" -f $totalrows

Write-Output "$mill rows imported in $([math]::round($secs,2)) seconds ($rs rows/sec and $rm rows/min)"
