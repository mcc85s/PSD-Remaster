

# ____                                                                            ____________________________________________________________________
#//¯¯\\__________________________________________________________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\
#\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//
    Function New-SubTable # Converts array of keys and values into an Object      ¯¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\
    {                       # ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        [ CmdLetBinding ( ) ] Param (

            [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True , HelpMessage = "Section Items"     ) ][ String [] ]  $Items ,
            [ Parameter ( Position = 1 , Mandatory = $True , ValueFromPipeline = $True , HelpMessage = "Section Values"    ) ][ String [] ] $Values )

        $Table = [ PSCustomObject ]@{ } # Declares an empty table

        If ( $Items.Count -eq $Values.Count ) # Prepares the key/value pairs
        {
            If ( $Items.Count -gt 1 ) { $Count = 0..( $Items.Count - 1 ) }
            $Count | % { $Table | Add-Member -MemberType NoteProperty -Name "Item:$_" -Value @{ ID = "$( $Items[$_] )" ; Value = "$( $Values[$_] )" } }
        }

        If ( $Items.Count -ne $Values.Count ) { Throw '$Items -ne $Values' } # Error handling

        Return $Table # Outputs the object
    }

# ____                                                                            ____________________________________________________________________
#//¯¯\\__________________________________________________________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\
#\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//
    Function New-Table # Converts array of objects into a single object           ¯¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\
    {                       # ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        [ CmdLetBinding ( ) ] Param (

            [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True , HelpMessage = "Name or Header"   ) ][         String    ] $Title ,
            [ Parameter ( Position = 1 , Mandatory = $True , ValueFromPipeline = $True , HelpMessage = "Section Quantity" ) ][            Int    ] $Depth ,
            [ Parameter ( Position = 2 , Mandatory = $True , ValueFromPipeline = $True , HelpMessage = "Section Names"    ) ][         String [] ] $ID    ,
            [ Parameter ( Position = 3 , Mandatory = $True , ValueFromPipeline = $True , HelpMessage = "Subtables"        ) ][ PSCustomObject [] ] $Table )

        $Object = [ PSCustomObject ]@{ Class = $Title } # Declares table title and Sync Root

        If ( ( $ID.Count -ne $Depth ) -or ( $Table.Count -ne $Depth ) ) { Throw '$Depth -ne $ID.Count or $Table.Count' } # Error handling
        If ( $Depth -eq 1 ) { $Count = 1 } Else { $Count = 0..( $Depth - 1 ) } # Determines a single or multiple 'count vector'

        $C = $Null # Ensures that the index count starts at 0

        $Count | % { # Begins the loop
    
            If ( $Depth -gt 1 ) # If multiple objects, selects the count, and continues
            { 
                If ( $C -ne $Null ) { $C = $C + 1 } 
                If ( $C -eq $Null ) { $C = 0 }
                  $Index = $ID[$C]
                $Section = $Table[$C] 
            }

            If ( $Depth -eq 1 ) # If a single object, then runs through the loop once
            { 
                      $C = 0
                  $Index = $ID
                $Section = $Table }

            # Indiscriminately uses the same logic whether using single or multiple objects

            $Object | Add-Member -MemberType NoteProperty -Name "ID:$C" -Value $Index
            $Keys = @( $Section | GM | ? { $_.MemberType -eq "NoteProperty" } | % { $_.Name } )

            ForEach ( $S in $Keys ) # Prepares the subtable key/value pairs output a PSCustomObject
            {
                $SubTable = [ Ordered ]@{ } # Declares empty table 

                ForEach ( $K in $Keys ) # Adds all section Key ID/Value pairs to temporary hashtable
                {
                    $Section.$K | % { $SubTable.Add( "$K" , @{ ID = $_.ID ; Value = $_.Value } ) }
                }
            } # Once complete, sends the temporary hashtable out to the object's section

            $Object | Add-Member -MemberType NoteProperty -Name "Section:$C" -Value $SubTable 
        }

        Return $Object
    }
    
