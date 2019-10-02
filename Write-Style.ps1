# Something I thought about a while back, somehow found my way back to doing it...
# [ Hint : It colorizes the grid of characters to have a kick ass theme ] #
"  ____                                                                        ____    ____    ____    ____    ____  "
" //¯¯\\______________________________________________________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\ "
" \\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__// "
"  ¯¯¯\\__[ Collecting Network/Host Information [30-45 seconds] ]__________]__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  "
"      ¯¯¯¯¯ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ ¯¯¯¯¯    ¯¯¯¯    ¯¯¯¯    ¯¯¯¯    ¯¯¯¯      "
"  ¯¯¯\\__[ Collecting Network/Host Information [30-45 seconds]fnejbvgf... ]"
$R = 0..120 | % { " " * $_ } ; $S = 0..120 | % { "_" * $_ } ; $T = 0..120 | % { "¯" * $_ }


$Function = "Collecting Network/Host Information [30-45 seconds]fnejbvgfjuirehnogisnresmg"
$FA = $Function

If ( $FA.Length -le 58 ) { $Y = " ]$($S[60-$FA.Length])" }
If ( $FA.Length -gt 58 ) { $FA = "$($FA[0..58] -join '' )... " ; $Y = "]__/"}

$0= "Green"
$1 =  "Red"

Write-Host "  ____  $( $R[68] )$( "  ____  " * 5 )" -F 10 -B 0

Write-Host " /"          -F 10 -B 0 -N
Write-Host "/¯¯\"        -F 12 -B 0 -N
Write-Host "\$($S[70])/" -F 10 -B 0 -N
Write-Host "/¯¯\"        -F 12 -B 0 -N
Write-Host "\__/"        -F 10 -B 0 -N
Write-Host "/¯¯\"        -F 12 -B 0 -N
Write-Host "\__/"        -F 10 -B 0 -N
Write-Host "/¯¯\"        -F 12 -B 0 -N
Write-Host "\__/"        -F 10 -B 0 -N
Write-Host "/¯¯\"        -F 12 -B 0 -N
Write-Host "\__/"        -F 10 -B 0 -N
Write-Host "/¯¯\"        -F 12 -B 0 -N
Write-Host "\ "          -F 10 -B 0 

Write-Host " \"          -F 10 -B 0 -N
Write-Host "\__/"        -F 12 -B 0 -N
Write-Host "/$($T[70])\" -F 12 -B 0 -N
Write-Host "\__/"        -F 12 -B 0 -N
Write-Host "/¯¯\"        -F 12 -B 0 -N
Write-Host "\__/"        -F 12 -B 0 -N
Write-Host "/¯¯\"        -F 12 -B 0 -N
Write-Host "\__/"        -F 12 -B 0 -N
Write-Host "/¯¯\"        -F 12 -B 0 -N
Write-Host "\__/"        -F 12 -B 0 -N
Write-Host "/¯¯\"        -F 12 -B 0 -N
Write-Host "\__/"        -F 12 -B 0 -N
Write-Host "/ "          -F 10 -B 0

Write-Host "  ¯¯¯\"      -F 10 -B 0 -N
Write-Host "\__[ "       -F 12 -B 0 -N
Write-Host "$FA"         -F 14 -B 0 -N
Write-Host "$Y"          -F 12 -B 0 -N
Write-Host "/¯¯\"        -F 10 -B 0 -N
Write-Host "\__/"        -F 12 -B 0 -N
Write-Host "/¯¯\"        -F 10 -B 0 -N
Write-Host "\__/"        -F 12 -B 0 -N
Write-Host "/¯¯\"        -F 10 -B 0 -N
Write-Host "\__/"        -F 12 -B 0 -N
Write-Host "/¯¯\"        -F 10 -B 0 -N
Write-Host "\__/"        -F 12 -B 0 -N
Write-Host "/¯¯¯  "      -F 10 -B 0 

Write-Host "      $( $T[72] )$( "    ¯¯¯¯" * 4 )      " -F 10 -B 0


    Function Write-Style
    {
        [ CmdLetBinding ( ) ] Param (

            [ Parameter ( Position = 0 , ValueFromPipeline = $True ) ][ Alias ( "S" ) ][ String ]     $String ,
            [ Parameter ( Position = 1 , ValueFromPipeline = $True ) ][ Alias ( "F" ) ][    Int ] $Foreground ,
            [ Parameter ( Position = 2 , ValueFromPipeline = $True ) ][ Alias ( "B" ) ][    Int ] $Background ,
            [ Parameter ( Position = 3 , ValueFromPipeline = $True ) ][ Alias ( "E" ) ][ Switch ]        $End )


            If (!$End )
            {
                $OP += Write-Host $String -ForegroundColor $Foreground -BackgroundColor $Background -NoNewline
            }

            If ( $End )
            {
                $OP += Write-Host $String -ForegroundColor $Foreground -BackgroundColor $Background
            }

        Return $OP
    }


$Line  = [ PSCustomObject ]@{ 
#-[ Line 0 ]--------------------------------------------------------------------------------------#
S0 = "  ____  $( $R[68] )$( "  ____  " * 5 )"
F0 = 10
B0 = 0
#-[ Line 1 ]--------------------------------------------------------------------------------------#
S1 = " /","/¯¯\","\$($S[70])/","/¯¯\","\__/","/¯¯\","\__/","/¯¯\","\__/","/¯¯\","\__/","/¯¯\","\ "
F1 = 10,12,10,12,10,12,10,12,10,12,10,12,10
B1 = 0,0,0,0,0,0,0,0,0,0,0,0,0
#-[ Line 2 ]--------------------------------------------------------------------------------------#
S2 = " \","\__/","/$($T[70])\","\__/","/¯¯\","\__/","/¯¯\","\__/","/¯¯\","\__/","/¯¯\","\__/","/ "
F2 = 10,12,12,12,12,12,12,12,12,12,12,12,10
B2 = 0,0,0,0,0,0,0,0,0,0,0,0,0
#-[ Line 3 ]--------------------------------------------------------------------------------------#
S3 = "  ¯¯¯\","\__[ ","$FA","$Y","/¯¯\","\__/","/¯¯\","\__/","/¯¯\","\__/","/¯¯\","\__/","/¯¯¯  "
F3 = 10,12,14,12,10,12,10,12,10,12,10,12,10
B3 = 0,0,0,0,0,0,0,0,0,0,0,0,0
#-[ Line 4 ]--------------------------------------------------------------------------------------#
S4 = "      $( $T[72] )$( "    ¯¯¯¯" * 4 )      "
F4 = 10
B4 = 0
}

$ST , $FR , $BA = $Line | % { $_.S0 , $_.F0 , $_.B0 }
If ( $ST.Count -eq 1 ) { Write-Style $ST $FR $BA }
Else
{
    ForEach ( $i in ( 0..( $ST.Count - 1 ) ) ) 
    { 
        Write-Style $ST[$I] $FR[$I] $BA[$I] 
    }
}
