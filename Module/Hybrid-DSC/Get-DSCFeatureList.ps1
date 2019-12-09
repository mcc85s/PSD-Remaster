    Function Get-DSCFeatureList # Collects all server features that pertain to DSC ______//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ] Param ( [ Parameter ( Position = 0 ) ] [ Switch ] $Underscore )
                        
        $Echo = @( "AD-Domain-Services" , "DHCP" , "DNS" , "GPMC" ; @( "" ; "-AdminCenter" , "-PowerShell" , "-Tools" | % { "-AD$_" } ; 
                   "" , "-Tools" | % { "-ADDS$_" } ; "-DHCP" , "-DNS-Server" , "-Role-Tools" ) | % { "RSAT$_" } ;
                   "" , "-AdminPack" , "-Deployment" , "-Transport"  | % { "WDS$_" } )

        If ( $Underscore ) 
        { 
            $Echo = $Echo.Replace( '-' , '_' ) 
        } 
        
        Return $Echo                                                                 #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}