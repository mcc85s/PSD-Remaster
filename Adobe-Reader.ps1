
    $ErrorActionPreference     = 'Stop'

    Function Set-Program
    {
        [ CmdLetBinding () ] Param (

            [ Parameter ( ParameterSetName = 0 ) ] [ Switch ] $ReaderMUI ,
            [ Parameter ( ParameterSetName = 1 ) ] [ Switch ] $ReaderMSP )

        If ( $ReaderMUI ) 
        { 
            @{  Source         = 'http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1901020064/AcroRdrDC1901020064_MUI.exe'
                DisplayName    = 'Adobe Acrobat Reader DC MUI'
                Checksum       = '81953f3cf426cbe9e6702d1af7f727c59514c012d8d90bacfb012079c7da6d23'
             }
        }

        If ( $ReaderMSP )
        {
            @{  Source         = 'http://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/1902120061/AcroRdrDCUpd1902120061_MUI.msp'
                DisplayName    = 'Adobe Acrobat Reader DC MSP'
                Checksum       = '27f436e1ed9cfd863dd96b9e874a30981afe9d9829ae91b2c6d76925515aa1979f9aaad99cf35f8ca7fa5fa300236d05c0830d81dd711913c4eb301a42c03659'
             }
        }
    }

    Function Get-Program
    {
        [ CmdLetBinding () ] Param (

            [ Parameter ( Position = 0 , ValueFromPipeline ) ][ String ] $Source      ,
            [ Parameter ( Position = 1 , ValueFromPipeline ) ][ String ] $DisplayName ,
            [ Parameter ( Position = 2 , ValueFromPipeline ) ][ String ] $Checksum    )

        [ Net.ServicePointManager ]::SecurityProtocol = [ Net.SecurityProtocolType ]::Tls12

        IPMO BitsTransfer

        $Return                = @{ 

            Source             = $Source 
            Destination        = "$ENV:Temp\$( $Source.Split( '/' )[-1] )"
            Description        = $DisplayName
        
        }
        
        Write-Theme -Action "Downloading [~]" $DisplayName

        Start-BitsTransfer @Return
        
        $Return                = @{
            
            Path               = $Return.Destination
            Algorithm          = @{
                
                32             = "MD5"
                40             = "SHA1"
                64             = "SHA256"
                96             = "SHA384"
                128            = "SHA512" 
            
            }[ $Checksum.Length ]
            
        }
            
        Get-FileHash @Return | % { 
        
            If ( $_.Hash -ne $Checksum )
            {
                Write-Theme -Action "Exception [!]" "$( $I.Algorithm ) Checksum Failed" 12 4 15

                RI $_.Path -Force
            }

            Else
            {
                Write-Theme -Action "Successful [+]" "$( $I.Algorithm ) Checksum Valid" 3 11 15
                
                Return @{ FilePath = $_.Path }
            }
        }
    }

    Function Install-AdobeReader
    {
        [ CmdLetBinding () ] Param (

            [ Parameter ( ) ] [ Int ] $DesktopIcon   = 0 ,
            [ Parameter ( ) ] [ Int ] $NoUpdates     = 0 ,
            [ Parameter ( ) ] [ Int ] $UpdateService = 0 ,
            [ ValidateSet ( 0 , 1 , 2 , 3 , 4 ) ]
            [ Parameter ( ) ] [ Int ] $UpdateMode    = 4 )

        $Params                  = [ PSCustomObject ]@{

            DesktopIcon          = $DesktopIcon
            NoUpdates            = $NoUpdates
            EnableUpdateService  = $UpdateService
            UpdateMode           = $UpdateMode
        }

        $Key                     = Resolve-UninstallList | ? { $_.DisplayName -like "*Adobe Acrobat Reader*" }
        $Options                 = ""

        $Flag                    = $Key | % { 
    
            [ PSCustomObject ]@{
        
                DisplayName      = $_.DisplayName
                DisplayVersion   = $_.DisplayVersion.Replace( '.' , '' )
                InstallerVersion = Set-Program -ReaderMUI | % { [ Int ]$_.Source.Split( '/' )[-2] }
                UpdaterVersion   = Set-Program -ReaderMSP | % { [ Int ]$_.Source.Split( '/' )[-2] }
                MUI              = 0
                MSP              = 0
            }
        }

        $Count                   = @( $Flag ).Count

        If ( $Count -eq 1 )
        {
            $Flag | % { 

                If ( $_.DisplayName -notmatch "MUI" )
                {
                    If ( $_.DisplayVersion -ge $_.InstallerVersion )
                    {
                        $Splat     = @{ 

                            Array  = "The currently installed $( $_.DisplayName ) is a single-language install." ,
                                     "This multi-language (MUI) package cannot overwrite it at this time." ,
                                     "You will need to uninstall $( $_.DisplayName ) first."
                            Title  = "Installation Halted" 
                            Prompt = "Press Enter to Continue" 

                        }

                        Write-Theme @Splat
                    }

                    Else
                    {
                        $Splat     = @{

                            Array  = "The currently installed $( $_.DisplayName ) is a single-language install" , 
                                     "This package will replace it with the multi-language (MUI) release" 
                            Title  = "Installation Process"
                            Prompt = "Press Enter to Continue"
                        }

                        Write-Theme @Splat
                    }
                }

                If ( $_.DisplayName -match "MUI" )
                {
                    If ( $_.DisplayVersion -ge $_.InstallerVersion )
                    {
                        Write-Theme -Action "Version Check [~]" "$( $Flag.DisplayName ) is current" 11 11 15
                        $_.MUI = 1
                    }
                    
                    If ( $_.DisplayVersion -eq $_.UpdaterVersion )
                    {
                        Write-Theme -Action "Version Check [~]" "$( $Flag.DisplayName.Replace( 'MUI' , 'MSP' ) ) is current" 11 11 15
                        
                        $_.MSP = 1
                    }

                    If ( $_.DisplayVersion -gt $_.UpdaterVersion )
                    {
                        $Splat     = @{

                            Array  = "$( $_.DisplayName ) v20$( $_.DisplayVersion ) installed." , 
                                     "This package installs v$( $_.UpdaterVersion ) and cannot replace a newer version."
                            Title  = "Installation Halted"
                            Prompt = "Press Enter to Continue"
                        }

                        Write-Theme @Splat
                    }
                }
            }
        }

        If ( $Count -gt 1 )
        {
            $Splat     = @{

                Array  = "$( $Key.Count ) matching installs of Adobe Acrobat Reader DC found!" , 
                         "To prevent accidental data loss, this install will be aborted." ,
                         " " ,
                         "The following installs were found " ,
                         @( ForEach ( $K in 0..( $Flag.DisplayName.Count - 1 ) )
                         {
                             "$( $Flag.DisplayName[$K] ) [~] : v20$( $Flag.DisplayVersion[$K] )"
                         })
                Title  = "Installation Halted"
                Prompt = "Press Enter to Continue"
            }

            Write-Theme @Splat
        }

        # Gets Files

        $Flag.MUI -ne 1       | % {
        
            $Item             = Set-Program -ReaderMUI
            
            Get-Program @Item | % { 
            
                $Flag.MUI     = $_.FilePath 
            }
        }

        $Flag.MSP -ne 1       | % { 
            
            $Item             = Set-Program -ReaderMSP
            
            Get-Program @Item | % { 
            
                $Flag.MSP     = $_.FilePath 
            }
        }

        $Params | % { 
        
            $_.DesktopIcon -eq 0 | % { Write-Theme -Action "Disabled [-]" "Desktop Icon [ Default ]" ; $Options += " DISABLEDDESKTOPSHORTCUT=1" }
            $_.DesktopIcon -eq 1 | % { Write-Theme -Action " Enabled [+]" "Desktop Icon" -C 11 }

            $_.NoUpdates   -eq 0 | % { Write-Theme -Action "Disabled [-]" "No Updates [ Default ]" }
            $_.NoUpdates   -eq 1 | % { 
            
                Write-Theme -Action " Enabled [+]" "No Updates" -C 11

                $Root            = "HKLM:\SOFTWARE\Policies"

                "Adobe\Acrobat Reader\DC\FeatureLockDown".Split( '\' ) | ? { 
            
                    ! ( Test-Path "$Root\$_" ) | % { New-Item -Path $Root -Name $_ }

                    $Root        = "$Root\$_"
                }
            
                $Splat           = @{ 
            
                    Path         = $Root
                    Name         = 'bUpdater'
                    PropertyType = "DWORD"
                    Value        = 0
                    Force        = $True 
            
                }
            
                New-ItemProperty @Splat
            }
        }

        If ( $Flag.MUI -ne 0 )
        {
            $Params | % { 
            
                $_.EnableUpdateService -eq 0 | % { Write-Theme -Action "Disabled [+]" "Adobe Auto-Update Service [ Default ]" ; $Options += ' DISABLE_ARM_SERVICE_INSTALL=1' }
                $_.EnableUpdateService -eq 1 | % { Write-Theme -Action " Enabled [+]" "Auto-Update Service." -C 11 }
            
            "AdobeARMservice" | % { 

                If ( Get-Service  $_ -ErrorAction SilentlyContinue )
                {
                    Set-Service   $_ -StartupType @( "Disabled" , "Automatic" )[ $Params.EnableUpdateService ]
                    Start-Service $_
                }
            }
        }
    
        $Update = [ PSCustomObject ]@{

            Index   = "Manual" , "Auto" , "Scheduled" , "Notifications" , "N/A"
            Mode    = @{ 0 = 0 , 0 , 4 ; 1 = 0 , 0 , 4 ; 2 = 1 , 0 , 4 ; 3 = 1 , 1 , 2 ; 4 = 1 , 1 , 3 }
        }

        $Update | % { Write-Theme -Action "Update Mode [~]" ( '[ Update ]: {0} [ Install ]: {1} [ Options ]: {2}' -f $_.Index[ $_.Mode[ $Params.UpdateMode ] ] ) }

        If ( $Flag.MUI -ne 0 )
        {
            $DR   = "HKLM:"

            $Root    = $DR

            "SOFTWARE\Adobe\Adobe ARM\1.0\ARM".Split( '\' ) | % { If ( ! ( Test-Path "$Root\$_" ) ) { New-Item -Path $Root -Name $_ } ; $Root = "$Root\$_" }
        
            GP $Root | ? { $_.iCheckReader -eq $Null } | % { New-ItemProperty $Root -Name "iCheckReader" -Value $Params.UpdateMode -Force } ; $Root = $DR

            "SOFTWARE\Wow6432Node\Adobe\Adobe ARM\Legacy\Reader\$( $Key.PSChildName )" | % { If ( ! ( Test-Path "$Root\$_" ) ) { New-Item -Path $Root -Name $_ }

                $Root = "$Root\$_" 
            }
        
            If ( ! ( GP $Root ) )
            {
                New-ItemProperty -Path $_ -Name 'Mode' -Value $Params.UpdateMode -Force
            }
        }
    
        $Options += " UPDATE_MODE=$( $Params.UpdateMode )"

        If ( $Flag.MUI -notin 0 , 1 )
        {
            $Splat             = @{
                
                FilePath       = $Flag.MUI
                ArgumentList   = "/sAll /msi /norestart /quiet ALLUSERS=1 EULA_ACCEPT=YES $options /L*v $( $Flag.MUI ).Install.log`""
            }

            SAPS @Splat | % { 
            
                If ( $_.ExitCode -eq 1603 )
                {
                    $Splat = @{
                    
                        Array  = "For code 1603, Adobe recommends to 'shut down Microsoft Office and all web browsers' and try again." ,
                                 "The install log should provide more details about the encountered issue:" ,
                                 "$( $Flag.MUI ).Install.log"
                        Title  = "Exit Code Exception"
                        Prompt = "Press Enter to Continue"
                    }

                    Write-Theme @Splat

                    Throw "Installation of $( $Flag.DisplayName ) was unsuccessful"
                }
            }
        }

        If ( $Flag.MSP -notin 0 , 1 )
        {
            $Splat            = @{
      
                FilePath      = 'msiexec.exe'
                ArgumentList  = "/p `"$( $File.MSP )`" /norestart /quiet ALLUSERS=1 EULA_ACCEPT=YES $Options /L*v `"$( $File.MSP ).Update.log`""
            }

            SAPS @Splat | % { 
            
                If ( $_.ExitCode -eq 1603 ) 
                {
                    $Splat = @{ 
                    
                        Array = "For code 1603, Adobe recommends to 'shut down Microsoft Office and all web browsers' and try again" ,
                                "The update log should provide more details about the encountered issue:" ,
                                "$( $File.MSP ).Update.log"
                        Title  = "Exit Code Exception"
                        Prompt = "Press Enter to Continue"
                    }

                    Write-Theme @Splat

                    Throw "Installation of $( $Flag.DisplayName.Replace( 'MUI' , 'MSP' ) ) was unsuccessful"
                }
            }
        }
    }
