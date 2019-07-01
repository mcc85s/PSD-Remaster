#\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
#// /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ \\#
#\\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ //#
#// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
#\\                                                                                                                   //#
#//   <@[ Script-Initialization ]@>                        "Script Magistration by Michael C. 'Boss Mode' Cook Sr."   \\#
#\\                                                                                                                   //#
#//                        [ Secure Digits Plus LLC | Hybrid ] [ Desired State Controller ]                           \\#
#\\                                                                                                                   //#
#//                  [ https://www.securedigitsplus.com | Server/Client | Seedling/Spawning Script ]                  \\#
#\\                                                                                                                   //#
#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ - - [ PXD-Validate ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# The following script is newly formatted and contains slight alterations or adjustments made by the aforementioned auth.
# Although I am nowhere close to complete, I have given these scripts my full attention in attempting to optimize them.
# There are definitely many issues that I have noticed, but making mistakes is part of life. Learning from them, and
# making the effort to correct them is what matters the most. Comments, questions, mcook@securedigitsplus.com

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

# Load core modules
Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global
Import-Module PSDUtility
Import-Module PSDDeploymentShare

$verbosePreference = "Continue"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: Load core modules"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: Deployroot is now $( $tsenv:DeployRoot )"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: env:PSModulePath is now $env:PSModulePath"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: tsenv:ImageSize $( $tsenv:ImageSize )"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: tsenv:ImageProcessorSpeed $( $tsenv:ImageProcessorSpeed )"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: tsenv:ImageMemory $( $tsenv:ImageMemory )"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name)
: tsenv:VerifyOS $( $tsenv:VerifyOS )"

<#
    '//----------------------------------------------------------------------------
    '//  Abort if this is a server OS
    '//----------------------------------------------------------------------------
#>

If ( $TSEnv:DeploymentType -eq "REFRESH" )
{
	If ( $TSEnv:VerifyOS -eq "CLIENT" )
    {
		If ( $TSEnv:IsServerOS -eq "TRUE" )
        {
            $Message = "ERROR - Attempting to deploy a client operating system to a machine running a server operating system."
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): $Message" -LogLevel 3
            Show-PSDInfo -Message $Message  -Severity Error
            Start-Process PowerShell -Wait
            Break
        }
    }

	If ( $TSEnv:VerifyOS -eq "SERVER" )
    {
		If ( $TSEnv:IsServerOS -eq "FALSE" )
        {
            $Message = "ERROR - Attempting to deploy a server operating system to a machine running a client operating system."
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): $Message" -LogLevel 3
            Show-PSDInfo -Message $Message  -Severity Error
            Start-Process PowerShell -Wait
            Break
        }
    }
}

<#
	'//----------------------------------------------------------------------------
	'//  Abort if "OSInstall" flag is set to something other than Y or YES
	'//----------------------------------------------------------------------------
#>

    If ( $TSEnv:OSInstall -eq "Y" -or "YES" )
    {
        $Message = "OSInstall flag is $TSEnv:OSInstall , install is allowed."
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): $Message" -LogLevel 1
    }

    Else
    {
        $Message = "OSInstall flag is NOT set to Y or YES, abort."
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): $Message" -LogLevel 3
        Show-PSDInfo -Message $Message -Severity Error
        Start-Process PowerShell -Wait
        Break
    }


Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Save all the current variables for later use"
Save-PSDVariables
