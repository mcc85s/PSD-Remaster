    Function Initialize-DomainController # Launches Hybrid-DSCPromo _____________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        
        Write-Theme -Action "Searching [~]" "For Valid Domain Controllers"
        
        $Report                           = Get-NBTScan 
        $DomainController                 = $Report | ? { $_.ID -eq "<1C>" }
        $MasterBrowser                    = $Report | ? { $_.ID -eq "<1B>" }

        $ST                               = Get-DSCFeatureState -All

        Write-Theme -Action "Loading [~]" "Active Directory Configuration Utility"

        $P                                = 0
        $Promo                            = Get-XAML -HybridDSCPromo   
        $Named                            = Find-XAMLNamedElements -XAML $Promo 
        $GUI                              = Convert-XAMLToWindow   -XAML $Promo -NE $Named -PassThru
        $Code                             = [ PSCustomObject ]@{ 
        
                    Command     = "" ; Process     = "" ; Forest      = "" ; Tree        = "" ; Child       = "" ; Clone       = "" ; 
        
                    DomainType  = "" ; ForestMode  = "" ; DomainMode  = "" ; ParentDomainName               = "" ;
        
                    AD_Domain_Services             = "" ; DHCP        = "" ; DNS         = "" ; GPMC        = "" ; RSAT        = "" ; 
                    RSAT_AD_AdminCenter            = "" ; RSAT_AD_PowerShell             = "" ; RSAT_AD_Tools                  = "" ; 
                    RSAT_ADDS                      = "" ; RSAT_ADDS_Tools                = "" ; RSAT_DHCP                      = "" ; 
                    RSAT_DNS_Server                = "" ; RSAT_Role_Tools                = "" ; WDS                            = "" ; 
                    WDS_AdminPack                  = "" ; WDS_Deployment                 = "" ; WDS_Transport                  = "" ;
        
                    InstallDNS                     = "" ; CreateDNSDelegation            = "" ; 
                    NoGlobalCatalog                = "" ; CriticalReplicationOnly        = "" ;
        
                    DatabasePath                   = "" ; LogPath     = "" ; SysvolPath  = "" ;
        
                    Credential  = "" ; DomainName  = "" ; DomainNetBIOSName              = "" ; NewDomainName                  = "" ; 
                    NewDomainNetBIOSName           = "" ; SiteName                       = "" ; ReplicationSourceDC            = "" ; 
        
                    SafeModeAdministratorPassword  = "" ; Profile                        = "" }

        Get-DSCPromoSelection -Type 0 -Control $Code -Services $ST -GUI $GUI | % { 
        
            $Code      = $_.Code
            $GUI       = $_.Window
            
            $GUI.Forest.IsChecked = $True

            "Tree" , "Child" , "Clone" | % { $GUI.$_.IsChecked = $False }
        }

        $GUI.Forest.Add_Click{ 

            Get-DSCPromoSelection -Type 0 -Control $Code -Services $ST -GUI $GUI | % { 
        
                $Code      = $_.Code
                $GUI       = $_.Window
            }

            $GUI.Forest.IsChecked = $True

            "Tree" , "Child" , "Clone" | % { $GUI.$_.IsChecked = $False }
        }

        $GUI.Tree.Add_Click{ 

            Get-DSCPromoSelection -Type 1 -Control $Code -Services $ST -GUI $GUI | % { 
        
                $Code      = $_.Code
                $GUI       = $_.Window
            }

            $GUI.Tree.IsChecked = $True

            "Forest" , "Child" , "Clone" | % { $GUI.$_.IsChecked = $False }
        }

        $GUI.Child.Add_Click{ 

            Get-DSCPromoSelection -Type 2 -Control $Code -Services $ST -GUI $GUI | % { 
        
                $Code      = $_.Code
                $GUI       = $_.Window
            }

            $GUI.Child.IsChecked = $True

            "Forest" , "Tree" , "Clone" | % { $GUI.$_.IsChecked = $False }
        }

        $GUI.Clone.Add_Click{ 

            Get-DSCPromoSelection -Type 3 -Control $Code -Services $ST -GUI $GUI | % { 
        
                $Code      = $_.Code
                $GUI       = $_.Window
            }

            $GUI.Clone.IsChecked = $True

            "Forest" , "Tree" , "Child" | % { $GUI.$_.IsChecked = $False }
        }

        $Service                          = Get-DSCPromoTable -Services

        0..( $Service.Count - 1 )         | % {

            IEX "`$GUI.`$( `$Service[$_] ) | ? { `$_.IsEnabled } | % { 
        
            `$_.Add_UnChecked({ `$Code.`$( `$Service[$_] ) = 0 })
              `$_.Add_Checked({ `$Code.`$( `$Service[$_] ) = 1 }) 
            }"
        }

        $GUI.CredentialButton.Add_Click({

            $Alternate           = 0

            If ( $Report -ne $Null )
            {
                $PDC                              = $Report | ? { $_.Service -eq "Domain Master Browser" }

                If ( $PDC.Count -gt 1 )
                {
                    $PDC                          = $PDC[0]
                }

                If ( $PDC -ne $Null )
                {
                    $DC                           = $PDC.Host.Split( '.' )[0]
                    $Domain                       = $PDC.Host.Replace( "$DC." , "" )
                    $NetBIOS                      = $PDC.Name
                }

                If ( $PDC -eq $Null )
                {
                    $BDC                          = $Report | ? { $_.Service -eq "Domain Controller" }

                    If ( $BDC.Count -gt 1 )
                    {
                        $BDC                      = $BDC[0]
                    }

                    If ( $BDC -ne $Null )
                    {
                        $DC                       = $BDC.Host.Split( '.' )[0]
                        $Domain                   = $BDC.Host.Replace( "$DC." , "" )
                        $NetBIOS                  = $BDC.Name
                    }
                }

                $Popup                            = Get-XAML -DCFound 
                $GUIX                             = Convert-XAMLToWindow -XAML $Popup -NE ( Find-XAMLNamedElements -XAML $Popup ) -PassThru

                $GUIX.Ok                          | % { $_.Add_Click({ $GUIX.DialogResult =  $True }) }
                $GUIX.Cancel                      | % { $_.Add_Click({ $GUIX.DialogResult = $False }) }
                $GUIX.DC                          | % { $_.Content = $DC      }
                $GUIX.Domain                      | % { $_.Content = $Domain  }
                $GUIX.NetBIOS                     | % { $_.Content = $NetBIOS }

                $Null                             = $GUIX.Ok.Focus()

                $PopupResult                      = Show-WPFWindow -GUI $GUIX

                If ( $PopupResult -eq $True )
                {
                    $DCCred                       = Invoke-Login -DC $DC -Domain $Domain
                    
                    If ( $DCCred -ne $Null )
                    {
                        $GUI.Credential           | % { $_.Text = $DCCred.UserName ; $_.IsEnabled = $False }

                        $Code.Credential          = $DCCred
                        
                        If ( ( $GUI.Forest.IsChecked ) -or ( $GUI.Child.IsChecked ) )
                        {
                            "ParentDomainName"    | % { 
                            
                                $GUI.$_.Text      = "$Domain"
                                $Code.$_          = "$Domain"
                            }

                            "DomainNetBIOSName"   | % {
                            
                                $GUI.$_.Text      = "$NetBIOS"
                                $Code.$_          = "$Domain"
                            }
                        }

                        If ( $GUI.Clone.IsChecked )
                        {
                            "DomainName"          | % {
                            
                                $GUI.$_.Text      = "$Domain"
                                $Code.$_          = "$Domain"
                            }

                            "ReplicationSourceDC" | % {
                            
                                $GUI.$_.Text      = "$DC.$Domain"
                                $Code.$_          = "$DC.$Domain"
                            }
                        }
                    }

                    If ( $DCCred -eq $Null )
                    {
                        Write-Theme -Action "Exception [!]" "Domain Credential not captured, attempting secondary login" 11 1 15
                        $Alternate = 1
                    }
                }

                Else
                {
                    Write-Theme -Action "Exception [!]" "Either the user cancelled or the dialog failed" 12 4 15
                    $Alternate            = 1
                }
            }

            If ( ( $Report -eq $Null ) -or ( $Alternate -eq 1 ) )
            {
                Write-Theme -Action "Not Detected [!]" "Found no network nodes, attempting manual configuration"

                If ( ( $GUI.Tree.IsChecked ) -or ( $GUI.Child.IsChecked ) )
                {
                    $Domain = $GUI.ParentDomainName.Text
                }
                
                If ( $GUI.Clone.IsChecked ) 
                { 
                    $Domain = $GUI.DomainName.Text 
                }

                If ( ( $Domain -eq "" ) -or ( $Domain -eq $Null ) )
                {
                    Show-Message "Error" "Domain Name is Null/Empty"
                    Break
                }

                $X = Confirm-DomainName -Domain $Domain
                
                If ( $X -ne $Domain )
                {
                    Show-Message "Error" "$X"
                    Break
                }
                
                Resolve-DNSName $Domain -Type A | % { Resolve-DNSName $_.IPAddress } | % { $DC = $_.NameHost.Replace( ".$Domain" , '' ) }

                If ( $DC -eq $Null )
                { 
                    Show-Message "Error" "Failed to detect the domain controller"
                    Return
                }

                $DCCred = Invoke-Login -DC $DC -Domain $Domain

                If ( $DCCred -ne $Null )
                {
                    IEX "Using Namespace System.DirectoryServices"

                    $AD                       = "LDAP://$( $DC )/CN=Partitions,CN=Configuration,DC=$( $Domain.Split( '.' ) -join ',DC=' )"
                        
                    $Searcher                 = [ DirectorySearcher ]::New() 

                    $Searcher                 | % {
                    
                        $_.SearchRoot         = [ DirectoryEntry ]::New( $AD , $DCCred.Username , $DCCred.GetNetworkCredential().Password )
                        $_.PageSize           = 1000
                        $_.PropertiesToLoad.Clear()
                    }

                    $EXE = $Searcher.FindAll()

                    0..( $EXE.Count - 1 )     | % { $EXE[$_].Properties } | ? { $_.netbiosname } | % { 
                        
                        $NetBIOS              = $_.netbiosname
                    }
                    
                    $GUI.Credential           | % { $_.Text = $DCCred.UserName ; $_.IsEnabled = $False }

                    $Code.Credential          = $DCCred

                    If ( ( $GUI.Forest.IsChecked ) -or ( $GUI.Child.IsChecked ) )
                    {
                        "ParentDomainName"    | % { 
                            
                            $GUI.$_.Text      = "$Domain"
                            $Code.$_          = "$Domain"
                        }

                        "DomainNetBIOSName"   | % {
                            
                            $GUI.$_.Text      = "$NetBIOS"
                            $Code.$_          = "$NetBIOS"
                        }
                    }

                    If ( $GUI.Clone.IsChecked )
                    {
                        "DomainName"          | % {
                        
                            $GUI.$_.Text      = "$Domain"
                            $Code.$_          = "$Domain"
                        }

                        "ReplicationSourceDC" | % {
                           
                            $GUI.$_.Text      = "$DC.$Domain"
                            $Code.$_          = "$DC.$Domain"
                        }
                    }
                }

                If ( $DCCred -eq $Null )
                {
                    Write-Theme -Action "Exception [!]" "Login Failed" 12 4 15 
                }
            }
        })

        $GUI.Cancel.Add_Click( { $GUI.DialogResult = $False } )

        $GUI.Start.Add_Click({

            If ( $GUI.Forest.IsChecked )
            {
                $GUI.DomainName.Text | % {

                    If ( $_ -eq "" )
                    {
                        Show-Message "Error" "Domain Name is missing"
                        Break
                    }

                    $X = Confirm-DomainName -Domain $_
                    
                    If ( $X -ne $_ )
                    {
                        Show-Message "Error" $X
                        Break
                    }

                    Else 
                    {
                        $Code.DomainName = $_
                    }
                }

                $GUI.DomainNetBIOSName.Text | % {

                    If ( $_ -eq "" )
                    {
                        Show-Message "Error" "Domain Name is missing"
                        Break
                    }

                    $X = Confirm-DomainName -NetBIOS $_
                    
                    If ( $X -ne $_ )
                    {
                        Show-Message "Error" $X
                        Break
                    }

                    Else 
                    {
                        $Code.DomainNetBIOSName = $_
                    }
                }
            }

            If ( ( $GUI.Tree.IsChecked ) -or ( $GUI.Child.IsChecked ) -or ( $GUI.Clone.IsChecked ) )
            {
                $GUI.Credential.Text       | % {
            
                    If ( $_ -eq "" )
                    { 
                        Show-Message "Error" "Credential Missing"
                        Break
                    }
                }
            }

            If ( ( $GUI.Tree.IsChecked ) -or ( $GUI.Child.IsChecked ) )
            {
                $GUI.ParentDomainName.Text | % { 

                    If ( $_ -eq "" ) 
                    { 
                        Show-Message "Error" "Parent Domain Name is missing"
                        Break
                    }
                
                    $X = Confirm-DomainName -Domain $_

                    If ( $X -ne $_ )
                    {
                        Show-Message "Error" $X
                        Break
                    } 

                    Else             
                    { 
                        $Code.ParentDomainName = $_ 
                    }
                }
            
                $GUI.NewDomainName.Text | % { 
                
                    If ( $_ -eq "" ) 
                    { 
                        Show-Message "Error" "New Domain Name is missing"
                        Break
                    }

                    If ( $_ -like "*$( $GUI.ParentDomainName.Text )*" )
                    {
                        If ( $GUI.Tree.IsChecked )
                        {
                            Show-Message "Error" "New Domain Name is too similar to Parent Domain"
                            Break
                        }
                    
                        If ( $GUI.Child.IsChecked )
                        {
                            Show-Message "Error" "Child Domain Name cannot contain Parent Domain"
                            Break
                        }
                    }
                        
                    If ( $GUI.Tree.IsChecked )
                    {
                        $X = Confirm-DomainName -Domain $_
                            
                        If ( $X -ne $_ )
                        {
                            Show-Message "Error" $X
                            Break
                        }

                        Else
                        {
                            $Code.NewDomainName = $_ 
                        }
                    }

                    If ( $GUI.Child.IsChecked )
                    {
                        $X = Confirm-DomainName -SiteName $_
                            
                        If ( $X -ne $_ )
                        {
                            Show-Message "Error" $X
                            Break
                        }

                        Else
                        {
                            $Code.NewDomainName = $_ 
                        }
                    }
                }

                $GUI.NewDomainNetBIOSName.Text | % { 
            
                    If ( $_ -eq "" ) 
                    { 
                        Show-Message "Error" "New NetBIOS Domain Name is missing"
                        Break
                    }

                    ElseIf ( ( $NetBIOS -ne $Null ) -and ( $_ -like "*$NetBIOS*" ) ) 
                    { 
                        Show-Message "Error" "New NetBIOS Domain Name is too similar to Parent"
                        Break
                    }

                    Else
                    {
                        $X = Confirm-DomainName -NetBIOS $_

                        If ( $X -ne $_ ) 
                        { 
                            Show-Message "Error" $X
                            Break
                        } 

                        Else             
                        { 
                            $Code.NewDomainNetBIOSName = $_ 
                        }
                    }
                }
            }

            If ( $GUI.Clone.IsChecked )
            {
                $GUI.DomainName.Text | % { 
                        
                    If ( $_ -eq "" )
                    {
                        Show-Message "Error" "Domain Name cannot be empty"
                        Break
                    }

                    $X = Confirm-DomainName -Domain $_
                        
                    If ( $X -ne $_ ) 
                    { 
                        Show-Message "Error" $X
                        Break
                    } 
                        
                    Else
                    { 
                        $Code.DomainName = $_ 
                    }
                }
            
                $GUI.ReplicationSourceDC.Text | % { 
            
                    If ( $_ -eq "" )
                    {
                        Show-Message "Error" "Source Domain Controller Missing"
                        Break
                    }

                    $X = Resolve-DNSName $_ -Type CName | % { $_.PrimaryServer }

                    If ( $X -ne $_ ) 
                    { 
                        Show-Message "Error" $X
                        Break
                    }

                    Else 
                    { 
                        $Code.ReplicationSourceDC  = $_ 
                    } 
                }
            }

            $GUI.SiteName.Text | % { 
                
                If ( $_ -eq "" )
                {
                    Show-Message "Error" "Site Name missing"
                    Break
                }

                $X = Confirm-DomainName -SiteName $_
                
                If ( $X -ne $_ )
                {
                    Show-Message "Error" $X
                    Break
                }

                Else
                {
                    $Code.SiteName = $_
                }
            }

            "Database" , "Log" , "Sysvol" | % { "$_`Path" } | % { $Code.$_ = $GUI.$_.Text }

            If ( $GUI.SafeModeAdministratorPassword.Password -eq "" )                          
            { 
                Show-Message "Error" "DSRM Key is empty"
                Break
            }

            If ( $GUI.SafeModeAdministratorPassword.Password.Length -lt 8 )
            { 
                Show-Message "Error" "Password is too short"
                Break
            }

            If ( $GUI.SafeModeAdministratorPassword.Password -notmatch $GUI.Confirm.Password )
            { 
                Show-Message "Error" "Invalid Confirmation"
                Break
            }
            
            $Code.SafeModeAdministratorPassword = $GUI.SafeModeAdministratorPassword.SecurePassword

            "ForestMode" , "DomainMode" | % { 
            
                $Code.$_ = $GUI.$_.SelectedIndex

                If ( $Code.$_ -eq 7 )
                {
                    $Code.$_ = 6
                } 
            }
                
            Get-DSCPromoTable -Roles | % {
            
                If ( $GUI.$_.IsEnabled ) 
                { 
                    $Code.$_ = $GUI.$_.IsChecked
                }
            }

            $GUI.DialogResult = $True
        })

        ( "Database" , "NTDS" ) , ( "Log" , "NTDS" ) , ( "Sysvol" , "SYSVOL" ) | % { 
        
            $GUI.$( $_[0] + "Path" ).Text = "C:\Windows\$( $_[1] )"
        }

        $Null = $GUI.SafeModeAdministratorPassword.Focus()

        $OP   = Show-WPFWindow -GUI $GUI

        If ( $OP -eq $True )
        {
            $DSCLoadout      = @( ) 
            
            Get-DSCPromoTable -Services | ? { $Code.$_ -eq "Available" -and $GUI.$_.IsChecked -eq $True } | % {
            
                $DSCLoadout += $_.Replace( '_' , '-' )
            }

            $Command         = $Code.Command

            $Provision       = [ Ordered ]@{ }

            $Code.Process    | ? { $_ -in 1..2 } | % {

                $Provision.Add( "DomainType" , ( Get-DSCPromoTable -DomainType )[$_] )
            }
            
            $Code.Profile    | % { 

                $Provision.Add( $_ , $Code.$_ )
            }

            "Database" , "Log" , "Sysvol" | % { "$_`Path" } | % { 

                $Provision.Add( $_ , $Code.$_ )
            }

            # Report/Confirmation Screen

             #_    ____________________________
             #\\__//¯¯[_______ Services ______]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ( $DSCLoadOut.Count -ge 1 )
            {
                $Section     = 0..2
                $SubTable    = 0..2
                $Z           = 0

                $Section[$Z]  = "Service Configuration"

                $Names       = @( )
                $Values      = @( )
            
                ForEach ( $I in 0..( $DSCLoadOut.Count - 1 ) ) 
                { 
                    $Names  += "Service [$I]" 
                    $Values += $DSCloadout[$I]
                }
                
                $Subtable[$Z] = New-SubTable -Items $Names -Values $Values

                $Z ++
            }

             #_    ____________________________
             #\\__//¯¯[_______ Command _______]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ( $DSCLoadOut.Count -eq 0 )
            {
                $Section     = 0..1
                $SubTable    = 0..1
                $Z           = 0
            }

            $Section[$Z]  = "Domain Controller Promotion"
            $Subtable[$Z] = New-SubTable -Items "Command/Type" -Values $Command

            $Z ++

             #_    ____________________________
             #\\__//¯¯[______ Parameters _____]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Section[$Z]  = "Parameters"
            $Names        = @( $Provision.Keys ) 
            $Values       = @( $Provision.Values )
            
            $Subtable[$Z] = New-SubTable -Items $Names -Values $Values

             #_    ____________________________
             #\\__//¯¯[_____ Confirmation ____]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            $Splat       = @{ 
                
                Title    = "Hybrid-DSC Promo Loadout"
                Depth    = $Section.Count
                ID       = ForEach ( $I in 0..( $Section.Count - 1 ) ) { "( $( $Section[$I] ) )" }
                Table    = ForEach ( $I in 0..( $Section.Count - 1 ) ) { $Subtable[$I] } 
            }
            
            $Table       = New-Table @Splat

            Write-Theme -Table $Table -Prompt "Press Enter to Continue, CTRL + C to Exit"

             #_    ____________________________
             #\\__//¯¯[__ Service Installer __]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            If ( $DSCLoadout.Count -gt 0 )
            {
                Write-Theme -Action "Installing [~]" "Loadout Services"

                $DSCLoadOut    | % {

                    $Splat     = @{ Name                   = $_
                                    IncludeAllSubFeature   = $True 
                                    IncludeManagementTools = $True }

                    Install-WindowsFeature @Splat
                }
            }

            IPMO ADDSDeployment -VB

             #_    ____________________________
             #\\__//¯¯[____ DCPromo Tester ___]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

            Write-Theme -Action "Testing [~]" "Promotion Parameters"

            $Promote = 0

            If ( $Command -eq "Install-ADDSForest" ) 
            { 
                $EXE = 0
                $MSG = "Test-ADDSForestInstallation"

                Test-ADDSForestInstallation @Provision
            }

            If ( $Command -eq "Install-ADDSDomain" )
            {
                $EXE = 1
                $MSG = "Test-ADDSDomainInstallation"

                Test-ADDSDomainInstallation @Provision
            }

            If ( $Command -eq "Install-ADDSDomainController" )
            {
                $EXE = 2
                $MSG = "Test-ADDSDomainControllerInstallation"

                Test-ADDSDomainControllerInstallation @Provision
            }

            If ( $? -eq $True )
            {
                Write-Theme -Action "Successful [+]" "$MSG Passed"
                $Promote = 1
            }
                
            If ( $? -eq $False )
            {
                Write-Theme -Action "Exception [!]" "$MSG Failed" 12 4 15
                Break
            }

            If ( $Promote -eq 1 )
            {
                Switch( $Host.UI.PromptForChoice( "Test Successful" , "Proceed with Domain Controller Promotion?" ,
                [ System.Management.Automation.Host.ChoiceDescription [] ]@( "&Yes" , "&No" ) , [ Int ] 1 ) )
                {
                    0   {   Write-Theme -Action "Selected [+]" "Promote to Domain Controller"

                            ( "NoRebootOnCompletion" , $False ) , ( "Force" , $True ) | % { $Provision.Add( $_[0] , $_[1] ) }

                            If ( $EXE -eq 0 )   { Install-ADDSForest @Provision }
                            If ( $EXE -eq 1 )   { Install-ADDSDomain @Provision }
                            If ( $EXE -eq 2 )   { Install-ADDSDomainController @Provision }

                            If ( $? -eq $True ) { Write-Theme -Action "Successful [+]" "Promotion Complete, Rebooting" }
                        }
                    
                    1   {   Write-Theme -Action "Selected [+]" "Do not promote to Domain Controller"   }
                }
            }
        }

        Else { Write-Theme -Action "[!] Exception" "Either the user cancelled, or the dialog failed" 12 4 15 }

                                                                                     #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}
