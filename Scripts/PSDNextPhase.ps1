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
#\\ - - [ PXD-NextPhase ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# The following script is newly formatted and contains slight alterations or adjustments made by the aforementioned auth.
# Although I am nowhere close to complete, I have given these scripts my full attention in attempting to optimize them.
# There are definitely many issues that I have noticed, but making mistakes is part of life. Learning from them, and
# making the effort to correct them is what matters the most. Comments, questions, mcook@securedigitsplus.com

# // ***************************************************************************
# // 
# // PowerShell Deployment for MDT
# //
# // File:      PSDNextPhase.ps1
# // 
# // Purpose:   Next PHASE
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
: Deployroot is now $($tsenv:DeployRoot)"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: env:PSModulePath is now $env:PSModulePath"

#Next Phase
$PHASE = $tsenv:PHASE
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Current Phase is $PHASE"

Switch ( $PHASE )
{
    INITIALIZATION { $PHASE =   "VALIDATION" }
    VALIDATION     { $PHASE = "STATECAPTURE" }
    STATECAPTURE   { $PHASE =   "PREINSTALL" }
    PREINSTALL     { $PHASE =      "INSTALL" }
    INSTALL        { $PHASE =  "POSTINSTALL" }
    POSTINSTALL    { $PHASE = "STATERESTORE" }
    STATERESTORE   { $PHASE =             "" }
}

$tsenv:PHASE = $Phase

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: --------------------"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: Next Phase is $PHASE"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: Save all the current variables for later use"

Save-PSDVariables
