<#
    .DESCRIPTION
    Creates a report about patches included in a Software Update Group.  
    Pre-Requisites:
        Configuration Manager Admin Service
        Microsoft Security Update API Access
    
    .PARAMETER ApiKey
    [string] - API Key for Microsoft Security Update API

    .PARAMETER SmsProviderFqdn
    [string] - URI for the Configuration Manager Admin Service
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true,Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey = '7efd581e8681469d92b95ed89d57df46',
    [Parameter(Mandatory=$true,Position=1)]
    [ValidateNotNullOrEmpty()]
    [string]$SmsProviderFqdn
)

