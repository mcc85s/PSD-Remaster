# // ***************************************************************************
# // 
# // PowerShell Deployment for MDT
# //
# // File:      PSDWindowsUpdate.ps1
# // 
# // Purpose:   Apply the specified operating system.
# // 
# // 
# // ***************************************************************************

    Param ( )

    # Load core modules
    Import-Module PSDUtility
    Import-Module PSDDeploymentShare

    $VerbosePreference = "Continue"
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Load core modules"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Deployroot is now $deployRoot"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : env:PSModulePath is now $env:PSModulePath"

    Function Find-WindowsUpdateList {
<#

.SYNOPSIS
Create a sheduled task to run powershell script that find available or installed windows updates through COM object.

.DESCRIPTION
Create a sheduled task to run powershell script that find available or installed windows updates through COM object.

.ROLE
Readers

.PARAMETER searchCriteria
  "IsInstalled = 0": available updates, "IsInstalled = 1": installed updates

.PARAMETER sessionId
  session Id used to identify different query instance

.PARAMETER serverSelection
  update service server

#>

    Param ( 
        
        [ Parameter ( Mandatory = $true ) ]

            [ String ] $SearchCriteria ,

        [ Parameter ( Mandatory = $true ) ]

            [ String ] $SessionId ,
        
        [ Parameter ( Mandatory = $true ) ]

            [ Int16 ] $serverSelection )

    #PowerShell script to run. In some cases, you may need use back quote (`) to treat some characters (eg. double/single quote, special escape sequence) literally.
    $Script = #@'
    Function GenerateSearchHash( $searchResults )
    {
        ForEach ( $searchResult in $searchResults )
        {
            Foreach ( $KBArticleID in $searchResult.KBArticleIDs )
            {
                $KBID = "KB$KBArticleID"
                If ( $KBArticleID -ne $null -and -Not $SearchHash.ContainsKey( $KBID ) )
                {
                    $searchHash.Add( $KBID, 
                    ( $searchResult | Microsoft.PowerShell.Utility\Select-Object MSRCSeverity , Title , IsMandatory ) )
                }
            }
        }
    }

    Function GenerateHistoryHash( $HistoryResults )
    {
        ForEach ( $HistoryResult in $HistoryResults)
        {
            $KBID = ( [ Regex ]::match( $historyResult.Title , 'KB(\d+)' ) ).Value.ToUpper()
            If ( $KBID -ne $null -and $KBID -ne '' )
            {
                $Title = $HistoryResult.Title.Trim()

                If ( -Not $HistoryHash.ContainsKey( $KBID ) )
                {
                    $HistoryHash.Add( $KBID , 
                    ( $HistoryResult | Microsoft.PowerShell.Utility\Select-Object  ResultCode, Date, Title ) )
                } 
                
                ElseIf ( ( $HistoryHash[ $KBID ].Title -eq $null -or $HistoryHash[ $KBID ].Title -eq '' ) -and ( $Title -ne $Null -or $Title.Length -gt 0 ) )
                {
                    #If the previous entry did not have a title and this item has one, update it
                    $HistoryHash[ $KBID ] = $historyResult | Microsoft.PowerShell.Utility\Select-Object  ResultCode , Date , $Title
                }
            }
        }
    }

                    $ObjSession = New-Object -ComObject "Microsoft.Update.Session"
                   $ObjSearcher = $ObjSession.CreateUpdateSearcher()
   $ObjSearcher.ServerSelection = $ServerSelection
                    $ObjResults = $ObjSearcher.Search( $SearchCriteria )

    $Result = New-Object Collections.ArrayList

    If ( $SearchCriteria -eq "IsInstalled=1" )
    {
        $SearchHash = @{}
        GenerateSearchHash( $objResults.Updates )

          $HistoryCount = $ObjSearcher.GetTotalHistoryCount()
        $HistoryResults = $objSearcher.QueryHistory( 0 , $HistoryCount )

           $HistoryHash = @{}
        GenerateHistoryHash( $HistoryResults )

        $InstalledItems = Get-Hotfix
        ForEach ( $InstalledItem in $InstalledItems )
        {
            $ResultItem = $InstalledItem | Microsoft.PowerShell.Utility\Select-Object HotFixID , InstalledBy
                 $Title = "$( $InstalledItem.Description ) ($( $resultItem.HotFixID ))"
           $InstallDate = $InstalledItem.InstalledOn

            $TitleMatch = $null

            $SearchMatch = $SearchHash.Item( $InstalledItem.HotFixID )
            If ( $SearchMatch -ne $null )
            {
                $TitleMatch = $SearchMatch.title
                $SM = @{    Name  = "MSRCSeverity" , "IsMandatory"
                            Value = $SearchMatch.MSRCSeverity , $SearchMatch.IsMandatory } 
                0..1 `
                | % { $ResultItem | Add-Member -MemberType NoteProperty -Name $SM.Name[$_] -Value $SM.Value[$_] } # That's how you do it ladies and gents. 
            }

            $HistoryMatch = $HistoryHash.Item( $InstalledItem.HotFixID )
            If ( $HistoryMatch -ne $null )
            {
                $ResultItem | Add-Member -MemberType NoteProperty -Name "InstallState" -Value $HistoryMatch.ResultCode
                If ( $TitleMatch -eq $Null -or $TitleMatch -eq '' )
                {
                    # If there was no matching title in searchMatch
                    $TitleMatch = $HistoryMatch.title
                }

                $InstallDate = $HistoryMatch.Date
            }

            If ( $TitleMatch -ne $null -or $TitleMatch -ne '' )
            {
                $Title = $TitleMatch
            }

            # Results_ | Hash-Table
            $Results_ = @{ Name = "Title" , "InstallDate" ; Value = $Title , $InstallDate }
            0..1 | % { $ResultItem | Add-Member -MemberType NoteProperty -Name ( $Results_.Name[$_] ) -Value ( $Results_.Value[$_] ) }

            $Result.Add( $ResultItem )
        }
    }
     
    Else 
    {
        Foreach ( $ObjResult in $ObjResults.Updates ) 
        {
            $ResultItem = $ObjResult | Microsoft.PowerShell.Utility\Select-Object MSRCSeverity , Title , IsMandatory
            $Result.Add( $ResultItem )
        }
    }

    If ( Test-Path $ResultFile )
    {
        Remove-Item $ResultFile
    }

    $Result | ConvertTo-Json -depth 10 | Out-File $ResultFile
    #'@

    #Pass parameters to script and generate script file in localappdata folder
    $TimeStamp = Get-Date -Format FileDateTimeUniversal
    # use both ps sessionId and timestamp for file/task prefix so that multiple instances wont delete others files and tasks
    $Fileprefix = "_PS$sessionId`_Time$timeStamp"
    $ResultFile = "$env:TEMP\Find-Updates-result$fileprefix.json"
    
    $Search_Criteria = '$searchCriteria = ' , "'$searchCriteria';" , '$ResultFile = ' , "'$ResultFile';" , '$serverSelection =' , "'$serverSelection';" , $Script
        $Script = -join $Search_Criteria[0..6]

    $ScriptFile = "$env:TEMP\Find-Updates$fileprefix.ps1"
    $Script | Out-File $ScriptFile

    If ( ! ( Test-Path $ScriptFile ) )
    {
        $Message = "Failed to create file:$ScriptFile"
        Write-Error $message
        Return #If failed to create script file, no need continue just return here
    }

    #Create a scheduled task
    $TaskName = "SMEWindowsUpdateFindUpdates$fileprefix"


    # Completely changed the Administrator Access Stuff here. You're Welcome.
    $r = "Principal" ; ( $w , $s , $p ) = $r , "Identity" , "BuiltInRole" | % { [ Type ] "Security.$r.Windows$_" } 
    $Role = ( New-Object $w $s::GetCurrent() ).IsInRole( $p::Administrator )
    $arg = "-NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File $ScriptFile"
    If ( ! $Role ) 
    {
        $f = "-File $PSCommandPath $( $MyInvocation.UnboundArguments )"
        Switch( $host.UI.PromptForChoice( 'Elevation Required - Make an attempt to Self-Elevate script?' , 
        "Microsoft says 'Restart the script as an Admin' but- we can also try Self-Elevation or Get-Credential. " , 
        [ System.Management.Automation.Host.ChoiceDescription[]]@( '&Yes - Attempt' , '&No - Exit' , 
        '&Enter your Credentials' ) , [ Int ] 1 )  )
        {
            0
            { 
                Echo "[~] Will Attempt Self-Elevation"
                If ( [ Int ] ( gcim Win32_OperatingSystem ).BuildNumber -ge 6000 )
                {
                    Start-Process -FilePath PowerShell.exe -Verb Runas -Args $f 
                    If ( $? -eq $true )
                    { 
                        Echo "[+] $a Script Elevation Successful" ; Return
                    } 
                    Else 
                    { 
                        Echo "[!] $a Script Elevation Failed . . . "
                        Echo "[~] Be sure to launch the console as an Administrator."
                        Read-Host "Press Enter to Exit" ; Exit 
                    }
               }
            }
            
            1
            {
                Echo "[~] Be sure to launch the console as an Administrator"
                Read-Host "Press Enter to Exit" ; Exit
            }

            2
            {
                Echo "[~] Launching Get-Credential"
                $Creds = Get-Credential
                 
                If ( $_ -eq $True )
                {
                    Start-Process -FilePath PowerShell.exe -Verb Runas -Args $f
                    If ( $_ -eq $True )
                    { 
                        Echo "[+] $a Script Elevation Successful"
                        Return
                    } 
                    Else
                    {
                        Echo "[!] Bad credentials or user closed the window."
                        Read-Host "Press Enter to Exit."
                        Exit
                    }
                }
                Else
                { 
                    Echo "[!] $a Script Elevation Failed . . . "
                    Echo "[~] Be sure to launch the console as an Administrator."
                    Read-Host "Press Enter to Exit" ; Exit 
                }
            }
        }
    }
    $Scheduler = New-Object -ComObject Schedule.Service

    #Try to connect to schedule service 3 time since it may fail the first time
    For ( $i = 1 ; $i -le 3 ; $i++ )
    {
	    Try
    	{
	    	$Scheduler.Connect()
		    Break
    	}

	    Catch
    	{
    		If ( $i -ge 3 )
		    {
		        Write-EventLog -LogName Application -Source "SME Windows Updates Find Updates" `
                    -EntryType Error -EventID 1 -Message "Can't connect to Schedule service"
    			Write-Error "Can't connect to Schedule service" -ErrorAction Stop
	    	}

            Else
    		{
	    		Start-Sleep -s 1
		    }
    	}
    }

    $RootFolder = $Scheduler.GetFolder( "\" )
    #Delete existing task
    If ( $RootFolder.GetTasks( 0 ) | ? { $_.Name -eq $TaskName } )
    {
	    Write-Debug( "Deleting existing task$TaskName" )
	    $RootFolder.DeleteTask( $TaskName , 0 )
    }

                            $Task = $Scheduler.NewTask( 0 )
                $RegistrationInfo = $Task.RegistrationInfo
    $RegistrationInfo.Description = $TaskName
         $RegistrationInfo.Author = $User.Name
                        $Triggers = $Task.Triggers
                         $Trigger = $Triggers.Create( 7 ) 
    #TASK_TRIGGER_REGISTRATION: Starts the task when the task is registered.
                 $Trigger.Enabled = $True
                        $Settings = $Task.Settings
                $Settings.Enabled = $True
     $Settings.StartWhenAvailable = $True
                 $Settings.Hidden = $False
                          $Action = $Task.Actions.Create( 0 )
                     $Action.Path = "PowerShell"
                $Action.Arguments = $Arg
    #Tasks will be run with the highest privileges
         $Task.Principal.RunLevel = 1

    #Start the task to run in Local System account. 6: TASK_CREATE_OR_UPDATE
    $RootFolder.RegisterTaskDefinition( $TaskName , $Task , 6 , "SYSTEM" , $Null , 1 ) `
    | Out-Null
    #Wait for running task finished
    $RootFolder.GetTask( $TaskName ).Run( 0 ) `
    | Out-Null
    While ( $Scheduler.GetRunningTasks( 0 ) `
    | ? { $_.Name -eq $TaskName } )
        { Start-Sleep -s 1      }

        #Clean up
        $RootFolder.DeleteTask( $TaskName , 0 )
        Remove-Item $ScriptFile
        #Return result
        If ( Test-Path $ResultFile )
        {
            $Result = Get-Content -Raw -Path $ResultFile | ConvertFrom-Json
            Remove-Item $ResultFile
            Return $Result
        }
    }
    ## [END] Find-WindowsUpdateList ##
<#

.SYNOPSIS
Script that get windows update automatic update options from registry key.

.DESCRIPTION
Script that get windows update automatic update options from registry key.

.ROLE
Readers

#>
    Function Get-AutomaticUpdatesOptions 
    {
        Import-Module Microsoft.PowerShell.Management

    
        $AU = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" # If there is AUOptions, return it, otherwise return NoAutoUpdate value

    $Option = @( gp $AU -Name "AUOptions" -ErrorVariable MyError -EA 3 )

    If ( $Option -ne $null )
    {
        Return $Option.AUOptions
    } 

    ElseIf ( $myerror )
    {
        $Option = @( gp $AU -Name "NoAutoUpdate" -ErrorVariable -EA 3 )

        If ( $Option -ne $null )
        {
            Return $Option.NoAutoUpdate
        }

        ElseIf ( $Myerror )
        {
            $Option = 0 
        }
    }
    Return $Option
    } ## [END] Get-AutomaticUpdatesOptions ##
    
<#

.SYNOPSIS
Script that returns if Microsoft Monitoring Agent is running or not.

.DESCRIPTION
Script that returns if Microsoft Monitoring Agent is running or not.

.ROLE
Readers

#>

    Function Get-MicrosoftMonitoringAgentStatus 
    {

        Import-Module Microsoft.PowerShell.Management

        $Status = Get-Service -Name HealthService -EA 3

        If ( $Status -eq $Null )
        {
            # which means no such service is found.
            @{ Installed = $False ; Running = $False }
        } 
    
        ElseIf ( $Status.Status -eq "Running" )
        {
            @{ Installed = $True ; Running = $True }
        }

        Else 
        {
            @{ Installed = $True ; Running = $False }
        }
    }

## [END] Get-MicrosoftMonitoringAgentStatus ##

<#

.SYNOPSIS
Script that check scheduled task for install updates is still running or not.

.DESCRIPTION
 Script that check scheduled task for install updates is still running or not. Notcied that using the following COM object has issue: when install-WUUpdates task is running, the busy status return false;
 but right after the task finished, it returns true.

.ROLE
Readers

#>

    Function Get-WindowsUpdateInstallerStatus 
    {
        Import-Module ScheduledTasks

        $TaskName = "SMEWindowsUpdateInstallUpdates"

        $ScheduledTask = Get-ScheduledTask | Microsoft.PowerShell.Utility\Select-Object TaskName, State | ? { $_.TaskName -eq $TaskName }
        If ( $ScheduledTask -ne $Null -and $ScheduledTask.State -eq 4 )
        {
            Return $True
        } 
        
        Else
        {
            Return $False
        }
    }

## [END] Get-WindowsUpdateInstallerStatus ##

<#

.SYNOPSIS
Create a scheduled task to run a powershell script file to installs all available windows updates through ComObject, restart the machine if needed.

.DESCRIPTION
Create a scheduled task to run a powershell script file to installs all available windows updates through ComObject, restart the machine if needed.
This is a workaround since CreateUpdateDownloader() and CreateUpdateInstaller() methods can't be called from a remote computer - E_ACCESSDENIED.
More details see https://msdn.microsoft.com/en-us/library/windows/desktop/aa387288(v=vs.85).aspx

.ROLE
Administrators

.PARAMETER restartTime
  The user-defined time to restart after update (Optional).

.PARAMETER serverSelection
  update service server

#>

    Function Install-WindowsUpdates
    { 
        Param ( 
        
        [ Parameter ( Mandatory = $False ) ]
            
            [ String ] $RestartTime ,
                
        [ Parameter ( Mandatory = $True ) ]

            [ Int16 ] $ServerSelection )

                         $Script = #@"
              $ObjServiceManager = New-Object -ComObject 'Microsoft.Update.ServiceManager'
                     $ObjSession = New-Object -ComObject 'Microsoft.Update.Session'
                    $ObjSearcher = $ObjSession.CreateUpdateSearcher()
    $ObjSearcher.ServerSelection = $ServerSelection
                    $ServiceName = 'Windows Update'
                         $Search = 'IsInstalled = 0'
                     $ObjResults = $ObjSearcher.Search( $Search )
                        $Updates = $ObjResults.Updates
         $FoundUpdatesToDownload = $Updates.Count
                 $NumberOfUpdate = 10
          $ObjCollectionDownload = New-Object -ComObject 'Microsoft.Update.UpdateColl'
                    $UpdateCount = $Updates.Count
    
    Foreach ( $Update in $Updates )
    {
	    Write-Progress -Activity 'Downloading updates' `
            -Status "[ $( $NumberOfUpdate )/$( $UpdateCount )] $( $Update.Title )" `
            -PercentComplete    $( [ Int ]( $NumberOfUpdate / $UpdateCount * 100 ) )
	    $NumberOfUpdate++
    	Write-Debug "Show Update To Download: $( $Update.Title )" 
	Write-Debug 'Accept Eula'
	
    $Update.AcceptEula()
	Write-Debug 'Send update to download collection'
	$ObjCollectionTmp = New-Object -ComObject 'Microsoft.Update.UpdateColl'
	$ObjCollectionTmp.Add( $Update ) | Out-Null

	        $Downloader = $ObjSession.CreateUpdateDownloader()
	$Downloader.Updates = $objCollectionTmp

	Try
	{
		Write-Debug 'Try download update'
		$DownloadResult = $Downloader.Download()
	} <#End Try#>

	Catch
	{
		If ( $_ -match 'HRESULT: 0x80240044' )
		{
			Write-Warning 'Your security policy does not allow a non-administator identity to perform this task' # Added self elevation to the script... so this should never happen.
		} <#End If $_ -match 'HRESULT: 0x80240044'#>

		Return 
    } <#End Catch#>

	Write-Debug 'Check ResultCode'
	Switch -exact ( $DownloadResult.ResultCode )
	{
		0   { $Status = 'NotStarted'           }
		1   { $Status = 'InProgress'           }
		2   { $Status = 'Downloaded'           }
		3   { $Status = 'DownloadedWithErrors' }
		4   { $Status = 'Failed'               }
		5   { $Status = 'Aborted'              } } <#End Switch#>

	    If ( $DownloadResult.ResultCode -eq 2 )
    	{
    		Write-Debug 'Downloaded then send update to next stage'
    		$ObjCollectionDownload.Add( $Update ) | Out-Null
    	} <#End If $DownloadResult.ResultCode -eq 2#>
    }

    $ReadyUpdatesToInstall = $objCollectionDownload.count
    Write-Verbose "$( Downloaded [ $ReadyUpdatesToInstall ] Updates to Install )"
    If ( $ReadyUpdatesToInstall -eq 0 )
    {
	    Return
    } <#End If $ReadyUpdatesToInstall -eq 0#>

       $NeedsReboot = $false
    $NumberOfUpdate = 1

<#install updates#>
    Foreach ( $Update in $objCollectionDownload )
    {
    	Write-Progress -Activity 'Installing updates' `
            -Status " [ $( $NumberOfUpdate )/$( $ReadyUpdatesToInstall )] $( $Update.Title )" `
            -PercentComplete $( [ Int ]( $NumberOfUpdate / $ReadyUpdatesToInstall * 100 ) )
	    Write-Debug 'Show update to install: $($Update.Title)'

    	Write-Debug 'Send update to install collection'
    	$ObjCollectionTmp = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    	$ObjCollectionTmp.Add( $Update ) | Out-Null

    	$ObjInstaller = $ObjSession.CreateUpdateInstaller()
    	$ObjInstaller.Updates = $ObjCollectionTmp

    	Try
	    {
		    Write-Debug 'Try install update'
    		$InstallResult = $objInstaller.Install()
    	} <#End Try#>

    	Catch
	    {
		    If ( $_ -match 'HRESULT: 0x80240044' )
    		{
	    		Write-Warning 'Your security policy do not allow a non-administator identity to perform this task';
		    } <#End If $_ -match 'HRESULT: 0x80240044'#>
    		Return
	    } #End Catch

    	If ( ! $NeedsReboot )
	    {
    		Write-Debug 'Set instalation status RebootRequired'
	    	$NeedsReboot = $installResult.RebootRequired
	    } <#End If !$NeedsReboot#>

	$NumberOfUpdate++
    } <#End Foreach $Update in $objCollectionDownload#>

    If ( $NeedsReboot )
    {
	<#Restart immediately#>
	    $WaitTime = 0
    
        If ( $RestartTime )
        {
		    <#Restart at given time#>
            $WaitTime = [ Decimal ]::Round( ( ( Get-Date $RestartTime ) - ( Get-Date ) ).TotalSeconds )
            If ( $WaitTime -lt 0 )
            {
                $WaitTime = 0
            }
        }

    Shutdown -R -T $WaitTime -C "SME installing Windows updates"
    }

    If ( $RestartTime ) #Pass parameters to script and generate script file in localappdata folder
    {
    	$Script = "$restartTime = $( "'$restartTime';" )$Script"
    }
    $Script = "'$serverSelection ='$( "'$serverSelection';" )$Script"

    $ScriptFile = $env:LocalAppData + "\Install-Updates.ps1"
    $Script | Out-File $ScriptFile
    
    If ( ! ( Test-Path $ScriptFile ) )
    {
        $Message = "Failed to create file:$ScriptFile"
        Write-Error $Message
        Return #If failed to create script file, no need continue just return here
    }

    #Create a scheduled task
    $TaskName = "SMEWindowsUpdateInstallUpdates"

    # Completely changed the Administrator Access Stuff here. You're Welcome.
    $r="Principal";($r,$s,$p)=($r,"Identity","BuiltInRole"|%{[Type]"Security.$r.Windows$_"});$a="Administrator"
    $r=(New-Object $r $s::GetCurrent()).IsInRole($p::$a);
    $arg = "-NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File $ScriptFile"

    If ( ! $Role )
    {
	    Write-Warning "To perform some operations you must run an elevated Windows PowerShell console."
    }

    $Scheduler = New-Object -ComObject Schedule.Service

    #Try to connect to schedule service 3 time since it may fail the first time
    For ( $i = 1 ; $i -le 3 ; $i++ )
    {
	    Try
    	{
		    $Scheduler.Connect()
    		Break
    	}

	    Catch
    	{
    		If ( $i -ge 3 )
    		{
	    		Write-EventLog -LogName Application -Source "SME Windows Updates Install Updates" `
                    -EntryType Error -EventID 1 -Message "Can't connect to Schedule service"
                        
    			Write-Error "Can't connect to Schedule service" -EA 4
	    	}

    		Else
	    	{
		    	Start-Sleep -s 1
    		}
	    }
    }

    $RootFolder = $Scheduler.GetFolder( "\" ) 
    #Delete existing task
    If ( $RootFolder.GetTasks( 0 ) | ? { $_.Name -eq $TaskName } )
    {
	    Write-Debug( "Deleting existing task$TaskName" )
	    $RootFolder.DeleteTask( $TaskName , 0 )
    }

                            $Task = $Scheduler.NewTask( 0 )
                $RegistrationInfo = $Task.RegistrationInfo
    $RegistrationInfo.Description = $TaskName
         $RegistrationInfo.Author = $User.Name

                        $Triggers = $Task.Triggers
                         $Trigger = $Triggers.Create( 7 ) 
    #TASK_TRIGGER_REGISTRATION: Starts the task when the task is registered.
                 $Trigger.Enabled = $True
                        $Settings = $Task.Settings
                $Settings.Enabled = $True
     $Settings.StartWhenAvailable = $True
                 $Settings.Hidden = $False

                          $Action = $Task.Actions.Create( 0 )
                     $Action.Path = "PowerShell"
                $Action.Arguments = $Arg

        #Tasks will be run with the highest privileges
         $Task.Principal.RunLevel = 1

        #Start the task to run in Local System account. 6: TASK_CREATE_OR_UPDATE
        $RootFolder.RegisterTaskDefinition( $TaskName , $Task , 6 , "SYSTEM" , $Null , 1 ) `
        | Out-Null
        #Wait for running task finished
        $RootFolder.GetTask( $TaskName ).Run( 0 ) `
        | Out-Null

        While ( $Scheduler.GetRunningTasks( 0 ) | ? { $_.Name -eq $TaskName } )
        {
	        Start-Sleep -s 1
        }

        #Clean up
        $RootFolder.DeleteTask( $TaskName , 0 )
        Remove-Item $ScriptFile
    }

## [END] Install-WindowsUpdates ##


    Function Set-AutomaticUpdatesOptions 
    {
<#

.SYNOPSIS
Script that set windows update automatic update options in registry key.

.DESCRIPTION
Script that set windows update automatic update options in registry key.

.EXAMPLE
Set AUoptions
PS C:\> Set-AUoptions "2"

.ROLE
Administrators

#>

    Param ( 
    
    [ Parameter ( Mandatory = $True ) ]

        [ String ] $AUOptions )

    $Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    Switch( $AUOptions )
    {
        '0' { if ( Test-Path $Path ) { ri $Path } }
        '1' { if ( Test-Path $Path )
                 {  sp -Path $Path -Name NoAutoUpdate -Value 0x1 -Force 
                    rp -Path $Path -Name AUOptions } 
            else {  New-Item $Path -Force
                    sp -Path $Path -Name NoAutoUpdate -Value 0x1 -Force      } }
    default { if ( ! ( Test-Path $Path ) )
            {       New-Item $Path -Force                                      }
                    sp -Path $Path -Name AUOptions -Value $AUOptions -Force
                    sp -Path $Path -Name NoAutoUpdate -Value 0x0 -Force      } } }

## [END] Set-AutomaticUpdatesOptions ##


<#

.SYNOPSIS
Gets Win32_ComputerSystem object.

.DESCRIPTION
Gets Win32_ComputerSystem object.

.ROLE
Readers

#>
##SkipCheck=true##

    Function Get-CimWin32ComputerSystem 
    {
        Import-Module CimCmdlets
        gcim -Namespace root/cimv2 -ClassName Win32_ComputerSystem

    }
## [END] Get-CimWin32ComputerSystem ##

<#

.SYNOPSIS
Gets Win32_LogicalDisk object.

.DESCRIPTION
Gets Win32_LogicalDisk object.

.ROLE
Readers

#>
##SkipCheck=true##

    Function Get-CimWin32LogicalDisk 
    {
        Import-Module CimCmdlets
        gcim -Namespace root/cimv2 -ClassName Win32_LogicalDisk

    }
## [END] Get-CimWin32LogicalDisk ##

<#

.SYNOPSIS
Gets Win32_NetworkAdapter object.

.DESCRIPTION
Gets Win32_NetworkAdapter object.

.ROLE
Readers

#>
##SkipCheck=true##

    Function Get-CimWin32NetworkAdapter 
    {
        Import-Module CimCmdlets
        gcim -Namespace root/cimv2 -ClassName Win32_NetworkAdapter
    }

## [END] Get-CimWin32NetworkAdapter ##

<#

.SYNOPSIS
Gets Win32_OperatingSystem object.

.DESCRIPTION
Gets Win32_OperatingSystem object.

.ROLE
Readers

#>
##SkipCheck=true##

    Function Get-CimWin32OperatingSystem 
    {
        Import-Module CimCmdlets

        gcim -Namespace root/cimv2 -ClassName Win32_OperatingSystem

    }

## [END] Get-CimWin32OperatingSystem ##

<#

.SYNOPSIS
Gets Win32_PhysicalMemory object.

.DESCRIPTION
Gets Win32_PhysicalMemory object.

.ROLE
Readers

#>
##SkipCheck=true##

    function Get-CimWin32PhysicalMemory
    {
        Import-Module CimCmdlets

        gcim -Namespace root/cimv2 -ClassName Win32_PhysicalMemory

    }
## [END] Get-CimWin32PhysicalMemory ##

<#

.SYNOPSIS
Gets Win32_Processor object.

.DESCRIPTION
Gets Win32_Processor object.

.ROLE
Readers

#>
##SkipCheck=true##

    Function Get-CimWin32Processor 
    {
        Import-Module CimCmdlets

        gcim -Namespace root/cimv2 -ClassName Win32_Processor

    }
## [END] Get-CimWin32Processor ##

<#

.SYNOPSIS
Retrieves the inventory data for a cluster.

.DESCRIPTION
Retrieves the inventory data for a cluster.

.ROLE
Readers

#>

    Function Get-ClusterInventory 
    {
        Import-Module CimCmdlets -EA 3

# JEA code requires to pre-import the module (this is slow on failover cluster environment.)
        import-module FailoverClusters -EA 3

<#

.SYNOPSIS
Get the name of this computer.

.DESCRIPTION
Get the best available name for this computer.  The FQDN is preferred, but when not avaialble
the NetBIOS name will be used instead.

#>

    Function getComputerName() 
    {
        $ComputerSystem = gcim Win32_ComputerSystem -EA 3 | Microsoft.PowerShell.Utility\Select-Object Name, DNSHostName

        If ( $ComputerSystem )
        {
            $ComputerName = $ComputerSystem.DNSHostName

            If ( $Null -eq $ComputerName )
            {
                $ComputerName = $ComputerSystem.Name
            }

        Return $ComputerName
        }

    Return $Null
    }

<#

.SYNOPSIS
Are the cluster PowerShell cmdlets installed on this server?

.DESCRIPTION
Are the cluster PowerShell cmdlets installed on this server?

#>

    Function getIsClusterCmdletAvailable() 
    {
        $Cmdlet = Get-Command "Get-Cluster" -EA 3

        Return !!$Cmdlet
    }

<#

.SYNOPSIS
Get the MSCluster Cluster CIM instance from this server.

.DESCRIPTION
Get the MSCluster Cluster CIM instance from this server.

#>

    Function getClusterCimInstance()
    {
        $namespace = gcim -Namespace root/MSCluster -ClassName __NAMESPACE -EA 3

        If ( $namespace )
        {
            Return gcim -Namespace root/mscluster MSCluster_Cluster -EA 3 | Microsoft.PowerShell.Utility\Select-Object fqdn, S2DEnabled
        }

        Return $null
    }


<#

.SYNOPSIS
Determines if the current cluster supports Failover Clusters Time Series Database.

.DESCRIPTION
Use the existance of the path value of cmdlet Get-StorageHealthSetting to determine if TSDB 
is supported or not.

#>
    Function getClusterPerformanceHistoryPath() 
    {
        Return $null -ne ( Get-StorageSubSystem clus* | Get-StorageHealthSetting -Name "System.PerformanceHistory.Path" )
    }

<#

.SYNOPSIS
Get some basic information about the cluster from the cluster.

.DESCRIPTION
Get the needed cluster properties from the cluster.

#>
    
    Function getClusterInfo()
    {
        $ReturnValues = @{}

                 $ReturnValues.FQDN = $Null
         $ReturnValues.isS2DEnabled = $False
        $ReturnValues.isTsdbEnabled = $False

    $Cluster = getClusterCimInstance
    If ( $Cluster )
    {
                 $ReturnValues.FQDN = $Cluster.fqdn
        $isS2dEnabled = ! ! ( GM -InputObject $Cluster -Name "S2DEnabled" ) -and ( $Cluster.S2DEnabled -eq 1 )
         $ReturnValues.isS2DEnabled = $IsS2dEnabled

        If ( $IsS2DEnabled )
        {
            $ReturnValues.isTsdbEnabled = getClusterPerformanceHistoryPath
        }
        Else 
        {
            $ReturnValues.isTsdbEnabled = $False
        }
    }

    Return $ReturnValues
}

<#

.SYNOPSIS
Are the cluster PowerShell Health cmdlets installed on this server?

.DESCRIPTION
Are the cluster PowerShell Health cmdlets installed on this server?

s#>

    Function getisClusterHealthCmdletAvailable()
    {
        $Cmdlet = Get-Command -Name "Get-HealthFault" -EA 3

        Return !!$cmdlet
    }
<#

.SYNOPSIS
Are the Britannica (sddc management resources) available on the cluster?

.DESCRIPTION
Are the Britannica (sddc management resources) available on the cluster?

#>
    Function getIsBritannicaEnabled()
    {
        Return $null -ne ( gcim -Namespace root/sddc/management -ClassName SDDC_Cluster -EA 3 )
    }

<#

.SYNOPSIS
Are the Britannica (sddc management resources) virtual machine available on the cluster?

.DESCRIPTION
Are the Britannica (sddc management resources) virtual machine available on the cluster?

#>
    Function getIsBritannicaVirtualMachineEnabled() 
    {
        Return $null -ne ( gcim -Namespace root/sddc/management -ClassName SDDC_VirtualMachine -EA 3 )
    }

<#

.SYNOPSIS
Are the Britannica (sddc management resources) virtual switch available on the cluster?

.DESCRIPTION
Are the Britannica (sddc management resources) virtual switch available on the cluster?

#>
    Function getIsBritannicaVirtualSwitchEnabled() 
    {
        Return $null -ne ( gcim -Namespace root/sddc/management -ClassName SDDC_VirtualSwitch -EA 3 )
    }

###########################################################################
# main()
###########################################################################

    $clusterInfo = getClusterInfo

    $Result = [ PSCustomObject ] 
    @{  0 = @(                                'Fqdn' ; $clusterInfo.FQDN                    )
        1 = @(                        'IsS2DEnabled' ; $clusterInfo.isS2DEnabled            )
        2 = @(                      'IsTsdbEnabled'  ; $clusterInfo.isTsdbEnabled           )
        3 = @(      'IsClusterHealthCmdletAvailable' ; getIsClusterHealthCmdletAvailable    )  
        4 = @(                 'IsBritannicaEnabled' ; getIsBritannicaEnabled               )
        5 = @(   'IsBritannicaVirtualMachineEnabled' ; getIsBritannicaVirtualMachineEnabled )
        6 = @(    'IsBritannicaVirtualSwitchEnabled' ; getIsBritannicaVirtualSwitchEnabled  )
        7 = @(            'IsClusterCmdletAvailable' ; getIsClusterCmdletAvailable          )
        8 = @(                  'CurrentClusterNode' ; getComputerName                      ) }

    $result

    }

## [END] Get-ClusterInventory ##

<#

.SYNOPSIS
Retrieves the inventory data for cluster nodes in a particular cluster.

.DESCRIPTION
Retrieves the inventory data for cluster nodes in a particular cluster.

.ROLE
Readers

#>

    Function Get-ClusterNodes
    {
        Import-Module CimCmdlets

# JEA code requires to pre-import the module ( this is slow on failover cluster environment. )
        Import-Module FailoverClusters -EA 3

###############################################################################
# Constants
###############################################################################

        Set-Variable -Name LogName    -Option Constant -Value "Microsoft-ServerManagementExperience" -EA 3
        Set-Variable -Name LogSource  -Option Constant -Value "SMEScripts"                           -EA 3
        Set-Variable -Name ScriptName -Option Constant -Value $MyInvocation.ScriptName               -EA 3

<#

.SYNOPSIS
Are the cluster PowerShell cmdlets installed?

.DESCRIPTION
Use the Get-Command cmdlet to quickly test if the cluster PowerShell cmdlets
are installed on this server.

#>

    Function getClusterPowerShellSupport()
    {
        $CmdletInfo = Get-Command 'Get-ClusterNode' -EA 3

        Return $cmdletInfo -and $cmdletInfo.Name -eq "Get-ClusterNode"
    }

<#

.SYNOPSIS
Get the cluster nodes using the cluster CIM provider.

.DESCRIPTION
When the cluster PowerShell cmdlets are not available fallback to using
the cluster CIM provider to get the needed information.

#>

    Function getClusterNodeCimInstances() 
    {
    # Change the WMI property NodeDrainStatus to DrainStatus to match the PS cmdlet output.
        Return gcim -Namespace root/mscluster MSCluster_Node -EA 3 `
        | Microsoft.PowerShell.Utility\Select-Object `
        @{ Name = "DrainStatus" ; Expression = { $_.NodeDrainStatus } } , DynamicWeight, Name, NodeWeight, FaultDomain, State
    }

<#

.SYNOPSIS
Get the cluster nodes using the cluster PowerShell cmdlets.

.DESCRIPTION
When the cluster PowerShell cmdlets are available use this preferred function.

#>

    Function getClusterNodePsInstances() 
    {
        Return Get-ClusterNode -EA 3 `
        | Microsoft.PowerShell.Utility\Select-Object DrainStatus, DynamicWeight, Name, NodeWeight, FaultDomain, State
    }

<#

.SYNOPSIS
Use DNS services to get the FQDN of the cluster NetBIOS name.

.DESCRIPTION
Use DNS services to get the FQDN of the cluster NetBIOS name.

.Notes
It is encouraged that the caller add their approprate -ErrorAction when
calling this function.

#>

    Function getClusterNodeFqdn( [ String ] $ClusterNodeName )
    {
        Return ( [ System.Net.DNS ]::GetHostEntry( $ClusterNodeName ) ).HostName
    }

<#

.SYNOPSIS
Writes message to event log as warning.

.DESCRIPTION
Writes message to event log as warning.

#>

    Function writeToEventLog( [ String ] $Message )
    {
        Microsoft.PowerShell.Management\New-EventLog   `
            -LogName                          $LogName `
            -Source                         $LogSource `
            -EA                                      3
        
        Microsoft.PowerShell.Management\Write-EventLog `
            -LogName                          $LogName `
            -Source                         $LogSource `
            -EventId                                 0 `
            -Category                                0 `
            -EntryType                         Warning `
            -Message                          $message `
            -EA                                      3
    }

<#

.SYNOPSIS
Get the cluster nodes.

.DESCRIPTION
When the cluster PowerShell cmdlets are available get the information about the cluster nodes
using PowerShell.  When the cmdlets are not available use the Cluster CIM provider.

#>

    Function getClusterNodes() 
    {
        $isClusterCmdletAvailable = getClusterPowerShellSupport

        If ( $isClusterCmdletAvailable )
        {
            $ClusterNodes = getClusterNodePsInstances
        }

        Else 
        {
            $ClusterNodes = getClusterNodeCimInstances
        }

        $ClusterNodeMap = @{}

        ForEach ( $ClusterNode in $ClusterNodes )
        {
            $ClusterNodeName = $ClusterNode.Name.ToLower()
        
            Try 
            {
                $ClusterNodeFqdn = getClusterNodeFqdn $ClusterNodeName -EA 3
            }

            Catch 
            {
                $ClusterNodeFqdn = $ClusterNodeName
                writeToEventLog "[$ScriptName]: The fqdn for node '$ClusterNodeName' could not be obtained. Defaulting to machine name '$ClusterNodeName'"
            }

            $ClusterNodeResult = [ PSCustomObject ] `
            @{  0 = @( 'FullyQualifiedDomainName' ; $clusterNodeFqdn           )
                1 = @(                     'Name' ; $clusterNodeName           )
                2 = @(            'DynamicWeight' ; $clusterNode.DynamicWeight )
                3 = @(               'NodeWeight' ; $clusterNode.NodeWeight    )
                4 = @(              'FaultDomain' ; $clusterNode.FaultDomain   )
                5 = @(                    'State' ; $clusterNode.State         )
                6 = @(              'DrainStatus' ; $clusterNode.DrainStatus   ) }

            $ClusterNodeMap.Add( $ClusterNodeName , $ClusterNodeResult )
        }
        Return $ClusterNodeMap
    }

###########################################################################
# main()
###########################################################################

    getClusterNodes

    }
## [END] Get-ClusterNodes ##

<#

.SYNOPSIS
Retrieves the inventory data for a server.

.DESCRIPTION
Retrieves the inventory data for a server.

.ROLE
Readers

#>

    Function Get-ServerInventory 
    {
        Set-StrictMode -Version 5.0

        Import-Module CimCmdlets

<#

.SYNOPSIS
Converts an arbitrary version string into just 'Major.Minor'

.DESCRIPTION
To make OS version comparisons we only want to compare the major and 
minor version.  Build number and/os CSD are not interesting.

#>

    Function ConvertOsVersion ( [string ] $OSVersion )
    {
        [ Ref ] $ParsedVersion = $null
        If ( ! [ Version ]::TryParse( $OSVersion , $ParsedVersion ) )
        {
            Return $Null
        }

        $Version = [ Version ] $ParsedVersion.Value
        Return New-Object Version -Args $Version.Major , $Version.Minor
    }

<#

.SYNOPSIS
Determines if CredSSP is enabled for the current server or client.

.DESCRIPTION
Check the registry value for the CredSSP enabled state.

#>

    Function isCredSSPEnabled() 
    {
        Set-Variable credSSPServicePath -Option Constant -Value "WSMan:\localhost\Service\Auth\CredSSP"
        Set-Variable credSSPClientPath  -Option Constant -Value  "WSMan:\localhost\Client\Auth\CredSSP"

        $CredSSPServerEnabled = $False;
        $CredSSPClientEnabled = $False;

        $CredSSPServerService = gi $CredSSPServicePath -EA 3
        If ( $CredSSPServerService )
        {
            $CredSSPServerEnabled = [ System.Convert ]::ToBoolean( $credSSPServerService.Value )
        }

        $CredSSPClientService = gi $CredSSPClientPath -EA 3
        If ( $CredSSPClientService )
        {
            $CredSSPClientEnabled = [ System.Convert ]::ToBoolean( $credSSPClientService.Value )
        }

        Return ( $CredSSPServerEnabled -or $CredSSPClientEnabled )
    }

<#

.SYNOPSIS
Determines if the Hyper-V role is installed for the current server or client.

.DESCRIPTION
The Hyper-V role is installed when the VMMS service is available.  This is much
faster then checking Get-WindowsFeature and works on Windows Client SKUs.

#>

    Function isHyperVRoleInstalled() 
    {
        $VMMSService = Get-Service -Name "VMMS" -EA 3

        Return $VMMsService -and $VMMsService.Name -eq "VMMS"
    }

<#

.SYNOPSIS
Determines if the Hyper-V PowerShell support module is installed for the current server or client.

.DESCRIPTION
The Hyper-V PowerShell support module is installed when the modules cmdlets are available.  This is much
faster then checking Get-WindowsFeature and works on Windows Client SKUs.

#>
    Function isHyperVPowerShellSupportInstalled()
    {
    # quicker way to find the module existence. it doesn't load the module.
        Return ! ! ( Get-Module -ListAvailable Hyper-V -EA 3 )
    }

<#

.SYNOPSIS
Determines if Windows Management Framework (WMF) 5.0, or higher, is installed for the current server or client.

.DESCRIPTION
Windows Admin Center requires WMF 5 so check the registey for WMF version on Windows versions that are less than
Windows Server 2016.

#>
    Function isWMF5Installed ( [ String ] $OperatingSystemVersion )
    {
        Set-Variable                     Server2016 `
        -Option                            Constant `
        -Value          ( New-Object Version '10.0' )   # And Windows 10 client SKUs

        Set-Variable                     Server2012 `
        -Option                            Constant `
        -Value           ( New-Object Version '6.2' )

    $Version = ConvertOsVersion $OperatingSystemVersion

    If ( -not $Version )
    {
        # Since the OS version string is not properly formatted we cannot know the true installed state.
        Return $False
    }

    If ( $Version -ge $Server2016 )
    {
        # It's okay to assume that 2016 and up comes with WMF 5 or higher installed
        Return $True
    }
    
    Else 
    {
        If ( $Version -ge $Server2012 )
        {
            # Windows 2012/2012R2 are supported as long as WMF 5 or higher is installed
                 $RegistryKey = 'HKLM:\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine'
            $RegistryKeyValue = gp -Path $RegistryKey -Name PowerShellVersion -EA 3

            If ( $RegistryKeyValue -and ( $RegistryKeyValue.PowerShellVersion.Length -ne 0 ) )
            {
                $InstalledWmfVersion = [ Version ] $RegistryKeyValue.PowerShellVersion

                If ( $InstalledWmfVersion -ge [ Version ] '5.0' )
                {
                    Return $true
                }
            }
        }
    }

    Return $false
}

<#

.SYNOPSIS
Determines if the current usser is a system administrator of the current server or client.

.DESCRIPTION
Determines if the current usser is a system administrator of the current server or client.

#>
    Function isUserAnAdministrator()
    {
        $r="Principal";($r,$s,$p)=($r,"Identity","BuiltInRole"|%{[Type]"Security.$r.Windows$_"});$r=(New-Object $r $s::GetCurrent()).IsInRole($p::Administrator);$r
    }

<#

.SYNOPSIS
Get some basic information about the Failover Cluster that is running on this server.

.DESCRIPTION
Create a basic inventory of the Failover Cluster that may be running in this server.

#>
    Function getClusterInformation() 
    {
        $ReturnValues = @{}

        $ReturnValues.IsS2dEnabled = $false
           $ReturnValues.IsCluster = $false
         $ReturnValues.ClusterFqdn = $null

    $Namespace = gcim -Namespace root/MSCluster -ClassName __NAMESPACE -EA 3
    If ( $Namespace )
    {
        $Cluster = gcim -Namespace root/MSCluster -ClassName MSCluster_Cluster -EA 3
        If ( $Cluster )
        {
               $ReturnValues.IsCluster = $True
             $ReturnValues.ClusterFqdn = $Cluster.FQDN
            $ReturnValues.IsS2dEnabled = ! ! ( Get-Member -InputObject $Cluster -Name "S2DEnabled" ) -and ( $Cluster.S2DEnabled -gt 0 )
        }
    }

    Return $ReturnValues
    }

<#

.SYNOPSIS
Get the Fully Qaulified Domain (DNS domain) Name (FQDN) of the passed in computer name.

.DESCRIPTION
Get the Fully Qaulified Domain (DNS domain) Name (FQDN) of the passed in computer name.

#>
    Function GetComputerFqdnAndAddress( $ComputerName ) 
    {
          $HostEntry = [ System.Net.Dns ]::GetHostEntry( $ComputerName )
        $AddressList = @()
    ForEach ( $Item in $HostEntry.AddressList )
    {
        $Address = New-Object PSObject
        $Address | Add-Member -MemberType NoteProperty -Name 'IpAddress'     -Value $Item.ToString()
        $Address | Add-Member -MemberType NoteProperty -Name 'AddressFamily' -Value $Item.AddressFamily.ToString()
        $AddressList += $Address
    }

    $Result = New-Object PSObject
    $Result | Add-Member -MemberType NoteProperty -Name 'Fqdn'        -Value $HostEntry.HostName
    $Result | Add-Member -MemberType NoteProperty -Name 'AddressList' -Value $AddressList
    Return $Result
}

<#

.SYNOPSIS
Get the Fully Qaulified Domain (DNS domain) Name (FQDN) of the current server or client.

.DESCRIPTION
Get the Fully Qaulified Domain (DNS domain) Name (FQDN) of the current server or client.

#>
    Function GetHostFqdnAndAddress ( $ComputerSystem )
    {
        $ComputerName = $ComputerSystem.DNSHostName
        If ( ! $ComputerName )
        {
            $ComputerName = $ComputerSystem.Name
        }

        Return GetComputerFqdnAndAddress $ComputerName
    }

<#

.SYNOPSIS
Are the needed management CIM interfaces available on the current server or client.

.DESCRIPTION
Check for the presence of the required server management CIM interfaces.

#>
    Function getManagementToolsSupportInformation()
    {
        $ReturnValues = @{}

    $ReturnValues.ManagementToolsAvailable = $false
    $ReturnValues.ServerManagerAvailable   = $false

    $Namespaces = gcim -Namespace root/microsoft/windows -ClassName __NAMESPACE -EA 3

    If ( $NameSpaces )
    {
        $ReturnValues.ManagementToolsAvailable = ! ! ( $Namespaces | ? { $_.Name -ieq "ManagementTools" } )
        $ReturnValues.ServerManagerAvailable   = ! ! ( $Namespaces | ? { $_.Name -ieq "ServerManager"   } )
    }
    Return $ReturnValues
}

<#

.SYNOPSIS
Check the remote app enabled or not.

.DESCRIPTION
Check the remote app enabled or not.

#>
    Function isRemoteAppEnabled() {
    Set-Variable key -Option Constant -Value "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Terminal Server\\TSAppAllowList"

    $RegistryKeyValue = gp -Path $key -Name fDisabledAllowList -EA 3

    If ( -not $RegistryKeyValue )
    {
        Return $false
    }
    Return $RegistryKeyValue.fDisabledAllowList -eq 1
}

<#

.SYNOPSIS
Check the remote app enabled or not.

.DESCRIPTION
Check the remote app enabled or not.

#>

<#
c
.SYNOPSIS
Get the Win32_OperatingSystem information

.DESCRIPTION
Get the Win32_OperatingSystem instance and filter the results to just the required properties.
This filtering will make the response payload much smaller.

#>

    Function getOperatingSystemInfo() 
    {
        Return gcim Win32_OperatingSystem `
        | Microsoft.PowerShell.Utility\Select-Object csName, Caption, OperatingSystemSKU, Version, ProductType
    }

<#

.SYNOPSIS
Get the Win32_ComputerSystem information

.DESCRIPTION
Get the Win32_ComputerSystem instance and filter the results to just the required properties.
This filtering will make the response payload much smaller.

#>

    Function getComputerSystemInfo() 
    {
        Return gcim Win32_ComputerSystem -EA 3 `
        | Microsoft.PowerShell.Utility\Select-Object TotalPhysicalMemory, DomainRole, Manufacturer, Model, `
        NumberOfLogicalProcessors, Domain, Workgroup, DNSHostName, Name, PartOfDomain
    }

###########################################################################
# main()
###########################################################################

             $OperatingSystem = getOperatingSystemInfo
              $ComputerSystem = getComputerSystemInfo
             $IsAdministrator = isUserAnAdministrator
              $FQDNAndAddress = getHostFqdnAndAddress $computerSystem
                    $Hostname = hostname
                     $NetBIOS = $env:ComputerName
  $ManagementToolsInformation = getManagementToolsSupportInformation
              $IsWmfInstalled = isWMF5Installed $OperatingSystem.Version
          $ClusterInformation = getClusterInformation -ErrorAction SilentlyContinue
 $IsHyperVPowershellInstalled = isHyperVPowerShellSupportInstalled
       $IsHyperVRoleInstalled = isHyperVRoleInstalled
            $IsCredSSPEnabled = isCredSSPEnabled
          $IsRemoteAppEnabled = isRemoteAppEnabled

$result = [ PSCustomObject ] `
@{ 0 = @(             'IsAdministrator' ; $isAdministrator                                     ) 
   1 = @(             'OperatingSystem' ; $operatingSystem                                     )
   2 = @(              'ComputerSystem' ; $computerSystem                                      )
   3 = @(                        'Fqdn' ; $fqdnAndAddress.Fqdn                                 )
   4 = @(                 'AddressList' ; $fqdnAndAddress.AddressList                          )
   5 = @(                    'Hostname' ; $hostname                                            )
   6 = @(                     'NetBios' ; $netbios                                             )
   7 = @(  'IsManagementToolsAvailable' ; $managementToolsInformation.ManagementToolsAvailable )
   8 = @(    'IsServerManagerAvailable' ; $managementToolsInformation.ServerManagerAvailable   )
   9 = @(              'IsWmfInstalled' ; $isWmfInstalled                                      )
  10 = @(                   'IsCluster' ; $clusterInformation.IsCluster                        )
  11 = @(                 'ClusterFqdn' ; $clusterInformation.ClusterFqdn                      )
  12 = @(                'IsS2dEnabled' ; $clusterInformation.IsS2dEnabled                     )
  13 = @(       'IsHyperVRoleInstalled' ; $isHyperVRoleInstalled                               )
  14 = @( 'IsHyperVPowershellInstalled' ; $isHyperVPowershellInstalled                         )
  15 = @(            'IsCredSSPEnabled' ; $isCredSSPEnabled                                    )
  16 = @(          'IsRemoteAppEnabled' ; $isRemoteAppEnabled                                  ) }

$result

}
## [END] Get-ServerInventory ##

