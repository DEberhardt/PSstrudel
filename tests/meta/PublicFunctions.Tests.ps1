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

  # Public Functions
  $PublicFunctions = $AllFunctions | Where-Object { $_.Directory -match '\\Public' }
  Write-Output ('ModuleFunctions - {0} public functions discovered' -f $PublicFunctions.Count)

}

Describe -Tags ('Unit', 'Acceptance') 'PSstrudel - Testing Module Functions' {
  BeforeAll {

  }

  Context 'Testing Module PUBLIC Functions' -ForEach $PublicFunctions {

    It ("'{0}' should have a SYNOPSIS section in the help block" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch '.SYNOPSIS'
    }

    It ("'{0}' should have a DESCRIPTION section in the help block" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch '.DESCRIPTION'
    }

    It ("'{0}' should have a EXAMPLE section in the help block" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch '.EXAMPLE'
    }

    It ("'{0}' should have a NOTES section in the help block" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch '.NOTES'
    }

    It ("'{0}' should have a INPUTS section in the help block" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch '.INPUTS'
    }

    It ("'{0}' should have a OUTPUTS section in the help block" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch '.OUTPUTS'
    }

    It ("'{0}' should have a COMPONENT section in the help block" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch '.COMPONENT'
    }

    It ("'{0}' should have a FUNCTIONALITY section in the help block" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch '.FUNCTIONALITY'
    }

    It ("'{0}' should have a LINK section in the help block" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch '.LINK'
    }

    It ("'{0}' should have the HELP URL linked in the LINK section in the help block" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch ('https://github.com/DEberhardt/PSstrudel/tree/main/docs/cmdlet/{0}.md' -f $_.BaseName)
      '{0}' -f $_.FullName | Should -FileContentMatch 'https://github.com/DEberhardt/PSstrudel/tree/main/docs/about/about_'
      '{0}' -f $_.FullName | Should -FileContentMatch 'https://github.com/DEberhardt/PSstrudel/tree/main/docs/'
    }

    It ("'{0}' should have an ABOUT topic linked in the LINK section in the help block" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch 'about_'
    }

    It ("'{0}' should have a BEGIN, PROCESS and END block" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch 'begin {'
      '{0}' -f $_.FullName | Should -FileContentMatch 'process {'
      '{0}' -f $_.FullName | Should -FileContentMatch 'end {'
    }

    It ("'{0}' should have an OUTPUTTYPE set" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch '[OutputType([*)]' # order and count of groupings deliberate
    }

    It ("'{0}' should contain at least one Write-Verbose blocks" -f $_.BaseName) {
      '{0}' -f $_.FullName | Should -FileContentMatch 'Write-Verbose'
    }

  } # Context "Testing Module PUBLIC Functions"

}