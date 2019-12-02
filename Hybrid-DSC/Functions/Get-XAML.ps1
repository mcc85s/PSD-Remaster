    Function Get-XAML # XAML Glossary and Generation Engine _____________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ][ OutputType ( "String" ) ] Param ( 
        
            [ Parameter ( ParameterSetName =     "Certificate" ) ][ Switch ] $Certificate    ,
            [ Parameter ( ParameterSetName =           "Login" ) ][ Switch ] $Login          ,
            [ Parameter ( ParameterSetName =     "New Account" ) ][ Switch ] $NewAccount     ,
            [ Parameter ( ParameterSetName =  "HybridDSCPromo" ) ][ Switch ] $HybridDSCPromo ,
            [ Parameter ( ParameterSetName =         "DCFound" ) ][ Switch ] $DCFound        ,
            [ Parameter ( ParameterSetName =         "DSCRoot" ) ][ Switch ] $DSCRoot        ,
            [ Parameter ( ParameterSetName =    "ProvisionDSC" ) ][ Switch ] $ProvisionDSC   )

            $XML       = @{ }

            $Schema    = "http://schemas.microsoft.com/winfx/2006/xaml" ; $Author = "Secure Digits Plus LLC"

            $CS        = GCIM Win32_OperatingSystem | % { $_.Caption }
            $B         = $False , $True 
            $YZ        = "[X]" , "[_]"

            $Glossary  = 
            "   `$W = 'Width'             " , "   `$H = 'Height'            " , "  `$MA = 'Margin'          " , 
            "  `$MN = 'Menu'              " , " `$MNI = 'MenuItem'          " , "  `$HD = 'Header'          " , 
            "  `$GB = 'GroupBox'          " , " `$GBI = 'GroupBoxItem'      " , "  `$CB = 'ComboBox'        " , 
            " `$CBI = 'ComboBoxItem'      " , " `$CHK = 'CheckBox'          " , "  `$TB = 'TextBox'         " , 
            " `$TBL = 'TextBlock'         " , "   `$G = 'Grid'              " , "  `$RD = 'RowDefinition'   " , 
            "  `$CD = 'ColumnDefinition'  " , "  `$GC = 'Grid.Column'       " , " `$GCS = 'Grid.ColumnSpan' " , 
            "  `$GR = 'Grid.Row'          " , " `$GRS = 'Grid.RowSpan'      " , "  `$SI = 'SelectedIndex'   " , 
            "  `$LA = 'Label'             " , "  `$BU = 'Button'            " , "  `$CO = 'Content'         " , 
            "   `$Q = 'Name'              " , "  `$SE = 'Setter'            " , "  `$PR = 'Property'        " ,
            "  `$BG = 'Background'        " , "  `$RB = 'RadioButton'       " , "  `$TW = 'TextWrapping'    "
            
            $Glossary   | % { IEX $_ }
            $GRD , $GCD = $RD , $CD | % { "$G.$_`s" }
            $Glossary  += " `$GRD = '$GRD'" , " `$GCD = '$GCD'" 

            $HAL        =  "Left" ,   "Center" ,  "Right" | % { "HorizontalAlignment = '$_'" } ; $HCAL =  $HAL | % { $_.Replace( 'lA' , 'lContentA' ) }
            $VAL        =   "Top" ,   "Center" , "Bottom" | % { "VerticalAlignment = '$_'"   } ; $VCAL =  $VAL | % { $_.Replace( 'lA' , 'lContentA' ) } 

            $SP         = 0..14 | % { "    " * $_ }

            $VC , $VV   = "Collapsed" , "Visible" | % { "Visibility = '$_'" }
            $CF ,  $OK ,  $CA = "Confirm" , "Start" , "Cancel"             
            $PW , $PWB , $PWC = "Password" | % { "$_" , "$_`Box" , "$_`Char" }

            $GFX        = Resolve-HybridDSC -Graphics

            $Z          = 0

        #/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
        If ( $Certificate ) # Certificate/Domain XAML                                [
        {#___________________________________________________________________________/

            $Title      = "Certificate Info"       
                
             # ____   _________________________
             #//¯¯\\__[_______ Header ________] 
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 2 ; @( 13 ) * 7 ; 10 , 9 ) | % { $SP[$_] }

                $Y      = @(  "<Window" , "  xmlns = '$Schema/presentation'" , "xmlns:x = '$Schema'" , "  Title = '$Author | Hybrid @ $Title'" ,  
                              "  $W = '350'" , " $H = '200'" , "Topmost = 'True' " , "   Icon = '$( $GFX.Icon )'" , "$( $HAL[1] )" , 
                              "  WindowStartupLocation = 'CenterScreen' >" )

                $XML[0] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_______ Framing _______]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 3 , 9 , 9 , 9 , 6 , 4 , 5 , 6 , 6 , 5 , 5 , 6 , 7 , 7 , 6 , 6 , 7 , 7 , 6 ) | % { $SP[$_] }

                $Y      = @( "<$GB" , " $HD = 'Company Information / Certificate Generation'" , "  $W = '330'" , " $H = '160'" , "  $( $VAL[0] ) >" , 
                             "<$G>" , "<$GRD>" ; "2" , "" | % { "<$RD $H = '$_*' />" } ; "</$GRD>" , "<$G $GR = '0' >" , "<$GCD>" ; 
                             "" , "2.5" | % { "<$CD $W = '$_*' />" } ; "</$GCD>" , "<$GRD>" ; 0..1 | % { "<$RD $H = '*' />" } ; "</$GRD>" )

                $XML[1] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[      User Input       ]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( @( 6 ) * 4 ) | % { $SP[$_] }

                $Y      = @( ( 0 , "Company" ) , ( 1 , "Domain" ) | % { 

                            "<$TBL $GR = '$( $_[0] )' $GC = '0' $MA = '10' TextAlignment = 'Right' >$( $_[1] ):</$TBL>" ,
                            "<$TB $Q = '$( $_[1] )' $GR = '$( $_[0] )' $GC = '1' $H = '24' $MA = '5' />" } )

                $XML[2] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[        Framing        ]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 5 ; 5..7 ; 7 , 6 ) | % { $SP[$_] }

                $Y      = @( "</$G>" , "<$G $GR = '1' >" , "<$GCD>" ; 0..1 | % { "<$CD $W = '*' />" } ; "</$GCD>" )

                $XML[3] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_______ Controls ______]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 6 , 6 ) | % { $SP[$_] }

                $Y      = @( ( 0 , "Ok" ) , ( 1 , "Cancel" ) | % { "<$BU $Q =  '$( $_[1] )' $CO = '$( $_[1] )' $GC = '$( $_[0] )' $MA = '10' />" } )

                $XML[4] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             #_    ____________________________
             #\\__//¯¯[_______ Header ________]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 5..2 ) | % { $SP[$_] }

                $Y      = @( "</$G>" , "</$G>" , "</$GB>" , "</Window>" )

                $XML[5] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
        }

        #/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
        If ( $Login -or $NewAccount ) # Login / New Account                          [
        {#___________________________________________________________________________/

            If ( $Login )
            { 
                $Title  = "AD Login"
                $Header = "Enter Directory Services Admin Account"
                $VX     = ""
            }
            
            If ( $NewAccount )
            {
                $Title  = "Account Designation"
                $Header = "Enter Username and Password"
                $VX     = $VC
            }

            $X          = @( 2 ; @( 13 ) * 7 ; 10 , 9 ) | % { $SP[$_] }

            $Y          = @( "<Window" , "  xmlns = '$Schema/presentation'" , "xmlns:x = '$Schema'" , 
                             "  Title = '$Author | Hybrid @ $Title'" , "  $W = '480'" , " $H = '280'" , "Topmost = 'True' " , 
                             "   Icon = '$( $GFX.Icon )'" , "$( $HAL[1] )" , "  WindowStartupLocation = 'CenterScreen' >" )

                $XML[0] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_______ Framing _______]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
                $X      = @( 3 , 9 , 9 , 9 , 6 , 4 , 5 , 6 , 6 , 5 , 5 , 6 , 7 , 7 , 6 , 6 , 7 , 7 , 7 , 6 ) | % { $SP[$_] }

                $Y      = @( "<$GB" , " $HD = '$Header'" , "  $W = '450'" , " $H = '240' $MA = '5'" , "  $( $VAL[1] )>" ,
                             "<$G>" , "<$GRD>" ; "2" , "1.25" | % { "<$RD $H = '$_*' />" } ; "</$GRD>" , "<$G $GR = '0' >" ,
                             "<$GCD>" ; "" , "3" | % { "<$CD $W = '$_*' />" } ; "</$GCD>" ; "<$GRD>" ;
                             0..2 | % { "<$RD $H = '*' />" } ; "</$GRD>" )

                $XML[1] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             #_    ____________________________
             #\\__//¯¯[_____ User Input ______]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( @( 6 , 7 ) * 6 ) | % { $SP[$_] }

                $Y      = @( "<$TBL $GC = '0' $GR = '0' $MA = '10' TextAlignment = 'Right' >" , "Username:</$TBL>" ,
                             "<$TB $Q = 'Username' $GC = '1' $GR = '0' $H = '24' $MA = '5' >" , "</$TB>" ,
                             "<$TBL $GC = '0' $GR = '1' $MA = '10' TextAlignment = 'Right' >" , "Password:</$TBL>" ,
                             "<$PWB $Q = 'Password' $GC = '1' $GR = '1' $H = '24' $MA = '5' $PWC = '*' >" , "</$PWB>" ,
                             "<$TBL $GC = '0' $GR = '2' $MA = '10' TextAlignment = 'Right' >" , "Confirm:</$TBL>" ,
                             "<$PWB $Q =  'Confirm' $GC = '1' $GR = '2' $H = '24' $MA = '5' $PWC = '*' >" , "</$PWB>" )

                $XML[2] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_______ Framing _______]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 5 ; 5..7 ; 7 , 6 , 6 , 7 , 7 , 6 ) | % { $SP[$_] }

                $Y      = @( "</$G>" , "<$G $GR = '1' >" , "<$GCD>" ; 0..1 | % { "<$CD $W = '*' />" } ; "</$GCD>" , "<$GRD>" ;
                             0..1 | % { "<$RD $H = '*'/>" } ; "</$GRD>" )

                $XML[3] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             #_    ____________________________
             #\\__//¯¯[_______ Controls ______]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 6 ; @( 6 , 7 ) * 3 ; 6..3 ) | % { $SP[$_] }

                $Y      = @( "<RadioButton $Q = 'Switch' $GR = '0' $GC = '0' $CO = 'Change' $($VAL[1]) $($HAL[1]) $VX/>" ,
                              "<$TB $Q = 'Port' $GR = '0' $GC = '1' $($VAL[1]) $($HAL[1]) $W = '120' IsEnabled = 'False' $VX>" ,
                              "389</TextBox>" , "<$BU $Q = 'Ok' $CO = 'Ok' $GC = '0' $GR = '1' $MA = '5' >" , "</$BU>" ,
                              "<$BU $Q = 'Cancel' $CO = 'Cancel' $GC = '1' $GR = '1' $MA = '5' >" , "</$BU>" , "</$G>" ,
                              "</$G>" , "</$GB>" , "</Window>" )

                $XML[4] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
        }

        #/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
        If ( $HybridDSCPromo ) # Domain Controller Promotion Configuration           [
        {#___________________________________________________________________________/
             
             $Title     = "Desired State Controller Promotion"
             # ____   _________________________
             #//¯¯\\__[_______ Header ________]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 2 ; @( 13 ) * 7 ; 10 , 9 ) | % { $SP[$_] }

                $Y      = @( "<Window" , "  xmlns = '$Schema/presentation'" , "xmlns:x = '$Schema'" , 
                             "  Title = '$Author | Hybrid @ $Title'" , "  $W = '800'" , " $H = '800'" , "Topmost = 'True' " ,
                             "   Icon = '$( $GFX.Icon )'" , "$( $HAL[1] )" , "  WindowStartupLocation = 'CenterScreen' >" )

                $XML[0] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             #_    ____________________________
             #\\__//¯¯[_______ Framing _______]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 2..4 ; 4 , 3 ) | % { $SP[$_] } 

                $Y      = @( "<$G>" , "<$GRD>" ; '20' , '*' | % { "<$RD $H = '$_' />" } ; "</$GRD>" )

                $XML[1] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             #_    ____________________________
             #\\__//¯¯[________ Menu _________]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $Menu   = 'Forest' , 'Tree' , 'Child' , 'Clone'

                $Action = "Domain" | % { "Forest" , "$_ Tree" , "$_ Child" , "$_`Controller" } | % { "Install-ADDS$_" }

                $X      = @( 3..5 ; 5 , 5 ; 5..3 ) | % { $SP[$_] }

                $Y      = @( "<$MN $GR = '0' $H = '20' >" , "<$MNI $HD = 'New' >" ;
                          0..3 | % { "<$MNI $Q = '$($Menu[$_])' $HD = '$($Action[$_])' IsCheckable = 'True' />" } ;
                          "</$MNI>" , "</$MN>" )

                $XML[2] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             #_    ____________________________
             #\\__//¯¯[______ Open Body ______]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = 3 , 12 , 13 , 10 , 10 , 13 , 13 | % { $SP[$_] }

                $Y      = "<$GB" , "   $GR = '1'" , " $HD = '[ Hybrid-DSC Domain Service Configuration ]'" ,
                          "$( $HAL[1] )" , "  $( $VAL[1] )" , "  $W = '760'" , " $H = '740' >"

                $XML[3] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             #_    ____________________________
             #\\__//¯¯[_______ Framing _______]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 4..7 ; 7 , 6 ; 6..8 ; 8 , 7 ) | % { $SP[$_] }

                $Y      = @( "<$G>" , "<$G $GR = '1' $MA = '10' >" , "<$GRD>" ; '' , '10' | % { "<$RD $H = '$_*' />" } ;
                          "</$GRD>" , "<$G $GR = '0' >" , "<$GCD>" ; 0..1 | % { "<$CD $W = '*' />" } ; "</$GCD>" )

                $XML[4] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_____ Domain Mode _____]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $LI     = @( ) ; $ED = @( "00" , "03" ; "08" , 12 | % { $_ , "$_ R2" } ; 16 , 19 )

                $R2     = $( If ( $CS -like "*R2*" ) { 1 } Else { 0 } )

                0..7    | % { $I  = $ED[$_] ; $J  = "False"
                        If ( $CS -like "*$I*" ) { If ( $R2 -eq 1 -and $_ -in    3 , 5 ) { $J = "True" }
                                                  If ( $R2 -eq 0 -and $_ -notin 3 , 5 ) { $J = "True" } }

                $LI    += "<$CBI $CO = 'Windows Server 20$I' IsSelected = '$J' />" }

                $LI[0]  = $LI[0].Replace( "2000" ,"2000 ( Default )" )

                0..1 | % {

                    $J  = ( "ForestMode" , "DomainMode" )[$_]

                    $X  = @( 7 , 8 ; @( 9 ) * 8 ; 8 , 7 ) | % { $SP[$_] }

                    $Y  = @( "<$GB $Q = '$J`Box' $HD = '$J' $GC = '$_' $MA = '5' $VC >" ,
                          "<$CB $Q = '$J' $H = '24' $SI = '0' >" ; @( $LI ) ; "</$CB>" , "</$GB>" )

                    $Z  = 0..11 | % { $X[$_] + $Y[$_] }

                    If ( $_ -eq 0 ) { $ForID = $Z } Else { $DomID = $Z } 
                }

                $ParID  = "ParentDomainName" | % {

                $X  = @( 6 , 7 , 6 ) | % { $SP[$_] } ;

                $Y  = "<$GB $Q = '$_`Box' $HD = '$($_.Replace('D',' D').Replace('N',' N'))' $GC = '0' $MA = '5' $VC >" ,
                      "<$TB $Q = '$_' Text = '&lt;Domain Name&gt;' $H = '20' $MA = '5' />" , "</$GB>"

                Return 0..2 | % { $X[$_] + $Y[$_] } }

                    $XML[5] = @( $ForID ; $DomID ; $ParID )

                    $X  = @( 6 , 6 , 7 , 8 , 8 , 7 , 7 , 8 , 8 , 7 ) | % { $SP[$_] }

                    $Y  = @( "</$G>" , "<$G $GR = '1' >" , "<$GCD>" ; '' , '2.5' | % { "<$CD $W = '$_*' />" } ;"</$GCD>" ,
                             "<$GRD>" ; '3.5' , '' | % { "<$RD $H = '$_*' />" } ; "</$GRD>" )

                    $XML[6] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[__ Services Selection _]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $FT = Get-DSCFeatureList ; $FTL = Get-DSCFeatureList -Underscore

                    $SVC = 0..16 | % { "<$TBL $GC = '0' $GR = '$_' $MA = '5' TextAlignment = 'Right' >$( $FT[$_] ):</$TBL>" ,
                      "<$CHK $GC = '1' $GR = '$_' $MA = '5' $Q = '$( $FTL[$_] )' IsEnabled = 'True' IsChecked = 'False' />" }

                    $X  = @( 6..9 ; 9 , 8 , 8 ; @( 9 ) * 17 ; @( 8 ) * 35 ; 7 , 6 ) | % { $SP[$_] }

                    $Y  = @( "<$GB $HD = 'Service Options' $GR = '0' $GC = '0' $MA = '5' >" , "<$G $GR = '0' $GC = '0' >" ,
                             "<$GCD>" ; '5' , '' | % { "<$CD $W = '$_*' />" } ; "</$GCD>" , "<$GRD>" ;
                             0..16 | % { "<$RD $H =  '*' />" } ; "</$GRD>" ; @( $SVC ) ; "</$G>" , "</$GB>" )

                    $XML[7] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_ Domain Name Options _]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $VA = '10 , 0 , 10 , 0' ; $BB = "BorderBrush = '{x:Null}'"

                    $VX = @( "Database" , "Sysvol" , "Log" | % { "$_`Path" } ; "Credential" ;
                          @( "Domain" | % { $_ , "New$_" } | % { $_ , "$_`NetBIOS" } ; "Site" ) | % { "$_`Name" } ;
                          "ReplicationSourceDC" )

                    $DomID  = ForEach ( $k in 0..9 )
                    {
                        $WX = $VX[$K]

                        If ( $K -eq 3 )
                        {
                            "<$GB $GR = '3' $HD = '$WX' Name = '$WX`Box' $VV $BB >" , "<$G>" , "<$GCD>" ;
                            "" , "3" | % { "<$CD $W = '$_*' />" } ; "</$GCD>" ,
                            "<$BU $CO = '$WX' $Q = '$WX`Button' $GC = '0' />" ,
                            "<$TB $H = '20' $MA = '$VA' Name = '$WX' $GC = '1' />" , "</$G>" , "</$GB>"
                        }

                        Else
                        {
                            "<$GB $GR = '$K' $HD = '$WX`' $Q = '$WX`Box' $VV $BB >" ,
                            "<$TB $H = '20' $MA = '$VA' $Q = '$WX' />" , "</$GB>"
                        }
                    }

                    $X  = @( 6 , 7 ; @( 8 ) * 10 ; 7 ; @( 7 , 8 , 7 ) * 3 ; 7..10 ; 10 , 9 , 9 , 9 , 8 , 7 ; @( 7 , 8 , 7 ) * 6 ; 6 ) | % { $SP[$_] }

                    $Y  = @( "<$G $GR = '0' $GC = '1' $MA = '$VA' >" , "<$GRD>" ; 0..9 | % { "<$RD $H = '*' />" } ;
                             "</$GRD>" ; @( $DomID ) ; "</$G>" )

                    $XML[8] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[__ Role Designations __]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                   $RCN = "Install DNS" , "Create DNS Delegation" , "No Global Catalog" , "Critical Replication Only"
                   $RID = $RCN | % { $_.Replace( " " , "" ) }

                    $Roles = 0..3 | % { "<$TBL $GR = '$_' TextAlignment = 'Right' $MA = '5' IsEnabled = 'True' >$( $RCN[$_] ):</$TBL>" ,
                                        "<$CHK $Q = '$( $RID[$_] )' $GR = '$_' $GC = '1' $MA = '5' IsEnabled = 'True' IsChecked = 'False' />" }

                    $X  = @( 6..9 ; 9 , 9 , 9 , 8 , 8 , 9 , 9 ; @( 8 ) * 9 ; 7 , 6 ) | % { $SP[$_] }

                    $Y  = @( "<$GB $GR = '1' $HD = 'Roles' $MA = '5' >" , "<$G>" , "<$GRD>" ; 0..3 | % { "<$RD $H = '*' />" } ; 
                             "</$GRD>" , "<$GCD>" ; '5' , '' | % { "<$CD $W = '$_*' />" } ; "</$GCD>" ; @( $Roles ) ; "</$G>" , "</$GB>" ) 

                    $XML[9] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_ DSRM/Initialization _]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                    $CF ,  $OK ,  $CA = "Confirm" , "Start" , "Cancel"
                    $PW , $PWB , $PWC = "Password" | % { "SafeModeAdministrator$_" , "$_`Box" , "$_`Char" }

                    $X  = @( 6..9 ; 9 , 8 , 8 , 9 , 9 , 8 , 8 , 9 , 8 , 8 , 9 , 8 , 8 ; 8..6 ) | % { $SP[$_] }

                    $Y  = @( "<$GB $GR = '1' $GC = '1' $HD = 'Initialization' $MA = '5' >" , "<$G>" , "<$GRD>" ;
                          0..1 | % { "<$RD $H = '*' />" } ; "</$GRD>" , "<$GCD>" ; 0..1 | % { "<$CD $W = '*' />" } ;
                          "</$GCD>" )

                    $C  = 0
                    $Y += $PW , $CF | % { "<$GB $GR = '0' $GC = '$C' $HD = '$_' >" , "<$PWB $Q = '$_' $H = '20' $MA = '5' $PWC = '*' />" , "</$GB>"
                        
                        [ Void ]$C ++ 
                    }

                    $C  = 0
                    $Y += $OK , $CA | % { "<$BU $Q = '$_' $GR = '1' $GC = '$C' $CO = '$_' $MA = '5' $W = '100' $H = '20' />"
                        [ Void ]$C ++ 
                    }

                    $Y += "</$G>" , "</$GB>"

                    $XML[10] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             #_    ____________________________
             #\\__//¯¯[_______ Framing _______]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
                    $X  = @( 5..0 ) | % { $SP[$_] }

                    $Y  = "</$G>" , "</$G>" , "</$G>" , "</$GB>" , "</$G>" , "</Window>"

                    $XML[11] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
        }

        #/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
        If ( $DCFound ) # Domain Controller Found                                    [
        {#___________________________________________________________________________/

             # ____   _________________________
             #//¯¯\\__[________ Header _______]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 2 ; @( 13 ) * 4 ; 10 , 13 , 13 , 9 ) | % { $SP[$_] }

                $Y      = "<Window" , "  xmlns = '$Schema/presentation'" , "xmlns:x = '$Schema'" , "  $W = '350'" ,
                          "  $H = '200'" , "$( $HAL[1] )" , "Topmost = 'True' " , "   Icon = '$( $GFX.Icon )'"
                          "  WindowStartupLocation = 'CenterScreen' >"

                $XML[0] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_______ Framing _______]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 4 , 5 , 6 , 6 , 5 , 5 , 6 , 7 , 7 , 6 , 6 , 7 , 7 , 7 , 6 ) | % { $SP[$_] }

                $Y      = @( "<$G>" , "<$GRD>" ; "3" , "" | % { "<$RD $H = '$_*' />" } ; "</$GRD>" , "<$G $GR = '0' >" ,
                          "<$GCD>" ; "" , "2" | % { "<$CD $W = '$_*' />" } ; "</$GCD>" , "<$GRD>" ;
                          0..2 | % { "<$RD $H = '*' />" } ; "</$GRD>" )

                $XML[1] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[      User Input       ]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = 0..2 | % { 6 , 7 , 6 } | % { $SP[$_] }

                $Y      = ( 0 , "Controller" , "DC" ) , ( 1 , "DNS" , "Domain" ) , ( 2 , "NetBIOS" , "NetBIOS" ) | % {
                        "<$TBL $GC = '0' $GR = '$($_[0])' $MA = '10' $($VAL[1]) $($HAL[2]) >" , "$($_[1]) Name:</$TBL>" ,
                        "<$LA $Q = '$($_[2])' $GC = '1' $GR = '$($_[0])' $($VAL[1]) $H = '24' $MA = '10' />" }

                $XML[2] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_______ Framing _______]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 5 , 5 , 6 , 7 , 7 , 6 ) | % { $SP[$_] }

                $Y      = @( "</$G>" , "<$G $GR = '1' >" , "<$GCD>" ; 0..1 | % { "<$CD $W = '*' />" } ; "</$GCD>" )

                $XML[3] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_______ Controls ______]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 6 ; 6..3 ) | % { $SP[$_] }

                $Y      = @( ( 0 , "Ok" ) , ( 1 , "Cancel" ) | % { "<$BU $Q = '$( $_[1] )' $CO = '$( $_[1] )' $GC = '$( $_[0] )' $GR = '1' $MA = '10' />" } ; 
                          "</$G>" , "</$G>" , "</Window>" )

                $XML[4] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] } 
            }
        
        #/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
        If ( $DSCRoot ) # Desired State Controller Root Install                      [
        {#___________________________________________________________________________/

             $Title = "DSC Root Installation"

             # ____   _________________________
             #//¯¯\\__[_______ Header ________]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 2 ; @( 13 ) * 7 ; 10 , 9 ) | % { $SP[$_] }

                $Y      = @( "<Window" , "  xmlns = '$Schema/presentation'" , "xmlns:x = '$Schema'" , "  Title = '$Author | Hybrid @ $Title'" , 
                             "  $W = '640'" , " $H = '450'" , "Topmost = 'True' " , 
                             "   Icon = '$( $GFX.Icon )'" , "$( $HAL[1] )" ,  "  WindowStartupLocation = 'CenterScreen' >" )

                $XML[0] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_______ Framing _______]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 2 , 4 , 5 , 4 , 4 ; @( 5 ) * 5 ; 4 , 4 ; @( 5 ) * 4 ; 4 ) | % { $SP[$_] }

                $Y      = @( "<$G>" , "<$G.Background>" , "<ImageBrush Stretch = 'UniformToFill' ImageSource = '$( $GFX.Background )' />" ,
                          "</$G.Background>" , "<$GRD>" ; 250 , "*" , "*" , 40 , 20 | % { "<$RD $H = '$_' />" } ; "</$GRD>" , "<$GCD>" ;
                          "" , 2 , 2 , "" | % { "<$CD $W = '$_*' />" } ; "</$GCD>" )

                $XML[1] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             #_    ____________________________
             #\\__//¯¯[_______ Framing _______]
             # ¯¯¯¯   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 4 , 4 , 5 , 4 , 4 , 6 , 5 , 4 , 4 , 4 , 3 , 2 ) | % { $SP[$_] }

                $Y      = @( "<Image $GR = '0' $GC`Span = '4' $( $HAL[1] ) $W = '640' $H = '250' Source = '$( $GFX.Banner )' />" ,
                       "<$TBL $GR = '1' $GC = '1' $GC`Span = '2' $( $HAL[1] ) Padding = '5' Foreground = '#00FF00' FontWeight = 'Bold' $( $VAL[1] )>" , 
                       "Hybrid - Desired State Controller - Dependency Installation Path" , "</$TBL>" , 
                       "<$TB $GR = '2' $GC = '1' $GC`Span = '2' $H = '22' TextWrapping = 'Wrap' $MA = '10' $( $HCAL[1] ) $Q = 'Install' >" ,
                       "<$TB.Effect>" , "<DropShadowEffect/>" , "</$TB.Effect>" , "</$TB>" ; 
                    
                       ( 1 , "Start" ) , ( 2 , "Cancel" ) | % { "<$BU $GR = '3' $GC = '$( $_[0] )' $Q = '$( $_[1] )' $CO = '$( $_[1] )' $MA = '10' />" } ; 
                    
                       "</$G>" , "</Window>" )

                $XML[2] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
            }


        #/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\
        If ( $ProvisionDSC ) # Provision Desired State Controller Server             [
        {#___________________________________________________________________________/

            $Title = "DSC Deployment Share"

             # ____   _________________________
             #//¯¯\\__[_______ Header ________]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 2 ; @( 13 ) * 10 ; 12 , 10 , 9 ) | % { $SP[$_] }

                $Y      = @( "<Window" , "  xmlns = '$Schema/presentation'" , "xmlns:x = '$Schema'" , "  Title = '$Author | Hybrid @ $Title'" , 
                             "  $W = '640'" , " $H = '960'" , "Topmost = 'True' " , "   Icon = '$( $GFX.Icon )'" , " ResizeMode = 'NoResize'" , "$( $HAL[1] )" ,  
                             "  WindowStartupLocation = 'CenterScreen' >" )

                $XML[0] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[__ Window Resources ___]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 3..5 ; 5..8 ; 9..3 ) | % { $SP[$_] } 

                $Y      = @( "<Window.Resources>" , "<Style TargetType = 'Label' x:Key = 'RoundedBox' >" , "<$SE $PR = 'TextBlock.TextAlignment' Value = 'Center' />" , 
                             "<$SE $PR = 'Template' >" , "<$SE.Value>" , "<ControlTemplate TargetType = 'Label' >" , 
                             "<Border CornerRadius = '12' $BG = 'Blue' BorderBrush = 'Black' BorderThickness = '3' >" , 
                             "<ContentPresenter x:Name = 'contentPresenter' ContentTemplate = '{ TemplateBinding ContentTemplate }' $MA = '5' />" ,
                             "</Border>" , "</ControlTemplate>" , "</$SE.Value>" , "</$SE>" , "</Style>" , "</Window.Resources>" )
                
                $XML[1] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_____ Background ______]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 3 , 4 , 5 , 5 , 5 , 4 , 4 , 5 , 4 , 4 , 5 ) | % { $SP[$_] } 
            
                $Y      = @( "<$G>" , "<$GRD>" ; 250 , '*' , 50 | % { "<$RD $H = '$_' />" } ; "</$GRD>" , "<$G.$BG>" , 
                             "<ImageBrush Stretch = 'UniformToFill' ImageSource = '$( $GFX.Background )' />" , "</$G.$BG>" , 
                             "<Image $GR = '0' Source = '$( $GFX.Banner )'/>" , 
                             "<TabControl $GR = '1' $BG = '{x:Null}' BorderBrush = '{x:Null}' Foreground = '{x:Null}' $( $HAL[1] )>" )

                $XML[2] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_______ Staging _______]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 5..7 ; 6 , 6 , 7 ; @( 8 ) * 6 ; 7 , 7 , 8 , 7 , 7 , 8 , 9 , 9 , 8 , 8 ; @( 9 ) * 5 ; 8 ; @( 8 , 9 , 9 , 10 , 9 , 8 , 8 ) * 5 ; 
                             7 , 7 , 8 , 9 , 9 , 8 ; @( 8 , 9 , 10 , 9 , 8 ) * 2 ; 7 ; 7 , 8 , 7 ) | % { $SP[$_] }

                $Y      = @( "<TabItem $HD = 'Stage Deployment Server' BorderBrush = '{x:Null}' $W = '280' >" , "<TabItem.Effect>" , "<DropShadowEffect/>" , 
                             "</TabItem.Effect>" , "<$G>" , "<$GRD>" ; 5 , 3 | % { 50 , "$_*" , "*" } | % { "<RowDefinition Height = '$_' />" } ; "</$GRD>" , 
                             "<$LA Style = '{ StaticResource RoundedBox }' $GR = '0' $( $VAL[1] ) $( $HAL[1] ) Foreground = '#FFFFFF' FontSize = '14' >" , 
                             "MDT Base Share Settings" , "</$LA>" , "<$G $GR = '1' >" , "<$GCD>" ; 2 , 3 | % { "<$CD $W = '$_*' />" } ; "</$GCD>" , "<$GRD>" ; 
                             0..4 | % { "<$RD $H = '*' />" } ; "</$GRD>" ; 

                            ( 0 , "Drive Label" ,   "Drive" ) , ( 1 ,    "Directory Path" ,   "Directory" ) , ( 2 , "Samba Share" , "Samba" ) , 
                            ( 3 ,    "PS Drive" , "DSDrive" ) , ( 4 , "Drive Description" , "Description" ) | % {
                                
                                "<$TBL $GR = '$( $_[0] )' $GC = '0' $( $VAL[1] ) $( $HAL[1] ) Foreground = '#00FF00' >" , "$( $_[1] )" , "<$TBL.Effect>" , 
                                "<DropShadowEffect   ShadowDepth = '1'  Color = '#336633' />" , "</$TBL.Effect>" , "</$TBL>" , 
                                "<$TB $GR = '$( $_[0] )' $GC = '1' $H = '24' $MA = '20,0,20,0' $Q = '$( $_[2] )' />" } ; 

                            "</$G>" , "<$G $GR = '2' >" , "<$GCD>" ; 0..1 | % { "<$CD $W = '*' />" } ; "</$GCD>" ;

                            ( 0 , "Legacy MDT" , "Legacy" ) , ( 1 , "PSD-Remaster" , "Remaster" ) | % { 
                    
                                "<$RB $GC = '$( $_[0] )' $MA =  '5' $( $VAL[1] ) $( $HAL[1] ) Foreground = '#00FF00' $CO = '$( $_[1] )' $Q = '$( $_[2] )' >" , 
                                "<$RB.Effect>" , "<DropShadowEffect ShadowDepth = '1' Color = '#336633' />" , "</$RB.Effect>" , "</$RB>" } ;
                            
                            "</$G>" , "<$LA Style = '{ StaticResource RoundedBox }' $GR = '3' $( $VAL[1] ) $( $HAL[1] ) Foreground = '#FFFFFF' FontSize = '14' >" , 
                            "BITS / IIS Configuration" , "</$LA>" )

                $XML[3] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[__ BITS / IIS Setup ___]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 7 , 8 , 9 , 9 , 8 , 8 , 9 , 9 , 9 , 8 ; @( 8 , 9 , 9 , 10 , 9 , 8 , 8 ) * 3 ; 7 , 7 , 8 , 9  , 9 , 8 ; @( 8 , 9 , 10 , 9 , 8 ) * 2 ; 
                             7 , 6 , 5 ) | % { $SP[$_] }

                $Y      = @( "<$G $GR = '4' >" , "<$GCD>" ; 2 , 3 | % { "<$CD $W = '$_*' />" } ; "</$GCD>" , "<$GRD>" ; 0..2 | % { "<$RD $H = '*' />" } ; "</$GRD>" ;

                            ( 0 , "BITS / IIS Name" , "IIS_Name" ) , ( 1 , "IIS App Pool" , "IIS_AppPool" ) , ( 2 , "Virtual Host / Proxy" , "IIS_Proxy" ) | % {
                           
                                "<$TBL $GR = '$( $_[0] )' $GC = '0' $MA =  '5' $( $VAL[1] ) $( $HAL[1] ) Foreground = '#00FF00' >" , "$( $_[1] )" , "<$TBL.Effect>" , 
                                "<DropShadowEffect ShadowDepth = '1' Color = '#336633' />" , "</$TBL.Effect>" , "</$TBL>" , 
                                "<$TB $GR = '$( $_[0] )' $GC = '1' $H = '24' $MA = '20,0,20,0' $Q = '$( $_[2] )' />" } ;
                            
                            "</$G>" , "<$G $GR = '5' >" , "<$GCD>" ; 0..1 | % { "<$CD $W = '*' />" } ; "</$GCD>" ;

                            ( 0 , "IIS_Install" , "Install / Configure IIS" ) , ( 1 , "IIS_Skip" , "Skip IIS Setup" ) | % { 

                                "<$RB $GC = '$( $_[0] )' $MA = '5' $( $VAL[1] ) $( $HAL[1] ) Foreground = '#00FF00' $Q = '$( $_[1] )' Content = '$( $_[2] )' >" , 
                                "<$RB.Effect>" , "<DropShadowEffect   ShadowDepth = '1'  Color = '#336633' />" , "</$RB.Effect>" , "</$RB>" } ;

                            "</$G>" , "</$G>" , "</TabItem>" )

                $XML[4] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[____ Company Info _____]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 5 , 6 , 7 , 6 , 6 , 7 ; @( 8 ) * 6 ; 7 , 7 , 8 , 7 , 7 , 8 , 9 , 9 , 8 , 8 ; @( 9 ) * 4 ; 8 ; @( 8 , 9 , 9 , 10 , 9 , 8 , 8 ) * 4 ; 
                             7 , 7 , 8 , 7 ) | % { $SP[$_] }
                
                $Y      = @( "<TabItem $HD = 'Image Info' $( $HAL[1] ) $W = '280' BorderBrush = '{x:Null}' >" , "<TabItem.Effect>" , "<DropShadowEffect/>" , 
                             "</TabItem.Effect>" , "<$G>" , "<$GRD>" ; 4 , 2 , 4 | % { 50 , "$_*" } | % { "<$RD $H = '$_' />" } ; "</$GRD>" ; 
                             "<$LA Style = '{ StaticResource RoundedBox }' $GR = '0' $( $VAL[1] ) $( $HAL[1] ) Foreground = '#FFFFFF' FontSize = '14' >" , 
                             "Company Information" , "</$LA>" , "<$G $GR = '1' >" , "<$GCD>" ; 2 , 3 | % { "<$CD $W = '$_*' />" } ; "</$GCD>" , "<$GRD>" ; 
                             0..3 | % { "<$RD $H = '*' />" } ; "</$GRD>" ;
                            
                            ( 0 , "Company Name" , "Company" ) , ( 1 , "Support Website" , "WWW" ) , ( 2 , "Support Phone" , "Phone" ) , 
                            ( 3 , "Support Hours" , "Hours" ) | % {

                                "<$TBL $GR = '$( $_[0] )' $GC = '0' $MA = '5' $( $VAL[1] ) $( $HAL[1] ) Foreground = '#00FF00' >" , "$( $_[1] )" , "<$TBL.Effect>" , 
                                "<DropShadowEffect ShadowDepth = '1' Color = '#336633' />" , "</$TBL.Effect>" , "</$TBL>" ; 
                                "<$TB $GR = '$( $_[0] )' $GC = '1' $H = '24' $MA = '20,0,20,0' $Q = '$( $_[2] )' $TW = 'WrapWithOverflow' />" }
    
                            "</$G>" , "<$LA Style = '{ StaticResource RoundedBox }' $GR = '2' $( $VAL[1] ) $( $HAL[1] ) Foreground = '#FFFFFF' FontSize = '14' >" , 
                            "Custom Graphics" , "</$LA>" )

                $XML[5] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[___ Custom Graphics ___]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 7 , 8 , 9 , 9 , 8 , 8 , 9 , 9 , 8 ; @( 8 , 9 , 9 , 10 , 9 , 8 , 8 ) * 2 ; 7 , 7 , 8 , 7 ) | % { $SP[$_] }

                $Y      = @( "<$G $GR = '3' >" , "<$GCD>" ; 2 , 3 | % { "<$CD $W = '$_*' />" } ; "</$GCD>" , "<$GRD>" ; 0..1 | % { "<$RD $H = '*' />" } ; "</$GRD>" ;

                            ( 0 , "Logo [120x120] BMP" , "Logo" ) , ( 1 , "Background" , "Background" ) | % {
                                
                                "<$TBL $GR = '$( $_[0] )' $GC = '0' $MA = '5' $( $VAL[1] ) $( $HAL[1] ) Foreground = '#00FF00' >" , "$( $_[1] )" , "<$TBL.Effect>" , 
                                "<DropShadowEffect ShadowDepth = '1' Color = '#336633' />" , "</$TBL.Effect>" , "</$TBL>" , 
                                "<$TB $GR = '$( $_[0] )' $GC = '1' $H = '24' $MA = '20,0,20,0' $Q = '$( $_[2] )' $TW = 'WrapWithOverflow' />" } ; 
                            
                            "</$G>" , "<$LA Style = '{ StaticResource RoundedBox }' $GR = '4' $( $VAL[1] ) $( $HAL[1] ) Foreground = '#FFFFFF' FontSize = '14' >" , 
                            "Network &amp; Target Credentials" , "</$LA>" )

                $XML[6] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_ Network Credentials _]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 7 , 8 , 9 , 9 , 8 , 8 ; @( 9 ) * 4 ; 8 ; @( 8,9,9,10,9,8,8 ) * 4 ; 7..4 ) | % { $SP[$_] }

                $Y      = @( "<$G $GR = '5' >" , "<$GCD>" ; 2 , 3 | % { "<$CD $W = '$_*' />" } ; "</$GCD>" ; "<$GRD>" ; 0..3 | % { "<$RD $H = '*' />" } ; "</$GRD>" ;

                            ( 0 , "Branch Name" , "Branch" ) , ( 1 , "NetBIOS Domain" , "NetBIOS" ) , ( 2 , "Administrator Account" , "LMCred_User" ) , 
                            ( 3 , "Administrator Password" , "LMCred_Pass" ) | % { 

                                If ( $_ -eq 3 ) { $TBX = $PWB ; $QX = "$PWC = '*'" } Else { $TBX = $TB ; $QX = "" }

                                "<$TBL $GR = '$( $_[0] )' $GC = '0' Margin =  '5' VerticalAlignment = 'Center' HorizontalAlignment = 'Center' Foreground = '#00FF00' >" , 
                                "$( $_[1] )" , "<$TBL.Effect>" , "<DropShadowEffect ShadowDepth = '1' Color = '#336633' />" , "</$TBL.Effect>" , "</$TBL>" , 
                                "<$TBX $GR = '$( $_[0] )' $GC = '1' $H = '24' $MA = '20,0,20,0' $Q = '$( $_[2] )' $QX />" } ; 
                            
                            "</$G>" , "</$G>" , "</TabItem>" , "</TabControl>" )

                $XML[7] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
             # ____   _________________________
             #//¯¯\\__[_______ Framing _______]
             #¯    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
                $X      = @( 4 , 5 ; @( 6 ) * 4 ; 5 , 5 ; 5..2 ) | % { $SP[$_] }

                $Y      = @( "<$G $GR = '2' >" , "<$GCD>" ; "" , 2 , 2 , "" | % { "<$CD $W = '*' />" } ; "</$GCD>" ; 
                
                            ( 1 , "Start" ) , ( 2 , "Cancel" ) | % { 
                            
                                "<$BU $GC = '$( $_[0] )' $Q = '$( $_[1] )' $CO = '$( $_[1] )' $MA = '10' />" } ; 
                                
                            "</$G>" , "</$G>" , "</Window>" )

                $XML[8] = 0..( $X.Count - 1 ) | % { $X[$_] + $Y[$_] }
        }
        
        $Item   = ForEach ( $i in 0..( $XML.Count - 1 ) ) { 0..( $XML[$I].Count - 1 ) | % { $XML[$I][$_] } } 
        $Return = ""

        0..( $Item.Count - 1 ) | % { $Return += "$( $Item[$_] )`n" } ; 

        $X = $( $Certificate    | ? { $_ } | % {                         "Certificate Panel" }
                $Login          | ? { $_ } | % {                               "Login Panel" }
                $NewAccount     | ? { $_ } | % {                         "New Account Panel" }
                $HybridDSCPromo | ? { $_ } | % {                    "Hybrid-DSC Promo Panel" }
                $DSCRoot        | ? { $_ } | % {     "Desired State Controller Root Install" }
                $ProvisionDSC   | ? { $_ } | % { "Provision Desired State Controller Server" } )

        Write-Theme -Action "Loaded [+]" "$X"
        
        Return $Return                                                           
                                                                                     #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}