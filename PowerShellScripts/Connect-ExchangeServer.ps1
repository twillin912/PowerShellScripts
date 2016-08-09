function Connect-ExchangeServer {
    <#
    .SYNOPSIS
        Use the Connect-ExchangeServer cmdlet to connect to the Exchange PowerShell web service.
    .PARAMETER Server
        Mandatory. The Server parameter specifies the name of the Exchange server running the PowerShell web services to connect to.
    .PARAMETER Credential
        Optional. The Credential paramater specifies alternative credentials to use to.  If this parameter is not specified the Connect-ExchangeServer cmdlet will connect with the current logged in user account.
    .EXAMPLE
        This example connects to the PowerShell web service on the Exchange server EXCH01 with your logged in user account.

        Connect-ExchangeServer -Server EXCH01
    .EXAMPLE
        This example connects to the PowerShell web service on the Exchange server EXCH01 with alternative credentials.

        Connect-ExchangeServer -Server EXCH01 -Credential (Get-Credential -Message 'Exchange Login')
    .LINK
        https://github.com/twillin912/PowerShellScripts
    .NOTES
        Author: Trent Willingham
        Check out my other scripts and projects @ https://github.com/twillin912

        Change Log
        v1.00   2016-08-09   Initial Release
    #>

    #requires -version 2
    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true)]
        [Alias('Identity','Name')]
        [string]$Server,

        [Parameter(Mandatory = $false)]
        [PSCredential]$Credential
    )

    Process {
        If ( $Credential ) {
            $Session = New-PSSession -ConfigurationName 'Microsoft.Exchange' -ConnectionUri "http://$($Server)/PowerShell" -Authentication Kerberos -Credential $($Credential)
        } else {
            $Session = New-PSSession -ConfigurationName 'Microsoft.Exchange' -ConnectionUri "http://$($Server)/PowerShell" -Authentication Kerberos
        }
        Import-PSSession -Session $Session
    }

}