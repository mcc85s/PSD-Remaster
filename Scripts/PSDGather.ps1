#\\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//#
#// /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ \\#
#\\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ \/ /\ //#
#// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\#
#\\                                                                                                                   //#
#//   <@[ Script-Initialization ]@>                        "Script Magistration by Michael C. 'Boss Mode' Cook Sr."   \\#
#\\                                                                                                                   //#
#//                        [ Secure Digits Plus LLC | Hybrid ] [ Desired State Controller ]                           \\#
#\\                                                                                                                   //#
#//                  [ https://www.securedigitsplus.com | Server/Client | Seedling/Spawning Script ]                  \\#
#\\                                                                                                                   //#
#//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#
#\\ - - [ PXD-Gather ]- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# The following script is newly formatted and contains slight alterations or adjustments made by the aforementioned auth.
# Although I am nowhere close to complete, I have given these scripts my full attention in attempting to optimize them.
# There are definitely many issues that I have noticed, but making mistakes is part of life. Learning from them, and
# making the effort to correct them is what matters the most. Comments, questions, mcook@securedigitsplus.com

# // ***************************************************************************
# // 
# // PowerShell Deployment for MDT
# //
# // File:      PSDGather.psm1
# // 
# // Purpose:   Module for gathering information about the OS and environment
# //            (mostly from WMI), and for processing rules (Bootstrap.ini, 
# //            CustomSettings.ini).  All the resulting information is saved
# //            into task sequence variables.
# // 
# // ***************************************************************************

