<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: PSDApplyOS.ps1
          Solution: PowerShell Deployment for MDT
          Purpose: Apply the specified operating system.
          Author: PSD Development Team
          Contact: @Mikael_Nystrom , @jarwidmark , @mniehaus , @SoupAtWork , @JordanTheItGuy
          Primary: @Mikael_Nystrom 
          Created: 
          Modified: 2019-05-09

          Version - 0.0.0 - () - Finalized functional version 1.
          Version - 0.1.0 - (2019-05-09) - Check access to image file
          Version - 0.1.1 - (2019-05-09) - Cleanup white space

          TODO:

.Example
#>

    Param ( )

    # Load core modules
    Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global # <- This thing is still encrypted...
    Import-Module DISM
    Import-Module PSDUtility
    Import-Module PSDDeploymentShare

    $VerbosePreference = "Continue"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Load core modules"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Deployroot is now $( $TSenv:DeployRoot )"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): env:PSModulePath is now $Env:PSModulePath"

    # Make sure we run at full power [ MC @ Heroes in a half shell... Turtle Power. ]
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Make sure we run at full power"
    & powercfg.exe /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

    # Get the OS image details
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Get the OS image details"
    
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Operating system: $( $TSenv:OSGUID )"

    $OS = Get-Item "DeploymentShare:\Operating Systems\$( $TSenv:OSGUID )"
    $OSSource = Get-PSDContent "$( $OS.Source.Substring( 2 ) )"
    $Image = "$OSSource$($OS.ImageFile.Substring( $OS.Source.Length ) )"
    $Index = $OS.ImageIndex

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : os is now $OS"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : osSource is now $OSSource"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : image is now $Image"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : index is now $Index"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Verifying access to $Image"
    
    If ( ( Test-Path -Path $Image ) -ne $True )
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Unable to continue, could not access the WIM $Image"
    
        Show-PSDInfo -Message "Unable to continue, could not access the WIM $image" -Severity Error
        Exit 1
}

    # Create a local scratch folder
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Create a local scratch folder"
    
    $ScratchPath = "$( Get-PSDLocalDataPath )\Scratch"
    
    Initialize-PSDFolder $ScratchPath

    # Apply the image
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Apply the image"
    
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Applying image $Image index $Index to $( $TSenv:OSVolume )"
    
    $StartTime = Get-Date
    
    Expand-WindowsImage -ImagePath $Image -Index $Index -ApplyPath "$( $TSenv:OSVolume):\" -ScratchDirectory $ScratchPath
    
    $Duration = $( Get-Date ) - $StartTime

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Time to apply image: $( $Duration.ToString( 'hh\:mm\:ss' ) )"

    ###############################################################################################################################################################
    # Inject drivers using DISM if Setup.exe is missing
    #$ImageFolder = $image | Split-Path | Split-Path
    #Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Checking if Setup.exe is present in $ImageFolder"
    #if(!(Test-Path -Path "$ImageFolder\Setup.exe"))
    #{
    #    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Could not find Setup.exe, applying Unattend.xml (Use-WindowsUnattend)"
    #    if(Test-Path -Path "$($tsenv:OSVolume):\Windows\Panther\Unattend.xml")
    #    {
    #        Use-WindowsUnattend -Path "$($tsenv:OSVolume):\" -UnattendPath "$($tsenv:OSVolume):\Windows\Panther\Unattend.xml" -ScratchDirectory $scratchPath
    #    }
    #    else
    #    {
    #        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Could not $($tsenv:OSVolume):\Windows\Panther\Unattend.xml"
    #    }
    #    
    #}
    #else
    #{
    #    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Found Setup.exe, no need to apply Unattend.xml"
    #}
    ###############################################################################################################################################################

    # Make the OS bootable
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Make the OS bootable"
    
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Configuring volume $( $TSenv:BootVolume ) to boot $( $TSenv:OSVolume ):\Windows."

    If ( $TSenv:IsUEFI -eq "True" )
    {
        $args = @( "$( $TSenv:OSVolume ):\Windows" , "/s" , "$( $TSenv:BootVolume ):" , "/f" , "uefi" )
    }
    
    Else 
    {
        $Args = @( "$( $Tsenv:OSVolume ):\Windows" , "/s" , "$( $TSenv:BootVolume ):")
    }

    #Added for troubleshooting (admminy)
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Running bcdboot.exe with the following arguments: $Args"

    $Result = Start-Process -FilePath "bcdboot.exe" -Args $args -Wait -Passthru
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : BCDBoot completed, rc = $( $result.ExitCode )"

    # Fix the EFI partition type
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Fix the EFI partition type if using UEFI"
    If ( $TSenv:IsUEFI -eq "True" )
    {
	    # Fix the EFI partition type
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Fix the EFI partition type"
	    @"
select volume $( $tsenv:BootVolume )
set id=c12a7328-f81f-11d2-ba4b-00a0c93ec93b
exit
"@ | diskpart
}

    # Fix the recovery partition type for MBR disks, using diskpart.exe since the PowerShell cmdlets are currently missing some options (like ID for MBR disks)
    If ( $TSenv:IsUEFI -eq "False" )
    {
        # Fix the recovery partition type 
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Fix the recovery partition type"
@"
select volume $( $tsenv:RecoveryVolume )
set id=27 override
exit
"@ | diskpart
}

