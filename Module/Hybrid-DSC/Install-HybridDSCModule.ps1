    Function Get-ScriptDirectory 
    
    Function Install-HybridDSCModule
    {
        $Path  = $env:USERPROFILE
        $Tree  = "Documents\WindowsPowerShell\Modules\Hybrid-DSC"
        $Split = $Tree.Split( '\' )

        ForEach ( $I in 0..( $Split.Count - 1 ) ) 
        {
            "$Path\$( $Split[$I] )" | % {

                If ( ! ( Test-Path $_ ) )
                {
                    NI $_ -ItemType Directory | Out-Null
                    Write-Host "   Created [+] $_" -F 11
                }

                Else 
                {
                    Write-Host "  Detected [~] $_" -F 14
                }

                $Path = $_
            }
        }

        $Destination = $Path

        GCI $Destination | % { 
        
            If ( $_ -ne $Null ) 
            { 
                Write-Host " Detected [!] $( $_.Name ), removing" -F 11 
                RI $_.FullName -Recurse -Force 
            }
        }

        $Source = Get-ScriptDirectory
    
        "Hybrid-DSC" | % { 
        
            If ( Test-Path "$Source\$_.zip" ) 
            {
                Write-Host "Extracting [~] $Destination\$_" -F 14

                Expand-Archive "$Source\$_.zip" "$Destination" -VB
            }

            Else
            {
                Write-Host " Exception [!] Zip file not found"
            }
        }

        "Graphics" , "Control" , "Map" | % { 

            Write-Host "Extracting [~] $Destination\$_.zip" -F 11

            Expand-Archive "$Destination\$_.zip" $Destination
        }
    
        IPMO Hybrid-DSC -Force
    }

    Install-HybridDSCModule