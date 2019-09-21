#PSD Helper
Param ( $MDTDeploySharePath , $UserName , $Password )

#Connect
& Net Use $MDTDeploySharePath $Password /USER:$UserName

# Set the module path based on the current script path
      $DeployRoot = Split-Path -Path "$PSScriptRoot"
$Env:PSModulePath = "$Env:PSModulePath;$DeployRoot\Tools\Modules"

#Import Env
Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global -Force -Verbose # <- This thing is still encrypted
Import-Module PSDUtility -Force -Verbose
Import-Module PSDDeploymentShare -Force -Verbose
Import-Module PSDGather -Force -Verbose

Dir TSenv: | Out-File "$( $Env:SystemDrive )\DumpVars.log"
Get-Content -Path "$( $Env:SystemDrive )\DumpVars.log"

