  Function Validate-DomainName # Verfies that text entries are valid ____________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ] [ OutputType ( "String" ) ] Param (

            [ Parameter ( Mandatory = $True , ParameterSetName = "0" ) ][ String ] $NetBIOS  ,
            [ Parameter ( Mandatory = $True , ParameterSetName = "1" ) ][ String ] $Domain   ,
            [ Parameter ( Mandatory = $True , ParameterSetName = "2" ) ][ String ] $SiteName )

        $C = "abcdefghijklmnopqrstuvwxyz" , "0123456789" , ".-" , "``~!@#$%^&*()=+_[]{}\|;:'`",<>/? " ; $I = $C -join ''

        $Alpha = $I[ 0..25] ; $Numeric = $I[26..35] + 0..9 ; $Split = $I[36..37] ; $Special = $I[38..68] ; $AN = $I[ 0..35] + 0..9

        $Reserved   = @{ 
            
            Words   = @( "ANONYMOUS,AUTHENTICATED USER,BATCH,BUILTIN,DIALUP,DIGEST AUTH,INTERACTIVE,INTERNET,NT AUTHORITY,NT DOMAIN" ,
                         "NTLM AUTH,NULL,PROXY,REMOTE INTERACTIVE,RESTRICTED,SCHANNEL AUTH,SELF,SERVER,SERVICE,SYSTEM,TERMINAL SERVER"
                         "THIS ORGANIZATION,USERS,WORLD" ; "LOCAL" | % { $_ , "$_ SYSTEM"  } ; "NETWORK" | % { $_ , "$_ SERVICE" } ; 
                         "GROUP" , "OWNER" | % { $_ , "$_ SERVER" } | % { "CREATOR $_" } ) -join ',' | % { $_.Split( ',' ) } | Sort

            DNSHost = "-GATEWAY" , "-GW" , "-TAC" <# RFC 952 #>

            SDDL    = "AN,AO,AU,BA,BG,BO,BU,CA,CD,CG,CO,DA,DC,DD,DG,DU,EA,ED,HI,IU,LA,LG,LS,LW,ME,MU,NO,NS,NU,PA,PO,PS,PU,RC,RD,RE,RO" +
                      "RS,RU,SA,SI,SO,SU,SY,WD" | % { $_.Split( ',' ) }
        }

        If ( $NetBIOS  ) { $X = $NetBIOS  ; $Y = @{ Min = 1 ; Max = 15 ; Reserve = $Reserved.Words ; Allow = $I[0..37] ; Deny = $Special } }
        If ( $Domain   ) { $X = $Domain   ; $Y = @{ Min = 2 ; Max = 63 ; Reserve = $Reserved.Words ; Allow = $I[0..37] ; Deny = $Special } } 
        If ( $SiteName ) { $X = $SiteName ; $Y = @{ Min = 1 ; Max = 63 ; Reserve = $Reserved.Words ; Allow = $I[0..37] ; Deny = $Special } }

        If ( $X.Length -lt $Y.Min )                                          { "Name is too short" }
        ElseIf ( $X.Length -gt $Y.Max )                                      { "Name is too long"  }
        ElseIf ( ( $X[0..$X[-1]] | ? { $_ -in $Y.Deny } ).Count -gt 0 )      { "Name has invalid characters" }

        ElseIf ( $NetBIOS )
        {
            If     ( "." -in $X )                                            { "Period found in NetBIOS Domain Name, breaking" }
            ElseIf ( $X -in $Y.Reserve )                                     { "Name is reserved" }
            Else { Return $X }
        }
            
        ElseIf ( ( $Domain ) -or ( $SiteName ) )
        {
            If ( ( $X[0] -notin $AN ) -or ( $X[-1] -notin $AN ) -eq $True )  { "First/Last Character must be AlphaNumeric" }
                
            ElseIf ( $Domain )
            {
                If ( ( $X.Length -eq 2 ) -and ( $X -in $Reserved.SDDL ) )    { "Name is reserved" }
                Else { Return $X }
            }
            
            ElseIf ( $SiteName )
            {
                Return $X
            }
        }
    }