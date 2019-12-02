    Function Find-XAMLNamedElements # Returns named items in a XAML HereString __________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ] [ OutputType ( "Array" ) ] Param (

            [ Parameter ( Mandatory = $True , Position = 0 , HelpMessage = "XAML Here String" ) ] [ String ] $XAML )

        $Xaml = $Xaml.Replace( '"' , "'" )
        
        $Array = $Xaml.Split( "`n" )

        $Collect = @( )

        0..( $Array.Count - 1 ) | ? { $Array[$_] -like "* Name = *" } | % {
    
            $Line = $Array[$_].Split(' ') | ? { $_.Length -ne 0 } 

            $Collect += $Line[( 0..( $Line.Count - 1 ) | ? { $Line[$_] -eq "Name" } ) + 2 ] 
        }

        $Return = 0..( $Collect.Count - 1 ) | % { 
        
            $Collect[$_].Replace( "'" , '' ) 
        }

        Return $Return                                                               #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}