
$CPU = $Env:Processor_Architecture         
$Path = "" , "\WOW6432Node" `
| % { "HKLM:\Software$_\Microsoft\Windows\CurrentVersion\Uninstall" }
If ( $CPU -eq "x86" ) { $Reg = $Path[ 0    ] | % { GP "$_\*" } }
Else                  { $Reg = $Path[ 0..1 ] | % { GP "$_\*" } }

$Program = @{ 
    Name              = "Adobe Acrobat Reader DC MUI"
    MUIurl            = "http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1901020064/AcroRdrDC1901020064_MUI.exe"
    MUIchecksum       = "81953f3cf426cbe9e6702d1af7f727c59514c012d8d90bacfb012079c7da6d23"
    MUImspURL         = "http://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/1901220035/AcroRdrDCUpd1901220035_MUI.msp"
    MUImspChecksum    = "67AAB19943FA63393F15E1354FACCE65BED476D1C2BB5D311DB8450614A33200" }

$Adobe = $Reg | ? { $_.DisplayName -match "$( $Program.Name )" } `
| Select    @{ Name =    "Name" ; Expression = { $_.DisplayName     } } ,
            @{ Name = "Version" ; Expression = { $_.DisplayVersion  } } ,
            @{ Name =  "Remove" ; Expression = { $_.UninstallString } } 
Echo $Adobe 

( $MUIInstalled , $UpdateOnly ) = 0..1 | % { $False }

$Adobe | ? { $_.Remove.Count -eq 1 } 
{
    $Version = 
    @{  Installed = $_.Version.Replace( '.' , '' )
        Installer = $Program.MUIURL.Split( '/' )[ -2 ] }

    If ( $_.Name -notlike "*MUI*" ) 
    {
        Write-Warning "Single-Language Installation detected . . . "

        If ( $Version.Installed -ge $Version.Installer )
        {   "[ $( $_.Name ) Version: $( $_.Version  ) ]"               ,
            " - - - - [ is newer than ] - - - - "                      ,
            "[ $( $_.Name ) Version: $( $Version.Installer ) ]"        ,
            " - - - - [ Manual Removal required ] - - - - "            ,
            "Exiting"                                                  `
            | % { Write-Warning $_ }
            Exit 
        }

        Else
        {   
            Write-Warning "[ Automatic Upgrade Commencing ]" 
        } 
    }

    Else
    {
        $MUIInstalled   = $True
        $UpdaterVersion = $Program.MUImspURL.Split( '/' )[ -2 ]

        If ( $Version.Installed -eq $UpdaterVersion )
        {
            Write-Verbose "Installed version is already up to date. Exiting."
            Exit
        }
        
        ElseIf ( $Version.Installed -gt $UpdaterVersion )
        {
            "[ $( $_.Name ) v20$( $_.Version ) ] is installed,"          ,
            "v$Env:ChocolateyPackageVersion can't overwrite a newer version. Exiting." `
            | % { Write-Warning $_ }
            Exit
        }

        ElseIf ( ( $Version.Installed -ge $Version.Installer ) -and ( $Version.Installed -lt $UpdaterVersion ) )
        {
            $UpdateOnly = $True
        }
    }
}

$Adobe | ? { $_.Remove.Count -gt 1 } 
{   "Multiple installs of $( $_.Name ) found." ,
    "[ $( $_.Name ) v$( $_.Version) ] " ,
    "Exiting" `
    | % { Write-Warning $_ }
    Exit 
}

$DownloadArgs = 
@{  packageName         =                                                          $Env:ChocolateyPackageName
    FileFullPath        =  "$Env:Temp\$Env:ChocolateyPackageName.$Env:ChocolateyPackageVersion.Installer.exe"
    URL                 =                                                                     $Program.MUIurl
    checksum            =                                                                $Program.MUIchecksum
    checksumType        =                                                                            'SHA256'
    GetOriginalFileName =                                                                              $True }

$MUIexePath =                                                             Get-ChocolateyWebFile @DownloadArgs
$Options    =                                                                     ' DISABLEDESKTOPSHORTCUT=1'


If ( $PackageParameters.DesktopIcon ) 
{ 
    $options +=                                                                                            '' 
    Write-Host                                                                'You requested a desktop icon.' `
        -F                                                                                                 11 }

If ( $PackageParameters.NoUpdates )
{
    $RegRoot       =                                                                'HKLM:\SOFTWARE\Policies'
    $RegFull       =                                                'Adobe\Acrobat Reader\DC\FeatureLockDown'
    $RegRecurse    =                                                                    $RegFull.Split( '\' )

    0..( $RegRecurse.Count - 1 ) `
    | % {   If ( $_ -eq 0 ) { $RegPath = "$RegRoot\$( $RegRecurse[$_] )" }
            Else            { $RegPath = "$RegPath\$( $RegRecurse[$_] )" }

            If ( ( Test-Path $RegPath ) -ne $True )
            {   $Null =                                                                                   NI `
                    -Path                                                                           $RegPath `
                    -Name                                                                    $RegRecurse[$_] } }

    $RegFull       =                                                                     "$RegRoot\$RegFull"

    If ( ( Test-Path $RegFull ) -eq $True )
    {
        $Null =                                                                                           SP `
            -Path                                                                                   $RegFull `
            -Name                                                                                 'bUpdater' `
            -Type                                                                                      DWORD `
            -Value                                                                                         0 `
            -Force                                                                                           } 
}

