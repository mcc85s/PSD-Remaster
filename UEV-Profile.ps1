
Using Namespace System.Security.Principal ;
Using Namespace System.IO.Compression.FileSystem ;

# - [ This script is nowhere even close to functional ] - #

# - [ Looking to refine the registry controls below and perform a complete ] - #
# - [ UEV-Profile and Application Migration without using USMT ] - - - - - - - #
# - [ You can do some manner of these things with various sofware out there, - #
# - [ but that costs money. Nobody has built a 100% free version of PCMover  - #
# - [ that doesn't suck or costs money. What I mean by 'doesn't suck', what I  #
# - [ mean is, if you pay for a product that 'doesn't really work' or 'causes -#
# - [ problems afterward, well, what exactly did you pay for?

# - [ Not to mention... if you have a problem on your machine, PCMover will go #
# - [ ahead and copy that problem over to your new installation! - - - - - - - #

# - [ ...rendering the fresh installation completely pointless... AND the $$$$ #
# - [ that you spent on it. Anyway, I'm working on a lot more than what's in - #
# - [ this script... this piece will perform a pre-flight UEV-Export, and a  - #
# - [ post-flight export of a dynamic driver library that will load in PXE, so #
# - [ you won't need to install them after your machine starts up for the - -  #
# - [ first time. I've done the work thousands of times for clients, I've done #
# - [ the work hundreds of times for myself, I have a very good idea of how to #
# - [ build this process... the hardest part is challenging myself to 'make' - #
# - [ all of these functions with my own research and testing. That means, I - #
# - [ don't pay a dime for anything that I use. It's all free software.  - - - #

$ID = [ WindowsIdentity ]::GetCurrent() 
$AC = [ Ordered ]@{ 
                    Name = $ENV:Username 
                FullName = $ID.Name 
       SecurityIdentifer = $ID.User.Value 
                    Path = $Home } 


( $HKU , $HKCR ) = ( "HKU" , "HKCR" | % { GDR -PSProvider Registry -Name $_ -EA 0 } )
If ( $HKU  -eq $Null ) {  $HKU = NDR -PSProvider Registry -Name HKU  -Root HKEY_USERS }
If ( $HKCR -eq $Null ) { $HKCR = NDR -PSProvider Registry -Name HKCR -Root HKEY_CLASSES_ROOT }

# - [ Main Hive ] - - - - - - - - - - - - - - #
$Hive   = ( GCI "HKLM:\BCD00000000\Objects" -EA 0 -Recurse ) | ? { $_.PSIsContainer -eq $True } 
$D = '"'

$R = @( 
$h = 0
do
{
    $i = $Hive[$h]
    # - [ Parent Containers ] - #
    $PSPath  = $i.PSPath
    $Path    = ( $i.PSPath ).Replace('Microsoft.PowerShell.Core\','')
    # - [ Output Parent Info ] - #
    Echo "[$( $Path.Replace('Registry::','') )]"


    Foreach ( $j in $i.PSChildName )
    {
        $Name    = $j
        $Type    = $J.Property
        $Value   = ( gp $J.PSPath | Select -Property $Type )
        $DWORD   = ("$( ( gi $Path ).GetValueKind( "$Type" ) ):").ToLower()

    Echo "$D$( $Type )$D=$D$DWORD$D"
    Read-Host "Lookin good?"
}
until ( $h -ge $Hive.Count ) )

    $Output = 
    "[$( $Path.Replace('Registry::','') )]
    $D$( $Type )$D=$D$DWORD$D"

    gp $Path\$Type

    
    $PSPath

    $i | Select PSPath , PSChildname , Property
    $j = 
    $j = $i.ChildName
    ( $i , $j , $k , $p ) = ( $Hive.PSChildName [$h] , $i.PSChildName , $i.Property , $i.PSPath )
    Echo "[$i]"
    
    $l = gp $p | Select -Property $k
    $j = $Hive.PSChildName[$h]
    $j.Count -gt 1
        | ? { $_.Count -gt 1 }
            $k = gci "Registry::$J"
            $k | ? { $_.Name.Count -gt 1
            {
                $l = gv 
    }





    ( gi $P ).PSChildName






          $Hive[$i]        
              $Items[$i] | ? { $_.Count -gt 0 } | % { gci  
                
                $Tree = gci "Registry::$( $Root[1] )"
                $Tree | ? { ! $_.Exists } | % { echo "Exists" }
                If ( gci "Registry::$( $Root[0] )" ? { $_.Count -gt 1 }

           $GI   =  gci "Registry::$( $Root[1] )"
           $GCI  =   gi "Registry::$( $Root[1] )"
                ( ( gv ( gi "Registry::$( $Root[1] )" ).Property[$j] ).Value[$k] ).Element




    $Items  = Foreach ( $i in 0..$L1 ) { ( $Hive[$i] ).SubKeyCount }
    $Leaf   = Foreach ( $i in 0..$L1 ) { ( $Hive[$i] ).GetValue() }
    $Branch = Foreach ( $i in 0..$L1 ) { ( gi "$( $Tree[$i] )" ).Property }     #
    $Leaf   = Foreach ( $i in 0..$L1 ) { gp -Path "Registry::$( $Tree[$i] )" }        #
    
$L1 | % { "- - - - - - " * 12 ; 
          "  Registry Output Path : [$( $Root[$_] )]" ; 
          "                Folder : $( $Tree[$_] )"   ; 
          "                   Key : $( $Trunk[$_] )"  ; 
          "              Property : $( $Branch[$_] )" }
