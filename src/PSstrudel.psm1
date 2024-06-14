using module .\Class\PSstrudel.Enums.ps1
using module .\Class\PSstrudel.Classes.psm1
# Above needs to remain the first line to import Classes
using namespace System.Management.Automation
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Linq

# Requirements
#requires -Version 7

<#
  PSstrudel - Module supplementing PowerShell Module Development
  Initially for personal use, but feel free to use/fork this and adapt it to your own needs.

  by David Eberhardt
  PSstrudel-Module@outlook.com
  @MightyOrmus
  www.davideberhardt.at
  https://github.com/DEberhardt
  https://davideberhardt.wordpress.com/

  Any and all technical advice, scripts, and documentation are provided as is with no guarantee.
  Always review any code and steps before applying to a production system to understand their full impact.

.LINK
  https://github.com/DEberhardt/PSstrudel/tree/master/docs

#>

#region Functions
#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($Function in @($Public + $Private)) {
  Try {
    . $Function.Fullname
  }
  Catch {
    Write-Error -Message ('Failed to import function {0}: {1}' -f $Function.Fullname, $_)
  }
}

# Exporting Module Members (Functions)
Export-ModuleMember -Function $Public.Basename
#endregion

#region Aliases
# Query Aliases
$Aliases = $null
#$Aliases = Foreach ($Function in @($Public + $Private)) {
$Aliases = Foreach ($Function in @($Public)) {
  if ( $Function.Fullname -match '.tests.ps1' ) { continue }
  $Content = $AliasBlocks = $null

  $Content = $Function | Get-Content

  $AliasBlocks = $Content -split "`n" | Select-String 'Alias\(' -Context 1, 1
  $AliasBlocks | ForEach-Object {
    $Lines = $_ -split "`n"
    if ( $Lines[0] -match 'CmdletBinding' -or $Lines[0] -match 'OutputType' -or $Lines[2] -match 'CmdletBinding' -or $Lines[2] -match 'OutputType' ) {
      if ( ($_ -split "`n")[1] -match "Alias\('(?<content>.*)'\)" ) {
        ($matches.content -split ',' -replace "'" -replace ' ') | ForEach-Object { if ( $_ -ne '' ) { $_ } }
      }
    }
    else {
      continue
    }
  }
}

# Manual definitions
$ManualAliases = @()

# Exporting Module Members (Aliases)
$AliasesToExport = @($Aliases + $ManualAliases)
Write-Verbose -Message ('Aliases to Export - Count: {0}' -f $Aliases.Count)
Write-Verbose -Message ('Aliases to Export - List: {0}' -f ($Aliases -join ','))
if ( $AliasesToExport ) {
  Export-ModuleMember -Alias $AliasesToExport
}
#endregion

#region Variables
# Defining Help URL Base string:
$script:PSstrudelURLBase = 'https://github.com/DEberhardt/PSstrudel'
$script:PSstrudelURLBaseNewIssue = '{0}/issues/new' -f $script:PSstrudelURLBase
$script:PSstrudelHelpURLBase = '{0}/blob/main/docs/' -f $script:PSstrudelURLBase
#endregion


# ModuleConfig & initial population of config.json

<#
# $DefaultConfig = (Get-ChildItem -Path Assets -Filter config.json -Recurse)[0].FullName
$DefaultConfig = Join-Path -Path $PSScriptRoot -ChildPath 'Assets' -AdditionalChildPath 'Configuration', 'config.json'
$script:ModuleConfigDefault = Import-PSstrudelConfiguration -Path $DefaultConfig
$script:ModuleConfig = $script:ModuleConfigDefault.psObject.Copy()

$ConfigPath = Join-Path -Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)) -ChildPath 'PSstrudel' -AdditionalChildPath 'config.json'

if ( -not (Test-Path $ConfigPath) ) {
  $script:ModuleConfig.PSstrudel.User = ($HOME -split '\\')[-1]
  $script:ModuleConfigDefault | Export-PSstrudelConfiguration -IgnoreDefaultValues $null # Initial Population requires Non-default values to be blank!

  $Message = '{0}Welcome to PSstrudel, {1}. Default PSstrudelConfiguration generated and saved in {2}. To simplify Connections with Enter-PSstrudel please set up Environments with Add-PSstrudelEnvironment' -f $PSstyle.Foreground.Green, $script:ModuleConfig.PSstrudel.User, $ConfigPath
  Write-Information -MessageData $Message -InformationAction Continue
}
else {
  Import-PSstrudelConfiguration | Set-PSstrudelConfiguration
  $Message = 'PSstrudelConfiguration loaded from {0}.' -f $ConfigPath
  Write-Verbose -Message $Message -Verbose
}
#>