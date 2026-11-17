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
  "usr":{"share":{"applications":{}}}},
  facts:["Ubuntu 4.10 ('Warty Warthog') launched in October 2004.","Linux 2.6 was introduced in late 2003 and widely used in 2004.","Ubuntu 4.10 shipped with the GNOME desktop."]
 },
 "2010": {
  title:"CLOUD & MOBILE",subtitle:"LINUX GOES EVERYWHERE",version:"2.6.35",context:"2010 · Android, virtualization and cloud",desktop:"GNOME 2 / EARLY CLOUD",prompt:"linux2010",
  intro:"Android and cloud infrastructure expanded Linux's reach. Linux 2.6 powered servers, smartphones and a growing virtualization ecosystem.",commands:[["ls /etc","Inspect system configuration"],["cat /etc/issue","Read distribution banner"],["cat /var/log/cloud-init.log","Inspect cloud initialization"],["uname -r","Inspect kernel release"],["ls /home/visitor/Projects","Explore cloud projects"],["desktop","Explore the desktop"]],files:{"README":"2010: CLOUD & MOBILE.\nAndroid and cloud infrastructure expanded Linux's reach. Linux 2.6 powered servers, smartphones and a growing virtualization ecosystem.","etc":{"issue":"Linux 2.6.35","os-release":"NAME=\"Linux\"\nPRETTY_NAME=\"Linux historical environment\""},"home":{"visitor":{"Desktop":{"Welcome.txt":"CLOUD & MOBILE"},"Projects":{"README":"Android and cloud infrastructure expanded Linux's reach. Linux 2.6 powered servers, smartphones and a growing virtualization ecosystem.","cloud.txt":"Cloud computing and virtualization expanded Linux adoption."}}},"var":{"log":{"cloud-init.log":"Cloud infrastructure and automation expanded around 2010."}}},facts:["Android grew into a major Linux-kernel-based mobile platform.","KVM virtualization was integrated into Linux in 2007 and was widely used by 2010.","OpenStack began in 2010 as an open-source cloud infrastructure project."]
 },
 "2015": {
  title:"CONTAINER REVOLUTION",subtitle:"THE CONTAINER ERA",version:"4.2",context:"2015 · Containers, orchestration and DevOps",desktop:"MODERN GNOME",prompt:"linux2015",
  intro:"Linux containers and orchestration transformed application deployment. Kubernetes 1.0 arrived in 2015 and Linux 4.x continued kernel development.",commands:[["cat /etc/os-release","Inspect distribution"],["ls /var/lib/containers","Inspect container storage"],["cat /home/visitor/Projects/containers.txt","Read container notes"],["uname -a","Inspect kernel details"],["ls /home/visitor/Projects","Explore projects"],["desktop","Explore the desktop"]],files:{"README":"2015: CONTAINER REVOLUTION.\nLinux containers and orchestration transformed application deployment. Kubernetes 1.0 arrived in 2015 and Linux 4.x continued kernel development.","etc":{"issue":"Linux 4.2","os-release":"NAME=\"Linux\"\nPRETTY_NAME=\"Linux historical environment\""},"home":{"visitor":{"Desktop":{"Welcome.txt":"CONTAINER REVOLUTION"},"Projects":{"README":"Linux containers and orchestration transformed application deployment. Kubernetes 1.0 arrived in 2015 and Linux 4.x continued kernel development.","containers.txt":"Docker and Kubernetes helped shape container-based application deployment."}}},"var":{"lib":{"containers":{"README":"Linux container storage and images."}}}},facts:["Kubernetes 1.0 was released in 2015.","Docker's early releases helped popularize application containers.","Linux namespaces and control groups underpin container isolation and resource management."]
 },
 "2020": {
  title:"CLOUD NATIVE",subtitle:"INFRASTRUCTURE AT SCALE",version:"5.10",context:"2020 · Cloud native, eBPF and remote infrastructure",desktop:"MODERN GNOME",prompt:"linux2020",
  intro:"Linux supported cloud-native platforms, observability and large-scale automation. eBPF enabled powerful tracing and networking use cases.",commands:[["cat /etc/os-release","Inspect distribution"],["ls /sys/fs/bpf","Explore eBPF filesystem"],["cat /home/visitor/Projects/observability.txt","Read observability notes"],["uname -r","Inspect kernel"],["env","View environment"],["desktop","Explore the desktop"]],files:{"README":"2020: CLOUD NATIVE.\nLinux supported cloud-native platforms, observability and large-scale automation. eBPF enabled powerful tracing and networking use cases.","etc":{"issue":"Linux 5.10","os-release":"NAME=\"Linux\"\nPRETTY_NAME=\"Linux historical environment\""},"home":{"visitor":{"Desktop":{"Welcome.txt":"CLOUD NATIVE"},"Projects":{"README":"Linux supported cloud-native platforms, observability and large-scale automation. eBPF enabled powerful tracing and networking use cases.","observability.txt":"eBPF enables Linux observability, networking and security tooling."}}},"sys":{"fs":{"bpf":{"README":"eBPF filesystem mount point."}}}},facts:["Linux 5.10 was released in December 2020 as a long-term support kernel.","eBPF became increasingly important for observability, security and networking.","Linux remained a foundation of cloud-native infrastructure."]
 },
 "2024": {
  title:"LINUX 6.x",subtitle:"A MODERN KERNEL",version:"6.6",context:"2024 · Linux 6.x, Rust and modern hardware",desktop:"MODERN LINUX",prompt:"linux2024",
  intro:"Modern Linux continued to evolve with architecture improvements, Rust infrastructure and new security and hardware features.",commands:[["cat /etc/os-release","Inspect distribution"],["ls /home/visitor/Projects","Explore projects"],["cat /home/visitor/Projects/kernel.txt","Read kernel notes"],["uname -a","Inspect kernel details"],["id","Inspect identity"],["desktop","Explore desktop"]],files:{"README":"2024: LINUX 6.x.\nModern Linux continued to evolve with architecture improvements, Rust infrastructure and new security and hardware features.","etc":{"issue":"Linux 6.6","os-release":"NAME=\"Linux\"\nPRETTY_NAME=\"Linux historical environment\""},"home":{"visitor":{"Desktop":{"Welcome.txt":"LINUX 6.x"},"Projects":{"README":"Modern Linux continued to evolve with architecture improvements, Rust infrastructure and new security and hardware features.","kernel.txt":"Linux 6.x continues to develop across architectures and hardware."}}}},facts:["The Linux 6.x series continued to evolve throughout 2024.","Initial Rust support was merged into Linux 6.1 in 2022, with further work continuing afterward.","Modern Linux supports a wide range of hardware architectures and workloads."]
 },
 "today": {
  title:"THE NEXT FRONTIER",subtitle:"MODERN OPEN SOURCE",version:"6.x",context:"Today · Containers, cloud and open ecosystems",desktop:"MODERN LINUX",prompt:"linux",
  intro:"Linux powers servers, phones, containers, embedded devices, supercomputers and desktop workstations. Linux continues to evolve across computing platforms.",
  commands:[["cat /etc/os-release","Inspect distribution identity"],["uname -a","Display system details"],["ls /home/visitor/Projects","Explore projects"],["id","Inspect user and groups"],["env","Display environment"],["desktop","Explore modern desktop"]],
  files:{"README":"Today: Linux is everywhere.\nModern Linux spans many distributions and environments.",
  "etc":{"os-release":"NAME=\"Linux\"\nPRETTY_NAME=\"Linux\"","issue":"Linux"},
  "home":{"visitor":{"Desktop":{"Welcome.txt":"Open source keeps evolving."},"Projects":{"README":"Containers, cloud, security and Linux."},"Documents":{}}},
  "usr":{"share":{"applications":{}}}},
  facts:["Linux underpins major cloud and container infrastructure.","Linux also runs across embedded systems and mobile devices.","Linux remains central to modern infrastructure."]
 }
};
