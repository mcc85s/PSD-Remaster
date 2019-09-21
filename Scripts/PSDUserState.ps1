# // ***************************************************************************
# // 
# // PowerShell Deployment for MDT
# //
# // File:      PSDUserState.ps1
# // 
# // Purpose:   Start or continue a PSD task sequence.
# // 
# // 
# // ***************************************************************************

Param ( $Action )

# Load core modules
Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global
Import-Module PSDUtility

$verbosePreference = "Continue"

#Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Load core modules"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Load core modules"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Deployroot is now $( $tsenv:DeployRoot )"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): env:PSModulePath is now $env:PSModulePath"

# TODO Action response
#Write-Verbose -Message "$($MyInvocation.MyCommand.Name): TODO Action response $Action"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): TODO Action response $Action" 
