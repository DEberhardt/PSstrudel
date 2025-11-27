# Function taken from PSscriptTools added true condition for if ( $TypeName -eq 'PSObject' )
# The ordering was not successful as Get-Member did not display them in the right order

# This turned out to not be an issue once the following setting id disabled in VScode
# "terminal.integrated.shellIntegration.enabled": false

Function ConvertTo-Hashtable
{
    <#
    .SYNOPSIS
        Converts PsObject to a Hashtable
    .DESCRIPTION
        Converts PsObject to a Hashtable
    .PARAMETER InputObject
        Object to transform
    .PARAMETER NoEmpty
        Signals to skip empty parameters. If not provided will convert key/value pairs where the value is NULL
    .PARAMETER Exclude
        Exclude certain parameters if found in the Input Object
    .PARAMETER Alphabetical
        Will create an ordered Hashtable and sort it alphabetically
    .PARAMETER Ordered
        Will create an ordered Hashtable, but will not sort it.
    .PARAMETER Recurse
        Recursively convert nested objects to hashtables
    .EXAMPLE
        $object | ConvertTo-Hashtable -Ordered -Alphabetical
    #>

    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    [OutputType([System.Collections.Hashtable])]

    Param(
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, HelpMessage = 'Please specify an object' )]
        [ValidateNotNullOrEmpty()]
        [object]$InputObject,

        [Parameter()]
        [switch]$NoEmpty,

        [Parameter()]
        [string[]]$Exclude,

        [Parameter()]
        [switch]$Alphabetical,

        [Parameter(HelpMessage = 'Create an ordered hashtable instead of a plain hashtable.')]
        [switch]$Ordered,

        [Parameter(HelpMessage = 'Recursively convert nested objects to hashtables.')]
        [switch]$Recurse
    )

    process
    {
        <#
            get type using the [Type] class because deserialized objects won't have
            a GetType() method which is what I would normally use.
        #>

        $TypeName = $InputObject.PSObject.TypeNames[0]
        Write-Verbose "Converting an object of type $TypeName"

        #get property names using Get-Member
        $names = $InputObject.psObject.properties.Name

        if ($Alphabetical)
        {
            Write-Verbose 'Sort property names alphabetically'
            $names = $names | Sort-Object
        }

        #define an empty hash table
        if ($Ordered)
        {
            Write-Verbose 'Creating an ordered hashtable'
            $hash = [ordered]@{ }
        }
        else
        {
            $hash = @{ }
        }

        #go through the list of names and add each property and value to the hash table
        foreach ($name in $names)
        {
            # Only add properties that haven't been excluded
            if ($Exclude -notcontains $name)
            {
                # Only add if -NoEmpty is not called and property has a value
                $value = $InputObject.$name
                if ($NoEmpty -and [string]::IsNullOrEmpty($value))
                {
                    Write-Verbose "Property '$name' - Skipping property as it is empty"
                }
                else
                {
                    Write-Verbose "Property '$name' - Adding property"
                    if ($Recurse -and $value -is [PSObject])
                    {
                        $hash[$name] = $value | ConvertTo-Hashtable -NoEmpty:$NoEmpty -Exclude:$Exclude -Alphabetical:$Alphabetical -Ordered:$Ordered -Recurse:$Recurse
                    }
                    else
                    {
                        $hash[$name] = $value
                    }
                }
            }
            else
            {
                Write-Verbose "Excluding $name"
            }
        }

        Write-Verbose 'Writing the result to the pipeline'
        Write-Output $hash
    }

}
