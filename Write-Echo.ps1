Function Write-Echo
{
    [ CmdLetBinding () ] Param (

        [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True , ParameterSetName = "0" ) ][ Switch ]   $Action ,
        [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True , ParameterSetName = "1" ) ][ Array ]     $Array ,
        [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True , ParameterSetName = "2" ) ][ PSCustomObject ] $Table ,

        [ Parameter ( Position = 1 , Mandatory = $True , ParameterSetName = "0" ) ][ String ] $Type ,
        [ Parameter ( Position = 2 , Mandatory = $True , ParameterSetName = "0" ) ][ String ] $Info ,
        [ Parameter ( Position = 1 , ParameterSetName = "1" ) ]
        [ Parameter ( Position = 1 , ParameterSetName = "2" ) ][ Switch ] $Top ,
        [ Parameter ( Position = 2 , ParameterSetName = "1" ) ]
        [ Parameter ( Position = 2 , ParameterSetName = "2" ) ][ Switch ] $Bot )

    Begin 
    {
        $B = @{ 0 = 0..1 ; 1 = 1..0 } ; $Z = "  " , "¯-" , "-_" | % { $_ * 54 } ; $S = " // " , " \\ " ; $F = "/¯¯\" , "\__/"
        $D = 0..1 | % { $X , $Y = $B[$_][0..1] ; "$( $S[$X] + ( $F[$X] + $F[$Y] ) * 13 + $F[$X] + $S[$Y] )" }
        $L , $R = $S[0..1] , $S[1..0] ; $LI = 0..1 | % { $L[$_] + $Z[0] + $R[$_] } ; $OP = @( )
    }

    Process 
    {
        # - [ Top Wrapper ] - - - - - - - - #

        If ( $Top ) { $OP += "  $( "_" * 112 )  " , $D , " //$( "¯" * 110 )\\ " , $LI[1] }

        # - [ Action Wrapper ]- - - - - - - #

        If ( $Action )
        {
            $T , $I = $Type , $Info ; $ST , $SI = ( 25 - $T.Length ) , ( 80 - $I.Length ) | % { " " * $_ }
            $Sub = "$( $S[1] )$ST$T : $I$SI$( $S[0] )" ; $AT , $AB = 1..2 | % { $S[0] + $Z[$_] + $S[1] }
            $OP += "" , $AT , $Sub , $AB , ""
        }

        # - [ Array Wrapper ] - - - - - - - #

        If ( $Array ) { Return $Array }

        # - [ Hashtable Wrapper ] - - - - - #

        If ( $Table )
        {
            # - [ Hashtable Title ] - - - - - - - #

            $TT = "[ $( $Table.Title.Replace( ' ' , '-' ) ) ]" ; $T = $TT | % { "$_" , "$_-" , "$_ " , " $_ -" }
            $U = 108 - $TT.Length ; $V = $U % 4 ; $W = ( $U - $V ) / 4 ; $TL , $TR = "_¯" , "¯_" | % { $_ * $W }
                
            $OP += " // $TL$( $T[$V] )$TR \\ " , $LI[1]

            # - [ Hashtable Index ] - - - - - - - #

            ForEach ( $I in $Table.Index )
            {
                If ( $Table.Index.Count -gt 1 )
                {
                    If ( $C -ne $Null ) { $C = $C + 1 }
                    If ( ( $C -eq $Null ) -and ( $Name -eq $Null ) ) { $C = 0 }
                    $Name = $Table.Index.Name[$C] ; $Item = $Table.Index.Items[$C]
                }

                If ( $Table.Index.Count -eq 1 ) 
                {
                    $Name = $Table.Index.Name ; $Item = $Table.Index.Items
                }

                # - [ Hashtable Section ] - - - - - - #

                $V  = $C % 2 ; $W = ( 1 - $V ) ; $U = 98 - $Name.Length
                $TO = "$( $L[$V] + ( "_" * 108 ) + $R[$V] )"
                $LL = "$( $L[$W] + ( "-" * 10 ) + $Name + ( "-" * $U ) + $R[$W] )"
                $BO = "$( $L[$V] + ( "¯" * 108 ) + $R[$V] )"

                $OP += $TO , $LL , $BO

                # - [ Hashtable Items ] - - - - - - - #

                $IC = $Item.Count

                If ( $IC -gt 1 )
                {
                    $IC = $IC - 1

                    If ( $C % 2 -eq 1 ) { $IZ = 0..1 } Else { $IZ = 1..0 }

                    $IK = @( $Item.Keys ) ; $IV = @( $Item.Values )

                    ForEach ( $Q in 0..$IC )
                    {
                        $P       = $IZ[$Q % 2]
                        $Key     = $IK[$Q] | % { "$( " " * ( 25 - $_.Length ) )$_" }
                        $Val     = $IV[$Q] | % { "$_$( " " * ( 80 - $_.Length ) )" }
                        $OP += "$( $L[$P] )$Key : $Val$( $R[$P] )"
                    }
                
                    If ( ( $IC | Select -Last 1 ) % 2 -eq 0 )
                    {
                        $OP += $LI[$V]
                    }
                }

                If ( $Item.Count -eq 1 )
                {
                    $Key = $Item.Keys   | % { "$( " " * ( 25 - $_.Length ) )$_" }
                    $Val = $Item.Values | % { "$_$( " " * ( 80 - $_.Length ) )" }
                    $OP += "$( $L[$V] )$Key : $Val$( $R[$V] )" , $LI[$W]
                }

                If ( $C -eq ( $Table.Index.Count - 1 ) )
                {
                    If ( $OP.Length % 2 -eq 1 )
                    {
                        $OP = $OP[ 0..( $OP.Length - 2 ) ]
                    }
                }
            }
        }

        # - [ Bottom Wrapper ] - - - - - - - - #

        If ( $Bot ) { $OP += $LI[0] , " \\$( "_" * 110 )// " , $D , "  $( "¯" * 112 )  " }
    }

    End { Return $OP }
}
