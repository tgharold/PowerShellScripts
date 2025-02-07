[CmdletBinding(SupportsShouldProcess)] #Make sure we can use -WhatIf and -Verbose
Param()

function Sort-ObjectPropertiesByName {
    process {
        if ($_ -eq $null) { return }
        Write-Debug "`$_: $($_)"
        $typeList = $_.GetType() | Select-Object -Property Name, FullName, BaseType
        Write-Debug "`$_{$($typeList)} = $($_)"

        if ($_ -is [System.Collections.IDictionary]) {
            $sortedObject = [ordered]@{}
            foreach($key in $_.Keys | Sort-Object) {
                $value = $_[$key]
                Write-Debug "key-value[$($key)]: $($value)"
                if ($value -is [PSCustomObject] -or $value -is [System.Management.Automation.PSObject] -or $value -is [System.Collections.IDictionary]) {
                    $sortedValue = $value | Sort-ObjectPropertiesByName
                    $sortedObject.Add($key, $sortedValue)
                } else {
                    $sortedObject.Add($key, $value)
                }
            }
            Write-Debug "`$sortedObject{$($sortedObject.GetType())} = $($sortedObject)"
            $sortedObject
        } else {
            $properties = $_.PSObject.Properties | Sort-Object Name
            $sortedObject = [ordered]@{}
            foreach ($property in $properties) {
                $typeList = $property.Value?.GetType() | Select-Object -Property Name, FullName, BaseType
                Write-Debug "property{$($typeList)}: $($property.Value)"
                if ($property.Value -is [PSCustomObject] -or $property.Value -is [System.Management.Automation.PSObject] -or $property.Value -is [System.Collections.IDictionary]) {
                    $value = $property.Value | Sort-ObjectPropertiesByName
                    $sortedObject.Add($property.Name, $value)
                } elseif ($property.Value -is [array]) {
                    Write-Debug "property-array{$($typeList)}: $($property.Value)"
                    $sortedValues = @($property.Value | Sort-Object -Stable)
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
    Zoo = $null
    Zulu = "b", "a", "t", "h", "f"
    Tags = @("Yellow")
    Taco = 7
    Gerald = @{
        Zebra = "Pink"
        Nada = @{
            T = $null
            Seven = "Alpha"
            Bravo = "Eight"
            V = @(5)
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

$output1 = $input1 | Sort-ObjectPropertiesByName
Write-Debug "`$output1.GetType() = $($output1.GetType()  | Select-Object -Property Name, FullName, BaseType)"
Write-Debug $($output1 | ConvertTo-Json -Depth 100)
Write-Debug "..."
