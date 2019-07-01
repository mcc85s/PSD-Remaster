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
#\\ - - [ PXD-Utility ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# The following script is newly formatted and contains slight alterations or adjustments made by the aforementioned auth.
# Although I am nowhere close to complete, I have given these scripts my full attention in attempting to optimize them.
# There are definitely many issues that I have noticed, but making mistakes is part of life. Learning from them, and
# making the effort to correct them is what matters the most. Comments, questions, mcook@securedigitsplus.com

# // ***************************************************************************
# // 
# // PowerShell Deployment for MDT
# //
# // File:      PSDUtility.psd1
# // 
# // Purpose:   General utility routines useful for all PSD scripts.
# // 
# // ***************************************************************************

#$VerbosePreference = "SilentlyContinue"

Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global -Force -Verbose -ErrorAction Stop

#$verbosePreference = "Continue"

$Global:PSUDataPath = ""
$Caller = Split-Path -Path $MyInvocation.PSCommandPath -Leaf

Function Get-PSDLocalDataPath
{
    Param (
        [ Switch ] $Move
    )
    # Return the cached local data path if possible
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Return the cached local data path if possible"
    If ( $global:PSUDataPath -ne "" -and ( -not $move ) )
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : global:psuDataPath is $PSUDataPath, testing access"
        If ( Test-Path $global:PSUDataPath )
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Returning data $PSUDataPath"
            Return $global:PSUDataPath
        }
    }

    # Always prefer the OS volume
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Always prefer the OS volume"

    $LocalPath = ""

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : localpath is $LocalPath"
    If ( $tsenv:OSVolumeGuid -ne "" )
    {
        If ( $tsenv:OSVolumeGuid -eq "MBR" )
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : tsenv:OSVolumeGuid is now $( $tsenv:OSVolumeGuid )"

            If ( $tsenv:OSVersion -eq "WinPE" )
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : tsenv:OSVersion is now $( $tsenv:OSVersion )"

                # If the OS volume GUID is not set, we use the fake volume guid value "MBR"
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : Get the OS image details (MBR)"
            
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : Using OS volume from tsenv:OSVolume: $( $tsenv:OSVolume )."
            
                $LocalPath = "$( $tsenv:OSVolume ):\MININT"

                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : localPath is now $LocalPath"
            }

            Else
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : tsenv:OSVersion is now $( $tsenv:OSVersion )"

                # If the OS volume GUID is not set, we use the fake volume guid value "MBR"
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : Get the OS image details (MBR)"

                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : Using OS volume from env:SystemDrive $( $env:SystemDrive )."
                $localPath = "$( $env:SystemDrive )\MININT"

                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : localPath is now $LocalPath"
            }
        }
        else
        {
            # If the OS volume GUID is set, we should use that volume (UEFI)
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Get the OS image details (UEFI)"

            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Checking for OS volume using $( $tsenv:OSVolumeGuid )."

            Get-Volume `
            | ? { $_.UniqueID -like "*$( $tsenv:OSVolumeGuid )*" } `
            | % { $localPath = "$( $_.DriveLetter ):\MININT"     }
        }
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : localpath is now $localPath"
    }
    
    if ( $localPath -eq "" )
    {
        # Look on all other volumes 
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Look on all other volumes"

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Checking other volumes for a MININT folder."

        Get-Volume `
        | ? {-not [String]::IsNullOrWhiteSpace( $_.DriveLetter ) } `
        | ? {                           $_.DriveType -eq 'Fixed' } `
        | ? {                         $_.DriveLetter -ne     'X' } `
        | ? {            Test-Path "$( $_.DriveLetter ):\MININT" } `
        | Select-Object                                -First 1    `
        | % {         $localPath = "$( $_.DriveLetter ):\MININT" }
        # [ MC ] I see you guys use '-not' quite a lot, does '!' not work in this ?

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : localpath is now $localPath"
    }
    
    # Not found on any drive, create one on the current system drive
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Not found on any drive, create one on the current system drive"
    
    If ( $LocalPath -eq "" )
    {
        $LocalPath = "$( $env:SYSTEMDRIVE )\MININT"
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : localpath is now $localPath"
    }
    
    # Create the MININT folder if it doesn't exist
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Create the MININT folder if it doesn't exist"
    
    If ( ( Test-Path $LocalPath ) -eq $False )
    {
        New-Item -ItemType Directory -Force -Path $localPath | Out-Null
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : localpath is now $localPath"
    }
    
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : localpath set to $LocalPath"
    $global:PSUDataPath = $LocalPath
    Return $LocalPath
}

