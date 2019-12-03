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
        $Selection                        = @( )
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
        
                    SafeModeAdministratorPassword  = "" }

        Get-DSCPromoSelection -Type 0 -Control $Code -Services $ST -GUI $GUI | % { 
        
            $Code      = $_.Code
            $GUI       = $_.Window
            $Selection = $_.Profile
            
            $GUI.Forest.IsChecked = $True

            "Tree" , "Child" , "Clone" | % { $GUI.$_.IsChecked = $False }
        }

        $GUI.Forest.Add_Click{ 

            Get-DSCPromoSelection -Type 0 -Control $Code -Services $ST -GUI $GUI | % { 
        
                $Code      = $_.Code
                $GUI       = $_.Window
                $Selection = $_.Profile 
            }

            $GUI.Forest.IsChecked = $True

            "Tree" , "Child" , "Clone" | % { $GUI.$_.IsChecked = $False }
        }

        $GUI.Tree.Add_Click{ 

            Get-DSCPromoSelection -Type 1 -Control $Code -Services $ST -GUI $GUI | % { 
        
                $Code      = $_.Code
                $GUI       = $_.Window
                $Selection = $_.Profile 
            }

            $GUI.Tree.IsChecked = $True

            "Forest" , "Child" , "Clone" | % { $GUI.$_.IsChecked = $False }
        }

        $GUI.Child.Add_Click{ 

            Get-DSCPromoSelection -Type 2 -Control $Code -Services $ST -GUI $GUI | % { 
        
                $Code      = $_.Code
                $GUI       = $_.Window
                $Selection = $_.Profile 
            }

            $GUI.Child.IsChecked = $True

            "Forest" , "Tree" , "Clone" | % { $GUI.$_.IsChecked = $False }
        }

        $GUI.Clone.Add_Click{ 

            Get-DSCPromoSelection -Type 3 -Control $Code -Services $ST -GUI $GUI | % { 
        
                $Code      = $_.Code
                $GUI       = $_.Window
                $Selection = $_.Profile 
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
                $PDC             = $Report | ? { $_.Service -eq "Domain Master Browser" }

                If ( $PDC.Count -gt 1 )
                {
                    $PDC         = $PDC[0]
                }

                If ( $PDC -ne $Null )
                {
                    $DC          = $PDC.Host.Split( '.' )[0]
                    $Domain      = $PDC.Host.Replace( "$DC." , "" )
                    $NetBIOS     = $PDC.Name
                }

                If ( $PDC -eq $Null )
                {
                    $BDC         = $Report | ? { $_.Service -eq "Domain Controller" }

                    If ( $BDC.Count -gt 1 )
                    {
                        $BDC     = $BDC[0]
                    }

                    If ( $BDC -ne $Null )
                    {
                        $DC      = $BDC.Host.Split( '.' )[0]
                        $Domain  = $BDC.Host.Replace( "$DC." , "" )
                        $NetBIOS = $BDC.Name
                    }
                }

                $Popup = Get-XAML -DCFound 
                $GUIX  = Convert-XAMLToWindow -XAML $Popup -NE ( Find-XAMLNamedElements -XAML $Popup ) -PassThru

                $GUIX.Ok         | % { $_.Add_Click({ $GUIX.DialogResult =  $True }) }
                $GUIX.Cancel     | % { $_.Add_Click({ $GUIX.DialogResult = $False }) }
                $GUIX.DC         | % { $_.Content = $DC      }
                $GUIX.Domain     | % { $_.Content = $Domain  }
                $GUIX.NetBIOS    | % { $_.Content = $NetBIOS }

                $Null            = $GUIX.Ok.Focus()

                $PopupResult     = Show-WPFWindow -GUI $GUIX

                If ( $PopupResult -eq $True )
                {
                    $DCCred      = Invoke-Login -DC $DC -Domain $Domain
                    
                    If ( $DCCred -ne $Null )
                    {
                        $GUI.Credential    | % { $_.Text = $DCCred.UserName ; $_.IsEnabled = $False }

                        $Code.Credential   = $DCCred
                        
                        If ( ( $GUI.Forest.IsChecked ) -or ( $GUI.Child.IsChecked ) )
                        {
                            "ParentDomainName"   | % { 
                            
                                $GUI.$_.Text     = "$Domain"
                                $Code.$_         = "$Domain"
                            }

                            "DomainNetBIOSName"  | % {
                            
                                $GUI.$_.Text     = "$NetBIOS"
                                $Code.$_         = "$Domain"
                            }
                        }

                        If ( $GUI.Clone.IsChecked )
                        {
                            "DomainName"         | % {
                            
                                $GUI.$_.Text     = "$Domain"
                                $Code.$_         = "$Domain"
                            }

                            "DomainNetBIOSName"  | % {

                                $GUI.$_.Text     = "$NetBIOS"
                                $Code.$_         = "$NetBIOS"
                            }

                            "ReplicationSourceDC" | % {
                            
                                $GUI.$_.Text = "$DC.$Domain"
                                $Code.$_     = "$DC.$Domain"
                            }
                        }
                    }

                    If ( $DCCred -eq $Null )
                    {
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
                If ( $Code.Process -in 1,2 ) 
                { 
                    $X = $GUI.ParentDomainName.Text 
                }
                
                If ( $Code.Process -eq 3   ) 
                { 
                    $X = $GUI.DomainName.Text 
                }

                If ( ( $X -eq "" ) -or ( $X -eq $Null ) )
                {
                    Show-Message "Error" "Domain Name is Null/Empty"
                    Break
                }

                Else
                {
                    $X | % {

                        If ( $Code.Process -eq 3 -and ( Confirm-DomainName -Domain $X ) -ne $X )
                        {
                            Show-Message "Error" "$X in Parent Domain Name"
                            Break
                        }
                    
                        Else
                        {
                            Resolve-DNSName $_ -Type A | % { Resolve-DNSName $_.IPAddress } | % { $Y = $_.NameHost.Replace( ".$X" , '' ) }

                            If ( $Y -eq $Null ) 
                            { 
                                [ System.Windows.MessageBox ]::Show( "Failed to detect the domain controller" , "Error" )
                                Return 
                            }
                        }
                    }

                    $DCCred = Invoke-Login -DC $Y -Domain $X
                }

                If ( $DCCred -ne $Null )
                { 
                    $GUI.Credential    | % { $_.Text = $DCCred.UserName ; $_.IsEnabled = $False }
                    $Code.Credential   = $DCCred

                    If ( $Code.Process -in 1 , 2 ) 
                    {
                        $GUI.ParentDomainName.Text = $X
            
                        $AD = "LDAP://$( $DC )/CN=Partitions,CN=Configuration,DC=$( $Domain.Split('.') -join ',DC=' )"

                        $Searcher = [ DirectorySearcher ]::New() | % {
                            $_.SearchRoot = [ DirectoryEntry ]::New( $AD , $DCCred.Username , $DCCred.GetNetworkCredential().Password )
                            $_.PageSize   = 1000
                            $_.PropertiesToLoad.Clear()
                        }

                        $EXE = $Searcher.FindAll()
                        0..( $EXE.Count - 1 ) | % { $EXE[$_].Properties } | ? { $_.netbiosname } | % { $NetBIOS = $_.netbiosname }
                    }

                    If ( $Code.Process -eq 3 )
                    { 
                        $GUI.DomainName.Text = $X 
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
                        Show-Message -Message "Domain Name is missing"
                        Break
                    }

                    $X = Confirm-DomainName -Domain $_
                    
                    If ( $X -ne $_ )
                    {
                        Show-Message -Message $X
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
                        Show-Message -Message "Domain Name is missing"
                        Break
                    }

                    $X = Confirm-DomainName -NetBIOS $_
                    
                    If ( $X -ne $_ )
                    {
                        Show-Message -Message $X
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
                        Show-Message -Message "Credential Missing"
                        Break
                    }
                }
            }

            If ( ( $GUI.Tree.IsChecked ) -or ( $GUI.Child.IsChecked ) )
            {
                $GUI.ParentDomainName.Text | % { 

                    If ( $_ -eq "" ) 
                    { 
                        Show-Message -Message "Parent Domain Name is missing"
                        Break
                    }
                
                    $X = Confirm-DomainName -Domain $_

                    If ( $X -ne $_ )
                    {
                        Show-Message -Message $X
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
                        Show-Message -Message "New Domain Name is missing"
                        Break
                    }

                    If ( $_ -like "*$( $GUI.ParentDomainName.Text )*" )
                    {
                        If ( $GUI.Tree.IsChecked )
                        {
                            Show-Message -Message "New Domain Name is too similar to Parent Domain"
                            Break
                        }
                    
                        If ( $GUI.Child.IsChecked )
                        {
                            Show-Message -Message "Child Domain Name cannot contain Parent Domain"
                            Break
                        }
                    }
                        
                    If ( $GUI.Tree.IsChecked )
                    {
                        $X = Confirm-DomainName -Domain $_
                            
                        If ( $X -ne $_ )
                        {
                            Show-Message -Message $X
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
                            Show-Message -Message $X
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
                        Show-Message -Message "New NetBIOS Domain Name is missing"
                        Break
                    }

                    ElseIf ( ( $NetBIOS -ne $Null ) -and ( $_ -like "*$NetBIOS*" ) ) 
                    { 
                        Show-Message -Message "New NetBIOS Domain Name is too similar"
                        Break
                    }

                    Else
                    {
                        $X = Confirm-DomainName -NetBIOS $_

                        If ( $X -ne $_ ) 
                        { 
                            Show-Message -Message $X
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
                        Show-Message -Message "Domain Name cannot be empty"
                        Break
                    }

                    $X = Confirm-DomainName -Domain $_
                        
                    If ( $X -ne $_ ) 
                    { 
                        Show-Message -Message    $X
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
                        Show-Message -Message "Source Domain Controller Missing"
                        Break
                    }

                    $X = Resolve-DNSName $_ -Type CName | % { $_.PrimaryServer }

                    If ( $X -ne $_ ) 
                    { 
                        Show-Message -Message $X
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
                    Show-Message "Site Name missing"
                    Break
                }

                $X = Confirm-DomainName -SiteName $_
                
                If ( $X -ne $_ )
                {
                    Show-Message -Message "Site Name is invalid"
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
                Show-Message -Message "DSRM is empty"
                Break
            }

            If ( $GUI.SafeModeAdministratorPassword.Password.Length -lt 8 )
            { 
                Show-Message -Message "Password is too short"
                Break
            }

            If ( $GUI.SafeModeAdministratorPassword.Password -notmatch $GUI.Confirm.Password )
            { 
                Show-Message -Message "Invalid Confirmation"
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
                
            Get-DSCPromoTable -Roles | ? { $GUI.$_.IsEnabled } | % { 
            
                $Code.$_ = $GUI.$_.IsChecked
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
            Return $Code
            #Get-DSCPromoTable -Services | % {

            #    If ( ( $Code.$_ -eq "Available" ) -and ( $GUI.$_.IsChecked -eq $True ) )
            #    {
            #        $FeatureInst = @{ Name                   = $_.Replace( '_' , '-' )
            #                          IncludeAllSubFeature   = $True 
            #                          IncludeManagementTools = $True                   }

             #       Install-WindowsFeature @FeatureInst
             #   }

            #$Command = @{ }

            #0..( $Return.Count - 1 ) | % { $Command.Add( $_ , $Code.$( $Return[$_] ) ) }

            #Echo $Code.Command , $Return 

        }

        Else { Write-Theme -Action "[!] Exception" "Either the user cancelled, or the dialog failed" 12 4 15 }

                                                                                     #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}
