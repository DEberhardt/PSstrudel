# Module:   PSstrudel (all)
# Function: Test
# Author:		David Eberhardt
# Updated:  19-01-2024
# Purpose:  Testing Module Structure, files, etc.




BeforeDiscovery {
  # Finding Module Source Path
  $Root = ($PsScriptRoot -split '\\Tests')[0]
  $PSstrudelSrc = Join-Path -Path $Root -ChildPath src

  $TestsFiles = Get-ChildItem -Path $PSstrudelSrc -Recurse -Include '*.tests.ps1' -Filter *.tests.ps1
  Write-Output "ModuleFunctions - $($TestsFiles.Count) test files discovered"

}

Describe -Tags ('Unit', 'Acceptance') 'PSstrudel - Testing Module Functions' {
  BeforeAll {

  }

  Context 'Testing Module TESTS files' -ForEach $TestsFiles {
    It ("'{0}' should have a valid header" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch 'Module:'
      '{0}' -f $_.FullName | Should -FileContentMatch 'Function:'
      '{0}' -f $_.FullName | Should -FileContentMatch 'Author:'
      '{0}' -f $_.FullName | Should -FileContentMatch 'Updated:'

    }

    #TODO add more tests for how the tests file should look like?
    It ("'{0}' should have a DESCRIBE block" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch 'Describe -Tags'
    }
  }

}