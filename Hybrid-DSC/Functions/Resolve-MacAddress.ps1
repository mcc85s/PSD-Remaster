    Function Resolve-MacAddress # Obtains the MAC Address Resolution Lists ______________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      

        $X      = Resolve-HybridDSC -Module

        $Return = [ Ordered ]@{ Count = "" ; Index = "" ; Vendor = "" }
        
        ForEach ( $i in "Count" , "Index" , "Vendor" ) 
        {     
            $Archive = @{ Path = "$x\Map\$I.zip" ; DestinationPath = $X ; Force = $True }

            Expand-Archive @Archive

            "$x\$I.txt" | % { $Return.$I = GC $_ ; RI $_ }
        }
        Return $Return                                                               #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}