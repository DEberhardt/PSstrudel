# Module:   PSstrudel
# Function: ModuleManagement
# Author:   Barbara Forbes, David Eberhardt
# Updated:  17-SEP 2022
# Status:   Live




function Update-InstalledModule {
  <#
    .SYNOPSIS
      Updates and reloads modules from a Repository.
    .DESCRIPTION
      Updates all local modules that originated from a Repository (PowerShellGallery by default)
    .PARAMETER Name
      List of modules to update
    .PARAMETER Exclude
      List of modules to exclude from updating.
    .PARAMETER AllowPrerelease
      Updates to latest Version including PreReleases (if found) for every Module discovered
    .PARAMETER SkipMajorVersion
      Skip major version updates to account for breaking changes.
    .PARAMETER Scope
      String. CurrentUser or AllUsers. Default is CurrentUser.
    .PARAMETER Repository
      String. If not provided, targets the PowerShell gallery (PSGallery)
      EXPERIMENTAL. Untested behaviour may occur for custom repositories (Credential Parameter is not parsed, etc.)
      Please use "Get-PsResource -Name MyModule | Where Repository -eq 'MyRepo' | Update-PsResource" as an alternative
    .PARAMETER Credential
      PsCredential. If provided, attaches the Credential on calls to Find-Module and Update-PsResource respectively.
      EXPERIMENTAL. Functionality is untested (Additional Parameters of *Module-CmdLets are not provided/parsed)
    .EXAMPLE
      Update-InstalledModule

      Updates all Modules to latest version found in Repository PowerShellGallery and installs them in the User Scope
    .EXAMPLE
      Update-InstalledModule [-Name] PSReadLine,PowerShellGet -SkipMajorVersion -Scope AllUsers

      Updates Modules PSReadLine and PowerShellGet to latest version found in Repository PowerShellGallery.
      Using Switch SkipMajorVersion will only update to the latest minor version currently installed of the module
      Scope AllUsers requires Administrative Rights. Script will terminate if not run as Administrator
    .EXAMPLE
      Update-InstalledModule [-Name] PSReadLine -AllowPrerelease

      Updates all Modules to latest version found in Repository PowerShellGallery including PreReleases
      NOTE: If the Name Parameter is not provided this will update ALL Modules to PreReleases found for each!
    .EXAMPLE
      Update-InstalledModule -Exclude Az

      Updates all Modules to latest version found in Repository PowerShellGallery, except Az
    .EXAMPLE
      Update-InstalledModule -Repository MyRepo

      Updates all Modules to latest version found in Repository MyRepo, except Az
    .EXAMPLE
      Update-InstalledModule -Repository MyRepo -Credential $MyPsCredential

      Authenticating against the Repository MyRepo with the provided Credential $MyCredential;
      Updates all Modules to latest version found in Repository MyRepo, except Az
    .INPUTS
      System.String
    .OUTPUTS
      System.Void
    .NOTES
      Inspired by Barbara Forbes (@ba4bes, https://4bes.nl) 'Update-EveryModule', just separated out into two scripts.
      This is splitting Update-EveryModule into
      Update-InstalledModule: Updating modules with options
      Limit-InstalledModule:  Removing old versions except the latest

      The parameters Repository and Credential are added to allow more flexibility with other repositories.
      They are currently EXPERIMENTAL and untested. Handle with Care!

      To avoid having to confirm a Trusted Source, the InstallationPolicy for the Repository can be set to Trusted with:
      Set-PSRepository -Name "PsGallery" -InstallationPolicy Trusted
      Set-PSRepository -Name "MyRepo" -InstallationPolicy Trusted
    .COMPONENT
      ModuleManagement
    .FUNCTIONALITY
      Updates all Modules installed for a given Repository providing some options to control
    .LINK
        https://github.com/DEberhardt/PSstrudel/tree/main/docs/cmdlet/Update-InstalledModule.md
    .LINK
      https://github.com/DEberhardt/PSstrudel/tree/main/docs/cmdlet/Limit-InstalledModule.md
    .LINK
      https://github.com/DEberhardt/PSstrudel/tree/main/docs/about/about_ModuleManagement.md
    .LINK
      https://github.com/DEberhardt/PSstrudel/tree/main/docs/about/about_Tools.md
    .LINK
      https://github.com/DEberhardt/PSstrudel/tree/main/docs/
  #>

  [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
  [Alias('uim')]
  [OutputType([System.Void])]
  param (
    [Parameter(HelpMessage = 'Modules will be updated')]
    $Name = [System.Collections.Generic.List[object]]::new(),

    [Parameter(HelpMessage = 'Excluded Modules will not be updated')]
    $Exclude = [System.Collections.Generic.List[object]]::new(),

    [Parameter()]
    [Alias('Prerelease')]
    [switch]$AllowPrerelease,

    [parameter()]
    [switch]$SkipMajorVersion,

    [Parameter()]
    [ValidateSet('CurrentUser', 'AllUsers')]
    [String]$Scope = 'CurrentUser',

    [Parameter()]
    [String]$Repository = 'PSGallery',

    [Parameter()]
    [System.Management.Automation.PSCredential]$Credential = [System.Management.Automation.PSCredential]::Empty
  )

  begin {
    Show-PSstrudelFunctionStatus -Level Live
    Write-Verbose -Message ('[BEGIN  ] {0}' -f $MyInvocation.MyCommand)

    #region Helper functions
    # Testing for Administrator
    if ( $Scope -eq 'AllUsers' ) {
      function Test-Administrator {
        $user = [Security.Principal.WindowsIdentity]::GetCurrent()
        (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
      }
      # Check for Admin privileges
      If (! (Test-Administrator)) {
        throw "No Administrative privileges. To install in the 'AllUsers' Scope, please run this script as Administrator"
      }
    }
    #endregion

    #region Validating Requirements - Module and Repository
    try {
      $PSResourceGetModuleName = 'Microsoft.PowerShell.PSResourceGet'
      $PSResourceGetModule = Get-Module -ListAvailable -Name $PSResourceGetModuleName
      if ( -not $PSResourceGetModule ) {
        Write-Verbose -Message ("This Cmdlet utilises the Module '{0}'. To continue, please install this module" -f $PSResourceGetModuleName)
        try {
          $PSResourceGetModule = (Find-Module $PSResourceGetModuleName -ErrorAction Stop)[0]
        }
        catch {
          $PSResourceGetModule = (Find-Module $PSResourceGetModuleName -AllowPrerelease -ErrorAction Stop)[0]
        }
        $PSResourceGetModule | Install-Module -Confirm
      }
      $PSResourceGetModule | Import-Module -ErrorAction Stop
    }
    catch {
      if ( -not $_.ErrorRecord -match 'Assembly with same name is already loaded' ) {
        $Message = "'{0}' could not be loaded properly, please investigate" -f $PSResourceGetModuleName
        Write-Error -Message $Message -Category InvalidResult -TargetObject $PSResourceGetModuleName
      }
    }
    if ( $PSResourceGetModule.PrivateData.PSdata.Prerelease ) {
      Write-Warning -Message ("This Cmdlet utilises the Module '{0}' which currently is installed in a Prerelease version. Please report issues to 'https://github.com/PowerShell/PSResourceGet/issues'" -f $PSResourceGetModuleName)
    }
    $PSResourceRepository = Get-PSResourceRepository -Name $Repository
    if ( -not $PSResourceRepository ) {
      if ( $Repository -eq 'PSGallery' ) {
        Register-PSResourceRepository -PSGallery -Trusted
        Set-PSResourceRepository PSGallery -ApiVersion v2
      }
      else {
        $URI = Read-Host -Prompt ("Repository not registered yet. Enter URI of Repository '{0}' to register repository" -f $Repository)
        Register-PSResourceRepository -Name $Repository -Trusted -Uri $URI
      }
    }
    elseif ( -not $PSResourceRepository.trusted ) {
      Write-Warning -Message ('Repository {0} - found but not trusted. To avoid having to confirm installing from this repository every single time, trusting this repository is recommended' -f $Repository)
      Set-PSResourceRepository -Name $Repository -Trusted -Confirm
      Write-Verbose ("PSResourceRepository '{0}' registered, but not trusted. Trusted flag set - OK" -f $Repository)
    }
    else {
      Write-Verbose ("PSResourceRepository '{0}' registered & trusted - OK" -f $Repository)
    }
    #endregion

    #region Defining Scope - Query & Filter
    # Setting Exclusions
    Write-Verbose -Message ('Excluding Modules: {0}' -f $Exclude -join ', ')

    # Preparing Query
    $GetInstalledPSResource = @{ ErrorAction = 'Stop' }
    if ( $PSBoundParameters['Name'] ) {
      Write-Verbose -Message ('Querying Modules with Name(s): {0}' -f $Name -join ', ')
      $GetInstalledPSResource.Name = @($Name)
    }
    else {
      Write-Verbose -Message 'Querying all Modules'
    }

    # Querying installed Modules
    $CurrentModules = Get-PSResource @GetInstalledPSResource | Where-Object Repository -EQ $Repository

    if ( $PSBoundParameters['Exclude'] ) {
      $CurrentModules = $CurrentModules | Where-Object Name -NotMatch "^$($Exclude -join '|')"
    }
    #endregion

    #region Confirm scope
    if ( -not $CurrentModules ) { throw 'No Modules have been queried, please investigate with Get-PSResource or Get-Module' }
    $Count = $(if ($CurrentModules.GetType().BaseType.Name -eq 'Array') { $CurrentModules.Count } else { 1 })
    Write-Verbose -Message ('Modules found to process: {0}' -f $Count)
    if ( $Count -gt 10 ) {
      $go = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Continue'
      $goWithConfirm = New-Object System.Management.Automation.Host.ChoiceDescription '&Confirm', 'Continue with Confirm'
      $abort = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Abort'
      $options = [System.Management.Automation.Host.ChoiceDescription[]]($go, $goWithConfirm, $abort)
      $title = 'Multiple Modules discovered!'
      $message = 'Detected {0} Modules to process, excluding: {1} | Proceed?' -f $Count, $(if ( $Exclude ) { $Exclude -join ', ' } else { 'none' })
      $result = $host.ui.PromptForChoice($title, $message, $options, 0)
      switch ($result) {
        0 { }
        1 { $ConfirmRequired = $true }
        2 { break }
      }
    }
    #endregion


    #region Preparing Splatting parameters
    $FindModuleParams = @{
      ErrorAction = 'Stop'
      Repository  = $Repository
    }
    $PSResource = @{
      ErrorAction   = 'Stop'
      AcceptLicense = $true
      Force         = $true
      Scope         = $Scope
    }
    switch ( $PSBoundParameters ) {
      'Credential' { $FindModuleParams.Credential = $PSResource.Credential = $Credential }
      'WhatIf' { $PSResource.WhatIf = $true }
    }
    if ( $ConfirmRequired -or $PSBoundParameters['Confirm'] ) { $PSResource.Confirm = $True }
    if ( $PSBoundParameters['AllowPreRelease'] ) {
      $FindModuleParams.AllowPreRelease = $true
      $PSResource.Prerelease = $true
    }
    #endregion
  }

  process {
    Write-Verbose -Message ('[PROCESS] {0}' -f $MyInvocation.MyCommand)
    $CurrentModules | ForEach-Object {
      $ModuleName = $_.Name
      [System.Version]$ModuleVersion = ($_.Version.tostring().split('-'))[0]
      #region Finding latest Module Version
      try {
        Write-Verbose ("{0} - Checking Repository '{1}' for latest version" -f $ModuleName, $Repository)
        $OnlineModule = Find-Module -Name $ModuleName @FindModuleParams
        # Finding most recent Minor Version if SkipMajorVersion is used.
        if ( $SkipMajorVersion.IsPresent -and $OnlineModule.Version.ToString().Split('.')[0] -gt $_.Version.ToString().split('.')[0] ) {
          Write-Warning ('{0} - Found new major version! Online: {1}, Local: {2}' -f $ModuleName, $OnlineModule.Version, $_.Version)

          $MaximumVersion = New-Object -TypeName System.Version -ArgumentList (($_.Version.Split('.')[0]), 999, 999)
          Write-Verbose ("{0} - Checking Repository '{1}'for latest minor version ({2})" -f $ModuleName, $Repository, $MaximumVersion) -Verbose
          $OnlineModule = Find-Module -Name $ModuleName @FindModuleParams -MaximumVersion $MaximumVersion
        }
        [System.Version]$OnlineModuleVersion = $OnlineModule.Version.tostring().split('-')[0]
      }
      catch {
        $Message = "Module '{0}' not found in Repository: {1}" -f $ModuleName, $_.Exception.Message
        Write-Error -Message $Message -Category ObjectNotFound -TargetObject $ModuleName
        $OnlineModule = $OnlineModuleVersion = $null
      }
      #endregion

      #region Update
      #BODGE this does not yield more than one result in any case, though sometimes $localmodule is empty for whatever reason and thus the info is empty below.
      $LocalModule = Get-Module -Name $ModuleName -ListAvailable -Verbose:$false | Sort-Object Version -Descending | Select-Object -First 1
      if ( $LocalModule ) {
        $LocalModuleVersion = if ( $LocalModule.Count -gt 1 ) { $LocalModule[0].Version } else { $LocalModule.Version }
      }
      else {
        $LocalModuleVersion = $null
      }

      Write-Verbose -Message ('{0} - Online: {1}, Local: {2}{3}' -f $ModuleName, $OnlineModule.Version, $_.Version, $( if ($LocalModuleVersion) { "| $($LocalModuleVersion)" }) )
      if ( $LocalModuleVersion -eq $OnlineModuleVersion ) {
        Write-Verbose -Message ('{0} - Module is up to date: {1}' -f $ModuleName, $LocalModuleVersion)
      }
      elseif ( $OnlineModuleVersion -gt $ModuleVersion -and $OnlineModuleVersion -gt $LocalModuleVersion ) {
        # Removing Module if Loaded
        $Loaded = Get-Module -Name $ModuleName
        if ( $Loaded ) {
          Write-Verbose -Message ('{0} - Module loaded; Removing Module' -f $ModuleName)
          Remove-Module -Name $ModuleName -Force -Verbose:$false -ErrorAction SilentlyContinue
        }

        #region Updating Module
        $UpdateInstalled = $false
        Write-Information ('INFO:    {0} - Updating Module from {1} to {2}' -f $ModuleName, $LocalModuleVersion, $OnlineModuleVersion)
        try {
          $PSResource.Name = $ModuleName
          Write-BetterDebug -Message 'Parameters (Update-PSResource)' -OutputObject $PSResource
          Write-BetterDebug -Message ('NOTE: Version ({0}) is added later as -Version or -RequiredVersion' -f $OnlineModuleVersion)
          $PSResource.Version = $OnlineModuleVersion
          try {
            Update-PSResource @PSResource
            $UpdateInstalled = $true
          }
          catch {
            # Overcoming halting errors when Module cannot be installed due to a signing issue.
            #NOTE Parameter Force is not available, or we could add both Skip parameters to the command before execution
            [string]$ExceptionMessage = $_.Exception.Message
            if ( $_.Exception.Message -match '-SkipPublisherCheck' ) {
              Write-Warning -Message ('{0} - Re-running with -SkipPublisherCheck' -f ($ExceptionMessage -split 'ensure')[0])
              try {
                Update-PSResource @PSResource -SkipPublisherCheck
                $UpdateInstalled = $true
              }
              catch {
                throw $_
              }
            }
            else {
              throw $_
            }
          }
        }
        catch {
          $Message = "Update of Module '{0}' with Update-PSResource failed: {1}" -f $ModuleName, $_.Exception.Message
          Write-Error -Message $Message -Category $_.CategoryInfo.Category -TargetObject $ModuleName
          continue
        }
        #endregion

        # Importing module if it was loaded before
        if ( $Loaded -and $UpdateInstalled ) {
          Write-Verbose -Message ('{0} - Importing Module' -f $ModuleName)
          try {
            $null = Import-Module -Name $ModuleName -Verbose:$false -ErrorAction Stop
            Write-Verbose -Message ('{0} - Module re-imported' -f $ModuleName)
          }
          catch {
            try {
              $null = Import-Module -Name $ModuleName -Verbose:$false -Force -ErrorAction Stop
              Write-Verbose -Message ('{0} - Module re-imported forcefully' -f $ModuleName)
            }
            catch {
              $Message = '{0} - Importing Module failed, please restart session to importing Module' -f $ModuleName
              Write-Verbose -Message $Message -Verbose
            }
          }
        }
        #endregion
      }
      elseif ($null -ne $OnlineModule) {
        Write-Verbose -Message ('{0} - Module is up to date: {1}' -f $ModuleName, $_.Version)
      }
      #endregion

    }
  } #process

  end {
    Write-Verbose -Message ('[END    ] {0}' -f $MyInvocation.MyCommand)

  } #end
} # Update-InstalledModule