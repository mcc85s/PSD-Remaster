    Function Initialize-PortScan # This will scan every port you tell it to _____________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding () ] Param ( 
    
            [ ValidateNotNullOrEmpty () ] [ Parameter ( Position = 0 ) ][    Int ] $Port = 80 ,
            [ ValidateNotNullOrEmpty () ] [ Parameter ( Position = 1 ) ][ Switch ] $Return    )

        $Collection = Start-PingSweep ; $S = $Collection.Success ; $C = $S.Count ; $Report = 0..( $C - 1 )

        ForEach ( $A in 0..( $C - 1 ) )
        {
            Write-Progress -Activity "Scanning Network $( $S[$A] )" -PercentComplete ( ( $A / $C ) * 100 )

            If ( ( Test-Connection –BufferSize 32 –Count 1 –Quiet –ComputerName $S[$A] -EA 0 ) -ne $Null )
            {
                Try 
                { 
                    New-Object System.Net.Sockets.TcpClient -Args ( $S[$A] , $Port ) -EA 0 | % { 
                    $Report[$A] = [ PSCustomObject ]@{ ID = $A ; IPAddress = $S[$A] ; Client = $_.Client ; Connected = $_.Connected } }
                }
                
                Catch 
                {
                    [ Void ]$_.Exception.Message
                    $Report[$A] = [ PSCustomObject ]@{ ID = $A ; IPAddress = $S[$A] ; Connected = "False" }
                }
            }
        }

        If ( $Return ) 
        { 
            Return $Report.Client | FT -AutoSize 
        }
        
        Else 
        { 
            Return $Report 
        }                                                                            #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}