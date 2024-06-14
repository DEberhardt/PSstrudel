# Module:   PSstrudel (all)
# Function: Test
# Author:		David Eberhardt
# Updated:  19-01-2024
# Purpose:  Testing Module Structure, files, etc.




BeforeDiscovery {
  # Finding Module Source Path
  $Root = ($PsScriptRoot -split '\\Tests')[0]
  $PSstrudelSrc = Join-Path -Path $Root -ChildPath src

  # Query all child items
  $AllFunctions = Get-ChildItem -Path $PSstrudelSrc -Recurse -Include '*.ps1' -Exclude '*.tests.ps1', 'Testing-MockedObjects*', '*.Enums*'
  Write-Output ('ModuleFunctions - {0} functions discovered' -f $AllFunctions.Count)

}

Describe -Tags ('Unit', 'Acceptance') 'PSstrudel - Testing Module Functions' {
  BeforeAll {

  }

  Context 'Testing File Contents' -ForEach $Allfunctions {

    It ("'{0}' should have a valid header" -f $_.Basename) {
      "{0}" -f $_.FullName | Should -FileContentMatch 'Module:'
      "{0}" -f $_.FullName | Should -FileContentMatch 'Function:'
      "{0}" -f $_.FullName | Should -FileContentMatch 'Author:'
      "{0}" -f $_.FullName | Should -FileContentMatch 'Updated:'
      "{0}" -f $_.FullName | Should -FileContentMatch 'Status:'
    }

    It ("'{0}' should have a function" -f $_.BaseName){
      "{0}" -f $_.FullName | Should -FileContentMatch 'function'
    }

    It ("'{0}' should be an advanced function" -f $_.BaseName) {
      "{0}" -f $_.FullName | Should -FileContentMatch '[Cmdletbinding([*)]' # order and count of groupings deliberate
      "{0}" -f $_.FullName | Should -FileContentMatch 'param'
    }

    It ("'{0}' is valid PowerShell code" -f $_.BaseName){
      $psFile = Get-Content -Path $_.FullName -ErrorAction Stop
      $errors = $null
      $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
      $errors.Count | Should -Be 0
    }
  } # Context "Testing Module ALL Functions"

}