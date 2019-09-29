
Function Search-CIM
{
    [ CmdLetBinding ( ) ] Param (

        [ Parameter ( Position = 0 , ParameterSetName = "0" ) ][ Switch ] $Hardware        ,
        [ Parameter ( Position = 0 , ParameterSetName = "1" ) ][ Switch ] $Software        ,
        [ Parameter ( Position = 0 , ParameterSetName = "2" ) ][ Switch ] $OperatingSystem ,
        [ Parameter ( Position = 0 , ParameterSetName = "3" ) ][ Switch ] $Performance     ,
        [ Parameter ( Position = 0 , ParameterSetName = "4" ) ][ Switch ] $Security        )

        If ( $Hardware        ) { $Item = $CimIndex.Hardware        }
        If ( $Application     ) { $Item = $CimIndex.Software        }
        If ( $OperatingSystem ) { $Item = $CimIndex.OperatingSystem }
        If ( $Performance     ) { $Item = $CimIndex.Performance     }
        If ( $Security        ) { $Item = $CimIndex.Security        }
    
        $List     = $Item | GM | ? { $_.Membertype -like "NoteProperty" } | % { $_.Name }
        $Count    = 0..( $List.Count - 1 )
        $Select   = $Count | % { "[$_] $( $List[$_] )" }
        Echo $Select , ""
        $Sub      = Read-Host "Enter Sub-Category"

        ForEach ( $i in $Count ) 
        { 
            If ( $Sub -like "*$I*" -or $Sub -like "*$( $List[$I] )*" ) 
            {
                $Item.$($List[$I] ) | Sort | % { "Win32_$_" }
            } 
        }
}

