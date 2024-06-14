# BUILD

#region Preparation
Import-Module -Name MSAL.PS -Force -WarningAction SilentlyContinue

# Build step
Write-Output 'Building module'

$RootDir = Get-Location
Write-Output 'Current location:      {0}' -f $RootDir.Path
$ModuleDir = Join-Path -Path $RootDir -ChildPath packages\module
Write-Verbose ('Module build location: {0}' -f $ModuleDir)

# Importing Package.JSON for processing & reading version from file
$PackageJSON = Get-Content $RootDir\package.json -Raw | ConvertFrom-Json
$ModuleVersion = $PackageJson.version
Write-Verbose -Message ("Publish: Current Module Version from Package.JSON: '{0}'" -f $ModuleVersion) -Verbose

$RequiredTeamsVersion = $PackageJson.Dependencies.MicrosoftTeams -replace '\^', ''
Write-Verbose -Message ("Publish: Reading Required Version of Module MicrosoftTeams from Package.JSON: '{0}'" -f $RequiredTeamsVersion) -Verbose

$PackageJson | Format-List
Write-Output ("Current Version is '{0}'" -f $ModuleVersion)


Write-Verbose -Message 'Creating Directory' -Verbose
# Create Directory
New-Item -Path $ModuleDir -ItemType Directory

# Copy from Server
Write-Verbose -Message 'Copying Module' -Verbose
$Excludes = @('.vscode', '*.git*', 'TODO.md', 'Archive', 'Incubator', 'packages', 'Workbench', 'PSScriptA*', 'Scrap*.*')
Copy-Item -Path * -Destination $ModuleDir -Exclude $Excludes -Recurse -Force
#endregion


#region Build
# Fetching current Version from Root Module
Set-Location $ModuleDir
$ManifestPath = Join-Path -Path $ModuleDir -ChildPath src\PSstrudel.psd1
$ManifestTest = Test-ModuleManifest -Path $ManifestPath

# Setting Build Helpers Build Environment ENV:BH*
Write-Verbose -Message 'General: Setting Up Build Environment' -Verbose
Set-BuildEnvironment -Path $ManifestTest.ModuleBase

# Functions to Export
$Pattern = @('FunctionsToExport', 'AliasesToExport')
$Pattern | ForEach-Object {
  Write-Output 'Old {0}:' -f $_
  Select-String -Path $ManifestPath -Pattern $_

  switch ($_) {
    'FunctionsToExport' { Set-ModuleFunction -Name $ManifestPath }
    'AliasesToExport' { Set-ModuleAlias -Name $ManifestPath }
  }

  Write-Output "New {0}:" -f $_
  Select-String -Path $ManifestPath -Pattern $_

}

# Updating Metadata from Package.JSON - for Definition see above
# Updating Copyright
$CurrentYear = (Get-Date).Year
$Copyright = $PackageJson.Copyright -replace ('2024-CurrentYear', '2024-{0}' -f $CurrentYear)
Update-Metadata -Path $ManifestTest.Path -PropertyName Copyright -Value $Copyright

# Updating Version
Update-Metadata -Path $ManifestTest.Path -PropertyName ModuleVersion -Value $ModuleVersion

Write-Output 'Manifest re-tested incl. Version, Copyright, etc.'
$ManifestTest = Test-ModuleManifest -Path $ManifestPath

#Importing Module
Write-Verbose -Message ('{0} Importing Module' -f $manifestTest.Name) -Verbose
Import-Module $ManifestPath
#endregion


Set-Location $RootDir