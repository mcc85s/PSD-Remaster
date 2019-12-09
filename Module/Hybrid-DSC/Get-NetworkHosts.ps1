    Function Get-NetworkHosts # Gets actual used network host addresses _________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        $Mac = Resolve-MacAddress 

        Function Return-Vendor
        {
            [ CmdLetBinding () ] Param ( [ Parameter ( Position = 0 , Mandatory = $True ) ] [ String ] $MacAddress )

            $Mac | % { $Code = $_.Count ; $Index  = $_.Index ; $Vendor = $_.Vendor }

            $Item = ( $MacAddress[ 0..5 ] -join '' )

            $Count  = 0

            $Item = $Item | % { [ Convert ]::ToInt64( $_,16 ) }

            ForEach ( $i in 1..( $Code.Count ) )
            {
                $Count = $Count + $Code[$I]
                If ( $Count -eq $Item ) { Return $Vendor[ ( $Index[ $I + 1 ] ) ] }
            }
        }

        Function Return-Class
        {
            [ CmdLetBinding () ] Param (

                [ Parameter ( Position = 0 , Mandatory = $True ) ] [ String ] $IPAddress )

            $Class = "N" , "A" , "B" ,"C" , "MC" , "R" , "BR" ,"L"
            $Range = @( 0 ; 1..126 | % { 1 } ; 7 ; 128..191 | % { 2 } ; 192..223 | % { 3 } ; 224..239 | % { 4 } ; 240..254 | % { 5 } ; 6 )

            Return $( $Class[ ( $Range[ ( $IPAddress.Split('.')[ 0 ] ) ] ) ] | % {

                If ( $_ -in ( "A" , "B" , "C" ) ) { Return "Class $_" }
                If ( $_ -eq "MC" ) { "Multicast" }
                If ( $_ -eq "R"  ) { "Reserved"  }
                If ( $_ -eq "BR" ) { "Broadcast" }
                If ( $_ -eq "L"  ) { "Localhost" }
                If ( $_ -eq "N"  ) { "Invalid"   }
            })
        }

        $List = @( )

        ForEach ( $i in "dynamic" , "static" )
        { 
            $List += arp -a | ? { $_ -like "*$I*" }
        }

        $Parse = @( )

        Get-NetworkInfo -LocalHost | % { $Parse += [ PSCustomObject ]@{ IPAddress = $_.IPV4 ; MacAddress = $_.MAC ; LeaseType = "localhost" } }

        ForEach ( $i in 0..( $List.Count - 1 ) )
        {
            $X , $Y , $Z = $List[$I]    | % { $_[0..23] , $_[24..40] , $_[41..55] | % { $_ -join ""  } }
            $X , $Y , $Z = $X , $Y , $Z | % { $_.Replace( " " , '' ) } | % { $_.Replace( "-" , '' ) }
            $Parse += [ PSCustomObject ]@{ IPAddress = $X ; MacAddress = $Y ; LeaseType = $Z }
        }

        $Reparse = @( )

        ForEach ( $i in 0..( $Parse.Count - 1 ) )
        {
            $Parse[$I] | % { 
            
                $X    = $Parse[$I]
                $MACV = $( $X.MacAddress | % { 
            
                    If ( $_.StartsWith( "01005e" ) -or $_.StartsWith( "ffffff" ) ) { "-" } 
                    Else { Return-Vendor -MacAddress ( $X.MacAddress ) } } )

                Return [ PSCustomObject ]@{ 
                    IPV4Address = $_.IPAddress
                    IPV4Class   = Return-Class -IPAddress $_.IPAddress
                    MACAddress  = $_.MacAddress
                    MACVendor   = $MACV
                }
            }
       }                                                                             #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}