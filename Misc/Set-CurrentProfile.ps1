

    Function Set-CurrentProfile
    {
        [ CmdLetBinding () ] Param (

            [ Parameter ( Mandatory = $True , ParameterSetName = "0" ) ] [ Switch ] $ShowIcons ,
            [ Parameter ( Mandatory = $True , ParameterSetName = "1" ) ] [ Switch ] $HideIcons )
        
        If ( $ShowIcons ) { $Action = 0 }
        If ( $HideIcons ) { $Action = 1 }

        $Old , $New = "ClassicStartMenu" , "NewStartPanel" | % { 
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\$_" 
        }

        $Icon = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" , # Computer
                "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" , # Network 
                "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"   # Documents 

        ForEach ( $I in 0..2 )
        {
            $Old , $New | % { SP $_ $Icon[$i] $Action }
        }
    }

# ---------------------------------------- #
# Defaults / New                           #
# ---------------------------------------- #
# "{031E4825-7B94-4dc3-B131-E946B44C8DD5}" # (1) Libraries
# "{208D2C60-3AEA-1069-A2D7-08002B30309D}" # (1) ?
# "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" # (0) Computer
# "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" # (1) Control Panel
# "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" # (1) Users Documents 
# "{871C5380-42A0-1069-A2EA-08002B30309D}" # (1) Internet Explorer ?
# "{9343812e-1c37-4a49-a12e-4b2d810d956b}" # (1) ?
# "{B4FB3F98-C1EA-428d-A78A-D1F5659CBA93}" # (1) ?
# "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" # (1) Network
# ---------------------------------------- #
