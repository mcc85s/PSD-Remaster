    Function Get-DSCPromoSelection # ____________________________________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ] Param ( [ ValidateSet ( 0 , 1 , 2 , 3 ) ]
        
            [ Parameter (                                                 Position = 0 ) ][            Int ] $Type = 0 ,
            [ Parameter ( Mandatory = $True , ValueFromPipeline = $True , Position = 1 ) ][ Windows.Window ] $GUI      )

            $P                            = $Type
            $B                            = $False , $True
            $Return                       = @( )
            $Code                         = Get-DSCPromoControl
        # ______________________________________________________________________________ #
        # Command
        # ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ #
            $Code.Command                 = ( Get-DSCPromoTable    -Command )[$P]
        # ______________________________________________________________________________ #
        # Process
        # ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ #
            $Code.Process                 = ( Get-DSCPromoTable    -Process )[$P]
        # ______________________________________________________________________________ #
        # Menu
        # ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ #
            $Names                        =   Get-DSCPromoTable       -Menu
            $Switch                       = @{ 0 = 1,0,0,0 ; 1 = 0,1,0,0 ; 2 = 0,0,1,0 ; 3 = 0,0,0,1 }

            $X                            = $Switch[$P]
                
                0..( $Names.Count - 1 )   | % {  
                    
                    $Y                    = $Names[$_]

                    If ( $X[$_] -eq 0 ) 
                    { 
                        $Code.$Y          = "-" 
                        $GUI.$Y           | % { $_.IsChecked  = $False }
                    }

                    If ( $X[$_] -eq 1 ) 
                    { 
                        $Code.$Y          = "Selected"
                        $GUI.$Y           | % { $_.IsChecked  = $True  }
                    }
                }
        # ______________________________________________________________________________ #
        # Domain Type
        # ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ #
            $Code.DomainType              = ( Get-DSCPromoTable -DomainType )[$P]
        # ______________________________________________________________________________ #
        # Mode
        # ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ #
            $Names                        = Get-DSCPromoTable -Mode
            $Switch                       = @{ 0 = 1,1,0 ; 1 = 0,1,1 ; 2 = 0,1,1  ; 3 = 0,0,0 }
        
            $X                            = $Switch[$P]
            
                0..( $Names.Count - 1 )   | % { 

                    $Y                    = $Names[$_]

                    If ( $Y -eq $Names[2] ) 
                    { 
                        $GUI.$Y           | % { $_.Text = '' }
                    }

                    If ( $X[$_] -eq 0 )
                    { 
                        $Code.$Y          = '-' 
                        $GUI."$Y`Box"     | % { $_.Visibility = "Collapsed" }
                    }
                    
                    If ( $X[$_] -eq 1 )
                    { 
                        $Code.$Y          = '' 
                        $GUI."$Y`Box"     | % { $_.Visibility = "Visible"   }
                        $Return          += $Y
                    }
                }
        # ______________________________________________________________________________ #
        # Services
        # ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ #
            $Names                        = Get-DSCPromoTable -Services
            $Switch                       = 0..16 | % { $ST[$_][-2] } | % { If ( $_ -eq "X" ) { 0 } Else { 1 } }
            
                0..( $Names.Count - 1 )   | % { 

                    $X , $Y               = $Switch[$_] , $Names[$_]

                    $GUI.$Y               | % { $_.IsEnabled = $False ; $_.IsChecked = $True }

                    If ( $X -eq 0 ) 
                    { 
                        $Code.$Y          = 'Installed' 
                    }

                    If ( $X -eq 1 ) 
                    { 
                        $Code.$Y          = 'Available'
                        $GUI.$Y           | % { $_.IsEnabled = $True }
                    }

                }
        # ______________________________________________________________________________ #
        # Roles
        # ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ #
            $Names                        = Get-DSCPromoTable -Roles
            $Switch                       = @{ 0 = 1,1,0,0 ; 1 = 1,1,1,0 ; 2 = 1,1,1,0 ; 3 = 1,1,1,1 }
            $Default                      = @{ 0 = 1,0,0,0 ; 1 = 1,0,0,0 ; 2 = 1,1,0,0 ; 3 = 1,0,0,0 }
            
            $X                            = $Switch[$P]

                0..( $Names.Count - 1 )   | % {  

                    $Y                    = $Names[$_]

                    $GUI.$Y               | % { $_.IsEnabled = $False ; $_.IsChecked = $True }
                    
                    If ( $X[$_] -eq 0 ) 
                    { 
                        $Code.$Y          = '-' 
                    }

                    If ( $X[$_] -eq 1 ) 
                    { 
                        $Code.$Y          = $X[$_]
                        $GUI.$Y.IsEnabled = $B[$Default[$P][$_]]
                        $Return          += $Y 
                    }
                }
        # ______________________________________________________________________________ #
        # Paths
        # ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ #
            $Names                        = Get-DSCPromoTable -Paths
            $Default                      = "NTDS" , "NTDS" , "SYSVOL" | % { "C:\Windows\$_" }
            
                0..( $Names.Count - 1 )   | % { 

                    $Y                    = $Names[$_]
                    $Code.$Y              = $Default[$_]
                    $GUI.$Y.Text          = $Default[$_]
                }
        # ______________________________________________________________________________ #
        # Domain
        # ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ #
            $Names                        = Get-DSCPromoTable -Domain
            $Switch                       = @{ 0 = 0,1,1,0,0,0,1 ; 1 = 1,0,0,1,1,0,1 ; 2 = 1,0,0,1,1,0,1 ; 3 = 1,1,0,0,0,1,1 }
            
            $X                            = $Switch[$P]

                0..( $Names.Count - 1 )   | % { 
                    
                    $Y                    = $Names[$_]
                    $GUI.$Y               | % { $_.Text = "" }

                    If ( $X[$_] -eq 0 ) 
                    { 
                        $Code.$Y          = '-' ; 
                        $GUI."$Y`Box"     | % { $_.Visibility = "Collapsed" }
                    }

                    If ( $X[$_] -eq 1 ) 
                    { 
                        $Code.$Y          = ''
                        $GUI."$Y`Box"     | % { $_.Visibility =   "Visible" }
                        $Return          += $Y
                    }
                }
        # ______________________________________________________________________________ #
        # DSRM
        # ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ #
            "Credential" | % {
                
                $GUI.$_                   | % { 
                
                    $_.IsEnabled          = $False
                    $_.Text               = "" 
                }
                
                If ( $P -ne 0 ) 
                {
                    $Code.$_              = ""
                }

                Else 
                { 
                    $Code.$_              = "N/A"
                }

                $Return                  += "SafeModeAdministratorPassword"
            
            }

            Return [ PSCustomObject ]@{ 
            
                Code                      = $Code
                Window                    = $GUI
                Profile                   = $Return 
            }
                                                                                     #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}