    Function Sync-DNSSuffix # Modified / Jeff Hicks @ github.com/jdhitsolutions ________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ] Param ( 
        
            # Not supporting multiple or network based computers yet.
            # Based on registry modification, was still very critical to implement domain membership sync

            [ Parameter ( Position = 0 , ParameterSetName = "Get" ) ] [ Switch ] $Get    ,
            [ Parameter ( Position = 0 , ParameterSetName = "Set" ) ] [ Switch ] $Set    ,
            [ Parameter ( Position = 1 , ParameterSetName = "Set" ) ] [ Switch ] $Domain )

            Begin 
            {
                $Query = "HKLM:\System\CurrentControlSet\Services\TCPIP\Parameters"
                $CS    = GCIM Win32_ComputerSystem
            }

            Process
            {
                If ( $Get )
                {
                    GP $Query | % { 

                        Return [ PSCustomObject ]@{

                            Computername      = $_.hostname
                            Domain            = $_.Domain
                            'NV Domain'       = $_.'NV Domain'
                            SynchronizeSuffix = $_.SyncDomainWithMembership -as [ Bool ]
                        }
                    }
                }

                If ( $Set )
                {
                    If ( ! ( $CS.PartOfDomain ) )
                    {
                        "Domain" | % { $_ , "NV $_" } | % { 
                        
                            SP -Path $Query -Name $_ -Value $Domain
                        }

                        SP -Path $Query -Name SyncDomainWithMembership -Value 1
                    }

                    If ( $CS.PartOfDomain )
                    {
                        [ System.Windows.Forms.MessageBox ]::Show( "System is part of a domain" , "Exception" )
                    }
                }
            }
    }
