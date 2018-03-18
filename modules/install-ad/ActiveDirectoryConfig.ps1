Configuration ActiveDirectoryConfig
{

    param
    (
        [Parameter(Mandatory)]
        [pscredential]$safemodeAdministratorCred,

        [Parameter(Mandatory)]
        [pscredential]$domainCred,

        [Parameter(Mandatory)]
        [pscredential]$NewADUserCred
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory

    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename
    {
        LocalConfigurationManager
        {
            ActionAfterReboot = 'StopConfiguration'
            ConfigurationMode = 'ApplyOnly'
        }
        
        WindowsFeature ADDSInstall {
            Ensure = "Present"
            Name   = "AD-Domain-Services"
        }

        WindowsFeature ADDSTools {
            Ensure = "Present"
            Name = "RSAT-ADDS"
        }

        xADDomain FirstDS
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DependsOn                     = "[WindowsFeature]ADDSInstall"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName           = $Node.DomainName
            DomainUserCredential = $domainCred
            RetryCount           = $Node.RetryCount
            RetryIntervalSec     = $Node.RetryIntervalSec
            DependsOn            = "[xADDomain]FirstDS"
        }

        xADUser FirstUser
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            UserName                      = "dummy"
            Password                      = $NewADUserCred
            Ensure                        = "Present"
            DependsOn                     = "[xWaitForADDomain]DscForestWait"
        }

    }
}

# Configuration Data for AD

$ConfigData = @{
    AllNodes = @(
        @{
            Nodename         = "localhost"
            Role             = "Primary DC"
            DomainName       = "auth.local"
            RetryCount       = 20
            RetryIntervalSec = 30
            PsDscAllowPlainTextPassword = $true
        }
    )
}

function Create-Credential {
    param([string]$UserName,
        [string]$Password)

    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    return New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $UserName, $SecurePassword
}

$SafeModeCredential = Create-Credential -UserName $Env:SAFEMODEADMINISTRATORUSER -Password $Env:SAFEMODEADMINISTRATORPASSWORD
$DomainCredential = Create-Credential -UserName $Env:DOMAINADMIN -Password $Env:DOMAINPASSWORD
$NewAdUserCredential = Create-Credential -UserName $Env:NEWADUSER -Password $Env:NEWADUSERPASSWORD

ActiveDirectoryConfig -configurationData $ConfigData `
    -safemodeAdministratorCred $SafeModeCredential `
    -domainCred $DomainCredential  `
    -NewADUserCred $NewAdUserCredential

Set-DSCLocalConfigurationManager -Verbose -Path .\ActiveDirectoryConfig

Start-DscConfiguration -Wait -Force -Verbose -Path .\ActiveDirectoryConfig
