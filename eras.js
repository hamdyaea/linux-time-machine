// Era content is based on historical milestones. Implementation details are documented in README.
export const eras = {
 "1991": {
  title:"LINUX 0.01", subtitle:"THE FIRST KERNEL", version:"0.01", context:"September 1991 · Linux 0.01 source code", desktop:"TEXT-ONLY ERA", prompt:"linux1991",
  intro:"Linux 0.01 was released in September 1991. The original release was an experimental kernel, not a ready-to-use desktop distribution.",
  commands:[["ls","List kernel source directories"],["cat README","Read Linux 0.01 notes"],["cd kernel","Enter kernel sources"],["ls kernel","Inspect kernel files"],["uname -r","Check kernel release"],["head README","Read first lines of README"]],
  files:{"README":"Linux 0.01 — September 1991\n\nAn early Linux kernel release for Intel 80386 PCs.\nOriginal sources: https://www.kernel.org/pub/linux/kernel/Historic/",
  "boot":{"boot.s":"Intel 80386 boot code. See the historical archive for full source."},
  "kernel":{"README":"Scheduling, traps and system-call implementation concepts.","sched.c":"Kernel source listing available in the historical archive."},
  "fs":{"README":"Early Linux filesystem implementation concepts."},
  "include":{},"init":{"main.c":"Kernel source listing available in the historical archive."},"lib":{},"mm":{},"tools":{}},
  facts:["1991: Linus Torvalds published the first Linux kernel source.","The first release targeted Intel 80386 computers.","No graphical Linux desktop was bundled with Linux 0.01."]
 },
 "1993": {
  title:"EARLY DISTRIBUTIONS",subtitle:"THE DISTRO ERA",version:"0.99.13",context:"1993 · Slackware and Debian emerge",desktop:"EARLY UNIX SHELL",prompt:"linux1993",
  intro:"1993 saw the arrival of Slackware and the founding of Debian. Distributions began packaging the kernel with utilities and installers.",
  commands:[["ls /etc","Explore configuration files"],["cat /etc/issue","Read Slackware banner"],["cat /etc/profile","Inspect shell environment"],["uname -r","Inspect kernel release"],["whoami","Show logged-in user"],["pwd","Print working directory"]],
  files:{"README":"1993: the rise of Linux distributions.\nSlackware and Debian marked a new era for Linux distributions.",
  "etc":{"issue":"Slackware Linux 1.x","distributions":"Slackware Linux: first released in 1993.\nDebian: project announced in 1993.","profile":"PATH=/bin:/usr/bin"},
  "home":{"visitor":{"notes.txt":"Distributions combine a Linux kernel with user-space software."}},"usr":{"share":{"doc":{"README":"Linux documentation"}}},"bin":{}},
  facts:["Slackware first appeared in 1993.","Ian Murdock announced the Debian project in 1993.","Linux distributions made installation and maintenance more approachable."]
 },
 "1998": {
  title:"THE DESKTOP REVOLUTION",subtitle:"GRAPHICAL LINUX",version:"2.0.36",context:"1998 · KDE 1.0 and the Linux desktop",desktop:"KDE 1.0 ERA",prompt:"linux1998",
  intro:"KDE 1.0 arrived in 1998, bringing an integrated graphical desktop to Linux and other Unix-like systems. KDE introduced an integrated desktop environment.",
  commands:[["ls /home/visitor","Browse home directory"],["ls /home/visitor/Desktop","View desktop files"],["cat /etc/issue","Read login banner"],["uname -r","Inspect Linux version"],["whoami","Show current user"],["desktop","Explore desktop"]],
  files:{"README":"1998: Linux graphical desktops expand.\nKDE 1.0 was released in July 1998.",
  "etc":{"issue":"Linux 2.0 / KDE desktop"},
  "home":{"visitor":{"Desktop":{"Welcome.txt":"Welcome to the graphical Linux era."},"Documents":{"history.txt":"KDE 1.0 debuted in 1998."}}},
  "usr":{"share":{"applications":{"README":"Desktop application directory."}}}},
  facts:["KDE 1.0 was released in July 1998.","GNOME's first stable major release followed in 1999.","KDE 1.0 introduced an integrated desktop experience."]
 },
 "2004": {
  title:"LINUX FOR EVERYONE",subtitle:"THE UBUNTU MOMENT",version:"2.6.8",context:"2004 · Ubuntu 4.10 and Linux 2.6",desktop:"GNOME 2 ERA",prompt:"linux2004",
  intro:"Ubuntu 4.10 launched in October 2004. Linux 2.6 and maturing desktop environments helped Linux reach more everyday users.",
  commands:[["cat /etc/issue","Read Ubuntu 4.10 banner"],["ls /home/visitor","Browse home folder"],["uname -r","Inspect kernel version"],["hostname","Print host name"],["id","Inspect user identity"],["desktop","Explore GNOME desktop"]],
  files:{"README":"2004: the modern Linux desktop gathers momentum.",
  "etc":{"issue":"Ubuntu 4.10 (Warty Warthog)","debian_version":"3.1"},
  "home":{"visitor":{"Desktop":{"Start.txt":"A new generation discovers Linux."},"Documents":{"history.txt":"Ubuntu 4.10 was released in October 2004."},"Pictures":{}}},
  "usr":{"share":{"applications":{}}},
  facts:["Ubuntu 4.10 ('Warty Warthog') launched in October 2004.","Linux 2.6 was introduced in late 2003 and widely used in 2004.","Ubuntu 4.10 shipped with the GNOME desktop."]
 },
 "2026": {
  title:"THE NEXT FRONTIER",subtitle:"MODERN OPEN SOURCE",version:"6.x",context:"2026 · Containers, cloud and open ecosystems",desktop:"MODERN LINUX",prompt:"linux2026",
  intro:"Linux powers servers, phones, containers, embedded devices, supercomputers and desktop workstations. Linux continues to evolve across computing platforms.",
  commands:[["cat /etc/os-release","Inspect distribution identity"],["uname -a","Display system details"],["ls /home/visitor/Projects","Explore projects"],["id","Inspect user and groups"],["env","Display environment"],["desktop","Explore modern desktop"]],
  files:{"README":"2026: Linux is everywhere.\nModern Linux spans many distributions and environments.",
  "etc":{"os-release":"NAME=\"Linux\"\nPRETTY_NAME=\"Linux 2026\"","issue":"Linux 2026"},
  "home":{"visitor":{"Desktop":{"Welcome.txt":"Open source keeps evolving."},"Projects":{"README":"Containers, cloud, security and Linux."},"Documents":{}}},
  "usr":{"share":{"applications":{}}},
  facts:["Linux underpins major cloud and container infrastructure.","Linux also runs across embedded systems and mobile devices.","Linux remains central to modern infrastructure."]
 }
};