$CIMIndex = [ PSCustomObject ]@{

    Hardware    = [ PSCustomObject ]@{ 
        
        Cooling     = "Fan" , "HeatPipe" , "Refrigeration" , "TemperatureProbe"

        Input       = "Keyboard" , "PointingDevice"

        MassStorage = "AutochkSetting" , "CDROMDrive" , "DiskDrive" , "FloppyDrive" , "PhysicalMedia" , "TapeDrive"

        Motherboard = @( @( "AllocatedResource" , "AssociatedProcessorMemory" , "BaseBoard" , "BIOS" , "Bus" , "CacheMemory" , "ControllerHasHub" , "DMAChannel" , "IRQResource" , 
                      "ParallelPort" , "PNPAllocatedResource" , "PNPEntity" , "PNPDevice" , "PortConnector" , "PortResource" , "Processor" , "SMBIOSMemory" , "USB" ) + 
                      @( "Infrared" , "Motherboard" , "OnBoard" , "Sound" | % { "$_`Device" } ) + @( "Bus" , "MemoryAddress" , "Settings" | % { "Device$_" } ) + 
                      @( "" , "Configuration" , "Setting" | % { "SerialPort$_" } ) + @( "BIOS" , "DriverPNPEntity" , "Enclosure" , "MemoryResource" , "Slot" | % { "System$_" } ) + 
                      @( "Floppy" , "PCMCIA" | % { "$_`Controller" } ) + @( "1394" , "IDE" , "SCSI" , "USB" | % { "$_`Controller" | % { "$_" , "$_`Device" } } )
                      @( (1,2),(1..3),(1,4),(1,4,2),(1,4,3),(0,1),(0..2),(0,1,4) | % { ( "Physical" , "Memory" , "Array" , "Location" , "Device" )[$_] -join '' } ) ) | Sort

        Networking  = "" , "Configuration" , "Setting" | % { "NetworkAdapter$_" }

        Power       = "Battery" , "CurrentProbe" , "PortableBattery" , "PowerManagementEvent" , "VoltageProbe" , "DriverForDevice"

        Printing    = @( "" , "Configuration" , "Controller" , "Driver" , "DriverDll" , "Setting" | % { "Printer$_" } ) + "PrintJob" , "TCPIPPrinterPort"

        Telephony   = "" , "ToSerialPort" | % { "POTSModem$_" }

        Video       = "DesktopMonitor" , "DisplayControllerConfiguration" , "VideoController" , "VideoSettings" }

    Software    = [ PSCustomObject ] @{ 

        General     = @( @( "CommandLine" , "Service" | % { "Application$_" } ) + @( "Environment" , "ProgID" , "File" , "IniFile" | % { "$_`Specification" } ) +
                      @( "ActionCheck" , "Binary" , "CheckCheck" , "CommandLineAccess"  , "Condition" , "InstalledSoftwareElement" , "LaunchCondition" , 
                      "ManagedSystemElementResource" , "MSIResource" , "Patch" , "PatchFile" , "PatchPackage" , "Property" , "ReserveCost" ,  "SettingCheck" , "ShortcutSAP" ) +
                      @( "ClassInfo" , "BindImage" , "CreateFolder" , "DuplicateFile" , "ExtensionInfo" ,  "FontInfo" , "MIMEInfo" , "MoveFile" , "PublishComponent" , 
                       "Registry" , "RemoveFile" , "RemoveIni" , "SelfRegModule" , "Shortcut" , "TypeLibrary" | % { "$_`Action" } ) ) | Sort

        Service     = "Control" , "Specification" , "SpecificationService" | % { "Service$_" }

        Product     = "" , "Check" , "ProductResource" , "SoftwareFeatures" | % { "Product$_" }

        ODBC        = "Attribute" , "DataSourceAttribute" , "DataSourceSpecification" , "DriverAttribute" , "DriverSoftwareElement" , "DriverSpecification" , 
                      "SourceAttribute" , "TranslatorSpecification" | % { "ODBC$_" }

        Software    = @( @( "" , "Action" , "Check" , "Condition" , "Resource" | % { "Element$_" } ) + 
                         @( "" , "Action" , "Check" , "Parent" , "SoftwareElements" | % { "Feature$_" } ) ) | % { "Software$_" }
    }

	OperatingSystem = [ PScustomObject ]@{
	
	    COM         = @( @( "ApplicationClasses" , "Class" , "ClassSettings" | % { "ClassicCOM$_" } ) + "ClientApplicationSetting" ; 
                      @( "" , "Classes" , "Settings" | % { "COMApplication$_" } ) + "COMClass" , "ComClassAutoEmulator" , "ComClassEmulator" , "ComponentCategory" , 
                      "COMSetting" ; @( "" , "AccessAllowedSetting" , "LaunchAllowedSetting" , "Setting" | % { "DCOMApplication$_" } ) + "ImplementedCategory" )

	    Desktop     = "Desktop" , "Environment" , "TimeZone" , "UserDesktop"

	    Drivers     = "DriverVXD" , "SystemDriver"

	    FileSystem  = @( "CIMLogicalDeviceCIMDataFile" ; @( "" , "Specification" | % { "Directory$_" } ) + @( "DiskDriveToDisk" , "Disk" | % { "$_`Partition" } ) +
                      "DiskQuota" ; @( "" , "RootDirectory" , "ToPartition" | % { "LogicalDisk$_" } ) + "MappedLogicalDisk" , "OperatingSystemAutochkSetting" , 
                      "QuotaSetting" , "ShortcutFile" , "SubDirectory" , "SystemPartitions" , @( "" , "Quota" , "QuotaSetting" , "UserQuota" | % { "Volume$_" } ) )

    	JobObjects  = @( "CollectionStatistics" , "LUID" , "LUIDandAttributes" ; @( "" , "ActgInfo" , "Limit" , "LimitSetting" , "Process" , "SecLimit" , "SecLimitSetting" , 
                      "Statistics" | % { "NamedJobObject$_" } ) + "SIDandAttributes" , "TokenGroups" , "TokenPrivileges" )

    	Memory_Page = @( "" , "System" | % { "$_`LogicalMemoryConfiguration" } ) + @( "" , "ElementSetting" , "Setting" , "Usage" | % { "PageFile$_" } )

    	AV_Media    = "CodecFile"

    	Networking  = @( "ActiveRoute" , "IP4PersistedRouteTable" , "IP4RouteTable" , "IP4RouteTableEvent" ; @( "Client" , "Connection" , "Protocol" | % { "Network$_" } ) +
                      "NTDomain" , "PingStatus" , "ProtocolBinding" )

	    Events      = @( "ComputerShutdownEvent" , "ComputerSystemEvent" , "DeviceChangeEvent" , "ModuleLoadTrace" , "ModuleTrace" , "ProcessStartTrace" , "ProcessStopTrace" ,
                      "ProcessTrace" , "SystemConfigurationChangeEvent" , "SystemTrace" ; @( "Start" , "Stop" , "" | % { "Thread$($_)Trace" } ) , "VolumeChangeEvent" )

	    Settings    = @( "BootConfiguration" ; @( "" , "Processor" , "Product" | % { "ComputerSystem$_" } ) + "DependentService" ; 
                      @( "" , "ServiceDependencies" , "ServiceMembers" | % { "LoadOrderGroup$_" } ) + @( "" , "QFE" | % { "OperatingSystem$_" } ) + "OSRecoveryConfiguration" , 
                      "QuickFixEngineering" , "StartupCommand" ; @( "BootConfiguration" , "Desktop" , "Devices" , "LoadOrderGroups" , "NetworkConnections" , "OperatingSystem" , 
                      "Processes" , "ProgramGroups" , "Resources" , "Services" , "Setting" , "SystemDriver" , "TimeZone" , "Users" | % { "System$_" } ) )

    	Processes   = @( "" , "Startup" | % { "Process$_" } ) + "Thread"

    	Registry    = "Registry"

    	Scheduler   = @( "Current" , "Local" , "UTC" | % { "$_`Time" } ) + "ScheduledJob"

    	Services    = "Base" , "" | % { "$_`Service" }

	    Shares      = @( "" , "Target" | % { "DFSNode$_" } ) + "DFSTarget" , "ServerConnection" , "ServerSession" , "ConnectionShare" , "PrinterShare" , "SessionConnection" , 
                      "SessionProcess" , "ShareToDirectory" , "Share"

	    StartMenu   = @( "" , "Directory" , "Item" , "ItemDataFile" | % { "LogicalProgramGroup$_" } ) + @( "" , "Contents" , "OrItem" | % { "ProgramGroup$_" } )

    	Storage     = @( "By" , "Context" , "Copy" , "DiffVolumeSupport" , "For" , "On" , "Provider" , "Storage" , "VolumeSupport" | % { "Shadow$_" } ) + 
                      @( "" , "UserQuota" | % { "Volume$_" } )

    	Users       = @( "Account" , @( "" , "InDomain" , "User" | % { "Group$_" } ) + @( "" , "MappedDisk" | % { "LogonSession$_" } ) + 
                      "NetworkLoginProfile" , "SystemAccount" , "UserAccount" , "UserInDomain" )

	    Logging     = @( "NTEventlogFile" ; @( "" , "Computer" , "Log" , "User" | % { "NTLogEvent$_" } ) )

	    Activation  = @( "WindowsProductActivation" | % { "ComputerSystem$_`Setting" , "Proxy" , "$_" } )
    }

	Performance = [ PSCustomObject ]@{ 
        Formatted   = "PerfFormattedData"
        Raw         = "PerfRawData"
        Logs        = "Perf"
    }

	Security = [ PSCustomObject ]@{ 

        Logical     = @( @( "Access" , "Auditing" , "Group" , "Owner" , "SecuritySetting" | % { "File$_" } ) + 
                      @( "Access" , "Auditing" , "SecuritySetting" | % { "Share$_" } ) ) | % { "Logical$_" }

        Descript    = "" , "Helper" | % { "SecurityDescriptor$_" }

        Account     = "AccountSID" , "ACE" , "PrivilegesStatus" , "SID" , "Trustee"

        System      = "" , "Access" , "Auditing" , "Group" , "OfLogicalFile" , "OfLogicalShare" , "OfObject" , "Owner" | % { "SecuritySetting$_" }
    } 

} | Sort
