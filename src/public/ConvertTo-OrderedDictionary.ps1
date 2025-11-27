function ConvertTo-OrderedDictionary
{
    <#
    .SYNOPSIS
        Converts a HashTable, Array, or an OrderedDictionary to an OrderedDictionary.
    .DESCRIPTION
        ConvertTo-OrderedDictionary takes a HashTable, Array, or an OrderedDictionary
        and returns an ordered dictionary.

        If you enter a hash table, the keys in the hash table are ordered
        alphanumerically in the dictionary. If you enter an array, the keys
        are integers 0 - n.
    .PARAMETER  Hash
        Specifies a hash table or an array. Enter the hash table or array,
        or enter a variable that contains a hash table or array. If the input
        is an OrderedDictionary the key order is the same in the copy.
    .INPUTS
        System.Collections.Hashtable
        System.Array
        System.Collections.Specialized.OrderedDictionary
    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary
    .NOTES
        source: https://gallery.technet.microsoft.com/scriptcenter/ConvertTo-OrderedDictionary-cf2404ba
        converted to function and added ability to copy OrderedDictionary

    .EXAMPLE
        $myHash = @{a=1; b=2; c=3}
        ConvertTo-OrderedDictionary -Hash $myHash

        Name                           Value
        ----                           -----
        a                              1
        b                              2
        c                              3
    .EXAMPLE
        $myHash = @{a=1; b=2; c=3}
        $myHash = .\ConvertTo-OrderedDictionary.ps1 -Hash $myHash
        $myHash

        Name                           Value
        ----                           -----
        a                              1
        b                              2
        c                              3

        $myHash | Get-Member

        TypeName: System.Collections.Specialized.OrderedDictionary
        . . .

    .EXAMPLE
        $colors = "red", "green", "blue"
        $colors = .\ConvertTo-OrderedDictionary.ps1 -Hash $colors
        $colors

        Name                           Value
        ----                           -----
        0                              red
        1                              green
        2                              blue
    .LINK
        about_hash_tables
    #>

    [CmdletBinding(ConfirmImpact = 'None')]
    [OutputType('System.Collections.Specialized.OrderedDictionary')]
    Param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [object]$InputObject,

        [Parameter(HelpMessage = 'Optionally sort the keys in the resulting ordered dictionary.')]
        [switch]$SortKeys
    )

    begin
    {
        Write-Verbose -Message "Starting [$($MyInvocation.MyCommand)]"
    }

    process
    {
        Write-Verbose -Message "Input object type: $($InputObject.GetType().FullName)"
        $dictionary = [ordered]@{}

        if ($InputObject -is [System.Collections.Hashtable])
        {
            Write-Verbose -Message 'Input object is a HashTable'
            $keys = $InputObject.Keys
            if ($SortKeys) { $keys = $keys | Sort-Object }
            foreach ($key in $keys)
            {
                $dictionary[$key] = $InputObject[$key]
            }
        }
        elseif ($InputObject -is [System.Array])
        {
            Write-Verbose -Message 'Input object is an Array'
            for ($i = 0; $i -lt $InputObject.Count; $i++)
            {
                $dictionary[$i] = $InputObject[$i]
            }
        }
        elseif ($InputObject -is [System.Collections.Specialized.OrderedDictionary])
        {
            Write-Verbose -Message 'Input object is an OrderedDictionary'
            $keys = $InputObject.Keys
            if ($SortKeys) { $keys = $keys | Sort-Object }
            foreach ($key in $keys)
            {
                $dictionary[$key] = $InputObject[$key]
            }
        }
        else
        {
            $Message = 'Enter a hash table, an array, or an ordered dictionary.'
            Write-Error -Message $Message -Category InvalidData -ErrorAction Stop
        }

        Write-Output $dictionary
    }

    end
    {
        Write-Verbose -Message "Ending [$($MyInvocation.MyCommand)]"
    }
}
