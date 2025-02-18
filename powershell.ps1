function Search-ByPrefixes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Object]$Items,  # Accepts single object or collection

        [Parameter(Mandatory = $true)]
        [ValidateSet("DeviceName", "Name")]
        [String]$NameProperty,

        [Parameter(Mandatory = $false)]
        [ValidateSet("OSName", "GuestOS")]
        [String]$OSProperty,

        [Parameter(Mandatory = $true)]
        [String[]]$Prefixes
    )

    # Ensure $Items is always treated as an array
    $Items = @($Items)

    # Return empty array if $Items is null or empty
    if (-not $Items) {
        return @()
    }

    # Initialize filtered results
    $filteredItems = foreach ($item in $Items) {
        if (-not $item) { continue }  # Skip null items

        foreach ($prefix in $Prefixes) {
            $nameValue = $item.$NameProperty
            $osValue = if ($PSBoundParameters.ContainsKey('OSProperty')) { $item.$OSProperty } else { $null }

            # Ensure $nameValue is not null and check for prefix match
            if ($nameValue -and $nameValue -is [string] -and $nameValue.ToLower().StartsWith($prefix.ToLower())) {
                if ($PSBoundParameters.ContainsKey('OSProperty') -and $osValue) {
                    # Return Name & OS if OSProperty is provided and not null
                    [PSCustomObject]@{
                        Name = $nameValue.Trim()
                        OS   = $osValue.Trim()
                    }
                } else {
                    # Return just NameProperty if OSProperty is not used
                    $nameValue.Trim()
                }
                break  # Stop checking other prefixes for this item once matched
            }
        }
    }

    return $filteredItems
}
