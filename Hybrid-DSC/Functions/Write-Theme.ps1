    Function Write-Theme # Even your grandmother might say "That's pretty cool."_________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding ( ) ] Param ( 

            [ Parameter ( Mandatory = $True , Position = 0 , ValueFromPipeline = $True , ParameterSetName = "0" ) ][         Switch ]   $Action ,
            [ Parameter ( Mandatory = $True , Position = 0 , ValueFromPipeline = $True , ParameterSetName = "1" ) ][         String ] $Function ,
            [ Parameter ( Mandatory = $True , Position = 0 , ValueFromPipeline = $True , ParameterSetName = "2" ) ][ PSCustomObject ]    $Table ,
            [ Parameter ( Mandatory = $True , Position = 0 , ValueFromPipeline = $True , ParameterSetName = "3" ) ][         Switch ]     $Free ,
            [ Parameter ( Mandatory = $True , Position = 0 , ValueFromPipeline = $True , ParameterSetName = "4" ) ][         Switch ]     $Foot ,
            [ Parameter ( Position = 1 , ValueFromPipeline = $True , ParameterSetName = "0" ) ][ String ]       $Type  ,
            [ Parameter ( Position = 2 , ValueFromPipeline = $True , ParameterSetName = "0" ) ][ String ]       $Info  ,
            [ Parameter ( Position = 3 , ValueFromPipeline = $True , ParameterSetName = "0" ) ]
            [ Parameter ( Position = 1 , ValueFromPipeline = $True , ParameterSetName = "1" ) ]
            [ Parameter ( Position = 1 , ValueFromPipeline = $True , ParameterSetName = "2" ) ]
            [ Parameter ( Position = 1 , ValueFromPipeline = $True , ParameterSetName = "3" ) ]
            [ Parameter ( Position = 1 , ValueFromPipeline = $True , ParameterSetName = "4" ) ][    Int ]   $Edge = 11 ,
            [ Parameter ( Position = 4 , ValueFromPipeline = $True , ParameterSetName = "0" ) ]
            [ Parameter ( Position = 2 , ValueFromPipeline = $True , ParameterSetName = "1" ) ]
            [ Parameter ( Position = 2 , ValueFromPipeline = $True , ParameterSetName = "2" ) ]
            [ Parameter ( Position = 2 , ValueFromPipeline = $True , ParameterSetName = "3" ) ]
            [ Parameter ( Position = 2 , ValueFromPipeline = $True , ParameterSetName = "4" ) ][    Int ] $Center = 12 ,
            [ Parameter ( Position = 5 , ValueFromPipeline = $True , ParameterSetName = "0" ) ]
            [ Parameter ( Position = 3 , ValueFromPipeline = $True , ParameterSetName = "1" ) ]
            [ Parameter ( Position = 3 , ValueFromPipeline = $True , ParameterSetName = "2" ) ]
            [ Parameter ( Position = 3 , ValueFromPipeline = $True , ParameterSetName = "3" ) ]
            [ Parameter ( Position = 3 , ValueFromPipeline = $True , ParameterSetName = "4" ) ][    Int ]   $Font = 15 ,
            [ Parameter ( Position = 6 , ValueFromPipeline = $True , ParameterSetName = "0" ) ]
            [ Parameter ( Position = 4 , ValueFromPipeline = $True , ParameterSetName = "1" ) ]
            [ Parameter ( Position = 4 , ValueFromPipeline = $True , ParameterSetName = "2" ) ]
            [ Parameter ( Position = 4 , ValueFromPipeline = $True , ParameterSetName = "3" ) ]
            [ Parameter ( Position = 4 , ValueFromPipeline = $True , ParameterSetName = "4" ) ][    Int ]   $Back =  0 ,
            [ Parameter ( Position = 5 , ValueFromPipeline = $True , ParameterSetName = "2" ) ][ String ]      $Prompt )

        Begin
        {
            $GX   = $Edge , $Center , $Font , $Back ; $S = " // " , " \\ " ; $F = "/¯¯\" , "\__/" ; $L = $S[1..0] ; $R = $S[0..1]
            $M    = "¯" , "_" , " " , "-" ; 0..3 | % { IEX "`$M$_ = 0..120 | % { '$( $M[$_] )' * `$_ }" } ; 

            $Echo = [ PSCustomObject ]@{ ST = @{ <# Object #> } ; FG = @{ <# Foreground #> } ; BG = @{ <#Background #> } }
        }

        Process
        {
            If ( $Function )
            {
                $FA = $Function   # Subject Variable Concat
                $FL = $FA.Length  # Subject Length

                If ( $FL -le 58 ) { $Y = " ]$( $M1[ 62 - $FL ] )__/" } # Dynamic String Length Buffer

                If ( $FL -gt 58 ) { $FA = "$( $FA[ 0..58 ] -join '' )... " ; $Y = "]__/" } # String Length Max
                
                $Echo | % { # [ Function ] Object Table
                            $_.ST = @{ 0 = "  ____  $( $M2[68] )$( "  ____  " * 5 )"
                                       1 = @( " /" , $F[0] , "\$( $M1[70] )/" ; $F  * 4 ; $F[0] , "\ " )
                                       2 = @( " \" , $F[1] , "/$( $M0[70] )\" ; @( $F[ 1 , 0 ] )  * 4 ; $F[1] , "/ " )
                                       3 = @( "  ¯¯¯\" , "\__[ " , $FA , $Y ; @( $F ) * 4 ; "/¯¯¯  " )
                                       4 = "      $( $M0[72] )$( "    ¯¯¯¯" * 4 )      " }

                            $_.FG = @{ 0 = 0 ; 1 = @( 0 , 1 ) * 6 + 0 ; 2 = @( 0 ; @( 1 ) * 11 ; 0 ) ; 3 = @( 0 , 1 , 2 ; @( 1 , 0 ) * 5 ) ; 4 = 0 }

                            ForEach ( $I in 0..4 ) { If ( $I -in 0 , 4 ) { $_.BG[$I] = 3 } Else { $_.BG[$I] = @( 3 ) * 13 } }
                }
            }

            If ( $Action )
            {
                $T , $I = $Type , $Info # Type/Detailed Subject Concat
                
                $T = $( If ( $T.Length -gt 18 ) { "$( $T[ 0..17 ] -join '' )..." } Else { "$( $M2[ ( 21 - $T.Length ) ] )$T" } ) # [ Type ] Dynamic String Length Buffer / String Length Max
                $I = $( If ( $I.Length -gt 66 ) { "$( $I[ 0..65 ] -join '' )..." } Else { "$I$( $M2[ ( 69 - $I.Length ) ])" } ) # [ Info ] Same ^

                $Echo | % { # [ Action ] Object Table
                            $_.FG = @{ 0 = 0 ; 1 = 0 , 1 , 0 , 1 , 0 ; 2 = 0 , 1 , 1 , 2 , 1 , 1 , 0 ; 3 = 0 , 1 , 0 , 1 , 0 ; 4 = 0 }
                            $_.BG = @{ 0 = 3 ; 1 = @( 3 ) * 5 ; 2 = @( 3 ) * 7 ; 3 = @( 3 ) * 5 ; 4 = 3 }
                            $_.ST = @{ 0 = "  ____    $( $M1[100] )      "
                                       1 = @( " /" ; $F ; "/$( $M0[98])\" , "\___  " )
                                       2 = @( " \" , $F[1] , "/¯¯¯ " , " $T : $I " , "___/" , $F[0] , "\ " )
                                       3 = @( "  ¯¯¯\" , "\$( $M1[98] )/" ; $F[ 0 , 1 ] ; "/ " )
                                       4 = "      $( $M0[100] )    ¯¯¯¯  "  }
                }
            }

            If ( $Free )
            {
                $Flag = @{ # Variable Prep
                
                    D = ( "m" , "d" , "Y" | % { Get-Date -UFormat "%$_" } | % { "$( $_.ToCharArray() )" } ) -join ' / '
                    A = " //¯" , " \\" , " //" , " \\_"
                    E = "[=]" , "\_/" , "| |"
                    B = ( "[=]" , "\_/" )[ 0 , 1 , 0 ] -join ''
                    S = "Beginning the fight against Technological Tyranny and Cyber Criminal Activities" , "Dynamically Engineered Digital Security" , 
                    "Application Development - Virtualization" , "Network & Hardware Magistration" , "What America Once Stood For", 
                    "($( [ Char ]960 )) A Heightened Sense Of Security ($( [ Char ]960 ))" , "HYBRID" , "BY" , "SECURE-DIGITS-PLUS-LLC" , "MICHAEL C COOK SR" 
                }
                
                $STR  = $Flag | % { $_.S[0..5] | % { "[ $_ ]" } ; $_.S[6..9] | % { $_.ToCharArray() -join ' ' } } ; $Sig  = $Flag.D + '  |  ' + $STR[9].Replace( "  " , " " )
                $ST0  = "   \" , "\__/" , "/   " ; $ST1  = "   /" , "/¯¯\" , "\   " ; $STR0 = @( $ST1 ; " \" , "\$( "  *   " * 6 )]" ) ; $STR1 = @( $ST0 ; " /" , "/$( "     *" * 5 )      ]" )

                $Filter = @{ # Uses X Index/Rank to select correct Y reconstitution variable

                     FG = @{ 0 = 0 ; 1 = 2 ; 2 = 5 ; 3 = 4 ; 4 = @( 4 ) * 4 ; 5 = 4 , 4 , 5 , 4 ; 6 = 4 , 4 , 5 , 7 , 5 , 4 ; 7 = 4 , 5 , 4 ; 8 = 4 , 5 , 8 , 5 , 4 ; 9 = 4 , 8 , 4 }
                     BG = @{ 0 = 7 ; 1 = @( 7 ) * 7 ; 2 = 6 , 5 ; 3 = 6 , 4 ; 4 = 6 , 4 , 4 , 4 ; 5 = 4 ; 6 = 4 , 7 , 4 ; 7 = 5 , 7 , 5 ; 8 = @( 7 ) * 9 }
                }

                $Echo   | % { $_.FG = 0..33 ; $_.BG = 0..33 ; $_.ST = 0..33 }

                ForEach ( $I in 0..33 )
                { 
                    $X           = $Filter.FG[ ( @( 0 , 1 , 2 , 3 ; @( 4 , 4 , 5 , 6 ) * 3 ; 4 , 4 , 7 ; @( 8 ) * 11 ; 9 , 2 , 1 , 0 )[ $I ] ) ]
                    $Echo.FG[$I] = $( If ( $I -in 1..32 ) { @( 0 , 1 , 0 ; $X ; 0 , 1 , 0 ) } Else { $X } )

                    $X           = $Filter.BG[ ( @( 0 , 1 , 1 , 1 ; @( 2 , 2 , 3 , 4 ) * 3 ; 2 , 2 , 5 , 6 , 7 , 7 ; @( 6 , 6 , 7 , 7 ) * 2 ; 8 , 1 , 1 , 0 )[ $I ] ) ]
                    $Echo.BG[$I] = $( If ( $I -in 4..29 ) { @( 7 , 7 , 7 , 7 ; $X ; 7 , 7 , 7 , 7 ) } Else { $X } )
                }

                $Echo.ST = @{   0 = "    ____    $( $M1[92] )    ____    "
                                1 = @( "   /" , "/¯¯\" , "\" , "==[$( $M0[92] )]==" , "/" , "/¯¯\" , "\   " )
                                2 = @( $ST0 ; "     $( $STR[0] )    " ; $ST0 ) 
                                3 = @( $ST1 ; "  $( $M1[88] )  " ; $ST1 )
                                4 = @( $ST0 ; " /" , "/¯$( $M0[35] )]" , "[$( $M0[47] )¯\" , "\ " ; $ST0 ) ; 
                                5 = @( $STR0 ; "[$( $M1[47] )_/" , "/ " ; $ST1 )
                                6 = @( $STR1 ; "[$( $M0[47] )¯\" , "\ " ; $ST0 ) ; 
                                7 = @( $STR0 ; "[__" , $STR[1] , "___/" , "/ " ; $ST1 )
                                8 = @( $STR1 ; "[$( $M0[47] )¯\" , "\ " ; $ST0 ) ; 
                                9 = @( $STR0 ; "[$( $M1[47] )_/" , "/ " ; $ST1 )
                               10 = @( $STR1 ; "[$( $M0[47] )¯\" , "\ " ; $ST0 ) ; 
                               11 = @( $STR0 ; "[_" , $STR[2] , "___/" , "/ " ; $ST1 )
                               12 = @( $STR1 ; "[$( $M0[47] )¯\" , "\ " ; $ST0 ) ; 
                               13 = @( $STR0 ; "[$( $M1[47] )_/" , "/ " ; $ST1 )
                               14 = @( $STR1 ; "[$( $M0[47] )¯\" , "\ " ; $ST0 ) ; 
                               15 = @( $STR0 ; "[______" , $STR[3] , "_______/" , "/ " ; $ST1 )
                               16 = @( $ST0  ; " /" , "/  $( $STR[4] )   ]" , "[$( $M0[47] )¯\" , "\ " ; $ST0 )
                               17 = @( $ST1  ; " \" , "\$( $M1[36] )]" , "[$( $M1[47] )_/" , "/ " ; $ST1 )
                               18 = @( $ST0  ; " /" , "/$( $M0[86] )\" , "\ " ; $ST0 )
                               19 = @( $ST1  ; " \" , "\$( $M1[32] )" , "$( $Flag.B )\__/$( $Flag.B )" , "$( $M1[32] )/" , "/ " ; $ST1 )
                               20 = @( $ST0  ; " /" , "/$( $M0[32] )" , "$( $Flag.E[2] )  $( $M1[11] )   $( $Flag.E[2] )" , "$( $M0[32] )\" , "\ " ; $ST0 )
                               21 = @( $ST1  ; " \" , "\$( $M1[32] )" , "$( $Flag.E[0] )_ $( $STR[6] ) __$( $Flag.E[0] )" , "$( $M1[32] )/" , "/ " ; $ST1 )
                               22 = @( $ST0  ; " /" , "/$( $M0[32] )" , "$( $Flag.E[2] + $M0[16] + $Flag.E[2] )" , "$( $M0[32] )\" , "\ " ; $ST0 )
                               23 = @( $ST1  ; " \" , "\_$( $M1[16])" , "$( $Flag.B * 2 )      $( $STR[7] )       $( $Flag.B * 2 )" , "$( $M1[16] )_/" , "/ " ; $ST1 )
                               24 = @( $ST0  ; " /" , "/$( $M0[17] )" , "$( $Flag.E[2] + $M0[15] )      $( $M0[3] )       $( $M0[15] + $Flag.E[2] )" , "$( $M0[17] )\" , "\ " ; $ST0 )
                               25 = @( $ST1  ; " \" , "\$( $M1[17] )" , "$( $Flag.E[0] )  $( $STR[8] ) $( $Flag.E[0] )" , "$( $M1[17] )/" , "/ " ; $ST1 )
                               26 = @( $ST0  ; " /" , "/$( $M0[17] )" , "$( $Flag.E[1] )  $( $M0[43] ) $( $Flag.E[1] )" , "$( $M0[17] )\" , "\ " ; $ST0 )
                               27 = @( $ST1  ; " \" , "\$( $M1[11] )" , "$( $Flag.B * 3 + $Flag.E[0] )\__/$( $Flag.E[0] + $Flag.B * 3 )" , "$( $M1[11] )/" , "/ " ; $ST1 )
                               28 = @( $ST0  ; " /" , "/$( $M0[11] )" , "$( $Flag.E[0] + $M0[58] + $Flag.E[0] )" , "$( $M0[11] )\" , "\ " ; $ST0 )
                               29 = @( $ST1  ; " \" , "\$( $M1[11] )" , "$( $Flag.E[0] )  $SIG  $( $Flag.E[0] )" , "$( $M1[11] )/" , "/ " ; $ST1 )
                               30 = @( $ST0  ; "  $( $M0[12] )" , "¯¯   $( $M0[19] )     $( $M0[30] )   ¯¯" , "$( $M0[12] )  " ; $ST0 )
                               31 = @( $ST1  ; "$( $M2[25] + $STR[5] + $M2[25] )" ; $ST1 ) ; 
                               32 = "   \" , "\__/" , "/" , "==[$( $M1[92] )]==" , "\" , "\__/" , "/   "
                               33 = "    ¯¯¯¯    $( $M0[92] )    ¯¯¯¯    " }
            }

            If ( $Foot )
            {
                $SR = "Secure Digits Plus LLC" , "Hybrid | Desired State Controller" , "Dynamically Engineered Digital Security" , "| Application Development" ,
                "Virtualization" , "Network and Hardware Magistration |" , "https://www.securedigitsplus.com" , "Server-Client" , "Seedling-Spawning Script" ,
                "[ Provisional Author : Michael C Cook Sr. | 'The Buck Stops Here' ]";
                
                $Title , $Strength , $Mark = ( 0..1 ) , ( 3..5 ) , ( 6..8 ) | % { $SR[$_] -join ' | ' }

                $Filter = @{ 
                
                    X = @{  0 = @( 1 , 0 ) * 14 ; 1 = @( @( 0 , 1 ) * 13 ; 0 ) ; 2 = @( 0 ; @( 1 ) * 27 ; 0 ) ; 3 = @( 2 , 1 ; @( 0 , 1 ) *  9 ; 2 ) ; 
                            4 = @( 2 , 1 ; @( 0 ) * 10 ; 1 , 2 ) ; 5 = @( 2 , 1 , 0 , 4 , 0 , 1 , 2 ) ; 6 = @( 2 , 0 , 4 , 0 , 2 ) ; 13 = 2 , 0 , 0 , 0 , 2 ; 14 = @( 2 ; @( 0 ) * 11 ; 2 ) ; 
                           15 = @( 2 ; @( 0 , 1 ) * 9 ; 0 , 2 ) ; 16 = @( 0 , 2 , 1 , 2 ; @( 1 ) * 19 ; 2 , 1 , 2 , 0 ) ; 17 = @( @( 1 , 0 ) * 13 ; 1 ) ; 18 = @( 0 , 1 ) * 13  } ; 
                
                    Y = @( 28 , 27 , 29 , 29 , 22 , 15 , 13 ; @( 11 ) * 6 ; 13 , 21 , 29 , 27 , 27, 26 ) } ; 7..12 | % { $Filter.X[$_] = 0 , 4 , 0 } ; 

                $Echo  | % { $_.ST = 0..18 ; $_.FG = 0..18 ; $_.BG = 0..18 

                ForEach ( $I in 0..18 ) 
                { 
                    $_.FG[$I] = $( If ( $I -in 3, 14, 15 ) { @( 0 , 1 , 2 , 1 ; $Filter.X[$I] ; 1 , 2 , 1 , 0 ) }
                                   If ( $I -in     4..13 ) { @( 0 , 1 , 2 , 2 ; $Filter.X[$I] ; 2 , 2 , 1 , 0 ) }
                                   If ( $I -notin  3..15 ) { $Filter.X[$I] } )

                    $_.BG[$I] = @( 3 ) * $Filter.Y[$I]
                }

                $101 = @( $F[1] ; $F ) ; $010 = @( $F ; $F[0] ) ; $10 = @( $F[1 , 0] )         
                
                    $_.ST = @{   0 = @( "        " ; @( "____" , " -- " ) * 12 ; "____" , "        " )
                                 1 = @( "    ___/" ; @( $F ) * 12 ; $F[ 0 ] , "\___    " )
                                 2 = @( "   /"     ; @( $F ) * 13 ; $F[ 0 ] , "\   " )
                                 3 = @( "   \"     ; $10 * 13 ; $F[ 1 ] , "/   " )
                                 4 = @( "   /"     ; $F  *  2 ; $F[ 0 ] , "\ " ; @( "  ¯¯¯¯  " ) * 8 ; " /" ; $F * 2 ; $F[0] , "\   " )
                                 5 = @( "   \"     ; $10 *  2 ; $F[ 1 ] , "/ " , " [ $Title ] " , " \" , $F[1] ; $F * 2 ; "/   " )
                                 6 = @( "   /"     ; $F * 2  ; "/¯¯¯" , "   ¯¯¯¯\__/$( $M0[47] )\__/¯¯¯   " , "¯¯¯\" ; $10 * 2 ; "\   " )
                                 7 = @( "   \"     ; $101 ; "/¯¯¯" , "         __/¯¯\ ([ $( $SR[2] ) ]) /¯¯\__        " , "¯¯¯\" ; $101 ; "/   " )
                                 8 = @( "   /"     ; $010 ; "\" , "  $( $M1[9] )/¯¯\__/$( $M1[9] ) $( $M1[16] ) $( $M1[20] )\__/¯¯\$( $M1[8] )  " , "/" ; $010 ; "\   " )
                                 9 = @( "   \"     ; $101 ; "/" , " $Strength " , "\" ; $101 ; "/   " )
                                10 = @( "   /"     ; $010 ; "\" , "  $( $M0[25] ) $( $M0[16] ) $( $M0[35] )  " , "/" ; $010 ; "\   " )
                                11 = @( "   \"     ; $101 ; "/" , "   $Mark    " , "\" ; $101 ; "/   " )
                                12 = @( "   /"     ; $010 ; "\___" , "$( $M0[32] )   $( $M0[13] )   $( $M0[24] ) " , "___/" ; $010 ; "\   " )
                                13 = @( "   \"     ; $10  * 2 ; "\ " , "  $( $SR[9] )   " , " /" ; $F * 2 ; "/   " )
                                14 = @( "   /"     ; $F * 2 ; "/ " ; @( "  ____  " ) * 9 ; " \" ; $10 * 2 ; "\   " )
                                15 = @( "   \"     ; $10 * 13 ; $F[1] ,"/   " )
                                16 = @( "    ¯¯¯\" ; $10 * 12 ; $F[1] , "/¯¯¯    " )
                                17 = @( "        " , "¯¯¯\" , $F[1] ; $F * 11 ; "/¯¯¯" , "        " )
                                18 = @( "        " ; @( " -- " , "¯¯¯¯" ) * 12 ; "            " ) }
                }
            }

            If ( $Table )
            {
                $C = $Null ; $Calc = 8 ; $Z = 0

                $List               = [ PSCustomObject ]@{ 
                
                      Class         = @{ Name = $Table | GM | ? { $_.Name -like   "*Class*" } | % { $_.Name } ; Items = @( ) }
                      ID            = @{ Name = $Table | GM | ? { $_.Name -like      "*ID*" } | % { $_.Name } ; Items = @( ) }
                      Section       = @{ Name = $Table | GM | ? { $_.Name -like "*Section*" } | % { $_.Name } ; Items = @( ) } 
                }

                $List.Class.Name    | % { $List.Class.Items   += $Table.$_ }
                $List.ID.Name       | % { $List.ID.Items      += $Table.$_ }
                $List.Section.Name  | % { $List.Section.Items += $Table.$_ }

                $List.Section.Name  | % { $Calc = $Calc + 3 } ; $List.Section.Items.Keys | % { $Calc ++ } ; @( "" , $Calc ++ )[ $Calc % 2 ]
                
                $Echo               | % { $_.ST = 0..$Calc ; $_.FG = 0..$Calc ; $_.BG = 0..$Calc }

                $Title              = $List.Class.Items | % { If ( $_.Length -gt 83 ) { "$( $_.Substring( 0 , 78 ) )..." } Else { $_ } } | % { "[ $_ ]" }

                $Recurse            = $Title | % { 92 - $_.Length | % { $_ ; $_ % 2 ; ( $_ - ( $_ % 2 ) ) / 2 } }

                $Output             = $ObjID | % { $M1[$Recurse[2]] , $M1[$Recurse[1]] , $Title , $M1[$Recurse[2]] -join '' }

                $Echo               | % {

                    $_.ST[$Z] = "  ____    $( $M1[100] )      "                                  ; $_.FG[$Z] = 0                              ; $_.BG[$Z] = 3              ; $Z++
                    $_.ST[$Z] = @( " /" ; $F ; "/$( $M0[98] )\" , "\___  " )                     ; $_.FG[$Z] = @( 0 , 1 , 0 , 1 , 0 )         ; $_.BG[$Z] = 0..4 | % { 3 } ; $Z++
                    $_.ST[$Z] = @( " \" , $F[1] , "/¯¯¯  " , $Output , "  ___/" , $F[0] , "\ " ) ; $_.FG[$Z] = @( 0 , 1 , 1 , 2 , 1 , 1 , 0 ) ; $_.BG[$Z] = 0..6 | % { 3 } ; $Z++
                    $_.ST[$Z] = @( " //¯¯\" , "\$( $M1[98] )/" ; $F ; "/ " )                     ; $_.FG[$Z] = @( 0 , 1 , 0 , 1 , 0 )         ; $_.BG[$Z] = 0..4 | % { 3 } ; $Z++
                    $_.ST[$Z] = " \\   $( $M0[100] )    ¯¯\(  "                                  ; $_.FG[$Z] = 0                              ; $_.BG[$Z] = 3              ; $Z++
                }

                $Count = $( $List.ID.Items.Count - 1 | % { If ( $_ -gt 0 ) { 0..$_ } Else { 0 } } )

                ForEach ( $Y in $Count )
                { 
                    If ( $Count.Length -gt 1 )
                    {
                        $Index      = $List.ID.Items[$Y]
                        $Section    = $List.Section.Items[$Y]
                    }
                        
                    Else
                    {
                        $Index      = $List.ID.Items
                        $Section    = $List.Section.Items
                    }

                    $Index  | % { 
                    
                        If ( $_.Length -gt 93 ) 
                        { 
                            $IDX = "$( $Index[ 0..93 ] -join '' ) ... " 
                        } 
                        
                        Else 
                        { 
                            $IDX = "$Index" 
                        }
                    }
                    
                    $Echo | % { 

                        $_.ST[$Z] = $L[ $Z % 2 ] , $M1[ 108 ] , $R[ $Z % 2 ]                                      ; $_.FG[$Z] = 0 , 0 , 0                ; $_.BG[$Z] = 3 , 3 , 3         ; $Z ++
                        $_.ST[$Z] = $L[ $Z % 2 ] , $M3[  10 ] , $IDX , $M3[ ( 98 - $IDX.Length ) ] , $R[ $Z % 2 ] ; $_.FG[$Z] = 0 , 1 , 2 , 1 , 0        ; $_.BG[$Z] = 3 , 3 , 3 , 3 , 3 ; $Z ++
                        $_.ST[$Z] = $L[ $Z % 2 ] , $M0[ 108 ] , $R[ $Z % 2 ]                                      ; $_.FG[$Z] = 0 , 0 , 0                ; $_.BG[$Z] = 3 , 3 , 3         ; $Z ++
                    }
                        
                    $Keys          = @( $Section.Keys )
                    $Values        = @( $Section.Values )

                    0..( $Keys.Count - 1 ) | % { # Determines distance and overflow handling for all provided names and values
                        
                        $RV = $Values[$_]

                        If ( $RV.ID.Length -gt 20 )    { $ID = "$( $RV.ID[0..20] -join '' ) ... " }      Else { $ID = "$( $M2[ ( 25 - $RV.ID.Length ) ] )$( $RV.ID )" }
                        If ( $RV.Value.Length -gt 70 ) { $VA = "$( $RV.Value[ 0..74 ] -join '' ) ... " } Else { $VA = "$( $RV.Value )$( $M2[ ( 80 - $RV.Value.Length ) ])" }
                        $Echo   | % { $_.ST[$Z] = @( $L[ $Z % 2 ] , $ID , " : " , $VA , $R[ $Z % 2 ] ) ; $_.FG[$Z] = 0 , 2 , 1 , 2 , 0 ; $_.BG[$Z] = 0..4 | % { 3 } ; $Z++ }
                    }
                }

                If ( $Z % 2 -ne 0 ) 
                { 
                    $Echo | % { $_.ST[$Z] = @( " // " , $M2[108] , " \\ " )
                                $_.FG[$Z] = 0 , 0 , 0
                                $_.BG[$Z] = 3 , 3 , 3 }
                                      $Z ++ 
                }

                $Echo | % { $_.ST[$Z] = @( " \\___" ; $M2[72] ; @( "____" , "    " ) * 4 ; "___// " )
                            $_.FG[$Z] = @( 0 ) * 11
                            $_.BG[$Z] = 0..10 | % { 3 }
                                  $Z ++

                            $_.ST[$Z] = @( " /" , $F[0] , "\$( $M1[70] )/" ; $F * 4 ; $F[0] , "\ " )
                            $_.FG[$Z] = @( @( 0 , 1 ) *  6 ; 0 )
                            $_.BG[$Z] = 0..12 | % { 3 }
                                  $Z ++

                            $_.ST[$Z] = @( " \" , $F[1] , "/$( $M0[70] )\" ; @( $F[ 1 , 0 ] ) * 4 ; $F[1] , "/ " )
                            $_.FG[$Z] = @( 0 ; @( 1 ) * 11 ; 0 )
                            $_.BG[$Z] = 0..12 | % { 3 }
                                  $Z++
                }

                If ( ! $Prompt ) 
                { 
                    $Echo.ST[$Z] = @( "  ¯¯¯\" , "\$( $M1[70] )/" ; $F * 4 ; "/¯¯¯  " )
                    $Echo.FG[$Z] = @( 0 ; @( 1 , 0 ) * 6 )
                    $Echo.BG[$Z] = 0..12 | % { 3 }
                }

                If ( $Prompt ) 
                { 
                    $Prompt | % { 
                    
                        If ( $_.Length -gt 63 ) 
                        { 
                            $Echo.ST[$Z] = @( "  ¯¯¯\" , "\__[ " , "$( $_.Substring( 0 , 59 ) )..." , " ]__/" ; $F * 4 ; "/¯¯¯  " )
                            $Echo.FG[$Z] = @( 0 , 1 , 2 ; @( 1 , 0 ) * 6 )
                            $Echo.BG[$Z] = 0..12 | % { 3 }
                        } 
                        
                        Else 
                        { 
                            $Echo.ST[$Z] = @( "  ¯¯¯\" , "\__[ " , " $_ " , "]$( $M1[ ( 61 - $_.Length ) ] )__/" ; $F * 4 ; "/¯¯¯  " )
                            $Echo.FG[$Z] = @( 0 , 1 , 2 ; @( 1 , 0 ) * 6 )
                            $Echo.BG[$Z] = 0..12 | % { 3 }
                             
                        }
                    }
                }

                $Z ++

                $Echo.ST[$Z] = @( "      $( $M0[72] )$( "    ¯¯¯¯" * 4 )      " )
                $Echo.FG[$Z] = 0
                $Echo.BG[$Z] = 3
            }
        }
        End
        {
            $GX = $Edge , $Center , $Font , $Back , 15 , 12 , 9 , 0 , 10

            ForEach ( $I in 0..( $Echo.ST.Count - 1 ) )
            { 
                $ST , $FG , $BG = $Echo | % { $_.ST[$I] , $GX[$_.FG[$I]] , $GX[$_.BG[$I]] }

                If ( $ST.Count -eq 1 ) 
                { 
                    Write-Host $ST -F $FG -B $BG
                }

                Else 
                { 
                    ForEach ( $J in 0..( $ST.Count - 1 ) ) 
                    {
                        $IEX = " -N" , "" | % { "Write-Host `$ST[`$J] -F `$FG[`$J] -B `$BG[`$J]$_" }

                        If ( $J -ne $ST.Count - 1 ) { IEX $IEX[0] } Else { IEX $IEX[1] } 
                    }
                }
            }

            If ( $Prompt )
            {
                Read-Host ( "¯" * 116 )
            }
        }                                                                            #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}