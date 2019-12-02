    Function Install-HybridDSC # Provisions/Installs a Legacy or PSD Deployment Share __//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ] Param ( [ Parameter ( ) ][ Switch ] $Test )

        Import-MDTModule
        
        $CS = gcim Win32_ComputerSystem

        $Code = [ PSCustomObject ]@{ 
        
        # MDT Drive Info
        Drive       = "" ; Directory   = "" ; Samba       = "" ; DSDrive     = "" ; 
        Description = "" ; 

        # MDT Installation Type Switch
        Legacy      = "" ; Remaster    = "" ; 

        # IIS Info
        IIS_Name    = "" ; IIS_AppPool = "" ; IIS_Proxy   = "" ; 
            
        # IIS Installation Type Switch
        IIS_Install = "" ; IIS_Skip    = "" ;

        # Deployment Share Information
        Company     = "" ; WWW         = "" ; Phone       = "" ; Hours       = "" ; 
        Logo        = "" ; Background  = "" ; Branch      = "" ; NetBIOS     = "" ; 

        # Target Machine Information
        LMCred_User = "" ; LMCred_Pass = "" }

        $MSG  = @( "File System/Drive" ,       "Root Directory" ,    "Network Share Name" ,      "PSDrive Name" , 
                   "Share Description" ,   "BITS-DSC Site Name" , "Application Pool Name" , "Virtual Host Name" , 
                        "Company Name" ;    "Website" , "Phone" , "Hours" | % { "Support $_" } ;         "Logo" ;
                          "Background" ;               "Branch" ;          "NetBIOS Name" ; 
                "Target/LM Admin User" ; "Target/LM Admin Pass" ) | % { "Show-Message -Title '$_ Missing' -Message 'You must enter a $_'" }

        $GUI = Get-XAML -ProvisionDSC              | % { 
            Convert-XAMLtoWindow -Xaml $_ -NE ( Find-XAMLNamedElements -XAML $_ ) -PassThru 
        }

        $GUI.Legacy.Add_Click({
            "Remaster"                   | % { $GUI.$_.IsChecked = $False ; $Code.$_ =        "-" }
            "Legacy"                     | % { $GUI.$_.IsChecked =  $True ; $Code.$_ = "Selected" }
        })

        $GUI.Remaster.Add_Click({
            "Remaster"                   | % { $GUI.$_.IsChecked =  $True ; $Code.$_ = "Selected" }
            "Legacy"                     | % { $GUI.$_.IsChecked = $False ; $Code.$_ =        "-" }
        })

        $GUI.IIS_Install.Add_Click({ 
            "IIS_Install"                | % { $GUI.$_.IsChecked =  $True ; $Code.$_ = "Selected" }
            "IIS_Skip"                   | % { $GUI.$_.IsChecked = $False ; $Code.$_ =        "-" }
            "Name" , "AppPool" , "Proxy" | % { "IIS_$_" } | % { $GUI.$_.IsEnabled =  $True ; $GUI.$_.Text = "" ; $Code.$_ = "" }
        })

        $GUI.IIS_Skip.Add_Click({
            "IIS_Install"                | % { $GUI.$_.IsChecked = $False ; $Code.$_ =        "-" }
            "IIS_Skip"                   | % { $GUI.$_.IsChecked =  $True ; $Code.$_ = "Selected" }
            "Name" , "AppPool" , "Proxy" | % { "IIS_$_" } | % { $GUI.$_.IsEnabled = $False ; $GUI.$_.Text = "" ; $Code.$_ = "" }
        })

        $GUI.Cancel.Add_Click({ $GUI.DialogResult = $False })

        $GUI.Start.Add_Click({

            $Stage = 0

                If ( $GUI.Drive           | % { $_.Text           -eq "" } ) { IEX $MSG[ 0] }
            ElseIf ( $GUI.Directory       | % { $_.Text           -eq "" } ) { IEX $MSG[ 1] }
            ElseIf ( $GUI.Samba           | % { $_.Text           -eq "" } ) { IEX $MSG[ 2] }
            ElseIf ( $GUI.DSDrive         | % { $_.Text           -eq "" } ) { IEX $MSG[ 3] }
            ElseIf ( $GUI.Description     | % { $_.Text           -eq "" } ) { IEX $MSG[ 4] }
            ElseIf ( $GUI.IIS_Install     | % { $_.IsChecked } )
            {
                    If ( $GUI.IIS_Name    | % { $_.Text           -eq "" } ) { IEX $MSG[ 5] }
                ElseIf ( $GUI.IIS_AppPool | % { $_.Text           -eq "" } ) { IEX $MSG[ 6] }
                ElseIf ( $GUI.IIS_Proxy   | % { $_.Text           -eq "" } ) { IEX $MSG[ 7] }
            }
            ElseIf ( $GUI.Company         | % { $_.Text           -eq "" } ) { IEX $MSG[ 8] }
            ElseIf ( $GUI.WWW             | % { $_.Text           -eq "" } ) { IEX $MSG[ 9] }
            ElseIf ( $GUI.Phone           | % { $_.Text           -eq "" } ) { IEX $MSG[10] }
            ElseIf ( $GUI.Hours           | % { $_.Text           -eq "" } ) { IEX $MSG[11] }
            ElseIf ( $GUI.Logo            | % { $_.Text           -eq "" } ) { IEX $MSG[12] }
            ElseIf ( $GUI.Background      | % { $_.Text           -eq "" } ) { IEX $MSG[13] }
            ElseIf ( $GUI.Branch          | % { $_.Text           -eq "" } ) { IEX $MSG[14] }
            ElseIf ( $GUI.NetBIOS         | % { $_.Text           -eq "" } ) { IEX $MSG[15] }
            ElseIf ( $GUI.LMCred_User     | % { $_.Text           -eq "" } ) { IEX $MSG[16] }
            ElseIf ( $GUI.LMCred_Pass     | % { $_.Password       -eq "" } ) { IEX $MSG[17] }

            $CHK    = 0..7
            $CHK[0] = $GUI.Drive.Text.Replace( '\' , '' )
            $CHK[1] = Get-ACL $CHK[0] | % { $_.Access } | ? { $_.IdentityReference -match $Env:Username } | % { $_.FileSystemRights }
            $CHK[2] = $GUI.Directory.Text.Replace( $CHK[0] , '' ).Replace( '\' , '' ).Replace( '/' , '' )
            $CHK[3] = $CHK[0,2] -join '\'
            $CHK[4] = $GUI.Samba.Text.Replace( '$' , '' )
            $CHK[5] = $GUI.DSDrive.Text.Replace( ':' , '' )
            $CHK[6] = $GUI.Logo.Text
            $CHK[7] = $GUI.Background.Text

            $MSG = @( "Invalid Drive" , "Insufficient priviledges over specified folder" ; "Directory" , "Share" | % { "$_ already exists, cannot proceed" } ;
            "name" , "path" | % { "MDT-PersistentDrive with that $_ already exists" } ; "not found" , "is not in bitmap form" | % { "Logo $_" } ; 
            "width" , "height" | % { "Logo $_ exceeds 120px" } ; "found" , "in an acceptable format" | % { "Background not $_" } ) | % { "Show-Message -Message '$_'" }

            If ( ! ( Test-Path $CHK[0] ) )                                                                         { IEX $MSG[ 0] }
            ElseIf ( ( "268435456" , "FullControl" , "Modify, Synchronize" | ? { $_ -in $CHK[1] } ).Count -eq 0 )  { IEX $MSG[ 1] }
            ElseIf ( Test-Path $CHK[3] )                                                                           { IEX $MSG[ 2] }
            ElseIf ( GSMBS | ? { $_.Name -like "*$( $CHK[4] )*" } )                                                { IEX $MSG[ 3] }
            ElseIf ( Get-MDTPersistentDrive | ? { $_.Name -eq $CHK[5] } )                                          { IEX $MSG[ 4] }
            ElseIf ( Get-MDTPersistentDrive | ? { $_.Path -eq $CHK[3] } )                                          { IEX $MSG[ 5] }
            ElseIf ( ! ( Test-Path $CHK[6] ) )                                                                     { IEX $MSG[ 6] }
            ElseIf ( $CHK[6].Split( '.' )[-1] -ne "bmp" )                                                          { IEX $MSG[ 7] }
            ElseIf ( [ System.Drawing.Bitmap ]::FromFile( $CHK[6] ).Width  -gt 120 )                               { IEX $MSG[ 8] }
            ElseIf ( [ System.Drawing.Bitmap ]::FromFile( $CHK[6] ).Height -gt 120 )                               { IEX $MSG[ 9] }
            ElseIf ( ! ( Test-Path $CHK[7] ) )                                                                     { IEX $MSG[10] }
            ElseIf ( !$CHK[7].Split( '.' )[-1] -in "BMP,GIF,JPG,PNG,TIF,DIB,JFIF,JPE,JPEG,WDP".Split( ',' ) )      { IEX $MSG[11] }

            If ( $GUI.Legacy.IsChecked )
            {
                $Code.Legacy      =    "Selected" 
                $Code.Remaster    =           "-"
            }

            If ( $GUI.Remaster.IsChecked )
            {
                $Code.Legacy      =           "-" 
                $Code.Remaster    =    "Selected"
            }

            If ( $GUI.IIS_Install.IsChecked )
            {
                $Code.IIS_Install =    "Selected" 
                $Code.IIS_Skip    =           "-"
                $Code.IIS_Name    = $GUI.IIS_Name.Text
                $Code.IIS_AppPool = $GUI.IIS_AppPool.Text
                $Code.IIS_Proxy   = $GUI.IIS_Proxy.Text
            }

            If ( $GUI.IIS_Skip.IsChecked )
            {
                $Code.IIS_Install =           "-"
                $Code.IIS_Skip    =    "Selected" 
                $Code.IIS_Name    =           "-"
                $Code.IIS_AppPool =           "-" 
                $Code.IIS_Proxy   =           "-"
            }

                $Code.Drive       = $CHK[0]
                $Code.Directory   = $CHK[3]
                $Code.Samba       = "$( $CHK[4] )$"
                $Code.DSDrive     = "$( $CHK[5] ):"
                $Code.Description = $GUI.Description.Text
                $Code.Company     = $GUI.Company.Text
                $Code.WWW         = $GUI.WWW.Text
                $Code.Phone       = $GUI.Phone.Text
                $Code.Hours       = $GUI.Hours.Text
                $Code.Logo        = $GUI.Logo.Text
                $Code.Background  = $GUI.Background.Text
                $Code.Branch      = $GUI.Branch.Text
                $Code.NetBIOS     = $GUI.NetBIOS.Text
                $Code.LMCred_User = $GUI.LMCred_User.Text
                $Code.LMCred_Pass = $GUI.LMCred_Pass.Password

                $GUI.DialogResult = $True
        })


        Resolve-HybridDSC -Domain | % { 
        
            $GUI.NetBIOS.Text = $_.NetBIOS
            $GUI.Branch.Text  = $_.Branch 
        }

        $GUI.Legacy      | % { $_.IsChecked = $True }
        $GUI.IIS_Install | % { $_.IsChecked = $True }

        If ( $Test )
        {
            $GFX = Resolve-HybridDSC -Graphics
            
            $GUI | % {
            
                $_.Drive       | % { $_.Text     = "C:\"                              }
                $_.Directory   | % { $_.Text     = "Test1"                            }
                $_.Samba       | % { $_.Text     = "Samba$"                           }
                $_.DSDrive     | % { $_.Text     = "PSDrive:"                         }
                $_.Description | % { $_.Text     = "Info"                             }
                $_.Company     | % { $_.Text     = "Secure Digits Plus LLC"           }
                $_.IIS_Name    | % { $_.Text     = "SiteName"                         }
                $_.IIS_AppPool | % { $_.Text     = "MDT_AppPool"                      }
                $_.IIS_Proxy   | % { $_.Text     = "Hybrid"                           }
                $_.WWW         | % { $_.Text     = "https://www.securedigitsplus.com" }
                $_.Phone       | % { $_.Text     = "(518) 406-8569"                   }
                $_.Hours       | % { $_.Text     = "24h/d; 7d/w; 365.25d/y;"          }
                $_.Logo        | % { $_.Text     = $GFX.Logo                          }
                $_.Background  | % { $_.Text     = $GFX.Brand                         }
                $_.LMCred_User | % { $_.Text     = "Administrator"                    }
                $_.LMCred_Pass | % { $_.Password = "password"                         }
            }
        }

        $OP = Show-WPFWindow -GUI $GUI

        If ( $OP -eq $True ) 
        {   
            If ( Test-Path $Code.Directory )
            {
                Write-Theme -Action "Exception [!]" "Directory must not exist, breaking"
                
                Read-Host "Press Enter to Return"
                
                Break
            }

            Else
            {
                NI -Path $Code.Directory -ItemType Directory

                If ( $? -eq $True )
                {
                    Write-Theme -Action "Successful [+]" "Directory Created"
                }

                Else
                {
                    Write-Theme -Action "Exception [!]" "Directory Creation Failed" 12 4 15
                    Read-Host "Press Enter to Exit"
                    Break
                }
            }
            
            # Create the Samba Share

            $NSMBS = @{ Name        = $Code.Samba 
                        Path        = $Code.Directory 
                        FullAccess  = "Administrators" 
                        Description = $Code.Description }
    
            NSMBS @NSMBS

            If ( $? -eq $True )
            {
                Write-Theme -Action "Successful [+]" "Samba Share Created"
            }

            Else
            {
                Write-Theme -Action "Exception [!]" "Samba Share Creation Failed" 12 4 15
                Read-Host "Press Enter to Exit"
                Break
            }

            # Create the PSDrive/MDTPersistent Drive
            
            $NDR = @{   Name        = $Code.DSDrive.Replace( ':' , '' )
                        PSProvider  = "MDTProvider"
                        Root        = $Code.Directory
                        Description = $Code.Description
                        NetworkPath = "\\$ENV:ComputerName\$( $Code.Samba )"
                        Verbose     = $True }

            NDR @NDR | Add-MDTPersistentDrive -VB

            # Scaffold Hybrid-DSC Deployment Share Root Settings, Copy Designated/Default Background & Logo
            
            $Code | % { 

                $DSC = "$( $_.Directory )\$( $_.Company )"

                NI $DSC -ItemType Directory 

                ( 0 , "Resources" ) , ( 1 , "Tools" ) , ( 2 , "Images" ) , ( 3 , "Profiles" ) , ( 4 , "Certificates" ) , ( 5 , "Applications" ) | % { 

                    NI "$DSC\($( $_[0] ))$( $_[1] )" -ItemType Directory
                }

                $RES = ( gci $DSC *0* ).FullName

                $_.Background , $_.Logo | % { CP $_ $RES }

                $_.Background = "$RES\$( $_.Background.Split('\')[-1] )"
                
                $_.Logo       = "$RES\$( $_.Logo.Split('\')[-1] )"
            }

            If ( $? -eq $True )
            {
                Write-Theme -Action "Successful [+]" "PSDrive/MDTPersistent Drive Created"
            }

            Else
            {
                Write-Theme -Action "Exception [!]" "PSDrive/MDTPersistent Drive Creation Failed" 12 4 15

                Read-Host "Press Enter to Exit"
                
                Break
            }
    
            # Plant Tree For Deployment Share Root Settings

            $Root = Resolve-HybridDSC -Root | % { $_.Root }

            $Tree = "Hybrid-DSC\$( $Code.Company )\$( $Code.DSDrive.Replace( ':' , '' ) )"

            $Rec  = $Tree.Split( '\' )

            $Path = $Root

            ForEach ( $i in 0..2 ) 
            {
                "$Path\$( $Rec[$I] )" | % {

                    If ( ! ( Test-Path $_ ) )
                    {
                        NI $Path -Name $Rec[$I]
                    }

                    $Path = $_
                }
            }

            # Place Deployment Share Root Settings in the registry
            $Names  = $Code  | GM | ? { $_.MemberType -eq "NoteProperty" } | % { $_.Name }
            $Values = $Names | % { $Code.$_ } 
            
            0..( $Names.Count - 1 ) | % { SP -Path $Path -Name $Names[$_] -Value $Values[$_] -Force }

            SP -Path $Path -Name "Server" -Value $ENV:ComputerName

            $Share = Resolve-HybridDSC -Share 
            
            $Share | % { SC -Path "$( $_.Directory )\DSC.txt" -Value ( $_ | ConvertTo-JSON ) -Force }

            If ( $Code.Remaster -eq "Selected" )
            {
                Write-Theme -Action "Creating" "[+] PowerShell [ Deployment / Development ] Share"
                    
                $Source   = Resolve-HybridDSC -Root | % { $_.Tree }
                $Remaster = GCI $Source "*PSD*" -Recurse | % { $_.FullName }

                If ( $Remaster -eq $Null )
                {
                    Write-Theme -Action "Exception [!]" "The Remastered package was not detected" 12 4 15
                    Break
                }

                $Manifest = [ PSCustomObject ]@{ 

                        Scripts   = "Scripts"
                        Templates = "Templates"
                        Modules   = "Tools\Modules"
                        Folders   = "Gather" , "DeploymentShare" , "Utility" , "Wizard" | % { "PSD$_" }
                        XSD       = "Groups" , "Medias" , "OperatingSystems" , "Packages" , "SelectionProfiles" , "TaskSequences" , 
                                    "Applications" , "Drivers" , "LinkedDeploymentShares" | % { "$_.xsd" }
                        PSSnapIn  = @( "dll" , "dll.config" , "dll-help.xml" , "Format.ps1xml" , "Types.ps1xml" | % { 
                                       "PSSnapIn.$_" } ; "Core.dll" , "Core.dll.config" , "ConfigManager.dll" )
                        Paths     = @( "Logs" , "Logs\Dyn" ; "Sources" , "Packages" | % { "Driver$_" } )
                }
                
                Expand-Archive $Remaster -DestinationPath "$Source\Tools"

                $Items = "Scripts" , "Templates" | % { gci "$Source\Tools\PSD-Master\$_" | % { $_.FullName } }
                
                0..( $Items.Count - 1 ) | % { 
                
                    $X = $Items[$_]
                    $Y = "$( $Code.Directory )\$( If ( $X -like "*Scripts*" ) { "Scripts" } If ( $X -like "*Templates*" ) { "Templates" } )"
                    MI $X $Y
                }
                
                RI "$Source\Tools\PSD-master" -Recurse -Force

                $M = $Manifest
                $W = $Code.Directory
                $X = $W , $M.Modules -join '\'

                $M.Folders | % { "$X\$_" } | ? { ! ( Test-Path $_ ) } | % { NI $_ -ItemType Directory -Verbose }

                GCI "$W\Scripts" *.psm1* -Recurse | % { CP $_.FullName "$W\Tools\Modules\$( $_.BaseName )\$( $_.Name )" -Verbose }

                $Snap  = "$W\Tools\Modules\Microsoft.BDD.PSSnapin" 
                
                $Snap  | ? { ! ( Test-Path $_ ) } | % { NI $_ -ItemType Directory -VB }

                $MDTDir = GP "HKLM:\Software\Microsoft\Deployment 4" | % { $_.Install_Dir }
                
                $M.PSSnapIn | % { GCI "$MDTDir\Bin" *$_* -Recurse } | % { CP $_.FullName "$Snap\$( $_.Name )" -Verbose }

                GCI $MDTDir *Gather.xml* -Recurse | % { CP $_.FullName "$W\Tools\Modules\PSDGather" -Verbose }

                $M.XSD      | % { GCI $MDTDir *$_* -Recurse } | % { CP $_.FullName "$W\Templates" -Verbose }
                
                $M.Paths    | % { "$W\$_" } | ? { ! ( Test-Path $_ ) } | % { NI $_ -ItemType Directory -Verbose }

            }

            Write-Theme -Action "Reducing [~]" "Permissions Hardening on $( $Code.Samba )"

            "Users" , "Administrators" , "SYSTEM" | % { ICACLS $Code.Directory /Grant "$_`:(OI)(CI)(RX)" }

            $Code.Samba | % { 
                
                GRSMBA -Name $_ -AccountName "EVERYONE" -AccessRight Change -Force
                RKSMBA -Name $_ -AccountName "CREATOR OWNER" -Force 
            }

            $Control = @{ Path        = GCI ( Resolve-HybridDSC -Root | % { $_.Tree } ) "*Control*" -Recurse | % { $_.FullName }
                          Destination = $Share | % { gci $_.Directory "*(2)Images*" -Recurse } | % { $_.FullName }
                          Recurse     = $True 
                          Force       = $True }

            CP @Control

            If ( $Code.Legacy -eq "Selected" )
            {
                Write-Theme -Action "Complete [+]" "Legacy MDT Installed"
            }
            
            If ( $Code.Remaster )
            {
                Write-Theme -Action "Complete [+]" "Hybrid-DSC/PSD Installed"
            }
                  
            If ( $Code.IIS_Install -eq "Selected" )
            {
                # ____   _________________________
                #//¯¯\\__[__ Table Definition ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Site         = [ PSCustomObject ]@{ 

                        Name      = $Code.IIS_Name
                        Pool      = $Code.IIS_AppPool
                        Host      = $Code.IIS_Proxy

                        System    = $ENV:SystemDrive
                        System32  = "$ENV:SystemRoot\System32"
                        Server    = $ENV:ComputerName

                        AppHost   = "Machine/Webroot/AppHost"
                        WebServer = "system.webServer"
                        SecAuth   = "security/authentication"
                        AutoStart = "ServerAutoStart"
                        Static    = "StaticContent"

                        Date      = ( Get-Date -UFormat "%m-%d-%Y" )
                        Log       = "$Home\Desktop\ACL"

                        Root      = ""
                        Site      = ""
                        URL       = ""
                    }

                    $Site | % { 
            
                        $_.Root = "$( $_.System )\inetpub\$( $_.Name )"
                        $_.Site = "IIS:\Sites\$( $_.Name )\$( $_.Host )"
                        $_.URL  = "$( $_.Name ).$env:USERDNSDOMAIN"

                    }

                    $Site.Root | % { $_ , "$_\AppData" | ? { ! ( Test-Path $_ ) } | % { NI $_ -ItemType Directory } }
                # ____   _________________________
                #//¯¯\\__[__ Get Web Services ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Web          = @( "Web-Server" , "DSC-Service" , "FS-SMBBW" , "ManagementOData" , "WindowsPowerShellWebAccess" , "WebDAV-Redirector" ; 
                    "BITS"        | % { "$_" , "$_-IIS-Ext" , "RSAT-$_-Server" } ;
                    "Net"         | % { "$_-Framework-45-ASP$_" , "$_-WCF-HTTP-Activation45" } ;
                    <# Web #>       @( "App-Dev" , "AppInit" , "Asp-Net45" , "Basic-Auth" , "Common-Http" , "Custom-Logging" , "DAV-Publishing" , "Default-Doc" ,
                    "Digest-Auth" , "Dir-Browsing" , "Filtering" , "Health" ; "HTTP" | % {  "$_-Errors" , "$_-Logging" , "$_-Redirect" , "$_-Tracing" } ;
                    "Includes" ; "ISAPI" | % { "$_-Ext" ; "$_-Filter" } ; "Log-Libraries" , "Metabase" , "Mgmt-Console" , "Net-Ext45" , "Performance" ,
                    "Request-Monitor" , "Security" , "Stat-Compression" , "Static-Content" , "Url-Auth" , "WebServer" , "Windows-Auth" ) | % { "Web-$_" } ;
            
                    "WAS"         | % { "$_" , "$_-Process-Model" , "$_-Config-APIs" } )

                    Write-Theme -Action "Checking [~]" "IIS / Windows Features"

                    Get-WindowsFeature | ? { $_.Name -in $Web -and $_.InstallState -ne "Installed" } | % {

                        Write-Theme -Action "Installing [~]" "Installing $( $_.Name )"
    
                        Install-WindowsFeature -Name $_.Name -IncludeAllSubFeature -IncludeManagementTools
        
                    }
                # ____   _________________________
                #//¯¯\\__[__ Set Web Services ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    IPMO WebAdministration
        
                    Write-Theme -Action "Loaded [~]" "WebAdministration Module"

                    Get-Website | ? { $_.Name -eq "Default Web Site" } | Stop-Website | SP "IIS:\Sites\$( $_.Name )" ServerAutoStart False

                    Write-Theme -Action "Stopped [+]" "Default Web Site"

                    "MRxDAV" , "WebClient" | % { Get-Service -Name $_ } | % { 
        
                        If ( $_.Status -ne "Running" ) 
                        {
                            $Service = @{ StartupType = "Automatic"
                                          Status      =   "Running"
                                          Name        =    $_.Name }
                
                            Set-Service @Service

                            Write-Theme -Action "Started [+]" "$( $_.Name ) Active"
                        }
            
                        Else 
                        {
                            Write-Theme -Action "Running [+]" "$( $_.Name ) was already Active"
                        }
                    }
                # ____   _________________________
                #//¯¯\\__[__ Generate AppPool ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    If ( ( Get-IISAppPool -Name $Site.Pool ) -ne $Null )
                    { 
                        Write-Theme -Action "Removing [!]" "Prior Application Pool"
            
                        Remove-WebAppPool -Name $Site.Pool
                    }

                    New-WebAppPool -Name $Site.Pool -Force

                    Write-Theme -Action "Configuring" "[~] Application Pool Settings"

                    ( "Enable32BitAppOnWin64" , "True" ) , ( "ManagedRuntimeVersion" , "v4.0" ) , ( "ManagedPipelineMode" , "Integrated" ) | % { 
            
                        SP -Path "IIS:\AppPools\$( $Site.Pool )" -Name $_[0] -Value $_[1]
                    }

                    Restart-WebAppPool -Name $Site.Pool
                # ____   _________________________
                #//¯¯\\__[__ Generate Website ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    If ( ( Get-WebSite -Name $Site.Name ) -ne $Null )
                    { 
                        Write-Theme -Action "Removing [!]" "Prior Website"

                        Remove-Website -Name $Site.Name
                    }
            
                    $Splat = @{ Name             = $Site.Name
                                ApplicationPool  = $Site.Pool
                                PhysicalPath     = $Site.Root 
                                Force            = $True }

                    New-Website @Splat

                    Write-Theme -Action "Generated [+]" "IIS Web Site $( $Site.Name )"

                    Start-Website -Name $Site.Name

                    Write-Theme -Action "Started [+]" "IIS Web Site $( $Site.Name )"
                # ____   _________________________
                #//¯¯\\__[___ Set Web Binding ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Binding [+]" "IIS Web Site $( $Site.Name )"

                    $Splat = @{ Name             = $Site.Name
                                HostHeader       = ""
                                PropertyName     = "HostHeader"
                                Value            = $Site.URL }

                    Set-WebBinding @Splat

                    Write-Theme -Action "Configured [+]" $Site.URL

                    $Splat = @{ Site             = $Site.Name
                                Name             = $Site.Host
                                PhysicalPath     = $Code.Directory
                                Force            = $True }

                    New-WebVirtualDirectory @Splat
                
                    Write-Theme -Action "Complete [+]" "http://$( $Site.URL )"
                # ____   _________________________
                #//¯¯\\__[__ WebDAV Authoring ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Configuring [~]" "WebDAV Authoring"
            
                    $Splat = @{ PSPath           = $_.AppHost
                                Location         = $_.Name
                                Filter           = "$( $_.WebServer )/webdav/authoring"
                                Name             = "Enabled"
                                Value            = "True" }

                    Set-WebConfigurationProperty @Splat

                    Write-Theme -Action "Complete [~]" "WebDAV Authoring"
                # ____   _________________________
                #//¯¯\\__[____ WebDAV Rules _____]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Generating [~]" "WebDAV Authoring Rules"
            
                    $Config = $Site | % { 
            
                        "Set Config '$( $_.Name )/$( $_.Host )'" , 
                        "/Section:$( $_.WebServer )/webdav/authoringRules" , 
                        "/+[Users='*',Path='*',Access='Read,Source']" , 
                        "/Commit:AppHost" -join ' ' 
                    }

                    $Splat = @{ FilePath         = GCI "$( $Site.System32 )\inetsrv" "*appcmd.exe" | % { $_.FullName }
                                ArgumentList     = $Config
                                NoNewWindow      = $True
                                PassThru         = $True }
                    
                    SAPS @Splat | Out-Null
                
                    Write-Theme -Action "Generating [~]" "WebDAV Authoring Rules"
                # ____   _________________________
                #//¯¯\\__[____ Add Mime Type ____]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $Splat = @{ PSPath = $Site.Site
                                Filter = "$( $Site.WebServer )\$( $Site.Static )"
                                Name   = "." }

                    Get-WebConfigurationProperty @Splat | % { $_.Collection } | ? { !$_.fileExtension -eq ".*" } | % {

                        $Splat.Add( "Value" , @{ fileExtension = '.*' ; mimeType = 'Text/Plain' } )

                        Add-WebConfigurationProperty @Splat
                
                        Write-Theme -Action "Configured [+]" "[ fileExtension: '.*' ] / [ mimeType: 'Text/Plain' ]"
                    }
                # ____   _________________________
                #//¯¯\\__[__ Directory Browse ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Enabling [+]" "Directory Browsing"

                    $Splat     = @{ Filter = "/$( $Site.WebServer )/DirectoryBrowse"
                                    Name   = "Enabled"
                                    PSPath = $Site.Site
                                    Value  = $True }

                    Set-WebConfigurationProperty @Splat
                # ____   _________________________
                #//¯¯\\__[____ Security/Auth ____]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $PSPath    = 0..8 | % { "MACHINE/WEBROOT/APPHOST" }
                    $Location  = ( $Site | % { "$( $_.Name )\" ; "$( $_.Name )\$( $_.Host )" } )[1,1,0,1,0,1,0,1,0]
                    $Filter    = @( "anonymous" , "windows" | % { "security/authentication/$_`Authentication" } ; "Rules" , "/properties" | % { "webdav/authoring$_" } ; 
                                    "fileExtentions" , "verbs" | % { "security/requestFiltering/$_" } )[0,1,2,3,3,4,4,5,5] | % { "system.webServer/$_" }
                    $Name      = (  "enabled" , "defaultMimeType" , "allowInfinitePropfindDepth" , "applyToWebDAV" )[0,0,1,2,2,3,3,3,3]
                    $Value     = (  "False" , "True" , "Text/XML" )[0,1,2,1,1,0,0,0,0]

                    ForEach ( $i in 0..8 )
                    { 
                        $Splat = @{ PSPath   = $PSPath[$i]
                                    Location = $Location[$i]
                                    Filter   = $Filter[$i]
                                    Name     = $Name[$i]
                                    Value    = $Value[$i] }
                    
                        $Names    = "Location" , "Filter" , "Name" , "Value"
                        $Values   = $Names | % { $Splat.$_ }
                        $Section  = "Setting WebConfiguration #$( $I + 1 )"

                        $Subtable = New-SubTable -Items $Names -Values $Values

                        $Panel    = @{ Title = "WebConfiguration"
                                       Depth = 1
                                       ID    = $Section  | % { "( $_ )" }
                                       Table = $Subtable | % { $_ } }
        
                        $Table    =    New-Table @Panel

                        Write-Theme -Table $Table

                        Set-WebConfigurationProperty @Splat

                    }
                # ____   _________________________
                #//¯¯\\__[___ Hidden Segments ___] # Disabled for now, recurring error "disk changes" ( This is a security issue )
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

                        # Write-Theme -Action "Restarting [~]" "IIS Service" 11 12 15
                    
                        # IISRESET /Stop

                        # Write-Theme -Action "Configuring [~]" "Security Request Filtering for WebDAV" 11 12 15

                        # $SP   = "system.webServer/security/requestFiltering" ; 
                        # $HS   = "hiddenSegments"
                        # $ATWD = "applytoWebDAV"
                    
                        # ( Get-IISConfigSection | ? { $_.SectionPath -like "*$SP*" } | Get-IISConfigElement -ChildElementName $HS ) | % { 
                    
                        #   Set-IISConfigAttributeValue -ConfigElement $_ -AttributeName "applytoWebDAV" -AttributeValue $False 
                    
                        # }

                        # IISRESET /Start
                # ____   _________________________
                #//¯¯\\__[_____ File System _____]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Access Control [~]" "Configuring SAM / Access Control Permissions"

                    'IIS_IUSRS', 'IUSR', "IIS APPPOOL\$( $Site.Pool )" | % { 

                        $Splat = @{ SAM     = $_
                                    Rights  = 'ReadAndExecute'
                                    Inherit = 'ContainerInherit' , 'ObjectInherit' }

                        New-ACLObject @Splat | % { Add-ACL -Path $Site.Root -ACL $_ }

                    }

                    'IIS_IUSRS', "IIS APPPOOL\$( $Site.Pool )"         | % {

                        $Splat = @{ SAM     = $_
                                    Rights  = 'Modify'
                                    Inherit = 'ContainerInherit' , 'ObjectInherit' }

                        New-AclObject @Splat | % { Add-Acl -Path "$( $Site.Root )\AppData" -ACL $_ }
                    }
                # ____   _________________________
                #//¯¯\\__[__ Strictly TLS 1.2 ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Configuring [~]" "SCHANNEL [ SSL 2.0 - 3.0 ] & [ TLS 1.0 - 1.2 ]"

                    $SSLTLS    = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"

                    $Types     = "Client" , "Server"

                    $Protocols = @( 2..3 | % { "SSL $_.0" } ; 0..2 | % { "TLS 1.$_" } )

                    $Protocols | % { If ( ! ( Test-Path "$SSLTLS\$_" ) ) { NI -Path $SSLTLS -Name "$_" } }

                    $List      = GCI $SSLTLS | % { $_.PSPath } 
                
                    $List      | % { If ( $_.PSChildName -eq $Null ) { NI -Path $_ -Name "Server" ; NI -Path $_ -Name "Client" } }

                    GCI $List  | % { 
                
                        $V = $( If ( $_ -like "*TLS 1.2*" ) { 1 } Else { 0 } )
                    
                        SP -Path $_.PSPath -Name "DisabledByDefault" -Value 0
                        SP -Path $_.PSPath -Name           "Enabled" -Value $V
                    }
                # ____   _________________________
                #//¯¯\\__[___ .Net FW TLS 1.2 ___]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Configuring [~]" ".Net Framework [ v2.0.50727 ] & [ v4.0.30319 ]"

                    ForEach ( $i in "" , "\WOW6432NODE" | % { "HKLM:\SOFTWARE$_\Microsoft\.NETFramework" } ) 
                    { 
                        "v2.0.50727" , "v4.0.30319" | % { 

                            If ( ( Test-Path $i ) -ne $True ) { NI -Path $i -Name "$_" }
                        
                            SP -Path $i -Name "SystemDefaultTlsVersions" -Type DWORD -Value 1
                        }
                    }
                # ____   _________________________
                #//¯¯\\__[_ Website / DNS Setup _]
                #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    Write-Theme -Action "Pausing [~]" "Website to modify DNS record"

                    Stop-Website $Site.Name

                    $Resolve = Resolve-HybridDSC -Domain

                    $Splat = @{ ZoneName = $Resolve.Branch
                                RRType   = "CNAME" }
                    
                    Get-DNSServerResourceRecord @Splat | ? { $_.HostName -eq $Site.Name } | % {

                        $Splat.Add(  "Name" , $_.HostName )
                        $Splat.Add( "Force" , $True )

                        Remove-DNSServerResourceRecord @Splat
                    }

                    $Splat = @{ HostNameAlias = Resolve-DnsName 127.0.0.1 | % { $_.NameHost }
                                Name          = $Site.Name
                                ZoneName      = $Resolve.Branch }

                    Add-DNSServerResourceRecordCName @Splat

                    Write-Theme -Action "Resuming [+]" "Website $( $Site.Name )"
                    Start-Website $Site.Name

                    Write-Theme -Action "Complete [+]" "Your Web Server should now be available to the internet"
                    Start "http://$( $Site.URL )"

                    Write-Theme -Action "Recommendation" "[!] You may want to configure SSL Certificates manually"
            } 

            If ( $Code.IIS_Skip -eq "Selected" )
            {
                Write-Theme -Action "Bypass [~]" "MDT/IIS Server Setup"
            }
        }

        Else
        {
            Write-Theme -Action "Exception [!]" "Either the user cancelled, or the dialog failed" 12 4 15
        }
                                                                                    #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}