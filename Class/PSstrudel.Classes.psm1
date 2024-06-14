# Module:   PSstrudel
# Function: Classes
# Author:   David Eberhardt
# Updated:  09-JUL 2023
# Status:   Live

# to use, bind them with 'using Module PSstrudel' in individual scripts
# all sub-modules have this file and their own classes file linked in module psm1.

#region Users (Licensing)
# M365 License
class PSstrudelM365LicensePublished {
  [string]$ProductName
  [string]$SkuPartNumber
  [string]$LicenseType
  [string]$ParameterName
  [bool]$IncludesTeams
  [bool]$IncludesPhoneSystem
  [ValidatePattern('^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$')]
  [string]$SkuId
  [object]$ServicePlans

  PSstrudelM365LicensePublished(
    [string]$ProductName,
    [string]$SkuPartNumber,
    [string]$LicenseType,
    [string]$ParameterName,
    [bool]$IncludesTeams,
    [bool]$IncludesPhoneSystem,
    [string]$SkuId,
    [object]$ServicePlans
  ) {
    $this.ProductName = $ProductName
    $this.SkuPartNumber = $SkuPartNumber
    $this.LicenseType = $LicenseType
    $this.ParameterName = $ParameterName
    $this.IncludesTeams = $IncludesTeams
    $this.IncludesPhoneSystem = $IncludesPhoneSystem
    $this.SkuId = $SkuId
    $this.ServicePlans = $ServicePlans
  }
}

# M365 License Service Plan (linked here to have all in one spot)
class PSstrudelM365LicenseServicePlan {
  [string]$ProductName
  [string]$ServicePlanName
  [ValidatePattern('^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$')]
  [string]$ServicePlanId
  [bool]$RelevantForTeams

  PSstrudelM365LicenseServicePlan(
    [string]$ProductName,
    [string]$ServicePlanName,
    [string]$ServicePlanId,
    [bool]$RelevantForTeams
  ) {
    $this.ProductName = $ProductName
    $this.ServicePlanName = $ServicePlanName
    $this.ServicePlanId = $ServicePlanId
    $this.RelevantForTeams = $RelevantForTeams
  }
}
#endregion


#region Tools
# PSstrudelCountry
class PSstrudelCountry {
  [string]$Name
  [string]$TwoLetterCode
  [string]$ThreeLetterCode
  [string]$NumericCode
  [int]$DialCode
  # [GeoRegion]$Region
  [ValidateSet('AMER', 'EMEA', 'APAC')][string]$Region
  [string]$TimeZone

  PSstrudelCountry(
    [string]$Name,
    [string]$TwoLetterCode,
    [string]$ThreeLetterCode,
    [string]$NumericCode,
    [int]$DialCode,
    [string]$Region,
    [string]$TimeZone

  ) {
    $this.Name = $Name
    $this.TwoLetterCode = $TwoLetterCode
    $this.ThreeLetterCode = $ThreeLetterCode
    $this.NumericCode = $NumericCode
    $this.DialCode = $DialCode
    $this.Region = $Region
    $this.TimeZone = $TimeZone
  }
}
#endregion