# Module:   PSstrudel
# Function: Enums
# Author:   David Eberhardt
# Updated:  10-JUL 2023
# Status:   Live




# GeoRegion
Add-Type -TypeDefinition @'
  public enum GeoRegion {
    AMER,
    EMEA,
    APAC,
  }
'@
