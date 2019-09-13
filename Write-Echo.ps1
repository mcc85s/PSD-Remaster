    Function Write-Echo
    {
        [ CmdLetBinding ( ) ] Param (
            [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True , ParameterSetName = "0" ) ][ Switch ]   $Action ,
            [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True , ParameterSetName = "1" ) ][ Array ]     $Array ,
            [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True , ParameterSetName = "2" ) ][ PSCustomObject ] $Table ,
            [ Parameter ( Position = 1 , Mandatory = $True , ParameterSetName = "0" ) ][ String ] $Type ,
            [ Parameter ( Position = 2 , Mandatory = $True , ParameterSetName = "0" ) ][ String ] $Info ,
            [ Parameter ( Position = 1 , ParameterSetName = "1" ) ]
            [ Parameter ( Position = 1 , ParameterSetName = "2" ) ][ Switch ] $Wrap ,
            [ ValidateSet ( 0 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 , 13 , 14 , 15 ) ] 
            [ Parameter ( Position = 2 , ParameterSetName = "0" ) ]
            [ Parameter ( Position = 2 , ParameterSetName = "1" ) ]
            [ Parameter ( Position = 2 , ParameterSetName = "2" ) ][ Alias ( "F" )][ String ] $ForegroundColor ,
            [ ValidateSet ( 0 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 , 13 , 14 , 15 ) ] 
            [ Parameter ( Position = 3 , ParameterSetName = "0" ) ]
            [ Parameter ( Position = 3 , ParameterSetName = "1" ) ]
            [ Parameter ( Position = 3 , ParameterSetName = "2" ) ][ Alias ( "B" )][ String ] $BackgroundColor )

        Begin 
        {
            $B = @{ 0 = 0..1 ; 1 = 1..0 } ; $Z = "  " , "¯-" , "-_" | % { $_ * 54 } ; $S = " // " , " \\ " ; $F = "/¯¯\" , "\__/"
            $OP = @( ) ; $FR = 0..1 | % { ( $F[( $B[$_] )] ) * 13 -join '' } 
            $D = 0..1 | % { $X , $Y = $B[$_][0..1] ; "$( $S[$X] + $FR[$_] + $F[$X] + $S[$Y] )" }
            $L , $R = $S , $S[1..0] ; $LI = 0..1 | % { $L[$_] + $Z[0] + $R[$_] } 
        }

        Process 
        {   
            If (   $Wrap ) 
            { 
                $OP += "  $( "_" * 112 )  " , $D[0] , $D[1] , " //$( "¯" * 110 )\\ " , $LI[1] 
            }

            If ( $Action ) 
            {   
                $T , $I = $Type , $Info ; $ST , $SI = ( 25 - $T.Length ) , ( 80 - $I.Length ) | % { " " * $_ }
                $Sub = "$( $S[1] )$ST$T : $I$SI$( $S[0] )" ; $AT , $AB = 1..2 | % { $S[0] + $Z[$_] + $S[1] }
                $OP += "" , $AT , $Sub , $AB , "" 
            }

            #     Array Wrapper

            If (  $Array ) 
            { 
                $Array | % { $OP += $_ }
            } 

            # Hashtable Wrapper

            If (  $Table ) 
            {   
                $Index = @( ) ; $Section = @( ) ; $Name = $Null ; $Item = $Null ; $C = $Null

                $ID = $Table | GM | ? { $_.MemberType -eq "NoteProperty" } 

                # [ Title ]
                
                $ID | ? { $_.Name -eq "Class" } | % { $Title = $Table.$( $_.Name ) }

                $Title = $Title.Replace( ' ' , '-' ) | % { "[ $_ ]" } 

                $TT = 108 - $Title.Length ; $TX = $TT % 4 ; $TY = ( $TT - $TX ) / 4
                
                $T = ( $Title | % { "$_" , "$_-" , "$_ " , " $_ -" } )[ $TX ]
                
                $TL , $TR = "_¯" , "¯_" | % { $_ * $TY }
                
                $Title = $S[0] + $TL + $T + $TR + $S[1]

                $OP += $Title , $LI[1]
                
                # [ Sections / Keys ]

                $ID | ? { $_.Name -like      "*ID:*" } | % { $Index   += $Table.$( $_.Name ) }
                $ID | ? { $_.Name -like "*Section:*" } | % { $Section += $Table.$( $_.Name ) }

                $Count = $Index.Count - 1
                
                $Total = 0

                If ( $Count -gt 0 ) { $Count = 0..$Count }

                $Count | % {

                    If ( $Index.Count -gt 1 )
                    {   
                        If   ( $C -ne $Null )                            { $C = $C + 1 }
                        If ( ( $C -eq $Null ) -and ( $Name -eq $Null ) ) { $C =      0 }
                        $Name = $Index[$C] ; $Item = $Section[$C]
                    }

                    If ( $Index.Count -eq 1 ) { $Name = $Index ; $Item = $Section } 

                    $U = 98 - $Name.Length
                    $V = $Total % 2
                    $W = ( 1 - $V ) 
                    
                    $SHeader = "_" , "¯" | % { "$( $L[$V] + ( "$_" * 108 ) + $R[$V] )" }
                    
                    $SLine   = $L[$W] + ( "-" * 10 ) + $Name + ( "-" * $U ) + $R[$W]
                    
                    $OP     += $SHeader[0] , $SLine , $SHeader[1] 
                    
                    $Total   = $Total + 3

                    $BX       = 0

                    ForEach ( $IX in ( 0..( $Item.Count - 1 ) ) )
                    {
                        $Item."Item:$IX" | % { $Key = $_.ID ; $Value = $_.Value }

                        $Y = $Total % 2

                        If (   $Key.Length -gt 20 ) {   $Key = $Key.SubString( 0 , 20 ) + " ... " } 
                        Else                        {   $Key = $Key | % { "$( " " * ( 25 - $_.Length ) )$_" } }
                        If ( $Value.Length -gt 75 ) { $Value = $Value.SubString( 0 , 75 ) + " ... " } 
                        Else                        { $Value = $Value | % { "$_$( " " * ( 80 - $_.Length ) )" } }

                        $OP += "$( $L[$Y] + $Key ) : $( $Value + $R[$Y] )"

                        $Total ++

                        $BX ++ 
                    } 
                } 
            }

            If ( $Wrap ) 
            { 
                If ( ( $OP.Count | Select -Last 1 ) % 2 -ne 0 ) { $OP += $LI[0] } 
                
                $OP += " \\$( "_" * 110 )// " , $D[0] , $D[1] , "  $( "¯" * 112 )  " 
            }
        }

        End 
        {
            If (   $ForegroundColor -ne $Null ) { If ( $BackgroundColor -eq $Null )   { $OP | % { Write-Host -F $FG $_ } } }
            If (   $BackgroundColor -ne $Null ) { If ( $ForegroundColor -eq $Null )   { $OP | % { Write-Host -B $BG $_ } } }
            If ( ( $ForegroundColor -ne $Null ) -and ( $BackgroundColor -ne $Null ) ) { $OP | % { Write-Host -F $FG -B $BG $_ } }
            If ( ( $ForegroundColor -eq $null ) -and ( $BackgroundColor -eq $null ) ) { $OP | % { Write-Host $_ } }
        }
    }
