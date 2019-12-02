    Function Get-DSCPromoTable # _________________________________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ] Param (

            [ Parameter ( Position = 0 , ParameterSetName =      "All" ) ][ Switch ] $All        ,
            [ Parameter ( Position = 0 , ParameterSetName =  "Command" ) ][ Switch ] $Command    ,
            [ Parameter ( Position = 0 , ParameterSetName =  "Process" ) ][ Switch ] $Process    ,
            [ Parameter ( Position = 0 , ParameterSetName =     "Menu" ) ][ Switch ] $Menu       ,
            [ Parameter ( Position = 0 , ParameterSetName =     "Type" ) ][ Switch ] $DomainType ,
            [ Parameter ( Position = 0 , ParameterSetName =      "Top" ) ][ Switch ] $Mode        ,
            [ Parameter ( Position = 0 , ParameterSetName = "Services" ) ][ Switch ] $Services   ,
            [ Parameter ( Position = 0 , ParameterSetName =    "Roles" ) ][ Switch ] $Roles      ,
            [ Parameter ( Position = 0 , ParameterSetName =    "Paths" ) ][ Switch ] $Paths      ,
            [ Parameter ( Position = 0 , ParameterSetName =   "Domain" ) ][ Switch ] $Domain     )
        
        $Table = [ Ordered ]@{ 

            Command    = @( "Forest" ; "" , "" , "Controller" | % { "Domain$_" } ) | % { "Install-ADDS$_" }
            Process    = 0..3
            Menu       =     "Forest" ,       "Tree" ,       "Child" , "Clone"
            DomainType =          "-" , "TreeDomain" , "ChildDomain" ,     "-"
            Mode       = "ForestMode" , "DomainMode" , "ParentDomainName"
            Services   = Get-DSCFeatureList -Underscore
            Roles      = "InstallDNS" , "CreateDNSDelegation" , "NoGlobalCatalog" , "CriticalReplicationOnly"
            Paths      = "Database" ,  "Log" , "Sysvol" | % { "$_`Path" }
            Domain     = @( "Credential" ; "Domain" | % { $_ , "New$_" } | % { $_ , "$_`NetBIOS" } | % { "$_`Name" } ; "ReplicationSourceDC" , "SiteName" )
            Buttons    = "Start" , "Cancel" , "CredentialButton" 
        }

        $Table | % { Return $( If ( $All        ) { $_          } If ( $Command    ) { $_.Command    } If ( $Process    ) { $_.Process  }
                               If ( $Menu       ) { $_.Menu     } If ( $DomainType ) { $_.DomainType } If ( $Mode       ) { $_.Mode     }
                               If ( $Services   ) { $_.Services } If ( $Roles      ) { $_.Roles      } If ( $Paths      ) { $_.Paths    }
                               If ( $Domain     ) { $_.Domain   } ) }                #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}