Function Initialize-PSDFolder
{
    Param( $FolderPath ) 

    If ( ( Test-Path $FolderPath ) -eq $False ) {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Creating $FolderPath"
        New-Item -ItemType Directory -Force -Path $FolderPath | Out-Null
    }
}

Function Start-PSDLogging
{
    $logPath = "$( Get-PSDLocalDataPath )\SMSOSD\OSDLOGS"
    Initialize-PSDfolder $logPath
    Start-Transcript "$logPath\$caller.transcript.log" -Append
    Write-Verbose -Message "$( $MyInvocation.MyCommand.Name )
    : Logging transcript to $logPath\$caller.transcript.log"

    #Writing to CMtrace file
    #Set PSDLogPath
    $PSDLogFile = "$( $( $Caller ).Substring( 0 , $( $caller ).Length-4 ) ).log"
    $Global:PSDLogPath = "$logPath\$PSDLogFile"
    
    #Create logfile
    If ( ! ( Test-Path $Global:PSDLogPath ) )
    {
        ## Create the log file
        New-Item $Global:PSDLogPath -Type File | Out-Null
    } 

    Write-Verbose -Message "$( $MyInvocation.MyCommand.Name )
    : Logging CMtrace logs to $Global:PSDLogPath"
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Logging CMtrace logs to $Global:PSDLogPath"
}

Function Stop-PSDLogging
{
    Stop-Transcript
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Stop Transcript Logging"
}

Function Write-PSDLog
{
    Param (
        
        [ Parameter ( Mandatory = $true ) ]
        
            [ String ] $Message ,
                                             
        [ Parameter () ][ ValidateSet ( 1 , 2 , 3 ) ]
        
            [ String ] $LogLevel = 1 )

    # Don't log any lines containing the word password
    If ( $Message -like '*password*' ) 
    {
        $Message = "<Message containing password has been suppressed>"
    }
    
    # PSDDebug settings
    If ( $tsenv:PSDDebug -eq "YES" )
    {
        $WriteToScreen = $true
    }

    #check if we have a logpath set
    If ( $Global:PSDLogPath -ne $Null )
    {
        If ( ! ( Test-Path -Path $Global:PSDLogPath ) )
        {
            ## Create the log file
            New-Item $Global:PSDLogPath -Type File | Out-Null
        }

        $IS       = $( $MyInvocation.ScriptName | Split-Path -Leaf -EA 0 ) ,
                                                                       "." ,
                    $( $MyInvocation.ScriptLineNumber                    )
        $Hour       =                      ( Get-Date -Format   HH:mm:ss )
        $Date       =                      ( Get-Date -Format MM-dd-yyyy )
        $Time       =            "$Hour.$( ( Get-Date ).Millisecond )+000"
        $Log        =                                  '<![LOG[{0}]LOG]!>' ,
                                                          '<time = "{1}" ' ,
                                                           'date = "{2}" ' ,
                                                            'COM = "{3}" ' ,
                                                        'context = "" '    ,
                                                           'type = "{4}" ' ,
                                                         'thread = "" '    ,
                                                           'file = "" >'
        $Type       =                                     -join  $IS[0..2]
        $LineOutput  =                                    -join $Log[0..7]
        $LineFormat =          $Message , $Time , $Date , $Type , $LogLevel
        $Line       =                            $LineOutput -f $LineFormat

        # Log to ScriptFile
        Add-Content -Value $Line -Path $Global:PSDLogPath

        # Log to NetworkShare
        If ( $DynLogging -eq $True )
        {
            Add-Content -Value $Line -Path $PSDDynLogPath -ErrorAction SilentlyContinue
        }

        # Log to MasterFile
        Add-Content -Value $Line -Path ( "$( $Global:PSDLogPath | Split-Path )\PSD.log" )
    }

    If ( $WriteToScreen -eq $True )
    {
        Switch ( $LogLevel )
        {
            '1'{ Write-Verbose -Message $Message }
            '2'{ Write-Warning -Message $Message }
            '3'{ Write-Error   -Message $Message }
            Default {}
        }
    }
}

