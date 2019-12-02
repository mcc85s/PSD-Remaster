    Function Update-HybridDSC # Recycles *all* Deployment Share Content ________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        Write-Theme -Action "Provision Root [~]" "MDT Imaging/Task Sequence Recycler"
                # ____   _________________________
                #//¯¯\\__[___ Provisional Root __]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Root                  = Resolve-HybridDSC -Share

                    $Section               = 0..2
                    $SubTable              = 0..2

                    $Root                  | % { 

                        $Provision         = [ PSCustomObject ]@{ 
            
                            Name           = $_.Company
                            Controller     = $_.Server
                            PSDrive        = $_.DSDrive.Replace( ':' , '' )
                            SMBShare       = $_.Samba
                            NetworkPath    = "\\$( $_.Server )\$( $_.Samba )"
                            HybridRoot     = "\\$( $_.Server )\$( $_.Samba )\$( $_.Company )"
                        }
                    }

                    $Section[0]            = "Desired State Controller @ Source"

                    $Names                 = ( $Provision | GM | ? MemberType -EQ NoteProperty | % { $_.Name } )[2,0,4,5,3,1]
                    $Values                = $Names | % { $Provision.$_ }

                    $Subtable[0]           = New-Subtable -Items $Names -Values $Values
                # ____   _________________________
                #//¯¯\\__[___ Local Variables ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Local                 = Resolve-LocalMachine

                    $Section[1]            = "Current Machine @ Variables"
                    $Names                 = ( $Local | GM | ? MemberType -EQ NoteProperty | % { $_.Name } )[1,0,5,6,4,2,3]
                    $Values                = $Names | % { $Local.$_ }

                    $Subtable[1]           = New-Subtable -Items $Names -Values $Values
                # ____   _________________________
                #//¯¯\\__[___ Bridge Variables __]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Target                = [ PScustomObject ]@{ 
            
                        Path               = "$ENV:SystemDrive\$( $Root.Company )"
                    }

                    $Tree                  = "Resources" , "Tools" , "Images" , "Profiles" , "Certificates" , "Applications"

                    0..( $Tree.Count - 1 ) | % { 
            
                        $Splat             = @{ MemberType = "NoteProperty"
                                                Name       = $Tree[$_]
                                                Value      = "$( $Target.Path )\($_)$( $Tree[$_] )" 
                        }
                
                        $Target            | Add-Member @Splat 
                    }

                    $Section[2]            = "Provision Index @ Bridge Control"

                    $Names                 = ( $Target | GM | ? MemberType -EQ NoteProperty | % { $_.Name } )[3,5,6,2,4,1,0]
                    $Values                = $Names | % { $Target.$_ }

                    $Subtable[2]           = New-Subtable -Items $Names -Values $Values
                # ____   _________________________
                #//¯¯\\__[____ Display Panel ____]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Panel                 = @{ Title = "Provisional Root Index"
                                                Depth = 3
                                                ID    = $Section | % { "( $_ )" }
                                                Table = $Subtable }

                    $Table                 = New-Table @Panel

                    Write-Theme -Table $Table

                    Read-Host "$( "¯" * 116 )`nPress Enter to Continue"
                # ____   _________________________
                #//¯¯\\__[__ Get Deploy/Share  __]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Loading [+]" "MDT Drive Content"

                    Import-MDTModule

                    $X = GDR -PSProvider MDTProvider

                    If ( $X -ne $Null )
                    {
                        $X = $X | ? { $_.Name -like "*$( $Root.DSDrive.Split(':')[0] )*" -and $_.Root -eq $Root.Directory }
                    }
                    
                    If ( $X -eq $Null )
                    {
                        $X = Get-MDTPersistentDrive
                        
                        If ( $X -eq $Null )
                        {
                            $Root | % { 

                                $Splat = @{ Name        = $_.DSDrive.Split(':')[0]
                                            PSProvider  = "MDTProvider"
                                            Root        = $_.Directory
                                            Description = $_.Description
                                            NetworkPath = $Provision.NetworkPath }
                            }

                            NDR @Splat -VB | Add-MDTPersistentDrive
                        }

                        If ( $X -ne $Null )
                        {
                            GSMBS | ? { $_.Path -eq $X.Path } | % {
                            
                                $Splat = @{ Name        = $X.Name
                                            PSProvider  = "MDTProvider"
                                            Root        = $_.Path
                                            Description = $X.Description 
                                            NetworkPath = "\\$ENV:ComputerName\$( $_.Path )" }
                            }
                            
                            NDR @Splat -VB
                        }
                    }
                # ____   _________________________
                #//¯¯\\__[_ Shape Variable Tree _]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $DeployRoot = Resolve-HybridDSC -Share | % { gci $_.Directory } | % { $_.FullName }
                    
                    $HybridRoot = $DeployRoot | ? { $_ -like "*$( $Root.Company )*" } | % { gci $_ } | % { $_.FullName }

                    $Tag        = @( "DC2016" ; "E" , "H" , "P" | % { "10$_`64" , "10$_`86" } )

                    $Names      = @( 'ImageName' , 'Architecture' , 'Version' , 'InstallationType' ; 'Created' , 'Modified' | % { "$_`Time" } )
                # ____   _________________________
                #//¯¯\\__[__ Get Stored Images __]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Catalog    = @{ 
                    
                        Hybrid  = @{ Title  = "Hybrid-DSC Client/Server Windows Image Recycler Panel"
                                     Images = $HybridRoot | ? { $_ -like           "*Images*" } | % { gci $_ *.wim* -Recurse } | % { $_.FullName } }

                        Deploy  = @{ Title  = "MDT Boot Image Client/Server Windows Image Panel"
                                     Images = $DeployRoot | ? { $_ -like "*Operating System*" } | % { gci $_ *.wim* -Recurse } | % { $_.FullName } }
                    }

                    $Catalog    | % { $_.Deploy , $_.Hybrid } | % { 

                        $Title  = $_.Title 
                        $Images = $_.Images
                        
                        If ( $Images -eq $Null )
                        {
                            Write-Theme -Action "Not Detected [!]" "$Title"
                        }

                        Else
                        {                    
                            If ( $Images.Count -eq 1 )
                            {
                                Write-Theme -Action "Detected [+]" "( 1 ) Image, obtaining details"
                        
                                $Count      = 0

                                $List       = Get-WindowsImage -ImagePath $Images -Index 1
                            }

                            If ( $Images.Count -gt 1 ) 
                            { 
                                Write-Theme -Action "Detected [+]" "( $( $Images.Count ) ) Images, obtaining details"
                        
                                $Count      = 0..( $Images.Count - 1 )

                                $List       = $Count | % { Get-WindowsImage -ImagePath $Images[$_] -Index 1 }
                            }

                            $Store = $List  | % { 
                        
                                [ PSCustomObject ]@{ 
                            
                                        ImageName        = $_.ImageName
                                        Architecture     = @( "x86" ; 1..8 | % { "" } ; "x64" )[ $_.Architecture ]
                                        Version          = $_.Version
                                        InstallationType = $_.InstallationType
                                        CreatedTime      = $_.CreatedTime
                                        ModifiedTime     = $_.ModifiedTime 
                                }
                            }
                    
                            $Panel = @{ Title = $Title ; Depth = "" ; ID = "" ; Table = "" }

                            If ( $Images.Count -eq 1 )
                            {
                                $Values      = $Names | % { "$( $Store.$_ )" }
                      
                                $Section     = $Store.ImageName

                                $Subtable    = New-SubTable -Items $Names -Values $Values

                                $Panel       | % { 

                                    $_.Depth = 1
                                    $_.ID    = "( $( $Section ) )"
                                    $_.Table = $Subtable 
                                }
                            }

                            If ( $Images.Count -gt 1 )
                            {
                                $Count        = 0..( $Store.Count - 1 )

                                $Section      = $Count | % { $_ }
                                $Subtable     = $Count | % { $_ }

                                ForEach ( $I in $Count )
                                { 
                                    $X            = $Store[$I] 

                                    $Values       = $Names | % { "$( $X.$_ )" }
                      
                                    $Section[$I]  = $X.ImageName
                            
                                    $Subtable[$I] = New-SubTable -Items $Names -Values $Values
                                }

                                $Panel        | % { 
                                        
                                    $_.Depth  = $Store.Count
                                    $_.ID     = $Count | % { "( $( $Section[$_] ) )" }
                                    $_.Table  = $Count | % { $Subtable[$_] }
                                }
                            }

                            $Table = New-Table @Panel

                            Write-Theme -Table $Table

                            Read-Host "$( "¯" * 116 )`nCarefully review these details. `nPress Enter to Continue"
                        }
                    }
                # ____   _________________________
                #//¯¯\\__[____ Recycle DISM _____]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $DeployRoot  | ? { $_ -like "*Operating Systems*" } | % { GCI $_ } | ? { $_ -ne $Null } | % { RI $_.FullName -Recurse -Force -VB }
    
                    $Output      = $HybridRoot | ? { $_ -like "*Images*" } 
                    
                    $Output      | % { gci $_ *.wim* } | ? { ! $Null } | % { RI $_.FullName -VB }
                    
                    $Destination = "$Output\$( Get-Date -UFormat "%m%d%Y" )"

                    $Names       = @( "ImagePath" , "Index" | % { "Source$_" } ; "ImagePath" , "Name" | % { "Destination$_" } )

                    ForEach ( $I in 0..( $Store.Count - 1 ) )
                    {
                        $Splat = @{ 

                                SourceImagePath      = $Catalog.Hybrid.Images[$I]
                                SourceIndex          = 1
                                DestinationImagePath = "$Destination.x$( $Store.InstallationType[$I] )_$( $Store.Version[$I] ).wim"
                                DestinationName      = $Store.ImageName[$I]
                                Verbose              = $True
                        }

                        $Values = $Names | % { $Splat.$_ }

                        New-SubTable -Items $Names -Values $Values | % { 

                            New-Table -Title "DISM -> MDT" -Depth 1 -ID "( $( $Tag[$I] ) )" -Table $_ | % {

                                Write-Theme -Table $_
                            }
                        }

                        Export-WindowsImage @Splat
                    }
                # ____   _________________________
                #//¯¯\\__[__ Clear MDT Content __]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $MDTOS  = $DeployRoot | ? { $_ -like "*Operating Systems*" } 
                    
                    $MDTOS  | % { GCI $_ } | ? { ! $Null } | % { RI $_.FullName -VB -Recurse -Force }
                    
                    $Paths  = "Operating Systems" , "Task Sequences" | % { "$( $Root.DSDrive )\$_" } 
                    
                    ForEach ( $i in $Paths )
                    {
                        GCI $I | % { 
                        
                            Write-Theme -Action "Relinquishing [+]" "$I\$( $_.Name )" 12 4 15
                            RI "$I\$( $_.Name )" -Recurse -Force }
                    }
                # ____   _________________________
                #//¯¯\\__[____ Recycle MDT ______]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Output | % { GCI $_ *.wim* } | % { 

                        $File = $_.FullName
                    
                        $Parent , $Child = $_.BaseName.Split( '_' )

                        $Parent = $Parent.Split( 'x' )[-1]

                        "Operating Systems" , "Task Sequences" | % { 

                            $Splat = @{ Path     = "$( $Root.DSDrive )\$_"
                                        Enable   = "True"
                                        Name     = "$Parent"
                                        Comments = "$( Get-Date -UFormat "%m%d%Y" )"
                                        ItemType = "Folder" }
                            
                            Write-Theme -Action "Generating [+]" "$( $Splat.Path )\$Parent"
                            
                            New-Item @Splat | Out-Null

                            $Splat | % { 
                            
                                $_.Path = "$( $_.Path )\$Parent"
                                $_.Name = "$Child"
                            }

                            Write-Theme -Action "Generating [+]" "$( $Splat.Path )\$Child"

                            New-Item @Splat | Out-Null
                        }

                        $Splat = @{ Path              = "$( $Root.DSDrive )\Operating Systems\$Parent\$Child" 
                                    SourceFile        = $File
                                    DestinationFolder = $Child
                                    Move              = $True   }
                        
                        Write-Theme -Action "Importing [+]" "Operating System Image File" 11 11 15

                        Import-MDTOperatingSystem @Splat | Out-Null
                    }
                # ____   _________________________
                #//¯¯\\__[____ Task Sequences ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Control = gci $Output "*Control*" | % { $_.FullName }

                    $TMPL    = $( If ( $Root.Remaster -eq "-" ) { "MDT" } If ( $Root.Legacy -eq "-" ) { "PSD" } ) 

                    ForEach ( $I in "Server" , "Client" )
                    {
                        $TS , $OS = "Task Sequences" , "Operating Systems" | % { "$( $Root.DSDrive )\$_\$I" }

                        $Build = GCI $OS | % { $_.Name }

                        $List = @( )
                        $GUID = @( )

                        $Swap = GCI "$OS\$Build" 
                        
                        $Swap | % { $List += $_.Name ; $GUID += $_.GUID }

                        ForEach ( $J in 0..( $List.Count - 1 ) )
                        {
                            $HEX = "$Control\$TMPL$I`Mod.xml"

                            $TEX = GC $HEX

                            0..( $TEX.Count - 1 ) | % {

                                If ( $TEX[$_] -like "*OSGUID*" )
                                { 
                                    $TEX[$_] = ( $TEX[$_] | % { $_.Split( '{' )[0] , $GUID[$J] , $_.Split( '}' )[1] } ) -join ''
                                }
                            }

                            SC $HEX -Value $TEX

                            $List[$J] | % { 

                                If ( $_ -like "*Server*" )
                                {
                                    $Name = "DC2016"
                                }

                                If ( $_ -notlike "*Server*" )
                                {
                                    $Arch = $( If ( $_ -like "*x64*" ) { "64" } If ( $_ -like "*x86*" ) { "86" } )
                                    
                                    $Name = "10$( If ( $_ -like "*Educ*" ) { "E" } If ( $_ -like "*Home*" ) { "H" } If ( $_ -like "*Pro*" ) { "P" } )$Arch"
                                }
                            }

                            $Splat = @{ Path                = "$TS\$Build"
                                        Name                = "$Name"
                                        Template            = "$HEX"
                                        Comments            = "Secure Digits Plus LLC [ Fighting Entropy ]"
                                        ID                  = "$Name"
                                        Version             = "1.0"
                                        OperatingSystemPath = "$OS\$Build\$( $List[$J] )"
                                        FullName            = $Root.LMCred_User
                                        OrgName             = $Root.Company
                                        HomePage            = $Root.WWW
                                        AdminPassword       = $Root.LMCred_Pass }

                            Write-Theme -Action "Importing [+]" "Task Sequence $Name"

                            Import-MDTTaskSequence @Splat | Out-Null

                        }
                    }

                    Write-Theme -Action "Imported [+]" "Task Sequences"
                # ____   _________________________
                #//¯¯\\__[____ Share Settings ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Names  = @( "Comments" , "MonitorHost" ; 64 , 86 | % { "Boot.x$_" } | % { "$_.GenerateLiteTouchISO" ; "$_.LiteTouch" | % { 
                                 "$_`WIMDescription" , "$_`ISOName" } ; "$_.BackgroundFile" } )

                    $Values = @( "Secure Digits Plus LLC : Fighting Entropy ($( [ Char ]960 ))" , 
                                 $Root.Server ; 64 , 86 | % { "True" ; "$( $Root.Company ) (x$_)" | % { "$_" , "$_.iso" } ; $Root.Background } )

                    ForEach ( $i in 0..9 )
                    {
                        SP $Root.DSDrive -Name $Names[$I] -Value $Values[$I]
                        Write-Host ( "_" * 116 )
                        Write-Theme -Function "$( $Names[$I] )" 11 11 15
                        Write-Theme -Action "Configured [+]" "$( $Values[$I] )" 11 11 15
                        Write-Host ( "¯" * 116 )
                    }
                # ____   _________________________
                #//¯¯\\__[__ Enable Monitoring __]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Resetting [~]" "MDT Monitor Service"
                    
                    ( Disable-MDTMonitorService -EA 0 )
                
                    $Splat = @{ EventPort = 9800
                                DataPort  = 9801 }

                    Enable-MDTMonitorService @Splat

                    $CTRL   = $DeployRoot | ? { $_ -like "*Control*" }
                    $Script = $DeployRoot | ? { $_ -like "*Scripts*" }
                # ____   _________________________
                #//¯¯\\__[____ Bridge Script ____]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Login [~]" "Provide a valid Deployment Credential"

                    Export-BridgeScript
                # ____   _________________________
                #//¯¯\\__[____ Bootstrap INI ____]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $BootStrap       = @{ Settings = @{ Priority           = "Default" } 
                                          Default  = @{ DeployRoot         = $Provision.NetworkPath
                                                        UserID             = $DCCred.Username
                                                        UserPassword       = $DCCred.GetNetworkCredential().Password
                                                        UserDomain         = $Root.Branch 
                                                        SkipBDDWelcome     = "YES" } }

                    $Splat = @{ Path      = $CTRL
                                Name      = "Bootstrap.ini"
                                Value     = $Bootstrap
                                Encoding  = "UTF8"
                                UTF8NoBom = $True 
                                Force     = $True }

                    Export-Ini @Splat
                # ____   _________________________
                #//¯¯\\__[_ CustomSettings INI __]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $CustomSettings  = @{ Settings = @{ Priority           = "Default" 
                                                        Properties         = "MyCustomProperty" } 
                                          Default  = @{ _SMSTSOrgName      = "$( $Root.Company )" 
                                                        OSInstall          = "Y" 
                                                        SkipCapture        = "NO" 
                                                        SkipAdminPassword  = "YES" 
                                                        SkipProductKey     = "YES" 
                                                        SkipComputerBackup = "NO" 
                                                        SkipBitLocker      = "YES" 
                                                        KeyboardLocale     = "en-US" 
                                                        TimeZoneName       = "$( ( Get-TimeZone ).ID )" 
                                                        EventService       = "http://$( $Root.Server ):9800" } }

                    $Splat | % { $_.Name  = "CustomSettings.ini"
                                 $_.Value = $CustomSettings }

                    Export-Ini @Splat
                # ____   _________________________
                #//¯¯\\__[_____ PXE Graphics ____]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    "computer.png" , "header-image.png" | % { 
                    
                        CP "$Control\$_" "$Script\$_" -Force 

                        Write-Theme -Action "Copied [+]" "PXE Graphic ( $_ )" 11 11 15
                    }
                # ____   _________________________
                #//¯¯\\__[___ MDT Boot Images ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Updating [~]" "Deployment Share"

                    Update-MDTDeploymentShare -Path $Root.DSDrive -Force -VB
                # ____   _________________________
                #//¯¯\\__[___ WDS Boot Images ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $OEM , $LT = $Provision.Name.Replace( ' ' , '_' ) , "LiteTouchPE"

                    $Boot      = $Root.Directory | % { GCI $_ *Boot* } | % { $_.FullName }

                    $Boot      | % { GCI $_ *$OEM* } | % { RI $_.FullName -VB }

                    $Boot      | % { GCI $_  *$LT* } | % { RNI $_.FullName -NewName $_.FullName.Replace( $LT , $OEM ) -VB }

                    $WDSImages = $Boot | % { GCI $_ *.wim* } 
                    
                    ForEach ( $I in 0..1 )
                    {
                        $Path  = ( $WDSImages | % { $_.FullName })[$I]
                        $Arch  = ( 64 , 86 )[$I]
                        $Name  = ( $WDSImages | % { Get-WindowsImage -ImagePath $_.FullName } | % { $_.ImageName })[$I]
                                              
                        Get-WDSBootImage -Architecture "X$Arch" -ImageName $Name -EA 0 | ? { ! $Null } | % {

                            Write-Theme -Action "Found [~]" "$Name"
                            
                            Remove-WDSBootImage -Architecture "x$Arch" -ImageName $Name

                            Write-Theme -Action "Removed [+]" "$Name"
                        }

                        Write-Theme -Action "Importing [~]" "$Name"

                        Import-WDSBootImage -Path $Path -NewDescription $Name -SkipVerify
                    
                    }

                    Write-Theme -Action "Complete [+]" "WDS Boot Images Recyled"
                # ____   _________________________
                #//¯¯\\__[_ Restart WDS Service _]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Restarting [~]" "WDS Service"

                    Restart-Service -Name WDSServer

                    If ( $? -eq $True ) 
                    { 
                        Write-Theme -Foot
                        Write-Theme -Action "Successful [+]" "Hybrid-DSC Fully Recycled"
                    }

                    Else
                    { 
                        Write-Theme -Action "Exception [!]" "The WDS Service has experienced an issue" 12 4 15
                    } 
                                                                                     #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}