# // ***************************************************************************
# // 
# // PowerShell Deployment for MDT
# //
# // File:      PSDPartition.ps1
# // 
# // Purpose:   Partition the disk
# // 
# // 
# // ***************************************************************************

Param ( )

# ( MC ) Gonna make sure that the process doesn't format a drive that's supposed to pull up as RAID... learned that the hard way. 

# Load core modules
Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global # <- This thing is still encrypted
Import-Module PSDUtility

$verbosePreference = "Continue"

#Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Load core modules"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Load core modules"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Deployroot is now $( $tsenv:DeployRoot )"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): env:PSModulePath is now $env:PSModulePath"

# Keep the logging out of the way
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Keep the logging out of the way"

$CurrentLocalDataPath = Get-PSDLocalDataPath
If ( $CurrentLocalDataPath -NotLike "X:\*" )
{
    Stop-PSDLogging
    $LogPath = "X:\MININT\Logs"
    If ( ( Test-Path $LogPath ) -eq $False)
    {
        New-Item -ItemType Directory -Force -Path $LogPath | Out-Null
    }
    Start-Transcript "$LogPath\PSDPartition.ps1.log"
}

# Partition and format the disk
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Partition and format the disk"

Update-Disk -Number 0
$Disk = Get-Disk -Number 0

If ( $TSenv:IsUEFI -eq "True" )
{
    # UEFI partitioning
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): UEFI partitioning"

    # Clean the disk if it isn't raw
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Clean the disk if it isn't raw"
    If ( $Disk.PartitionStyle -ne "RAW" ) # If it isn't raw... it's not *as much* fun. I'm talking about the partition style you sick puppy...
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Clearing disk"
        Clear-Disk -Number 0 -RemoveData -RemoveOEM -Confirm:$false
    }

    # Initialize the disk
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Initialize the disk"

    Initialize-Disk -Number 0 -PartitionStyle GPT
    Get-Disk -Number 0

    # Calculate the OS partition size, as we want a recovery partiton after it
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Calculate the OS partition size, as we want a recovery partiton after it"
      $OSSize = $Disk.Size - 500MB - 128MB - 1024MB

    # Create the paritions
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Create the paritions"
         $EFI = New-Partition -DiskNumber 0 -Size 500MB -AssignDriveLetter
         $MSR = New-Partition -DiskNumber 0 -Size 128MB -GptType '{e3c9e316-0b5c-4db8-817d-f92df00215ae}'
          $OS = New-Partition -DiskNumber 0 -Size $OSSize -AssignDriveLetter
    $Recovery = New-Partition -DiskNumber 0 -UseMaximumSize -AssignDriveLetter -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}'

    # Save the drive letters and volume GUIDs to task sequence variables
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Save the drive letters and volume GUIDs to task sequence variables"

            $TSenv:BootVolume = $EFI.DriveLetter
        $TSenv:BootVolumeGuid = $EFI.Guid
              $TSenv:OSVolume = $OS.DriveLetter
          $TSenv:OSVolumeGuid = $OS.Guid
        $TSenv:RecoveryVolume = $Recovery.DriveLetter
    $TSenv:RecoveryVolumeGuid = $Recovery.Guid

    # Format the volumes
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Format the volumes"
    Format-Volume -DriveLetter $TSenv:BootVolume -FileSystem FAT32
    Format-Volume -DriveLetter $TSenv:OSVolume -FileSystem NTFS
    Format-Volume -DriveLetter $TSenv:RecoveryVolume -FileSystem NTFS
    }
    
    Else
    {
        # Clean the disk if it isn't raw
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Clean the disk if it isn't raw"
        If ( $Disk.PartitionStyle -ne "RAW")
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Clearing disk"
            Clear-Disk -Number 0 -RemoveData -RemoveOEM -Confirm:$False
        }

    # Initialize the disk
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Initialize the disk"

    Initialize-Disk -Number 0 -PartitionStyle MBR
    Get-Disk -Number 0

    # Calculate the OS partition size, as we want a recovery partiton after it
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Calculate the OS partition size, as we want a recovery partiton after it"
    $OSSize = $Disk.Size - 499MB - 1024MB

    # Create the paritions
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Create the partitions" # What if the computer doesn't feel like it though ?

        $Boot = New-Partition -DiskNumber 0 -Size 499MB     -AssignDriveLetter -IsActive
          $OS = New-Partition -DiskNumber 0 -Size $OSSize   -AssignDriveLetter
    $Recovery = New-Partition -DiskNumber 0 -UseMaximumSize -AssignDriveLetter

    # Save the drive letters and volume GUIDs to task sequence variables
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Save the drive letters and volume GUIDs to task sequence variables"

    $TSenv:BootVolume = $Boot.DriveLetter
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): tsenv:BootVolume is now $TSenv:BootVolume"
    
      $TSenv:OSVolume = $os.DriveLetter
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): tsenv:OSVolume is now $TSenv:OSVolume"

    $TSenv:RecoveryVolume = $Recovery.DriveLetter
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): tsenv:RecoveryVolume $TSenv:RecoveryVolume"
    
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Format the partitions (admminy)"

    Format-Volume -DriveLetter $TSenv:BootVolume     -FileSystem NTFS -Verbose
    Format-Volume -DriveLetter $TSenv:OSVolume       -FileSystem NTFS -Verbose
    Format-Volume -DriveLetter $TSenv:RecoveryVolume -FileSystem NTFS -Verbose

    #Fix for MBR
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Getting Guids from the volumes"

    $VDGUID = @( $tsenv:OSVolumeGuid  ; $tsenv:RecoveryVolumeGuid  ; $tsenv:BootVolumeGuid  )
    $String = @( "tsenv:OSVolumeGuid" ; "tsenv:RecoveryVolumeGuid" ; "tsenv:BootVolumeGuid" )
    0..2 | % {  $VDGUID[$_] = ( Get-Volume | ? Driveletter -EQ $VDGUID[$_] ).UniqueId.Replace( "\\?\Volume" , "" ).Replace( "\" , "" )
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : $( $String[$_] ) is now $( $VDGUID[$_] )"
}

# Make sure there is a PSDrive for the OS volume
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Make sure there is a PSDrive for the OS volume"

If ( ( Test-Path "$( $tsenv:OSVolume ):\" ) -eq $False )
{
    New-PSDrive -Name $TSenv:OSVolume -PSProvider FileSystem -Root "$( $TSenv:OSVolume ):\" -Verbose
}

# If the old local data path survived the partitioning, copy it to the new location
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): If the old local data path survived the partitioning, copy it to the new location"

If ( Test-Path $CurrentLocalDataPath )
{
    # Copy files to new data path
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Copy files to new data path"
    
    $NewLocalDataPath = Get-PSDLocalDataPath -Move
    If ( $CurrentLocalDataPath -ine $NewLocalDataPath )
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Copying $CurrentLocalDataPath to $NewLocalDataPath"
        Copy-PSDFolder $CurrentLocalDataPath $NewLocalDataPath
        
        # Change log location for TSxLogPath, since we now have a volume
        $Global:TSxLogPath = "$NewLocalDataPath\SMSOSD\OSDLOGS\PSDPartition.log"
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Now logging to $Global:TSxLogPath"
    }
}

# Dumping out variables for troubleshooting
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Dumping out variables for troubleshooting"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): tsenv:BootVolume  is $TSenv:BootVolume"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): tsenv:OSVolume is $TSenv:OSVolume"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): tsenv:RecoveryVolume is $TSenv:RecoveryVolume"
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): tsenv:IsUEFI is $TSenv:IsUEFI"

# Save all the current variables for later use
Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Save all the current variables for later use"
Save-PSDVariables
