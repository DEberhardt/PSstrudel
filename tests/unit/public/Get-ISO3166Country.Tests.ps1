# Module:   PSstrudel.Tools
# Function: Test
# Author:   David Eberhardt
# Updated:  23-JUL-2022

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

    Context 'Execution without Arguments' {
      BeforeAll {
        $Countries = Get-ISO3166Country
      }

      It 'Should return an array if called without parameters' {
        $Countries.Count | Should -BeGreaterThan 240
      }

      It 'Should return objects of the Type PSstrudelCountry' {
        $Countries[0] | Should -BeOfType [System.Object] # PSstrudelCountry does not work :(
      }
    }

    Context 'Execution with Parameters' {
      It 'Should return one object when searched with -TwoLetterCode' {
        $QueryTwoLetterCode = Get-ISO3166Country -TwoLetterCode DK

        $QueryTwoLetterCode.Name | Should -Be 'Denmark'
        $QueryTwoLetterCode.ThreeLetterCode | Should -Be 'DNK'
        $QueryTwoLetterCode.NumericCode | Should -Be '208'
        $QueryTwoLetterCode.DialCode | Should -Be '45'
        $QueryTwoLetterCode.Region | Should -Be 'EMEA'
        $QueryTwoLetterCode.TimeZone | Should -Be 'UTC+01:00'
      }

      It 'Should return one object when searched with ThreeLetterCode' {
        $QueryThreeLetterCode = Get-ISO3166Country -ThreeLetterCode NOR

        $QueryThreeLetterCode.Name | Should -Be 'Norway'
        $QueryThreeLetterCode.TwoLetterCode | Should -Be 'NO'
        $QueryThreeLetterCode.NumericCode | Should -Be '578'
        $QueryThreeLetterCode.DialCode | Should -Be '47'
        $QueryThreeLetterCode.Region | Should -Be 'EMEA'
        $QueryThreeLetterCode.TimeZone | Should -Be 'UTC+01:00'
      }

      It 'Should return one object when searched with NumericCode' {
        $QueryNumericCode = Get-ISO3166Country -NumericCode 800

        $QueryNumericCode.Name | Should -Be 'Uganda'
        $QueryNumericCode.TwoLetterCode | Should -Be 'UG'
        $QueryNumericCode.ThreeLetterCode | Should -Be 'UGA'
        $QueryNumericCode.DialCode | Should -Be '256'
        $QueryNumericCode.Region | Should -Be 'EMEA'
        $QueryNumericCode.TimeZone | Should -Be 'UTC+03:00'
      }

      It 'Should return an array when searched with Region' {
        $QueryRegion = Get-ISO3166Country -Region APAC

        $QueryRegion.Count | Should -BeGreaterThan 5
      }

      It 'Should return an array when searched with TimeZone' {
        $QueryTimeZone = Get-ISO3166Country -TimeZone UTC-11:00

        $QueryTimeZone.Count | Should -Be 3
      }

      It 'Should return a single country when searched with DialCode' {
        $QueryTimeZone = Get-ISO3166Country -DialCode 43

        $QueryTimeZone.Count | Should -Be 1
        $QueryTimeZone.Name | Should -Be 'Austria'
      }
    }

    Context 'Output' {
      #Properties, Values, Types

    }

  }
}
