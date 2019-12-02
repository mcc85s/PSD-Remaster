    Function Resolve-HybridDSC # Module Root Path Delcaration __________________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        [ CmdLetBinding ( ) ] Param (

            [ Parameter ( ParameterSetName =   "Module" ) ] [ Switch ] $Module   ,
            [ Parameter ( ParameterSetName =     "Root" ) ] [ Switch ] $Root     ,
            [ Parameter ( ParameterSetName =    "Share" ) ] [ Switch ] $Share    ,
            [ Parameter ( ParameterSetName =   "Domain" ) ] [ Switch ] $Domain   ,
            [ Parameter ( ParameterSetName = "Graphics" ) ] [ Switch ] $Graphics )

        $Author = "Secure Digits Plus LLC"

        $Main   = $ENV:PSModulePath.Split( ';' ) | ? { GCI $_ -Recurse "*Hybrid-DSC*" } | % { "$_\Hybrid-DSC" }

        If ( $Module ) # Returns the default module path
        {
            $Main | % { 
            
                If ( $_ -eq $Null ) 
                { 
                    Write-Theme -Action "Exception [!]" "Hybrid-DSC Module Resources Missing"
                }
            
                If ( $_ -ne $Null )
                {
                    $Return = $Main
                }
            }
        }

        If ( ( $Root ) -or ( $Share ) ) # Returns Registry Keys / Path, will also install tools if missing
        {
            "HKLM:\Software\Policies" | % { 
            
                If ( ! ( Test-Path "$_\$Author" ) ) 
                { 
                    NI $_ -Name $Author 
                }
                
                $Tree = "$_\$Author" 
            }

            GP $Tree | % { 
            
                If ( $_ -eq $Null )
                {
                    Install-DSCRoot
                }

                $Return = @{ Root = $Tree
                             Tree = $_."Hybrid-DSC"
                             Date = $_."Installation Date" }
            }

            If ( $Root ) # Returns the root Hybrid-DSC keys
            {   
                Return $Return
            }

            If ( $Share ) # Returns a Hybrid-DSC share information from registry/installs deployment share
            {
                $Tree = $Return | % { $_.Root , "Hybrid-DSC" -join '\' }
                
                Test-Path $Tree | % { 
                
                    If ( $_ -ne $True ) 
                    {
                        Install-HybridDSC -Test
                    }
                }

                $Child = GCI $Tree |  % { $_.PSChildName }
            
                If ( $Child.Count -gt 1 )
                {
                    Write-Theme -Action "Option [~]" "Multiple Companies Found"

                    $C       = 0..( $Child.Count - 1 )
                    $Options = $C | % { "`n[$_] $( $Child[$_] )" }

                    Do
                    {
                        $Selection = Read-Host -Prompt @( "Select # of Company" ; $Options )
                        
                        If ( $Selection -notin $C ) { Echo "Not a valid option" }
                        If ( $Selection    -in $C ) { $Child = $Child[$Selection] }
                    }

                    Until ( $Child.Count -eq 1 )
                }
   
                $Provision = GCI "$Tree\$Child" | % { $_.PSChildName }
            
                If ( $Provision.Count -gt 1 )
                {
                    Write-Theme -Action "Option [~]" "Multiple Drives Found"

                    $C       = 0..( $Provision.Count - 1 )
                    $Options = $C | % { "`n[$_] $( $Provision[$_] )" }

                    Do
                    {
                        $Selection = Read-Host -Prompt @( "Select # of Drive" ; $Options )
                        
                        If ( $Selection -notin $C ) { Echo "Not a valid option" }
                        If ( $Selection    -in $C ) { $Provision = $Provision[$Selection] }
                    }

                    Until ( $Provision.Count -eq 1 )
                }

                $Path     = "$Tree\$Child\$Provision"

                $Property = GI $Path | % { $_.Property }

                $Return   = [ PSCustomObject ]@{ }

                $List     = GP $Path 

                $Property | % { $Return | Add-Member -MemberType NoteProperty -Name $_ -Value $List.$_ }

            }
        }

        If ( $Domain )
        {
            $CS = gcim Win32_ComputerSystem
            
            $Return = [ PSCustomObject ]@{ NetBIOS = "" ; Branch = "" ; Domain = "" }

            If ( $CS.PartOfDomain -eq $True )
            {
                $Return | % {     
                    $_.NetBIOS = $ENV:UserDomain
                    $_.Branch  = $ENV:USERDNSDOMAIN
                    $_.Domain  = $True
                }
            }

            If ( $CS.PartOfDomain -eq $False )
            {
                $NBT = nbtstat -n | ? { $_ -like "*REGISTERED*" } | % { 

                    [ PSCustomObject ]@{ 
                        Name   = ( $_[ 0..18] | ? { $_ -ne " " } ) -join '' 
                        ID     = ( $_[19..22] | ? { $_ -ne " " } ) -join '' 
                        Type   = ( $_[24..34] | ? { $_ -ne " " } ) -join '' 
                        Status = ( $_[35..50] | ? { $_ -ne " " } ) -join '' 
                    }
                }
            
                $NBID  = $NBT | ? { $_ -like  "*GROUP*" -and $_ -like "*<00>*" }
                If ( $NBID.Count -gt 1 ) {  $NBID =  $NBID[0] } Else { }

                $CNAME = $NBT | ? { $_ -like "*UNIQUE*" -and $_ -like "*<00>*" }
                If ( $NBID.Count -gt 1 ) { $CNAME = $CNAME[0] } Else { }
                
                $Return | % {

                    $_.NetBIOS = $NBID
                    $_.Branch  = $CNAME
                    $_.Domain  = $False 
                }
            }
        }

        If ( $Graphics )
        {
            $Items = "background.jpg" , "banner.png" , "oembg.jpg" , "icon.ico" , "oemlogo.bmp" | % { GCI $Main -Recurse "*$_*" | % { $_.FullName } }
            
            $Return = [ PSCustomObject ]@{ 

                Author     = $Author
                Title      = "$Author | Hybrid-DSC"
                Background = $Items[0]
                Banner     = $Items[1]
                Brand      = $Items[2]
                Icon       = $Items[3]
                Logo       = $Items[4]
            }
        }

        Return $Return
                                                                                    #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}