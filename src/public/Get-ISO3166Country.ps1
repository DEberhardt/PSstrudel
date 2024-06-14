# Module:   PSstrudel
# Function: Helper
# Author:   David Eberhardt
# Updated:  11-JUL-2022
# Status:   Live




function Get-ISO3166Country {
  <#
  .SYNOPSIS
    ISO 3166 Country table. Period.
  .DESCRIPTION
    Returns the full ISO3166 Country table with Name, -alpha2, -alpha3 & NUM code.
  .PARAMETER TwoLetterCode
    ISO 3166-alpha2 - Two Letter Country Code. Returns exact match if found, nothing if not.
  .PARAMETER ThreeLetterCode
    ISO 3166-alpha3 - Three Letter Country Code. Returns exact match if found, nothing if not.
  .PARAMETER NumericCode
    ISO3166-num - Three digit Numeric Country Code. Returns exact match if found, nothing if not.
  .PARAMETER Region
    GeoRegion AMER, EMEA or APAC. Returns all countries that are matching this region.
  .PARAMETER TimeZone
    TimeZone. Returns all countries that are matching this Time Zone
  .PARAMETER DialCode
    DialCode. Returns the country that is matching this DialCode
  .EXAMPLE
    Get-ISO3166Country

    Returns the full table of Countries including TwoLetterCode (alpha2) & ThreeLetterCode (alpha3) and NumericCode (NUM)
  .EXAMPLE
    Get-ISO3166Country -TwoLetterCode AZ

    Returns entry for Country "Azerbaijan" queried from the TwoLetterCode (ISO3166-Alpha2) AW
  .EXAMPLE
    Get-ISO3166Country -ThreeLetterCode BLZ

    Returns entry for Country "Belize" queried from the ThreeLetterCode (ISO3166-Alpha3) BLZ
  .EXAMPLE
    Get-ISO3166Country -Region APAC

    Returns every entry for Countries in the GeoRegion APAC
  .EXAMPLE
    Get-ISO3166Country -TimeZone UTC-03:00

    Returns every entry for Countries in the Time Zone UTC-03:00
  .EXAMPLE
    Get-ISO3166Country -DialCode 43

    Returns entry for Country "Austria" as it has teh unique dial code of 43
  .EXAMPLE
    Get-ISO3166Country | Where-Object TwoLetterCode -eq "AW"

    Returns entry for Country "Aruba" queried from the TwoLetterCode (ISO3166-Alpha2) AW
  .EXAMPLE
    (Get-ISO3166Country).TwoLetterCode

    Returns the column TwoLetterCode (ISO3166-Alpha2) for all countries
  .INPUTS
    System.Void
  .OUTPUTS
    System.Object
  .NOTES
    This CmdLet is created based on the C# definition of https://github.com/schourode/iso3166
    Manually translated into PowerShell from source file https://raw.githubusercontent.com/schourode/iso3166/master/Country.cs
    Dataset last queried 31 JUL 2021 (based on last update of Github repo 08 JAN 2020)
    ISO3166-alpha2 is used as the Usage Location in Office 365
  .COMPONENT
    SupportingFunction
  .FUNCTIONALITY
    Retruns a List of all ISO3166 Countries
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/cmdlet/Get-ISO3166Country.md
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/about/about_Tools.md
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/
  #>

  [CmdletBinding(DefaultParameterSetName = 'Alpha2')]
  [OutputType([System.Collections.Generic.List[System.Object]])]
  param (
    [Parameter(ParameterSetName = 'Alpha2', HelpMessage = 'ISO 3166-alpha2 - Two Letter Country Code')]
    [AllowNull()]
    [ValidatePattern('^[A-Z][A-Z]$')]
    <#
    [ValidateScript( {
        if ($null -eq $_ -or $_ -match '^[A-Z][A-Z]$' ) { return $true } else {
          throw [System.Management.Automation.ValidationMetadataException] 'Value must be a two-digit Country Code'
        } })]
        #>
    [string]$TwoLetterCode,

    [Parameter(ParameterSetName = 'Alpha3', HelpMessage = 'ISO 3166-alpha3 - Three Letter Country Code')]
    [ValidatePattern('^[A-Z][A-Z][A-Z]$')]
    [string]$ThreeLetterCode,

    [Parameter(ParameterSetName = 'Num', HelpMessage = 'ISO 3166-num - Three digit Numeric Country Code')]
    [ValidatePattern('^[0-9][0-9][0-9]$')]
    [string]$NumericCode,

    [Parameter(ParameterSetName = 'Region', HelpMessage = 'GeoRegion AMER, EMEA or APAC')]
    [GeoRegion]$Region,

    [Parameter(ParameterSetName = 'TimeZone', HelpMessage = 'TimeZone')]
    [ValidatePattern('^UTC[+-](0[0-9]|1[0-4]):(00|15|30|45)$')]
    [string]$TimeZone,

    [Parameter(ParameterSetName = 'DialCode', HelpMessage = 'DialCode')]
    [int]$DialCode
  )

  begin {
    Show-PSstrudelFunctionStatus -Level Live
    Write-Verbose -Message 'Returning ISO 3166 Country List'

    # using class PSstrudelCountry, defined in Module scope
    $ISO3166Countries = [System.Collections.Generic.List[object]]::new()

    #region Adding Countries
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Afghanistan', 'AF', 'AFG', '004', '93', 'EMEA', 'UTC+04:30'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Åland Islands', 'AX', 'ALA', '248', '358', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Albania', 'AL', 'ALB', '008', '355', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Algeria', 'DZ', 'DZA', '012', '213', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('American Samoa', 'AS', 'ASM', '016', '1684', 'APAC', 'UTC-11:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Andorra', 'AD', 'AND', '020', '376', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Angola', 'AO', 'AGO', '024', '244', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Anguilla', 'AI', 'AIA', '660', '1264', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Antarctica', 'AQ', 'ATA', '010', '672', 'APAC', 'UTC+12:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Antigua and Barbuda', 'AG', 'ATG', '028', '1268', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Argentina', 'AR', 'ARG', '032', '54', 'AMER', 'UTC-03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Armenia', 'AM', 'ARM', '051', '374', 'EMEA', 'UTC+04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Aruba', 'AW', 'ABW', '533', '297', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Australia', 'AU', 'AUS', '036', '61', 'APAC', 'UTC+10:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Austria', 'AT', 'AUT', '040', '43', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Azerbaijan', 'AZ', 'AZE', '031', '994', 'EMEA', 'UTC+04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Bahamas', 'BS', 'BHS', '044', '1242', 'AMER', 'UTC-05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Bahrain', 'BH', 'BHR', '048', '973', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Bangladesh', 'BD', 'BGD', '050', '880', 'APAC', 'UTC+06:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Barbados', 'BB', 'BRB', '052', '1246', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Belarus', 'BY', 'BLR', '112', '375', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Belgium', 'BE', 'BEL', '056', '32', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Belize', 'BZ', 'BLZ', '084', '501', 'AMER', 'UTC-06:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Benin', 'BJ', 'BEN', '204', '229', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Bermuda', 'BM', 'BMU', '060', '1441', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Bhutan', 'BT', 'BTN', '064', '975', 'APAC', 'UTC+06:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Bolivia, Plurinational State of', 'BO', 'BOL', '068', '591', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Bonaire, Sint Eustatius and Saba', 'BQ', 'BES', '535', '599', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Bosnia and Herzegovina', 'BA', 'BIH', '070', '387', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Botswana', 'BW', 'BWA', '072', '267', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Bouvet Island', 'BV', 'BVT', '074', '47', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Brazil', 'BR', 'BRA', '076', '55', 'AMER', 'UTC-03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('British Indian Ocean Territory', 'IO', 'IOT', '086', '246', 'APAC', 'UTC+06:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Brunei Darussalam', 'BN', 'BRN', '096', '673', 'APAC', 'UTC+08:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Bulgaria', 'BG', 'BGR', '100', '359', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Burkina Faso', 'BF', 'BFA', '854', '226', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Burundi', 'BI', 'BDI', '108', '257', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Cabo Verde', 'CV', 'CPV', '132', '238', 'EMEA', 'UTC-01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Cambodia', 'KH', 'KHM', '116', '855', 'APAC', 'UTC+07:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Cameroon', 'CM', 'CMR', '120', '237', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Canada', 'CA', 'CAN', '124', '1', 'AMER', 'UTC-07:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Cayman Islands', 'KY', 'CYM', '136', '1345', 'AMER', 'UTC-05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Central African Republic', 'CF', 'CAF', '140', '236', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Chad', 'TD', 'TCD', '148', '235', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Chile', 'CL', 'CHL', '152', '56', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('China', 'CN', 'CHN', '156', '86', 'APAC', 'UTC+08:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Christmas Island', 'CX', 'CXR', '162', '61', 'APAC', 'UTC+07:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Cocos (Keeling) Islands', 'CC', 'CCK', '166', '61', 'APAC', 'UTC+06:30'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Colombia', 'CO', 'COL', '170', '57', 'AMER', 'UTC-05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Comoros', 'KM', 'COM', '174', '269', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Congo, Democratic Republic of the', 'CD', 'COD', '180', '243', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Congo, Republic of the', 'CG', 'COG', '178', '242', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Cook Islands', 'CK', 'COK', '184', '682', 'APAC', 'UTC-10:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Costa Rica', 'CR', 'CRI', '188', '506', 'AMER', 'UTC-06:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new("Côte d'Ivoire", 'CI', 'CIV', '384', '225', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Croatia', 'HR', 'HRV', '191', '385', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Cuba', 'CU', 'CUB', '192', '53', 'AMER', 'UTC-05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Curaçao', 'CW', 'CUW', '531', '599', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Cyprus', 'CY', 'CYP', '196', '357', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Czechia', 'CZ', 'CZE', '203', '420', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Denmark', 'DK', 'DNK', '208', '45', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Djibouti', 'DJ', 'DJI', '262', '253', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Dominica', 'DM', 'DMA', '212', '1767', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Dominican Republic', 'DO', 'DOM', '214', '1809', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Ecuador', 'EC', 'ECU', '218', '593', 'AMER', 'UTC-05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Egypt', 'EG', 'EGY', '818', '20', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('El Salvador', 'SV', 'SLV', '222', '503', 'AMER', 'UTC-06:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Equatorial Guinea', 'GQ', 'GNQ', '226', '240', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Eritrea', 'ER', 'ERI', '232', '291', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Estonia', 'EE', 'EST', '233', '372', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Eswatini', 'SZ', 'SWZ', '748', '268', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Ethiopia', 'ET', 'ETH', '231', '251', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Falkland Islands (Malvinas)', 'FK', 'FLK', '238', '500', 'EMEA', 'UTC-03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Faroe Islands', 'FO', 'FRO', '234', '298', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Fiji', 'FJ', 'FJI', '242', '679', 'APAC', 'UTC+12:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Finland', 'FI', 'FIN', '246', '358', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('France', 'FR', 'FRA', '250', '33', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('French Guiana', 'GF', 'GUF', '254', '594', 'AMER', 'UTC-03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('French Polynesia', 'PF', 'PYF', '258', '689', 'APAC', 'UTC-10:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('French Southern Territories', 'TF', 'ATF', '260', '262', 'APAC', 'UTC+05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Gabon', 'GA', 'GAB', '266', '241', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Gambia', 'GM', 'GMB', '270', '220', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Georgia', 'GE', 'GEO', '268', '995', 'EMEA', 'UTC+04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Germany', 'DE', 'DEU', '276', '49', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Ghana', 'GH', 'GHA', '288', '233', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Gibraltar', 'GI', 'GIB', '292', '350', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Greece', 'GR', 'GRC', '300', '30', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Greenland', 'GL', 'GRL', '304', '299', 'EMEA', 'UTC-03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Grenada', 'GD', 'GRD', '308', '1473', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Guadeloupe', 'GP', 'GLP', '312', '590', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Guam', 'GU', 'GUM', '316', '1671', 'APAC', 'UTC+10:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Guatemala', 'GT', 'GTM', '320', '502', 'AMER', 'UTC-06:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Guernsey', 'GG', 'GGY', '831', '44', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Guinea', 'GN', 'GIN', '324', '224', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Guinea-Bissau', 'GW', 'GNB', '624', '245', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Guyana', 'GY', 'GUY', '328', '592', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Haiti', 'HT', 'HTI', '332', '509', 'AMER', 'UTC-05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Heard Island and McDonald Islands', 'HM', 'HMD', '334', '672', 'APAC', 'UTC+05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Holy See', 'VA', 'VAT', '336', '3906', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Honduras', 'HN', 'HND', '340', '504', 'AMER', 'UTC-06:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Hong Kong', 'HK', 'HKG', '344', '852', 'APAC', 'UTC+08:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Hungary', 'HU', 'HUN', '348', '36', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Iceland', 'IS', 'ISL', '352', '354', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('India', 'IN', 'IND', '356', '91', 'APAC', 'UTC+05:30'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Indonesia', 'ID', 'IDN', '360', '62', 'APAC', 'UTC+08:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Iran, Islamic Republic of', 'IR', 'IRN', '364', '98', 'EMEA', 'UTC+03:30'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Iraq', 'IQ', 'IRQ', '368', '964', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Ireland', 'IE', 'IRL', '372', '353', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Isle of Man', 'IM', 'IMN', '833', '44', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Israel', 'IL', 'ISR', '376', '972', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Italy', 'IT', 'ITA', '380', '39', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Jamaica', 'JM', 'JAM', '388', '1876', 'AMER', 'UTC-05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Japan', 'JP', 'JPN', '392', '81', 'APAC', 'UTC+09:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Jersey', 'JE', 'JEY', '832', '44', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Jordan', 'JO', 'JOR', '400', '962', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Kazakhstan', 'KZ', 'KAZ', '398', '7', 'EMEA', 'UTC+06:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Kenya', 'KE', 'KEN', '404', '254', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Kiribati', 'KI', 'KIR', '296', '686', 'APAC', 'UTC+13:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new("Korea, Democratic People's Republic of", 'KP', 'PRK', '408', '850', 'EMEA', 'UTC+09:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Korea, Republic of', 'KR', 'KOR', '410', '82', 'EMEA', 'UTC+09:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Kosovo', 'XK', 'KVX', '', '383', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Kuwait', 'KW', 'KWT', '414', '965', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Kyrgyzstan', 'KG', 'KGZ', '417', '996', 'APAC', 'UTC+06:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new("Lao People's Democratic Republic", 'LA', 'LAO', '418', '856', 'APAC', 'UTC+07:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Latvia', 'LV', 'LVA', '428', '371', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Lebanon', 'LB', 'LBN', '422', '961', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Lesotho', 'LS', 'LSO', '426', '266', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Liberia', 'LR', 'LBR', '430', '231', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Libya', 'LY', 'LBY', '434', '218', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Liechtenstein', 'LI', 'LIE', '438', '423', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Lithuania', 'LT', 'LTU', '440', '370', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Luxembourg', 'LU', 'LUX', '442', '352', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Macao', 'MO', 'MAC', '446', '853', 'APAC', 'UTC+08:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Madagascar', 'MG', 'MDG', '450', '261', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Malawi', 'MW', 'MWI', '454', '265', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Malaysia', 'MY', 'MYS', '458', '60', 'APAC', 'UTC+08:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Maldives', 'MV', 'MDV', '462', '960', 'APAC', 'UTC+05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Mali', 'ML', 'MLI', '466', '223', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Malta', 'MT', 'MLT', '470', '356', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Marshall Islands', 'MH', 'MHL', '584', '692', 'APAC', 'UTC+12:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Martinique', 'MQ', 'MTQ', '474', '596', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Mauritania', 'MR', 'MRT', '478', '222', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Mauritius', 'MU', 'MUS', '480', '230', 'EMEA', 'UTC+04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Mayotte', 'YT', 'MYT', '175', '262', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Mexico', 'MX', 'MEX', '484', '52', 'AMER', 'UTC-06:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Micronesia, Federated States of', 'FM', 'FSM', '583', '691', 'APAC', 'UTC+11:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Moldova, Republic of', 'MD', 'MDA', '498', '373', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Monaco', 'MC', 'MCO', '492', '377', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Mongolia', 'MN', 'MNG', '496', '976', 'APAC', 'UTC+08:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Montenegro', 'ME', 'MNE', '499', '382', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Montserrat', 'MS', 'MSR', '500', '1664', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Morocco', 'MA', 'MAR', '504', '212', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Mozambique', 'MZ', 'MOZ', '508', '258', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Myanmar', 'MM', 'MMR', '104', '95', 'APAC', 'UTC+06:30'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Namibia', 'NA', 'NAM', '516', '264', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Nauru', 'NR', 'NRU', '520', '674', 'APAC', 'UTC+12:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Nepal', 'NP', 'NPL', '524', '977', 'APAC', 'UTC+05:45'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Netherlands', 'NL', 'NLD', '528', '31', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('New Caledonia', 'NC', 'NCL', '540', '687', 'APAC', 'UTC+11:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('New Zealand', 'NZ', 'NZL', '554', '64', 'APAC', 'UTC+12:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Nicaragua', 'NI', 'NIC', '558', '505', 'AMER', 'UTC-06:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Niger', 'NE', 'NER', '562', '227', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Nigeria', 'NG', 'NGA', '566', '234', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Niue', 'NU', 'NIU', '570', '683', 'APAC', 'UTC-11:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Norfolk Island', 'NF', 'NFK', '574', '672', 'APAC', 'UTC+11:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('North Macedonia', 'MK', 'MKD', '807', '389', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Northern Mariana Islands', 'MP', 'MNP', '580', '1670', 'APAC', 'UTC+10:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Norway', 'NO', 'NOR', '578', '47', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Oman', 'OM', 'OMN', '512', '968', 'EMEA', 'UTC+04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Pakistan', 'PK', 'PAK', '586', '92', 'APAC', 'UTC+05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Palau', 'PW', 'PLW', '585', '680', 'APAC', 'UTC+09:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Palestine, State of', 'PS', 'PSE', '275', '970', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Panama', 'PA', 'PAN', '591', '507', 'AMER', 'UTC-05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Papua New Guinea', 'PG', 'PNG', '598', '675', 'APAC', 'UTC+10:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Paraguay', 'PY', 'PRY', '600', '595', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Peru', 'PE', 'PER', '604', '51', 'AMER', 'UTC-05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Philippines', 'PH', 'PHL', '608', '63', 'APAC', 'UTC+08:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Pitcairn', 'PN', 'PCN', '612', '870', 'APAC', 'UTC-08:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Poland', 'PL', 'POL', '616', '48', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Portugal', 'PT', 'PRT', '620', '351', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Puerto Rico', 'PR', 'PRI', '630', '1', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Qatar', 'QA', 'QAT', '634', '974', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Réunion', 'RE', 'REU', '638', '262', 'EMEA', 'UTC+04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Romania', 'RO', 'ROU', '642', '40', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Russian Federation', 'RU', 'RUS', '643', '7', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Rwanda', 'RW', 'RWA', '646', '250', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Saint Barthélemy', 'BL', 'BLM', '652', '590', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Saint Helena, Ascension and Tristan da Cunha', 'SH', 'SHN', '654', '290', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Saint Kitts and Nevis', 'KN', 'KNA', '659', '1869', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Saint Lucia', 'LC', 'LCA', '662', '1758', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Saint Martin (French part)', 'MF', 'MAF', '663', '590', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Saint Pierre and Miquelon', 'PM', 'SPM', '666', '508', 'AMER', 'UTC-03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Saint Vincent and the Grenadines', 'VC', 'VCT', '670', '1784', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Samoa', 'WS', 'WSM', '882', '685', 'APAC', 'UTC+13:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('San Marino', 'SM', 'SMR', '674', '378', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Sao Tome and Principe', 'ST', 'STP', '678', '239', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Saudi Arabia', 'SA', 'SAU', '682', '966', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Senegal', 'SN', 'SEN', '686', '221', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Serbia', 'RS', 'SRB', '688', '381', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Seychelles', 'SC', 'SYC', '690', '248', 'EMEA', 'UTC+04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Sierra Leone', 'SL', 'SLE', '694', '232', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Singapore', 'SG', 'SGP', '702', '65', 'APAC', 'UTC+08:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Sint Maarten (Dutch part)', 'SX', 'SXM', '534', '1721', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Slovakia', 'SK', 'SVK', '703', '421', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Slovenia', 'SI', 'SVN', '705', '386', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Solomon Islands', 'SB', 'SLB', '090', '677', 'APAC', 'UTC+11:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Somalia', 'SO', 'SOM', '706', '252', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('South Africa', 'ZA', 'ZAF', '710', '27', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('South Georgia and the South Sandwich Islands', 'GS', 'SGS', '239', '500', 'EMEA', 'UTC-02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('South Sudan', 'SS', 'SSD', '728', '211', 'APAC', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Spain', 'ES', 'ESP', '724', '34', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Sri Lanka', 'LK', 'LKA', '144', '94', 'APAC', 'UTC+05:30'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Sudan', 'SD', 'SDN', '729', '249', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Suriname', 'SR', 'SUR', '740', '597', 'AMER', 'UTC-03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Svalbard and Jan Mayen', 'SJ', 'SJM', '744', '47', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Sweden', 'SE', 'SWE', '752', '46', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Switzerland', 'CH', 'CHE', '756', '41', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Syrian Arab Republic', 'SY', 'SYR', '760', '963', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Taiwan, Province of China', 'TW', 'TWN', '158', '886', 'APAC', 'UTC+08:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Tajikistan', 'TJ', 'TJK', '762', '992', 'APAC', 'UTC+05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Tanzania, United Republic of', 'TZ', 'TZA', '834', '255', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Thailand', 'TH', 'THA', '764', '66', 'APAC', 'UTC+07:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Timor-Leste', 'TL', 'TLS', '626', '670', 'APAC', 'UTC+09:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Togo', 'TG', 'TGO', '768', '228', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Tokelau', 'TK', 'TKL', '772', '690', 'APAC', 'UTC+13:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Tonga', 'TO', 'TON', '776', '676', 'APAC', 'UTC+13:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Trinidad and Tobago', 'TT', 'TTO', '780', '1868', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Tunisia', 'TN', 'TUN', '788', '216', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Turkey', 'TR', 'TUR', '792', '90', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Turkmenistan', 'TM', 'TKM', '795', '993', 'APAC', 'UTC+05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Turks and Caicos Islands', 'TC', 'TCA', '796', '1649', 'AMER', 'UTC-05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Tuvalu', 'TV', 'TUV', '798', '688', 'APAC', 'UTC+12:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Uganda', 'UG', 'UGA', '800', '256', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Ukraine', 'UA', 'UKR', '804', '380', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('United Arab Emirates', 'AE', 'ARE', '784', '971', 'EMEA', 'UTC+04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('United Kingdom of Great Britain and Northern Ireland', 'GB', 'GBR', '826', '44', 'EMEA', 'UTC+00:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('United States Minor Outlying Islands', 'UM', 'UMI', '581', '', 'APAC', 'UTC-11:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('United States of America', 'US', 'USA', '840', '1', 'AMER', 'UTC-06:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Uruguay', 'UY', 'URY', '858', '598', 'AMER', 'UTC-03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Uzbekistan', 'UZ', 'UZB', '860', '998', 'APAC', 'UTC+05:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Vanuatu', 'VU', 'VUT', '548', '678', 'APAC', 'UTC+11:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Venezuela, Bolivarian Republic of', 'VE', 'VEN', '862', '58', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Viet Nam', 'VN', 'VNM', '704', '84', 'APAC', 'UTC+07:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Virgin Islands, British', 'VG', 'VGB', '092', '1284', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Virgin Islands, U.S.', 'VI', 'VIR', '850', '1340', 'AMER', 'UTC-04:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Wallis and Futuna', 'WF', 'WLF', '876', '681', 'APAC', 'UTC+12:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Western Sahara', 'EH', 'ESH', '732', '212', 'EMEA', 'UTC+01:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Yemen', 'YE', 'YEM', '887', '967', 'EMEA', 'UTC+03:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Zambia', 'ZM', 'ZMB', '894', '260', 'EMEA', 'UTC+02:00'))
    [void]$ISO3166Countries.Add([PSstrudelCountry]::new('Zimbabwe', 'ZW', 'ZWE', '716', '263', 'EMEA', 'UTC+02:00'))
    #endregion
  }

  process {
    # Output
    if ( $PSBoundParameters['TwoLetterCode'] ) {
      return $( $ISO3166Countries | Where-Object TwoLetterCode -EQ $TwoLetterCode )
    }
    elseif ( $PSBoundParameters['ThreeLetterCode'] ) {
      return $( $ISO3166Countries | Where-Object ThreeLetterCode -EQ $ThreeLetterCode )
    }
    elseif ( $PSBoundParameters['NumericCode']  ) {
      return $( $ISO3166Countries | Where-Object NumericCode -EQ $NumericCode )
    }
    elseif ( $PSBoundParameters['Region']  ) {
      return $( $ISO3166Countries | Where-Object Region -EQ $Region )
    }
    elseif ( $PSBoundParameters['TimeZone']  ) {
      $TimeZoneValue = if ( $TimeZone -eq 'UTC' ) { 'UTC+00:00' } else { $TimeZone }
      return $( $ISO3166Countries | Where-Object TimeZone -EQ $TimeZoneValue )
    }
    elseif ( $PSBoundParameters['DialCode']  ) {
      return $( $ISO3166Countries | Where-Object DialCode -EQ $DialCode )
    }
    else {
      return $ISO3166Countries
    }
  }

  end {

  }
} #Get-ISO3166Country