Start-PSDLogging

Function Save-PSDVariables
{
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Save-PSDVariables"

    $V = [ XML ]"<?xml version=`"1.0`" ?><MediaVarList Version=`"4.00.5345.0000`"></MediaVarList>"
    gci TSEnv: | % `
    {
        $Element = $V.CreateElement( "Var" )
        $Element.SetAttribute( "Name" ,  $_.Name ) | Out-Null
        $Element.AppendChild( $V.createCDATASection( $_.Value ) ) | Out-Null
        $V.DocumentElement.AppendChild( $Element ) | Out-Null
    }
    $Path = "$( Get-PSDLocaldataPath )\Variables.dat"
    $V.Save( $Path )
    Return $Path
}

Function Restore-PSDVariables
{
    $Path = "$( Get-PSDLocaldataPath )\Variables.dat"
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Restore-PSDVariables from $Path"
    
    If ( Test-Path -Path $Path )
    {
        [ XML ] $v = Get-Content -Path $Path
        $V | Select-Xml -Xpath "//var" | % { Set-Item tsenv:$( $_.Node.Name ) -Value $_.Node.'#cdata-section' } 
    }
    Return $Path
}

Function Clear-PSDInformation # What if we disabled this part ? For instance, 
# if an installation stalls, but the files were already copied over... Bet it 
# produces a log file that shows some pretty important stuff - and I happen to 
# have seen what it says. Not exactly cool with what I saw, but, that's why you
# need help with this. I'll help you finish this, but it needs to be done the
# right way. Until you add me to the PSD project so I can make changes, these 
# files will remain as PXD-Master.

{
    # Create a folder for the logs
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Create a folder for the logs"

    $LogDest = "$( $env:SystemRoot )\Temp\DeploymentLogs"
    Initialize-PSDFolder $LogDest

    # Process each volume looking for MININT folders
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Process each volume looking for MININT folders"
    Get-Volume `
    | ? { -not [ String ]::IsNullOrWhiteSpace( $_.DriveLetter ) } `
    | ? {                              $_.DriveType -eq 'Fixed' } `
    | ? {                            $_.DriveLetter -ne     'X' } `
    | ? {               Test-Path "$( $_.DriveLetter ):\MININT" } `
    | % {            
    
    # Stay in ForEach-Object Loop ?
    $localPath = "$( $_.DriveLetter ):\MININT"

        # Copy PSD logs
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Copy PSD logs"
        
        If ( Test-Path "$localPath\SMSOSD\OSDLOGS" )
        {
            Copy-Item "$localPath\SMSOSD\OSDLOGS\*" $LogDest -Force
        }

        # Copy Panther logs
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Copy Panther logs"
        
        If ( Test-Path "$localPath\Logs" )
        {
            & Xcopy $env:SystemRoot\Panther $LogDest /s /e /v /d /y /i | Out-Null
        }

        # Copy SMSTS log
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Copy SMSTS log"

        If ( Test-Path "$localPath\Logs" )
        {
            Copy-Item -Path $env:LOCALAPPDATA\temp\smstslog\smsts.log -Destination $LogDest
        }

        # Check if DEVRunCleanup is set to NO
        If ( $( $tsenv:DEVRunCleanup ) -eq "NO" )
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : tsenv:DEVRunCleanup is now $tsenv:DEVRunCleanup"

            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Cleanup will not remove MININT or Drivers folder"
        }

        Else
        {

            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : tsenv:DEVRunCleanup is now $tsenv:DEVRunCleanup"

            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Cleanup will remove MININT and Drivers folder"

            # Remove the MININT folder
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Remove the MININT folder"

            Try
            {
                Remove-Item "$LocalPath" -Recurse -Force
            }

            Catch
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : Unable to completely remove $LocalPath."
            }

            # Remove the Drivers folder
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Remove the Drivers folder"

            Try
            {
                Remove-Item "$env:Systemdrive\Drivers" -Recurse -Force
            }
            catch
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : Unable to completely remove $( $env:Systemdrive )\Drivers"
            }
        }
    }

    # Cleanup start folder
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Cleanup start folder"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Removing link to re-run $PSCommandPath from the all users Startup folder"

    # Remove shortcut to PSDStart.ps1 if it exists
    $AllUsersStartup = [ Environment ]::GetFolderPath( 'CommonStartup' )
    $LinkPath = "$AllUsersStartup\PSDStartup.lnk"
    If ( Test-Path $LinkPath )
    {
        $Null = Get-Item -Path $linkPath | Remove-Item -Force
    }

    # Cleanup AutoLogon
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Cleanup AutoLogon"

    $WinLogon = 
    @{  Path  = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        Name  = "AutoAdminLogon" , ( "UserName" , "Password" | % { "Default$_" } )
        Value = 0 , "" , "" }
    
    0..2 | % { $Null = sp -Path $Winlogon.Path -Name $Winlogon.Name[$_] -Value $Winlogon.Value[$_] -Force }

    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): AutoLogon has been removed"
}

