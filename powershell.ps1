function Search-ByPrefixes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Object]$Items,

        [Parameter(Mandatory = $true)]
        [ValidateSet("DeviceName", "Name")]
        [String]$NameProperty,

        [Parameter(Mandatory = $false)]
        [ValidateSet("OSName", "GuestOS")]
        [String]$OSProperty,

        [Parameter(Mandatory = $true)]
        [String[]]$Prefixes
    )

    # Filter items based on prefixes
    $filteredItems = $Items | Where-Object {
        $prefixes -match "^(?i)$_.$NameProperty"
    }

    # If OSProperty is provided, return objects with both Name and OS fields
    if ($PSBoundParameters.ContainsKey('OSProperty')) {
        return $filteredItems | Select-Object @{Name="Name";Expression={$_.($NameProperty).Trim()}},
                                               @{Name="OS";Expression={$_.($OSProperty).Trim()}}
    } else {
        return $filteredItems | ForEach-Object { $_.($NameProperty).Trim() }
    }
}
