#region Preparation
Write-Output 'Running Pester Tests'

$RootDir = $(Get-Location).path
Write-Output "Current location:      $RootDir"
$ModuleDir = "$RootDir\packages\module"
Write-Verbose "Module build location: $ModuleDir"

Set-Location $ModuleDir
Import-Module "$ModuleDir\src\PSstrudel.psd1"

Write-Verbose -Message 'Loaded Modules' -Verbose
Get-Module | Select-Object Name, Version, ModuleType, ModuleBase | Format-Table -AutoSize

#endregion


#region Pester Testing
$PesterConfig = New-PesterConfiguration
#$Pesterconfig.Run.path = $ModuleDir
$PesterConfig.Run.PassThru = $true
$PesterConfig.Run.Exit = $true
$PesterConfig.Run.Throw = $true
$PesterConfig.TestResult.Enabled = $true
$PesterConfig.Output.CIFormat = 'GithubActions'
#$PesterConfig.CodeCoverage.Enabled = $true

$Script:TestResults = Invoke-Pester -Configuration $PesterConfig
#$CoveragePercent = [math]::floor(100 - (($Script:TestResults.CodeCoverage.NumberOfCommandsMissed / $Script:TestResults.CodeCoverage.NumberOfCommandsAnalyzed) * 100))

#endregion

#region Documentation
Write-Verbose -Message 'Pester Testing - Updating ReadMe' -Verbose
. $PSScriptRoot\Set-ShieldsIoBadge2.ps1

Set-BuildEnvironment -Path $ModuleDir

Write-Output 'Displaying ReadMe for validation'
$ReadMe = Get-Content $RootDir\ReadMe.md
$ReadMe
#endregion


Set-Location $RootDir