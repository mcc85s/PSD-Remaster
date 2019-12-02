    Function Start-NetworkInfo  # Collects all needed interface data ____________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ] Param (

            [ Parameter ( ParameterSetName =     "Local" ) ] [ Switch ]     $Local ,
            [ Parameter ( ParameterSetName =       "Map" ) ] [ Switch ]       $Map ,
            [ Parameter ( ParameterSetName =   "NetBIOS" ) ] [ Switch ]   $NetBIOS , 
            [ Parameter ( ParameterSetName = "Telemetry" ) ] [ Switch ] $Telemetry ,
            [ Parameter ( ParameterSetName =       "All" ) ] [ Switch ]       $All )

            $Index = "Network Adapter" , "Network Host IP/MAC" ,  "NetBIOS / Domain" , "Certificate / Location" | % { "$_ Information" }

            If ( $All )
            {
                $Section    = @{ } ; $SubTable = @{ }
                
                0..3 | % { $Section.Add( $_ , "" ) ; $SubTable.Add( $_ , "" ) }
            }
        <#________________________#>
        <#[ Network Information  ]#>
        <#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯#>

            $Network = Get-NetworkInfo -LocalHost

            If ( $Network -ne $Null )
            {
                $Subject    = ( $Network | GM | ? { $_.MemberType -like "*Note*" } )[5,1,8,7,0,6,2,10,9,4,3]
                $Names      = $Subject   | % { $_.Name }
                $Values     = $Subject   | % { $_.Definition.Split( '=' )[-1] }

                $Output     = "[0]" , "" | % { 

                    "`$Section$_    = @{ 
                
                        Name    = `$Names
                        Value   = `$Values
                        Section = `$Index[0] 
                     }
                 
                    `$Subtable$_   = New-Subtable -Items `$Section$_.Name -Values `$Section$_.Value"
                }

                If ( $All   ) { IEX $Output[0] }
                If ( $Local ) { IEX $Output[1] }
            }

            If ( $Network -eq $Null )
            {
                Write-Theme -Action "Exception [!]" "Network Adapter information not found" 12 4 15
                Break
            }

        <#________________________#>
        <#[   Network Host Map   ]#>
        <#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯#>

            $HostList       = Get-NetworkHosts | ? { $_.IPV4Class -like "*Class*" }

            If ( $HostList -ne $Null )
            {
                $Names      = $HostList | % { $_.IPV4Address }
                $Values     = $HostList | % { $_.MACAddress  }

                $Output     = "[1]" , "" | % { 

                    "`$Section$_    = @{ 
                
                        Name    = `$Names
                        Value   = `$Values
                        Section = `$Index[1] 
                     }
                 
                    `$Subtable$_   = New-Subtable -Items `$Section$_.Name -Values `$Section$_.Value"
                }
                
                If ( $All   ) { IEX $Output[0] }
                If ( $Map   ) { IEX $Output[1] }
            }

            If ( $HostList -eq $Null )
            {
                Write-Theme -Action "Exception [!]" "Network Adapter information not found" 12 4 15
                Break
            }

        <#________________________#>
        <#[   NetBIOS / NBTScan  ]#>
        <#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯#>
        
            $NBT            = Get-NBTSCAN
            $Control        = @( $NBT | ? { $_.ID -like "*1C*" } )

            If ( $Control.Count -gt 1 )
            {
                $Control    = $Control[0] # Will write better selection logic for multiple servers
            }
            
            If ( $Control -eq $Null )
            {
                nbtstat -N
                $Control    = $NBT | ? { $_.IP -eq $Network.IPV4 -and $_.ID -like "*00*" -and $_.Type -eq "GROUP" }
            }

            If ( $Control -ne $Null )
            {
                $Names      = ( $Control | GM | ? { $_.MemberType -like '*Note*' } )[2,0,3,1,5,4] | % { $_.Name }
                $Values     = $Names | % { $Control.$_ }

                $Output     = "[2]" , "" | % {

                    "`$Section$_    = @{ 
                
                        Name    = `$Names
                        Value   = `$Values
                        Section = `$Index[2] 
                     }
                 
                    `$Subtable$_   = New-Subtable -Items `$Section$_.Name -Values `$Section$_.Value"
                }
                
                If ( $All       ) { IEX $Output[0] }
                If ( $NetBIOS   ) { IEX $Output[1] }
            }

        <#________________________#>
        <#[___ Telemetry Data ___]#>
        <#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯#>

            $TD             = Get-TelemetryData
            
            If ( $TD -eq $Null )
            {
                Write-Theme -Action "Exception [!]" "Certificate information not loaded" 12 4 15
                Break
            }

            If ( $TD -ne $Null )
            {
                $Names       = @( $TD | GM | ? { $_.MemberType -eq "NoteProperty" } | % { $_.Name } )[2,6,4,0,3,1,7,8,5]
                $Values      = $Names | % { $TD.$_ }

                $Output     = "[3]" , "" | % {

                    "`$Section$_    = @{ 
                
                        Name    = `$Names
                        Value   = `$Values
                        Section = `$Index[3] 
                     }
                 
                    `$Subtable$_   = New-Subtable -Items `$Section$_.Name -Values `$Section$_.Value"
                }

                If ( $All       ) { IEX $Output[0] }
                If ( $Telemetry ) { IEX $Output[1] }
            }
        <#________________________#>
        <#[___ Generate Table ___]#>
        <#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯#>
            
            $Panel = @{ Title = "Domain Controller Bootstrap" ; Depth = "" ; ID = "" ; Table = "" }

            If ( $All )
            {
                $Panel | % { 
                    
                    $_.Depth = 4
                    $_.ID    = 0..3 | % { $Section[$_].Section  | % { "( $_ )" } }
                    $_.Table = 0..3 | % { $Subtable[$_] } 
                }
            }

            If ( ( $Local ) -or ( $Map ) -or ( $NetBIOS ) -or ( $Telemetry ) )
            {
                $Panel | % {

                    $_.Depth = 1
                    $_.ID    = $Section.Section
                    $_.Table = $Subtable 
                 }
            }
        
            $Table          =    New-Table @Panel
        <#________________________#>
        <#[___ Display Table ____]#>
        <#¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯#>

        Write-Theme -Table $Table

        Return $Table                                                                #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}