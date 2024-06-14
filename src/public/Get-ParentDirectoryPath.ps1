# Module:     PSstrudel
# Function:   Support, CallQueue, AutoAttendant
# Author:     David Eberhardt
# Updated:    24-JUL-2022
# Status:     Live



function Get-ParentDirectoryPath {
  <#
	.SYNOPSIS
		Returns the Parent Directory Path for the Parent Directory Name given.
	.DESCRIPTION
		Crawls through the Directory structure (upstream only, no recursive downstream!) and searches for a parent directory
    with the name given. If no DirectoryName is provided will use the current directory.
	.PARAMETER DirectoryName
		Optional. Folder path to search for. If not provided is provided will use the current directory.
	.PARAMETER TargetParentDirectory
		Required. String to be searched for. This string is required to be found in the current Folder Path
  .EXAMPLE
    Get-ParentDirectoryPath -TargetParentDirectory "test"

    Returns the path if a parent directory is called test. Searches from the current directory
  .EXAMPLE
    Get-ParentDirectoryPath -TargetParentDirectory "test" -DirectoryName C:\Temp\Test\Subfolder\Level2\Test

    Returns the path if a parent directory is called test: C:\Temp\Test -- Note, the own directory name is ignored.
  .EXAMPLE
    Get-ParentDirectoryPath -TargetParentDirectory "test" -DirectoryName C:\Temp\Testing\Subfolder\Level2\Test

    Throws an error as the TargetParentDirectory is not part of the folder name
  .INPUTS
    System.String
  .OUTPUTS
    System.String
	.NOTES
    Used for Traversing Folder structure to find files in parent folders.
  .COMPONENT
    Tools
	.FUNCTIONALITY
		Finds correct folder names
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/cmdlet/Get-ParentDirectoryPath.md
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/about/about_Tools.md
  .LINK
    https://github.com/DEberhardt/PSstrudel/tree/main/docs/
	#>

  param (
    [Parameter()]
    [string]$DirectoryName = (Get-Location),

    [Parameter(Mandatory)]
    [string]$TargetParentDirectory
  )

  begin {
    #Show-PSstrudelFunctionStatus -Level Live
    #Write-Verbose -Message ("[BEGIN  ] {0}" -f $MyInvocation.MyCommand)

  } #begin

  process {
    #Write-Verbose -Message ("[PROCESS] {0}" -f $MyInvocation.MyCommand)
    if ( $DirectoryName -match $TargetParentDirectory ) {
      $Directory = $DirectoryName
      do {
        try {
          $Directory = Split-Path $Directory -Parent -ErrorAction Stop
          $Name = Split-Path $Directory -Leaf -ErrorAction Stop
        }
        catch {
          throw 'Error encountered when splitting paths: {0}' -f $_.Exception.Message
        }
      }
      until ($Name -eq $TargetParentDirectory)
      return $Directory
    }
    else {
      throw "No directory found in the Folder Path with the Name '{0}'" -f $TargetParentDirectory
    }
  } #process

  end {
    #Write-Verbose -Message ("[END    ] {0}" -f $MyInvocation.MyCommand)
  } #end
} # Get-ParentDirectoryPath
