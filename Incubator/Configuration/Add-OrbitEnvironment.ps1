# Module:   Orbit
# Function: Configuration
# Author:   David Eberhardt
# Updated:  11-MAR 2024
# Status:   Alpha




function Add-OrbitEnvironment {
  <#
  .SYNOPSIS
    Adds an Environment to connect to with Enter Orbit
  .DESCRIPTION
    Stores relevant connection values, like TenantId and ApplicationId in a local file to easier use when establishing Orbit.
  .PARAMETER Environment
    Name of the Orbit Environment to store. This value is used in Enter-Orbit to look up TenantId & ApplicationId
  .PARAMETER TenantId
    Guid of the Tenant to connect to. Query in Azure Admin Center
  .PARAMETER ApplicationId
    Guid of the Application to connect to. Query in Azure Admin Center which shows this as 'ClientId'
    The default ApplicationId '14d82eec-204b-4c2f-b7e8-296a70dab67e' for the PowerShell application can be used, but if
    a separate Application is created and authorised for Graph queries with delegated or application permissions,
    use this ClientId
  .PARAMETER Force
    Optional. Overwrites an existing Environment configuration with the current values
	.EXAMPLE
		Add-OrbitEnvironment -Environment "Tenant" -TenantId fa321c32-d9f7-47d2-be83-4cbc19be3990 -ApplicationId 9d55a1f8-cf88-4109-a199-913fe5040ecd

    Saves TenantId and ApplicationId in the Orbit Environment store in AppData\Orbit
  .INPUTS
    System.String
  .OUTPUTS
		System.Void
  .NOTES
    Currently, only Interactive Connections can be stored through this cmdlet, when using AppRegistration, please provide
    a previously created AppRegistration Object to Enter-Orbit directly.
  .COMPONENT
    Configuration
  .FUNCTIONALITY
    Local Settings
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/cmdlet/Add-OrbitEnvironment.md
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/about/about_Orbit.md
  .LINK
    https://github.com/DEberhardt/Orbit/tree/main/docs/
  #>

  [cmdletbinding()]
  param (
    [Parameter(Mandatory)]
    [string]$Environment,

    [Parameter(Mandatory)]
    [guid]$TenantId,

    [Parameter(Mandatory, ParameterSetName = 'Interactive')]
    # [Parameter(Mandatory, ParameterSetName = 'AppregistrationWithSecret')]
    [Alias('ClientId')]
    [guid]$ApplicationId, # = '14d82eec-204b-4c2f-b7e8-296a70dab67e', # Default SDK ClientId for PowerShell?

    <# Not available yet - only Interactive is available right now
    [Parameter(Mandatory, ParameterSetName = 'AppregistrationWithCredential')]
    [psCredential]$Credential,

    [Parameter(Mandatory, ParameterSetName = 'AppregistrationWithCertificate')]
    [string]$CertificateThumbprint,
    #>

    [Parameter()]
    [switch]$Force

  )

  begin {
    # Write-Verbose -Message ('[BEGIN  ] {0}' -f $MyInvocation.MyCommand)

    # Output configuration is written locally into ModuleConfig and saved to disk with Export-Cmdlet
    [ref] $OutConfig = ([ref]$script:ModuleConfig)

    #Add $Environment to $script:ModuleConfig.Environments
    switch ( $PSCmdlet.ParameterSetName ) {
      'Interactive' {
        $EnvironmentObject = [ordered]@{
          Environment = $Environment
          SecretType  = 'Interactive'
          TokenParams = [ordered]@{
            TenantId           = $TenantId
            ClientId           = $ApplicationId
            Interactive        = $true
            AzureCloudInstance = 1
          }
        }
      }
      <#
      'AppregistrationWithSecret' {
        #TBC
        #TODO ClientId is $Credential.Username, ClientSecret = $Credential.Password
        $EnvironmentObject = [ordered]@{
          Environment = $Environment
          SecretType  = 'ClientSecret'
          TokenParams = [ordered]@{
            TenantId           = $TenantId
            ClientId           = $null
            ClientSecret       = $null
            AzureCloudInstance = 1
          }
        }
      }
      'AppregistrationWithCertificate' {
        #TBC
        #TODO ClientId is $Credential.Username, ClientSecret = $Credential.Password
        # ALT: Thumbprint can be read from Credential as well. - this means the methods could be ONE combined input
        # [string]$CertificateThumbprint = $AppRegistration.Credential.GetNetworkCredential().Password

        $CurrentUserPath = 'Cert:\CurrentUser\My\{0}' -f $CertificateThumbprint
        $LocalMachinePath = 'Cert:\LocalMachine\My\{0}' -f $CertificateThumbprint
        if (Test-Path $CurrentUserPath) {
          $CertificateStore = 'CurrentUser'
          # $CertificatePath = $CurrentUserPath
        }
        elseif (Test-Path $LocalMachinePath) {
          $CertificateStore = 'LocalMachine'
          # $CertificatePath = $LocalMachinePath
        }
        else {
          $Message = 'Certificate with provided Thumbprint is not found in LocalMachine or CurrentUser store! Please import Certificate before running this Cmdlet'
          Write-Error -Message $Message -Category ReadError -TargetObject $CertificateThumbprint -ErrorAction Stop
        }
        $EnvironmentObject = [ordered]@{
          Environment      = $Environment
          SecretType       = 'Certificate'
          CertificateStore = $CertificateStore
          TokenParams = [ordered]@{
            TenantId              = $TenantId
            ClientId              = $null
            ClientSecret          = $null
            AzureCloudInstance    = 1
            CertificateThumbprint = $null # this needs to be looked up from Secretstore
          }
        }
      }
      #>
    }

  }

  process {
    # Write-Verbose -Message ('[PROCESS] {0}' -f $MyInvocation.MyCommand)

    if ( $EnvironmentObject ) {
      $AddMember = @{
        Name       = $Environment
        MemberType = 'NoteProperty'
        Value      = $EnvironmentObject
      }
      if ($Force.IsPresent) { $AddMember.Force = $true }
      $OutConfig.Value.Environments | Add-Member @AddMember
    }

  }

  end {
    # This saves the cached configuration to file
    Export-OrbitConfiguration

  }
}