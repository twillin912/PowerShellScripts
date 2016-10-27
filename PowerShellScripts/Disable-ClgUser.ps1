function Disable-ClgUser {
    #Requires -Version 2.0
    #Requires -Module ActiveDirectory
    #Requires -Module ExchangeRemoting
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER Username
    .PARAMETER Firstname
    .PARAMETER Lastname
    .LINK
    .NOTES
    #>

    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName='ByUsername')]
        [string[]]$Username,

        [Parameter(ParameterSetName='ByDisplayName')]
        [string]$FirstName,

        [Parameter(ParameterSetName='ByDisplayName')]
        [string]$LastName,

        [Parameter()]
        [string]$ADServer = $env:LOGONSERVER,

        [Parameter()]
        [string]$ExchangeServer = 'MIEXMDB01'

    )

    Begin {
        $Sessions = Get-PSSession | Where-Object { $_.ComputerName -eq $ExchangeServer -and $_.ConfigurationName -eq 'Microsoft.Exchange' }
        If ( $Sessions ) {
            $ExchangeSession = $Sessions | Select-Object -First 1
        } else {
            $ExchangeSession = New-PSSession -ConfigurationName 'Microsoft.Exchange' -ConnectionUri "http://$($ExchangeServer)/PowerShell" -Authentication Kerberos
        }
        Import-PSSession -Session $ExchangeSession -AllowClobber -DisableNameChecking -Verbose:$false | Out-Null
    }

    Process {
        $FilterParams = @()
        If ( $Username ) {
            ForEach ( $Item in $Username ) {
                $FilterParams += "samAccountName -eq ""$Item"""
            }
            $FilterString = $FilterParams -join ' -or '
        }

        If ( $FirstName -or $LastName ) {
            If ( $FirstName ) {
                $FilterParams += "givenName -eq ""$FirstName"""
            }
            If ( $LastName ) {
                $FilterParams += "sn -eq ""$LastName"""
            }
            $FilterString = $FilterParams -join ' -and '
        }

        Write-Verbose -Message "Filter query string: '$FilterString'"

        Try {
            $UserAccounts = Get-ADUser -Filter $FilterString -ErrorAction Stop
        }
        Catch {
            Throw "Error querying Active Directory."
        }

        If ($UserAccounts.Count -eq 0 ) {
            Write-Warning -Message "Query filter '$FilterString' returned no results."
            Return            
        }

        Write-Host -Object "Disabling the following user accounts. Press 'Enter' to continue or 'Ctrl-C' to cancel." -ForegroundColor Yellow
        Write-Host -Object ($UserAccounts -join "`n")
        $Key = Read-Host
        If ( $Key ) {
            Write-Warning -Message "User aborted execution."
            Break
        }

        ForEach ( $Account in $UserAccounts ) {
            Write-Verbose "$($Account.Name): Disabling user account and updating description with disabled time."
            Disable-ADAccount -Identity $Account
            Set-ADUser -Identity $Account -Description "Account Disabled at $(Get-Date)"
            
            $GroupMembership = Get-ADPrincipalGroupMembership -Identity $Account | Where-Object { $_.name -ne 'Domain Users' }
            ForEach ( $Group in $GroupMembership ) {
                Write-Verbose "$($Account.Name): Removing membership from group '$($Group.Name)'"
                Remove-ADPrincipalGroupMembership -Identity $Account -MemberOf $Group -Confirm:$false
            }
            Try {
                #$MyErrorAction = $Global:ErrorActionPreference
                #$Global:ErrorActionPreference = 'Stop'
                $Mailbox = Get-Mailbox -Identity $($Account.DistinguishedName) -ErrorAction Stop
                If ( ($Mailbox | Measure-Object).Count -eq 1 ) {
                    Write-Verbose "$($Account.Name): Hidding mailbox from address list."
                    $Mailbox | Set-Mailbox -HiddenFromAddressListsEnabled $true -ErrorAction Stop -WhatIf
                }
            }
            Catch {
                Write-Warning -Message "No mailbox found for user '$($Account.Name)'." 
            }
            #$Global:ErrorActionPreference = $MyErrorAction
            Write-Verbose "$($Account.Name): Moving user account to 'Disabled Users' OU."
            Move-ADObject -Identity $Account -TargetPath 'OU=Disabled Users,OU=CLG,DC=CLG,DC=Local'
        }
    }

    End {
        #Remove-PSSession -Session $ExchangeSession
    }
}

Disable-ClgUser -Username LGarcia,virginiaholt -Verbose | FT
#Disable-ClgUser -FirstName Virginia -LastName Holt -Verbose | FT
