# Module:   PSstrudel
# Function: Test
# Author:
# Updated:  00-JAN 2024




# Unit Tests
Describe -Tags ('Unit', 'Acceptance') "Function '$(((Split-Path -Leaf $PsCommandPath) -replace '\.Tests\.', '.') -replace '\.ps1', '')'" {
  InModuleScope -ModuleName 'PSstrudel' {
    BeforeAll {
      # Splatting Parameters
      $Params = @{
        WarningAction     = 'SilentlyContinue'
        InformationAction = 'SilentlyContinue'
      }

      # Dot Sourcing Mock Objects
      . "$((Split-Path -Parent $PsScriptRoot) -split 'Tests')\Tests\Testing-MockedObjects.ps1"
    }

    Context 'Input' {
      # Pipeline, Position, etc.

    }

    Context 'Execution' {
      # Code Logic

    }

    Context 'Output' {
      #Properties, Values, Types

    }

  }
}
