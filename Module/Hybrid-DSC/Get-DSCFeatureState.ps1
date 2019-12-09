    Function Get-DSCFeatureState # Determines Installation Loadout ______________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ] Param ( [ Parameter () ][ Switch ] $All )

        $Services = Get-DSCFeatureList ; $GWF = Get-WindowsFeature ; $Array = @( ) ; $Table = [ Ordered ]@{ Installed = @( ) ; Available = @( ) }

        ForEach ( $I in $Services ) { $X = $GWF | ? { $_.Name -eq $I } | % { 
            If ( $_.InstallState -ne "Installed" ) { $Array += "$I [_]" ; $Table.Available += "$I [_]" }
            If ( $_.InstallState -eq "Installed" ) { $Array += "$I [X]" ; $Table.Installed += "$I [X]" } } }

        Return $( If ( !$All ) { $Table } If ( $All ) { $Array } )                   #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}