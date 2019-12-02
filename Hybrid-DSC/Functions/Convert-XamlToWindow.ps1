    Function Convert-XAMLToWindow # Modified, originally by Dr. Tobias Weltner  _________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        Param ( [ Parameter ( Mandatory ) ] [ String ] $XAML , [ String [] ] $NE = $Null , [ Switch ] $PassThru )

        @( "Framework" , "Core" | % { "Presentation$_" } ) + "WindowsBase" | % { Add-Type -AssemblyName $_ }
 
        $NR = [ XML.XMLReader ]::Create( [ IO.StringReader ] $XAML ) ; $OP = [ Windows.Markup.XAMLReader ]::Load( $NR )
        
        $NE | % { $OP | Add-Member -MemberType NoteProperty -Name $_ -Value $OP.FindName( $_ ) -Force }
 
        If ( $PassThru ) { $OP } Else { $Null = $GUI.Dispatcher.InvokeAsync( { $OP = $GUI.ShowDialog() ; SV -Name OP -Value $OP -Scope 1 } ).Wait() ; $OP }

                                                                                     #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}