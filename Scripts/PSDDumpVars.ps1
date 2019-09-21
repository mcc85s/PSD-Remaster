$VerbosePreference = "Continue"
$DeployRoot        = Split-Path -Path "$PSScriptRoot"
Import-Module "$DeployRoot\Scripts\PSDUtility.psm1" -Force

Dir TSenv: | Out-File "$( $env:SystemDrive )\DumpVars.log"
