# https://docs.microsoft.com/en-us/windows/security/identity-protection/credential-guard/credential-guard-manage    

$CTRL = "HKLM:\System\CurrentControlSet\Control"

    ( "EnableVirtualizationBasedSecurity" , 1 ) , ( "RequirePlatformSecurityFeatures" , 3 ) | % {

        SP -Path "$CTRL\DeviceGuard" -Name $_[0] -Value $_[1]

    }

        SP -Path "$CTRL\LSA" -Name "LsaCfgFlags" -Value 1
        
