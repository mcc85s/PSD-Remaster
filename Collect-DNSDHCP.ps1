    Function Echo-Date
    {
        Return Get-Date -UFormat "%Y%m%d"
    }

    Function Collect-DHCP
    {
         $CMD = Get-DhcpServerv4OptionValue | Select OptionID , Name , Type , Value | Sort OptionID

           $X = @( 0..( $CMD.Count - 1 ) )

        $DHCP = @( $X )

        $Echo = @( "DHCP Log ( $( Echo-Date ) )" | % { ( "_" * $_.Length ) , $_ , ( "¯" * $_.Length ) } )

        ForEach ( $i in $X ) 
        { 
            $DHCP[$i] = [ Ordered ]@{ 
            OptionID = $CMD[$i].OptionID | % { If ( $_ -in 0..9 ) { "  $_" } If ( $_ -in 10..99 ) { " $_" } If ( $_ -gt 99 ) { "$_" } }
                Name = $CMD[$i].Name   
                Type = $CMD[$i].Type
               Value = $CMD[$i].Value    | % { If ( $_.Count -gt 1 ) { @( $_ ) } Else { $_ } } }
            
            $DHCP[$I] | % { 
                
                $Echo += "OptionID: $( $_.OptionID ) $( $_.Name | % { 
                
                If ( $_ -eq $Null ) { "/ N/A" } 
                
                Else { "$_" } } )" | % { ( "_" * $_.Length ) , $_ , ( "¯" * $_.Length ) } 
                
                $X = "$( $_.Type )"

                If ( $_.Value.Count -gt 1 )
                {
                    ForEach ( $i in ( 0..( $_.Value.Count - 1 ) ) )
                    {
                        If ( $i -eq 0 ) { $Echo +=              "$( $X ): $( $_.Value[$i] )" }
                        Else            { $Echo += "$( " " * $X.Length ): $( $_.Value[$i] )" }
                    }
                }

                If ( $_.Value.Count -eq 1 ) { $Echo += "$( $_.Type ): $( $_.Value )" }
            }
        }   

        "$Home\Desktop\$( Get-Date -UFormat "%Y%m%d" )_DHCP.txt" | % { 
        
            If ( Test-Path $_ ) { RI $_ -VB } 
            SC -Path $_ -Value $Echo
        }

        Echo $Echo
    }

    Function Collect-DNS
    {
        $Zone  = @( )
        
        Get-DnsServerZone | ? { $_.ZoneName -notlike "*.arpa*" } | ? { $_.ZoneName      -ne "TrustAnchors" } | % { $Zone += $_.ZoneName }
        Get-DNSServerZone | ? { $_.ZoneName    -like "*.arpa*" } | ? { $_.IsAutoCreated -ne         $True  } | % { $Zone += $_.ZoneName } 

        $R     = @( )
        $C     = @( "DNS Log ( $( Echo-Date ) )" | % { ( "_" * $_.Length ) , $_ , ( "¯" * $_.Length ) } )
        $RR    = "A" , "AAAA" , "CName" , "DHCID" , "NS" , "SOA" , "SRV"
        $RRT   = @( 4 , 6 | % { "IPv$_`Address" } ) + @( "HostNameAlias" , "DHCID" , "NameServer" )

        ForEach ( $i in $Zone ) 
        { 
            $R += $RR | % { Get-DNSServerResourceRecord -RRType $_ -ZoneName $i } 
        }

        ForEach ( $x in 0..6 ) 
        { 
            $RT = $RR[$x]
            $RT.Length | ? { $_ -lt 5 } | % { $RT = "$( " " * ( 5-$_ ) )$RT" }
            $C += "RecordType: $( $RT )" | % { ( "_" * $_.Length ) , $_ , ( "¯" * $_.Length ) }

            $R | ? { $_.RecordType -eq "$( $RR[$x] )" } | Select HostName , RecordType , RecordData | % {

                If ( $X -in 0..4 )
                {
                    $RD = $RRT[$X]
                    $C += "  Hostname: $( $_.HostName )" , "  $( $_.RecordData.$RD )" , "  ------------ "
                }

                If ( $X -eq    5 ) 
                {
                    $RD = @( )
                    $_.RecordData | % { $_.SerialNumber , $_.PrimaryServer , $_.ResponsiblePerson | % { $RD += "[$( $_ )]" } }
                    $C += $RD[0..3] -join ''
                }
                
                If ( $X -eq    6 ) 
                {
                    $RD = @( )
                    $_.RecordData | % { $_.Priority , $_.Weight , $_.Port , $_.DomainName | % { $RD += "[$( $_ )]" } }
                    $C += $RD[0..3] -join ''
                }
            }
        } 

        "$Home\Desktop\$( Get-Date -UFormat "%Y%m%d" )_DNS.txt" | % { 
        
            If ( Test-Path $_ ) { RI $_ -VB } 
            SC -Path $_ -Value $C
        }

        Echo $C
    }
