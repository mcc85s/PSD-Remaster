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
#\\ - - [ PXD-Drivers ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# The following script is newly formatted and contains slight alterations or adjustments made by the aforementioned auth.
# Although I am nowhere close to complete, I have given these scripts my full attention in attempting to optimize them.
# There are definitely many issues that I have noticed, but making mistakes is part of life. Learning from them, and
# making the effort to correct them is what matters the most. Comments, questions, mcook@securedigitsplus.com

<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: PSDDrivers.ps1
          Solution: PowerShell Deployment for MDT
          Purpose: Download and install drivers
          Author: PSD Development Team
          Contact: @Mikael_Nystrom , @jarwidmark , @mniehaus , @SoupAtWork , @JordanTheItGuy
          Primary: @Mikael_Nystrom 
          Created: 
          Modified: 2019-05-09

          Version - 0.0.0 - () - Finalized functional version 1.

          TODO:
          Add support for PNP

.Example
#>

Param ( )

# Load core modules
Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global
Import-Module DISM
Import-Module PSDUtility
Import-Module PSDDeploymentShare

$VerbosePreference = "Continue"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: Load core modules"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: Deployroot is now $( $TSenv:DeployRoot )"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: env:PSModulePath is now $Env:PSModulePath"

# Building source and destionation paths based on model DriverGroup001
         $BaseDriverPath = "DriverPackages"
                $Drivers = ( ( $tsenv:DriverGroup001 ).Replace( "\" , " - " ) ).Replace( " " , "_" )
$SourceDriverPackagePath = "$BaseDriverPath\$Drivers"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: tsenv:DriverGroup001 is $( $tsenv:DriverGroup001 )"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: SourceDriverPackagePath is now $SourceDriverPackagePath"

#Copy drivers to cache
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: Copy $SourceDriverPackagePath to cache "

Get-PSDContent -content $SourceDriverPackagePath

#Get all ZIP files from the cache
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: Getting drivers..."

$Zips = gci -Path "$( $TSenv:OSVolume ):\MININT\Cache\DriverPackages" -Filter *.zip -Recurse

#Did we find any?
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Found $( $Zips.Count ) packages"
ForEach ( $Zip in $Zips )
{
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Unpacking $( $Zip.FullName )"

    # Need to use this method, since the assemblys can not be loaded due to a issue... ( MC ) It's probably the encoding
    Start PowerShell -Args "Expand-Archive -Path $( $Zip.FullName ) -DestinationPath $( $TSenv:OSVolume ):\Drivers -Force -Verbose" -Wait
}

Start-Sleep -Seconds 1

# What do we have here
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
: Get list of drivers from \Drivers"

$Drivers = gci -Path "$( $TSenv:OSVolume ):\Drivers" -Filter *.inf -Recurse

ForEach ( $Driver in $Drivers )
{
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : $( $Driver.Name ) is now in the \Drivers folder"
    $TSxDriverInfo = Get-PSDDriverInfo -Path $Driver.FullName
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Driverinfo:`
       Name:$(              $TSxDriverInfo.Name )  
     Vendor:$(      $TSxDriverInfo.Manufacturer )  
      Class:$(             $TSxDriverInfo.Class )  
       Date:$(              $TSxDriverInfo.Date )  
    Version:$(           $TSxDriverInfo.Version )"
}
