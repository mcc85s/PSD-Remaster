﻿    Function Initialize-Server # This commandlet does stuff _____________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      

        $Info            = Get-NetworkInfo -LocalHost
        $Report          = Start-PingSweep
        $IPAddress       = $Report.Failure | Select -First 1

        $Adapter         = Get-NetRoute -AddressFamily IPV4 | ? { $_.DestinationPrefix -like "*$( $Info.IPV4 )/*" } | % { $_.InterfaceIndex }
        $Gateway         = Get-NetRoute -AddressFamily IPv4 -InterfaceIndex $Adapter | ? { $_.DestinationPrefix -eq "0.0.0.0/0" } | % { $_.NextHop }
        
        $Splat           = @{    InterfaceIndex = $Adapter
                                      IPAddress = $IPAddress
                                   PrefixLength = $Info.CIDR
                                 DefaultGateway = $Gateway
                                  ValidLifeTime = [ TimeSpan ]::MaxValue
                              PreferredLifeTime = [ TimeSpan ]::MaxValue }

        New-NetIpAddress @IPAddress

                                                                                     #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}