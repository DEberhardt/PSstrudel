# Module:   PSstrudel (all)
# Function: Test
# Author:		David Eberhardt
# Updated:  19-01-2024
# Purpose:  Testing Module Structure, files, etc.




BeforeDiscovery {
  # Finding Module Source Path
  $Root = ($PsScriptRoot -split '\\Tests')[0]
  $PSstrudelSrc = Join-Path -Path $Root -ChildPath '\src'

  # Query all child items
  $AllFunctions = Get-ChildItem -Path $PSstrudelSrc -Recurse -Include '*.ps1' -Exclude '*.tests.ps1', 'Testing-MockedObjects*', '*.Enums*'
  Write-Output ('ModuleFunctions - {0} functions discovered' -f $AllFunctions.Count)

  # Private Functions
  $PrivateFunctions = $AllFunctions | Where-Object { $_.Directory -match '\\Private' }
  Write-Output ('ModuleFunctions - {0} private functions discovered' -f $PrivateFunctions.Count)

}

Describe -Tags ('Unit', 'Acceptance') 'PSstrudel - Testing Module Functions' {
  BeforeAll {

  }

  Context 'Testing Module PRIVATE Functions' -ForEach $PrivateFunctions {

    # currently no special tests for private functions

  } # Context "Testing Module PRIVATE Functions"

}