#$verbosePreference = "Continue"

    Function Get-PSDLocalInfo
    {
        Process
        {
            # [ Look up OS Info ] - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
            $tsenv:IsServerCoreOS = "False"
                $tsenv:IsServerOS = "False"
                              $SC = HKLM:System\CurrentControlSet\Control
                              $TS = gwmi Win32_OperatingSystem | Select-Object Version, BuildNumber

        If ( Test-Path "$SC\MiniNT" ) 
        {
            $TSenv:OSVersion      = "WinPE"
        }

        Else
        {
            $TSenv:OSVersion      = "Other"

            If ( Test-Path "$env:WINDIR\Explorer.exe" )
            {
                $TSenv:IsServerCoreOS = "True"
            }

            $PPT = "$SC\ProductOptions\ProductType"

            If ( Test-Path $PPT )
            {
                $ProductType = gi $PPT

                If ( $ProductType -eq "ServerNT" -or $ProductType -eq "LanmanNT" )
                {
                    $tsenv:IsServerOS = "True"
                }
            }
        }
             # [ Look up network details ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
             $Obj =                                     "IPAddress" , "MACAddress" , "DefaultIPGateway"
              $IP = gwmi Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 1" | Select-Object $Obj
             # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#
              $List =@(        0..2  )
            ForEach   (  $j in 0..2  ) { 
          $List[$j] =@{ ( $Obj[0..2] ) = ( $IP.IPAddress[$j] , $IP.MACAddress[$j] , $IP.DefaultIPGateway[$j] ) } }

             $tsenvlist:IPAddress =          $IP.IPAddress 
            $tsenvlist:MACAddress =         $IP.MACAddress 
        $tsenvlist:DefaultGateway =   $IP.DefaultIPGateway

        # Look up asset information
                 $tsenv:IsDesktop = "False"
                  $tsenv:IsLaptop = "False"
                  $tsenv:IsServer = "False"
                     $tsenv:IsSFF = "False"
                  $tsenv:IsTablet = "False"

        gwmi Win32_SystemEnclosure | Select-Object SMBIOSAssetTag , ChassisTypes `
        | % {      $tsenv:AssetTag = ( $_.SMBIOSAssetTag ).Trim()
                                $t = $_.ChassisTypes[0]                   }
        if ( $type -in 8..12 + 14 , 18 , 21 ) {  $tsenv:IsLaptop = "True" }
        if ( $type -in 3..7 + 15..16        ) { $tsenv:IsDesktop = "True" }
        if ( $type -in 17 , 23              ) {  $tsenv:IsServer = "True" }
        if ( $type -in 34..36               ) {     $tsenv:IsSFF = "True" }
        if ( $type -in @( 13 ; 30..32 )     ) { $tsenv:IsTablet  = "True" } 

        gwmi Win32_BIOS `
        | % {  $tsenv:SerialNumber = $_.SerialNumber.Trim() }

        If ( $env:PROCESSOR_ARCHITEW6432 )
        {
            If ( $env:PROCESSOR_ARCHITEW6432 -eq "AMD64" )
            {
                $tsenv:Architecture = "x64"
            }

            Else
            {
                $tsenv:Architecture = $env:PROCESSOR_ARCHITEW6432.ToUpper()
            }
        }

        Else
        {
            If ( $env:PROCESSOR_ARCHITECTURE -eq "AMD64" )
            {
                $tsenv:Architecture = "x64"
            }

            Else
            {
                $tsenv:Architecture = $env:PROCESSOR_ARCHITECTURE.ToUpper()
            }
        }

        gwmi Win32_Processor `
        | % { $tsenv:ProcessorSpeed = $_.MaxClockSpeed
                $tsenv:SupportsSLAT = $_.SecondLevelAddressTranslationExtensions }

        # TODO: Capable architecture
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : TODO: Capable architecture" 

        gwmi Win32_ComputerSystem `
        | % {   $tsenv:Manufacturer = $_.Manufacturer
                       $tsenv:Model = $_.Model
                      $tsenv:Memory = [ Int ] ( $_.TotalPhysicalMemory / 1024 / 1024 ) }

        gwmi Win32_ComputerSystemProduct `
        | % {           $tsenv:UUID = $_.UUID }
    
        gwmi Win32_BaseBoard `
        | % {        $tsenv:Product = $_.Product }

        # UEFI
        Try
        {
            Get-SecureBootUEFI -Name SetupMode | Out-Null
            $tsenv:IsUEFI = "True"
        }

        Catch
        {
            $tsenv:IsUEFI = "False"
        }

        # TEST: Battery
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : TEST: Battery" 

     	     $bFoundAC = $false
           $bOnBattery = $false
    	$bFoundBattery = $false
        ForEach ( $Battery in ( gwmi -Class Win32_Battery ) )
        {
            $bFoundBattery = $true
            If ( $Battery.BatteryStatus -eq "2" )
            {
                $bFoundAC = $true
            }
        }
        If ( $bFoundBattery -and ! $bFoundAC )
        {
            $tsenv.IsOnBattery = $true
        }
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : bFoundAC: $bFoundAC" 

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : bOnBattery :$bOnBattery" 

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : bFoundBattery: $bFoundBattery"

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : tsenv.IsOnBattery is now $( $tsenv.IsOnBattery )"

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : TODO: GetDP" 

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : TODO: GetWDS" 

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : TODO: GetHostName" 
    
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : TODO: GetOSSKU" 
            
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : TODO: GetCurrentOSInfo" 

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : TEST: Virtualization" 
    
        $Win32_ComputerSystem = gwmi -Class Win32_ComputerSystem
        switch ( $Win32_ComputerSystem.model )
        {   "Virtual Machine"            {  $tsenv:IsVM = "True" }
            "VMware Virtual Platform"    {  $tsenv:IsVM = "True" }
            "VMware7,1"                  {  $tsenv:IsVM = "True" }
            "Virtual Box"                {  $tsenv:IsVM = "True" }
            Default                      { $tsenv:IsVM = "False" } }

    
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Model is $( $Win32_ComputerSystem.model )" 

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : tsenv:IsVM is now $tsenv:IsVM" 
    
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : TODO: BitLocker" 

      }
    }

    Function Invoke-PSDRules
    {
        [ CmdletBinding () ] Param ( 

            [ ValidateNotNullOrEmpty () ]

                [ Parameter ( ValueFromPipeline = $True , Mandatory = $True ) ] 
        
                    [ String ] $FilePath ,

            [ ValidateNotNullOrEmpty () ]
         
                [ Parameter ( ValueFromPipeline = $True , Mandatory = $True ) ] 

                    [ String ] $MappingFile ) 
        Begin
        {
                        $Global:iniFile = Get-IniContent $FilePath
            [ XML ]$Global:variableFile = Get-Content $MappingFile

            # Process custom properties
            If ( $Global:INIFile[ "Settings" ][ "Properties" ] )
            {
                $Global:INIFile[ "Settings" ][ "Properties" ].Split( "," ).Trim() `
                | % { $NewVar = $Global:VariableFile.Properties.Property[0].Clone()
                
                If ( $_.EndsWith( "(*)" ) )
                {        $NewVar.ID = $_.Replace( "(*)" , "" )
                       $NewVar.Type = "list" }
                Else
                {        $NewVar.ID = "$_"
                       $NewVar.Type = "string" }
                  $NewVar.Overwrite = "false"
                $NewVar.Description = "Custom property"
            
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : Adding custom property $( $NewVar.ID )" 
                $Null = $Global:VariableFile.Properties.AppendChild( $NewVar ) }
            }
            $Global:Variables = $Global:VariableFile.Properties.Property
        }

        Process
        {
            $Global:INIFile[ "Settings" ][ "Priority" ].Split( "," ).Trim() | Invoke-PSDRule
        }
    }

    Function Invoke-PSDRule
    {
        [ CmdletBinding () ] Param( 
            
            [ ValidateNotNullOrEmpty () ]
             
                [ Parameter ( ValueFromPipeline = $True , Mandatory = $True ) ] 
                
                    [ String ] $RuleName ) 
        Begin
        {
            # ooook ? uh lol Why is there even a 'Begin' here if this is gonna be left empty...
            # started thinking of a billie mays commercial....
            # "Are you tired of people asking you to do stuff for em? Trrrry this...
            # Introducing.... 'Nothin'! You can't see it, it's not there, and people can try all day
            # to take it from ya? But guess what- ain't 'Nothin' for em to take! "
            # Sigh. Probably seemed more funny in my mind than typing it out.
            # Anyway...
        }
        Process
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Processing Rule $RuleName" 

            $V = $Global:Variables | ? { $_.ID -ieq $RuleName }
            
            If ( $RuleName.ToUpper() -eq "DEFAULTGATEWAY" )
            {   Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : TODO: Process default gateway" 
            }
            
            ElseIf ( $v )
            {
                If ( $V.type -eq "list" )
                {
                    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                    : Processing values of $RuleName" 

                    ( gi tsenvlist:$( $v.ID ) ).Value | Invoke-PSDRule
                }

                Else
                {
                    $S = ( gi tsenv:$( $v.ID ) ).Value
                    If ( $S -ne "" )
                    {
                        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                        : Processing value of $RuleName" 
                        Invoke-PSDRule $S
                    }

                    Else
                    {
                        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                        : Skipping rule $RuleName, value is blank" 
                    }
                }
            }

            Else
            {
                Get-PSDSettings $Global:INIFile[ $RuleName ]
            }
        }
    }

    Function Get-PSDSettings
    {
        [ CmdletBinding () ] Param ( $section ) 
    
        Begin
        {

        }
        Process
        {
            $skipProperties = $false

            # Exit if the section doesn't exist / ( what? seems incredibly strange ... )
            If ( -not $section )
            {
                Return
            }

            # Process special sections and exits
            If ( $Section.Contains( "UserExit" ) )
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : TODO: Process UserExit Before" 
            }

            If ( $Section.Contains( "SQLServer" ) )
            {
                $SkipProperties = $True
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : TODO: Database" 
            }

            If ( $Section.Contains( "WebService" ) )
            {
                $SkipProperties = $True
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : TODO: WebService" 
            }

            If ( $Section.Contains( "Subsection" ) )
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : Processing subsection"
                Invoke-PSDRule $Section[ "Subsection" ]
            }

            # Process properties
            If ( -not $SkipProperties )
            {   $Section.Keys `
                | % { $SectionVar = $_
                      $v = $Global:Variables `
                | ? { $_.id -ieq $sectionVar }

                        If ( $V )
                        {
            		        If ( ( gi tsenv:$V ).Value -eq $section[ $sectionVar ] )
                            {
                                # Do nothing, value unchanged
    		            	}

                            If ( ( gi tsenv:$V ).Value -eq "" -or $v.Overwrite -eq "true" )
                            {
                                $Value = $( ( gi tsenv:$( $V.ID ) ).Value )
                                If ( $Value -eq '' )
                                {
                                    $value = "EMPTY"
                                }
                
                                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                                : Changing PROPERTY $( $v.ID ) to $( $Section[ $SectionVar ] )
                                , was $Value" 
                                si tsenv:$( $v.id ) -Value $Section[ $SectionVar]
                            }

                            ElseIf ( ( gi tsenv:$v).Value -ne "" )
                            {
                                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                                : Ignoring new value for $( $V.ID )" 
                            }
                        }

                        Else
                        {
                            $TrimVar = $SectionVar.TrimEnd( 0..9 )
                            $V = $Global:Variables `
                            | ? { $_.ID -ieq $TrimVar }
                            If ( $V) 
                            {
                                If ( $V.type -eq "list" )
                                {
                                    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                                    : Adding $( $Section[ $SectionVar ] ) to $( $V.ID )" 
                                    $N = @( ( gi tsenvlist:$( $V.ID ) ).Value )
                                    $N += [ String ] $Section[ $SectionVar ]
                                        si tsenvlist:$( $V.ID ) -Value $N
                                }
                            }
                        }
                    } 
                }

            If ( $Section.Contains( "UserExit" ) )
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : TODO: Process UserExit After" 
            }
        }
    }

    Function Get-IniContent
    { 
    <# 
    .Synopsis 
        Gets the content of an INI file 
         
    .Description 
        Gets the content of an INI file and returns it as a hashtable 
         
    .Notes 
        Author		: Oliver Lipkau <oliver@lipkau.net> 
        Blog		: http://oliver.lipkau.net/blog/ 
	Source		: https://github.com/lipkau/PsIni
			  http://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91
        Version		: 1.0 - 2010/03/12 - Initial release 
			  1.1 - 2014/12/11 - Typo (Thx SLDR)
                                         Typo (Thx Dave Stiff)
         
        #Requires -Version 2.0 
         
    .Inputs 
        System.String 
         
    .Outputs 
        System.Collections.Hashtable 
         
    .Parameter FilePath 
        Specifies the path to the input file. 
         
    .Example 
        $FileContent = Get-IniContent "C:\myinifile.ini" 
        ----------- 
        Description 
        Saves the content of the c:\myinifile.ini in a hashtable called $FileContent 
     
    .Example 
        $inifilepath | $FileContent = Get-IniContent 
        ----------- 
        Description 
        Gets the content of the ini file passed through the pipe into a hashtable called $FileContent 
     
    .Example 
        C:\PS>$FileContent = Get-IniContent "c:\settings.ini" 
        C:\PS>$FileContent["Section"]["Key"] 
        ----------- 
        Description 
        Returns the key "Key" of the section "Section" from the C:\settings.ini file 
         
    .Link 
        Out-IniFile 
    #> 
     
    [ CmdletBinding () ] Param ( 

        [ ValidateNotNullOrEmpty () ] 
            
            [ ValidateScript ( { ( Test-Path $_ ) -and ( ( gi $_ ).Extension -eq ".ini" ) } ) ] 

                [ Parameter ( ValueFromPipeline = $True , Mandatory = $True ) ] 
        
                    [ String ] $FilePath ) 
     
    Begin 
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Function started"
    } 
         
    Process 
    { 
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Processing file: $Filepath"
             
        $Ini = @{} 
        Switch -Regex -File $FilePath 
        { 
            "^\[(.+)\]$" # Section 
            { 
                $Section = $Matches[1] 
                $Ini[ $Section ] = @{} 
                $CommentCount = 0 
            } 
            "^(;.*)$" # Comment 
            { 
                If ( ! ( $Section ) ) 
                { 
                    $Section = "No-Section" 
                    $Ini[ $Section ] = @{} 
                }
                $Value = $Matches[1] 
                $CommentCount = $CommentCount + 1 
                $Name = "Comment" + $CommentCount 
                $Ini[ $Section][$Name] = $Value 
            }  
            "(.+?)\s*=\s*(.*)" # Key 
            { 
                If ( ! ( $Section ) ) 
                { 
                    $Section = "No-Section" 
                    $Ini[ $Section] = @{} 
                } 
                $Name,$Value = $Matches[1..2] 
                $Ini[ $Section ][ $Name] = $Value 
            } 
        } 
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Finished Processing file: $FilePath" 
        Return $Ini 
    } 
         
    End 
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Function ended" 
    } 
}
