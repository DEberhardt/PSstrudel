# Module:   PSstrudel.Tools
# Function: Test
# Author:   David Eberhardt
# Updated:  11-OCT-2020

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
      It 'Should accept a String as a Pipeline' {
        'UserAccount@domain.com' | Test-StringInput -Is UPN | Should -BeTrue
      }

      It 'Should accept a String as a positional Parameter' {
        Test-StringInput 'UserAccount@domain.com' -Is UPN | Should -BeTrue
      }
    }

    Context 'Execution' {
      # Code Logic
      It 'Should be of type System.Boolean' {
        (New-Guid).Guid | Test-StringInput -Is Guid | Should -BeOfType System.Boolean
      }
    }

    Context 'Output' {
      #Properties, Values, Types
      It 'Should be of type System.Boolean' {
        Test-StringInput -String 'Test' -Is Guid | Should -BeOfType System.Boolean

      }

      It 'Should identify a Guid' {
        $Is = 'Guid'

        (New-Guid).Guid | Test-StringInput -Is $Is | Should -BeTrue
        '8749dbcf-f571-4b17-8d92-09e8dd4171b8' | Test-StringInput -Is $Is | Should -BeTrue
        # This parses OK for a Guid
        '8749dbcff5714b178d9209e8dd4171b8' | Test-StringInput -Is $Is | Should -BeTrue

        'not a guid' | Test-StringInput -Is $Is | Should -BeFalse
        '+123456789011' | Test-StringInput -Is $Is | Should -BeFalse
        'User@domain.com' | Test-StringInput -Is $Is | Should -BeFalse

        # malformed Guid
        '8749dbcf f571 4b17 8d92 09e8dd4171b8' | Test-StringInput -Is $Is | Should -BeFalse

      }

      It 'Should identify a UPN' {
        $Is = 'UPN'

        'User@domain.com' | Test-StringInput -Is $Is | Should -BeTrue
        '+123456789011@domain.com' | Test-StringInput -Is $Is | Should -BeTrue

        # Wrong Type
        '+123456789011' | Test-StringInput -Is $Is | Should -BeFalse

        # Malformed UPN
        'Faulty User@domain.com' | Test-StringInput -Is $Is | Should -BeFalse
        'User@faultyDomain' | Test-StringInput -Is $Is | Should -BeFalse
        'User@domain with Spaces.com' | Test-StringInput -Is $Is | Should -BeFalse

      }

      It 'Should identity a GuidOrUPN' {
        $Is = 'GuidOrUPN'

        'User@domain.com' | Test-StringInput -Is $Is | Should -BeTrue

        (New-Guid).Guid | Test-StringInput -Is $Is | Should -BeTrue
        '8749dbcf-f571-4b17-8d92-09e8dd4171b8' | Test-StringInput -Is $Is | Should -BeTrue
        # This parses OK for a Guid
        '8749dbcff5714b178d9209e8dd4171b8' | Test-StringInput -Is $Is | Should -BeTrue

        'not a guid' | Test-StringInput -Is $Is | Should -BeFalse
        '+123456789011' | Test-StringInput -Is $Is | Should -BeFalse

        # malformed Guid
        '8749dbcf f571 4b17 8d92 09e8dd4171b8' | Test-StringInput -Is $Is | Should -BeFalse

        # malformed UPN
        'Faulty User@domain.com' | Test-StringInput -Is $Is | Should -BeFalse
        'User@faultyDomain' | Test-StringInput -Is $Is | Should -BeFalse
        'User@domain with Spaces.com' | Test-StringInput -Is $Is | Should -BeFalse

      }

      It 'Should identify an Audio File Extension' {
        $Is = 'AudioFileExt'

        'AudioFile.wav' | Test-StringInput -Is $Is | Should -BeTrue
        'AudioFile.WAV' | Test-StringInput -Is $Is | Should -BeTrue
        'AudioFile.mp3' | Test-StringInput -Is $Is | Should -BeTrue
        'AudioFile.MP3' | Test-StringInput -Is $Is | Should -BeTrue
        'AudioFile.wma' | Test-StringInput -Is $Is | Should -BeTrue
        'AudioFile.WMA' | Test-StringInput -Is $Is | Should -BeTrue

        'C:\Temp\AudioFile with Space.mp3' | Test-StringInput -Is $Is | Should -BeTrue

        # Wrong Format
        'AudioFile.MP4' | Test-StringInput -Is $Is | Should -BeFalse
        'AudioFile.MOV' | Test-StringInput -Is $Is | Should -BeFalse
        'AudioFile.ogg' | Test-StringInput -Is $Is | Should -BeFalse

        # Wrong Type
        (New-Guid).Guid | Test-StringInput -Is $Is | Should -BeFalse
        'User@domain.com' | Test-StringInput -Is $Is | Should -BeFalse

      }

      It 'Should identify a ChannelGuid' {
        $Is = 'ChannelGuid'

        '19:abcdef1234567890abcdef1234567890@thread.tacv2' | Test-StringInput -Is $Is | Should -BeTrue
        '19:abcdef1234567890abcdef1234567890@thread.skype' | Test-StringInput -Is $Is | Should -BeTrue
        '19:abcdef1234567890abcdef1234567890@thread.a24bc' | Test-StringInput -Is $Is | Should -BeTrue

        # Wrong Type
        (New-Guid).Guid | Test-StringInput -Is $Is | Should -BeFalse
        'User@domain.com' | Test-StringInput -Is $Is | Should -BeFalse

        # Wrong prefix
        '29:abcdef1234567890abcdef1234567890@thread.tacv2' | Test-StringInput -Is $Is | Should -BeFalse
        # Wrong suffix
        #TEST this matches if in lower-case, need to get more samples to improve Regex pattern
        '19:abcdef1234567890abcdef1234567890@thread.TACv5' | Test-StringInput -Is $Is | Should -BeFalse
        # Wrong number of characters
        '19:abcd890abcdef1234567890@thread.tacv2' | Test-StringInput -Is $Is | Should -BeFalse
      }

      It 'Should identify a PhoneNumber' {
        $Is = 'PhoneNumber'

        '+1234' | Test-StringInput -Is $Is | Should -BeTrue
        '+234567890' | Test-StringInput -Is $Is | Should -BeTrue
        '+12345678901234567890' | Test-StringInput -Is $Is | Should -BeTrue
        'tel:+123456789011' | Test-StringInput -Is $Is | Should -BeTrue

        'tel:+123456789011;ext=1234' | Test-StringInput -Is $Is | Should -BeTrue
        '+3456789011;ext=987' | Test-StringInput -Is $Is | Should -BeTrue
        '+3456789011;ext=98765432' | Test-StringInput -Is $Is | Should -BeTrue

        '+123456789011' | Test-StringInput -Is $Is | Should -BeTrue
        '+123456789011' | Test-StringInput -Is $Is | Should -BeTrue
        '+123456789011' | Test-StringInput -Is $Is | Should -BeTrue

        # Extension too long
        '+3456789011;ext=987654321' | Test-StringInput -Is $Is | Should -BeFalse
        # Number too short
        '+123' | Test-StringInput -Is $Is | Should -BeFalse
        # Number too long
        '+123456789012345678901' | Test-StringInput -Is $Is | Should -BeFalse

      }

      It 'Should identify a Certificate Thumbprint' {
        $Is = 'Thumbprint'

        '5FB7EE0633E259DBAD0C4C9AE6D38F1A61C7DC25' | Test-StringInput -Is $Is | Should -BeTrue
        '5EEED86FA37C675230642F55C84DDBF67CD33C80' | Test-StringInput -Is $Is | Should -BeTrue
        '590D2D7D884F402E617EA562321765CF17D894E9' | Test-StringInput -Is $Is | Should -BeTrue
        '503006091D97D4F5AE39F7CBE7927D7D652D3431' | Test-StringInput -Is $Is | Should -BeTrue
        '4EFC31460C619ECAE59C1BCE2C008036D94C84B8' | Test-StringInput -Is $Is | Should -BeTrue
        '4EB6D578499B1CCF5F581EAD56BE3D9B6744A5E5' | Test-StringInput -Is $Is | Should -BeTrue
        '47BEABC922EAE80E78783462A79F45C254FDE68B' | Test-StringInput -Is $Is | Should -BeTrue
        '3679CA35668772304D30A5FB873B0FA77BB70D54' | Test-StringInput -Is $Is | Should -BeTrue
        '2B8F1B57330DBBA2D07A6C51F70EE90DDAB9AD8E' | Test-StringInput -Is $Is | Should -BeTrue
        '2796BAE63F1801E277261BA0D77770028F20EEE4' | Test-StringInput -Is $Is | Should -BeTrue

        # Wrong Type
        (New-Guid).Guid | Test-StringInput -Is $Is | Should -BeFalse
        'User@domain.com' | Test-StringInput -Is $Is | Should -BeFalse

        # Guid in disguise
        '8749dbcff5714b178d9209e8dd4171b8' | Test-StringInput -Is $Is | Should -BeFalse

        # Wrong character (G)
        '2796BAE63F1801E277261BA0D77770028F20EEEG' | Test-StringInput -Is $Is | Should -BeFalse
        # Too few Characters
        '2796BAE63F1801E277261BA0D77770028F20EEE' | Test-StringInput -Is $Is | Should -BeFalse
        # Too many Characters
        '2796BAE63F1801E277261BA0D77770028F20EEE4F3A3B2' | Test-StringInput -Is $Is | Should -BeFalse

      }

    }

  }
}
