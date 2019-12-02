    Function Update-Branding # Updates the branding ( TEH WEI KING ) ___________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯       
        [ CmdLetBinding () ] Param (

            [ Parameter ( Mandatory = $True ) ] [ String ] $Logo ,
            [ Parameter ( Mandatory = $True ) ] [ String ] $Background ,
            [ Parameter ( Mandatory = $True ) ] [ String ] $Network    )

        $SD , $SR , $SYS , $PGD = @( $env:SystemDrive ; $env:SystemRoot | % { $_ , "$_\System32" } ; $env:ProgramData )

        If ( $Network )
        {
            $Root = Resolve-HybridDSC -DeploymentServer
        }
    
        Else 
        {
            $Root = Resolve-HybridDSC -Share
        }
    
        # Build Registry Tree
        $Registry  = [ PSCustomObject ]@{ 

            Hive   = "CU" , "LM" , "LM" , "LM"  | % { "HK$_`:\Software" }
            Link   = "" , "" , "" , "Policies\" | % { "$_`Microsoft\Windows" }
            Mark   = @( "Policies\System" , "OEMInformation" , "Authentication\LogonUI\Background" | % { "CurrentVersion\$_" } ; "Personalization" )
    
        }

        # Registry Links
        $REX       = 0..3 | % { "$( $Registry.Hive[$_] )\$( $Registry.Link[$_] )\$( $Registry.Mark[$_] )" }
    
        # File Links
        $FEX       = @( @( "" ; "" , "\Backgrounds" | % { "\OOBE\Info$_" } ) | % { "$SYS$_" } ; 
                        @( "Screen" , "Wallpaper\Windows" | % { "$SR\Web\$_" } ; "$PGD\Microsoft\User Account Pictures" ) )
    
        # New Items
        $FEX[2]   | ? { ! ( Test-Path $_ ) } | % { # OEM Background Folder
    
            NI $_ -ItemType Directory
            Write-Theme -Action "Created [+]" "OEM Background Directory"

        }

        $REX[3,1] | ? { ! ( Test-Path $_ ) } | % { #
    
            $X = $_.Split( '\' )[-1]
            NI $_ -Name $X
            Write-Theme -Action "Created [+]" "Registry Key / $X"
    
        }

        # Copy Items 
        $FEX[0,1,5] | % { CP $Root.Logo       $_ -VB } # Logo
        $FEX[2..4]  | % { CP $Root.Background $_ -VB } # Background

        $Properties = [ PSCustomObject ]@{

            Path    = $REX[0,0,1,1,1,1,1,3,2]
            Name    = @( "" , "Style" | % { "Wallpaper$_" } ; "Logo" , "Manufacturer" ; "Phone" , "Hours" , "URL" | % { "Support$_" } ; 
                         "LockScreenImage" , "OEMBackground" )
            Value   = $Root | % { "$( $FEX[4] )\$( $_.Background )" , 2 , "$SYS\$( $_.Logo )" , $_.Company , $_.Phone , $_.Hours , $_.WWW , 
                      "$( $FEX[3] )\$( $_.Background )" , 1 }
    
        }

        # Set Properties
        0..8        | % { SP $PEX[$_] -Name $NEX[$_] -Value $VEX[$_] -VB }          #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}