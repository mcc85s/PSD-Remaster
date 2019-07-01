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
#\\ - - [ PXD-DeploymentShare ] - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //#
# # #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\#

# The following script is newly formatted and contains slight alterations or adjustments made by the aforementioned auth.
# Although I am nowhere close to complete, I have given these scripts my full attention in attempting to optimize them.
# There are definitely many issues that I have noticed, but making mistakes is part of life. Learning from them, and
# making the effort to correct them is what matters the most. Comments, questions, mcook@securedigitsplus.com

<#
.SYNOPSIS

.DESCRIPTION

.LINK

.NOTES
          FileName: PSDDeploymentShare.psd1
          Solution: PowerShell Deployment for MDT
          Purpose: Connect to a deployment share and obtain content from it, using either HTTP or SMB as needed.
          Author: PSD Development Team
          Contact: @Mikael_Nystrom , @jarwidmark , @mniehaus , @SoupAtWork , @JordanTheItGuy
          Primary: @Mikael_Nystrom 
          Created: 
          Modified: 2019-05-09

          Version - 0.0.0 - () - Finalized functional version 1.
          Version - 0.1.1 - () - Removed blocker if we item could not be found, instead we continue and log, error handling must happen when object is needed, not when downloading.

          TODO:

.Example
#>

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Importing Module BITSTransfer"

    Import-Module BITSTransfer -Global

    # Local variables
        $global:psddsDeployRoot = ""
        $global:psddsDeployUser = ""
    $global:psddsDeployPassword = ""
        $global:PSDdsCredential = ""

    # Main function for establishing a connection 
    Function Get-PSDConnection 
    {
        Param ( [ String ] $DeployRoot , [ String ] $Username , [ String ] $Password )

        # Save values in local variables
            $Global:PSDdsDeployRoot = $DeployRoot
            $Global:PSDdsDeployUser = $Username
        $Global:PSDdsDeployPassword = $Password

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Global:PSDdsDeployRoot is now $Global:PSDdsDeployRoot"
    
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Global:PSDdsDeployUser is now $Global:PSDdsDeployUser"
    
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Global:PSDdsDeployPassword is now $Global:PSDdsDeployPassword"

    # Get credentials
    If ( ! $Global:PSDdsDeployUser -or ! $Global:PSDdsDeployPassword )
    {
        $Global:PSDdsCredential = Get-Credential -Message "Specify credentials needed to connect to $uncPath"
    }

    Else
    {
        # ( MC ) So what this part here means, if someone enters in the password, and they know how to exploit this system during installation
        # then, by not declaring the "$Global:psddsDeployPassword = "" after it's assigned to a secure variable ( like below ) , then, someone 
        # can easily get into your account elsewhere... For someone that told me that writing passwords to a file is 'lazy'... I'd say that is
        # quite the contradiction here. Anyway ...

        # You should fix this. I've fixed it in this version, but you have other problems in your scripts, problems that need a good look.

        $Secure = ConvertTo-SecureString $global:psddsDeployPassword -AsPlainText -Force
        $Global:PSDdsCredential = New-Object -TypeName System.Management.Automation.PSCredential -Args $global:psddsDeployUser, $secure
    }

    # Make sure we can connect to the specified location
    If ( $Global:PSDdsDeployRoot -ilike "http*" )
    {
        # Get a copy of the Control folder
        $Cache = Get-PSDContent -Content "Control"
         $Root = Split-Path -Path $Cache -Parent

        # Get a copy of the Templates folder
        $Null = Get-PSDContent -Content "Templates"

        # Connect to the cache
        Get-PSDProvider -DeployRoot $Root
    }

    ElseIf ( $Global:PSDdsDeployRoot -like "\\*" )
    {
        # Connect to a UNC path
        Try
        {
            New-PSDrive `
                -Name        ( Get-PSDAvailableDriveLetter ) `
                -PSProvider                       FileSystem `
                -Root                $global:psddsDeployRoot `
                -Credential          $global:psddsCredential `
                -Scope                                Global
        }

        Catch
        {
            Echo "There's no catch! XD"
        }
        Get-PSDProvider -DeployRoot $Global:PSDdsDeployRoot
    }

    # This shouldn't be here.
    #Else
    #{
    #    # Connect to a local path ( no credential needed )
    #    Get-PSDProvider -DeployRoot $Global:PSDdsDeployRoot
    #}

}

# Internal function for initializing the MDT PowerShell provider, to be used to get objects from the MDT deployment share.
Function Get-PSDProvider # Will find it.
{
    Param ( [ String ] $DeployRoot )

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : DeployRoot is now $DeployRoot"

    # Set an install directory if necessary (needed so the provider can find templates)
    $_MDT = "HKLM:\Software\Microsoft\Deployment 4"
    If ( ( Test-Path $_MDT ) -eq $False )
    {
        $Null = New-Item $_MDT
        sp $_MDT -Name "Install_Dir" -Value "$DeployRoot\"
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Set MDT Install_Dir to $DeployRoot\ for MDT Provider."
    }

    # Load the PSSnapIn PowerShell provider module
    $Modules           = Get-PSDContent -Content "Tools\Modules"
    $VerbosePreference = "SilentlyContinue"
    Import-Module        "$Modules\Microsoft.BDD.PSSnapIn"
    $VerbosePreference = "Continue"

    # Create the PSDrive
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Creating MDT provider drive DeploymentShare: at $DeployRoot"
    
    New-PSDrive -Name DeploymentShare -PSProvider MDTProvider -Root $DeployRoot -Scope Global
}

# Internal function for getting the next available drive letter.
Function Get-PSDAvailableDriveLetter 
{
    $Drives = ( Get-PSDrive -PSProvider Filesystem ).Name
    Foreach   ( $Letter in "ZYXWVUTSRQPONMLKJIHGFED".ToCharArray())
    {
        If ( $Drives -notcontains $letter )
        {
            Return $letter
            Break
        }
    }
} 

# Function for finding and retrieving the specified content.  The source location specifies
# a relative path within the deployment share.  The destination specifies the local path where
# the content should be placed.  If no destination is specified, it will be placed in a
# cache folder.
Function Get-PSDContent
{
    Param ( [ String ] $Content , [ String ] $Destination = "" )

    $VerbosePreference = "Continue"
                 $Dest = ""

    # Track the time
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Track the time"

    $Start = Get-Date

    # If the destination is blank, use a default value
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : If the destination is blank, use a default value"

    If ( $Destination -eq "" )
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Destination is blank, setting value Dest"

        $PSDLocalDataPath = Get-PSDLocalDataPath
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : PSDLocalDataPath is $PSDLocalDataPath"

        $Dest = "$PSDLocalDataPath\Cache\$content"
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Dest is $dest"
    }

    Else
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Destination is NOT blank"
        
        $Dest = $Destination
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Dest is $dest"
    }

    # If the destination already exists, assume the content was already downloaded.
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): If the destination already exists, assume the content was already downloaded."
    # Otherwise, download it, copy it, .
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name ): Otherwise, download it, copy it."

    If ( Test-Path $Dest )
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Access to $dest is OK"

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Already copied $content, not copying again."
    }

    ElseIf ( $Global:PSDdsDeployRoot -ilike "http*" )
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Global:PSDdsDeployRoot is now $Global:PSDdsDeployRoot"

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Running Get-PSDContentWeb -Content $Content -Destination $Dest"
        Get-PSDContentWeb -Content $Content -Destination $Dest
    }

    Elseif ( $Global:PSDdsDeployRoot -like "\\*" )
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Global:PSDdsDeployRoot is now $Global:PSDdsDeployRoot"

        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Running Get-PSDContentUNC -Content $Content -Destination $Dest"

        Get-PSDContentUNC -Content $Content -Destination $Dest
    }

    Else
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Path for $Content is already local, not copying again"
    }

    # Report the time
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Report the time"
    
    $Elapsed = ( Get-Date ) - $Start
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Elapsed time to transfer $Content : $Elapsed"
    
    # Return the destination
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Return the destination $Dest"
    Return $Dest
}

# Internal function for retrieving content from a UNC path (file share)
Function Get-PSDContentUNC
{
    Param ( [ String ] $Content , [ String ] $Destination )

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Copying from $( $Global:PSDdsDeployRoot )\$Content to $Destination"
    Copy-PSDFolder "$( $Global:PSDdsDeployRoot )\$Content" $Destination
}

# Internal function for retrieving content from URL (web server/HTTP)
Function Get-PSDContentWeb
{
    Param ( [ String ] $Content , [ String ] $Destination )
    
    $FullSource = "$( $Global:psddsDeployRoot )/$content".Replace( "\" , "/" )
       $Request = [ System.Net.WebRequest ]::Create( $FullSource )
        $TopURI = New-Object System.URI $FullSource
     $PrefixLen = $TopURI.LocalPath.Length
        
      $Request.UserAgent = "PSD"
         $Request.Method = "PROPFIND"
    $Request.ContentType = "Text/XML"
    $Request.Headers.Set( "Depth" , "Infinity" )
    $Request.Credentials = $Global:PSDdsCredential
          
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Retrieving directory listing of $fullSource via WebDAV."
    
    Try
    {  
        $Response = $Request.GetResponse()
    }

    Catch
    {
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Unable to retrieve directory listing!"
        
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : $( $_.Exception.InnerException )"
        
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : $Response"

        #$Message = "Unable to Retrieve directory listing of $($fullSource) via WebDAV. Error message: $($_.Exception.Message)"
        #Show-PSDInfo -Message "$($Message)" -Severity Error
        #Start-Process PowerShell -Wait
        #Break 
    }
	
	If ( $Response -ne $Null )
    {
        $SR = New-Object System.IO.StreamReader -Args $Response.GetResponseStream(),[ System.Encoding ]::Default
        [ XML ] $xml = $SR.ReadToEnd()		

        # Get the list of files and folders, to make this easier to work with
    	$Results = @()
        $XML.MultiStatus.Response `
        | ? { $_.HREF -ine $URL } `
        | % {   $URI = New-Object System.URI $_.HREF
               $Dest = $URI.LocalPath.Replace( "/" , "\" ).Substring( $PrefixLen ).Trim( "\" )
                $Obj = [ PSCustomObject ]`
                @{          HREF = $_.HREF
                            Name = $_.PropStat.Prop.DisplayName
                    IsCollection = $_.PropStat.Prop.IsSollection
                     Destination = $Dest
            }
            $Results += $Obj
        }
        Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
        : Directory listing retrieved with $( $Results.Count ) items."

        # Create the folder structure
        $Results `
        | ? { $_.IsCollection -eq "1" } `
        | Sort Destination `
        | % {   $Folder = "$Destination\$( $_.Destination )"
                If ( Test-Path $Folder ) {                       }
                Else {                     $null = MkDir $folder } }

        # If possible, do the transfer using ACP or BITS.  Otherwise, download the files one at a time
        If ( $TSenv:SMSTSDownloadProgram )
        {
            #We are using an ACP/ assume it works in WinPE as well. We use ACP as BITS does not function as regular BITS in WinPE, so cannot use PS cmdlet.
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Downloading files using ACP."

            # Begin create regular ACP style .ini file
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Create regular ACP style .ini file"

            #Needed, do not remove.
            $PSDPkgId = "PSD12345" 

            # Create regular ACP style .ini file
            $INIPath = "$Env:Tmp\$PSDPkgId`_Download.ini"
            Set-Content -Value '[ Download ]' -Path $INIPath -Force -Encoding Ascii
            Add-Content -Value "Source=$TopURI" -Path $INIPath
            Add-Content -Value "Destination=$Destination" -Path $INIPath
            Add-Content -Value "MDT=true" -Path $INIPath
            
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Destination=$Destination"

            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Source=$TopURI"


            # ToDo, check that the ini file exists before we try...
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Downloading information saved to $INIPath so starting $TSenv:SMSTSDownloadProgram"

            If ( ( Test-Path -Path $INIPath ) -eq $True )
            {
                #Start-Process -Wait -FilePath "$tsenv:SMSTSDownloadProgram" -ArgumentList "$iniPath $PSDPkgId `"$($destination)`""
                Start-Process -Wait -WindowStyle Hidden -FilePath "$tsenv:SMSTSDownloadProgram" -Args "$INIPath $PSDPkgId `"$( $Destination )`""
                # ToDo hash verification / ( MC ) Yeah I'd say that's a pretty fuckin good idea.
            }

            Else
            {
                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                : Unable to access $INIPath, aborting..."
                Show-PSDInfo -Message "Unable to access $INIPath, aborting..." -Severity Information
                Start-Process PowerShell -Wait
                Exit 1
            }
        }

        # If possible, do the transfer using BITS.  Otherwise, download the files one at a time
        ElseIf ( $Env:SYSTEMDRIVE -eq "X:" )
        {
            # In Windows PE, download the files one at a time using WebClient
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Downloading files using WebClient."
            
            $WC = New-Object System.Net.WebClient , @{ Credentials = $Global:PSDdsCredential }
            $Results `
            | ? { $_.IsCollection -eq "0" } `
            | Sort Destination `
            | % {       $HREF = $_.HREF
                    $FullFile = "$Destination\$( $_.Destination )"
                    try   { $WC.DownloadFile( $HREF , $FullFile ) }
                    catch { Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                            : Unable to download file $href."
                            
                            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                            : $( $_.Exception.InnerException )" } }            
        }

        Else
        {
            # Create the list of files to download
            $SourceUrl = @()
             $DestFile = @()
            $Results `
            | ? { $_.IsCollection -eq "0" } `
            | Sort Destination `
            | % {   $SourceUrl += [ String ] $_.HREF
                      $FullFile = "$Destination\$( $_.Destination )"
                     $DestFile += [ String ] $FullFile
            }
            # Do the download using BITS
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Downloading files using BITS."

            $BITSJob = Start-BitsTransfer                 `
                -Authentication                      Ntlm `
                -Credential       $global:psddsCredential `
                -Source                        $sourceUrl `
                -Destination                    $destFile `
                -TransferType                    Download `
                -DisplayName               "PSD Transfer" `
                -Priority                            High
        }
    }
}

    Export-ModuleMember -function Get-PSDConnection
    Export-ModuleMember -function Get-PSDContent

    # Reconnection logic
    If ( Test-Path "TSenv:" )
    {
        If ( $TSenv:DeployRoot -ne "" )
        {
            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
            : Reconnecting to the deployment share at $( $TSenv:DeployRoot )."

        If ( $tsenv:UserDomain -ne "" )
        {
            Get-PSDConnection                                             `
                -DeployRoot                             $TSenv:DeployRoot `
                -UserName     "$( $TSenv:UserDomain )\$( $TSenv:UserID )" `
                -Password                             $TSenv:UserPassword
        }

        Else
        {
            Get-PSDConnection `
                -DeployRoot                             $TSenv:DeployRoot `
                -UserName                                   $TSenv:UserID `
                -Password                             $TSenv:UserPassword
        }
    }
}
