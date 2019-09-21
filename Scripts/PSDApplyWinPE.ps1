# // ***************************************************************************
# // 
# // PowerShell Deployment for MDT
# //
# // File:      PSDTemplate.ps1
# // 
# // Purpose:   Apply the specified operating system.
# // 
# // 
# // ***************************************************************************

Param ( )

# Load Core Modules

Import-Module PSDUtility
Import-Module PSDDeploymentShare

$VerbosePreference = "Continue"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Load core modules"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Deployroot is now $DeployRoot"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): env:PSModulePath is now $Env:PSModulePath"
