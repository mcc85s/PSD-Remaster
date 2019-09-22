# // ***************************************************************************
# // 
# // PowerShell Deployment for MDT
# //
# // File:      PSDApplications.ps1
# // 
# // Purpose:   Installs the apps specified in task sequence variables 
# //            Applications and MandatoryApplications.
# // 
# // ***************************************************************************

Param ( )

# Load core modules
Import-Module PSDUtility
Import-Module PSDDeploymentShare

$VerbosePreference = "Continue"

#Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Load core modules"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Load core modules"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Deployroot is now $( $TSenv:DeployRoot)"

Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): env:PSModulePath is now $Env:PSModulePath"

# Internal functions

# Function to install a specified app
Function Install-PSDApplication
{
    Param ( [ Parameter ( Mandatory = $True , ValueFromPipeline = $True ) ] [ String ] $ID )

    # Make sure we access to the application folder
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Make sure we access to the application folder"

    $Apps = "DeploymentShare:\Applications"
    If ( ( Test-Path $apps ) -ne $true)
    {   
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): no access to $Apps , skipping."
        Return 0
    }

    # Make sure the app exists
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Make sure the app exists $Apps\$ID"
    If ( ( Test-Path "$Apps\$id") -ne $true)
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Unable to find application $id, skipping."
        Return 0
    }

    # Get the app
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Get the app"
    $App = gi "$Apps\$id"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Processing :$( $App.Name )"

    # Process dependencies (recursive)
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Process dependencies (recursive)"
    If ( $App.Dependency.Count -ne 0 )
    {
        $App.Dependency | Install-PSDApplication
    }

    # Check if the app has been installed already
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Check if the app has been installed already"

    $AlreadyInstalled = @()
    $AlreadyInstalled = @( ( gi tsenvlist:InstalledApplications).Value)
               $Found = $False
    $AlreadyInstalled | ? { $_ -eq $ID } | % { $Found = $True }
    If ( $Found )
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Application $( $App.Name ) is already installed, skipping."
        Return
    } 

    # TODO: Check supported platforms
    # Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    # TODO: Check supported platforms"  / ( MC ) If you're a tool, you'll write that...

    # TODO: Check for uninstall string
    # Write-Verbose "$($MyInvocation.MyCommand.Name): TODO: Check for uninstall string"
    # Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: Check for uninstall string"
    # ( MC ) That's easy. 

    ## [ Written by MC ] #############################################################################
    #
    #$Path = "" , "\WOW6432Node" | % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall" }
    #if ( $Architecture -eq "x86" )  { $Reg = gp "$( $Path[0] )\*"                                   }
    #else                            { $Reg = $Path | % { gp "$_\*" }                                }

    #$Objects = "DisplayName" , "InstallSource" , "UninstallString"

    #$Filter = [ Ordered ] `
    #@{  MSI = ( $Reg | ? { $_.UninstallString    -like "*MsiExec.exe*" } | Select-Object $Objects )
    #    WMI = ( $Reg | ? { $_.UninstallString -notlike "*MsiExec.exe*" } | Select-Object $Objects ) }
    #
    ## [ Written by MC ] Thought you guys were pros.... Everything from here down is pretty dumb. ####
    ## Update 9/21/2019 @ MC - Gee... I seem to have a way with words don't I? It's not dumb. ^ I was just being obnoxious.

    ### /// ( MC stopped here )

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Set the working directory"
    $workingDir = ""
    If ( $App.WorkingDirectory -ne "" -and $App.WorkingDirectory -ne "." )
    {
        If ( $App.WorkingDirectory -like ".\*" )
        {
            # App content is on the deployment share, get it
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): App content is on the deployment share, get it"
            $AppContent = Get-PSDContent -Content "$( $App.WorkingDirectory.Substring( 2 ) )"
            $WorkingDir = $AppContent
        }

        Else
        {
            $workingDir = $app.WorkingDirectory
        }
    }

    # Install the app
    #Write-Verbose "$($MyInvocation.MyCommand.Name): Install the app"
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Install the app"

    if ($app.CommandLine -eq "")
    {
        #Write-Verbose "$($MyInvocation.MyCommand.Name): No command line specified (bundle)."
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): No command line specified (bundle)."
    }
    elseif ($app.CommandLine -ilike "install-package *")
    {
        Invoke-Expression $($app.CommandLine)
    }
    elseif ($app.CommandLine -icontains ".appx" -or $app.CommandLine -icontains ".appxbundle")
    {
        # TODO: Process modern app
        #Write-Verbose "$($MyInvocation.MyCommand.Name): TODO: Process modern app"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: Process modern app"
    }
    else
    {
        $cmd = $app.CommandLine
        # TODO: Substitute
        #Write-Verbose "$($MyInvocation.MyCommand.Name): TODO: Substitute"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: Substitute"
        #Write-Verbose "$($MyInvocation.MyCommand.Name): About to run: $cmd"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): About to run: $cmd"
        if ($workingDir -eq "")
        {
            $result = Start-Process -FilePath "$toolRoot\bddrun.exe" -ArgumentList $cmd -Wait -Passthru
        }
        else
        {
            #Write-Verbose "$($MyInvocation.MyCommand.Name): Setting working directory to $workingDir"
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Setting working directory to $workingDir"
            $result = Start-Process -FilePath "$toolRoot\bddrun.exe" -ArgumentList $cmd -WorkingDirectory $workingDir -Wait -Passthru
        }
        # TODO: Check return codes
        #Write-Verbose "$($MyInvocation.MyCommand.Name): TODO: Check return codes"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): TODO: Check return codes"
        #Write-Verbose "$($MyInvocation.MyCommand.Name): Application $($app.Name) return code = $($result.ExitCode)"
        Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Application $($app.Name) return code = $($result.ExitCode)"
    }

    # Update list of installed apps
    #Write-Verbose "$($MyInvocation.MyCommand.Name): Update list of installed apps"
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Update list of installed apps"
    $alreadyInstalled += $id
    $tsenvlist:InstalledApplications = $alreadyInstalled

    # Reboot if specified
    #Write-Verbose "$($MyInvocation.MyCommand.Name): Reboot if specified"
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Reboot if specified"
    if ($app.Reboot -ieq "TRUE")
    {
        return 3010
    }
    else
    {
        return 0
    }
}


