Function Get-IPInfo
{
    Return @( ipconfig /all )
}

Function Get-DNSSuffix
{
    $DNS = @( )
    Get-IPInfo | ? { $_ -like "*Connection-specific DNS Suffix*" } | % { $_.Split( ':' )[1].ToCharArray() } | ? { $_ -ne " " } | % { $DNS += $_ }
    If ( $DNS -ne $Null ) { Return $DNS -join '' } Else { Return "[!] Not Detected" }
}

Function Get-SubnetMask
{
    $Subnet = @( )
    Get-IPInfo | ? { $_ -like "*Subnet Mask*" } | % { $_.Split( ':' )[1].ToCharArray() } | ? { $_ -ne " " } | % { $Subnet += $_ }
    If ( $Subnet -ne $Null ) { Return $Subnet -join '' } Else { Return "[!] Not Detected" }
}

Function Get-IPv4Address
{
    $IPv4 = @( )
    Get-IPInfo | ? { $_ -like "*IPv4 Address*" } | % { $_.Split( ':' )[1].ToCharArray() } | ? { $_ -ne " " } | % { $IPv4 += $_ }
    If ( $IPv4 -ne $Null ) { Return ( $IPv4 -join '' ).Replace( "(Preferred)" , '' ) } Else { Return "[!] Not Detected" }
}

Function Get-DNSServerIP
{
    $DNSS = @( )
    Get-IPInfo | ? { $_ -like "*Connection-specific DNS Suffix*" } | % { $_.Split( ':' )[1].ToCharArray() } | ? { $_ -ne " " } | % { $DNSS += $_ }
    If ( $DNSS -ne $Null ) { Return $DNS -join '' } Else { Return "[!] Not Detected" }
}

Function Get-NetBIOS
{
    $NBT = [ Ordered ]@{ Name = @( ) ; ID = @( ) ; Type = @( ) ; Status = @( ) }
    $NBTStat  = @( NBTSTAT -n )
    
    ForEach ( $I in ( 0..( $NBTStat.Count - 1 ) ) ) 
    { 
        $X = $NBTStat[$I]

        If ( $X -like "*<1C>*" )
        {
            $Name , $ID , $Type , $Status = 0..3 | % { @( ) }
            $X[ 0..18] | ? { $_ -ne " " } | % {   $Name += $_ } 
            $X[19..22] | ? { $_ -ne " " } | % {     $ID += $_ }
            $X[25..36] | ? { $_ -ne " " } | % {   $Type += $_ }
            $X[37..48] | ? { $_ -ne " " } | % { $Status += $_ }

            $NBT | % {   $_.Name +=   $Name -join ''
                           $_.ID +=     $ID -join ''
                         $_.Type +=   $Type -join ''
                       $_.Status += $Status -join '' }
        }
    
        If ( $NBT.Name -ne $Null ) { Return $NBT }
    }
}

Function Get-DNSSuffix
{
    $IPCONFIG = @( ipconfig /all ) ; $Name = @( )
    $IPConfig | ? { $_ -like "*Connection-specific DNS Suffix*" } | % { $_.Split( ':' )[1].ToCharArray() } | ? { $_ -ne " " } | % { $Name += $_ }
    If ( $Name -ne $Null ) { Return $Name -join '' } Else { Return "[!] Not Detected" }
}

