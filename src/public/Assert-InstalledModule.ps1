# Module:   PSstrudel
# Function: Support
# Author:   David Eberhardt
# Updated:  01-JUL-2020
# Status:   Live




function Assert-InstalledModule {
  <#
  .SYNOPSIS
    Tests whether a Module is loaded
  .DESCRIPTION
    Tests whether a specific Module is loaded
  .PARAMETER Module
    Names of one or more Modules to assert
  .PARAMETER UpToDate
    Verifies Version installed is equal to the latest found online
  .PARAMETER PreRelease
    Verifies Version installed is equal to the latest prerelease version found online
  .EXAMPLE
    Assert-InstalledModule -Module ModuleName

    Will Return $TRUE if the Module 'ModuleName' is installed and loaded
  .EXAMPLE
    Assert-InstalledModule -Module ModuleName -UpToDate

    Will Return $TRUE if the Module 'ModuleName' is installed in the latest release version and loaded
  .EXAMPLE
    Assert-InstalledModule -Module ModuleName -UpToDate -PreRelease

    Will Return $TRUE if the Module 'ModuleName' is installed in the latest pre-release version and loaded
  .INPUTS
    System.String
  .OUTPUTS
    Boolean
  .NOTES
    None
  .COMPONENT
    ModuleManagement
  .FUNCTIONALITY
    Asserts whether the Module is installed, Loaded and optionally also whether it is up-to-date (incl. Prerelease)
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/cmdlet/Assert-InstalledModule.md
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/about/about_ModuleManagement.md
    .LINK
      https://github.com/DEberhardt/PSstrudel/tree/main/docs/about/about_Tools.md
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/
  #>

  [CmdletBinding()]
  [OutputType([Boolean])]
  Param
  (
    [Parameter(Position = 0, HelpMessage = 'Module to test')]
    [string[]]$Module,

    [Parameter(HelpMessage = 'Verifies the latest version is installed')]
    [switch]$UpToDate,

    [Parameter(HelpMessage = 'Verifies the latest prerelease version is installed')]
    [switch]$PreRelease

  )

  begin {
    Show-PSstrudelFunctionStatus -Level Live
    Write-Verbose -Message ("[BEGIN  ] {0}" -f $MyInvocation.MyCommand)

  } #begin

  process {
    Write-Verbose -Message ("[PROCESS] {0}" -f $MyInvocation.MyCommand)
    foreach ($M in $Module) {
      Write-Verbose -Message ("{0} - Verifying Module '{1}' - Checking Installation" -f $MyInvocation.MyCommand, $M )
      $Installed = Get-Module -Name $M -ListAvailable -Verbose:$false -WarningAction SilentlyContinue
      if ( -not $Installed) {
        Write-Verbose -Message ("{0} - Verifying Module '{1}' - Checking Installation - Module not installed" -f $MyInvocation.MyCommand, $M )
        return $false
      }
      else {
        # Determining Current Version
        if ($Installed.count -gt 1) { $Current = $Installed[0] } else { $Current = $Installed }
        Write-Verbose -Message ("{0} - Verifying Module '{1}' - Checking Version installed: {2}" -f $MyInvocation.MyCommand, $M, $Current.Version )
        $CurrentVersion = [Version] ($Current.Version.ToString() -replace '^(\d+(\.\d+){0,3})(\.\d+?)*$' , '$1')
        Write-BetterDebug -Message 'CurrentVersion' -OutputObject $CurrentVersion

        if ($UpToDate) {
          # Checking Current Version is UpToDate
          Write-Verbose -Message ("{0} - Verifying Module '{1}' - Checking Version" -f $MyInvocation.MyCommand, $M )
          $FindModuleParams = @{
            Name        = $M
            Verbose     = $false
            Debug       = $false
            ErrorAction = 'SilentlyContinue'
          }
          if ($PreRelease) { $FindModuleParams.AllowPrerelease = $true }
          $Latest = Find-Module @FindModuleParams
          $LatestVersion = if ($Latest.Version -match '-') { $Latest.Version.Split('-')[0] } else { $Latest.Version }
          $LatestVersion = [Version] ($LatestVersion.ToString() -replace '^(\d+(\.\d+){0,3})(\.\d+?)*$' , '$1')
          Write-BetterDebug -Message 'LatestVersion' -OutputObject $LatestVersion

          if ($CurrentVersion -lt $LatestVersion) {
            # $CurrentVersion is less than $LatestVersion
            Write-Verbose -Message ("{0} - Verifying Module '{1}' - Update available! Latest Version: {2}" -f $MyInvocation.MyCommand, $M, $Latest.Version ) -Verbose
            return $false
          }
        }

        # Checking Imported Version is CurrentVersion
        Write-Verbose -Message ("{0} - Verifying Module '{1}' - Checking Import" -f $MyInvocation.MyCommand, $M )
        $CurrentlyLoaded = Get-Module -Name $M -Verbose:$false -WarningAction SilentlyContinue
        if ($null -ne $CurrentlyLoaded) {
          if ($CurrentlyLoaded.Count -eq 1) {
            $CurrentlyLoadedVersion = [Version] ($CurrentlyLoaded.Version.ToString() -replace '^(\d+(\.\d+){0,3})(\.\d+?)*$' , '$1')
          }
          Write-BetterDebug -Message 'CurrentlyLoadedVersion' -OutputObject $CurrentlyLoadedVersion
          if ($CurrentlyLoadedVersion -ne $CurrentVersion -or $CurrentlyLoaded.IsArray) {
            Write-Verbose -Message ("{0} - Removing Module - Version '{1}'" -f $M, $CurrentlyLoadedVersion )
            Remove-Module -Name $M -Force -Verbose:$false -ErrorAction SilentlyContinue
          }
        }
        $Loaded = Get-Module -Name $M -Verbose:$false -WarningAction SilentlyContinue
        if ($null -ne $Loaded) {
          return $true
        }
        else {
          Write-Verbose -Message ("{0} - Importing Module - Version '{1}'" -f $M, $CurrentVersion )
          $SaveVerbosePreference = $global:VerbosePreference
          $global:VerbosePreference = 'SilentlyContinue'
          Import-Module -Name $M -Global -Force -Verbose:$false -ErrorAction SilentlyContinue
          $global:VerbosePreference = $SaveVerbosePreference
          if (Get-Module -Name $M -WarningAction SilentlyContinue) {
            return $true
          }
          else {
            return $false
          }
        }
      }
    }
  } #process

  end {
    Write-Verbose -Message ("[END    ] {0}" -f $MyInvocation.MyCommand)

  } #end
} # Assert-InstalledModule
