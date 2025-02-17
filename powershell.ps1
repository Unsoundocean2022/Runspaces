function Search-ByPrefixes {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
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


	Begin {
		$filteredItems = @()
	}

	Process {
		foreach ($item in $Items) {
			# Check if $item is null or empty
			if (-not $item) {
				Write-Warning "Skipping null or empty item."
				continue # Skip to the next item
			}

			# OSProperty is present
			if ($PSBoundParameters.ContainsKey('OSProperty')) {
				try {
					# Check if the properties exist and are not null
					if (-not ($item | Get-Member -MemberType NoteProperty -Name $NameProperty) -or -not ($item."$NameProperty")) {
						Write-Warning "Item missing NameProperty: $($NameProperty). Skipping."
						continue
					}
					if (-not ($item | Get-Member -MemberType NoteProperty -Name $OSProperty) -or -not ($item."$OSProperty")) {
						Write-Warning "Item missing OSProperty: $($OSProperty). Skipping."
						continue
					}


					foreach ($prefix in $Prefixes) {
						if (($item."$NameProperty".ToLower()).StartsWith($prefix.ToLower())) {
							$filteredItems += [PSCustomObject]@{
								Name = ($item."$NameProperty").Trim()
								OS   = $item."$OSProperty".Trim()
							}
							break # No need to check other prefixes if a match is found
						}
					}
				}
				catch {
					Write-Error "Error processing item: $($_.Exception.Message)"
				}
			}
			# OSProperty is not present
			else {
				try {
					# Check if the NameProperty exists and is not null
					if (-not ($item | Get-Member -MemberType NoteProperty -Name $NameProperty) -or -not $item."$NameProperty") {
						Write-Warning "Item missing NameProperty: $($NameProperty). Skipping."
						continue
					}


					foreach ($prefix in $Prefixes) {
						if (($item."$NameProperty".ToLower()).StartsWith($prefix.ToLower())) {
							$filteredItems += $item."$NameProperty".Trim()
							break # No need to check other prefixes if a match is found
						}
					}
				}
				catch {
					Write-Error "Error processing item: $($_.Exception.Message)"
				}
			}
		}
	}

	End {
		return $filteredItems
	}
}

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

    # Validate if the necessary properties exist on the objects
    if (-not $Items) {
        Write-Error "No items were provided."
        return
    }

    # Ensure NameProperty exists in the items
    if (-not ($Items[0].PSObject.Properties[$NameProperty])) {
        Write-Error "The property '$NameProperty' does not exist in the items."
        return
    }

    # Validate if OSProperty is present on the items when it's specified
    if ($OSProperty -and -not ($Items[0].PSObject.Properties[$OSProperty])) {
        Write-Error "The property '$OSProperty' does not exist in the items."
        return
    }

    # Initialize an empty array for the filtered items
    $filteredItems = @()

    # Handle the logic based on the presence of the OSProperty
    if ($PSCmdlet.MyInvocation.BoundParameters['OSProperty']) {
        # OSProperty is provided, filtering by both OS and Name properties
        Write-Host "Searching by '$OSProperty' and '$NameProperty'"
        foreach ($item in $Items) {
            foreach ($prefix in $Prefixes) {
                if (($item.$NameProperty).ToLower().StartsWith($prefix.ToLower())) {
                    # Make sure both properties are non-null or empty
                    $filteredItems += [PSCustomObject]@{
                        Name = ($item.$NameProperty).Trim()
                        OS = if ($item.$OSProperty) { $item.$OSProperty.Trim() } else { "Unknown OS" }
                    }
                }
            }
        }
    } else {
        # OSProperty is not provided, filtering only by Name property
        Write-Host "Searching by '$NameProperty' only"
        foreach ($item in $Items) {
            foreach ($prefix in $Prefixes) {
                if (($item.$NameProperty).ToLower().StartsWith($prefix.ToLower())) {
                    $filteredItems += ($item.$NameProperty).Trim()
                }
            }
        }
    }

    # Return the filtered items
    return $filteredItems
}
