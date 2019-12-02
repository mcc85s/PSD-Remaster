    Function Get-DSCPromoControl # Provides backend for reliable XAML Control ___________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        Return [ PSCustomObject ]@{ 
        
        Command     = "" ; Process     = "" ; Forest      = "" ; Tree        = "" ; Child       = "" ; Clone       = "" ; 
        
        DomainType  = "" ; ForestMode  = "" ; DomainMode  = "" ; ParentDomainName               = "" ;
        
        AD_Domain_Services             = "" ; DHCP        = "" ; DNS         = "" ; GPMC        = "" ; RSAT        = "" ; 
        RSAT_AD_AdminCenter            = "" ; RSAT_AD_PowerShell             = "" ; RSAT_AD_Tools                  = "" ; 
        RSAT_ADDS                      = "" ; RSAT_ADDS_Tools                = "" ; RSAT_DHCP                      = "" ; 
        RSAT_DNS_Server                = "" ; RSAT_Role_Tools                = "" ; WDS                            = "" ; 
        WDS_AdminPack                  = "" ; WDS_Deployment                 = "" ; WDS_Transport                  = "" ;
        
        InstallDNS                     = "" ; CreateDNSDelegation            = "" ; 
        NoGlobalCatalog                = "" ; CriticalReplicationOnly        = "" ;
        
        DatabasePath                   = "" ; LogPath     = "" ; SysvolPath  = "" ;
        
        Credential  = "" ; DomainName  = "" ; DomainNetBIOSName              = "" ; NewDomainName                  = "" ; 
        NewDomainNetBIOSName           = "" ; SiteName                       = "" ; ReplicationSourceDC            = "" ; 
        
        SafeModeAdministratorPassword  = "" }
    }