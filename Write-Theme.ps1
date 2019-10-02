Function Write-Theme # A badass commandlet that makes PowerShell so cool to look at? Even your grandmother might say "That's pretty cool."
{
    [ CmdLetBinding ( ) ] Param (

        [ Parameter ( Mandatory = $True , Position = 0 , ValueFromPipeline = $True , ParameterSetName = "0" ) ][ String ] $Function ,
        [ Parameter ( Mandatory = $True , Position = 0 , ValueFromPipeline = $True , ParameterSetName = "1" ) ][ Switch ]   $Action ,
        [ Parameter ( Position = 1 , ValueFromPipeline = $True , ParameterSetName = "1" ) ][ String ] $Type ,
        [ Parameter ( Position = 2 , ValueFromPipeline = $True , ParameterSetName = "1" ) ][ String ] $Info ,

        [ Parameter ( Position = 1 , ValueFromPipeline = $True , ParameterSetName = "0" ) ]
        [ Parameter ( Position = 3 , ValueFromPipeline = $True , ParameterSetName = "1" ) ][    Int ]       $Edge = 10 ,
        [ Parameter ( Position = 2 , ValueFromPipeline = $True , ParameterSetName = "0" ) ]
        [ Parameter ( Position = 4 , ValueFromPipeline = $True , ParameterSetName = "1" ) ][    Int ]     $Center = 12,
        [ Parameter ( Position = 3 , ValueFromPipeline = $True , ParameterSetName = "0" ) ]
        [ Parameter ( Position = 5 , ValueFromPipeline = $True , ParameterSetName = "1" ) ][    Int ]       $Font = 15 ,
        [ Parameter ( Position = 4 , ValueFromPipeline = $True , ParameterSetName = "0" ) ]
        [ Parameter ( Position = 6 , ValueFromPipeline = $True , ParameterSetName = "1" ) ][    Int ]       $Back = 0 )

    Begin
    {
        $R = 0..120 | % { " " * $_ } ; $S = 0..120 | % { "_" * $_ } ; $T = 0..120 | % { "¯" * $_ }
        $CV = $Edge ; $CW = $Center ; $CX = $Font ; $CY = $Back
    }

    Process
    {
        If ( $Function )
        {
            $FA = $Function
            If ( $FA.Length -le 58 ) { $Y = " ]$($S[62-$FA.Length])__/" } 
            If ( $FA.Length -gt 58 ) { $FA = "$($FA[0..58] -join '' )... " ; $Y = "]__/"}
            $ST = @{ 0 = "  ____  $( $R[68] )$( "  ____  " * 5 )" 
            1 = " /" , "/¯¯\" , "\$($S[70])/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\ "
            2 = " \" , "\__/" , "/$($T[70])\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/ "
            3 = "  ¯¯¯\" , "\__[ " , "$FA" , "$Y" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯¯  "
            4 = "      $( $T[72] )$( "    ¯¯¯¯" * 4 )      " }
            $FG = @{ 0 = $CV
            1 = $CV,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV 
            2 = $CV,$CW,$CW,$CW,$CW,$CW,$CW,$CW,$CW,$CW,$CW,$CW,$CW,$CV
            3 = $CV,$CW,$CX,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV
            4 = $CV }

            $BG  = @{ 0 = $CY ; 1 = 0..13 | % { $CY } ; 2 = 0..13 | % { $CY } ; 3 = 0..13 | % { $CY } ; 4 = $CY }
        }

        If ( $Action )
        {
            $T , $I = $Type , $Info
            $X   = $( If ( $T.Length -gt 18 ) { "$( $T[0..17] -join '' )..." } Else { "$( " " * ( 21 - $T.Length ) )$T" } )
            $Y   = $( If ( $I.Length -gt 66 ) { "$( $I[0..65] -join '' )..." } Else { "$I$( " " * ( 69 - $I.Length ) )" } )
            $ST  = @{ 0 = "  ____    $( $S[100])      "
               1 = " /" , "/¯¯\" , "\__/", "/$( "¯" * 98 )\","\___  "
               2 = " \" , "\__/" , "/¯¯¯ " , " $X : $Y " , "___/" , "/¯¯\", "\ "
               3 = "  ¯¯¯\" , "\$( $S[98] )/", "/¯¯\","\__/","/ "
               4 = "      $( "¯" * 100 )    ¯¯¯¯  " }
            $FG  = @{ 0 = $CV ; 1 = $CV,$CW,$CV,$CW,$CV ; 2 = $CV,$CW,$CW,$CX,$CW,$CW,$CV ; 3 = $CV,$CW,$CV,$CW,$CV ; 4 = $CV }
            $BG  = @{ 0 = $CY ; 1 = 0..4 | % { $CY } ; 2 = 0..6 | % { $CY } ; 3 = 0..4 | % { $CY } ; 4 = $CY }
        }
    }

    End
    {
        ForEach ( $i in 0..4 ) 
        { 
            If ( $ST[$I].Count -eq 1 ) { Write-Host $ST[$i] -F $FG[$i] -B $BG[$i] }

            Else 
            { 
                $XX = @( $ST[$I] ) ; $XY = @( $FG[$I] ) ; $XZ = @( $BG[$I] )

                ForEach ( $X in ( 0..( $XX.Count - 1 ) ) ) 
                { 
                    If ( $X -eq $XX.Count - 1 ) 
                    {
                        Write-Host $XX[$X] -F $XY[$X] -B $XZ[$X] 
                    }
                    
                    Else 
                    { 
                        Write-Host $XX[$X] -F $XY[$X] -B $XZ[$X] -N 
                    }
                }
            }
        }
    }
}
