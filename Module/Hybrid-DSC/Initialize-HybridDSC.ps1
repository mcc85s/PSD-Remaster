    Function Initialize-HybridDSC # Populates Tools and Items for subfolders ___________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯       
        [ CmdLetBinding () ] Param (

            [ Parameter ( ParameterSetName =     "Images" ) ] [ Switch ] $Images     ,
            [ Parameter ( ParameterSetName = "Slipstream" ) ] [ Switch ] $Slipstream )

        $DS      = Resolve-HybridDSC -Share | % { GCI ( $_.Directory , $_.Company -join '\' ) } | % { $_.FullName }

        $Tag     = @( "DC2016" ; "E" , "H" , "P" | % { "10$_`64" , "10$_`86" } )

        If ( $Images )
        {
                # ____   _________________________
                #//¯¯\\__[___ Images Scaffold ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Collecting [~]" "Windows Client/Server Images"

                    $WimImages  = $DS | ? { $_ -like "*Images*" }

                    0..6 | % { $X = $Tag[$_] ; "$WimImages\($_)$X" | ? { ! ( Test-Path $_ ) } | % { NI $_ -ItemType Directory ; NI "$_\_" -ItemType Directory } } 
            
                    Write-Theme -Action "Forward Image [+]" "Scaffold Generated"
                # ____   _________________________
                #//¯¯\\__[____ ISO Scaffold _____]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    ForEach ( $i in @( "1607" ; 64 , 32 | % { "1909_x$_" } ) ) { "$WimImages\ISO\$I" | ? { ! ( Test-Path $_ ) } | % { NI $_ -ItemType Directory } } 
                    
                    Write-Theme -Action "Windows Media [+]" "Scaffold Generated"
                # ____   _________________________
                #//¯¯\\__[___ Clean Source ISO __] [ Server 2016 Eval / 1909 x86 / x64 ]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Initializing [+]" "Retrieving Images Directly from Microsoft"

                    [ Net.ServicePointManager ]::SecurityProtocol = [ Net.SecurityProtocolType ]::TLS12

                    IPMO BitsTransfer 

                    $ISO    = ( GCI "$WimImages\ISO" | % { $_.FullName } )[0,2,1]

                    $Client = 64 , 32 | % { "https://software-download.microsoft.com/db/Win10_1909_English_x$_.iso?t=b56fde02-8f2e-4c09-9a2d-e93a99596203" }

                    $Splat  = 0..2
                # ____   _________________________
                #//¯¯\\__[_____ Server 2016 _____]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Splat[0]  = @{    Source = "https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"
                                  Destination = "$( $ISO[0] )\1607.ISO"    
                                  Description = "Windows Server ( 1607.ISO ) [ Evaluation Copy ]" }
                # ____   _________________________
                #//¯¯\\__[___ Client x64 1909 ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Splat[1]  = @{    Source = "$( $Client[0] )&e=1574831548&h=0898529f30d00f99cd6fdd9b889a43f7"
                                  Destination = "$( $ISO[1] )\1909x64.iso" 
                                  Description = "Windows Client ( 1909_x64.ISO )" }
                # ____   _________________________
                #//¯¯\\__[___ Client x32 1909 ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Splat[2]  = @{    Source = "$( $Client[1] )&e=1574831549&h=f44e9f4e43ccd7bc7fdd3ee618073bfa"
                                  Destination = "$( $ISO[2] )\1909x32.iso"
                                  Description = "Windows Client ( 1909_x32.ISO )" }
                # ____   _________________________
                #//¯¯\\__[___ Clean Source ISO __]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    0..2 | % { $X = $Splat[$_] ; If ( ! ( Test-Path $X.Destination ) ) { Write-Theme -Action "Downloading [+]" $X.Description ; Start-BitsTransfer @X } }
                # ____   _________________________
                #//¯¯\\__[___ Clean Source ISO __]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Processing [+]" "ISO -> WIM File Conversion"
                    
                    $Dest   = ( GCI $WimImages | % { $_.FullName } )[0..6]
                    
                    $DN     = ( @( "Server 2016 Datacenter x64" ; "Education" , "Home" , "Pro" | % { "10 $_" } | % { "$_ x64" , "$_ x86" } ) | % { "Windows $_" } )
                    
                    $IP     = ( GCI $ISO *.iso* | % { $_.FullName } )[ 0 , 1 , 2 , 1 , 2 , 1 , 2 ]
                    
                    $SI     = 4 , 4 , 4 , 1 , 1 , 6 , 6
                    
                    $SIP    = "$( 67..90 | % { [ Char ]$_ } | ? { $_ -notin ( Get-Volume | % { $_.DriveLetter } | Sort ) } | Select -First 1 ):\Sources\Install.WIM"

                    $DIP    = 0..6 | % { "$( $Dest[$_] )\$( $Tag[$_] ).wim" }

                    0..6 | % {

                        Write-Theme -Action "Extracting [~]" $DN[$_]

                        Mount-DiskImage -ImagePath $IP[$_]

                        $Splat = @{ SourceIndex          = $SI[$_]
                                    SourceImagePath      = $SIP
                                    DestinationImagePath = $DIP[$_]
                                    DestinationName      = $DN[$_] }
                        
                        Export-WindowsImage @Splat

                        Dismount-DiskImage -ImagePath $IP[$_]
                    }
                    
                    $List = 0..6 | % { Get-WindowsImage -ImagePath $DIP[$_] -Index 1 } | % { 
                        
                        [ PSCustomObject ]@{ 
                            
                            ImageName        = $_.ImageName
                            Architecture     = $_.Architecture | % { If ( $_ -eq 0 ) { "x86" } If ( $_ -eq 9 ) { "x64" } }
                            Version          = $_.Version
                            InstallationType = $_.InstallationType
                            CreatedTime      = $_.CreatedTime
                            ModifiedTime     = $_.ModifiedTime 
                        }
                    }

                    $Subtable = @( )

                    $FX       = @( "ImageName" , "Architecture" , "Version" , "InstallationType" ; "Created" , "Modified" | % { "$_`Time" } )

                    ForEach ( $i in 0..6 )
                    {
                        $Splat = @{ Items  = $FX
                                    Values = $FX | % { "$( $List[$I].$_ )" } }
                        
                        $Subtable    += New-SubTable @Splat
                    }

                    $Panel = @{ Title = "Clean Windows Image ( WIM ) Storage List"
                                Depth = 7
                                ID    = 0..6 | % { "( [ Image # $_ ] )" }
                                Table = 0..6 | % { $Subtable[$_]   } }

                    $Table = New-Table @Panel

                    Write-Theme -Table $Table

                    Return $List
        }

        If ( $Slipstream )
        {
                # ____   _________________________
                #//¯¯\\__[___ Updates Scaffold __]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Updates = "$( $DS[2] )\Updates" | % { If ( ! ( Test-Path $_ ) ) { NI $_ -ItemType Directory } Else { GI $_ } } | % { $_.FullName }

                    ForEach ( $i in "Server" , "Client" )
                    { 
                        "$Updates\$I" | ? { ! ( Test-Path $_ ) } | % { 
                        
                            NI $_ -ItemType Directory 

                            Write-Theme -Action "Created [+]" "( $I ) Update Directory"
                        }

                        ForEach ( $j in 86 , 64 )
                        {
                            "$Updates\$I\x$J" | ? { ! ( Test-Path $_ ) } | % { 
                            
                                NI $_ -ItemType Directory 
                            
                                Write-Theme -Action "Created [+]" "( $I\x$J ) Update Directory"
                            }
                        }
                    }

                    Write-Theme -Action "Windows Update [+]" "Scaffold Generated"

                    $Path = GCI $DS[2] *.wim* -Recurse | % { $_.FullName }

                    $List = $Path | % { Get-WindowsImage -ImagePath $_ -Index 1 }
                    
                    $Type = [ PSCustomObject ]@{ Server = @{ x64 = @( ) ; x86 = @( ) } ; Client  = @{ x64 = @( ) ; x86 = @( ) } }

                    0..( $List.Count - 1 ) | % {

                        $X = $List[$_]

                            $X.InstallationType | % { $InstallType = $( If ( $_ -eq "Server" ) { "Server" } If ( $_ -eq "Client" ) { "Client" } ) }
                            $X.Architecture     | % { $InstallArch = $( If ( $_ -eq        9 ) {    "x64" } If ( $_ -eq        0 ) {    "x86" } ) }

                        $Type.$InstallType.$InstallArch += [ PSCustomObject ]@{ 
                        
                            WIMFile     = $Path[$_]
                            MountDir    = $Path[$_] | % { $_.Replace( $_.Split('\')[-1] , "_" ) }
                            PackagePath = "$Updates\$InstallType\$InstallArch"
                            Name        = $List[$_].ImageName
                            Version     = $List[$_].Version
                        }
                    }

                    $Process = $Type | % { $_.Server , $_.Client | % { $_.x64 , $_.x86 } }

                    ForEach ( $I in 0..( $Process.Count - 1 ) )
                    {
                        $Process[$I] | % { 
                        
                            If ( ( $_ -ne $Null ) -and ( ( GCI $_.PackagePath *.msu* ) -ne $Null ) ) 
                            {
                                Write-Theme -Action "Detected [+]" "Update Image Catalog"

                                $Splat = @{ ImagePath = $_.WimFile 
                                            Index     = 1
                                            Path      = $_.MountDir }

                                Write-Theme -Action "Mounting [~]" "$( $_.Name )"

                                Mount-WindowsImage @Splat

                                $Splat = @{ PackagePath = $_.PackagePath
                                            LogPath     = "AddPackage.log" 
                                            IgnoreCheck = $True }
                            
                                Write-Theme -Action "Processing [~]" "Update Packages"
                                    
                                Add-WindowsPackage @Splat

                                Write-Theme -Action "Cleaning [~]" "Component Store Cleanup"

                                DISM /Image:$( $_.MountPath ) /Cleanup-Image /StartComponentCleanup /ResetBase
                            
                                Write-Theme -Action "Dismounting [~]" "$( $_.Name )"

                                DISM /Unmount-WIM /MountDir:$( $_.MountDir ) /Commit

                                Write-Theme -Action "Complete [+]" "$( $_.Name )"
                            }
                        }
                    }
                
                    Write-Theme -Action "Updated [+]" "Imaging Catalog"
        }                                                                           #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____   
}