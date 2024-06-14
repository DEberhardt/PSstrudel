# Module:   PSstrudel
# Function: Support
# Author:   Unknown
# Updated:  03-MAY-2020
# Status:   Live




function Format-StringForUse {
  <#
  .SYNOPSIS
    Formats a string by removing special characters usually not allowed.
  .DESCRIPTION
    Special Characters in strings usually lead to terminating errors.
    This function gets around that by formating the string properly.
    Use is limited, but can be used for UPNs and Display Names
    Adheres to Microsoft recommendation of special Characters
  .PARAMETER InputString
    Mandatory. The string to be reformatted
  .PARAMETER As
    Desired Output Format: DisplayName, UserPrincipalName, Number, E164, LineUri.
    Uses predefined special characters to remove, Cannot be used together with -SpecialChars
    Display Names are truncated to the provided MaxLength or the default of 64
  .PARAMETER SpecialChars
    Default, Optional String. Manually define which special characters to remove.
    If not specified, only the following characters are removed: ?()[]{}
    Cannot be used together with -As
  .PARAMETER Replacement
    Optional String. Manually replaces removed characters with this string.
  .PARAMETER MaxLength
    Optional for -As DisplayName. Enforces that the string does not exceed the maximum allowed length.
    Set to any value between 20 and 256 characters. String will be truncated after the last allowed character.
    If not provided, Display Names are truncated after 64 characters
  .EXAMPLE
    Format-StringForUse  -InputString "<my>\Test(String)"

    Returns "<my>\TestString". All SpecialChars defined will be removed.
  .EXAMPLE
    Format-StringForUse  -InputString "<my>\Test(String)" -SpecialChars "\"

    Returns "myTest(String)". All SpecialChars defined will be removed.
  .EXAMPLE
    Format-StringForUse -InputString "<my>\Test(String)" -As UserPrincipalName

    Returns "myTestString" for UserPrincipalName does not support any of the special characters
  .EXAMPLE
    Format-StringForUse  -InputString "<my>\Test(String)" -As DisplayName

    Returns "myTest(String)" for DisplayName does not support some special characters if the length does not exceed 64 characters
  .EXAMPLE
    Format-StringForUse  -InputString "<my>\Test(String)" -As DisplayName -MaxLength 40

    Returns "myTest(String)" for DisplayName does not support some special characters if the length does not exceed 40 characters
  .EXAMPLE
    Format-StringForUse  -InputString "1 (555) 1234-567" -As E164

    Returns "+15551234567" for LineURI does not support spaces, dashes, parenthesis characters and must start with "+"
  .EXAMPLE
    Format-StringForUse  -InputString "1 (555) 1234-567" -As LineURI

    Returns "tel:+15551234567" for LineURI does not support spaces, dashes, parenthesis characters and must start with "tel:+"
  .INPUTS
    System.String
  .OUTPUTS
    System.String
  .NOTES
    None
  .COMPONENT
    Tools
  .FUNCTIONALITY
    Reformats a string to be used as an E.164 Number, LineUri/TelUri, DisplayName or UserPrincipalName; Removes special Characters in the process
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/cmdlet/Format-StringForUse.md
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/about/about_Tools.md
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/
  #>

  [CmdletBinding(DefaultParameterSetName = 'Manual')]
  [OutputType([String])]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'String to reformat')]
    [string]$InputString,

    [Parameter(HelpMessage = 'Replacement character or string for each removed character')]
    [string]$Replacement = '',

    [Parameter(ParameterSetName = 'Specific')]
    [ValidateSet('UserPrincipalName', 'DisplayName', 'Number', 'E164', 'LineURI')]
    [string]$As,

    [Parameter(ParameterSetName = 'Manual')]
    [string]$SpecialChars = '?()[]{}'
  ) #param

  DynamicParam {

    If ($As -eq 'DisplayName') {

      $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary

      # Defining parameter attributes
      $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
      $attributes = New-Object System.Management.Automation.ParameterAttribute
      $attributes.ParameterSetName = '__AllParameterSets'
      $attributes.HelpMessage = 'Custom max length of the DisplayName'

      # Adding ValidateNotNullOrEmpty parameter validation
      $v = New-Object System.Management.Automation.ValidateNotNullOrEmptyAttribute
      $AttributeCollection.Add($v)

      # Adding ValidateRange parameter validation
      $value = @(20, 256)
      $v = New-Object System.Management.Automation.ValidateRangeAttribute($value)
      $AttributeCollection.Add($v)
      $attributeCollection.Add($attributes)

      # Defining the runtime parameter
      $dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter('MaxLength', [Int32], $attributeCollection)
      $dynParam1.Value = 64
      $paramDictionary.Add('MaxLength', $dynParam1)

      return $paramDictionary
    } # end if

  } #end DynamicParam

  begin {
    Show-PSstrudelFunctionStatus -Level Live
    #Write-Verbose -Message ("[BEGIN  ] {0}" -f $MyInvocation.MyCommand)

    $ReplacementWarning = "Replacement is not allowed for '{0}'. Ignoring input" -f $As

  } #begin

  process {
    Write-Verbose -Message ('[PROCESS] {0}' -f $MyInvocation.MyCommand)

    switch ($PsCmdlet.ParameterSetName) {
      'Specific' {
        switch ($As) {
          'UserPrincipalName' {
            $CharactersToRemove = '\%&*+/=?{}|<>();:,[]"'
            $CharactersToRemove += "'´"
          }
          'DisplayName' {
            #$CharactersToRemove = '\%*+/=?{}|<>[]"'
            $CharactersToRemove = '\%*+=?{}|<>[]"'
          }
          'Number' {
            $CharactersToRemove = '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;+'

            if ( $Replacement -ne '') {
              Write-Warning -Message $ReplacementWarning
              $Replacement = '' # Replacement is not allowed
            }
          }
          'E164' {
            $CharactersToRemove = '\%*/@:=-()?{}|<>[]" abcdefghijklmnopqrstuvwxyz;'

            if ( $Replacement -ne '') {
              Write-Warning -Message $ReplacementWarning
              $Replacement = '' # Replacement is not allowed
            }
          }
          'LineURI' {
            $CharactersToRemove = '\%*/-()?{}|<>[]" abcdfghijkmnopqrsuvwyz'

            if ( $Replacement -ne '') {
              Write-Warning -Message $ReplacementWarning
              $Replacement = '' # Replacement is not allowed
            }
          }
        }
      }
      'Manual' { $CharactersToRemove = $SpecialChars }
      Default { }
    }

    $rePattern = ($CharactersToRemove.ToCharArray() | ForEach-Object { [regex]::Escape($_) }) -join '|'

    if ($As -eq 'E164' -or $As -eq 'Number') {
      # Truncating Extension if specified ";ext=" if specified
      $InputString = $InputString.split(';')[0]
    }

    [String]$String = $InputString -replace $rePattern, $Replacement

    if ($As -eq 'UserPrincipalName') {
      # Replacing Spaces with underscores as no spaces are allowed
      $String = $String.replace(' ','_')
      # Validate User Side of a UPN does not end in a '.'
      [String]$OutputString = $String.replace('.@', '@')
      try {
        # Catching Errors for misconfigured UPNs
        if ( ($String.split('@')[0]).length -gt 64 ) { throw 'UserPrincipalName - Prefix (User) must not exceed 64 characters' }
        if ( ($String.split('@')[1]).length -gt 48 ) { throw 'UserPrincipalName - Suffix (Domain) must not exceed 48 characters' }
      }
      catch {
        $PSCmdlet.WriteError($_)
      }
    }
    elseif ($As -eq 'DisplayName') {
      # Catching misconfigured DisplayNames
      $MaxLength = if ( $PsBoundParameters.MaxLength ) { $PsBoundParameters.MaxLength } else { 64 }
      if ( $String.length -gt $MaxLength ) {
        $String = $String.Substring(0, $MaxLength).Trim()
        $message = "Formatting as DisplayName - Length must not exceed {0} characters. Truncating String to fit: '{1}'" -f $MaxLength, $String
        Write-Warning $message
      }
      [String]$OutputString = $String
    }
    elseif ($As -eq 'Number') {
      switch -regex ($String) {
        '^\d' { [String]$OutputString = $String; Break }
        default {
          if ($String -match '\+') {
            [String]$OutputString = $String.replace('+', '')
          }
          Break
        }
      }
      if ( -not $OutputString ) {
        [String]$OutputString = ''
      }
    }
    elseif ($As -eq 'E164') {
      switch -regex ($String) {
        '^\d' { [String]$OutputString = '+' + $String; Break }
        '^\+\d' { [String]$OutputString = $String; Break }
        default {
          if ($String -match '\+') {
            [String]$OutputString = '+' + $String.replace('+', '')
          }
          Break
        }
      }
      if ( -not $OutputString ) {
        [String]$OutputString = ''
      }
    }
    elseif ($As -eq 'LineURI') {
      switch -regex ($String) {
        '^\d' { [String]$OutputString = 'tel:+' + $String; Break }
        '^\+\d' { [String]$OutputString = 'tel:' + $String; Break }
        '^tel:\+\d' { [String]$OutputString = $String; Break }
        '^tel:\d' { [String]$OutputString = $String -replace 'tel:', 'tel:+'; Break }
      }
      if ( -not $OutputString ) {
        [String]$OutputString = ''
      }
    }
    else {
      [String]$OutputString = $String
    }

    return $OutputString
  } #process

  end {
    #Write-Verbose -Message ("[END    ] {0}" -f $MyInvocation.MyCommand)
  } #end
} #Format-StringForUse
