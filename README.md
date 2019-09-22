# PSD-Remaster
Enhancements for customizing and automating the PSD-Master Project found at 'FriendsOfMDT' and...

# ¯¯\\_(ツ)_/¯¯
^ Finding out who this guy *really* is. He's always there... With that smug look on his face... hands in the air like he's trying to say "who knows." Well *I'll* tell you my theory... cause that's all I've got so far... I think he's the guy who REALLY runs Microsoft... If I find out who he is, I will gladly let everyone know his true identity. But until then? His identity remains unknown.

# Hybrid | Desired State Controller
This is a personal fork of the project I am working on found here, github.com/secure-digits-plus-llc/Hybrid-DesiredStateController
However this is a lot more hands on with the PSD project and 'integrating' my project 'Hybrid' with 'PSD-Master', and I'm rebadging it as "PSD-Remaster". This includes GUI interfaces, network connection stuff, Active Directory, Certificates,  drivers, images, and even a few kitchen sinks just for laughs.

# What are the intentions of this project ?
To establish the tools necessary to secure any network of any size, starting from the ground up, deployment, distribution, networking, 
network security, firmware, file systems, web servers, server service setup, Active Directory deployment and configuration, DNS, DHCP, 
WDS, MDT, WinPE, WinADK, MDT, Virtualization, Application management, User Environment Virtualization and User State Migration, only...

...it will do it with the least amount of resources humanly and digitally possible. It'll be so far outside the box? That people will say "you're reinventing the wheel dude." I won't lie. I'm not reinventing the wheel. I'm inventing new tools to make the blueprints that the guy who makes said wheel has to look at, all in the name of him being able to make that damn wheel correctly... But, on top of that...? I get to do what's called "fail miserably over and over until 'stuff finally works...'

I don't know what everyone else calls it, but... I call it 'swearing at my computer a lot.' If *that* doesn't sound like *fun* to you, oh, well- you have *no idea* what a blast you're missing out on. 

# Sounds like a lot of work
Well... it is. I don't want to be sarcastic here... it's... probably the most difficult thing I've ever forced myself to do and honestly... ***its not that fun sometimes....***

# What is the 'point' of doing all of this?
Have you ever gotten a virus, malware, or looked into the depths of DCOM ? There's a lot to 'make certain of' that security is maintained. Security is a boolean value, if even one little thing isn't secure, it can crash the entire topology of your network. SCCM tries to do this by digitally signing everything, but even as 'hardened as it is', it still has it's fair share of security vulnerabilities. Granted, Microsoft has some wizards who work there who know how to 'solve most of the problems before they ever happen...' but there are some that still slip through.

In terms of SCCM, it takes a *lot of time* for changes to *propogate across a network*. So if you push updates in a 2 hour maintenance Window, and you forgot to put something somewhere for all of those machines... oh, well guess what. Now you get to wait until next month to install that critical update that you forgot to put in. So there's that. Hardened security is good for 'every half a year'... but 'not the best use of time or resources when there's a way to do the same thing in a lot less time. That's what MDT can do. You could even use SCCM and MDT in tandem, you could also use the Media Creation tool and download the same thing from each computer... heck. you could even learn how to quack like a duck... but the end result everyone cares about is "how long is that gonna take" and "hey, this thing needs to reboot. but i have all my stuff open."

# Now, you're an administrator...
...and when you see that a user hasn't rebooted their machine for 3 months, you know it's because they have some files open and they don't know how to hit the 'save' button... I mean, we all know that he does, and he knows that he does, but the reason he just chooses not to is because he seems to have a completely false sense of security and does things like leaving written passwords all over his desk, or leaving his session open... just cause. So, there's a stigma involved with 'rebooting a machine.' I'm not impervious to that either. But the problem is, until Windows is rengineered to perform live updating, meaning, when it can "update itself without ever needing to actually reboot"... then what happens is that the security updates that kept getting pushed off, they don't protect a critical vulnerability that now get to allow '100-browser-tab Tom', to enjoy what it feels like to become a victim of identity theft. Pretty cool huh? 

# You're... gonna build a competitor to SCCM, how does that help Microsoft?
Because SCCM and MDT currently use a painfully slow set of older tools like vbscript, cscript, wscript, ActiveX, HTA... and guess what. They have some stuff that's way better and way faster, and it seems like 'they're not gonna make the whole process quicker and more secure... by recycling those older tools and opting to go forward with strictly 100% PowerShell... Michael Niehaus has 'talked' with me a handful of times, we share some concerns about the security of deployment, and, all things considered, I'm trying to pick up where he left off. Cause. Stuff.

Johan's crew is attempting to 'use the old model and make it backward compatible with Powershell natively. I'm attempting to 'Create an 
entirely new process that "doesn't use VBScript OR cscript.exe". That means, PowerShell natively in the boot environment, ASP.Net accessibile from PXE, Dynamic driver templates that don't require packaging, as well as Applications that can be automatically packaged up and distributed before Windows even fully starts. The biggest problem in that regard is WinPE/ADK. *I'm not looking forward to reengineering WinPE... but, whatevs...* 
