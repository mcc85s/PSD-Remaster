    Function New-Table # Converts array of objects into a single object _________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding ( ) ] Param (

            [ Parameter ( Position = 0 , Mandatory = $True , ValueFromPipeline = $True ) ][         String    ] $Title ,
            [ Parameter ( Position = 1 , Mandatory = $True , ValueFromPipeline = $True ) ][            Int    ] $Depth ,
            [ Parameter ( Position = 2 , Mandatory = $True , ValueFromPipeline = $True ) ][         String [] ] $ID    ,
            [ Parameter ( Position = 3 , Mandatory = $True , ValueFromPipeline = $True ) ][ PSCustomObject [] ] $Table )

        $Object = [ PSCustomObject ]@{ Class = $Title }
        
        If ( ( $ID.Count -ne $Depth ) -or ( $Table.Count -ne $Depth ) ) 
        { 
            Throw '$Depth -ne $ID.Count or $Table.Count' 
        }
        
        If ( $Depth -eq 1 ) 
        { 
            $Count = 1 
        } 
        
        If ( $Depth -gt 1 ) 
        { 
            $Count = 0..( $Depth - 1 ) 
        }
        
        $C = $Null ; $Count | % {

            If ( $Depth -gt 1 )
            {   
                If ( $C -ne $Null ) 
                { 
                    $C = $C + 1 
                } 
                
                If ( $C -eq $Null ) 
                { 
                    $C = 0 
                } 
                
                $Index   = $ID[$C]
                $Section = $Table[$C] 
            }

            If ( $Depth -eq 1 )
            {   
                $C = 0 ; $Index = $ID ; $Section = $Table 
            }

            $Object | Add-Member -MemberType NoteProperty -Name "ID:$C" -Value $Index

            $Keys = @( $Section | GM | ? { $_.MemberType -eq "NoteProperty" } | % { $_.Name } )

            ForEach ( $S in $Keys )
            {   
                $SubTable = [ Ordered ]@{ }

                ForEach ( $K in $Keys ) 
                { 
                    $Section.$K | % { 
                    
                        $SubTable.Add( "$K" , @{ ID = $_.ID ; Value = $_.Value } ) 
                    } 
                } 
            } 

            $Object | Add-Member -MemberType NoteProperty -Name "Section:$C" -Value $SubTable
        }
        Return $Object                                                               #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}