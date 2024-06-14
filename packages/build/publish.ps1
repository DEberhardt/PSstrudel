# PUBLISH
#region Preparation
Write-Output 'Creating Release'

$RootDir = Get-Location
Write-Output 'Current location:      {0}' -f $RootDir.Path
$ModuleDir = Join-Path -Path $RootDir -ChildPath packages\module
Write-Verbose ('Module build location: {0}' -f $ModuleDir)

# Importing Package.JSON for processing & reading version from file
Write-Verbose -Message 'Publish: Reading Package.json' -Verbose
$PackageJson = Get-Content $RootDir\package.json -Raw | ConvertFrom-Json
Write-Verbose -Message ("Publish: Current Module Version from Package.json:         '{0}'" -f $PackageJson.version) -Verbose
Write-Verbose -Message ("Publish: Reading Module Version from Environment Variable: '{0}'" -f $env:ModuleVersion) -Verbose
$ModuleVersion = if ( $env:ModuleVersion ) { $env:ModuleVersion } else { $PackageJson.version }
$PackageJson | Format-List
Write-Output ("New Version is '{0}'" -f $ModuleVersion)


# Using Microsoft.PowerShell.PsResourceGet - Setting PowerShell Repository to Trusted - just in case
Set-PSResourceRepository -Name 'PsGallery' -Trusted
#endregion


#region Pulbishing Module
Set-Location $ModuleDir\src
$ManifestPath = Join-Path -Path $ModuleDir -ChildPath src -AdditionalChildPath PSstrudel.psd1

# Fetching current Version from Module
$ManifestTest = Test-ModuleManifest -Path $ManifestPath

# Handling prereleases
$PrivateData = Get-Metadata -Path $ManifestPath -PropertyName PrivateData
if ( $PackageJson.isPreRelease -eq 'true' ) {
  $preReleaseTag = $PackageJson.preReleaseTag

  $PrivateData = Get-Metadata -Path $ManifestPath -PropertyName PrivateData
  $PrivateData.PsData.Prerelease = $preReleaseTag # Adding or setting Prerelease tag
  Update-Metadata -Path $ManifestPath -PropertyName PrivateData -Value $PrivateData

  $ManifestTest = Test-ModuleManifest -Path $ManifestPath
}
else {
  if ( $PrivateData.PsData.ContainsKey('PreRelease') ) {
    [void]$PrivateData.PsData.Remove('PreRelease')
    Update-Metadata -Path $ManifestPath -PropertyName PrivateData -Value $PrivateData
    $ManifestTest = Test-ModuleManifest -Path $ManifestPath
  }
  else {
    Write-Output 'No Pre-Release key found in Manifest: OK'
  }
}

# Updating Metadata from Package.json - for Definition see above
# Updating Copyright
$CurrentYear = (Get-Date).Year
$Copyright = $PackageJson.Copyright -replace '2020-CurrentYear', ('2020-{0}' -f $CurrentYear)
Update-Metadata -Path $ManifestPath -PropertyName Copyright -Value $Copyright
Write-Verbose -Message ("Module PSstrudel: Copyright changed to '{0}'" -f $Copyright) -Verbose

# Updating Version
Update-Metadata -Path $ManifestPath -PropertyName ModuleVersion -Value $ModuleVersion
Write-Verbose -Message ("Module PSstrudel:  Version changed to '{0}'" -f $ModuleVersion) -Verbose

# Last proper test of the manifest before publishing.
$ManifestTest = Test-ModuleManifest -Path $ManifestPath

# Resetting RequiredModules to allow processing via Build script

$RequiredModulesValue = [System.Collections.Generic.List[object]]::new()
$Dependencies = $PackageJson.Dependencies.psObject.Members | Where-Object MemberType -EQ 'Noteproperty'
$Dependencies | ForEach-Object {
  $Module = $_.Name
  $Version = $_.Value -replace '\^', ''
  Write-Verbose -Message ("Publish: From Package.JSON, adding Dependency of Module '{0}' with '{1}'" -f $Module, $Version) -Verbose
  $RequiredModulesValue.Add( @{ModuleName = $Module; ModuleVersion = $Version } )
}
Update-Metadata -Path $ManifestPath -PropertyName RequiredModules -Value $RequiredModulesValue

# Output ManifestTest
$ManifestTest = Test-ModuleManifest -Path $ManifestPath
$ManifestTest | Format-List

# Publish-PSResource @PM -WhatIf
$PM = @{
  Path        = $ManifestPath
  ApiKey      = $env:NuGetApiKey
  Repository  = 'PsGallery'
  ErrorAction = 'Stop'
}
Publish-PSResource @PM
Write-Verbose -Message ('Module PSstrudel:  Version {0} published to the PowerShell Gallery.' -f $ModuleVersion) -Verbose

#endregion


Set-Location $RootDir