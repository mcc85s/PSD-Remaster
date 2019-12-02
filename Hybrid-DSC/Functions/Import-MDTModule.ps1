    Function Import-MDTModule # Loads the module for MDT _______________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
       
        GP "HKLM:\Software\Microsoft\Deployment 4" | % { GCI $_.Install_Dir "*Toolkit.psd1" -Recurse } | % { IPMO $_.FullName -VB }
        Write-Theme -Action "Module [+]" "Microsoft Deployment Toolkit"
                                                                                    #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}