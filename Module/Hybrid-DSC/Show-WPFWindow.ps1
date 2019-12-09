    Function Show-WPFWindow # Modified, originally by Dr. Tobias Weltner ________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        Param ( [ Parameter ( Mandatory ) ] [ Windows.Window ] $GUI )

        $OP = $Null ; $Null = $GUI.Dispatcher.InvokeAsync( { $OP = $GUI.ShowDialog() ; SV -Name OP -Value $OP -Scope 1 } ).Wait() ; $OP 
                                                                                      #____    ____    ____    ____    ____    ____    ____    ____      
}