# ____                                                                            ____________________________________________________________________
#//¯¯\\__________________________________________________________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\
#\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//
    Function Write-Echo # Modifies Write-Output to stylize strings/arrays/tables  ¯¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\
    {                   # ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        [ CmdLetBinding ( ) ] Param (
            [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True , ParameterSetName = "0" ) ][ Switch ]        $Action ,
            [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True , ParameterSetName = "1" ) ][ Array  ]         $Array ,
            [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True , ParameterSetName = "2" ) ][ PSCustomObject ] $Table ,
            [ Parameter ( Position = 1 , Mandatory = $True , ParameterSetName = "0" ) ][ String ] $Type ,
            [ Parameter ( Position = 2 , Mandatory = $True , ParameterSetName = "0" ) ][ String ] $Info ,
            [ Parameter ( Position = 1 , ParameterSetName = "1" ) ]
            [ Parameter ( Position = 1 , ParameterSetName = "2" ) ][ Switch ] $Wrap ,
            [ ValidateSet ( 0 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 , 13 , 14 , 15 ) ] 
            [ Parameter ( Position = 2 , ParameterSetName = "2" ) ][ Alias ( "F" )][ String ] $ForegroundColor ,
            [ ValidateSet ( 0 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 , 13 , 14 , 15 ) ] 
            [ Parameter ( Position = 3 , ParameterSetName = "2" ) ][ Alias ( "B" )][ String ] $BackgroundColor )

        Begin # Declares 'textures' used for each commandlet ( lots of math/switching here )
        {
            $B = @{ 0 = 0..1 ; 1 = 1..0 } ; $Z = "  " , "¯-" , "-_" | % { $_ * 54 } ; $S = " // " , " \\ " ; 
            $F = "/¯¯\" , "\__/" ; $OP = @( ) ; $FR = 0..1 | % { ( $F[( $B[$_] )] ) * 13 -join '' } 
            $D = 0..1 | % { $X , $Y = $B[$_][0..1] ; "$( $S[$X] + $FR[$_] + $F[$X] + $S[$Y] )" }
            $L , $R = $S , $S[1..0] ; $LI = 0..1 | % { $L[$_] + $Z[0] + $R[$_] } 
        }

        Process # Processes each commandlet into an array for output
        {   
            If (   $Wrap ) { $OP += "  $( "_" * 112 )  " , $D[0] , $D[1] , " //$( "¯" * 110 )\\ " , $LI[1] }  #       Top Wrapper

            If ( $Action )                                                                                    #    Action Wrapper
            {   
                $T , $I = $Type , $Info ; $ST , $SI = ( 25 - $T.Length ) , ( 80 - $I.Length ) | % { " " * $_ }
                $Sub = "$( $S[1] )$ST$T : $I$SI$( $S[0] )" ; $AT , $AB = 1..2 | % { $S[0] + $Z[$_] + $S[1] }
                $OP += "" , $AT , $Sub , $AB , "" 
            }

            If (  $Array ) { $Array | % { $OP += $_ } }                                                       #     Array Wrapper

            If (  $Table )                                                                                    # Hashtable Wrapper
            {   
                $Index = @( ) ; $Section = @( ) ; $Name = $Null ; $Item = $Null ; $C = $Null
                $ID = $Table | GM | ? { $_.MemberType -eq "NoteProperty" } 

                $ID | ? { $_.Name -eq "Class" } | % { $Title = $Table.$( $_.Name ) }                          #     Title Wrapper
                $Title = $Title.Replace( ' ' , '-' ) | % { "[ $_ ]" }
                If ( $Title.Length -gt 103 ) { $Title = "$( $Title.Substring( 0 , 103 ) ) ... " }

                $TT = 108 - $Title.Length ; 
                $TX = $TT % 4 ; $TY = ( $TT - $TX ) / 4 ; $TL , $TR = "_¯" , "¯_" | % { $_ * $TY } 
                $T = ( $Title | % { "$_" , "$_-" , "$_ " , " $_ -" } )[ $TX ]
                $Title = $S[0] + $TL + $T + $TR + $S[1] ; $OP += $Title , $LI[1]                              #    Title -> Array
                
                $ID | ? { $_.Name -like      "*ID:*" } | % { $Index   += $Table.$( $_.Name ) }                #       ID Selector
                $ID | ? { $_.Name -like "*Section:*" } | % { $Section += $Table.$( $_.Name ) }                #  Section Selector

                $Count = $Index.Count - 1 ; $Total = 0 # Starts the count ( Critical for character orientation )

                If ( $Count -gt 0 ) { $Count = 0..$Count }

                $Count | % {

                    If ( $Index.Count -gt 1 )                                                                 #       If Multiple
                    {   
                        If   ( $C -ne $Null ) { $C = $C + 1 } # Starts the index
                        If ( ( $C -eq $Null ) -and ( $Name -eq $Null ) ) { $C =      0 }
                        $Name = $Index[$C] ; $Item = $Section[$C]
                    }

                    If ( $Index.Count -eq 1 ) { $Name = $Index ; $Item = $Section }                           #         If Single

                    If ( $Name.Length -gt 93 ) { $Name = "$( $Name.Substring( 0 , 93 ) ) ... " }

                    $U = 98 - $Name.Length ; $V = $Total % 2 ; $W = ( 1 - $V )
                    $SHeader = "_" , "¯" | % { "$( $L[$V] + ( "$_" * 108 ) + $R[$V] )" }
                    $SLine = $L[$W] + ( "-" * 10 ) + $Name + ( "-" * $U ) + $R[$W]
                    $OP += $SHeader[0] , $SLine , $SHeader[1] ; 
                    
                    $Total = $Total + 3 ; $BX = 0

                    ForEach ( $IX in ( 0..( $Item.Count - 1 ) ) )
                    {
                        $Item."Item:$IX" | % { $Key = $_.ID ; $Value = $_.Value } ; $Y = $Total % 2
                        If (   $Key.Length -gt 20 ) {   $Key = $Key.SubString( 0 , 20 ) + " ... " } 
                        Else                        {   $Key = $Key | % { "$( " " * ( 25 - $_.Length ) )$_" } }
                        If ( $Value.Length -gt 75 ) { $Value = $Value.SubString( 0 , 75 ) + " ... " } 
                        Else                        { $Value = $Value | % { "$_$( " " * ( 80 - $_.Length ) )" } }

                        $OP += "$( $L[$Y] + $Key ) : $( $Value + $R[$Y] )" ; $Total ++ ; $BX ++ 
                    }
                }
            }

            If ( $Wrap ) 
            { 
                If ( ( $OP.Count | Select -Last 1 ) % 2 -ne 0 ) { $OP += $LI[0] } 
                $OP += " \\$( "_" * 110 )// " , $D[0] , $D[1] , "  $( "¯" * 112 )  " 
            }
        }

        End { $OP | % { Write-Host $_ } }
    }


    # Testing the functions [ Template ]

    $Author = "Secure Digits Plus LLC" # A common denominator
    $Title  = "Provisional Root" # Title of the output object

    $Names  = "Desired State Controller @ Source" , "Current Machine @ Variables" , "Provision Index @ Bridge Control" | % { "( $_ )" } # Max of ~ 100 Characters here

    $Items  = [ Ordered ]@{ # Output Table shows a max of ~ 20 characters before it trails off, so stay within 20 characters
        0 = "Provisionary" ,      "(DSC) Share" ,      "(DSC) Share" ,    "Resources" , "Tools / Drivers" ,       "Images" ,     "Profiles" ,     "Certificates" ,     "Applications"
        1 =   "(DSC) Host" , "Current Hostname" , "CPU Architecture" , "System Drive" ,    "Windows Root" ,     "System32" , "Program Data"
        2 = "(DSC) Target" ,        "Resources" ,  "Tools / Drivers" ,       "Images" ,        "Profiles" , "Certificates" , "Applications" }

    $Values = [ Ordered ]@{ # Output Table shows a max of ~ 75 characters before it trails off, so stay within 75 characters
        0 = @( "$Author" , "\\DSC0\Secured$" , "DSC0" ; @( "(0)Resources" , "(1)Tools" , "(2)Images" , "(3)Profiles" , "(4)Certificates" , "(5)Applications" | % { "C:\Secured\$Author\$_" } ) )
        1 = "Yes" ,  "DSC0" , "AMD64" , "C:\" , "C:\Windows" , "C:\Windows\System32" , "C:\ProgramData"
        2 = @( "DSC0" ; @( "(0)Resources" , "(1)Tools" , "(2)Images" , "(3)Profiles" , "(4)Certificates" , "(5)Applications" | % { "C:\$Author\$_" } ) ) }

    $ID     = @( )  
    $Table  = @( )
    
    0..2 | % { $ID += $Names[$_] ; $Table += New-SubTable -Items $Items[$_] -Values $Values[$_] }

    $OBJ  = @( New-Table -Title $Title -Depth 3 -ID $ID -Table $Table )

    Write-Echo -Table $Obj -Wrap -F 10 -B 0
    Sleep -S 3

    Write-Echo -Table $Obj -Wrap -F 11 -B 0
    Sleep -S 3

    Write-Echo -Table $Obj -Wrap -F 12 -B 0
