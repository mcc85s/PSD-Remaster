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
            $B  = @{ 0 = 0..1 ; 1 = 1..0 } ; $Z  = "  " , "¯-" , "-_" | % { $_ * 54 } ; $S  = " // " , " \\ " ; $F  = "/¯¯\" , "\__/"
            $FR = 0..1 | % { ( $F[( $B[$_] )] ) * 13 -join '' } ; $D  = 0..1 | % { $X , $Y = $B[$_][0..1] ; "$( $S[$X] + $FR[$_] + $F[$X] + $S[$Y] )" }
            $L , $R = $S , $S[1..0] ; $LI = 0..1 | % { $L[$_] + $Z[0] + $R[$_] }
            $TopL = "  $( "_" * 112 )  " , $D , " //$( "¯" * 110 )\\ " , $LI[1]
            $BotL = $LI[0] , " \\$( "_" * 110 )// " , $D , "  $( "¯" * 112 )  "
            $OP = @( )
        }

        Process 
        {
            # - [ Top Wrapper ] - - - - - - - - #

            If ( $Top ) { $OP += $TopL }

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
                # - [ Discover / Format Title ] - - - - - - #

                $HT       = $Hash | GM
                $Title    =   $HT | ? { $_.Name -eq "[+]Title" } | % { $_.Definition.Split( "=" )[1] } | % { $_.Replace( ' ' , '-' ) } | % { "[ $_ ]" }

                # - [ Calculate Title via Shrodingers Fricken' Cat ] - - - - - - - #

                $TT = 108 - $Title.Length ; $TX = $TT % 4 ; $TY = ( $TT - $TX ) / 4 ; $T = ( $Title | % { "$_" , "$_-" , "$_ " , " $_ -" } )[$TX]
                $TL , $TR = "_¯" , "¯_" | % { $_ * $TY }

                $Title    = $S[0] + $TL + $T + $TR + $S[1]

                # - [ Send Title to Output Array ] - - - - - #

                $OP      += $Title , $LI[1]

            # - [ Discover / Format Sections ] - - - - - - #

            $Index   =   $HT | ? { $_.Name -like "*]Index*" }
            $Count   = $Index.Count - 1

            If ( $Count -gt 0 ) { $Count = 0..$Count }

            $Names   = $Index | % { $_.Definition.Split( "=" )[1] }
            $Table   = [ Ordered ]@{ }

            $Total = 0

            # - [ Mathematics and Logic having a baby... ] - - - - #

            ForEach ( $i in $Count )
            { 
                If ( $Count.Count -gt 1 )
                {
                    If ( $C -ne $Null ) { $C = $C + 1 }
                    If ( ( $C -eq $Null ) -and ( $Name -eq $Null ) ) { $C = 0 }

                    $Name = $Names[$i]
                }

                If ( $Count.Count -eq 1 ) 
                {
                    $Name = $Names
                }

                # - [ Calculate / Output Section:# ] - - - - - - #

                $U  = 98 - $Name.Length
                $V  = $Total % 2
                $W  = ( 1 - $V )

                $SHeader = "_" , "¯" | % { "$( $L[$V] + ( "$_" * 108 ) + $R[$V] )" }
                $SLine   = "$( $L[$W] + ( "-" * 10 ) + $Name + ( "-" * $U ) + $R[$W] )"

                $OP += $SHeader[0] , $SLine , $SHeader[1]

                $Total = $Total + 3

                # - [ Calculate / Parse Items:# ] - - - - - - #

                $X = "[$I]:"
                $C = 0
                $HT | ? { "$( $_.Name.Split( ':' )[0] ):" -eq $X } | % {

                    $DF = $_.Definition.Replace( "string $X" , "" ).Split( "=" )
                    
                    $Y    = $Total % 2

                    $Key   = $DF[0].Split(':')[1] | % { "$( " " * ( 25 - $_.Length ) )$_" }
                    $Value = $DF[1] | % { "$_$( " " * ( 80 - $_.Length ) )" }
                    
                    $OP   += "$( $L[$Y] + $Key ) : $( $Value + $R[$Y] )"
                    $Total++
                    $C++
                }
            }

            If ( ( $OP.Count | Select -Last 1 ) % 2 -ne 0 ) { $OP += $LI[1] }      

        If ( $Bot ) { $OP += $LI[0] , " \\$( "_" * 110 )// " , $D , "  $( "¯" * 112 )  " }

        }
    }

    End { Return $OP }
}
