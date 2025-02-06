[CmdletBinding(SupportsShouldProcess)] #Make sure we can use -WhatIf and -Verbose
Param()

function Sort-ObjectPropertiesByName {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $InputObject
    )

    process {
        $typeList = $InputObject.GetType() | Select-Object -Property Name, FullName, BaseType
        Write-Debug "`$InputObject{$($typeList)} = $($InputObject)"

        if ($InputObject -is [System.Collections.IDictionary]) {
            $sortedObject = [ordered]@{}
            foreach($key in $InputObject.Keys | Sort-Object) {
                $value = $InputObject[$key]
                Write-Debug "key-value[$($key)]: $($value)"
                if ($value -is [PSCustomObject] -or $value -is [System.Management.Automation.PSObject] -or $value -is [System.Collections.IDictionary]) {
                    $sortedValue = Sort-ObjectPropertiesByName -InputObject $value
                    $sortedObject.Add($key, $sortedValue)
                } else {
                    $sortedObject.Add($key, $value)
                }
            }
            Write-Debug "`$sortedObject{$($sortedObject.GetType())} = $($sortedObject)"
            $sortedObject
        } else {
            $properties = $InputObject.PSObject.Properties | Sort-Object Name
            $sortedObject = [ordered]@{}
            foreach ($property in $properties) {
                $typeList = $property.Value.GetType() | Select-Object -Property Name, FullName, BaseType
                Write-Debug "property{$($typeList)}: $($property.Value)"
                if ($property.Value -is [PSCustomObject] -or $property.Value -is [System.Management.Automation.PSObject] -or $property.Value -is [System.Collections.IDictionary]) {
                    $value = Sort-ObjectPropertiesByName -InputObject $property.Value
                    $sortedObject.Add($property.Name, $value)
                } elseif ($property.Value -is [array]) {
                    Write-Debug "property-array{$($typeList)}: $($property.Value)"
                    $sortedValues = $property.Value | Sort-Object -Stable
                    $sortedObject.Add($property.Name, $sortedValues)
                } else {
                    $sortedObject.Add($property.Name, $property.Value)
                }
            }
            Write-Debug "`$sortedObject{$($sortedObject.GetType())} = $($sortedObject)"
            [PSCustomObject]$sortedObject
        }
    }
}

$input1 = [PSCustomObject][ordered]@{
    Bell = 5
    Zulu = "b", "a", "t", "h", "f"
    Taco = 7
    Gerald = @{
        Zebra = "Pink"
        Nada = @{
            Seven = "Alpha"
            Bravo = "Eight"
            Q = [PSCustomObject][ordered]@{        
                Charred = 5, 3, 2, 7, 9
            }
            Alpha = "Tango"
        }
        Blue = "Yellow"
        "Charlie Seven" = "12345662"
    }
}
Write-Debug "`$input1.GetType() = $($input1.GetType()  | Select-Object -Property Name, FullName, BaseType)"
Write-Debug $($input1 | ConvertTo-Json -Depth 100)
Write-Debug "..."

$output1 = Sort-ObjectPropertiesByName -InputObject $input1
Write-Debug "`$output1.GetType() = $($output1.GetType()  | Select-Object -Property Name, FullName, BaseType)"
Write-Debug $($output1 | ConvertTo-Json -Depth 100)
Write-Debug "..."
