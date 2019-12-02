    Function Resolve-LocalMachine # Turns local machine information into an object _____//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        $Local = @( $Env:ComputerName , $Env:Processor_Architecture , "$Env:SystemDrive\" ; $Env:SystemRoot | % { "$_" , "$_\System32" } ; 
        $Env:ProgramData , $Env:ProgramFiles )
        
        Return [ PSCustomObject ]@{ 
            
            ComputerName  = $Local[0]
            Architecture  = $Local[1]
            SystemDrive   = $Local[2]
            SystemRoot    = $Local[3]
            System32      = $Local[4]
            ProgramData   = $Local[5]
            ProgramFiles  = $Local[6]
        }                                                                           #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}