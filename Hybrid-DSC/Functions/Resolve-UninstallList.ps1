    Function Resolve-UninstallList # Collects installed applications from the registry__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        $Return = "" , "\WOW6432Node" | % { "HKLM:\SOFTWARE$_\Microsoft\Windows\CurrentVersion\Uninstall\*" }
        
        $env:PROCESSOR_ARCHITECTURE | % { 
        
            If ( $_ -eq "AMD64" ) 
            {
                Return $Return | % { GP $_ }
            }

            Else
            {
                Return GP $Return[0]
            }
        }                                                                           #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}