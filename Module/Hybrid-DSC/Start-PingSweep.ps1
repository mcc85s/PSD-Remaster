    Function Start-PingSweep  # Gets actual used network host addresses _________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        Write-Theme -Action "Scanning [~]" "Network Host Range"

        $Stopwatch = [ System.Diagnostics.Stopwatch ]::StartNew()
        
        $NW        = Get-NetworkInfo -LocalHost
        $HR        = @( )
        $PF        = $NW.Prefix
        $Range     = $NW | % { $_.Start , $_.End } | % { $_.Replace( "$PF." , "" ) }
        $Start     = $Range[0]
        $End       = $Range[1]

        $HostRange = $Start..$End | % { "$PF.$_" }

        $Return    = @{ Success = @( ) ; Failure = @( ) }

        $Report    = @( )

        ForEach ( $I in $HostRange )
        {
            IEX "Using Namespace System.Net.NetworkInformation"
            $B = @( 1..9 + "abcdef".ToCharArray() | % { "0x6$_" } ; 0..7 | % { "0x7$_" } ; 1..9 | % { "0x6$_" } ) # < - Condensed version of Test-ConnectionAsync by Boe Prox
            New-Object PingOptions | % { $O = $_ ; $_.TTL = 128 ; $_.DontFragment = $False }
            $Report += ( New-Object Ping ).SendPingAsync( $I , 100 , $B , $O )
        }

        $Report.Result | ? { $_.Status -eq "Success" }   | % { $Return.Success += $_.Address.ToString() }

        $HostRange     | ? { $_ -notin $Return.Success } | % { $Return.Failure += $_ }

        $Stopwatch.Stop()

        Write-Theme -Action "Complete [+]" "$( $Stopwatch.Elapsed ) / Hosts Found : [$( $Return.Success.Count )]"

        Return $Return
                                                                                     #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}