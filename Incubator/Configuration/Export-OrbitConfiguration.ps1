# Module:   Orbit
# Function: Configuration
# Author:   Jason Thompson
# Updated:  16-MAR 2024
# Status:   RC




function Export-OrbitConfiguration {
  <#
	.SYNOPSIS
		Writes the local configuration file for existing Customer configuration.
	.DESCRIPTION
		TBC
  .PARAMETER  InputObject
    Optional. ModuleCondig is loaded by default
  .PARAMETER IgnoreProperty
    Property Names to Ignore
  .PARAMETER IgnoreDefaultValues
    Ignore Default Configuration Values
  .PARAMETER Path
    Configuration File Path
	.EXAMPLE
		Export-OrbitConfiguration
  .INPUTS
    System.System
  .OUTPUTS
		Orbit.ConnectionContext
  .NOTES
    None
  .COMPONENT
    Session
  .FUNCTIONALITY
    Exports local Configuration
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/cmdlet/Export-OrbitConfiguration.md
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/about/about_TeamsSession.md
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/
	#>

  [CmdletBinding()]
  param (
    # Configuration Object
    [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline)]
    [psObject] $InputObject = $script:ModuleConfig,

    [Parameter(Mandatory = $false)]
    [string[]] $IgnoreProperty,

    [Parameter(Mandatory = $false)]
    [psObject] $IgnoreDefaultValues = $script:ModuleConfigDefault,

    [Parameter(Mandatory = $false)]
    [string] $Path = 'config.json'
  )

  begin {
    Write-Verbose -Message ('[BEGIN  ] {0}' -f $MyInvocation.MyCommand)

    if (![IO.Path]::IsPathRooted($Path)) {
      $AppDataDirectory = Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)) 'Orbit'
      $Path = Join-Path $AppDataDirectory $Path
    }

    ## Read configuration file
    $ModuleConfigPersistent = $null
    if (Test-Path $Path) {
      ## Load from File
      $ModuleConfigPersistent = Get-Content $Path -Raw | ConvertFrom-Json
    }
    if (!$ModuleConfigPersistent) { $ModuleConfigPersistent = [PSCustomObject]@{} }

    Write-BetterDebug -Message 'OrbitConfigPersistent (imported)' -OutputObject $ModuleConfigPersistent

  }

  process {
    Write-Verbose -Message ('[PROCESS] {0}' -f $MyInvocation.MyCommand)

    ## Update persistent configuration
    foreach ($Property in $InputObject.psObject.Properties) {
      if ($Property.Name -in (Get-ObjectPropertyValue $ModuleConfigPersistent.psObject.Properties 'Name')) {
        ## Update previously persistent property value
        $Message = "OrbitConfiguration - Update property '{0}'" -f $Property.Name
        Write-Verbose -Message $Message
        $ModuleConfigPersistent.($Property.Name) = $Property.Value
      }
      elseif ($IgnoreProperty -notcontains $Property.Name -and $Property.Value -ne (Get-ObjectPropertyValue $IgnoreDefaultValues $Property.Name)) {
        ## Add property with non-default value
        $Message = "OrbitConfiguration - Add property '{0}' with non-default value." -f $Property.Name
        Write-Verbose -Message $Message
        $ModuleConfigPersistent | Add-Member -Name $Property.Name -MemberType NoteProperty -Value $Property.Value
      }
    }

    ## Export persistent configuration to file
    Write-BetterDebug -Message 'OrbitConfigPersistent (exported)' -OutputObject $ModuleConfigPersistent
    Assert-DirectoryExists $AppDataDirectory
    ConvertTo-Json $ModuleConfigPersistent -Depth 5 | Set-Content $Path
  }

  end {
    # Write-Verbose -Message ("[END    ] {0}" -f $MyInvocation.MyCommand)

  }
}