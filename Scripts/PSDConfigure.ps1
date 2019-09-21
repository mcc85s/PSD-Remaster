# // ***************************************************************************
# // 
# // PowerShell Deployment for MDT
# //
# // File:      PSDConfigure.ps1
# // 
# // Purpose:   Configure the unattend.xml to be used with the new OS.
# // 
# // 
# // ***************************************************************************

    Param ( )

    # Load core modules
    Import-Module Microsoft.BDD.TaskSequenceModule -Scope Global  # < - This thing is still encrypted.
    Import-Module DISM
    Import-Module PSDUtility
    Import-Module PSDDeploymentShare

    $verbosePreference = "Continue"

    #Write-Verbose -Message "$($MyInvocation.MyCommand.Name): Load core modules"
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Load core modules"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Deployroot is now $( $TSenv:DeployRoot )"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : env:PSModulePath is now $Env:PSModulePath"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
    # Load the unattend.xml                                   #
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Load the unattend.xml"

              $TSInfo = Get-PSDContent "Control\$( $TSenv:TaskSequenceID )"
    [ XML ] $Unattend = Get-Content "$TSInfo\unattend.xml"
          $Namespaces = @{ Unattend = 'URN:Schemas-Microsoft-COM:Unattend'    }
             $Changed = $False
         $UnattendXML = "$( $TSenv:OSVolume ):\Windows\Panther\Unattend.xml"

   Initialize-PSDFolder "$( $TSenv:OSVolume ):\Windows\Panther"

    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Substitute the values in the unattend.xml"

    $Scripts = Get-PSDContent "Scripts"
    [ xml ] $Config 
             = Get-Content "$Scripts\ZTIConfigure.xml"
     $Config | Select-Xml "//mapping[@type='xml']" `
    | % { # Still in function

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
    # Process each substitution rule from ZTIConfigure.xml    #
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

    $Variable = $_.Node.ID
       $Value = ( gi TSenv:$Variable ).Value
     $Removes = $_                          `
              | Select-Xml "Remove" $_      `
              | Select-Xml "Xpath"          `
              | % { 

                # Process each XPath query
                $Xpath = $_.Node.'#CDATA-Section'
        $RemoveIfBlank = $_.Node.RemoveIfBlank
             $Unattend | Select-Xml -XPath $Xpath -Namespace $Namespaces `
                       | % {

                        # Process found entry in the unattend.xml
                        $Prev = $_.Node.InnerText
                        If ( $Value -eq "" -and $Prev -eq "" -and $RemoveIfBlank -eq "Self" )
                        {   $_.Node.ParentNode.RemoveChild( $_.Node ) `
                            | Out-Null
                            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                            : Removed $xpath from unattend.xml because the value was blank."
                            $Changed = $True }

                        ElseIf ( $Value -eq "" -and $Prev -eq "" -and $RemoveIfBlank -eq "Parent" )
                        {   $_.Node.ParentNode.ParentNode.RemoveChild( $_.Node.ParentNode ) `
                        |   Out-Null
                            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                            : Removed parent of $Xpath from unattend.xml because the value was blank."
                            $Changed = $True
                        }
            
                        ElseIf ( $Value -ne "" )
                        {   $_.Node.InnerText = $Value
                            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                            : Updated Unattend.Xml with $Variable = $Value ( Value was $Prev )."
                            $Changed = $True
                            $_.Node.ParentNode `
                            | Select-Xml -XPath "Unattend:PlainText" -Namespace $Namespaces `
                            | % {   $_.Node.InnerText = "True"
                            Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                            : Updated PlainText entry to true." }

                        # Remove any contradictory entries / ( MC ) Hmmm
                        $Removes `
                        | % {   $RemoveXpath = $_.Node.'#CDATA-Section'
                                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                                : *** $RemoveXpath"
                                $Unattend `
                                | Select-Xml -XPath $RemoveXpath -Namespace $Namespaces `
                                | % {   $_.Node.ParentNode.RemoveChild( $_.Node ) `
                                | Out-Null
                                Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                                : Removed $RemoveXpath entry from unattend.xml." } } }

                        Else
                        {   Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
                            : No value found for $Variable." } } } }

    # Save the file
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Save the file"
    
    $Unattend.Save( $UnattendXml )

    # File Saved
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Saved $unattendXml."

    # Apply the unattend.xml
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Apply the unattend.xml"
    $ScratchPath = "$( Get-PSDLocalDataPath )\Scratch"
    Initialize-PSDFolder $ScratchPath
    Use-WindowsUnattend -UnattendPath $UnattendXml -Path "$( $TSenv:OSVolume ):\" -ScratchDirectory $ScratchPath -NoRestart

    # Copy needed script and module files
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Copy needed script and module files"

    Initialize-PSDFolder "$( $TSenv:OSVolume ):\MININT\Scripts"
    $Modules = Get-PSDContent "Tools\Modules"
    Copy-Item "$Scripts\PSDStart.ps1" "$( $TSenv:OSVolume ):\MININT\Scripts"
    Copy-PSDFolder "$Modules" "$( $tsenv:OSVolume ):\MININT\Tools\Modules"

    # Save all the current variables for later use
    Write-PSDLog -Message "$( $MyInvocation.MyCommand.Name )
    : Save all the current variables for later use"
    Save-PSDVariables

    # Request a reboot
    Write-PSDLog -Message "$($MyInvocation.MyCommand.Name): Request a reboot"
    $TSenv:SMSTSRebootRequested = "True"
