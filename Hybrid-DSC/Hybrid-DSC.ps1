
    $Reg = ( gci *Hybrid-DSC.ps1* ).Directory.FullName

    $Mod  = $ENV:PSModulePath.Split( ';' ) | ? { $_ -like "*$Env:UserName\Documents*" }
        
    $Mod , "$Mod\Hybrid-DSC" | % { 

        If ( ! ( Test-Path $_ ) ) { NI $_ -ItemType Directory ; Write-Host "   Created [+] $_" -F 11 }
        Else { Write-Host "  Detected [-] $_" -F 14 }
        
    }
    If ( $? ) { $Clean = GCI "$Mod\Hybrid-DSC" }
    
    
    "Hybrid-DSC" | % { 
        
        If ( Test-Path "$Reg\$_.zip" ) 
        {
            Write-Host "Retrieving [~] $Reg\$_.zip" -F 14

            $Splat = @{ Path            = "$Reg\$_.zip"
                        DestinationPath = "$Mod\$_"     }

            Write-Host "Extracting [~] $Mod\$_" -F 14

            Expand-Archive @Splat
        }

        IPMO Hybrid-DSC -Force
    }