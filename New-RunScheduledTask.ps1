
[ CmdLetBinding () ] Param (

    [ Parameter ( Mandatory = $True ) ] [ String ] $Path ,
    [ Parameter ( Mandatory = $True ) ] [ String ] $Name ,
    [ Parameter ( Mandatory = $True ) ] [ String ] $Info ,
    [ Parameter ( Mandatory = $True ) ] [    Int ] $Lead = 15 )

        $Time = "Y,m,d,H,M,S".Split( ',' ) | % { [ Int ]( Get-Date -UFormat "%$_" ) }

        $Time[3] = Get-TimeZone | % { [ Int ] $_.BaseUTCOffSet.Hours } | % { 
            
            Return $Time[3] + $( If ( $_ -lt 0 ) { ( $_..0 ).Length - 1 } If ( $_ -eq 0 ) { 0 } If ($_ -gt 0 ) { ( 0..$X ).Length - 1 } )
        }

        $LY  = [ Int ]( 29 , 28 , 28 , 28 )[ $Time[0] % 4 ]
        $Y   = $Time[0]
        $MO  = $Time[1]
        $DIM = ( 30 , 31 , $LY )[ 1 , 2 , 1 , 0 , 1 , 0 , 1 , 1 , 0 , 1 , 0 , 1 ][ $Time[1] ]
        $D   = $Time[2]
        $H   = $Time[3]
        $MI  = $Time[4]
        $SE  = $Time[5] + $Lead

        $SE | % { If ( $_ -notin   0..59 ) { $SE = $_ -   60 ; $MI = $MI + 1 } }
        $MI | % { If ( $_ -notin   0..59 ) { $MI = $_ -   60 ; $H  = $H  + 1 } }
        $H  | % { If ( $_ -notin   0..23 ) { $H  = $_ -   24 ; $D  = $D  + 1 } }
        $D  | % { If ( $_ -notin 1..$DIM ) { $D  = $_ - $DIM ; $MO = $MO + 1 } }
        $MO | % { If ( $_ -notin   1..12 ) { $MO = $_ -   12 ; $Y  = $Y  + 1 } }
        
        If ( $MO -lt 10 ) { $MO = "0$MO" }
        If ( $D  -lt 10 ) { $D  =  "0$D" }
        If ( $H  -lt 10 ) { $H  =  "0$H" }
        If ( $MI -lt 10 ) { $MI = "0$MI" }
        If ( $SE -lt 10 ) { $SE = "0$SE" }

        "$Y-$MO-$D`T$H`:$MI`:$SE`Z"

    $Action   = @{ Execute  = "PowerShell"
                   Argument = $Path }

    $Trigger  = @{ Once     = $True
                   At       = "$Y-$MO-$D`T$H`:$MI`:$SE`Z" }

    $Task     = @{ Action      = New-ScheduledTaskAction @Action
                   Trigger     = New-ScheduledTaskTrigger @Trigger
                   TaskName    = $Name
                   Description = $Info }

    Register-ScheduledTask $Task
