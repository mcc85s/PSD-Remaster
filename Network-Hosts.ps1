



    
    $V  = @( 0..9 | % { "  $_" }  ; 10..99 | % { " $_" } ; 100..255 | % { "$_" } ) | % { "[$_]" } ; $W = $V.Replace( " " , "¯" ) 
    $CT = 0 ; $OB = 0..126 ; $Bot = 0..15 | % { "¯" * $_ } ; $Top = 0..15 | % { "_" * $_ } ; $Items = 0..3 ;
    $GX = "Mask" , "Start" , "End" , "Broad" | % { "[$( "¯" * ( 6 - $_.Length ) )$( $_ ):¯" } 

    ForEach ( $i in 0..3 ) { $J = $( If ( $I -eq 0 ) { $W } Else { $V } ) ; $Items[$I] = $J | % { $GX[$I] , $_ -join '' } }

    $Mask , $Start , $End , $Echo = $Items[0..3] ; $OP = @( )

    1 , 2 , 4 , 8 , 16 , 32 , 64 | % { 
        $I = $_ ; $X = 256 / $I ; If ( $I -gt 1 ) { $C = $I..1 } Else { $C = 1 } ; $Y = $C | % { 256 - ( $X ) * $_ } ; If ( $I -gt 1 ) { $C = 0..( $I - 1 ) }
        $C | % { $X * $_ } | % {  If ( $I -eq 1 ) { $OB[$CT] = [ PSCustomObject ]@{ Count = 1 ; Mask = 0 ; Start = 1 ; End = 254 ; Echo = 255 } }
            Else { $OB[$CT] = [ PSCustomObject ]@{ Count = "$( $_ / $X + 1 )/$I" ; Mask = $_ ; Start = $_ + 1 ; End   = $_ + ( $X - 2 ) ; Echo  = $_ + ( $X - 1 ) } }
            $CT ++
        }
    }

    $OB | ? { $_.Count -eq "1" } | % { $Top[14] , "[ 1 _________]" , $Mask[$_.Mask] , $Start[$_.Start] , $End[$_.End] , $Echo[ $_.Echo] , $Bot[14] | % { $OP += $_ } }

    ForEach ( $I in 2 , 4 , 8 , 16 , 32 , 64 )
    {
        $Object = $OB | ? { $_.Count -like  "*/$I*" }
        $OC     = $Object.Count - 1
        $LJ     = 0..$OC

        ForEach ( $I in $LJ )
        {
            $Object[$I] | % { $NWQ = $_.Count | % { "[_ $_ $( "_" * ( 9 - $_.Length ) )]" }
                $LJ[$I] = [ PSCustomObject ]@{ 0 = $Top[14] ; 1 = $NWQ ; 2 = $Mask[$_.Mask] ; 3 = $Start[$_.Start] ; 4 = $End[$_.End] ; 5 = $Echo[$_.Echo] ; 6 = $Bot[14] } 
            }
        }
        
        If ( $I -eq $OC )
        {   
            $OP += 0..6 | % { $LJ[0..7].$_ -join '' }
            If ( $I -gt 8 ) 
            { 
                $Loop = ( $Object.Count / 8 ) - 1 ; $L = 0 ; $H = 7 
                Do
                {
                    $L += 8 ; $H += 8
                    $OP += 0..6 | % { $LJ[$L..$H].$_ -join '' }
                    $Loop -= 1
                }
                Until ( $Loop -eq 0 )
            }
        }
    }
