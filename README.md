# PSD-Remaster
Enhancements for customizing and automating the PSD-Master Project found at 'FriendsOfMDT'

# Hybrid | Desired State Controller
This is a personal fork of the project I am working on found here, github.com/secure-digits-plus-llc/Hybrid-DesiredStateController
However this is a lot more hands on with the PSD project and 'integrating' my project 'Hybrid' with 'PSD-Master', and I'm rebadging it as 
"PSD-Remaster"

# What are the intentions of this project ?
To establish the tools necessary to secure any network of any size, starting from the ground up, deployment, distribution, networking, 
network security, firmware, file systems, web servers, server service setup, Active Directory deployment and configuration, DNS, DHCP, 
WDS, MDT, WinPE, WinADK, MDT, Virtualization, Application management, User Environment Virtualization and User State Migration, only...

...it will do it with the least amount of resources humanly and digitally possible, which is what will allow it to be the fastest way to
perform a bare metal recovery for any domain of any size, once the 'application filtering' begins to work for any user and any program.

PCMover is a great way to 'try' to do these things, but doesn't get any of the remaining 90% of things I am looking to target.

# Sounds like a lot of work
It is.

# What is the 'point' of doing all of this?
Have you ever gotten a virus, malware, or looked into the depths of DCOM ? There's a lot to 'make certain of' that security is maintained.
Security is a boolean value, if even one little thing isn't secure, it can crash the entire topology of your network. SCCM tries to do this
by digitally signing everything, but even as 'hardened as it is', it still has it's fair share of security vulnerabilities that MS attempts
to hide with their security updates. Can't say I blame them, but they make mistakes too. They're just in a position to where 'they'd really
rather not accept that they messed up somewhere'. As strange as it may seem, I'm looking to help them make their product stack even better
by providing some actual competition to SCCM, using MDT.

# You're... gonna build a competitor to SCCM, how does that help Microsoft?
Because when they see how much faster my idea is then theirs, and they see that I had to rewrite nearly all of the things they use in their
architecture, they might actually consider taking my ideas more seriously. Michael Niehaus has 'talked' with me a fair amount, we share some
concerns about the security of deployment, and, all things considered, I'm trying to pick up where he left off.

Johan's crew is attempting to 'use the old model and make it backward compatible with Powershell natively. I'm attempting to 'Create an 
entirely new process that "doesn't use VBScript OR cscript.exe". That means, PowerShell natively in the boot environment, ASP.Net accessibile
from PXE, Dynamic driver templates that don't require packaging, as well as Applications that can be automatically packaged up and distributed 
before Windows even fully starts.

# In other words...
It's "Dynamically Engineered Digital Security, Application Development, and Hardware/Networking Magistration"
... making magic happen with 0's and 1's.

# Yeah..... You're nuts.
How about you actually take a look at the code, you might find that I'm doing it.

# I don't want to read through all of that...
Then don't judge me.
