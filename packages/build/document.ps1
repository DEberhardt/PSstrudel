# DOCUMENT

#region Preparation
Write-Output 'Updating Documentation & ReadMe'

$RootDir = Get-Location
Write-Output 'Current location:      {0}' -f $RootDir.Path
$ModuleDir = Join-Path -Path $RootDir -ChildPath packages\module
Write-Verbose ('Module build location: {0}' -f $ModuleDir)

Set-Location $ModuleDir
$ManifestPath = Join-Path -Path $ModuleDir -ChildPath src -AdditionalChildPath PSstrudel.psd1
Import-Module $ManifestPath
#endregion


#region Markdown files
Write-Verbose -Message 'Creating MarkDownHelp with PlatyPs' -Verbose
Import-Module PlatyPs

$DocsFolder = Join-Path -Path $RootDir -ChildPath docs
$CmdletFolder = Join-Path -Path $DocsFolder -ChildPath cmdlet

New-MarkdownHelp -Module PSstrudel -OutputFolder $CmdletFolder -AlphabeticParamsOrder:$false -ErrorAction SilentlyContinue
Update-MarkdownHelp -Path $CmdletFolder -Force -UpdateInputOutput -AlphabeticParamsOrder:$false
New-ExternalHelp -Path $CmdletFolder -OutputPath $DocsFolder -Force

$HelpFiles = Get-ChildItem -Path $DocsFolder -Recurse
Write-Output ('Helpfiles total: {0}' -f $HelpFiles.Count)
#endregion


#region Version
# Updating version for Release Workflow
Write-Verbose -Message 'Updateing Package.json' -Verbose
# Fetching current Version from Root Module
$ManifestTest = Test-ModuleManifest -Path $ManifestPath

# Workflow Changelog and Release Drafter are using Package.json file to read new version
$PackageJSON = Get-Content $RootDir\package.json -Raw | ConvertFrom-Json
$PackageJSON.Version = $ManifestTest.Version.ToString()
Write-Output ('Packgage.JSON updated to {0}' -f $PackageJSON.Version)
$PackageJSON | ConvertTo-Json | Set-Content $RootDir\package.json
$PackageJSON
#endregion


Set-Location $RootDir