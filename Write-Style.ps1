Function Write-Style
{
    [ CmdLetBinding ( ) ] Param (

        [ Parameter ( Position = 0 , ValueFromPipeline = $True ) ][ Alias ( "S" ) ][ String ]     $String ,
        [ Parameter ( Position = 1 , ValueFromPipeline = $True ) ][ Alias ( "F" ) ][    Int ] $Foreground ,
        [ Parameter ( Position = 2 , ValueFromPipeline = $True ) ][ Alias ( "B" ) ][    Int ] $Background ,
        [ Parameter ( Position = 3 , ValueFromPipeline = $True ) ][ Alias ( "E" ) ][ Switch ]        $End )
        If (!$End ) { $OP += Write-Host $String -ForegroundColor $Foreground -BackgroundColor $Background -NoNewline }
        If ( $End ) { $OP += Write-Host $String -ForegroundColor $Foreground -BackgroundColor $Background } ; Return $OP
}

Function Write-Theme
{
    [ CmdLetBinding ( ) ] Param (

        [ Parameter ( Position = 0 , ValueFromPipeline = $True ) ][ Alias ( "M" ) ][ String ]    $Message ,
        [ Parameter ( Position = 1 , ValueFromPipeline = $True ) ][ Alias ( "E" ) ][    Int ]       $Edge ,
        [ Parameter ( Position = 2 , ValueFromPipeline = $True ) ][ Alias ( "C" ) ][    Int ]     $Center ,
        [ Parameter ( Position = 3 , ValueFromPipeline = $True ) ][ Alias ( "T" ) ][    Int ]       $Type ,
        [ Parameter ( Position = 4 , ValueFromPipeline = $True ) ][ Alias ( "B" ) ][    Int ]       $Back )

    $R = 0..120 | % { " " * $_ } ; $S = 0..120 | % { "_" * $_ } ; $T = 0..120 | % { "¯" * $_ }
    
    $FA = $Message ; $CV = $Edge ; $CW = $Center ; $CY = $Type 

    If ( $FA.Length -le 58 ) { $Y = " ]$($S[62-$FA.Length])__/" } If ( $FA.Length -gt 58 ) { $FA = "$($FA[0..58] -join '' )... " ; $Y = "]__/"}

    $ST  = @{ 0 = "  ____  $( $R[68] )$( "  ____  " * 5 )" 
    1 = @( " /" , "/¯¯\" , "\$($S[70])/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\ " )
    2 = @( " \" , "\__/" , "/$($T[70])\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/ " ) ; 
    3 = @( "  ¯¯¯\" , "\__[ " , "$FA" , "$Y" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯\" , "\__/" , "/¯¯¯  " )
    4 = "      $( $T[72] )$( "    ¯¯¯¯" * 4 )      " }

    $FG = @{ 0 = $CV ; 1 = @($CV,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV ) ; 
    2 = @($CV,$CW,$CW,$CW,$CW,$CW,$CW,$CW,$CW,$CW,$CW,$CW,$CW,$CW,$CV )
    3 = @($CV,$CW,$CY,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV,$CW,$CV ) ; 4 = $CV }

    $BG  = @{ 0 = $CX ; 1 = 0..13 | % { $CX } ; 2 = 0..13 | % { $CX } ; 3 = 0..13 | % { $CX } ; 4 = $CX }

    ForEach ( $i in 0..4 ) 
    { 
        If ( $ST[$I].Count -eq 1 ) { Write-Style $ST[$i] $FG[$i] $BG[$i] -E }
        Else { $XX = @( $ST[$I] ) ; $XY = @( $FG[$I] ) ; $XZ = @( $BG[$I] )
            ForEach ( $X in ( 0..( $XX.Count - 1 ) ) ) 
            { If ( $X -eq $XX.Count - 1 ) 
            {          Write-Style $XX[$X] $XY[$X] $XZ[$X] -E }
                Else { Write-Style $XX[$X] $XY[$X] $XZ[$X]    }
            }
        }
    }
}
