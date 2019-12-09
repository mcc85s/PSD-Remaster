    Function Get-NBTSCAN # Scans all discoverable NetBIOS Nodes _________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯     
        [ CmdLetBinding () ] Param ( 

            [ Parameter ( Position = 0 , HelpMessage = "Output the information to a table" )][ Switch ] $Table )

        $Return  = @( )

        $IP    = Start-PingSweep | ? { $_.Success -ne $Null } | % { $_.Success }
        $IPV4  = Get-NetworkInfo -LocalHost | % { $_.IPV4 }

        $ID =  "00" , "01" , "01" , "03" , "06" , "1F" , "20" , "21" , "22" , "23" , "24" , "30" , "31" , "43" , "44" , "45" , "46" , "4C" , "42" , 
        "52" , "87" , "6A" , "BE" , "BF" , "03" , "00" , "1B" , "1C" , "1D" , "1E" , "2B" , "2F" , "33" , "20" , "01" | % { "<$_>" }

        $Type = ( "UNIQUE" , "GROUP" )[0,0,1+@(0..21|%{0})+1,0,1,0,1,0,1,1,1,1]

        $SVX  = "Workstation" , "Messenger" , "Master Browser" , "Messenger" , "RAS Server" , "NetDDE" , "File Server" ,  "RAS Client" , 
        "Interchange(MSMail Connector)" , "Store" , "Directory" , "Server" , "Client" , "Control" , "SMS Administrators Remote Control Tool" , 
        "Chat" , "Transfer" , "on Windows NT" , "mccaffee anti-virus" , "on Windows NT" , "MTA" , "IMC" , "Network Monitor Agent" , 
        "Network Monitor Application" , "Messenger" , "Name" , "Master Browser" , "Controllers" , "Master Browser" , "Browser Service Elections" , 
        "Server" , "" , "" , "DCA IrmaLan Gateway Server" , "MS NetBIOS Browse"

        $Filter = 0,0,7,0,0,0,0,0,1,1,1,3,3,4,0,4,4,6,7,6,1,1,7,7,0,5,5,5,7,7,2,2,2,7,0

        $Item  = @( "SVX Service" ; "Microsoft Exchange" , "Lotus Notes" , "Modem Sharing" , "SMS Clients Remote" , "Domain" , "DEC TCPIP SVC" | % { "$_ SVX" } ; "SVX" )

        $Service = ForEach ( $i in 0..34 ) { $Item[ ( $Filter[$I] ) ].Replace( "SVX" ,"$( $SVX[$I] )" )  }

        $List = @( ) ; ForEach ( $i in 0..34 ) { $List += [ PSCustomObject ]@{ ID = $ID[$i] ; Type = $Type[$i] ; Service = $Service[$i] } }

        Write-Theme -Action "Initiating [~]" "NetBIOS Scanner"

        ForEach ( $I in ( 0..( $IP.Count - 1 ) ) ) 
        {
            Write-Theme -Function "Host # $( $IP[$I] )"

            $DNS = Resolve-DnsName -Name $IP[$I] -EA 0 | % { $_.Namehost }
                
            If ( $DNS -eq $Null ) { $DNS = "*No Hostname*" }

            $X   = @( )

            If ( $IP[$I] -eq $IPV4 ) { NBTSTAT -n         | ? { $_ -like "*Registered*" } | % { If ( $_ -notin $X ) { $X += $_ } } }

            If ( $IP[$I] -ne $IPV4 ) { NBTSTAT -A $IP[$I] | ? { $_ -like "*Registered*" } | % { If ( $_ -notin $X ) { $X += $_ } } }

            ForEach ( $y in 0..( $X.Count - 1 ) ) { If ( $X[$Y] -like "*__MSBROWSE__*" ) { $X[$Y] = "    MSBROWSE       <01>  GROUP       Registered " } }

            $X | % { 

                $Z = @( $_[0..18] , $_[19..23] , $_[24..32] | % { ( $_ -ne " " ) -join '' } )

                $List | ? { $Z[1] -eq $_.ID -and $Z[2] -eq $_.Type } | % { $SVC = $_.Service }

                $Return += [ PSCustomObject ]@{ IP = $IP[$I] ; Host = $DNS ; Name = $Z[0] ; ID = $Z[1] ; Type = $Z[2] ; Service = $SVC }
            }
        }

    Return $( If ( !$Table ) { $Return } If ( $Table ) { $Return | FT -AutoSize } )  #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}