# Module:     PSstrudel
# Function:   Helper
# Author:     Francois-Xavier Cat
# Updated:    31-MAY-2021
# Status:     Live




function Set-PowerShellWindowTitle {
  <#
  .SYNOPSIS
    Function to set the title of the PowerShell Window
  .DESCRIPTION
    Function to set the title of the PowerShell Window
  .PARAMETER Title
    Specifies the Title of the PowerShell Window
  .EXAMPLE
    Set-PowerShellWindowTitle -Title LazyWinAdmin.com

    Sets the Window Title to "LazyWinAdmin.com"
  .INPUTS
    System.String
  .OUTPUTS
    System.Void
  .NOTES
    Francois-Xavier Cat
    lazywinadmin.com
    @lazywinadmin
  .COMPONENT
    SupportingFunction
  .FUNCTIONALITY
    Sets the Window title of the Powershell console
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/cmdlet/Set-PowerShellWindowTitle.md
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/about/about_Tools.md
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/
  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Window title is a miniscule change')]
  [CmdletBinding()]
  PARAM($Title)

  begin {
    #Show-PSstrudelFunctionStatus -Level Live

  }

  process {
    #Write-Verbose -Message ("[PROCESS] {0}" -f $MyInvocation.MyCommand)
    try {
      $Host.UI.RawUI.WindowTitle = $Title
    }
    catch {
      $PSCmdlet.ThrowTerminatingError($_)
    }
  }

  end {

  }
}