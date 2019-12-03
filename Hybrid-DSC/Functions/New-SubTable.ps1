    Function New-SubTable # Converts array of keys and values into an Object ___________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding ( ) ] Param (

            [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True ) ][ String [] ]  $Items ,
            [ Parameter ( Position = 1 , Mandatory = $True , ValueFromPipeline = $True ) ][ String [] ] $Values )

        $Table = [ PSCustomObject ]@{ }

        If ( $Items.Count -eq $Values.Count )
        {
            If ( $Items.Count -gt 1 ) 
            { 
                $Count = 0..( $Items.Count - 1 )
                $Count | % { $Table | Add-Member -MemberType NoteProperty -Name "Item:$_" -Value @{ ID = "$( $Items[$_] )" ; Value = "$( $Values[$_] )" } }
            }
            
            If ( $Items.Count -eq 1 )
            {
                $Table | Add-Member -MemberType NoteProperty -Name "Item:0" -Value @{ ID = "$( $Items )" ; Value = "$( $Values )" } 
            }
        }
        
        If ( $Items.Count -ne $Values.Count ) 
        { 
            Throw '$Items -ne $Values' 
        }
        
        Return $Table                                                                #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}