Function Copy-PSDFolder
{
    Param (
        
        [ Parameter ( Mandatory = $True , Position = 1 ) ] [ String ] $Source ,
        
        [ Parameter ( Mandatory = $True , Position = 2 ) ] [ String ] $Destination )

    $Copy = ( $Source , $Destination ).TrimEnd( "\" )

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Copying folder $( $Copy[0] ) to $( $Copy[1] ) using XCopy"

    & Xcopy ( $s = $Copy[0] ) ( $d = $Copy[1] ) /s /e /v /d /y /i | Out-Null
}

Function Test-PSDNetCon
{
    Param ( $HostName , $Protocol )
    
    Switch ( $Protocol )
    {   SMB   { $Port =  445 }
        HTTP  { $Port =   80 }
        HTTPS { $Port =  443 }
        WINRM { $Port = 5985 }
      Default {         Exit }  }

    Try
    {
        $IPS = ( [ System.Net.DNS ]::GetHostAddresses( $HostName ) `
        | ?                      $_.AddressFamily -EQ InterNetwork `
        | Select-Object                        IPAddressToString ).IPAddressToString

        If ( $IPS.GetType().Name -eq "Object[]" )
        {
            $IPS
        }
    }

    Catch
    {
        Write-Verbose "Possibly $HostName is wrong hostname or IP"
        $IPS = "NA"
    }

    ForEach ( $IP in $IPS )
    {
        $TcpClient = New-Object Net.Sockets.TCPClient

        Try
        {
            Write-Verbose "Testing $( $IP ):$( $Port )"
            $TCPClient.Connect( $IP , $Port )
        }

        Catch
        {
        }

        If ( $TCPClient.Connected )
        {
            $TCPClient.Close()
            $Result = $True
            Return $Result
            Break
        }

        Else
        {
            $Result = $false
        }
    }
    Return $Result
}

Function Get-PSDDriverInfo
{
    Param ( $Path = $Driver.FullName )

    #Get filename
    $InfName   = $Path | Split-Path -Leaf

    $Pattern   = 'DriverVer'
    $Content   = Get-Content -Path $Path
   #$DriverVer = $Content | Select-String -Pattern $Pattern
    $DriverVer = ( ( $Content | Select-String -Pattern $Pattern -CaseSensitive ) `
                    -Replace '.*=(.*)' , '$1' ) -Replace ' ' , '' -Replace ',' , '-' -Split "-"

    $DriverVersion = ( $DriverVer[1] -Split ";" )[0]

    $Pattern   = 'Class'
    $Content   = Get-Content -Path $Path
    $Class     = ( ( ( $Content | Select-String -Pattern $Pattern ) -NotLike "ClassGUID*" ) )[0] `
                    -Replace " " , "" -Replace '.*=(.*)' , '$1' -Replace '"' , ''


    $Provider = ( $Content | Select-String '^\s*Provider\s*=.*' ) -Replace '.*=(.*)' , '$1'

    If ( $Provider.Length -eq 0 )
    {
        $Provider = ""
    }

    ElseIf ( $Provider.Length -gt 0 -And $Provider -is [ System.Array ] )
    {
        If ( $Provider.Length -gt 1 -And $Provider[0].Trim( " " ).StartsWith( "%" ) )
        {
            $Provider = $Provider[1] ;
        } 
        Else 
        {
            $Provider = $Provider[0]
        }
    }

    $Provider = $Provider.Trim( ' ' )

    If ( $Provider.StartsWith( "%" ) )
    {
        $Provider   = $Provider.Trim( '%' )
        $Manufacter = ( $Content | Select-String "^$Provider\s*=" ) -Replace '.*=(.*)' , '$1'
    }

    Else 
    {
        $Manufacter = ""
    }    

    If ( $Manufacter.Length -eq 0 )
    {
        $Manufacter = $Provider
    } 
    ElseIf ( $Manufacter.Length -gt 0 -And $Manufacter -is [ System.Array ] )
    {
        If ( $Manufacter.Length -gt 1 -And $Manufacter[0].Trim( " " ).StartsWith( "%" ) )
        {
            $Manufacter = $Manufacter[1] ;
        }
        Else
        {
            $Manufacter = $Manufacter[0]
        }
    }
    $Manufacter = $Manufacter.Trim( ' ' ).Trim( '"' )

    $HashTable = [ Ordered ] `
    @{  Name         =       $InfName
        Manufacturer =    $Manufacter
        Class        =         $Class
        Date         =  $DriverVer[0]
        Version      = $DriverVersion }
    
    New-Object -TypeName PSObject -Property $HashTable
}

Function Show-PSDInfo
{
    Param ( $Message , [ ValidateSet ( "Information" , "Warning" , "Error" ) ]
            $Severity         = "Information" ,
            $OSDComputerName                  ,
            $DeployRoot                       )

    $File = {
    Param ( $Message , 
            $Severity         = "Information" ,
            $OSDComputerName                  ,
            $DeployRoot                       )
    
    Switch ( $Severity )
    {       'Error'       { $BackColor = "Salmon"  ; $Label0Text = "Error"       }
            'Warning'     { $BackColor = "Yellow"  ; $Label0Text = "Warning"     }
            'Information' { $BackColor = "#F0F0F0" ; $Label0Text = "Information" }
            Default       { $BackColor = "#F0F0F0" ; $Label0Text = "Information" } }

    gwmi Win32_ComputerSystem        `
                      | %            `
    {   $Manufacturer = $_.Manufacturer
               $Model = $_.Model
              $Memory = [ Int ] ( $_.TotalPhysicalMemory / 1024 / 1024 ) }

    gwmi Win32_ComputerSystemProduct `
                      | %            `
    {           $UUID = $_.UUID }
    
    gwmi Win32_BaseBoard             `
                      | %            `
    {        $Product =            $_.Product
        $SerialNumber =       $_.SerialNumber }

    Try   { Get-SecureBootUEFI -Name SetupMode | Out-Null ; $BIOSUEFI = "UEFI" } 
    Catch { $BIOSUEFI = "BIOS" }

    gwmi Win32_SystemEnclosure `
                     | % `
    {      $AssetTag = $_.SMBIOSAssetTag.Trim()
            $Chassis =        $_.ChassisTypes[0]
             $Filter = @{   
                   0 = @( 8..12 ; 14 ; 18 ; 21 )
                   1 = @( 3..7 ; 15 ; 16 )
                   2 = @( 17 ; 23 )
                   3 = @( 34..36 )
                   4 = @( 13 ; 30..32 ) }
               $Type = "Laptop" , "Desktop" , "Server" , "Small Form Factor" , "Tablet"
                0..4 | ? { if ( $Chassis -in $Filter[$_] ) { 
         $ChassiType = $Type[$_] } } }

    gwmi Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 1" `
    | Select-Object  @{ Name =  'IP' ; Expression =        { $_.IPAddress } } , 
                     @{ Name = 'MAC' ; Expression =       { $_.MacAddress } } , 
                     @{ Name =  'GW' ; Expression = { $_.DefaultIPGateway } } `
                             | % `
    {  if (  $_.IP ) {  $IP  = @() 
                       $_.IP | % {  
                        $IP += $_  } }
       if ( $_.MAC ) { $MAC  = @() 
                      $_.MAC | % { 
                       $MAC += $_  } }
       if (  $_.GW )  {  $GW = @() 
                       $_.GW | % {  
                        $GW += $_  } } }

                  $IPAddress =  $IP
                 $MacAddress = $MAC
             $DefaultGateway =  $GW

    Try
    {
        Add-Type -AssemblyName System.Windows.Forms -IgnoreWarnings
        [ System.Windows.Forms.Application ]::EnableVisualStyles()
    } # It's 2019, we don't want to use Forms anymore. I'll get this running with WPF/XAML when I know more about the process
      # Hell. I'm thinking of getting 'a cool idea I have for [ Virtualized ASP.Net MVC ] ' into this environment.

    Catch [ System.UnauthorizedAccessException ]
    {
        # This should never happen, but we're catching if it does anyway.
        Start-Process PowerShell -Args `
        {
            Write-Warning -Message 'Access denied when trying to load required assemblies, cannot display the summary window.'
            Pause
        } -Wait
    Exit 1
    }

    Catch [ System.Exception ]
    {
    # This should never happen either, but we're catching if it does anyway.
        Start-Process PowerShell -Args `
        {
            Write-Warning -Message 'Unable to load required assemblies, cannot display the summary window.'
            Pause
        } -Wait
    Exit 1
    }

    # For now I'll code the math for future use . . .

                $Form = New-Object System.Windows.Forms.Form ,
    @{     ClientSize = '600 , 390'
                 Text = "PSD"
        StartPosition = "CenterScreen"
            BackColor = $BackColor
              TopMost = $True
                 Icon = [ System.Drawing.Icon ]::ExtractAssociatedIcon( "$PSHome\powershell.exe" ) }

          $Label_Text = "$Label1Text" , "OSDComputername: $OSDComputername" , "DeployRoot: $Deployroot" ,
                      "Model: $Model" ,       "Manufacturer: $Manufacturer" ,     "Memory(MB): $Memory" ,
               "BIOS/UEFI: $BIOSUEFI" ,       "SerialNumber: $SerialNumber" ,             "UUID: $UUID" ,
            "ChassiType: $ChassiType"

          $Label_Font = @( 0    | % { "Segoe UI , 14" } ) + 
                        @( 1..9 | % { "Segoe UI , 10" } )
            $Label_FY = 10 , 180 , 200 , 220 , 240 , 260 , 280 , 300 , 320 , 340
               $Label = @( 0..9 | % { $_ = New-Object System.Windows.Forms.Label } )

         $Label[0..9] | % `
    {      $Label[$_] = 
    @{           Text = $L_Text[$_]
             AutoSize = $True
                Width = 25
               Height = 10 
             Location = New-Object System.Drawing.Point( 25 , $Label_FY[$_] )
                 Font = $Label_Font[$_] } }

            $TextBox1 = New-Object System.Windows.Forms.TextBox , 
    @{      Multiline = $True
                Width = 550
               Height = 100
             Location = New-Object System.Drawing.Point( 25 , 60 )
                 Font = 'Segoe UI , 12'
                 Text = $Message
             ReadOnly = $True }

             $Button1 = New-Object System.Windows.Forms.Button , 
    @{           Text = "Ok"
                Width = 60
               Height = 30
             Location = New-Object System.Drawing.Point( 500 , 300 )
                 Font = 'Segoe UI , 12' }
                 
    $Form.Controls.AddRange( @( $Label[0..9] , $TextBox1 , $Button1 ) )

    $Button1.Add_Click( { Ok } )
    
    Function Ok () { $Form.Close() }

    [ Void ] $Form.ShowDialog()

}

    $ScriptFile = "$env:TEMP\Show-PSDInfo.ps1"
    $File | Out-File -Width 255 -FilePath $ScriptFile

    If ( ( $OSDComputername -eq "" ) -or ( $OSDComputername -eq $null ) )
    {
        $OSDComputername = $env:COMPUTERNAME
    }

    If ( ( $Deployroot -eq "" ) -or ( $Deployroot -eq $null ) )
    {
        $Deployroot = "NA"
    }

    Start-Process -FilePath PowerShell.exe `
        -Args $ScriptFile , "'$Message'" , $Severity , $OSDComputername , $Deployroot
}

Function Get-PSDInputFromScreen
{
    Param ( $Header , $Message , [ ValidateSet ( "Ok" , "Yes" ) ] $ButtonText )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

                $Form = New-Object System.Windows.Forms.Form , 
    @{           Text = $Header
                 Size = New-Object System.Drawing.Size(  400 , 200 )
        StartPosition = 'CenterScreen' }

             $Button1 = New-Object System.Windows.Forms.Button ,
    @{       Location = New-Object System.Drawing.Point( 290 , 110 )
                 Size = New-Object System.Drawing.Size(   80 ,  30 )
                 Text = $ButtonText
         DialogResult = [ System.Windows.Forms.DialogResult ]::OK
         AcceptButton = $Button1 }
    

              $Label1 = New-Object System.Windows.Forms.Label ,
    @{       Location = New-Object System.Drawing.Point(   10 , 20 )
                 Size = New-Object System.Drawing.Size(   300 , 20 )
                 Text = $Message }

             $TextBox = New-Object System.Windows.Forms.TextBox ,
    @{       Location = New-Object System.Drawing.Point(   10 , 40 )
                 Size = New-Object System.Drawing.Size(   360 , 20 ) }


    $Form.Controls.AddRange( @( $Button1 , $Label1 , $TextBox ) )
    $Form.Topmost = $True
    $Form.Add_Shown( { $TextBox.Select() } )
    $Result       = $Form.ShowDialog()

    Return $TextBox.Text
}

Function Invoke-PSDHelper
{
    Param ( $MDTDeploySharePath , $UserName , $Password )

    #Connect
    & Net Use $MDTDeploySharePath $Password /USER:$UserName

    #Import Env
    Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global `
        -Force -Verbose

    Import-Module PSDUtility `
        -Force -Verbose

    Import-Module PSDDeploymentShare `
        -Force -Verbose

    Import-Module PSDGather `
        -Force -Verbose

    Dir tsenv: | Out-File "$( $env:SystemDrive )\DumpVars.log"
    Get-Content -Path "$( $env:SystemDrive )\DumpVars.log"
}

Function Invoke-PSDEXE
{
    [ CmdletBinding ( SupportsShouldProcess = $true ) ] Param (

        [ Parameter ( Mandatory = $True , Position = 0 ) ] [ ValidateNotNullOrEmpty () ]

            [ String ] $Executable ,

        [ Parameter ( Mandatory = $False , Position = 1 ) ]
        
            [ String ] $Arguments )

    If ( $Arguments -eq "" )
    {
        Write-Verbose "Running Start-Process -FilePath $Executable -NoNewWindow -Wait -Passthru"
        $ReturnFromEXE = Start-Process -FilePath $Executable -NoNewWindow -Wait -Passthru
    }
    
    Else
    {
        Write-Verbose "Running Start-Process -FilePath $Executable -Args $Arguments -NoNewWindow -Wait -Passthru"
        $ReturnFromEXE = Start-Process -FilePath $Executable -Args $Arguments -NoNewWindow -Wait -Passthru
    }
    Write-Verbose "Returncode is $( $ReturnFromEXE.ExitCode )"

    Return $ReturnFromEXE.ExitCode
}

Function Set-PSDCommandWindowsSize
{
    <#
    .Synopsis
    Resets the size of the current console window
    .Description
    Set-myConSize resets the size of the current console window. By default, it
    sets the windows to a height of 40 lines, with a 3000 line buffer, and sets the 
    the width and width buffer to 120 characters. 
    .Example
    Set-myConSize
    Restores the console window to 120x40
    .Example
    Set-myConSize -Height 30 -Width 180
    Changes the current console to a height of 30 lines and a width of 180 characters. 
    .Parameter Height
    The number of lines to which to set the current console. The default is 40 lines. 
    .Parameter Width
    The number of characters to which to set the current console. Default is 120. Also sets the buffer to the same value
    .Inputs
    [int]
    [int]
    .Notes
        Author: Charlie Russel
     Copyright: 2017 by Charlie Russel
              : Permission to use is granted but attribution is appreciated
       Initial: 28 April, 2017 (cpr)
       ModHist:
              :
    #>
    [ CmdLetBinding () ] Param (

         [ Parameter ( Mandatory = $False , Position = 0 ) ]
         
            [ Int ] $Height = 40 ,

         [ Parameter ( Mandatory = $False , Position = 1 ) ]

             [ Int ] $Width = 120 )

               $Console = $Host.UI.RawUI
                $Buffer = $Console.BufferSize
               $ConSize = $Console.WindowSize

    # If the Buffer is wider than the new console setting, first reduce the buffer, then do the resize
    If ( $Buffer.Width -gt $Width ) 
    {
         $ConSize.Width = $Width
    $Console.WindowSize = $ConSize
    }

          $Buffer.Width = $Width
         $ConSize.Width = $Width
         $Buffer.Height = 3000
    $Console.BufferSize = $Buffer
               $ConSize = $Console.WindowSize
         $ConSize.Width = $Width
        $ConSize.Height = $Height
    $Console.WindowSize = $ConSize
}

Function Get-PSDNtpTime
{
    ( [ String ] $NTPServer )

# From https://www.madwithpowershell.com/2016/06/getting-current-time-from-ntp-service.html

# Build NTP request packet. We'll reuse this variable for the response packet

                  $NTPData = New-Object byte[] 48 
                  # Array of 48 bytes set to zero

               $NTPData[0] = 27                    
               # Request header: 00 = No Leap Warning; 011 = Version 3; 011 = Client Mode; 00011011 = 27

    # Open a connection to the NTP service

                   $Socket = New-Object Net.Sockets.Socket ( 'InterNetwork' , 'Dgram' , 'Udp' )
       $Socket.SendTimeOut = 2000  # ms
    $Socket.ReceiveTimeOut = 2000  # ms
    $Socket.Connect( $NTPServer, 123 )

                     # Make the request
                     $Null = $Socket.Send(    $NTPData )
                     $Null = $Socket.Receive( $NTPData )

    # Clean up the connection
    $Socket.Shutdown( 'Both' )
    $Socket.Close(           )

    # Extract relevant portion of first date in result (Number of seconds since "Start of Epoch")
    $Seconds = [ BitConverter ]::ToUInt32( $NTPData[ 43..40 ] , 0 )

    # Add them to the "Start of Epoch", convert to local time zone, and return
    ( [ datetime ] '1/1/1900' ).AddSeconds( $Seconds ).ToLocalTime()
} 

Function Write-PSDEvent
{
    Param ( $MessageID , $Severity , $Message )

    If ( $tsenv:EventService -eq "" )
    {
        Return
    }
    
    # a Deployment has started                ( EventID 41016 )
    # a Deployment completed successfully     ( EventID 41015 )
    # a Deployment failed                     ( EventID 41014 )
    # an error occurred                       ( EventID     3 )
    # a warning occurred                      ( EventID     2 )

    If ( $tsenv:LTIGUID -eq "" )
    {
        $LTIGUID = ( [ guid ]::NewGuid() ).GUID
        New-Item -Path TSEnv: -Name "LTIGUID" -Value "$LTIGUID" -Force
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : tsenv:LTIGUID is now: $tsenv:LTIGUID"
        Save-PSDVariables
    }

         $MacAddress = $tsenv:MacAddress001
              $Lguid = $tsenv:LTIGUID
                 $id = $tsenv:UUID
             $vmhost = 'NA'
       $ComputerName = $tsenv:OSDComputerName

        $CurrentStep = $tsenv:_SMSTSNextInstructionPointer

	If ( $CurrentStep -eq "" )
    {
        $CurrentStep = '0'
    }

	     $TotalSteps = $tsenv:_SMSTSInstructionTableSize

 	If ( $TotalSteps -eq "")
    {
        $TotalSteps  = '0'
    }

    # Sends reports to the MDT Monitoring Service, AKA BDD.Utility
    $MDTMonitorService = 
    "$tsenv:EventService/MDTMonitorEvent/PostEvent?" , # Name
    "uniqueID=$Lguid"                                , # GUID
    "&computerName=$ComputerName"                    , # Host Name
    "&messageID=$messageID"                          , # Message ID
    "&severity=$severity"                            , # Severity
    "&stepName=$CurrentStep"                         , # Current Step 
    "&totalSteps=$TotalSteps"                        , # Total Steps
    "&id=$id,$macaddress"                            , # MDT Installation ID
    "&message=$Message"                              , # Message
    "&dartIP="                                       , # DART IP ( Unused )
    "&dartPort="                                     , # DART Port ( Unused )
    "&dartTicket="                                   , # DART Ticket ( Unused )
    "&vmHost=$vmhost"                                , # VM Host Name / Used for VMS
    "&vmName=$ComputerName"                            # VM HostName 

    $Return = Invoke-WebRequest ( -join $MDTMonitorService[0..13] ) -UseBasicParsing
}
