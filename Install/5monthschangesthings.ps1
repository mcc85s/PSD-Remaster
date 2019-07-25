Here's the crap I was writing 5 months ago.

function Priviledge-Escalation {    
$Run=[Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$Admin=[Security.Principal.WindowsBuiltInRole] 'Administrator'
$NotAdmin='These scripts must be run as administrator.'
If(-not$Run.IsInRole($Admin)){Write-Error -Category PermissionDenied -Message $NotAdmin}
Else{Set-ExecutionPolicy Bypass;Initialize-Hybrid}}
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                               Initialize-@Hybrid                              ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
function Initialize-Hybrid {
$h = @([PSCustomObject]@{
0 = "                                                                                ";
1 = " #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - # ";
2 = " #                                                                            # ";
3 = " ############################################################################## ";
4 = " #                       Setting Domain Controls/Paths                        # ";
5 = " #                         Paths loaded Successfully                          # ";
6 = " #                         VM-Flag Template Dialogue                          # ";
7 = " #                         Continuing to OEM-Stamp                            # ";
8 = " #   VMWare Tools are being copied to the local machine for auto-execution.   # ";
9 = " #          The directory already exists. Proceeding with execution.          # ";
10= " #                        [Installing] VMWare Tools                           # ";
11= " #                         [Installed] VMWare Tools                           # ";
12= " #                  [Installing] VirtualBox Guest Additions                   # ";
13= " #    Guest Additions are copying to the local machine for auto-execution.    # ";
14= " #         The directory already exists. Proceeding with execution.           # ";
15= " #                   [Installed] VirtualBox Guest Additions                   # ";
16= " #                         Continuing to OEM-Stamp                            # ";
17= " #                     [Applying] OEM-Stamp / Branding                        # ";
18= " #                      [Applied] OEM-Stamp / Branding                        # ";
19= " #    Windows is checking for missing Updates/Windows Defender Definitions    # ";
20= " #              Driver Repository: Adding Firewall Exceptions                 # ";
21= " #                   Driver Repository: Installing drivers                    # ";
22= " #                 App Repo: [Installing] Package Manager(s)                  # ";
23= " #               App Repo: [Installing] Applications Template                 # ";
24= " #                          App Repo: [Installed]                             # ";
25= " #                       Checking Windows Activation                          # ";
26= " ### ( User Step 1 ) ########################################################## ";
27= " #                           Selection confirmed.                             # ";
28= " #                       The username cannot be blank.                        # ";
29= " ### ( User Step 2 ) ########################################################## ";
30= " #                       The password cannot be blank.                        # ";
31= " #                           Selection confirmed.                             # ";
32= " ### ( User Step 3 ) ########################################################## ";
33= " #                         Creating User Account.                             # ";
34= " #         Copying the user's profile import script to their desktop.         # ";
35= " #               To continue, you'll need to manually re-enter-               # ";
36= " #       The Machine Post-Install is complete. Finalizing user profile.       # ";
37= " #     The machine needs to perform a reboot to load the user profile.        # ";
38= " #    Post-Install processes are complete, I.E. Windows Update, Drivers,      # ";
39= " #     Applications. It's time to tell this command line how you feel.        # ";
40= " # Returning to Username selection (Step 1)                                   # ";
41= " #  End of post-installation. You can press [(W)ait] to reboot, or you could  # ";
42= " # Some people play games- but not you. You just 'terminated' this script . . # ";
43= " #  You chose to keep it real and told this '(Computer)' how it's gonna be.   # ";
44= " # - - - - - - - -             _______________               - - - - - - - - -# ";
45= " #- - - - - -   _______________]  '#Hybrid'  [_______________     - - - - - - # ";
46= " # - - - - -   {          ______] - - - - - [______          }     - - - - - -# ";
47= " #- - - - - -   \________[ Secure Digits Plus, LLC ]________/     - - - - - - # ";
48= " # - - - - - - - - - - - - -  02/27/2019 by (MCC)              - - - - - - - -# ";
49= " #- - - - - -                \__________________/                 - - - - - - # ";
50= " # - - - - - - - - - - - - - -                   - - - - - - - - - - - - - - -# ";
})
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                   #Hybrid 'Desired State Controller' Variables                ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
$r=@([PSCustomObject]@{0='\\dsc2\secured$';1='Secure Digits Plus, LLC';2='dsc2';
3='Int3264!';4='dsc-deploy';5='https://www.securedigitsplus.com';6='(518)847-3459';
7='24/7';8='OEMbg.jpg';9='OEMlogo.bmp';10='(Vermont)';
11='vermont.securedigitsplus.com';12='Administrator';13='Int3264!';14='dsc2'});
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                   Custom OEM Desired State Controller Options                 ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
$oem=$dsc+'\oem_custom.txt';
if($(Try{Test-Path($oem).trim()}Catch{$false})){
$r=@(Get-Content ($oem))};
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###               #Hybrid's 'Desired State Controller' OEM Concat-Math            ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
$dsc=($r.0+'\'+$r.1);
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                 #Hybrid Ubiquitous Network Root Sub-Directories               ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
$d=@([PSCustomObject]@{0=($dsc+'\[0]Branding');1=($dsc+'\[1]Certificates');
2=($dsc+'\[2]Tools');3=($dsc+'\[3]Snapshots');4=($dsc+'\[4]Profiles');});
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                           Local Machine Directories                           ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
$l=@([PSCustomObject]@{0=$env:ComputerName;1=$env:Processor_Architecture;
2=$env:SystemDrive;3=$env:SystemRoot;4=($env:SystemRoot+'\System32');
5='\Resources';6=$env:programdata});
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                      Local Machine Directory Concat-Math                      ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
$ld=($l.2+'\'+$r.1+'\');$lr=($ld+$l.5+'\');$_bg=($lr+'\'+$r.8);$bg=$r.8;
$_lg=($lr+'\'+$r.9);$lg=$r.9;
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                          #Hybrid Program/Script Logo                          ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
Write-Host $h.3;Write-Host $h.44;Write-Host $h.45;Write-Host $h.46;Write-Host $h.47;
Write-Host $h.48;Write-Host $h.49;Write-Host $h.50;Write-Host $h.3;Write-Host $h.0;
Initialize-DCLink}
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                Credential Declaration on Domain Controller Link               ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
function Initialize-DCLink {
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.4;Write-Host $h.2;
Write-Host $h.1;Write-Host $h.0;
cmdkey /add:$d.2 /user:$d.3 /pass:$d.4;
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.5;Write-Host $h.2;
Write-Host $h.1;Write-Host $h.0;VM-Flag}
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                       Virtual Machine Flag GUI Prompt                         ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
function VM-Flag {
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.6;
Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;
$vmf=@([PSCustomObject]@{1='VM-Flag';2='Is this a virtual machine?';
3=([System.Management.Automation.Host.ChoiceDescription[]]@('&Yes';'&No'));
4=[int]1});
$vmf_switch=$host.UI.PromptForChoice($vmf.1,$vmf.2,$vmf.3,$vmf.4)
switch($vmf_switch)
{0 {VM-Selection}
 1 {Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.7;Write-Host $h.2;
    Write-Host $h.1;Write-Host $h.0;OEM-Stamp}}}
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###           Virtual Machine Template Selection/Installation GUI Prompt          ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
function VM-Selection {
$vms=@([PSCustomObject]@{1='VM-Selection';2='Which type?';
3=[System.Management.Automation.Host.ChoiceDescription[]]@(
'&VMWare';'&VBox';'&Cancel');4=[int]2});
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                       Virtual Machine Template Variables                      ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
$vm=@([PSCustomObject]@{0=($d.2+'\VM\VMWare');1=($lr+'\VM\VMWare');2='\setup.exe';
3='\setup64.exe';4='/s /v "/qn reboot=r"';5=($d.2+'\VM\Oracle');6=($lr+'\VM\Oracle');
7='\VBoxWindowsAdditions-x86.exe';8='\VBoxWindowsAdditions-AMD64.exe';
9='/s "/qn reboot=r"';10='\cert\vbox-sha1.cer';11='\cert\vbox-sha256.cer';
12='Cert:\LocalMachine\TrustedPublisher';})
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                      Virtual Machine Switch & Execution                       ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
$vms_switch=$host.UI.PromptForChoice($vms.1,$vms.2,$vms.3,$vms.4)
switch($vms_switch)
{0{ Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.8;Write-Host $h.2;
    Write-Host $h.1;Write-Host $h.0;
    if($(Try{Test-Path ($vm.2).trim()}Catch{$false})){
    Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.8;Write-Host $h.2;
    Write-Host $h.1;Write-Host $h.0;Copy-Item ($vm.0+'\*') ($vm.1+'\*') -Recurse}
    else{Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.9;
    Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;}
    if($l.1 -eq 'x86') { $vmx = ($vm.1+$vm.2)
    Start-Process -Wait -Filepath $vmx -ArgumentList $vm.4}
    if($l.1 -eq 'AMD64') { $vmx = ($vm.1+$vm.3)
    Start-Process -Wait -Filepath $vmx -ArgumentList $vm.4}
    Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.10;Write-Host $h.2;
    Write-Host $h.1;Write-Host $h.0;OEM-Stamp}
 1{ Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.11;Write-Host $h.2;
    Write-Host $h.1;Write-Host $h.0;
    if($(Try{Test-Path ($vm.6).trim()}Catch{$false})){
    Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.12;Write-Host $h.2;
    Write-Host $h.1;Write-Host $h.0;
    Copy-Item $vm.5 $vm.6 -Recurse}
    else{
    Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.13;Write-Host $h.2;
    Write-Host $h.1;Write-Host $h.0}
    $vmc = ($vm.6+$vm.10)
    Import-Certificate -FilePath $vmc -CertStoreLocation $vm.12
    $vmc = ($vm.6+$vm.10)
    Import-Certificate -FilePath $vmc -CertStoreLocation $vm.12
    if ($lm.2 -eq 'x86') { $vmx = ($vm.6+$vm.7)
    Start-Process -Wait -Filepath $vmx -ArgumentList $vmw.9}
    if ($lm.2 -eq 'AMD64') {$vmx = ($vm.6+$vm.7)
    Start-Process -Wait -Filepath $vmx -ArgumentList $vmw.9}
    Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.14;Write-Host $h.2;
    Write-Host $h.1;Write-Host $h.0;OEM-Stamp}
 2{ Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.15;Write-Host $h.2;
    Write-Host $h.1;Write-Host $h.0;OEM-Stamp}}}
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                   OEM-Stamping (Heavily Modified/TEH WEI KING)                ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
function OEM-Stamp {og=@([PSCustomObject]@{
0='HKLM:';1='HKCU:';2='\Software\Policies\Microsoft\Windows';
3='\Software\Microsoft\Windows\CurrentVersion';
4='\Policies';5='Personalization';6='System';7='\OEMInformation';
8='\Authentication\LogonUI\Background'})
#/*---------------------*\
##### URI Hash Table #####
#\*---------------------*/
of=@([PSCustomObject]@{0='$l.3';1='$l.4';2='\OOBE\Info';3='\Backgrounds'
4='\Microsoft\User Account Pictures';5='\Web\Screen';6='\Web\Wallpaper\Windows'})
#/*---------------------*\
######## Math=om #########
#\*---------------------*/
om=@([PSCustomObject]@{0=($of.0+$of.2+$of.3);1=($og.0+$og.2);2=($og.1+$og.3+$og.4);
3=($of.1+$of.4);4=($of.0+$of.2);5=(($of.1+$of.2+$of.3)+'\');6=($l.3+$of.6+'\'+$bg);
7=($l.3+$of.7+'\'+$bg);8=($og.1+$og.3+$og.4+'\'+$og.5);9=($of.0+$of.6+'\'+$bg);
10=($og.0+$og.3+$og.6);11=($of.1+'\'+$lg);12=($og.0+$og.2+'\'+$og.5);
13=($of.0+$of.5+'\'+$bg);14=($og.0+$og.3+$og.7);})
#/*---------------------*\
####### Commands #########
#\*---------------------*/
New-Item $om.0 -Type $ot.0
New-Item -Path $om.1 -Name $og.5 -Force
New-Item -Path $om.2 -Name $og.6 -Force
Copy-Item $_lg @($of.0;$om.3;$om.4)
Copy-Item $_bg @($om.5;$om.7;$om.8)
Set-ItemProperty -Path $om.9 -Name Wallpaper -Value $om.10
Set-ItemProperty -Path $om.9 -Name WallpaperStyle -Value "2"
Set-ItemProperty -Path $om.11 -Name Logo -Value $om.12 
Set-ItemProperty -Path $om.11 -Name Manufacturer -Value $r.1 
Set-ItemProperty -Path $om.11 -Name SupportPhone -Value $r.6 
Set-ItemProperty -Path $om.11 -Name SupportHours -Value $r.7 
Set-ItemProperty -Path $om.11 -Name SupportURL -Value $r.5 
Set-ItemProperty -Path $om.12 -Name LockScreenImage -Value $om.13
Set-ItemProperty -Path $om.14 -Name OEMBackground -Value 1
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.17;
Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;Windows-Update}
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                   Windows-Update (The best part... Almost NONE)               ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
function Windows-Update {
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.18;
Start-Process ms-settings:windowsupdate
Start-Process ms-settings:windowsupdate-action
Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;Install-Drivers}
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###               Snappy Driver Installer (For now/until further notice           ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
function Install-Drivers {$sdi=@([PSCustomObject]@{0=($d.2+'\Drivers\SDI\')
1='SDI_R1811.exe';2='SDI_x64_R1811.exe';3='\SDI_auto.bat';}) 
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.19;Write-Host $h.2;
Write-Host $h.1;Write-Host $h.0;
if ($l.1 -eq "x86") { $sdix = $sdi.1; }
if ($l.1 -eq "AMD64") { $sdix = $sdi.2; }
New-NetFirewallRule -DisplayName "$sdix [In++]" -Direction Inbound -Program $sdix -RemoteAddress LocalSubnet -Action Allow
New-NetFirewallRule -DisplayName "$sdix [Out-]" -Direction OutBound -Program $sdix -RemoteAddress LocalSubnet -Action Allow
Start-Process $sdi.3 -WindowStyle Minimized
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.20;Write-Host $h.2;
Write-Host $h.1;Write-Host $h.0;Install-Applications}
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###         Chocolatey Application Installer (For now/until further notice        ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
function Install-Applications {Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;
Write-Host $h.21;Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) -wait
choco source remove -n=chocolatey
$source = ('//'+$d.14+':8081/repository/apps-proxy/')
choco source add -n=apps -s=http:$source
New-NetFirewallRule -DisplayName "Double Proxy [In++]" -Direction Inbound -LocalPort 8081 -Protocol UDP -RemoteAddress LocalSubnet -Action Allow
New-NetFirewallRule -DisplayName "Double Proxy [Out-]" -Direction OutBound -LocalPort 8081 -Protocol UDP -RemoteAddress LocalSubnet -Action Allow
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.22;Write-Host $h.2;
Write-Host $h.1;Write-Host $h.0;
#This block is commented out because I'm still learning how to pipeline/runspace
#$apps=@([PSCustomObject]@{1='googlechrome';2='adblockpluschrome';3='flashplayerp`
#lugin';#4='adobeair';5='adobereader-update';6='silverlight';7='jre8';8='7zip.ins`
#tall';9='ccleaner';10='k-litecodecpackfull';11='malwarebytes';12='teamviewer'})
#$appscontainer = {
#$choco Param([string] $apps)
#$processes = Invoke-Command  {
choco install googlechrome adblockpluschrome flashplayerplugin adobeair adobereader -y
choco adobereader-update silverlight jre8 7zip.install ccleaner 
choco install k-litecodecpackfull malwarebytes teamviewer -y
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.23;Write-Host $h.2;
Write-Host $h.1;Write-Host $h.0;Windows-Activation}
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###                        Windows License/Activation Check                       ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
function Windows-Activation {
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.24;Write-Host $h.2;
Write-Host $h.1;Write-Host $h.0;
start ms-settings:activation
Define-Account}
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###             Profile-Designation/Selection GUI (Will link UEV-Capture)         ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
function Define-Account {
Add-Type -AssemblyName PresentationFramework
[xml]$dx=@'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Secure Digits Plus, LLC | Define User" Width="405" Height="300" WindowStartupLocation="CenterScreen">
    <GroupBox Header="Enter Username and Password" HorizontalAlignment="Center" VerticalAlignment="Center" Height="248" Margin="9,10,9.4,12.4" Width="380">
        <StackPanel>
            <Label Content="Enter the credentials you would like to designate to your user." Margin="10,5,10,0" HorizontalAlignment="Center" FontSize="10"/>
            <Label Content="A password is required, but may be changed after logging in." Margin="10,0,10,5" HorizontalAlignment="Center" FontSize="10"/>
            <StackPanel Orientation="Horizontal">
                <Label Content="Username:" Width="65" Margin="100,5,5,5" HorizontalContentAlignment="Right"/>
                <TextBox Name="Username" Height="20" Width="120" Margin="5,5,100,5"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal">
                <Label Content="Password:" Width="65" Margin="100,5,5,5" HorizontalContentAlignment="Right"/>
                <TextBox Name="Password" Height="20" Width="120" Margin="5,5,100,5"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal">
                <Label Content="Confirm:" Width="65" Margin="100,5,5,5" HorizontalContentAlignment="Right"/>
                <TextBox Name="Confirm" Height="20" Width="120" Margin="5,5,100,5"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal" Width="330" Height="40" HorizontalAlignment="Center">
                <Button Name="Ok" Content="OK" Height="20" Width="95" Margin="60 5 10 5" HorizontalAlignment="Center"/>
                <Button Name="Cancel" Content="Cancel" Height="20" Width="95" Margin="10 5 60 5" HorizontalAlignment="Center"/>
            </StackPanel>
        </StackPanel>
    </GroupBox>
</Window>
'@
$dr = New-Object System.Xml.XmlNodeReader($dx);
$df=[Windows.Markup.XamlReader]::Load($dr)
$username = $df.FindName("Username");$password = $df.FindName("Password");
$confirm = $df.FindName("Confirm");$OK = $df.FindName("Ok");
$Cancel = $df.FindName("Cancel");
$OK.Add_Click({$user = $username.Text;$pass = $password.Text;$conf = $confirm.Text;
if($user -eq ""){
[System.Windows.MessageBox]::Show("Username cannot be empty.","Invalid Username")
}elseif($pass -eq ""){
[System.Windows.MessageBox]::Show("Password cannot be empty.","Invalid Password")
}elseif($pass -ne $conf){
[System.Windows.MessageBox]::Show("Passwords must match.","Invalid Password")
}else{$df.Close();Create-Credentials}});$Cancel.Add_Click({$df.Close();Username;});
$df.ShowDialog()}
######################################################################################
#/*--------------------------------------------------------------------------------*\#
###      Profile-Designation/Selection: If GUI Fails to load or admin cancels     ####
#\*--------------------------------------------------------------------------------*/#
######################################################################################
function Username {Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.25;
Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;
$user = Read-Host " # Enter a new Username "
Write-Host $h.2
if ($user -ne "") {Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.26;
Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;Password}
if ($user -eq "") {Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.27;
Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;Username}}
function Password {
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.28;Write-Host $h.2;
Write-Host $h.1;Write-Host $h.0;
$pass = Read-Host " # Enter a password (You may disable after first login) "
if ( $pass -eq "") {
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.29;Write-Host $h.2;
Write-Host $h.1;Write-Host $h.0;Password}
if ( $pass -ne "") {Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.30;
Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;Credentials}}
function Credentials {Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;
Write-Host $h.31;
$confirm_creds = Read-Host " # Confirm that [$user/$pass] is correct (y/n) ? "
if ($confirm_creds -eq "y") {Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;
Create-Credentials}
function Create-Credentials{Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;
Write-Host $h.32;Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;
net user /add $user $pass;net localgroup administrators /add $user;Confirm-Summary}
if ($confirm_creds -eq "n") {Info-Username}}
function Confirm-Summary {
$restart = Read-Host " # Does all of this look good to you (y/n)? "
if ($restart -eq "y" ) {Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;
Write-Host $h.33;Write-Host $h.34;
Write-Host " #                              '$pass'  ";Write-Host $h.2;
Write-Host $h.1;Write-Host $h.0;runas /user:$user "explorer /separate";
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.35;Write-Host $h.2;
Write-Host $h.1;Write-Host $h.0;
$profile=@([PSCustomObject]@{0=($lr+'\StartLayout.xml');
1=($lr+'\User-Import.ps1');2=($l.2+'\Users\'+$user+'\Desktop')})
Import-StartLayout -LayoutPath $profile.0 -MountPath $lm.3
Dism.exe /Online /Import-DefaultAppAssociations:C:\OEM\DefaultApps.xml
Copy-Item $profile.1 $profile.2;Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;
Write-Host $h.36;Write-Host $h.37;Write-Host $h.38;Write-Host $h.2;
Write-Host $h.1;Write-Host $h.0;Complete-Script}
if ($restart -eq "n" ) {Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;
Write-Host $h.39;Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;
rmdir $lm_userf;net user /del $user;Info-Username}}
function Complete-Script {
Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;Write-Host $h.40;
$restart_queue = Read-Host " #         show this computer how [(R)eal] you are (Reboot). (w/r) ? "
Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;
if ($restart_queue -eq 'w') {Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;
Write-Host $h.41;Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;exit}
if ($restart_queue -eq 'r') {Write-Host $h.0;Write-Host $h.1;Write-Host $h.2;
Write-Host $h.42;Write-Host $h.2;Write-Host $h.1;Write-Host $h.0;
Start-Sleep -Seconds 5;Restart-Computer}}
Priviledge-Escalation
