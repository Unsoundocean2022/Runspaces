function Search-ByPrefixes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Object[]]$Items,

        [Parameter(Mandatory = $true)]
        [ValidateSet("DeviceName", "Name")]
        [String]$NameProperty,

        [Parameter(Mandatory = $false)]
        [ValidateSet("OSName", "GuestOS")]
        [String]$OSProperty,

        [Parameter(Mandatory = $true)]
        [String[]]$Prefixes
    )

    # Filter items based on prefix match
    $filteredItems = foreach ($item in $Items) {
        foreach ($prefix in $Prefixes) {
            if ($item.$NameProperty -and $item.$NameProperty.ToLower().StartsWith($prefix.ToLower())) {
                if ($PSBoundParameters.ContainsKey('OSProperty')) {
                    # Return Name & OS when OSProperty is provided
                    [PSCustomObject]@{
                        Name = $item.$NameProperty.Trim()
                        OS   = $item.$OSProperty.Trim()
                    }
                } else {
                    # Return just NameProperty when OSProperty is not provided
                    $item.$NameProperty.Trim()
                }
                break # Avoid redundant checks once matched
            }
        }
    }

    return $filteredItems
}
