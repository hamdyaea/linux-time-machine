import { eras } from "./eras.js?v=20261118-command-guide2";

// Browser-based historical shell interfaces. See README for implementation scope.
let year="1991",cwd=[],history=[],historyIndex=0,bootToken=0;
const $=selector=>document.querySelector(selector);
const terminal=$("#terminal"),output=$("#output"),input=$("#command"),prompt=$("#prompt");
const shell=$("#shell"),tips=$("#command-tips"),facts=$("#era-facts"),preview=$("#desktop-preview");
const getPath=()=>"/"+cwd.join("/");
const homePath=()=>year==="1991"?"/":"/home/visitor";
const displayPath=()=>{const p=getPath();return p===homePath()?"~":p.startsWith(homePath()+"/")?"~"+p.slice(homePath().length):p;};
const promptText=()=>year==="1991"?"# ":year==="1993"?"bash# ":year==="1998"?"[visitor@linux "+displayPath()+"]$ ":year==="2004"?"visitor@ubuntu:"+displayPath()+"$ ":"visitor@linux:"+displayPath()+"$ ";
const normalize=value=>{const result=value.startsWith("/")?[]:[...cwd];for(const part of value.split("/")){if(!part||part===".")continue;if(part==="..")result.pop();else result.push(part)}return result;};
const nodeAt=parts=>{let node=eras[year].files;for(const part of parts){if(!node||typeof node!=="object"||!Object.hasOwn(node,part))return null;node=node[part]}return node;};
const print=(value,kind="")=>{const line=document.createElement("div");line.className="line "+kind;line.textContent=value;output.append(line);terminal.scrollTop=terminal.scrollHeight;};
const updatePrompt=()=>{prompt.textContent=promptText();};
const commands=()=>["help","ls","pwd","cd","cat","head","grep","wc","echo","printf","clear","date","uname","hostname","id","uptime","env","whoami","history","about","source","timeline","desktop"];
function execute(line){
 const args=line.trim().split(/\s+/);const command=args[0],target=args[1]||".",node=nodeAt(normalize(target)),era=eras[year];
 switch(command){
 case "":break;
 case "help":print("Available commands:\n"+commands().join("  "));break;
 case "ls":print(node===null?"ls: no such file or directory":typeof node==="string"?target:Object.keys(node).sort().join("   "));break;
 case "pwd":print(getPath());break;
 case "hostname":print(year==="2004"?"ubuntu":"linux");break;
 case "id":print(year==="1991"||year==="1993"?"uid=0(root) gid=0(root)":"uid=1000(visitor) gid=1000(visitor)");break;
 case "uptime":print("up 0 min, 1 user");break;
 case "env":print("HOME="+homePath()+"\nSHELL=/bin/sh\nPATH=/bin:/usr/bin");break;
 case "printf":print(args.slice(1).join(" ").replaceAll("\\n","\\n"));break;
 case "head":{const file=nodeAt(normalize(args.at(-1)||"."));print(typeof file==="string"?file.split("\n").slice(0,10).join("\n"):"head: cannot open file");break;}
 case "wc":{const file=nodeAt(normalize(args.at(-1)||"."));print(typeof file==="string"?file.split("\n").length+" "+file.trim().split(/\s+/).length+" "+file.length+" "+args.at(-1):"wc: cannot open file");break;}
 case "grep":{const pattern=args[1];const file=nodeAt(normalize(args[2]||"."));print(!pattern?"grep: missing pattern":typeof file==="string"?file.split("\n").filter(x=>x.includes(pattern)).join("\n"):"grep: cannot open file");break;}
 case "cd":{const path=normalize(args[1]||homePath());const dest=nodeAt(path);if(dest&&typeof dest==="object"){cwd=path;updatePrompt()}else print("cd: not a directory");break;}
 case "cat":print(!args[1]?"cat: missing filename":node===null?"cat: file not found":typeof node==="object"?"cat: is a directory":node);break;
 case "echo":print(args.slice(1).join(" "));break;
 case "clear":output.replaceChildren();break;
 case "date":print(new Date().toString());break;
 case "uname":print(args.includes("-r")?era.version:args.includes("-a")?"Linux "+era.prompt+" "+era.version+" i386 GNU/Linux":"Linux");break;
 case "whoami":print(year==="1991"||year==="1993"?"root":"visitor");break;
 case "history":print(history.map((item,index)=>(index+1)+"  "+item).join("\n"));break;
 case "about":print(era.intro);break;
 case "source":print("Original Linux 0.01 archive: https://www.kernel.org/pub/linux/kernel/Historic/");break;
 case "timeline":print(Object.entries(eras).map(([key,item])=>key+" — "+item.title).join("\n"));break;
 case "desktop":print(year==="1991"?"No graphical environment installed.":year==="1993"?"X Window System packages are available separately.":"DISPLAY=:0");break;
 default:print(command+": command not found");
 }
}
function submit(value){print(promptText()+value,"entered");if(value.trim()){history.push(value);historyIndex=history.length;}execute(value);input.value="";terminal.scrollTop=terminal.scrollHeight;}
function reset(){cwd=year==="1991"?[]:["home","visitor"];history=[];historyIndex=0;output.replaceChildren();input.value="";updatePrompt();input.focus();}
function renderDesktop(era){
 preview.replaceChildren();const label=document.createElement("div");label.className="preview-label";label.textContent=era.desktop;preview.append(label);
 if(year==="1991"||year==="1993"){const panel=document.createElement("div");panel.className="preview-text";panel.textContent=year==="1991"?"NO GRAPHICAL DESKTOP\nLinux 0.01 was a kernel release.":"EARLY DISTRIBUTION ERA\nA shell-first historical overview.";preview.append(panel);return;}
 const scene=document.createElement("div");scene.className="desktop-scene desktop-"+year;
 const bar=document.createElement("div");bar.className="desktop-bar";bar.textContent=year==="1998"?"K • File  Edit  View  Help":year==="2004"?"Applications    Places    System":"◈   Activities     Files     Terminal";
 const window=document.createElement("div");window.className="desktop-window";
 const title=document.createElement("div");title.className="desktop-window-title";title.textContent="Welcome — "+year+"  ◻ ×";
 const content=document.createElement("div");content.className="desktop-window-content";content.textContent=year==="1998"?"Graphical Linux enters a new era.":year==="2004"?"Linux becomes a desktop option for more people.":year==="2010"?"Linux powers cloud infrastructure and mobile devices.":year==="2015"?"Containers change how applications are delivered.":year==="2020"?"Cloud-native Linux scales across infrastructure.":year==="2024"?"Linux 6.x advances modern systems.":"Linux powers the modern world.";
 window.append(title,content);scene.append(bar,window);preview.append(scene);
}
const banners={
 "1991":["Linux 0.01  (i386)","tty0: console ready",""],
 "1993":["Slackware Linux 1.0","Linux 0.99.13 (i386)","login: root",""],
 "1998":["Linux 2.0.36 (i386)","Welcome to Linux",""],
 "2004":["Ubuntu 4.10 (Warty Warthog)","Linux 2.6.8 (i386)",""],
 "2010":["Linux 2.6.35 (i686)","Cloud and mobile systems online",""],
 "2015":["Linux 4.2 (x86_64)","Container runtime ready",""],
 "2020":["Linux 5.10 (x86_64)","Cloud-native infrastructure ready",""],
 "2024":["Linux 6.6 (x86_64)","Modern Linux workstation ready",""],
 "today":["Linux (x86_64)",""]
};
// Era banners are presentation text, not kernel-generated boot logs.
function showBanner(){
 const token=++bootToken;
 const lines=banners[year]||["Linux",""];const element=$("#boot-description");
 element.textContent="";
 const reduced=window.matchMedia("(prefers-reduced-motion: reduce)").matches;
 if(reduced){element.textContent=lines.join("\n")+"\n";return;}
 let i=0;
 const add=()=>{if(token!==bootToken)return;if(i>=lines.length){return;}element.textContent+=lines[i++]+"\n";terminal.scrollTop=terminal.scrollHeight;window.setTimeout(add,85);};
 add();
}
const realKernelEras=new Set(["1991","1993","1998","2004"]);
let realKernelAvailable=false;
async function checkRealKernelAssets(){
 const paths=["/vendor/v86/libv86.js","/vendor/v86/v86.wasm","/vendor/v86/seabios.bin","/vendor/v86/vgabios.bin","/images/linux-0.01-floppy.img","/images/linux-0.01-hda.img.gz"];
 try{
  const results=await Promise.all(paths.map(async path=>{
   const response=await fetch(path,{method:"HEAD",cache:"no-store"});
   return response.ok&&!((response.headers.get("content-type")||"").includes("text/html"));
  }));
  realKernelAvailable=results.every(Boolean);
 }catch{realKernelAvailable=false;}
 updateKernelPanel();
}
function updateKernelPanel(){
 const panel=$("#kernel-boot-panel"),detail=$("#kernel-boot-detail"),title=$("#kernel-boot-title");
 if(!panel)return;
 panel.hidden=true;
 if(panel.hidden)return;
 title.textContent="1993 / HISTORICAL KERNEL";
 detail.textContent="A verified 1993 kernel and matching distribution disk have not yet been prepared. The terminal below is an interactive historical shell.";
}
async function initializeTemporalEngine(){
 const img=document.querySelector(".temporal-gallery img");
 if(!img)return;
 try{
  const response=await fetch(img.getAttribute("src"));
  if(!response.ok)throw Error("HTTP "+response.status);
  const svg=new DOMParser().parseFromString(await response.text(),"image/svg+xml").documentElement;
  if(svg.localName!=="svg"||!svg.querySelector("#temporal-engine-year"))throw Error("Invalid temporal SVG");
  svg.classList.add("temporal-engine-live");
  svg.setAttribute("aria-label","Temporal engine destination "+year);
  img.replaceWith(document.importNode(svg,true));
  updateTemporalEngine();
 }catch(error){console.warn("Temporal engine unavailable:",error);}
}
function updateTemporalEngine(){
 const svg=document.querySelector(".temporal-engine-live");
 if(!svg)return;
 svg.querySelector("#temporal-engine-year").textContent=year.toUpperCase();
 svg.querySelector("#temporal-engine-coordinates").textContent=year.toUpperCase()+" → TODAY";
 svg.setAttribute("aria-label","Temporal engine destination "+year);
 const caption=document.querySelector(".temporal-gallery-caption span:last-child");
 if(caption)caption.textContent=year.toUpperCase()+" → TODAY";
}
function setEra(next){
 if(!Object.hasOwn(eras,next))return;
 year=next;reset();updateKernelPanel();updateTemporalEngine();
 const realHome=$("#real-linux-home"),historicalShell=$("#console-shell");
 if(realHome){realHome.hidden=year!=="1991"&&year!=="1993"&&year!=="1998";realHome.dataset.guestYear=year;}
 if(historicalShell)historicalShell.hidden=realKernelEras.has(year);
 const facts1991=$("#linux001-facts"),facts1993=$("#linux1993-facts"),guestTitle=$("#real-linux-guest-title"),guestHint=$("#real-linux-hint");
 if(facts1991)facts1991.hidden=year!=="1991";
 if(facts1993)facts1993.hidden=year!=="1993";
 if(guestTitle)guestTitle.textContent=year==="2004"?"◉ UBUNTU 4.10 WARTY WARTHOG · 128 MiB · IDE · LOGIN: demo / PASSWORD: demo":year==="1998"?"◉ RED HAT LINUX 5.2 · 64 MiB · IDE · LOGIN: root / PASSWORD: toor":year==="1993"?"◉ LINUX 0.99.12 / SLACKWARE 1.01 · 16 MiB · IDE · LOGIN: root":"◉ LINUX 0.01 / REAL x86 · 8 MiB · IDE";
 if(guestHint)guestHint.textContent=year==="2004"?"REAL UBUNTU 4.10 · Username: demo · Password: demo · Click inside the guest screen to type.":year==="1998"?"REAL RED HAT LINUX 5.2 · Username: root · Password: toor · Click inside the guest screen to type.":year==="1993"?"REAL LINUX 0.99.12 · Slackware 1.01 · Click inside the guest screen to type · At the login prompt, enter root · Commands run inside the historical x86 system.":"REAL LINUX 0.01 · Click inside the guest screen to type · Commands run inside the historical x86 system.";
 window.dispatchEvent(new CustomEvent("linux-time-machine-era-change",{detail:{year}}));
 document.querySelectorAll("[data-jump]").forEach(button=>{const selected=button.dataset.jump===year;button.classList.toggle("selected",selected);button.setAttribute("aria-pressed",String(selected));});
 const era=eras[year];
 document.querySelectorAll(".era-card").forEach(button=>{const active=button.dataset.year===year;button.classList.toggle("active",active);button.setAttribute("aria-pressed",String(active));});
 $(".portal-year").textContent=year;
 const chronoVector=$("#chrono-vector");if(chronoVector)chronoVector.textContent=year.toUpperCase();
 $("#console-title").innerHTML="BOOT INTO <em>"+year+".</em>";
 $("#console-description").textContent=era.intro;
 $("#console-identifier").textContent="CHRONO_TERMINAL // "+era.title;
 $("#console-destination").textContent="DESTINATION: "+year;
 $("#console-shell").dataset.era=year;
 $("#console-shell").classList.remove("is-booting");
 void $("#console-shell").offsetWidth;
 $("#console-shell").classList.add("is-booting");
 $("#terminal-status").textContent=year==="1991"?"◉ tty0 · 80×25":year==="1993"?"◉ tty1 · 80×25":year==="today"?"◉ pts/0 · UTF-8":"◉ tty1 · 80×25";
 showBanner();
 tips.replaceChildren();const guide=document.querySelector(".command-guide > p");if(guide)guide.textContent=realKernelEras.has(year)?"Click a command to copy it, then paste it inside the real Linux guest terminal. Commands run in the guest, not in a simulated shell.":"Select a command to run it in the terminal above. The commands and files change with each era.";era.commands.forEach(([command,description])=>{const button=document.createElement("button");button.type="button";button.className="command-tip";button.title=realKernelEras.has(year)?"Copy command to clipboard":"Run command";const code=document.createElement("code");code.textContent=command;const detail=document.createElement("span");detail.textContent=description;button.append(code,detail);button.addEventListener("click",async()=>{if(realKernelEras.has(year)){try{await navigator.clipboard.writeText(command);detail.textContent="Copied — paste into Linux guest";setTimeout(()=>{detail.textContent=description},2200);}catch{detail.textContent="Select and copy: "+command;setTimeout(()=>{detail.textContent=description},3000);}return;}submit(command);input.focus()});tips.append(button);});
 facts.replaceChildren();era.facts.forEach(item=>{const li=document.createElement("li");li.textContent=item;facts.append(li);});
 renderDesktop(era);
}
shell.addEventListener("submit",event=>{event.preventDefault();submit(input.value);});
input.addEventListener("keydown",event=>{if(event.ctrlKey&&event.key.toLowerCase()==="l"){event.preventDefault();output.replaceChildren();$("#boot-description").textContent="";return;}if(event.key==="Tab"){
 event.preventDefault();
 const before=input.value.slice(0,input.selectionStart);
 const after=input.value.slice(input.selectionEnd);
 const tokenStart=Math.max(before.lastIndexOf(" ")+1,before.lastIndexOf("\t")+1);
 const token=before.slice(tokenStart);
 const commandPosition=before.slice(0,tokenStart).trim().length===0;
 let matches=[];
 if(commandPosition&&!token.includes("/")){
  matches=commands().filter(name=>name.startsWith(token)).sort();
 }else{
  const slash=token.lastIndexOf("/");
  const directory=slash>=0?token.slice(0,slash+1):"";
  const prefix=slash>=0?token.slice(slash+1):token;
  const parent=nodeAt(normalize(directory||"."));
  if(parent&&typeof parent==="object"){
   matches=Object.keys(parent).filter(name=>name.startsWith(prefix)).sort().map(name=>directory+name);
  }
 }
 if(matches.length){
  const common=matches.reduce((prefix,item)=>{
   let i=0;while(i<prefix.length&&i<item.length&&prefix[i]===item[i])i++;
   return prefix.slice(0,i);
  },matches[0]);
  if(common.length>token.length||matches.length===1){
   input.value=before.slice(0,tokenStart)+common+(matches.length===1?" ":"")+after;
   input.setSelectionRange(input.value.length-after.length,input.value.length-after.length);
  }else{
   print(matches.join("  "));
  }
 }
 return;
}if(event.key==="ArrowUp"){event.preventDefault();historyIndex=Math.max(0,historyIndex-1);input.value=history[historyIndex]||"";}else if(event.key==="ArrowDown"){event.preventDefault();historyIndex=Math.min(history.length,historyIndex+1);input.value=history[historyIndex]||"";}});
$("#reset").addEventListener("click",()=>{reset();showBanner();});
terminal.addEventListener("click",()=>input.focus());
document.querySelectorAll("[data-jump]").forEach(button=>button.addEventListener("click",()=>setEra(button.dataset.jump)));
document.querySelectorAll(".era-card").forEach(button=>button.addEventListener("click",()=>{setEra(button.dataset.year);$("#terminal-section").scrollIntoView({behavior:matchMedia("(prefers-reduced-motion: reduce)").matches?"instant":"smooth"});}));
setEra("1991");
void initializeTemporalEngine();
checkRealKernelAssets();
