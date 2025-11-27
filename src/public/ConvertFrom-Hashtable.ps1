function ConvertFrom-HashTable
{
    <#
    .SYNOPSIS
        Converts a hashtable to a PSCustomObject.
    .DESCRIPTION
        This function takes a hashtable and converts it to a PSCustomObject.
        If the hashtable contains nested hashtables, it will recursively convert them as well.
    .PARAMETER HashTable
        The hashtable to convert.
    .EXAMPLE
        $hash = @{ Name = 'John'; Age = 30; Address = @{ Street = '123 Main St'; City = 'Anytown' } }
        $object = ConvertFrom-HashTable -HashTable $hash
        $object | Format-Table -AutoSize
    .NOTES
        This function is useful for converting hashtables to objects that can be easily manipulated in PowerShell.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [hashtable]$HashTable
    )

    process
    {
        Write-Verbose -Message 'Converting hashtable to PSCustomObject'

        $oht = [ordered]@{} # Aux. ordered hashtable for collecting property values.
        foreach ($entry in $HashTable.GetEnumerator())
        {
            if ($entry.Value -is [System.Collections.IDictionary])
            {
                Write-Verbose -Message "Recursively converting nested hashtable for key '$($entry.Key)'"
                # Nested dictionary? Recurse.
                $oht[[object]$entry.Key] = ConvertFrom-HashTable -HashTable $entry.Value # NOTE: Casting to [object] prevents problems with *numeric* hashtable keys.
            }
            else
            {
                Write-Verbose -Message "Adding key '$($entry.Key)' with value '$($entry.Value)'"
                # Copy value as-is.
                $oht[[object]$entry.Key] = $entry.Value
            }
        }

        Write-Verbose -Message 'Conversion complete, outputting PSCustomObject'
        Write-Output [PSCustomObject]$oht # Convert to [PSCustomObject] and output.
    }
}
