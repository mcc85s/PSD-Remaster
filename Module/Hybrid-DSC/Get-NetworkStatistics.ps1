    Function Get-NetworkStatistics # Like if netstat by itself wasn't so lame ___________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        $OP     = netstat -ant | ? { $_ -like "*TCP*" -or $_ -like "*UDP*" }

        $OP     | ? { $_ -notmatch '\*' } | % { $X = $_.Split( ' ' ) | ? { $_.Length -gt 0 }
        Return  [ PSCustomObject ]@{ Protocol = $X[0] ; Local = $X[1] ; Foreign = $X[2] ; LinkState = $X[3] ; Stream = $X[4] } }

        $OP     | ? { $_    -match '\*' } | % { $X = $_.Split( ' ' ) | ? { $_.Length -gt 0 }
        Return  [ PSCustomObject ]@{ Protocol = $X[0] ; Local = $X[1] ; Foreign = "*:*" ; LinkState = "*:*" ; Stream = "*:*" } }

                                                                                     #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}