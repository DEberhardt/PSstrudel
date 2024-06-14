# Module:   Orbit
# Function: Connection
# Author:   Jason Thompson
# Updated:  04-FEB 2024
# Status:   RC




function Import-OrbitConfiguration {
  <#
	.SYNOPSIS
		Reads the local configuration file for existing Customer configuration.
	.DESCRIPTION
		TBC
	.EXAMPLE
		Import-OrbitConfiguration
  .INPUTS
    System.System
  .OUTPUTS
		Orbit.ConnectionContext
  .NOTES
    None
  .COMPONENT
    Session
  .FUNCTIONALITY
    Imports local Configuration
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/cmdlet/Import-OrbitConfiguration.md
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/about/about_TeamsSession.md
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/
	#>

  [CmdletBinding()]
  [OutputType([psObject])]
  param (
    [Parameter()]
    [string] $Path = 'config.json'
  )

  begin {
    # Write-Verbose -Message ("[BEGIN  ] {0}" -f $MyInvocation.MyCommand)

  }

  process {
    Write-Verbose -Message ('[PROCESS] {0}' -f $MyInvocation.MyCommand)

    if (![IO.Path]::IsPathRooted($Path)) {
      $AppDataDirectory = Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)) 'Orbit'
      $Path = Join-Path $AppDataDirectory $Path
    }

    if ( Test-Path $Path ) {
      ## Load from File
      $ModuleConfigPersistent = Get-Content $Path -Raw | ConvertFrom-Json

      ## Return Config
      return $ModuleConfigPersistent
    }

  }

  end {
    # Write-Verbose -Message ("[END    ] {0}" -f $MyInvocation.MyCommand)

  }
}