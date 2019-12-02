    Function Install-DSCRoot # Provisioned installation of Hybrid-DSC __________________//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯\\__//¯¯¯  
    {#/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯ -- ¯¯¯¯    ¯¯¯¯      
        
        $GUI = Get-XAML -DSCRoot | % { Convert-XAMLToWindow -XAML $_ -NE ( Find-XAMLNamedElements -Xaml $_ ) -PassThru }

        $GUI.Cancel.Add_Click({ $GUI.DialogResult = $False })

        $GUI.Start.Add_Click({ 

            If ( $GUI.Install.Text -eq "" ) 
            { 
                "Installation Location" | % { Show-Message -Title "$_ Missing" -Message "You must enter a $_" } 
            }   
            
            Else                            { $GUI.DialogResult = $True }
        })

        $OP = Show-WPFWindow -GUI $GUI

        $Null = $GUI.Install.Focus()

        If ( $OP -eq $True )
        {
            $Root = @{ Base     = $GUI.Install.Text
                       Registry = "HKLM:\SOFTWARE\Policies"
                       Vendor   = "Secure Digits Plus LLC" 
                       Date     = Get-Date }
            
            If ( ! ( Test-Path $Root.Base ) )
            {
                NI $Root.Base -ItemType Directory

                Write-Theme -Action "Created [+]" "Installation Directory"
            }

            If ( Test-Path $Root.Base )
            {
                Write-Theme -Action "Detected [+]" "Installation Directory"
            }

            Start $Root.Base

            Sleep -M 100
            
            $Base = "$( $Root.Registry )\$($Root.Vendor )" 
            
            $Base | % { If ( Test-Path $_ ) { RI $_ } }

            Write-Theme -Action "Creating [~]" "Registry Entry for Installation Path"

            NI -Path $Root.Registry -Name $Root.Vendor 

            $Set = @{ Path  = $Base
                      Name  = "Hybrid-DSC"
                      Value = $Root.Base      }

            SP @Set
                
            Write-Theme -Action "Created [+]" "$( $Set.Name )"

            $Set = @{ Path  = $Base
                      Name  = "Installation Date"
                      Value = $Root.Date      }    
            
            SP @Set

            Write-Theme -Action "Created [+]" "$( $Set.Name )"

            Write-Theme -Action "Installing [~]" "Hybrid-DSC Root Structure"

            "Hybrid" , "Libraries" , "Scripts" , "Templates" , "Install" | % { 
            
                "$( $Root.Base )\$_" | % { If ( ( Test-Path $_ ) -ne $True ) { NI $_ -ItemType Directory } Else { GI $_ } }
            }

            $ENV:PSModulePath.Split( ';' ) | ? { GCI $_ -Recurse "*Hybrid-DSC*" } | % { "$_\Hybrid-DSC" } | % { 

                ForEach ( $I in "Graphics" , "Map" , "Control" )
                {
                    "$_\$I.zip" | % { Expand-Archive -Path $_ -DestinationPath "$( $Root.Base )\Hybrid" }
                }
            }

            $Registry     = Resolve-UninstallList

            $Base         = "$( $Root.Base )\Tools" | % { If ( ( Test-Path $_ ) -ne $True ) { NI $_ -ItemType Directory } Else { GI $_ } } | % { $_.FullName }

            $MDTFile      = "MicrosoftDeploymentToolkit_x$( If ( $env:PROCESSOR_ARCHITECTURE -eq "x86" ) { 86 } Else { 64 } ).msi"

            $Pull         = [ Ordered ]@{ }

            # [ Windows ADK ] - The Awesome Deployment Kit. That's what ADK means. Really.

            $Pull.Add( 0 , @(                                                    "Deployment Kit - Windows 10" ,
                                                                                                "10.1.17763.1" ,
                                                                                                      "WinADK" ,
                                                                       "Windows Assessment and Deployment Kit" ,
                                                                                                "$Base\WinADK" ,
                                                                                              "winadk1903.exe" ,
                                                             "https://go.microsoft.com/fwlink/?linkid=2086042" ,
                                                    "/quiet /norestart /log $env:temp\win_adk.log /features +" ) ) # ~ 2m

            # [ Windows PE ] - The Pain-in-the-ass Environment...

            $Pull.Add( 1 , @(                                                                "Preinstallation" ,
                                                                                                "10.1.17763.1" ,
                                                                                                       "WinPE" ,
                                                                     "Windows ADK Preinstallation Environment" ,
                                                                                                 "$Base\WinPE" ,
                                                                                               "winpe1903.exe" ,
                                                             "https://go.microsoft.com/fwlink/?linkid=2087112" ,
                                                    "/quiet /norestart /log $env:temp\win_adk.log /features +" ) ) # ~ 10m

            # Microsoft Deployment Toolkit

            $Pull.Add( 2 , @(                                                                "Deployment Tool" ,
                                                                                               "6.3.8450.0000" ,
                                                                                                         "MDT" ,
                                                                                "Microsoft Deployment Toolkit" ,
                                                                                                   "$Base\MDT" ,
                                                                                                    "$MDTFile" ,
                 "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/$MDTFile" ,
                                                                                           "/quiet /norestart" ) ) # ~  4s
            $ETA = "2m" , "10m" , "4s" | % { "Estimated Time [~] $_" }
        
            Write-Theme -Action "Querying [~]" "Registry for installed applications"

            0..2      | % {

                $X    = $Pull[$_]

                $T    = $ETA[$_]
            
                $Item = $Registry | ? { $_.DisplayName -like "*$( $X[0] )*" }

                If ( ( $Item -ne $Null ) -and ( $Item.DisplayVersion -ge $X[1] ) )
                {
                    Write-Theme -Action "Confirmed [+]" "$( $X[3] ) meets minimum requirements"
                }

                ElseIf ( ( $Item -eq $Null ) -or ( $Item.DisplayVersion -lt $X[1] ) )
                {
                    Write-Theme -Action "Collecting [~]" "$( $X[3] )"
                
                    If ( ! ( Test-Path $X[4] ) )
                    {
                        NI $X[4] -ItemType Directory
                    
                        Write-Theme -Action "Created [+]" "$( $X[4] )"
                    }

                    IPMO BitsTransfer
                
                    [ Net.ServicePointManager ]::SecurityProtocol = [ Net.SecurityProtocolType ]::Tls12

                    $BITS = @{  Source           = $X[6]
                                Destination      = "$( $X[4] )\$( $X[5])"
                                Description      = $X[3] }

                    Start-BitsTransfer @BITS

                    $SAPS = @{  FilePath         = $X[5]
                                Args             = $X[7] 
                                WorkingDirectory = $X[4]
                                Passthru         = $True }

                    Write-Theme -Action "Installing [+]" "$( $X[3] )"
                    
                    Write-Theme -Function "ETA $T"

                    $Time = [ System.Diagnostics.Stopwatch ]::StartNew()

                    SAPS @SAPS | % { 
                    
                        For ( $j = 0 ; $j -le 100 ; $j = ( $j + 1 ) % 100 ) 
                        {
                            $Progress = @{  Activity        = "[ Installing ] $( $X[3] )"
                                            PercentComplete = "$J"
                                            Status          = "$J% Complete" }

                            Write-Progress @Progress
                
                            Sleep -M 250 

                            If ( $_.HasExited ) 
                            { 
                                Write-Progress -Activity "[ Installed ]" -Completed
                                Return 
                            }
                        }
                    }

                    $Time.Stop()

                    Write-Theme -Action "Installed [+]" "$( $X[3] )"

                    Write-Theme -Function "$( $Time.Elapsed )"

                }
            }

            Write-Theme -Action "Verified [+]" "PSD/MDT Dependencies"

            IPMO BitsTransfer
             
            [ Net.ServicePointManager ]::SecurityProtocol = [ Net.SecurityProtocolType ]::Tls12
                    
            $BITS = @{ Source      = "https://github.com/FriendsOfMDT/PSD/archive/master.zip"
                       Destination = "$( $Root.Base )\Tools\PSD_Master.zip" 
                       Description = "PowerShell Deployment" }
            
            Start-BitsTransfer @BITS
        }

        Else
        {
            Write-Theme -Action "Exception [!]" "The exited or the dialogue failed" 12 4 15
        }
                                                                                    #____ -- ____    ____ -- ____    ____ -- ____    ____ -- ____      
}