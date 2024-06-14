# Module:   Orbit
# Function: Configuration
# Author:   David Eberhardt
# Updated:  11-MAR 2024
# Status:   Alpha




function Remove-OrbitEnvironment {
  <#
  .SYNOPSIS
    Removes an Environment from the local Orbit configuration store
  .DESCRIPTION
    Removes an Environment and its connection values, like TenantId and ApplicationId from the local configuration store
  .PARAMETER Environment
    Name of the Orbit Environment to store. This value is used in Enter-Orbit to look up TenantId & ApplicationId
	.EXAMPLE
		Remove-OrbitEnvironment -Environment "Tenant"

    Removes the saved environment 'Tenant' from the Orbit Environment store in AppData\Orbit
  .INPUTS
    System.String
  .OUTPUTS
		System.Void
  .NOTES
    None
  .COMPONENT
    Configuration
  .FUNCTIONALITY
    Local Settings
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/cmdlet/Remove-OrbitEnvironment.md
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/about/about_Orbit.md
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/
  #>

  [cmdletbinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript( {
        if ($_ -in $(Get-AcSbOrbitEnvironment @args) ) { $True } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Environment not found. Please check Environment name or set up Environment with Add-OrbitEnvironment.'
        } })]
    # [ArgumentCompleter({ Get-AcSbOrbitEnvironment @args })]
    [string]$Environment
  )

  begin {
    # Write-Verbose -Message ('[BEGIN  ] {0}' -f $MyInvocation.MyCommand)

    # Output configuration is written locally into ModuleConfig and saved to disk with Export-Cmdlet
    [ref] $OutConfig = ([ref]$script:ModuleConfig)

  }

  process {
    # Write-Verbose -Message ('[PROCESS] {0}' -f $MyInvocation.MyCommand)

    $OutConfig.Value.Environments = $OutConfig.Value.Environments | Select-Object * -ExcludeProperty $Environment

  }

  end {
    # This saves the cached configuration to file
    Export-OrbitConfiguration

  }
}