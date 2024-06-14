# Module:   PSstrudel.Tools
# Function: Test
# Author:		David Eberhardt
# Updated:  03-JUN 2023

# Script Analyzer Exceptions
#[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Justification = 'Context Boundaries')]


# Unit Tests
Describe -Tags ('Unit', 'Acceptance') "Function '$(((Split-Path -Leaf $PsCommandPath) -replace '\.Tests\.', '.') -replace '\.ps1', '')'" {
  InModuleScope -ModuleName 'PSstrudel' {
    BeforeAll {
      # Mocking basic connection commands to avoid connectivity related errors
      Mock Sync-PSstrudel -MockWith { $null }


      # Splatting Parameters
      $Params = @{
        WarningAction     = 'SilentlyContinue'
        InformationAction = 'SilentlyContinue'
      }

      # Dot Sourcing Mock Objects
      . "$(((Split-Path -Parent $PsScriptRoot) -split 'Tests')[0])\Tests\Unit\Testing-MockedObjects.ps1"
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
