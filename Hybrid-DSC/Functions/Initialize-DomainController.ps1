    Function Initialize-DomainController # Launches Hybrid-DSCPromo _____________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        
        Write-Theme -Action "Searching [~]" "For Valid Domain Controllers"
        
        $Report                           = Get-NBTScan 
        $DomainController                 = $Report | ? { $_.ID -eq "<1C>" }
        $MasterBrowser                    = $Report | ? { $_.ID -eq "<1B>" }

        Write-Theme -Action "Loading [~]" "Active Directory Configuration Utility"

        $P                                = 0
        
        $GUI = Get-XAML -HybridDSCPromo   | % { 
        
            Convert-XAMLToWindow -XAML $_ -NE ( Find-XAMLNamedElements -Xaml $_ ) -PassThru 
        }

        Get-DSCPromoSelection -Type 0 -GUI $GUI | % { $Code = $_.Code ; $GUI = $_.Window ; $Return = $_.Profile }
        
        $Named                            = Find-XAMLNamedElements -Xaml ( Get-XAML -HybridDSCPromo )
        
        $Menu                             = Get-DSCPromoTable -Menu

        0..( $Menu.Count - 1 )            | % { 
        
            IEX "`$GUI.`$( `$Menu[$_] ).Add_Click({ 
        
                Get-DSCPromoSelection -Type $_ -GUI `$GUI | % { 
            
                    `$Code                = `$_.Code ; 
                    `$GUI                 = `$_.Window ; 
                    `$Return              = `$_.Profile }
            })"
        }

        $Service                          = Get-DSCPromoTable -Services

        0..( $Service.Count - 1 )         | % {

            IEX "`$GUI.`$( `$Service[$_] ) | ? { `$_.IsEnabled } | % { 
        
            `$_.Add_UnChecked({ `$Code.`$( `$Service[$_] ) = 0 })
              `$_.Add_Checked({ `$Code.`$( `$Service[$_] ) = 1 }) 
            }"
        }

        $GUI.CredentialButton.Add_Click({

            $Alternate                    = 0

            If ( $Report -ne $Null ) 
            {
                $PDC = $Report | ? { $_.Service -eq "Domain Master Browser" }

                If ( $PDC -ne $Null )
                {
                    $DC      = $PDC.Host.Split( '.' )[0]
                    $Domain  = $PDC.Host.Replace( "$DC." , "" )
                    $NetBIOS = $PDC.Name
                }

                If ( $PDC -eq $Null )
                {
                    $BDC = $Report | ? { $_.Service -eq "Domain Controller" }

                    If ( $BDC.Count -gt 1 )
                    {
                        $BDC = $BDC[0]
                    }

                    If ( $BDC -ne $Null )
                    {
                        $DC      = $BDC.Host.Split( '.' )[0]
                        $Domain  = $BDC.Host.Replace( "$DC." , "" )
                        $NetBIOS = $BDC.Name
                    }
                }

                $Popup                    = Get-XAML -DCFound | % { 
                
                    Convert-XAMLToWindow -XAML $_ -NE ( Find-XAMLNamedElements -XAML $_ ) -PassThru 
                }

                $Popup.Ok                 | % { $_.Add_Click({ $Popup.DialogResult =  $True }) }
                $Popup.Cancel             | % { $_.Add_Click({ $Popup.DialogResult = $False }) }
                $Popup.DC                 | % { $_.Content = $DC      }
                $Popup.Domain             | % { $_.Content = $Domain  }
                $Popup.NetBIOS            | % { $_.Content = $NetBIOS }

                $Null                     = $Popup.Ok.Focus()

                $PopupResult              = Show-WPFWindow -GUI $Popup

                If ( $PopupResult -eq $True )
                {
                    $DCCred               = Invoke-Login -DC $DC -Domain $Domain
                }

                Else
                {
                    Write-Theme -Action "Exception [!]" "Either the user cancelled or the dialog failed" 12 4 15
                    $Alternate            = 1
                }
            }

            If ( ( $Report -eq $Null ) -or ( $Alternate -eq 1 ) )
            {
                $X = $( If ( $Code.Process -in 1,2 ) { $GUI.ParentDomainName  | % { $_.Text } }
                        If ( $Code.Process -eq 3   ) { $GUI.DomainName        | % { $_.Text } } )

                If ( ( $X -eq "" ) -or ( $X -eq $Null ) )
                {
                    Show-Message "Error" "Domain Name is Null/Empty"
                    Return
                }

                Else
                {
                    $X | % {

                        If ( $Code.Process -eq 3 -and ( Validate-DomainName -Domain $X ) -ne $X )
                        {
                            Show-Message "Error" , "$X in Parent Domain Name"
                            Return
                        }
                    
                        Else
                        {
                            Resolve-DNSName $_ -Type A | % { Resolve-DNSName $_.IPAddress } | % { $Y = $_.NameHost.Replace( ".$X" , '' ) }
                            If ( $Y -eq $Null ) { [ System.Windows.MessageBox ]::Show( "Failed to detect the domain controller" , "Error" ) ; Return }
                        }
                    }

                    $DCCred = Invoke-Login -DC $Y -Domain $X 
                }
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
                    0..( $EXE.Count - 1 ) | % { $EXE[$_].Properties } | ? { $_.netbiosname } | % { $NBIOS = $_.netbiosname }
                }

                Else { $GUI.DomainName.Text = $X }
            }

            If ( $DCCred -eq $Null )
            {
                Write-Theme -Action "Exception [!]" "Login Failed" 12 4 15 
            }
        })

        $GUI.Cancel.Add_Click( { $GUI.DialogResult = $False } )

        $GUI.Start.Add_Click({

            If ( $Code.Process -eq 0 )
            {
                ( "DomainName" , "Domain" ) , ( "DomainNetBIOSName" , "NetBIOS" ) | % { 
            
                    $X = $GUI.$( $_[0] ).Text
                
                    If ( $X -eq "" ) { Show-Message -Message "$( $_[1] ) is missing" }
                
                    $Y = IEX "Validate-DomainName -$( $_[1] ) $X"
                
                    If ( $X -eq $Y ) { $Code.$( $_[0] ) = $X } Else { Show-Message -Message $Y } 
                }
            }

            ElseIf ( $Code.Process -ne 0 ) 
            {
                $GUI.Credential.Text       | % { 
            
                    If ( $_ -eq "" )                            { Show-Message -Message "Credential Missing" }

                    ElseIf ( $_ -ne $Code.Credential.Username ) { Show-Message -Message "Credential Invalid" } 
                }

                If ( $Code.Process -in 1,2 )
                {
                    $GUI.ParentDomainName.Text | % { 

                        If ( $_ -eq "" ) { Show-Message -Message "Parent Domain Name is missing" }
                
                        Else
                        {
                            $X = Validate-DomainName -Domain $_

                            If ( $X -ne $_ ) { Show-Message -Message    $X } 

                            Else             { $Code.ParentDomainName = $_ }
                        }
                    }
            
                    $GUI.NewDomainName.Text | % { 
                
                        If ( $_ -eq "" ) { Show-Message -Message "New Domain Name is missing" }
                
                        Else
                        {
                            $Y  = $GUI.ParentDomainName.Text

                            If ( $_ -like "*$Y*" )
                            {
                                If ( $Code.Process -eq 1 )
                                {
                                    Show-Message -Message "New Domain Name is too similar to Parent Domain"
                                }
                    
                                If ( $Code.Process -eq 2 )
                                {
                                    Show-Message -Message "Child Domain Name cannot contain Parent Domain"
                                }
                            }

                            Else 
                            {
                                $X = Validate-DomainName -Domain $_
                            
                                If ( $X -eq $_ )     { $Code.NewDomainName        = $_ }
                            
                                Else                 { Show-Message -Message        $X }
                            }
                        }
                    }

                    $GUI.NewDomainNetBIOSName.Text | % { 
            
                        If ( $_ -eq "" ) { Show-Message -Message "New NetBIOS Domain Name is missing" }

                        ElseIf ( ( $NBIOS -ne $Null ) -and ( $_ -like "*$NBIOS*" ) ) { Show-Message -Message "New NetBIOS Domain Name is too similar" }
                        Else
                        {
                            $X = Validate-DomainName -Domain $_
                            If ( $X -ne $_ ) { Show-Message -Message    $X } 

                            Else             { $Code.NewDomainNetBIOSName = $_ }
                        }
                    }
                }

                If ( $Code.Process -eq 3 )
                {
                    $GUI.DomainName.Text | % { 
            
                        $X = Validate-DomainName -Domain $_ 
                        If ( $X -ne $_ ) { Show-Message -Message    $X } 
                        Else
                        { 
                            $Code.DomainName           = $_ 
                        }
                    }
            
                    $GUI.ReplicationSourceDC.Text | % { 
            
                        $X = Resolve-DNSName $_ -Type CName | % { $_.PrimaryServer }
                        If ( $X -ne $_ ) { Show-Message -Message $X } 
                        Else 
                        { 
                            $Code.ReplicationSourceDC  = $_ 
                        } 
                    }
                }

                $GUI.SiteName.Text | % { 
        
                    If ( ( Validate-DomainName -SiteName $_ ) -ne $_ )
                    {
                        Show-Message -Message "Site Name is invalid"
                    }
                }

                "Database" , "Log" , "Sysvol" | % { "$_`Path" } | % { $Code.$_ = $GUI.$_.Text }

                "SafeModeAdministratorPassword" | % { 
        
                    If     ( $GUI.$_.Password -eq "" )                          { Show-Message -Message "DSRM is empty"         }
                    ElseIf ( $GUI.$_.Password.Length -lt 8 )                    { Show-Message -Message "Password is too short" }
                    ElseIf ( $GUI.$_.Password -notmatch $GUI.Confirm.Password ) { Show-Message -Message "Invalid Confirmation"  }
                    Else { $Code.$_ = $GUI.$_.SecurePassword }
                }

                "ForestMode" , "DomainMode"    | ? { $_ -in $Return } | % { $Code.$_ = $GUI.$_.SelectedIndex }
                Get-DSCPromoTable -Roles | ? { $_ -in $Return } | % { $Code.$_ = $GUI.$_.IsChecked     }
            }

            Else { $GUI.DialogResult = $True }
        })

        ( "Database" , "NTDS" ) , ( "Log" , "NTDS" ) , ( "Sysvol" , "SYSVOL" ) | % { 
        
            $GUI.$( $_[0] + "Path" ).Text = "C:\Windows\$( $_[1] )"
        }

        $Null = $GUI.SafeModeAdministratorPassword.Focus()

        $OP   = Show-WPFWindow -GUI $GUI

        If ( $OP -eq $True )
        {
            Get-DSCPromoTable -Services | % {

                If ( ( $Code.$_ -eq "Available" ) -and ( $GUI.$_.IsChecked -eq $True ) )
                {
                    $FeatureInst = @{ Name                   = $_.Replace( '_' , '-' )
                                      IncludeAllSubFeature   = $True 
                                      IncludeManagementTools = $True                   }

                    Install-WindowsFeature @FeatureInst
                }
            }

            $Command = @{ }

            0..( $Return.Count - 1 ) | % { $Command.Add( $_ , $Code.$( $Return[$_] ) ) }

            Echo $Code.Command , $Return 

        }

        Else { Write-Theme -Action "[!] Exception" "Either the user cancelled, or the dialog failed" 12 4 15 }

                                                                                     #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}