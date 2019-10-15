
Using Namespace System.Security.Principal ;
Using Namespace System.IO.Compression.FileSystem ;

$ID = [ WindowsIdentity ]::GetCurrent() 
$AC = [ Ordered ]@{ 
                    Name = $ENV:Username 
                FullName = $ID.Name 
       SecurityIdentifer = $ID.User.Value 
                    Path = $Home } 










( $HKU , $HKCR , $HKLM , $HKCU ) = ( "HKU" , "HKCR" , "HKLM" , "HKCR" | % { GDR -PSProvider Registry -Name $_ -EA 0 } )
If ( $HKU  -eq $Null ) {  $HKU = NDR -PSProvider Registry -Name HKU  -Root HKEY_USERS }
If ( $HKCR -eq $Null ) { $HKCR = NDR -PSProvider Registry -Name HKCR -Root HKEY_CLASSES_ROOT }

# - [ Main Hive ] - - - - - - - - - - - - - - #
$Hive   = ( GCI "Registry::$HKLM" -EA 0 -Recurse ) | ? { $_.PSIsContainer -eq $True } | Select PSParentPath 
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



            ForEach ( $i in 0..5 )
            {
                $R = $Root[$i]
                $P = $Path[$i]
                $C = $Path[$i].Count
                $F = $File[$i]
                $D = $File[$i].Count
                If ( ( $C -gt 1 ) -or ( $D -gt 1 ) )
                {
                    If ( $C -gt 1 )
                    {
                        ForEach ( $j in ( 0..( $C - 1 ) ) )
                        { 
                            "$R\($j)$( $p[$j] )" | ? { ( Test-Path $_ ) -eq $False } | % { NI -Path $_ -ItemType Directory }
                        }
                    }
                    If ( $D -gt 1 )
                    {
                        $Dir = $R
                        ForEach ( $k in ( 0..( $D - 1 ) ) )
                        {
                            $F[$k] | ? { ( Test-Path "$R\$_" ) -eq $False } | % { Robocopy "$( $Inst[$i] )" $R "$_" }
                        }
                    }
                }
            }