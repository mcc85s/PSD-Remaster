    Function Get-CurrentServices # Retrieves/Displays Current Services _________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ] Param (

            [ Parameter ( ParameterSetName = "Theme" ) ] [ Switch ] $Display )

        $Return = GCIM Win32_Service | % {
    
            [ PSCustomObject ]@{ 
            
                Status      = $_.State
                StartType   = $_.StartMode
                Name        = $_.Name 
                DisplayName = $_.DisplayName
                PathName    = $_.PathName
                Description = $_.Description
            }
        }

        If ( $Display )
        {
            $Range               = 0..( $Return.Count - 1 )
            $Section             = 0..( $Return.Count - 1 )
            $Subtable            = 0..( $Return.Count - 1 )
    
            $Names               = @( "Status" , "StartType" ; @( "" , "Display" , "Path" | % { "$_`Name" } ) )

            ForEach ( $i in 0..( $Return.Count - 1 ) )
            {
                $X               = $Return[$I]
        
                $Section[$I]     = "( $( $X.DisplayName ) )"
        
                $Splat           = @{ 

                    Items        = 0..4 | % {       $Names[$_] }
                    Values       = 0..4 | % { $X.$( $Names[$_] )    }

                }

                $SubTable[$I]    = New-SubTable @Splat
            }

            $Table = New-Table -Depth $Range.Count -Title "Current Services" -ID $Section -Table $SubTable
    
            Write-Theme -Table $Table -Prompt "Press Enter to Continue"
        }

        Return $Return
                                                                                    #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____     
}
