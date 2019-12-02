    Function Get-TelemetryData # Accesses Internet API's to recover Settings ____________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
            Test-Connection 1.1.1.1 -Count 1 | ? { $_ -eq $Null } | % { 
    
                Write-Theme -Action "Exception [!]" "Not connected to the internet" 12 4 15
                
                Break
            }

            [ Net.ServicePointManager ]::SecurityProtocol = [ Net.SecurityProtocolType ]::TLS12

            $X = IRM -URI "http://ipinfo.io/$( ( IWR -URI 'http://ifconfig.me/ip' ).Content )" # < - [ Chrissy LeMaire ]

            $Info  = [ PSCustomObject ]@{ 
                ExternalIP   = $X.IP
                State        = $X.Region
                Organization = "Default"
                CommonName   = "Default"
                Location     = $X.City
                Country      = $X.Country
                ZipCode      = $X.Postal
                TimeZone     = "Default" 
                SiteLink     = "Default-First-Site-Name" }

            Write-Theme -Action "Collecting [+]" "Telemetry Data / Certificate Information"
        
            $Key = "tZqSUOHxpjLy9kyOLKspvyZmjciB0nWpxz6PMl3KQNQBNEnW5sCbTKkKBPalSOBk"

            $Y = IRM -URI "https://www.zipcodeapi.com/rest/$Key/info.json/$( $X.Postal )/degrees" -Method Get 

            $Info | % { $_.Location = $Y.City 
                        $_.TimeZone = $Y.TimeZone.TimeZone_Identifier
                        $_.SiteLink = "$( ( $Y.City.Split( ' ' ) | % { $_[0] } ) -join '' )-$( $X.Postal )" }

            $MSG  = "Company" , "Domain" | % { "[ System.Windows.MessageBox ]::Show( 'You must enter a $_' , '$_ Error' )" }

            $GUI = Get-XAML -Certificate | % { Convert-XAMLtoWindow -Xaml $_ -NE ( Find-XAMLNamedElements $_ ) -PassThru }

            $GUI.Cancel.Add_Click({ $GUI.DialogResult = $False })

            $GUI.Ok.Add_Click({

                If     ( $GUI.Company.Text -eq $Null )                 { IEX $MSG[0] }
                ElseIf ( $GUI.Domain.Text  -eq $Null )                 { IEX $MSG[1] }
                Else { $GUI.DialogResult = $True }

            })

            $GUI.Domain | % { $_.Text = Get-NetworkInfo -LocalHost | % { $_.DNS } | % { If ( $_ -ne $Null ) { $_ } Else { "" } } }

            $Null = $GUI.Company.Focus()

            $OP = Show-WPFWindow -GUI $GUI
        
            If ( $OP -eq $True )
            { 
                Write-Theme -Action "Complete [+]" "Generating Certificate Information"

                $Info | % { $_.Organization = $GUI.Company.Text 
                            $_.CommonName   = $GUI.Domain.Text  }

                Return $Info
            }

            Else 
            { 
                Write-Theme -Action "Cancelled [!]" "Abandoned Certificate Generation, using defaults" 11 12 15

                Return $Info
            }                                                                      #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}