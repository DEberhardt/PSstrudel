# Module:   PSstrudel
# Function: ModuleManagement
# Author:   Barbara Forbes, David Eberhardt
# Updated:  17-SEP 2022
# Status:   Live




function Limit-InstalledModule {
  <#
    .SYNOPSIS
      Removes older versions of installed modules.
    .DESCRIPTION
      Removes older versions of the discovered modules keeping them tidy and making space on your disk.
    .PARAMETER Name
      List of modules to limit version to
    .PARAMETER Exclude
      List of modules to exclude from limiting.
    .PARAMETER Repository
      String. If not provided, targets the PowerShell gallery (PsGallery)
      EXPERIMENTAL. Untested behaviour may occur for custom repositories
      Please use "Get-InstalledModule | Where Repository -eq 'MyRepo' | Update-Module" as an alternative
    .PARAMETER SkipDependencyCheck
      Switch. Allows removal of Modules that have dependencies. This is useful for Modules like Microsoft.Graph and Az
      As the most recent version is retained, this should not cause issues.
    .PARAMETER Force
      Switch. Allows removal of Modules that were excluded because they are known to cause instabilities.
      This does not impact any Module specified with Exclude. Please see notes below. Handle with Care!
    .EXAMPLE
      Limit-InstalledModule

      Uninstalls all versions except the most recent version for ALL Modules found in Repository PsGallery
      This may not work for Modules in the AllUsers Scope if the Cmdlet is not run with Administrative rights.
    .EXAMPLE
      Limit-InstalledModule [-Name] ImportExcel,BuildHelpers

      Uninstalls all versions except the most recent version for Modules ImportExcel and BuildHelpers
    .EXAMPLE
      Limit-InstalledModule -Exclude MySpecialModule -Repository MyRepo

      Uninstalls all versions except the most recent version of all Modules found installed from the Repository 'MyRepo',
      except MySpecialModule and the modules known to cause instabilities. Please see notes below. Limitations may apply
    .EXAMPLE
      Limit-InstalledModule -Exclude MicrosoftTeams -Force

      Uninstalls all versions except the most recent version of all Modules found in PsGallery, except MicrosoftTeams
      This will also target Modules known to cause instabilities. Please see notes below. Handle with Care!
    .INPUTS
      System.String
    .OUTPUTS
      System.Void
    .NOTES
      Inspired by Barbara Forbes (@ba4bes,https://4bes.nl) 'Update-EveryModule', just separated out into two scripts.
      This is splitting Update-EveryModule into
      Limit-InstalledModule:  Removing old versions except the latest
      Update-InstalledModule: Updating modules with options

      Sensitive Modules or ones known to cause instabilities have been excluded by default: Az, PsReadline, PowerShellGet
      Override with Force to also target these protected modules (This does not impact the use of the Exclude parameter).

      Repositories other than PsGallery could not be tested.
    .COMPONENT
      ModuleManagement
    .FUNCTIONALITY
      Removes old Module Versions retaining the most recent one installed
    .LINK
      https://github.com/DEberhardt/PSstrudel/tree/main/docs/cmdlet/Limit-InstalledModule.md
    .LINK
      https://github.com/DEberhardt/PSstrudel/tree/main/docs/cmdlet/Update-InstalledModule.md
    .LINK
      https://github.com/DEberhardt/PSstrudel/tree/main/docs/about/about_ModuleManagement.md
    .LINK
      https://github.com/DEberhardt/PSstrudel/tree/main/docs/about/about_Tools.md
    .LINK
      https://github.com/DEberhardt/PSstrudel/tree/main/docs/
  #>

  [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  [Alias('lim')]
  [OutputType([System.Void])]
  param (
    [Parameter(HelpMessage = 'Modules will be updated')]
    $Name = [System.Collections.Generic.List[object]]::new(),

    [Parameter(HelpMessage = 'Excluded Modules will not be removed')]
    $Exclude = [System.Collections.Generic.List[object]]::new(),

    [Parameter()]
    [String]$Repository = 'PsGallery',

    [Parameter(HelpMessage = 'Overrides protection Modules with Dependencies')]
    [switch]$SkipDependencyCheck,

    [Parameter(HelpMessage = 'Overrides protection for Modules known to cause instabilities')]
    [switch]$Force
  )

  begin {
    Show-PSstrudelFunctionStatus -Level Live
    Write-Verbose -Message ("[BEGIN  ] {0}" -f $MyInvocation.MyCommand)

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
        $Message = "Module '{0}' could not be loaded properly, please investigate" -f $PSResourceGetModuleName
        Write-Error -Message $Message -Category $_.CategoryInfo.Category -TargetObject $PSResourceGetModuleName
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
    # Preparing Query
    $GetPSResource = @{      ErrorAction = 'Stop' }
    if ( $PSBoundParameters['Name'] ) {
      Write-Verbose -Message ("Querying Modules with Name(s): {0}" -f ($Name -join ', '))
      $GetPSResource.Name = @($Name)
    }
    else {
      Write-Verbose -Message 'Querying all Modules'
    }

    # Querying installed Modules
    $CurrentModules = Get-PSResource @GetPSResource | Where-Object Repository -EQ $Repository | Sort-Object Version -Descending

    # Preparing Objects
    # $ModulesExcluded = [System.Collections.Generic.List[object]]::new()
    $ModulesToProcess = [System.Collections.Generic.List[object]]::new()

    # Filter Protected Modules
    $ProtectedModules = [System.Collections.Generic.List[object]]::new()
    'Az', 'PSReadLine', 'PowerShellGet', 'Microsoft.PowerShell.PSResourceGet' | ForEach-Object { $ProtectedModules.Add($_) }
    if ( -not $Force ) {
      # Adding Protected Modules to Exclusion scope if not already added
      #$ProtectedModules | ForEach-Object { if ( !($_ -in $Exclude) ) { $Exclude.Add($_) } }
    }

    # Processing Excludes
    Write-BetterDebug -Message 'Exclude' -OutputObject $Exclude
    $Currentmodules | ForEach-Object {
      # Filtering first the ProtectedModules, then Excluded ones (adding both to ModulesExcluded) and adding all others to ModulesToProcess
      if ( -not $Force -and ($_.Name.StartsWith('Az.') -or $_.Name -match "^($($ProtectedModules -join '|'))$" ) ) {
        Write-Verbose -Message ("Module '{0}' excluded from processing (Protected Module); Override with -Force" -f $_.Name)
        # $ModulesExcluded.Add($_)
      }
      elseif ( $_.Name -match "^($($Exclude -join '|'))$" ) {
        Write-Verbose -Message ("Module '{0}' excluded from processing (manually excluded)" -f $_.Name)
        # $ModulesExcluded.Add($_)
      }
      else {
        Write-Verbose -Message ("Module '{0}' considered for processing" -f $_.Name)
        $ModulesToProcess.Add($_)
      }
    }

    # Providing Feedback
    if ( -not $Force ) {
      Write-Warning -Message ('The Modules {0} are excluded as they are protected against accidental deletion - To override please use -Force' -f ($ProtectedModules -join ', '))
    }
    if ( $PSBoundParameters['Exclude'] ) {
      Write-Information ('INFO:    Modules {0} are excluded from processing (provided through Exclude parameter)' -f ($Exclude -join ', '))
    }
    # #BODGE This works, but creates a warning for each module (flood)!
    # $ModulesExcluded | Select-Object Name -Unique | ForEach-Object {
    # It requires the manual inclusion of $_.StartsWith('Az.') as the match for 'Az.*' wouldn't work (includes AzureAdPreview)
    # if ( $_.Name.StartsWith('Az.') -or $_.Name -match "^($($ProtectedModules -join '|'))$" ) {
    #   Write-Warning -Message ("Module '{0}' excluded as it is a protected Module - To override please use -Force" -f $_.Name)
    # }
    # else {
    #   Write-Information ("INFO:    Module '{0}' excluded from processing (provided through Exclude parameter)" -f $_.Name)
    # }
    # }


    # exiting if no scope detected
    if ( -not $ModulesToProcess ) {
      Write-Information 'INFO:    No Modules scoped for removal, exiting'
      break
    }
    #endregion

    #region Confirm scope
    $Count = ($ModulesToProcess | Select-Object Name -Unique).Count
    Write-Verbose -Message ("Modules found to process: {0} with {1} Versions" -f $Count, $ModulesToProcess.Count)
    if ( ($Exclude.Count -gt $ProtectedModules.Count + 1) -or $Count -gt 3 ) {
      $go = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Continue'
      $goWithConfirm = New-Object System.Management.Automation.Host.ChoiceDescription '&Confirm', 'Continue with Confirm'
      $abort = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Abort'
      $options = [System.Management.Automation.Host.ChoiceDescription[]]($go, $goWithConfirm, $abort)
      $title = 'Multiple Modules discovered!'
      $message = ("Detected {0} Modules to process, excluding: {1} | Proceed?" -f $Count, ($Exclude -join ', ' ))
      $result = $host.ui.PromptForChoice($title, $message, $options, 0)
      switch ($result) {
        0 { $ConfirmRequired = $false }
        1 { $ConfirmRequired = $true }
        2 { break }
      }
    }
    #endregion
  }

  process {
    Write-Verbose -Message ("[PROCESS] {0}" -f $MyInvocation.MyCommand)
    $ModulesToProcess | Sort-Object Name | ForEach-Object {
      $LastVersion = ($ModulesToProcess | Where-Object Name -EQ $_.Name | Select-Object -First 1).Version
      if ( $_.Version -eq $LastVersion ) {
        Write-Verbose -Message ("{0} - Version {1} is most recent version and will be retained" -f $_.Name, $_.Version)
      }
      else {
        # Module version is not the most recent version installed and is eligible for removal
        Write-Verbose -Message ("{0} - Version {1} - Module is superseded by Version '{2}' and will be uninstalled" -f $_.Name, $_.Version, $LastVersion)
        Write-BetterDebug -Message 'Module Version to Remove' -OutputObject $_
        #region Preparing Splatting parameters
        $PSResource = @{
          Name                = $_.Name
          ErrorAction         = 'Stop'
          Version             = $_.Version
          SkipDependencyCheck = $SkipDependencyCheck #Required for individual Modules of MicrosoftGraph, Az, etc.
        }
        switch ( $PSBoundParameters ) {
          'Credential' { $PSResource.Credential = $Credential }
          'WhatIf' { $PSResource.WhatIf = $true }
        }

        if ( $ConfirmRequired -or $PSBoundParameters['Confirm'] ) { $PSResource.Confirm = $True }
        if ( $PSBoundParameters['AllowPreRelease'] ) { $PSResource.Prerelease = $true }
        #endregion

        # Execute
        try {
          Write-Verbose -Message ('{0} - Unloading Module' -f $PSResource.Name)
          $PSResource.Name | Remove-Module -Force -ErrorAction Ignore -Verbose:$False
          Write-Verbose -Message ("{0} - Uninstalling Version {1}" -f $PSResource.Name, $PSResource.Version)
          Write-BetterDebug -Message 'Parameters (Uninstall-PSResource)' -OutputObject $PSResource
          if ( $Force -or $PSCmdlet.ShouldProcess(('Module {0}, Version {1}' -f $PSResource.Name, $PSResource.Version), 'Uninstall-PSResource') ) {
            Uninstall-PSResource @PSResource
          }
        }
        catch {
          if ( $_.Exception.Message.Contains('Administrator rights are required to uninstall from that folder') ) {
            Write-Warning -Message ("{0} - Uninstalling module version {1} failed: Cannot uninstall Module from the 'AllUsers' Scope. Please run this script as Administrator to do so" -f $PSResource.Name, $PSResource.Version)
          }
          else {
            $Message = '{0} - Uninstalling module version {1} failed: {2}' -f $PSResource.Name, $PSResource.Version, $_.Exception.Message
            Write-Error -Message $Message -Category $_.CategoryInfo.Category -TargetObject $UPN
          }
        }
      }
    }
  } #process

  end {
    Write-Verbose -Message ("[END    ] {0}" -f $MyInvocation.MyCommand)

  } #end
} # Limit-InstalledModule
