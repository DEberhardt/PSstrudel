# Module:   Orbit
# Function: Configuration
# Author:   David Eberhardt
# Updated:  11-MAR 2024
# Status:   Alpha




function Get-OrbitEnvironment {
  <#
  .SYNOPSIS
    Returns output of the Developer Environment paths
  .DESCRIPTION
    Returns contents of a local DevEnvSettings.json in your PowerShell folder detailing folder paths to use
	.EXAMPLE
		Get-OrbitEnvironment

    Returns all configured Environments from the Orbit Module Configuration
  .INPUTS
    System.System
  .OUTPUTS
		System.Object
  .NOTES
    None
  .COMPONENT
    Session
  .FUNCTIONALITY
    Readies the local Environment for PowerShell Module Management and local testing
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/cmdlet/Get-OrbitEnvironment.md
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/about/about_Orbit.md
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/
  #>

  [CmdletBinding()]
  [OutputType([psObject])]
  param ()


  begin {
    # Write-Verbose -Message ('[BEGIN  ] {0}' -f $MyInvocation.MyCommand)

    if (![IO.Path]::IsPathRooted($Path)) {
      $AppDataDirectory = Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)) 'Orbit'
      $Path = Join-Path $AppDataDirectory 'config.json'
    }

  }

  process {
    Write-Verbose -Message ('[PROCESS] {0}' -f $MyInvocation.MyCommand)

    if ( Test-Path $Path ) {
      ## Load from File
      $ModuleConfigPersistent = Get-Content $Path -Raw | ConvertFrom-Json

      ## Return Config
      foreach ($Name in $ModuleConfigPersistent.Environments.PsObject.Properties.Name) { $ModuleConfig.Environments.$Name | Format-List }
    }

  }

  end {

  }
}