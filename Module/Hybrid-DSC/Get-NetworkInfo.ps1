    Function Get-NetworkInfo # Obtains Extensive Network Information ____________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯     
        [ CmdLetBinding () ] Param (
            
            [ Parameter ( Position = 0 , ParameterSetName =    "LocalHost" ) ] [ Switch ] $LocalHost ,
            [ Parameter ( Position = 0 , ParameterSetName = "NetworkHosts" ) ] [ Switch ] $NetworkHosts )

        # Finds Network Interface and Gateway Address
        Get-NetRoute | ? { $_.DestinationPrefix -eq "0.0.0.0/0" } | % { $Interface = $_.InterfaceIndex ; $Gateway = $_.NextHop }

        # If you don't have a gateway ? Then, you can't even do anything cool.
        $Gateway | ? { $_ -eq $Null } | % { Write-Theme -Action "Exception [!]" "No gateway, set a valid gateway and try again. Aborting" 12 4 15 ; Break }
    
        # Gets the local adapter's MAC Address
        Get-NetAdapter   -InterfaceIndex $Interface | % { $Mac  = $_.MacAddress.Replace('-','') }

        # Gets the DNS Name and the IPV4 Address
        Get-NetIPConfiguration | ? { $_.IPV4DefaultGateway } | % { $DNS = $_.NetProfile.Name ; $IPV4 = $_.IPV4Address.IPAddress ; }

        # Collects Network Information from ARP capture
        $ARP = ARP -A | ? { $_ -like "*$( $IPV4.Split('.')[0] )*" } | ? { $_ -notlike "*Int*" } | % { ( $_[ 0..23] | ? { $_ -ne " " } ) -join '' }

        # Indexes the classes of IP addresses, not used here.
        $Class = "N" , "A" , "B" ,"C" , "M" , "R" , "BR" ,"L"
        $Range = @( 0 ; 1..126 | % { 1 } ; 7 ; 128..191 | % { 2 } ; 192..223 | % { 3 } ; 224..239 | % { 4 } ; 240..254 | % { 5 } ; 6 )

        # Searches through ARP to find similar addresses
        $List = ForEach ( $I in 0..( $Arp.Count - 1 ) ) { $Arp[$I].Split('.')[0] | % { $Range[$_] } | ? { $_ -in 1..3 } | % { $Arp[$I] } }

        # Sets up a split between network and host addresses
        $NWA = @( ) ; $HL  = @( )
        ForEach ( $I in 0..( $List.Count - 1 ) )
        {
            $NW = "" ; $HA = $Null ; $X = $List[$I].Split( '.' ) ; $Y = $IPV4.Split( '.' )
            0..3 | % { 

                If ( $X[$_] -eq $Y[$_] ) 
                { 
                    If ( $_ -eq 0 ) { $NW =         $X[$_]    }
                    Else            { $NW = "$NW.$( $X[$_] )" }
                }
                Else 
                {
                    $HA = $X[$_] ; 
                    If ( $I -eq $List.Count - 1 ) { $CL = $Y[$_] ; $NWX = $NW }
                }
            }
            If ( $NW -notin $NWA ) { $NWA += $NW } ; $HL += $HA
        }
        If ( $NW -notin $NWA ) { $NWA += $NWx } $HL += $CL ; $HostRange = $HL | % { [ Int ]$_ } | Sort ; $List += $IPV4
            
        # Now that it has the correct information, it can parse NetRoute correctly
        $Route = Get-NetRoute -AddressFamily IPv4 | ? { $_.DestinationPrefix -like "*$NW*" } | % { $_.DestinationPrefix }
        $Subnet , $CIDR = $Route | ? { $_.Split( '/' )[0] -notin $List } | % { $_.Split( '/' ) }
            
        # Convert the information found from CIDR to Full format for autocorrective measures ( I still need to work on this for Class A/B )
        $Binary = 0 , 1 , 2, 4 , 8 , 16 , 32 , 64 , 128
        $Div , $For = $CIDR | % { $_ / 8 ; $_ % 8 } ; $NM = @( )
        $NM     = @( 0..( $Div - 1 ) | % { ( $Binary[1..8] | Measure -Sum ).Sum } ; ( $Binary[0..$For] | Measure -Sum ).Sum ) -join '.'

        # Compare with IP Config Parse
        $NWIPC  = IPCONFIG | ? { $_ -like "*Subnet Mask*" } | ? { $_ -like "*$NM*" } | % { $_.Split( ':' )[1].Replace( ' ' , '' ) }
                
        If ( $NWIPC -eq $NM )
        { 
            $Return = [ PSCustomObject ]@{ 
                IPV4    = $IPV4
                Class   = "Class $( $Class[ ( $Range[ ( $NW.Split( "." )[0] )])] ) Address"
                Prefix  = $NW
                NetMask = $NM
                CIDR    = $CIDR
                MAC     = $MAC
                DNS     = $DNS 
                Subnet  = "$NW.$( ( $HostRange | Select -First 1 ) - 1 )"
                Start   = "$NW.$( $HostRange[0] )"
                End     = "$NW.$( ( $HostRange | Select -Last 1 ) - 1 )"
                Echo    = "$NW.$( ( $HostRange | Select -Last 1 ) )"
            }
        }

        If (    $LocalHost ) { Return $Return }

        If ( $NetworkHosts )
        {
            0..( $HostRange.Count - 2 ) | % {
                
                Return [ PSCustomObject ]@{ Host = "$NW.$( $HostRange[$_] )" }

            }
        }                                                                            #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}