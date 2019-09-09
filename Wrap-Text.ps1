
    $Z = "  " , "¯-" , "-_" | % { $_ * 54 }

    $S = " // " , " \\ "

    $H = "- " , " -"

    $L , $R = $S[0..1] , $S[1..0]
    
    $LI = 0..1 | % { $L[$_] + $Z[0] + $R[$_] }

    $Title = "Provisional Root"

    $Index = 0..2

    $Hash  = [ PSCustomObject ]@{ Title = $Title ; Index = $Index }

    $Index[0] = [ Ordered ]@{
    
        Name  = "( Desired State Controller @ Source )"

        Items = [ Ordered ]@{
          
            "Provisionary"     = "Secure Digits Plus LLC"
            "(DSC) Share"      = "\\DSC2\Secured$"
            "(DSC) Controller" = "DSC0"
            "Resources"        = "C:\Secured\Secure Digits Plus LLC\(0)Resources"
            "Tools / Drivers"  = "C:\Secured\Secure Digits Plus LLC\(1)Tools"
            "Images"           = "C:\Secured\Secure Digits Plus LLC\(2)Images"
            "Profiles"         = "C:\Secured\Secure Digits Plus LLC\(3)Profiles"
            "Certificates"     = "C:\Secured\Secure Digits Plus LLC\(4)Certificates"
            "Applications"     = "C:\Secured\Secure Digits Plus LLC\(5)Applications"

        }
    }
                       
    $Index[1] = [ Ordered ]@{ 

        Name  = "( Current Machine @ Variables )"

        Items = [ Ordered ]@{

            "(DSC) Host"       = "Yes"
            "Current Hostname" = "DSC0"
            "CPU Architecture" = "AMD64"
            "System Drive"     = "C:\"
            "Windows Root"     = "C:\Windows"
            "System32"         = "C:\Windows\System32"
            "Program Data"     = "C:\ProgramData"
        }
    }

    $Index[2] = [ Ordered ]@{ 
    
        Name = "( Provision Index @ Bridge Control )"
        
        Items = [ Ordered ]@{
            
            "(DSC) Target"     = "DSC0"
            "Resources"        = "C:\Secure Digits Plus LLC\(0)Resources"
            "Tools / Drivers"  = "C:\Secure Digits Plus LLC\(1)Tools"
            "Images"           = "C:\Secure Digits Plus LLC\(2)Images"
            "Profiles"         = "C:\Secure Digits Plus LLC\(3)Profiles"
            "Certificates"     = "C:\Secure Digits Plus LLC\(4)Certificates"
            "Applications"     = "C:\Secure Digits Plus LLC\(5)Applications"
        }
    }

# ____                                                                            ____________________________________________________________________
#//¯¯\\__________________________________________________________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\
#\\__//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//
#    \\________________[ Title ]_________________________________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\
#     ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    $Array = @( )
    $C = $Null
    $Name = $Null

    $H  = "[ $( $Hash.Title.Replace( ' ' , '-' ) ) ]" 
    $T  = $TT | % { "$H" , "$H-" , "$H " , " $H -"  }
    $U  = 108 - $TT.Length
    $V  = $U % 4 
    $W  = ( $U - $V ) / 4 
    $TL = "_¯" * $W 
    $TR = "¯_" * $W 

    $Array += " // $TL$( $T[$V] )$TR \\ " , $LI[1]

    ForEach ( $i in $Hash.Index )
    {
        If ( $Hash.Index.Count -gt 1 )
        {
            If ( $C -ne $Null ) { $C = $C + 1 }
            If ( ( $C -eq $Null ) -and ( $Name -eq $Null ) ) { $C = 0 }

            $Name = $Hash.Index.Name[$C]
            $Item = $Hash.Index.Items[$C]
        }

        If ( $Hash.Index.Count -eq 1 )
        {
            $Name = $Hash.Index.Name
            $Item = $Hash.Index.Items
        }

        $U = 98 - $Name.Length
        $V = $C % 2 
        $W = ( 1 - $V )
        $IS = $LI[$V]
        $LL = $L[$W] + ( "-" * 10 ) + $Name + ( "-" * $U ) + $R[$W]
        
        $IS , $LL , $IS | % { $Array += $_ }

            $IC = $Item.Count
            
            If ( $IC -gt 1 ) 
            {
                $IC = $IC - 1
                $IK = @( $Item.Keys )
                $IV = @( $Item.Values )

                ForEach ( $Q in 0..$IC )
                {
                    $V = $Q % 2
                    $W = ( 1 - $V )
                    $Key = $IK[$Q] | % { "$( " " * ( 25 - $_.Length ) )$_" }
                    $Val = $IV[$Q] | % { "$_$( " " * ( 80 - $IV[$Q].Length ) )" }

                    $Array += "$( $L[$W] )$Key : $Val$( $R[$W] )"
                }
                
                If ( $IC % 2 -ne 1 )
                {
                    $Array += $LI[$V]
                }
            }

            If ( $IC -eq 1 )
            {
                $Key = $Item.Keys   | % { "$( " " * ( 25 - $_.Length ) )$_" }
                $Val = $Item.Values | % { "$_$( " " * ( 80 - $IV[$Q].Length ) )" }
                $Array += "$( $L[$V] )$Key : $Val$( $R[$V] )" , $LI[$W]
            }

        If ( $C -eq $I.Count ) { Break }
    }
    
    Wrap-Text -Top
    Echo $Array
    Wrap-Text -Bot
