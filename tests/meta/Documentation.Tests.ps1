# Module:   PSstrudel (all)
# Function: Test
# Author:		David Eberhardt
# Updated:  19-01-2024
# Purpose:  Testing Module Structure, files, etc.




BeforeDiscovery {
  # Finding Module Source Path
  $Root = ($PsScriptRoot -split '\\Tests')[0]
  $PSstrudelSrc = Join-Path -Path $Root -ChildPath src

  # Documentation
  $PSstrudelDocs = Get-ChildItem -Path ($PSstrudelSrc | Split-Path -Parent) -Filter docs
  $PublicDocs = Get-ChildItem -Path $PSstrudelDocs -Include '*.md' -Recurse
  Write-Output ('ModuleFunctions - {0} markdown files discovered' -f $PublicDocs.Count)

}

Describe -Tags ('Unit', 'Acceptance') 'PSstrudel - Testing Module Functions' {
  BeforeAll {

  }

  Context 'Testing Module PUBLIC Documentation' -ForEach $PublicDocs {

    It ("'{0}' should NOT have empty documentation in the MD file" -f $_) {
      # Deactivated as PlatyPs now adds a common parameter 'ProgressAction'
      # '{0}' -f $_.FullName | Should -Not -FileContentMatch ([regex]::Escape('{{'))
    }
  } # Context "Testing Module DOCS"

}