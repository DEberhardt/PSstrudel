# Module:   PSstrudel
# Function: ResourceAccount
# Author:   David Eberhardt
# Updated:  01-MAR-2022
# Status:   Live




function Test-StringInput {
  <#
  .SYNOPSIS
    Tests whether a string matches a set criteria
  .DESCRIPTION
    Tests whether a string matches a set criteria
  .PARAMETER String
    Mandatory. The string to be reformatted
  .PARAMETER Is
    Mandatory. Desired Output Format to test against: Guid, UPN, GuidOrUpn, AudioFileExt, ChannelGuid, PhoneNumber
  .EXAMPLE
    $_ | Test-StringInput -Is Guid

    Returns TRUE if the piped object matches a Guid. This is useful in ValidateScript statement and indicates an Identity
  .EXAMPLE
    $_ | Test-StringInput -Is UPN

    Returns TRUE if the piped object matches a UPN. This is useful in ValidateScript statement and indicates a UserPrincipalName
  .EXAMPLE
    $_ | Test-StringInput -Is GuidOrUpn

    Returns TRUE if the piped object matches a GUID or a UPN. This is useful in ValidateScript statement
  .EXAMPLE
    Test-StringInput -String $Prompt -Is AudioFileExt

    Returns TRUE if the $Prompt matches an Audio File Extension acceptable for a Teams Audio File (MP3, WMA, WAV)
  .EXAMPLE
    Test-StringInput -String $ChannelGuid -Is ChannelGuid

    Returns TRUE if the $ChannelGuid matches a GUID used for Teams Channels
  .EXAMPLE
    Test-StringInput -String $PhoneNumber -Is PhoneNumber

    Returns TRUE if the $PhoneNumber matches a formatted PhoneNumber in any way (to be reformatted later to get rid of unwanted characters)
  .EXAMPLE
    Test-StringInput -String $Thumbprint -Is Thumbprint

    Returns TRUE if the $Thumbprint matches a Certificate Thumbprint of 40 characters without spaces and only 0-9 and A-F (uppercase)
  .INPUTS
    System.String
  .OUTPUTS
    System.Boolean
  .NOTES
    None
  .COMPONENT
    Tools
  .FUNCTIONALITY
    Tests whether a string matches a set criteria
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/cmdlet/Test-StringInput.md
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/about/about_Tools.md
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/
  #>

  [CmdletBinding(DefaultParameterSetName = 'Manual')]
  [OutputType([bool])]
  param (
    [Parameter(Mandatory)]
    [ValidateSet('Guid', 'UPN', 'GuidOrUpn', 'AudioFileExt', 'ChannelGuid', 'PhoneNumber', 'Thumbprint')]
    [string]$Is,

    [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
    [string]$String
  )

  begin {
    Show-PSstrudelFunctionStatus -Level Live
    #Write-Verbose -Message ("[BEGIN  ] {0}" -f $MyInvocation.MyCommand)

    [regex]$script:PSstrudelRegexPhoneNumber = '^(tel:\+|\+)?([0-9]?[-\s]?(\(?[0-9]{3}\)?)[-\s]?([0-9]{3}[-\s]?[0-9][-\s]?[0-9]{3})|([0-9][-\s]?){4,20})((x|;ext=)([0-9]{3,8}))?$'
    [regex]$script:PSstrudelRegexAudioFileExtension = '.(wav|wma|mp3|WAV|WMA|MP3)$'
    [regex]$script:PSstrudelRegexChannelGuid = '^(19:)([0-9a-f]{32}|[a-zA-Z0-9-_]{44})(@thread.)(skype|tacv2|([0-9a-z]{5}))$'
    [regex]$script:PSstrudelRegexUPN = '^(?:([^@ ]+)@([^@ ]+)\.([^@ ]+))$'
    [regex]$script:PSstrudelRegexThumbprint = '^([0-9A-F]){40}$'
  }

  process {
    # Write-Verbose -Message ("[PROCESS] {0}" -f $MyInvocation.MyCommand)

    switch ( $Is ) {
      'Guid' { [bool]( [guid]::TryParse( $String, ([ref]$([guid]::NewGuid()))) ) }
      'UPN' { [bool]( $script:PSstrudelRegexUPN.isMatch( $String ) ) }
      'GuidOrUpn' { [bool](  $script:PSstrudelRegexUPN.isMatch( $String ) -or ([guid]::TryParse($String, ([ref]$([guid]::NewGuid()))) )) }
      'AudioFileExt' { [bool]( $script:PSstrudelRegexAudioFileExtension.isMatch( $String ) ) }
      'ChannelGuid' { [bool]( $script:PSstrudelRegexChannelGuid.isMatch( $String ) ) }
      'PhoneNumber' { [bool]( $script:PSstrudelRegexPhoneNumber.isMatch( $String ) ) }
      'Thumbprint' { [bool]( $script:PSstrudelRegexThumbprint.isMatch( $String ) ) }
    }

  }

  end {
    #Write-Verbose -Message ("[END    ] {0}" -f $MyInvocation.MyCommand)

  }

}