If ( ! ( $PackageParameters.UpdateMode ) )
{   
    $UpdateMode =                                                                                          0
}
 
Else 
{   
    $UpdateMode =                                                              $PackageParameters.UpdateMode
}

If ( ( 0..4 ) -contains $UpdateMode )
{   
    $Sw =                                                   "Configuring manual update checks and installs." , 
                                                          "You requested manual update checks and installs." ,
                                             "You requested automatic update downloads and manual installs." ,
                                                               "You requested scheduled, automatic updates." ,
                                                           "You requested notifications but manual updates."

    Switch ( $UpdateMode ) 
    { 0 { Write-Host "$( $Sw[0] )" -F 11 }
      1 { Write-Host "$( $Sw[1] )" -F 11 }
      2 { Write-Host "$( $Sw[2] )" -F 11 }
      3 { Write-Host "$( $Sw[3] )" -F 11 }
      4 { Write-Host "$( $Sw[4] )" -F 11 } }

    If ( $MUIinstalled )
    {   
        "HKLM:\SOFTWARE\Adobe\Adobe ARM\1.0\ARM" `
        | % {   
                If ( Test-Path $_ )
                {
                    $Null = SP -Path $_ -Name 'iCheckReader' -Value $UpdateMode -Force } 
                }
    
        $GUID = "{$( $Adobe.Remove.Split('{')[-1] )"
        
        "HKLM:\SOFTWARE\Wow6432Node\Adobe\Adobe ARM\Legacy\Reader\$GUID" `
        | % {   
                If ( Test-Path $_ )
                {
                    $Null = SP -Path $_ -Name 'Mode' -Value $UpdateMode -Force }
                }
    }

    Else
    {   
        $options += " UPDATE_MODE=$UpdateMode"   
    }
}


$1603 = "For code 1603, Adobe recommends to 'shut down Microsoft Office and all web browsers' and try again." , 
        "The install log should provide more details about the encountered issue:" , 
        "   $( $DownloadArgs.FileFullPath )" , 
        "Installation of $env:ChocolateyPackageName was unsuccessful."
        "Exception Thrown. Exiting"

If ( ! $UpdateOnly )
{
    $packageArgsEXE    = 
    @{  packageName    = "$env:ChocolateyPackageName (installer)"
        fileType       = 'EXE'
        File           = $MUIexePath
        checksumType   = 'SHA256'
        silentArgs     = "/sAll /msi /norestart /quiet ALLUSERS=1 EULA_ACCEPT=YES $options /L*v '$( $DownloadArgs.FileFullPath.Replace( 'er.exe' , '.log' ) )'"
        validExitCodes = 0 , 1000 , 1101 , 1603 }

    $exitCode = Install-ChocolateyInstallPackage @packageArgsEXE
    
    If ( $ExitCode -eq 1603 )
    {  $1603 | % { If ( $_ -eq 2 ) { Write-Error "   $(  $DownloadArgs.FileFullPath.Replace( 'er.exe' , '.log' ) )" } 
                   Else            { Write-Error "$_"                                                             } } 
    } 
} 

If ( $Program.MUIurl.Split('/')[ -2 ] -ne $Program.MUImspURL.Split('/')[ -2 ] )
{
    $DownloadArgs      = 
    @{  packageName    = "$env:ChocolateyPackageName ( Update )"
        FileFullPath   = "$( $DownloadArgs.FileFullPath.Replace( 'exe' , 'msp' ) )"
        url            = $Program.MUImspURL
        checksum       = $Program.MUImspChecksum
        checksumType   = 'SHA256'
        GetOriginalFileName = $True                                                           }

   $mspPath = Get-ChocolateyWebFile @DownloadArgs
 
   $UpdateArgs         = 
   @{   Statements     = "/p `"$mspPath`" /norestart /quiet ALLUSERS=1 EULA_ACCEPT=YES $options /L*v '$( $DownloadArgs.FileFullPath.Replace( 'Installer.exe' , 'Update.log' ) )'"
        ExetoRun       = 'msiexec.exe'
        validExitCodes = 0 , 1603 }

   $exitCode           = Start-ChocolateyProcessAsAdmin @UpdateArgs
 
   If ( $ExitCode -eq 1603 )
   {    $1603 | % { If ( $_ -eq 2 ) { Write-Warning "   $( $DownloadArgs.FileFullPath.Replace( 'Installer.exe' , 'Update.Log' ) )" }
                    Else            { Write-Warning "$_"                                                                         } } 
   }
}