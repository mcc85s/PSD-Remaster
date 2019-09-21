# // ***************************************************************************
# // 
# // PowerShell Deployment for MDT
# //
# // File:      PSDGather.ps1
# // 
# // Purpose:   Update gathered information in the task sequence environment.
# // 
# // 
# // ***************************************************************************

Param ( )

# Load core module
Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global
Import-Module PSDUtility
Import-Module PSDGather

$VerbosePreference = "Continue"

#Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Load core module"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Load core modules"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Deployroot is now $( $TSenv:DeployRoot)"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): env:PSModulePath is now $Env:PSModulePath"

Write-PSDEvent -MessageID 41000 -severity 1 -Message "Starting: $( $MyInvocation.MyCommand.Name )"

# Gather local info to make sure key variables are set (e.g. Architecture)
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Gather local info to make sure key variables are set (e.g. Architecture)"
Get-PSDLocalInfo

# Save all the current variables for later use
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Save all the current variables for later use"
Save-PSDVariables
