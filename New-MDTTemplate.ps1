<#
.SYNOPSIS Makes a LiteTouchPE XML template for MDT

.DESCRIPTION Tells the Microsoft Deployment Toolkit, that it may be awesome as hell, but... this thing must follow some commands.

.USAGE New-MDTTemplate -LiteTouch
#>

Function New-MDTTemplate
{
    [ CmdLetBinding ( ) ] Param (

        [ Parameter ( ParameterSetName = "LiteTouch" ) ] [ Switch ] $LiteTouch )

    $SP = 0..13 | % { "    " * $_ }

    $XML = [ Ordered ]@{ }

    If ( $LiteTouch )
    {
        $DEF , $WPE , $VER , $SRC , $SCR , $IMGN , $IMGD , $CMP = @( "Definition" , "WindowsPE" , "Version" , "Source" , "ScratchSpace" ; "Name" , "Description" | % { "Image$_" } ; "Component" )
        $Components = "hta" , "scripting" , "wim" , "securestartup" , "fmapi" , "netfx" , "powershell" , "dismcmdlets" , "storagewmi" , "enhancestorage" , "securebootcmdlets"
    
        $XT = ( "exe" , "dll" )[0,0,1,1,0,1,1,0,0,0,1,0,0+(0..6|%{1})]
        $ID = "BDDRUN" , "WinRERUN" , "CcmCore" , "CcmUtilLib" , "Smsboot" , "SmsCore" , "TsCore" , "TSEnv" , "TsManager" , "TsmBootstrap" , "TsMessaging" , 
        "TsmBootstrap" , "TsProgressUI" , "TSResNlc" , "CommonUtils" , "ccmgencert" , "msvcp120" , "msvcr120" , "00000409\tsres" , "Microsoft.BDD.Utility"
        $Tool = 0..19 | % { $ID[$_] , $XT[$_] -join '.' }

        $BDD = "Tools\Modules\Microsoft.BDD.TaskSequenceModule"

        $X = @( 0..4 | % { 0 } ; 0..4 | % { 1 } ; 0..2 | % { 0 } ; 0..13 | % { 1 } ; 0..2 | % { 0 } ) | % { $SP[$_] }

        $Y = @( "<$DEF>" , "  <$WPE>" , "" , "" , "<!-- Settings -->" , "<$VER />" , "<$SRC />" , "<$SCR>64</$SCR>" , "<$IMGN />" , "<$IMGD />" ,
                "" , "" , "<!-- $CMP`s -->" , "<$CMP`s>" ; 0..10 | % { "<$CMP>winpe-$( $Components[$_] )</$CMP>" } ; "</$CMP`s>" , "" , "" ) ; 

        $XML.Add( "00" , @( 0..27 | % { $X[$_] + $Y[$_] } ) )

        $X = @( 0 , 1 , 1 , 0 , 0 , 0 , 1 , 0 , 1 , 1 , 1 , 1 , 0 , 0 , 1 , 1 , 1 , 0 , 0 , 0 ; 0..19 | % { 1 } ) | % { $SP[$_] }

        $Y = @( "<!-- Driver and packages -->" , "<Drivers />" , "<Packages />" , "" , "" , "<!-- Content -->" , "  <Content>" , "" ,  "  <!-- Configuration -->" , 
                "  <Copy source='%DEPLOYROOT%\Control\Bootstrap.ini' dest='Deploy\Scripts\Bootstrap.ini' />" , 
                "  <Copy source='%DEPLOYROOT%\Templates\Unattend_PE_%PLATFORM%.xml' dest='Unattend.xml' />" , 
    	        "  <Copy source='%INSTALLDIR%\Templates\winpeshl.ini' dest='Windows\system32\winpeshl.ini' />" , "" , "" , "<!-- Scripts -->" , 
                "  <Copy source='%DEPLOYROOT%\Scripts\PSDStart.ps1' dest='Deploy\Scripts\PSDStart.ps1' />" , 
                "  <Copy source='%DEPLOYROOT%\Scripts\PSDHelper.ps1' dest='Deploy\Scripts\PSDHelper.ps1' />" , "" , "" , "<!-- Tools -->" ; 
                0..19 | % { 
                    "<Copy source='%DEPLOYROOT%\Tools\%PLATFORM%\$( $Tool[$_] )' dest='$( If ( $_ -eq 0 ) { "Windows\system32" } Else { "Deploy\Tools\%PLATFORM%" } )\$( $Tool[$_] )' />" } )

        $XML.Add( "01" , @( 0..40 | % { $X[$_] + $Y[$_] } ) )

        $X = @( 0 , 1 , 0 ; 0..2 | % { 1 } ; 0 ; 0..4 | % { 1 } ; 0 , 0 , 0 ; 0..3 | % { 1 } ; 0..2 | % { 0 } ) | % { $SP[$_] }

        $Y = @( "" , "<!-- Modules -->" , "" ; "dll" , "psd1" | % { "$BDD\Microsoft.BDD.TaskSequenceModule.$_" } | % { "<Copy source='%DEPLOYROOT%\$_' dest='Deploy\$_' />" } ; 
                "Interop.TSCore.dll" | % { "<Copy source='%DEPLOYROOOT%\$BDD\$_' dest='Deploy\$BDD\$_ />" } ; "" ; 
            
                ( 0 , "DeploymentShare" ) , ( 1 , "Utility" ) , ( 2 , "Gather" ) , ( 3 , "Gather" ) , ( 4 , "Wizard" ) | % { 
                
                    $Z = $( If ( $_[0] -eq 3 ) { "ZTI$( $_[1] ).xml" } Else { "PSD$( $_[1] ).psm1" } )
                    "<Copy source='%DEPLOYROOT%\Tools\Modules\PSD$( $_[1] )\$z' dest='Deploy\Tools\Modules\PSD$( $_[1] )\$Z' />" } ; "" , "  </Content>" , "" , 
            
                "<!-- Exits -->" , "<Exits>" , "  <Exit>cscript.exe '%INSTALLDIR%\Samples\UpdateExit.vbs'</Exit>" , "</Exits>" , "" , "  </WindowsPE>" , "</Definition>" )

        $XML.Add( "02" , @( 0..21 | % { $X[$_] + $Y[$_] } ) )
    }

    $Return = ""
    ForEach ( $i in 0..2 ) { $XML[$I] | % { $Return += "$_`n" } }

    Return $Return.Replace( "'" , '"' )
}
