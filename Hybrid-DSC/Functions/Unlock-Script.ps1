    Function Unlock-Script # Allows for elevation ( Not Finished ) _____________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        $CS = GCIM Win32_OperatingSystem
        IEX "Using Namespace System.Security.Principal"
        "Windows" | % { IEX "( [ $_`Principal ] [ $_`Identity ]::GetCurrent() ).IsInRole( 'Administrator' )" } | % {
        
            If ( ( ( $_ -eq $False ) -and ( $CS | % { [ Int ]$_.BuildNumber -gt 6000 } ) ) -or ( $_ -eq $True ) )
            {
                $MyInvocation | % { SAPS PowerShell -Verb RunAs -Args "-File $( $_.PSCommandPath ) $( $_.UnboundArguments )" }
                Set-ExecutionPolicy ByPass -Scope Process -Force
            }

            Else { Read-Host "[!] Access Failed. Press Enter to Exit" ; Exit }
        }                                                                           #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}