# Main code
#Write-Verbose "$($MyInvocation.MyCommand.Name): Main code"
Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Main code"

# Get tools
#Write-Verbose "$($MyInvocation.MyCommand.Name): Get tools"
Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Get tools"
$toolRoot = Get-PSDContent "Tools\$($tsenv:Architecture)"


# Single application install initiated by a Task Sequence action
# Note: The ApplicationGUID variable isnt set globally. Its set only within the scope of the Install Application action/step. One of the hidden mysteries of the task sequence engine :)

Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Checking for single application install step"
If ($tsenv:ApplicationGUID -ne "") {
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Mandatory Single Application install indicated. Guid is $($tsenv:ApplicationGUID)"
    Install-PSDApplication $tsenv:ApplicationGUID
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Mandatory Single Application installed, exiting application step"
    Exit
}
else
{
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): No Single Application install found. Continue with checking for dynamic applications"
}
			

# Process applications
#Write-Verbose "$($MyInvocation.MyCommand.Name): Process applications"
Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Process applications"
if ($tsenvlist:MandatoryApplications.Count -ne 0)
{
    #Write-Verbose "$($MyInvocation.MyCommand.Name): Processing $($tsenvlist:MandatoryApplications.Count) mandatory applications."
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Processing $($tsenvlist:MandatoryApplications.Count) mandatory applications."
    $tsenvlist:MandatoryApplications | Install-PSDApplication
}
else
{
    #Write-Verbose "$($MyInvocation.MyCommand.Name): No mandatory applications specified."
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): No mandatory applications specified."
}

if ($tsenvlist:Applications.Count -ne 0)
{
    #Write-Verbose "$($MyInvocation.MyCommand.Name): Processing $($tsenvlist:Applications.Count) applications."
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Processing $($tsenvlist:Applications.Count) applications."
    $tsenvlist:Applications | % { Install-PSDApplication $_ }
}
else
{
    #Write-Verbose "$($MyInvocation.MyCommand.Name): No applications specified."
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): No applications specified."
}
