# Module:   Orbit
# Function: Configuration
# Author:   Jason Thompson
# Updated:  16-MAR 2024
# Status:   RC




function Set-OrbitConfiguration {
  <#
  .SYNOPSIS
    Applies settings to the Orbit configuration
  .DESCRIPTION
    Orbit stores configuration and environments in a local config.json file for ease of use.
    This cmdlet allows enabling some features.
  .PARAMETER InputObject
    Imported OrbitConfiguration to change
  .PARAMETER EnableNagerAPI
    Enables use of the Nager API for Holiday Lookup.
	.EXAMPLE
		Set-OrbitConfiguration
  .INPUTS
    System.Object
  .OUTPUTS
		System.Void
  .NOTES
    None
  .COMPONENT
    Configuration
  .FUNCTIONALITY
    Readies the Orbit Module with Configuration options
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/cmdlet/Set-OrbitConfiguration.md
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/about/about_Orbit.md
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/
  #>

  [CmdletBinding()]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Not relevant, only saving configuration')]
  param (
    [Parameter(Position = 0, ValueFromPipeline)]
    [psObject] $InputObject,

    [Parameter()]
    [string]$User,

    #region Settings
    [Parameter()]
    [bool] $EnableNagerAPI,
    #endregion

    [Parameter()]
    [ref] $OutConfig = ([ref]$script:ModuleConfig)
  )

  begin {
    # Write-Verbose -Message ('[BEGIN  ] {0}' -f $MyInvocation.MyCommand)

  }

  process {
    Write-Verbose -Message ('[PROCESS] {0}' -f $MyInvocation.MyCommand)

    ## Update local configuration
    if ($InputObject) {
      if ($InputObject -is [hashtable]) { $InputObject = [PSCustomObject]$InputObject }
      foreach ($Property in $InputObject.psObject.Properties) {
        if ($OutConfig.Value.psObject.Properties.Name -contains $Property.Name) {
          $OutConfig.Value.($Property.Name) = $Property.Value
        }
        else {
          Write-Warning ('Ignoring invalid configuration property [{0}].' -f $Property.Name)
        }
      }
    }

    if ($PSBoundParameters.ContainsKey('User')) { $OutConfig.Value.Orbit.User = $User }
    if ($PSBoundParameters.ContainsKey('EnableNagerAPI')) { $OutConfig.Value.Configuration.'Nager.API'.Enabled = $EnableNagerAPI }



  }

  end {
    # This saves the cached configuration to file
    Export-OrbitConfiguration

  }
}