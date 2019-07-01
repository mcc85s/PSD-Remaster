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
#\\ - - [ PXD-SetVariable ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# The following script is newly formatted and contains slight alterations or adjustments made by the aforementioned auth.
# Although I am nowhere close to complete, I have given these scripts my full attention in attempting to optimize them.
# There are definitely many issues that I have noticed, but making mistakes is part of life. Learning from them, and
# making the effort to correct them is what matters the most. Comments, questions, mcook@securedigitsplus.com

# // ***************************************************************************
# // 
# // PowerShell Deployment for MDT
# //
# // File:      PSDSetVariables.ps1
# // 
# // Purpose:   Set variable
# // 
# // 
# // ***************************************************************************

Param ( )

# Load core modules
Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global
Import-Module PSDUtility

$VerbosePreference = "Continue"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: Load core modules"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: Deployroot is now $( $TSenv:DeployRoot )"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: env:PSModulePath is now $Env:PSModulePath"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: TSEnv:VariableName is now $TSEnv:VariableName"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: TSEnv:VariableValue is now $TSEnv:VariableValue"

 $VariableName = $TSEnv:VariableName
$VariableValue = $TSEnv:VariableValue
New-Item -Path TSEnv: -Name "$VariableName" -Value "$VariableValue" -Force

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: $VariableName is now $( ( gci -Path TSEnv: | ? Name -Like $VariableName ).Value )"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: Save all the current variables for later use"
Save-PSDVariables

BREAK
<#
<variable name="VariableName" property="VariableName">DriverGroup001</variable>
<variable name="VariableValue" property="VariableValue">Client\Windows 10 1709\%model%</variable>
oEnvironment.Item(oEnvironment.Item("VariableName")) = oEnvironment.Item("VariableValue")
$tsenv:DeployRoot

powershell.exe -executionpolicy bypass -command "& {$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment; $tsenv.Value('ImageVersion') = get-date -uformat %m%d%Y}"

#>

