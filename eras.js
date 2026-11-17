// Educational eras. These are illustrative reconstructions, not bootable historical distributions.
export const eras = {
 "1991": {
  title:"LINUX 0.01", subtitle:"THE FIRST KERNEL", version:"0.01", context:"September 1991 · Linux 0.01 source code", desktop:"TEXT-ONLY ERA", prompt:"linux1991",
  intro:"Linux 0.01 was released in September 1991. The original release was an experimental kernel, not a ready-to-use desktop distribution.",
  commands:[["help","List supported commands"],["ls","Explore the source tree"],["cat README","Read the release notes"],["cd kernel","Visit the kernel directory"],["uname -r","See the simulated kernel version"],["history","Review your commands"]],
  files:{"README":"Linux 0.01 — September 1991\n\nAn early Linux kernel release for Intel 80386 PCs.\nThis educational file tree is simplified, not an exact archive.\nOriginal sources: https://www.kernel.org/pub/linux/kernel/Historic/",
  "boot":{"boot.s":"Boot source placeholder. For original code, consult the historical archive."},
  "kernel":{"README":"Scheduling, traps and system-call implementation concepts.","sched.c":"Educational placeholder — not original source code."},
  "fs":{"README":"Early Linux filesystem implementation concepts."},
  "include":{},"init":{"main.c":"Educational placeholder — not original source code."},"lib":{},"mm":{},"tools":{}},
  facts:["1991: Linus Torvalds published the first Linux kernel source.","The first release targeted Intel 80386 computers.","No graphical Linux desktop was bundled with Linux 0.01."]
 },
 "1993": {
  title:"EARLY DISTRIBUTIONS",subtitle:"THE DISTRO ERA",version:"0.99",context:"1993 · Slackware and Debian emerge",desktop:"EARLY UNIX SHELL",prompt:"linux1993",
  intro:"1993 saw the arrival of Slackware and the founding of Debian. Distributions began packaging the kernel with utilities and installers.",
  commands:[["help","List supported commands"],["ls /etc","Explore configuration files"],["cat /etc/issue","Read the era banner"],["cat /etc/distributions","Discover early distributions"],["uname -r","Inspect the illustrative kernel"],["timeline","Learn the milestones"]],
  files:{"README":"1993: the rise of Linux distributions.\nThis is a teaching model, not an actual Slackware or Debian installation.",
  "etc":{"issue":"Linux Time Machine — 1993 educational environment","distributions":"Slackware Linux: first released in 1993.\nDebian: project announced in 1993.","profile":"PATH=/bin:/usr/bin"},
  "home":{"visitor":{"notes.txt":"Distributions combine a Linux kernel with user-space software."}},"usr":{"share":{"doc":{"README":"Educational files, not a historical disk image."}}},"bin":{}},
  facts:["Slackware first appeared in 1993.","Ian Murdock announced the Debian project in 1993.","Linux distributions made installation and maintenance more approachable."]
 },
 "1998": {
  title:"THE DESKTOP REVOLUTION",subtitle:"GRAPHICAL LINUX",version:"2.0",context:"1998 · KDE 1.0 and the Linux desktop",desktop:"KDE-INSPIRED CONCEPT",prompt:"linux1998",
  intro:"KDE 1.0 arrived in 1998, bringing an integrated graphical desktop to Linux and other Unix-like systems. This scene is a modern interpretation, not KDE code.",
  commands:[["help","List supported commands"],["desktop","Preview the desktop concept"],["ls /home/visitor","Explore personal files"],["cat /etc/issue","See the era banner"],["uname -r","Inspect the illustrative kernel"],["timeline","Learn the milestones"]],
  files:{"README":"1998: Linux graphical desktops expand.\nKDE 1.0 was released in July 1998.",
  "etc":{"issue":"Linux Time Machine — 1998 educational environment"},
  "home":{"visitor":{"Desktop":{"Welcome.txt":"Welcome to the graphical Linux era."},"Documents":{"history.txt":"KDE 1.0 debuted in 1998."}}},
  "usr":{"share":{"applications":{"README":"Illustrative desktop application directory."}}}},
  facts:["KDE 1.0 was released in July 1998.","GNOME's first stable major release followed in 1999.","This preview is a generic original desktop sketch, not a copy of KDE assets."]
 },
 "2004": {
  title:"LINUX FOR EVERYONE",subtitle:"THE UBUNTU MOMENT",version:"2.6",context:"2004 · Ubuntu 4.10 and Linux 2.6",desktop:"2000s DESKTOP CONCEPT",prompt:"linux2004",
  intro:"Ubuntu 4.10 launched in October 2004. Linux 2.6 and maturing desktop environments helped Linux reach more everyday users.",
  commands:[["help","List supported commands"],["desktop","Preview the desktop concept"],["cat /etc/os-release","Inspect the era identity"],["ls /home/visitor","Browse the home folder"],["uname -r","See the illustrative kernel"],["timeline","Learn the milestones"]],
  files:{"README":"2004: the modern Linux desktop gathers momentum.",
  "etc":{"os-release":"NAME=\"Linux Time Machine educational reconstruction\"\nERA=\"2004\"\nNOTE=\"Not a real Ubuntu installation\"","issue":"Linux Time Machine — 2004"},
  "home":{"visitor":{"Desktop":{"Start.txt":"A new generation discovers Linux."},"Documents":{"history.txt":"Ubuntu 4.10 was released in October 2004."},"Pictures":{}}},
  "usr":{"share":{"applications":{}}},
  facts:["Ubuntu 4.10 ('Warty Warthog') launched in October 2004.","Linux 2.6 was introduced in late 2003 and widely used in 2004.","The visual preview is original artwork, not a historical screenshot."]
 },
 "2026": {
  title:"THE NEXT FRONTIER",subtitle:"MODERN OPEN SOURCE",version:"modern",context:"2026 · Containers, cloud and open ecosystems",desktop:"MODERN DESKTOP CONCEPT",prompt:"linux2026",
  intro:"Linux powers servers, phones, containers, embedded devices, supercomputers and desktop workstations. This is a thematic 2026 scene, not a specific distribution.",
  commands:[["help","List supported commands"],["desktop","Preview a modern desktop"],["ls /etc","Inspect system configuration"],["cat /etc/os-release","Identify the demo"],["uname -a","Inspect the simulated system"],["timeline","Compare Linux milestones"]],
  files:{"README":"2026: Linux is everywhere.\nThis environment is illustrative and not a bootable distribution.",
  "etc":{"os-release":"NAME=\"Linux Time Machine demo\"\nERA=\"2026\"\nSIMULATED=true","issue":"Linux Time Machine — modern era"},
  "home":{"visitor":{"Desktop":{"Welcome.txt":"Open source keeps evolving."},"Projects":{"README":"Containers, cloud, security and Linux."},"Documents":{}}},
  "usr":{"share":{"applications":{}}},
  facts:["Linux underpins major cloud and container infrastructure.","Linux also runs across embedded systems and mobile devices.","This is an original educational interpretation of the modern Linux ecosystem."]
 }
};
