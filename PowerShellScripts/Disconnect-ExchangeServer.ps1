function Disconnect-ExchangeServer {
    <#
    .SYNOPSIS
        Use the Disconnect-ExchangeServer cmdlet to disconnect from the Exchange PowerShell web service.
    .PARAMETER SessionName
        Optional. The name of the powershell session connected to the Exchange web service.  By default the session name will be 'RemoteExchange'
    .EXAMPLE
        This example disconnects from the default PowerShell web service session.

        Disconnect-ExchangeServer
    .LINK
        https://github.com/twillin912/PowerShellScripts
    .NOTES
        Author: Trent Willingham
        Check out my other scripts and projects @ https://github.com/twillin912

        Change Log
        v1.00   2016-10-06   Initial Release
    #>

    #requires -version 2
    [CmdletBinding()]
    Param (
        [Alias('Identity')]
        [string]$SessionName = 'RemoteExchange'
    )

    Process {
        Try {
            $Null = Get-PSSession -Name $SessionName -ErrorAction Stop
        }
        Catch {
            Write-Warning -Message "Session '$SessionName' not found."
            Break
        }
        Remove-PSSession -Name $SessionName
    }

}