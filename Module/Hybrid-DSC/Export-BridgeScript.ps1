    Function Export-BridgeScript # Exports the bridge script ___________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        Resolve-HybridDSC -Domain | % { 
    
            $NetBIOS    = $_.NetBIOS
            $DNS        = $_.Branch
            $Domain     = $_.Domain 
        }

        $Root = Resolve-HybridDSC -Share 
        
        $Root | % {

            $Company    = $_.Company 
            $Server     = $_.Server
            $Drive      = $_.DSDrive.Replace( ":" , "" )
            $DeployRoot = "\\$Server\$( $_.Samba )"
            $HybridRoot = "$DeployRoot\$( $_.Company )"
        }

        If ( $Domain )
        {
            Write-Theme -Action "Detected [+]" "Domain Environment, loading ADDS Login"

            $DCCred = Invoke-Login -DC ( $Root.Server ) -Domain $DNS
        }

        If ( ! $Domain )
        {
            Write-Theme -Action "Detected [+]" "Workgroup Environment, loading Local User Login"
            
            Do
            {
                Add-Type -AssemblyName System.DirectoryServices.AccountManagement

                $DCCred = Get-Credential
        
                $X      = $DCCred | % { Get-LocalUser -Name $_.UserName -EA 0 }
        
                $Y      = [ System.DirectoryServices.AccountManagement.PrincipalContext ]::New( "Machine" , $ENV:ComputerName ) | % { 
        
                    $_.ValidateCredentials( $DCCred.UserName , $DCCred.GetNetworkCredential().Password ) | ? { $True }
                
                }

                If ( ( $X -eq $Null ) -or ( $X.Enabled -ne $True ) -or ( $Y -eq $False ) )
                {
                    Switch( $Host.UI.PromptForChoice( "Invalid Credential" , "Attempt login again?" , 
                    [ System.Management.Automation.Host.ChoiceDescription [] ]@( "&Yes" , "&No" ) , [ Int ] 0 ) )
                    {
                        0 { $DCCred = $Null } 1 { $Exit = 1 }
                    }
                }
        
                Else
                {
                    Return $DCCred
                }
            }

            Until ( ( $DCCred -ne $Null ) -or ( $Exit -eq 1 ) )
        }

        $RootVar         = [ PSCustomObject ]@{
            Company      = $Company
            NetworkShare = $DeployRoot
            DSDrive      = $Drive
            Description  = $Root.Description
            Server       = $Server
            DomainUser   = $DCCred.UserName
            DomainPass   = $DCCred.GetNetworkCredential().Password
            Website      = $Root.WWW
            Phone        = $Root.Phone
            Hours        = $Root.Hours
            Logo         = GCI $HybridRoot "*$( $Root.Logo.Split('\')[-1] )*" -Recurse | % { $_.FullName }
            Background   = GCI $HybridRoot "*$( $Root.Background.Split('\')[-1] )*" -Recurse | % { $_.FullName }
            Certificate  = ""
            Domain       = $DNS
            LocalUser    = $Root.LMCred_User
            LocalPass    = $Root.LMCred_Pass
            Proxy        = $Root.IIS_Proxy
            NetBIOS      = $NetBIOS
            Directory    = $Root.Directory
        }

        SC "$DeployRoot\root.txt" -Value ( $RootVar | ConvertTo-JSON )
        SC "$Env:AppData\root.txt" -Value ( $RootVar | ConvertTo-JSON )

        <# Variables #> # $DeployRoot\root.txt
        <#    Script #> # $DeployRoot\Scripts\Initialize-Hybrid.ps1
        <#     Timer #> # $DeployRoot\Scripts\New-RunScheduledTask.ps1

        $Return = @"
       
        `$DeployRoot   = "$( $Rootvar.NetworkShare )"
        `$Root         = '$( GC "$DeployRoot\root.txt" )' | ConvertFrom-JSON
        `$Company      = "$( $Root.Company )"
        `$Timer , `$Hybrid = "New-RunScheduledTask" , "Initialize-Hybrid" | % {

            "`$DeployRoot\Scripts\`$_.ps1"
        }
        
        CP "`$DeployRoot\root.txt" "`$Env:AppData\root.txt"

        SAPS PowerShell -Verb RunAs -ArgumentList "-File `$Timer -Args -Path `$Hybrid"
"@

        SC "$DeployRoot\Scripts\Import-BridgeScript.ps1" $Return -Force -VB         #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}