Function Get-HostRange
{
    $Class = "Network" , "A" , "B" , "C" , "D / MC" , "E / R&D" , "Broadcast" , "Loopback"
    $Range = [ Ordered ]@{ 0 = 0 ; 1 = 1..126 ; 2 = 128..191 ; 3 = 192..223 ; 4 = 224..239 ; 5 = 240..254 ; 6 = 6 ; 7 = 127 }
    $IP = ( Get-IPv4Address ).Split( '.' )
    $SM = ( Get-SubnetMask  ).Split( '.' )

    $Full   = @( )
    $Concat = 0
    $Close  = 0

    ForEach ( $I in 0..3 )
    {
        If ( $Close -eq 0 )
        {
            If ( $SM[$I] -eq 255 ) { $Full += $IP[$I] } If ( $SM[$I] -ne 255 ) { $Concat = 1 }

            If ( $Concat -eq 1 )
            {
                $NW   = $Full -Join "."
                $Full = $NW

                If ( $SM[$I] -eq 0 )
                {
                    $NW , $Start , $End , $BC = 0 , 1 , 254 , 255 | % { "$Full.$_" }
                }

                Else
                {
                    ForEach ( $J in 1..5 )
                    { 
                        If ( $SM[$I] -in $Range[$J] )
                        {
                            $X  = $Range[$J]
                            $Y  = $X | Select -First 1  , $X | Select -Last  1
                            $Y += $Y[1] + 1
                                
                            $NW , $Start , $End , $BC = $Y[0..2] | % { "$Full.$_" }
                        }
                    }
                }

                $Close = 1
            }
        }
            
        If ( $Close -eq 1 )
        {
            If ( $I -ne 3 )
            {
                $NW , $BC , $Start , $End | % { "$_.0" }
            }
        }
    }
            
    $DHCP = [ Ordered ]@{ 
        Class      = ForEach ( $k in 1..5 ) { If ( $IP[0] -in $Range[$k] ) { "Class $( $Class[$k] ) Address" } }
        IPAddress  = $IP   -Join "." 
        SubnetMask = $SM   -Join "."
        Network    = $Full   
        Start      = $Start
        End        = $End 
        Broadcast  = $BC   }
    
    Echo $DHCP
}

Function Get-HostMask
{
    $Base = 1 , 2 , 4 , 8 , 16 , 32 , 64

    $Hash = [ Ordered ]@{ }
    ForEach ( $y in ( 0..( $Base.Count - 1 ) ) )
    {
        $X = $Base[$y]
        $Q = 256 / $X
            
        If ( $X -eq 1 )
        {
            $X | % { $A = 256 - $Q
                     $B = $A + $_
                     $C = 256 - ( $_ * 2 )
                     $D = 256 - $_ }

            $Hash.$y = [ Ordered ]@{
                Netmask   = $A
                Network   = $B
                Hosts     = $C
                Broadcast = $D 
            }
        }

        If ( $X -gt 1 )
        {
            $A , $B , $C , $D = 0..3 | % { @( ) }

            $A += 0..( $X - 1 ) | % { $Q * $_ }
            $B +=    $A | % { $_ + 1 }
            $C +=    $A | % { $_ + ( $Q - 2 ) }
            $D +=    $A | % { $_ + ( $Q - 1 ) }

            $Hash.$y = [ Ordered ]@{ 
                    Netmask   = @( $A ) 
                    Network   = @( $B )
                    Hosts     = @( $C )
                    Broadcast = @( $D ) }
        }
    }
    Return $Hash
}

Function Get-NetworkHosts
{
    $Return = @( )
    $List = @( )
    $ARP = @( arp -a )
    $Net = ( Get-HostRange ).Network

    Foreach ( $i in ( 0..( $ARP.count - 1 ) ) )
    { 
        If ( ( $ARP[$i] -like "*$Net*" ) -and ( $ARP[$i] -notlike "*Interface*" ) )
        {
            $List += $ARP[$i]
        }
    }

    ForEach ( $i in ( 0..( $List.Count - 1 ) ) )
    {
        $X = $List[$i]
        $Rarp = @{ INet = @( ) ; Phy = @( ) ; Type = @( ) }
        $INet , $Phy , $Type = 0..2 | % { @( ) }
        $X[ 0..23] | ? { $_ -ne " " } | % {   $INet += $_ } 
        $X[24..40] | ? { $_ -ne " " } | % {    $Phy += $_ }
        $X[41..56] | ? { $_ -ne " " } | % {   $Type += $_ }

        $RARP | % {   $_.INet +=   $INet -join ''
                       $_.Phy +=    $Phy -join ''
                      $_.Type +=   $Type -join '' }

        $Return += $RARP
    }
    
    $Return | ? { $_ -ne $Null } | % { Return $_ }
}

