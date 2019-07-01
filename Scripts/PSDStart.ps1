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
#\\ - - [ PXD-Start ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# The following script is newly formatted and contains slight alterations or adjustments made by the aforementioned auth.
# Although I am nowhere close to complete, I have given these scripts my full attention in attempting to optimize them.
# There are definitely many issues that I have noticed, but making mistakes is part of life. Learning from them, and
# making the effort to correct them is what matters the most. Comments, questions, mcook@securedigitsplus.com

# // ***************************************************************************
# // 
# // PowerShell Deployment for MDT
# //
# // File:      PSDStart.ps1
# // 
# // Purpose:   Start or continue a PSD task sequence.
# // 
# // 
# // Version 9.1 - Added check for network access when doing network deployment
# // Version 9.2 - Check that needed files are in WinPE for XAML files to show correctly
# //               Logic for detection if running in WinPE
# //               Check for unsupported variables
# // ***************************************************************************

    Param ( [ Switch ] $Start , [ Switch ] $PSDDeBug )

    #Check for PSDDeBug
    If ( $PSDDeBug -eq $True )
    {
        $VerbosePreference = "Continue"
        Write-Verbose "verbosePreference is now $VerbosePreference"
    }

    # Set the module path based on the current script path
    $DeployRoot       = Split-Path -Path "$PSScriptRoot"
    $Env:PSModulePath = "$Env:PSModulePath;$DeployRoot\Tools\Modules"

    # Verify the module path based on the current script path
    If ( $PSDDeBug -eq $true )
    {
        $VerbosePreference = "Continue"
        Write-Verbose $DeployRoot
        Write-Verbose $PSScriptRoot
        Write-Verbose $Env:PSModulePath
    }

    #Check if we booted from WinPE
    $BootfromWinPE = $false
    If ( $Env:SYSTEMDRIVE -eq "X:" )
    {
        $BootfromWinPE = $True
    }

    If ( $PSDDeBug -eq $True )
    {
        Write-Verbose "BootfromWinPE is now $BootfromWinPE"
    }

    # Load core module
    Import-Module PSDUtility -Force

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : --------------------"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Beginning initial process in PSDStart.ps1"

    # Set Command Window size
    # Reason for 99 is that 99 seems to use the screen in the best possible way, 100 is just one pixel to much
    Set-PSDCommandWindowsSize -Width 99 -Height 15

    If ( $BootfromWinPE -eq $True )
    {

        # Windows ADK v1809 could be missing certain files, we need to check for that.
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Check if we are running Windows ADK 10 v1809"
    
        If ( $( gwmi Win32_OperatingSystem ).BuildNumber -eq "17763" )
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Check for BCP47Langs.dll and BCP47mrm.dll, needed for WPF"

            "BCP47Langs.dll" , "BCP47mrm.dll" | % `
            {
                If ( ! ( Test-Path -Path "X:\Windows\System32\$_" ) )
                {
                    Start-Process PowerShell -Args {
                    "Write-warning -Message 'We are missing the BCP47Langs.dll and BCP47mrm.dll files required for WinPE 1809.';
                    Write-warning -Message 'Please check the PSD documentation on how to add those files.';
                    Write-warning -Message 'Critical error, deployment can not continue..';Pause"
                    } -Wait
                Exit 1
                }
            }
        }

        # We need more than 1.5 GB (Testing for at least 1499MB of RAM)
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Check for minimum amount of memory in WinPE to run PSD"
    
        If ( ( gwmi Win32_ComputerSystem ).TotalPhysicalMemory -le 1499MB )
        {
            Show-PSDInfo -Message "Not enough memory to run PSD, aborting..." -Severity Error
            Start-Process PowerShell -Wait
            Exit 1
        }

        # All tests succeded, log that info
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Completed WinPE prerequisite checks"
    }

    Import-Module PSDDeploymentShare -Force -EA 4
    Import-Module PSDGather          -Force -EA 4
    Import-Module PSDWizard          -Force -EA 4

    $verbosePreference = "Continue"

    #Check if tsenv: works
    Try
    {
        gci -Path "TSEnv:"
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Able to read from TSEnv"
    }

    Catch
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Unable to read from TSEnv"
        #Break
    }

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Load core modules"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Deployroot is now $DeployRoot"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : env:PSModulePath is now $Env:PSModulePath"

    # If running from RunOnce, create a startup folder item and then exit
    If ( $Start )
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Creating a link to re-run $PSCommandPath from the all users Startup folder"

        # Create a shortcut to run this script
            $AllUsersStartup =           [ Environment ]::GetFolderPath( 'CommonStartup' )
                   $LinkPath =                         "$AllUsersStartup\PSDStartup.lnk"
                   $WSHShell =                      New-Object -COMObject WScript.Shell
                   $Shortcut =                      $WshShell.CreateShortcut( $linkPath )
        $Shortcut.TargetPath =                                          "powershell.exe"
         $Shortcut.Arguments = "-noprofile -executionpolicy bypass -file $PSCommandPath"
        $Shortcut.Save()
        Exit 0
    }

    # Gather local info to make sure key variables are set (e.g. Architecture)
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : About to run Get-PSDLocalInfo"

    Get-PSDLocalInfo
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Deployroot is now $deployRoot"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : env:PSModulePath is now $env:PSModulePath"
    
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : --------------------"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Checking if there is an in-progress task sequence"

    # Check for an in-progress task sequence
    $TSInProgress = $false
    Get-Volume `
    | ? {       -not [ String ]::IsNullOrWhiteSpace( $_.DriveLetter ) } `
    | ? {                                    $_.DriveType -eq 'Fixed' } `
    | ? {                                  $_.DriveLetter -ne     'X' } `
    | ? { Test-Path "$( $_.DriveLetter ):\_SMSTaskSequence\TSEnv.dat" } `
    | % {

        # Found it, save the location
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : In-progress task sequence found at $( $_.DriveLetter ):\_SMSTaskSequence"
        $TSInProgress = $True
             $TSDrive = $_.DriveLetter

        # Restore the task sequence variables
        $VariablesPath = Restore-PSDVariables
        Try
        {

            Foreach ( $i in ( gci -Path TSEnv: ) )
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : Property $( $i.Name ) is $( $i.Value )"
            }
        }

        Catch
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Unable to restore variables from $VariablesPath."
            Show-PSDInfo -Message "Unable to restore variables from $VariablesPath." -Severity Error
            Start-Process PowerShell -Wait
            Exit 1
        }

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Restored variables from $variablesPath."

        # Reconnect to the deployment share
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Reconnecting to the deployment share at $( $tsenv:DeployRoot )."

        If ( $tsenv:UserDomain -ne "" )
        {
            Get-PSDConnection -DeployRoot $tsenv:DeployRoot -UserName "$( $tsenv:UserDomain )\$( $tsenv:UserID )" -Password $TSenv:UserPassword
        }
        
        Else
        {
            Get-PSDConnection -DeployRoot $TSenv:DeployRoot -UserName $TSenv:UserID -Password $TSenv:UserPassword
        }
    }

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : --------------------"
    
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : If a task sequence is in progress, resume it. Otherwise, start a new one"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Deployroot is now $DeployRoot"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : env:PSModulePath is now $Env:PSModulePath"

    # If a task sequence is in progress, resume it.  Otherwise, start a new one
    [ Environment ]::CurrentDirectory = "$( $env:WINDIR )\System32"
    If ( $TSInProgress )
    {
        # Find the task sequence engine
        If ( Test-Path -Path "X:\Deploy\Tools\$( $TSenv:Architecture )\tsmbootstrap.exe" )
        {
            $tsEngine = "X:\Deploy\Tools\$( $tsenv:Architecture )"
        }
        
        Else
        {
            $tsEngine = Get-PSDContent "Tools\$( $tsenv:Architecture )"
        }
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Task sequence engine located at $TSEngine."

        # Get full scripts location
                  $Scripts = Get-PSDContent -Content "Scripts"
           $Env:ScriptRoot = $scripts

        # Set the PSModulePath
                  $Modules = Get-PSDContent -Content "Tools\Modules"
         $Env:PSModulePath = "$Env:PSModulePath;$modules"

        # Resume task sequence
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Deployroot is now $DeployRoot"

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : env:PSModulePath is now $Env:PSModulePath"
    
        Stop-PSDLogging
        $Result = Start-Process -FilePath "$TSEngine\TSMBootstrap.exe" -Args "/env:SAContinue" -Wait -Passthru
    }

    Else
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : No task sequence is in progress."

        # Process bootstrap
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Processing Bootstrap.ini"

        If ( $env:SYSTEMDRIVE -eq "X:" )
        {
            $MappingFile = "X:\Deploy\Tools\Modules\PSDGather\ZTIGather.xml"
            Invoke-PSDRules -FilePath "X:\Deploy\Scripts\Bootstrap.ini" -MappingFile $MappingFile
        }
    
        Else
        {
            $MappingFile = "$DeployRoot\Scripts\ZTIGather.xml"
            Invoke-PSDRules -FilePath "$DeployRoot\Control\Bootstrap.ini" -MappingFile $MappingFile
        }

        # Determine the Deployroot
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : --------------------"
        
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Determine the Deployroot"

        # Check if we are deploying from media
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : --------------------"

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Check if we are deploying from media"

        Get-Volume `
        | ? {    -not [ String ]::IsNullOrWhiteSpace( $_.DriveLetter ) } `
        | ? {                                 $_.DriveType -eq 'Fixed' } `
        | ? {                               $_.DriveLetter -ne     'X' } `
        | ? { Test-Path "$( $_.DriveLetter ):Deploy\Scripts\Media.tag" } `
        | % {

            # Found it, save the location
            Write-PSDLog -Message "$($MyInvocation.MyCommand.Name)
            : Found Media Tag $( $_.DriveLetter ):Deploy\Scripts\Media.tag"
                           $TSDrive = $_.DriveLetter
	              $TSenv:DeployRoot = "$tsDrive`:\Deploy"
	            $TSenv:ResourceRoot = "$tsDrive`:\Deploy"
	        $TSenv:DeploymentMethod = "MEDIA"

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : DeploymentMethod is $tsenv:DeploymentMethod, this solution does not currently 
        support deploying from media, sorry, aborting"

        Show-PSDInfo -Message "No deployroot set, this solution does not currently support 
        deploying from media, aborting..." -Severity Error

        Start-Process PowerShell -Wait
        Break
        }

        Switch ( $tsenv:DeploymentMethod )
        {
            'MEDIA' 
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : DeploymentMethod is $tsenv:DeploymentMethod, this solution does not currently support 
                deploying from media, sorry, aborting"

                Show-PSDInfo -Message "No deployroot set, this solution does not currently support deploying 
                from media, aborting..." -Severity Error
                
                Start-Process PowerShell -Wait
                Break
            }

            Default 
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : --------------------"
            
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : We are deploying from Network, checking IP's,"
            
                # Check Network
                Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Invoking DHCP refresh..."    
                Invoke-PSDexe -Executable ipconfig.exe -Arguments "/renew" | Out-Null
                    
                $NICIPOK = $False

                gwmi Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 1" `
                | Select-Object  @{ Name =  'IP' ; Expression =        { $_.IPAddress } } , 
                                 @{ Name = 'MAC' ; Expression =       { $_.MacAddress } } , 
                                 @{ Name =  'GW' ; Expression = { $_.DefaultIPGateway } } `
                | % {  
                       if (  $_.IP ) {  $IP  = @() ;  $_.IP | % {  $IP += $_ } }
                       if ( $_.MAC ) { $MAC  = @() ; $_.MAC | % { $MAC += $_ } }
                       if (  $_.GW ) {  $GW  = @() ;  $_.GW | % {  $GW += $_ } }
                    }

                      $IPAddress =  $IP
                     $MacAddress = $MAC
                 $DefaultGateway =  $GW

                       $ipListv4 =  $IP
                If ( $ipListv4 -ne $Null )
                {
                    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Found IP address $IP"
                    $NICIPOK = $True
                }

                If ( $NICIPOK -ne $True )
                {
                    $Message = "Sorry, it seems that you dont have a valid IP, aborting..."
                    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                    : $Message"
                
                    Show-PSDInfo -Message "$Message" -Severity Error
                        
                    Read-Host "Press Enter to exit"
                }

            ######## [   Ignore this ] ###########################################
            # XXXX Log if we are running APIPA as warning                        #
            # XXXX Log IP, Networkadapter name, if exist GW and DNS              #
            # XXXX Return Network as deployment method, with Yes we have network #
            ######## [ / Ignore this ] ###########################################

            # ( MC ) If you have an APIPA Address, then it shouldn't be working, period. 
            # This is one thing I've noticed, is that if the target system doesn't have a valid IP,
            # it can actually push it's way through. Especially if it's a VM. That shouldn't be a thing.
            # What that means is that someone has installed a clever exploit or there's a gaping wide 
            # security hole where there shouldn't be one, like, on your network. This could 
            # be a lot of different things but most importantly, if the connection lacks
            # a gateway address, the computer should drop out entirely. At some point when
            # I'm ready to test and make changes, I will be removing that.

            # Also, you guys log things way more than there needs to be. Just saying.

            }
        }

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : --------------------"
    
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Testing if we are using PSDdeployroots or not"

        If ( $TSenv:PSDDeployRoots -ne "" )
        {
            $Items = $TSenv:PSDDeployRoots.Split( "," )
            Foreach ( $Item in $Items )
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Testing $item"
                If ( $Item -ilike "http://*" )
                {
                    $ServerName = $Item.Replace( "http://" , "" ) | Split-Path
                        $Result = Test-PSDNetCon -Hostname $ServerName -Protocol HTTP
                    If ( ( $Result ) -ne $True )
                    {
                        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                        : Unable to access $Item using HTTP"
                    }

                    Else
                    {
                        $TSenv:DeployRoot = $item
                        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                        : Deployroot is now $TSenv:DeployRoot"
                        Break
                    }
                }

                If ( $Item -ilike "https://*" )
                {
                    $ServerName = $Item.Replace( "https://" , "" ) | Split-Path
                        $Result = Test-PSDNetCon -Hostname $ServerName -Protocol HTTPS
                
                    If ( ( $Result ) -ne $True )
                    {
                        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                        : Unable to access $Item using HTTPS"
                    }

                    Else
                    {
                        $TSenv:DeployRoot = $Item
                        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                        : Deployroot is now $TSenv:DeployRoot"
                        Break
                    }
                }
                If ( $Item -like "\\*" )
                {
                    $ServerName = $Item.Split( "\\" )[2]
                        $Result = Test-PSDNetCon -Hostname $ServerName -Protocol SMB
                    
                    If ( ( $Result ) -ne $True )
                    {
                        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                        : Unable to access $item using SMB"
                    }

                    Else
                    {
                        $TSenv:DeployRoot = $Item
                        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                        : Deployroot is now $TSenv:DeployRoot"
                        Break
                    }
                }
            }
        }

        Else
        {
            $DeployRoot = $TSenv:DeployRoot
        }

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : --------------------"
    
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Validate network route to $TSenv:DeployRoot"

        If ( ! ( $TSenv:DeployRoot -notlike $null -or "" ) )
        {
            $Message = "Since we are deploying from network, we should be able to access the deploymentshare, but we can't, please check your network."
        
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : $Message"

            Show-PSDInfo -Message "$Message" -Severity Error
            Start-Process PowerShell -Wait
            Break
        } 

        If ( $NICIPOK -eq $False )
        {
            If ( $DeployRoot -notlike $Null -or "" )
            {
                $Message = "Since we are deploying from network, we should have network access but we don't, check networking"
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : $Message"

                Show-PSDInfo -Message "$Message" -Severity Error
                Start-Process PowerShell -Wait
                Break
            }
        }

        # Validate network route to $deployRoot
        If ( $DeployRoot -notlike $Null -or "" )
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : New deploy root is $DeployRoot."

            If ( $DeployRoot -ilike "http://*" )
            {
                $ServerName = $DeployRoot.Replace( "http://" , "" ) | Split-Path
                    $Result = Test-PSDNetCon -Hostname $ServerName -Protocol HTTP
                If ( ( $Result ) -ne $True )
                {
                    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                    : Unable to access $ServerName"

                    Show-PSDInfo -Message "Unable to access $ServerName, aborting..." -Severity Error

                    Start-Process PowerShell -Wait
                    Break
                }
            }

            If ( $DeployRoot -like "\\*" )
            {
                $ServerName = $DeployRoot.Split("\\")[2]
                    $Result = Test-PSDNetCon -Hostname $ServerName -Protocol SMB -ErrorAction SilentlyContinue
            
                If ( ( $Result ) -ne $True )
                {
                    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Unable to access $ServerName"
                    Show-PSDInfo -Message "Unable to access $ServerName, aborting..." -Severity Error
                    Start-Process PowerShell -Wait
                    Break
                }
            }
        }

        Else
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Deployroot is empty, this solution does not currently support deploying from media, sorry, aborting"
    
            Show-PSDInfo -Message "No deployroot set, this solution does not currently support deploying from media, aborting..." -Severity Error
            Start-Process PowerShell -Wait
            Break
        }

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : New deploy root is $DeployRoot."
            
        Get-PSDConnection -DeployRoot $TSenv:DeployRoot -Username "$TSenv:UserDomain\$TSenv:UserID" -Password $TSenv:UserPassword

        # Set time on client
        If ( $TSenv:DeploymentMethod -ne "MEDIA" )
        {
            If ( $DeployRoot -like "\\*" )
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : About to run net time \\$ServerName /set /y"
                Net Time \\$ServerName /set /y
            }

            If ( $DeployRoot -ilike "http://*" )
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : About to run Get-PSDNtpTime -NTPServer time.windows.com"
                Get-PSDNtpTime -NTPServer time.windows.com
            }
        }

        $Time = Get-Date
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Computertime is set to $Time"

        # Process CustomSettings.ini
        $Control = Get-PSDContent -Content "Control"

        If ( ( Test-Path -Path "$Control\CustomSettings.ini" ) -ne $True )
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Unable to access $Control\CustomSettings.ini"
        
            Show-PSDInfo -Message "Unable to access $Control\CustomSettings.ini, aborting..." -Severity Error
            Start-Process PowerShell -Wait
            Break    
        }
    
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Processing CustomSettings.ini"

        Invoke-PSDRules -FilePath "$Control\CustomSettings.ini" -MappingFile $MappingFile

        If ( $tsenv:EventService -notlike $null -or "" )
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Eventlogging is enabled"
        }

        Else
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Eventlogging is not enabled"
        }

        # Get full scripts location
                 $Scripts = Get-PSDContent -Content "Scripts"
          $Env:ScriptRoot = $scripts

        # Set the PSModulePath
                 $Modules = Get-PSDContent -Content "Tools\Modules"
        $env:PSModulePath = "$env:PSModulePath;$modules"

        # Process wizard
        $TSenv:TaskSequenceID = ""
        If ( $TSenv:SkipWizard -ine "YES" )
        {
                  $Result = Show-PSDWizard "$Scripts\PSDWizard.xaml"

            If ( $Result.DialogResult -eq $False)
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : Cancelling, aborting..."
            
                Show-PSDInfo -Message "Cancelling, aborting..." -Severity Information
            
                Stop-PSDLogging
            
                Clear-PSDInformation
            
                Start-Process PowerShell -Wait
            
                Exit 0
            }
        }

        If ( $TSenv:TaskSequenceID -eq "" )
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): No TaskSequence selected, aborting..."
            Show-PSDInfo -Message "No TaskSequence selected, aborting..." -Severity Information
            Stop-PSDLogging
            Clear-PSDInformation
            Start-Process PowerShell -Wait
            Exit 0
        }

        If ( $TSenv:OSDComputerName -eq "") {
            $TSenv:OSDComputerName = $env:COMPUTERNAME
        }

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : --------------------"
    
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Find the task sequence engine"

        # Find the task sequence engine
        If ( Test-Path -Path "X:\Deploy\Tools\$( $TSenv:Architecture )\tsmbootstrap.exe" )
        {
            $TSEngine = "X:\Deploy\Tools\$( $TSenv:Architecture )"
        }

        Else
        {
            $TSEngine = Get-PSDContent "Tools\$( $TSenv:Architecture )"
        }
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Task sequence engine located at $TSEngine."

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : tsenv:Phase is now: $TSenv:Phase"

        If ( $BootfromWinPE -eq $True )
        {
        	$TSenv:Phase = "PREINSTALL"

            If ( $TSenv:DeploymentType -eq "" )
            {
                $TSenv:DeploymentType = "NEWCOMPUTER"
            }
        }

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : tsenv:Phase is now: $TSenv:Phase"
    
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : tsenv:DeploymentType is now: $TSenv:DeploymentType"
    
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Saving Variables"
        Save-PSDVariables

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : --------------------"
    
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Start the task sequence"

        # Start task sequence
        $VariablesPath = Save-PSDVariables
        Copy-Item -Path $VariablesPath -Destination $TSEngine -Force
        Copy-Item -Path "$Control\$( $TSenv:TaskSequenceID )\ts.xml" -Destination $TSEngine -Force

        #Update TS.XML before using it, changing workbench specific .WSF scripts to PowerShell to avoid issues
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Update ts.xml before using it, changing workbench `specific .WSF scripts to PowerShell to avoid issues"

          $TSxml =  "$tsEngine\ts.xml" ; $D = "`"" ; $SCR = "%SCRIPTROOT%" ; $CS = "cscript.exe $D$SCR" ; $PS = "PowerShell.exe -file $D$SCR"
            $WSF = "Drivers" ,  "Gather" ,  "Validate" ,    "BIOSCheck" ,     "Diskpart"  , "UserState" ,  "Backup" , "SetVariable" , "NextPhase" ,
                     "Apply" ,   "WinRE" ,   "Patches" ,    "NextPhase" ,  "Applications" , "WindowsUpdate" , "Bde" , "BDE" , "Groups" `
                 | % { "$CS\$( if ( $_ -eq "Apply" ) { "LTI$_" } else { "ZTI$_" } ).wsf$( if ( $_-eq"UserState" ){ " /capture" } else { "`" } )$D" }
            # Above and below, filters and pipes the output to the loop below 
            $PS1 = "Drivers" ,  "Gather" , "Validate" , "-" , "Partition" , "-" , "-" , "SetVariable" , "-" , "ApplyOS", @( 10..17 | % { "-" } ) `
                 | % { "$PS\PXD-$( if ( $_ -eq "-" ) { "TBA" } else { $_ } ).ps1$D" }

           0..17 | % { ( Get-Content -Path $TSXML ).Replace("$( $WSF[$_] )","$( $PS1[$_] )") } | Set-Content -Path $TSxml 

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Saving a copy of the updated TS.xml"
        Copy-Item -Path $tsEngine\ts.xml -Destination "$( Get-PSDLocalDataPath )\"

        # Check for unsupported variables
        If ( ! ( ( $tsenv:SLShareDynamicLogging -eq "" ) -or ( $tsenv:SLShareDynamicLogging -eq $Null ) ) )
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : $tsenv:SLShareDynamicLogging is currently not supported"
        }
    
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Deployroot is now $DeployRoot"

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : env:PSModulePath is now $env:PSModulePath"

        Write-PSDEvent -MessageID 41016 -severity 4 -Message "PSD beginning deployment"
    
        Stop-PSDLogging
    
        $Result = Start-Process -FilePath "$TSEngine\TSMBootstrap.exe" `
            -Args "/env:SAStart" -Wait -Passthru
    }

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Deployroot is now $DeployRoot"
    
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : env:PSModulePath is now $Env:PSModulePath"

    # Make sure variables.dat is in the current local directory 
    If ( Test-Path "$( Get-PSDLocalDataPath )\Variables.dat" )
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Variables.dat found in the correct location, $( Get-PSDLocalDataPath )\Variables.dat, no need to copy."
    }

    Else
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Copying Variables.dat to the current location, $( Get-PSDLocalDataPath )\Variables.dat."
        Copy-Item $VariablesPath "$( Get-PSDLocalDataPath )\"
    }

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Deployroot is now $DeployRoot"
    
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : env:PSModulePath is now $Env:PSModulePath"

    # Process the exit code from the task sequence
    Start-PSDLogging
    Switch ( $result.ExitCode )
    {
        0 
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : SUCCESS!"
            
            Write-PSDEvent -MessageID 41015 -Severity 4 -Message "PSD deployment completed successfully."
        
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Reset HKLM:\Software\Microsoft\Deployment 4"
            gp "HKLM:\Software\Microsoft\Deployment 4" | rm -Force -Recurse

        #Checking for FinalSummary
        If ( ! ( $tsenv:SkipFinalSummary -eq "YES" ) )
        {
            Show-PSDInfo -Message "OSD SUCCESS!" -Severity Information
        }

        # TODO Reboot for finishaction
        If ( $tsenv:finishaction -eq "Reboot" -or "Restart" )
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : TODO Reboot for finishaction"
        }
        
        Clear-PSDInformation
        Stop-PSDLogging
        
        Exit 0
    }

    -2147021886 `
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): REBOOT!"

        if ( $env:SYSTEMDRIVE -eq "X:" )
        {
            # Exit with a zero return code and let Windows PE reboot
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Exit with a zero return code and let Windows PE reboot"
            Stop-PSDLogging
            Exit 0
        }

        Else
        {
            # In full OS, need to initiate a reboot
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : In full OS, need to initiate a reboot"

            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Execute Save-PSDVariables"
            Save-PSDVariables

            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Findig out where the tools folder is..."
            $Tools = Get-PSDContent -Content "Tools\$( $tsenv:Architecture )"
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Tools is now $Tools"
            
            $Executable = "regsvr32.exe"
            $Arguments = "/u /s $tools\tscore.dll"
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : About to run: $Executable $Arguments"
            
            $Return = Invoke-PSDEXE -Executable $Executable -Args $Arguments
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Exitcode: $return"

            $Executable = "$Tools\TSProgressUI.exe"
            $Arguments = "/Unregister"
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : About to run: $Executable $Arguments"

            $Return = Invoke-PSDEXE -Executable $Executable -Args $Arguments
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Exitcode: $return"

            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Restart, see you on the other side... (Shutdown.exe /r /t 30 /f)"
            
            #Restart-Computer -Force
            Shutdown.exe /r /t 30 /f

            Stop-PSDLogging
            Exit 0
        }
    }

    Default `
    {
        # Exit with a non-zero return code
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Task sequence failed, rc = $( $Result.ExitCode )"

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Reset HKLM:\Software\Microsoft\Deployment 4"
        gp "HKLM:\Software\Microsoft\Deployment 4"  -EA 3 | rm -Force -Recurse

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Reset HKLM:\Software\Microsoft\SMS"
        gp "HKLM:\Software\Microsoft\SMS" -EA 3 | rm -Force -Recurse

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Finding out where the tools folder is..."
        
        $Tools = Get-PSDContent -Content "Tools\$( $tsenv:Architecture )"
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Tools is now $Tools"

        $Executable = "regsvr32.exe"
        $Arguments = "/u /s $tools\tscore.dll"
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : About to run: $Executable $Arguments"
        
        $Return = Invoke-PSDEXE -Executable $Executable -Args $Arguments
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Exitcode: $return"

        $Executable = "$Tools\TSProgressUI.exe"
        $Arguments = "/Unregister"
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : About to run: $Executable $Arguments"
        
        $Return = Invoke-PSDEXE -Executable $Executable -Args $Arguments
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Exitcode: $return"
        
        Clear-PSDInformation
        Stop-PSDLogging

        #Invoke-PSDInfoGather
        Write-PSDEvent -MessageID 41014 -Severity 1 -Message "PSD deployment failed, Return Code is $( $Result.ExitCode )"
        Show-PSDInfo -Message "Task sequence failed, Return Code is $( $Result.ExitCode )" -Severity Error

        Exit $Result.ExitCode
    }
}
