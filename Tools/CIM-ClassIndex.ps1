
$CIMIndex = [ PSCustomObject ]@{

    Hardware = [ PSCustomObject ]@{ 

    Cooling     = "Fan" , "HeatPipe" , "Refrigeration" , "TemperatureProbe"

    Input       = "Keyboard" , "PointingDevice"

    MassStorage = "AutochkSetting" , "CDROMDrive" , "DiskDrive" , "FloppyDrive" , "PhysicalMedia" , "TapeDrive"

    Motherboard = "1394Controller" , "1394ControllerDevice" , "AllocatedResource" , "AssociatedProcessorMemory" , "BaseBoard" ,
    "BIOS" , "Bus" ,  "CacheMemory" , "ControllerHasHub" , "DeviceBus" , "DeviceMemoryAddress" , "DeviceSettings" , "DMAChannel" , 
    "FloppyController" , "IDEController" , "IDEControllerDevice" , "InfraredDevice" , "IRQResource" , "MemoryArray" , "MemoryArrayLocation" , 
    "MemoryDevice" , "MemoryDeviceArray" , "MemoryDeviceLocation" , "MotherboardDevice" , "OnBoardDevice" , "ParallelPort" , "PCMCIAController" , 
    "PhysicalMemory" , "PhysicalMemoryArray" , "PhysicalMemoryLocation" , "PNPAllocatedResource" , "PNPDevice" , "PNPEntity" , "PortConnector" , 
    "PortResource" , "Processor" , "SCSIController" , "SCSIControllerDevice" , "SerialPort" , "SerialPortConfiguration" , "SerialPortSetting" , 
    "SMBIOSMemory" , "SoundDevice" , "SystemBIOS" , "SystemDriverPNPEntity" , "SystemEnclosure" , "SystemMemoryResource" , "SystemSlot" , 
    "USBController" , "USBControllerDevice" , "USBHub"

    Networking  = "NetworkAdapter" , "NetworkAdapterConfiguration" , "NetworkAdapterSetting"

    Power       = "Battery" , "CurrentProbe" , "PortableBattery" , "PowerManagementEvent" , "VoltageProbe" , "DriverForDevice"

    Printing    = "Printer" , "PrinterConfiguration" , "PrinterController" , "PrinterDriver" , "PrinterDriverDll" , "PrinterSetting" , 
                  "PrintJob" , "TCPIPPrinterPort"

    Telephony   = "POTSModem" , "POTSModemToSerialPort"

    Video       = "DesktopMonitor" , "DisplayControllerConfiguration" , "VideoController" , "VideoSettings" }

    Application = [ PSCustomObject ] @{ Software =
    "ActionCheck" , "ApplicationCommandLine" , "ApplicationService" , "Binary" , "BindImageAction" , "CheckCheck" , "ClassInfoAction" , 
    "CommandLineAccess" , "Condition" , "CreateFolderAction" , "DuplicateFileAction" , "EnvironmentSpecification" , "ExtensionInfoAction" , 
    "FileSpecification" , "FontInfoAction" , "IniFileSpecification" , "InstalledSoftwareElement" , "LaunchCondition" , "ManagedSystemElementResource" , 
    "MIMEInfoAction" , "MoveFileAction" , "MSIResource" , "ODBCAttribute" , "ODBCDataSourceAttribute" , "ODBCDataSourceSpecification" , "ODBCDriverAttribute" , 
    "ODBCDriverSoftwareElement" , "ODBCDriverSpecification" , "ODBCSourceAttribute" , "ODBCTranslatorSpecification" , "Patch" , "PatchFile" , "PatchPackage" , 
    "Product" , "ProductCheck" , "ProductResource" , "ProductSoftwareFeatures" , "ProgIDSpecification" , "Property" , "PublishComponentAction" , "RegistryAction" , 
    "RemoveFileAction" , "RemoveIniAction" , "ReserveCost" , "SelfRegModuleAction" , "ServiceControl" , "ServiceSpecification" , "ServiceSpecificationService" , 
    "SettingCheck" , "ShortcutAction" , "ShortcutSAP" , "SoftwareElement" , "SoftwareElementAction" , "SoftwareElementCheck" , "SoftwareElementCondition" , 
    "SoftwareElementResource" , "SoftwareFeature" , "SoftwareFeatureAction" , "SoftwareFeatureCheck" , "SoftwareFeatureParent" , "SoftwareFeatureSoftwareElements" , 
    "TypeLibraryAction" }

	OperatingSystem = [ PScustomObject ]@{
	
	COM         = "ClassicCOMApplicationClasses" , "ClassicCOMClass" , "ClassicCOMClassSettings" , "ClientApplicationSetting" , "COMApplication" , 
    "COMApplicationClasses" , "COMApplicationSettings" , "COMClass" , "ComClassAutoEmulator" , "ComClassEmulator" , "ComponentCategory" , "COMSetting" , 
    "DCOMApplication" , "DCOMApplicationAccessAllowedSetting" , "DCOMApplicationLaunchAllowedSetting" , "DCOMApplicationSetting" , "ImplementedCategory"

	Desktop     = "Desktop" , "Environment" , "TimeZone" , "UserDesktop"

	Drivers     = "DriverVXD" , "SystemDriver"

	FileSystem  = "CIMLogicalDeviceCIMDataFile" , "Directory" , "DirectorySpecification" , "DiskDriveToDiskPartition" , "DiskPartition" , "DiskQuota" , 
    "LogicalDisk" , "LogicalDiskRootDirectory" , "LogicalDiskToPartition" , "MappedLogicalDisk" , "OperatingSystemAutochkSetting" , "QuotaSetting" , 
    "ShortcutFile" , "SubDirectory" , "SystemPartitions" , "Volume" , "VolumeQuota" , "VolumeQuotaSetting" , "VolumeUserQuota"

	JobObjects  = "CollectionStatistics" , "LUID" , "LUIDandAttributes" , "NamedJobObject" , "NamedJobObjectActgInfo" , "NamedJobObjectLimit" , 
    "NamedJobObjectLimitSetting" , "NamedJobObjectProcess" , "NamedJobObjectSecLimit" , "NamedJobObjectSecLimitSetting" , "NamedJobObjectStatistics" , 
    "SIDandAttributes" , "TokenGroups" , "TokenPrivileges"

	Memory_Page = "LogicalMemoryConfiguration" , "PageFile" , "PageFileElementSetting" , "PageFileSetting" , "PageFileUsage" ,"SystemLogicalMemoryConfiguration"

	AV_Media    = "CodecFile"

	Networking  = "ActiveRoute" , "IP4PersistedRouteTable" , "IP4RouteTable" , "IP4RouteTableEvent" , "NetworkClient" , "NetworkConnection" , "NetworkProtocol" , 
    "NTDomain" , "PingStatus" , "ProtocolBinding"

	OperatingSystemEvents = "ComputerShutdownEvent" , "ComputerSystemEvent" , "DeviceChangeEvent" , "ModuleLoadTrace" , "ModuleTrace" , "ProcessStartTrace" , 
    "ProcessStopTrace" , "ProcessTrace" , "SystemConfigurationChangeEvent" , "SystemTrace" , "ThreadStartTrace" , "ThreadStopTrace" , "ThreadTrace" , "VolumeChangeEvent"

	OperatingSystemSettings = "BootConfiguration" , "ComputerSystem" , "ComputerSystemProcessor" , "ComputerSystemProduct" , "DependentService" , "LoadOrderGroup" , 
    "LoadOrderGroupServiceDependencies" , "LoadOrderGroupServiceMembers" , "OperatingSystem" , "OperatingSystemQFE" , "OSRecoveryConfiguration" , "QuickFixEngineering" , 
    "StartupCommand" , "SystemBootConfiguration" , "SystemDesktop" , "SystemDevices" , "SystemLoadOrderGroups" , "SystemNetworkConnections" , "SystemOperatingSystem" , 
    "SystemProcesses" , "SystemProgramGroups" , "SystemResources" , "SystemServices" , "SystemSetting" , "SystemSystemDriver" , "SystemTimeZone" , "SystemUsers"

	Processes = "Process" , "ProcessStartup" , "Thread"

	Registry  = "Registry"

	SchedulerJobs = "CurrentTime" , "ScheduledJob" , "LocalTime" , "UTCTime"

	Security  = "AccountSID" , "ACE" , "LogicalFileAccess" , "LogicalFileAuditing" , "LogicalFileGroup" , "LogicalFileOwner" , "LogicalFileSecuritySetting" , 
    "LogicalShareAccess" , "LogicalShareAuditing" , "LogicalShareSecuritySetting" , "PrivilegesStatus" , "SecurityDescriptor" , "SecuritySetting" , 
    "SecuritySettingAccess" , "SecuritySettingAuditing" , "SecuritySettingGroup" , "SecuritySettingOfLogicalFile" , "SecuritySettingOfLogicalShare" , 
    "SecuritySettingOfObject" , "SecuritySettingOwner" , "SID" , "Trustee"

	Services  = "BaseService" , "Service"

	Shares    = "DFSNode" , "DFSNodeTarget" , "DFSTarget" , "ServerConnection" , "ServerSession" , "ConnectionShare" , "PrinterShare" , "SessionConnection" , 
    "SessionProcess" , "ShareToDirectory" , "Share"

	StartMenu = "LogicalProgramGroup" , "LogicalProgramGroupDirectory" , "LogicalProgramGroupItem" , "LogicalProgramGroupItemDataFile" , "ProgramGroup" , 
    "ProgramGroupContents" , "ProgramGroupOrItem"

	Storage   = "ShadowBy" , "ShadowContext" , "ShadowCopy" , "ShadowDiffVolumeSupport" , "ShadowFor" , "ShadowOn" , "ShadowProvider" , "ShadowStorage" , 
    "ShadowVolumeSupport" , "Volume" , "VolumeUserQuota"

	Users     = "Account" , "Group" , "GroupInDomain" , "GroupUser" , "LogonSession" , "LogonSessionMappedDisk" , "NetworkLoginProfile" , 
    "SystemAccount" , "UserAccount" , "UserInDomain"

	EventLog  = "NTEventlogFile" , "NTLogEvent" , "NTLogEventComputer" , "NTLogEventLog" , "NTLogEventUser"

	WindowsProductActivation = "ComputerSystemWindowsProductActivationSetting" , "Proxy" , "WindowsProductActivation" }

	Performance = [ PSCustomObject ]@{ Logs = "Perf" , "PerfFormattedData" , "PerfRawData" }

	Security = [ PSCustomObject ]@{ Security = "SecurityDescriptor" , "SecurityDescriptorHelper" } 

    }
