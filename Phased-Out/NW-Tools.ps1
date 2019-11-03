 
 #____                                                                             __//¯¯\\__//==\\__/----\__//==\\__/----\__//==\\__/----\__//¯¯\\___  
#//¯¯\\___________________________________________________________________________/¯¯¯    ¯¯¯¯ ¯¯ ¯¯¯¯ ¯¯ ¯¯¯¯ ¯¯ ¯¯¯¯ ¯¯ ¯¯¯¯ ¯¯ ¯¯¯¯ ¯¯ ¯¯¯¯ ¯¯ ¯¯¯\\ 
#\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯        ____    ____ __ ____ __ ____ __ ____ __ ____ __ ____    ___// 
    Function Get-HostRange # Obtains a range of potential hosts _________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯     

        $Class = "Network" , "A" , "B" , "C" , "D / MC" , "E / R&D" , "Broadcast" , "Loopback"

        $Range = [ Ordered ]@{ 0 = 0 ; 1 = 1..126 ; 2 = 128..191 ; 3 = 192..223 ; 4 = 224..239 ; 5 = 240..254 ; 6 = 6 ; 7 = 127 }

        Get-NetworkInfo | % { $IP = $_.IPV4.Split( '.' ) ; $SM = $_.NetMask.Split( '.' ) }
            
        $Full  = @( ) ; $Concat = 0 ; $Close = 0

        ForEach ( $I in 0..3 )
        {
            If ( $Close -eq 0 )
            {
                If ( $SM[$I] -eq 255 ) 
                { 
                    $Full += $IP[$I] 
                } 
                
                If ( $SM[$I] -ne 255 ) 
                { 
                    $Concat = 1 
                }

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

                                $Y  = $X | Select -First 1 , $X | Select -Last  1

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
            
        Return [ PSCustomObject ]@{ 

            Class   = ForEach ( $k in 1..5 ) 
            { 
                If ( $IP[0] -in $Range[$k] ) 
                { 
                    "Class $( $Class[$k] ) Address" 
                }
            }
            Prefix  = $Full
            IPV4    = $IP -Join "."
            NetMask = $SM -Join "."
            Subnet  = $NW 
            Start   = $Start
            End     = $End
            Echo    = $BC 
        }
    }#                                                                            ____    ____    ____    ____    ____    ____    ____    ____    ____  
#//¯¯\\__________________________________________________________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\ 
#\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__// 
    Function Get-HostMask # Obtains NetMask Chart, number of hosts and etc.       ¯¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#\______________________________________________________________________________/¯¯¯¯    ¯¯¯¯    ¯¯¯¯    ¯¯¯¯    ¯¯¯¯    ¯¯¯¯    ¯¯¯¯    ¯¯¯¯      
    
        [ CmdLetBinding () ] Param ( 
        
            [ Parameter ( Position = 0 , Mandatory = $True , ParameterSetName = "0" ) ][ Switch ] $Locate  , 
            [ Parameter ( Position = 0 , Mandatory = $True , ParameterSetName = "1" ) ][ Switch ] $HostMap , 
            [ Parameter ( Position = 0 , Mandatory = $True , ParameterSetName = "2" ) ][ Switch ] $Table   )

            $V     = @( 0..9 | % { "  $_" }  ; 10..99 | % { " $_" } ; 100..255 | % { "$_" } ) | % { "[$_]" } 

            $W     = $V.Replace( " " , "¯" )
            
            $CT    = 0

            $OB    = 0..126 

            $Bot   = 0..15 | % { "¯" * $_ }

            $Top   = 0..15 | % { "_" * $_ }

            $Items = 0..3 

            $GT    = $W , $V , $V , $V

            $GX    = "Mask" , "Start" , "End" , "Broad" | % { "[$( "¯" * ( 6 - $_.Length ) )$( $_ ):¯" } 
            
            ForEach ( $i in 0..3 ) 
            { 
                $Items[$I] = $GT[$I] | % { $GX[$I] , $_ -join '' } 
            }
            
            $Subnet , $Start , $End , $Echo = $Items[0..3]
            
            $OP = @( )

            1 , 2 , 4 , 8 , 16 , 32 , 64 | % { 

                $I = $_

                $X = 256 / $I

                If ( $I -gt 1 ) { $C = $I..1 } Else { $C = 1 }
                
                $Y = $C | % { 256 - ( $X ) * $_ }
                
                If ( $I -gt 1 ) { $C = 0..( $I - 1 ) }

                $C | % { $X * $_ } | % { 
                
                    If ( $I -eq 1 ) 
                    { 
                        $OB[$CT] = [ PSCustomObject ]@{ Count = 1 ; Subnet = 0 ; Start = 1 ; End = 254 ; Echo = 255 } 
                    }

                    Else 
                    {
                        $OB[$CT] = [ PSCustomObject ]@{ Count = "$( $_ / $X + 1 )/$I" ; Subnet = $_ ; Start = $_ + 1 ; End   = $_ + ( $X - 2 ) ; Echo  = $_ + ( $X - 1 ) } 
                    }
                    
                    $CT ++
                }
            }

            If (   $Table ) { Return $OB }

            If (  $Locate ) 
            { 
                $Hosts = Get-HostRange

                $PFX   = $Hosts.Prefix 

                $K     = $Hosts | Select Subnet , Start , End , Echo

                $Comp  = $OB | Select @{ Name = "Subnet" ; Expression = { "$PFX.$( $_.Subnet )" } } , 
                                      @{ Name =  "Start" ; Expression = { "$PFX.$( $_.Start  )" } } , 
                                      @{ Name =    "End" ; Expression = { "$PFX.$( $_.End    )" } } , 
                                      @{ Name =   "Echo" ; Expression = { "$PFX.$( $_.Echo   )" } }

                $I     = 0

                $Comp  | % { 
                    
                    If ( $_.Subnet -eq $K.Subnet -and $_.Start -eq $K.Start -and $_.End -eq $K.End -and $_.Echo -eq $K.Echo ) 
                    { 
                        $Select = $OB[$I] 
                    } 
                    
                    Else { $I++ } 
                }

                Return $Select
            }

            If ( $HostMap )
            {
                $OB | ? { $_.Count -eq "1" } | % { $Top[14] , "[ 1 _________]" , $Subnet[$_.Subnet] , $Start[$_.Start] , $End[$_.End] , $Echo[ $_.Echo] , $Bot[14] | % { $OP += $_ } }
                
                ForEach ( $I in 2 , 4 , 8 , 16 , 32 , 64 )
                {
                    $Object = $OB | ? { $_.Count -like  "*/$I*" }
                    
                    $OC = $Object.Count - 1

                    $LJ = 0..$OC

                    ForEach ( $I in $LJ )
                    {
                        $Object[$I] | % { $NWQ = $_.Count | % { "[_ $_ $( "_" * ( 9 - $_.Length ) )]" }

                            $LJ[$I] = [ PSCustomObject ]@{ 0 = $Top[14] ; 1 = $NWQ ; 2 = $Subnet[$_.Subnet] ; 3 = $Start[$_.Start] ; 4 = $End[$_.End] ; 5 = $Echo[$_.Echo] ; 6 = $Bot[14] } 
                        }
                    }
        
                    If ( $I -eq $OC )
                    {   
                        $OP += 0..6 | % { $LJ[0..7].$_ -join '' }

                        If ( $I -gt 8 ) 
                        { 
                            $Loop = ( $Object.Count / 8 ) - 1

                            $L    = 0

                            $H    = 7

                        Do
                        { 
                            $L   += 8

                            $H   += 8

                            $OP  += 0..6 | % { $LJ[$L..$H].$_ -join '' } 
                            
                            $Loop -= 1 }
                            
                            Until ( $Loop -eq 0 ) 
                        }
                    }
                }
                Return $OP
            }
    }#     