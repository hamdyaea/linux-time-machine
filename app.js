import { eras } from "./eras.js";

// Browser-based historical shell interfaces. See README for implementation scope.
let year="1991",cwd=[],history=[],historyIndex=0;
const $=selector=>document.querySelector(selector);
const terminal=$("#terminal"),output=$("#output"),input=$("#command"),prompt=$("#prompt");
const shell=$("#shell"),tips=$("#command-tips"),facts=$("#era-facts"),preview=$("#desktop-preview");
const getPath=()=>"/"+cwd.join("/");
const normalize=value=>{const result=value.startsWith("/")?[]:[...cwd];for(const part of value.split("/")){if(!part||part===".")continue;if(part==="..")result.pop();else result.push(part)}return result;};
const nodeAt=parts=>{let node=eras[year].files;for(const part of parts){if(!node||typeof node!=="object"||!Object.hasOwn(node,part))return null;node=node[part]}return node;};
const print=(value,kind="")=>{const line=document.createElement("div");line.className="line "+kind;line.textContent=value;output.append(line);terminal.scrollTop=terminal.scrollHeight;};
const updatePrompt=()=>{prompt.textContent="visitor@"+eras[year].prompt+":"+getPath()+"$";};
const commands=()=>["help","ls","pwd","cd","cat","echo","clear","date","uname","whoami","history","about","source","timeline","desktop"];
function execute(line){
 const args=line.trim().split(/\s+/);const command=args[0],target=args[1]||".",node=nodeAt(normalize(target)),era=eras[year];
 switch(command){
 case "":break;
 case "help":print("Available commands:\n"+commands().join("  ")+"\n\nTry the suggested commands below the terminal.");break;
 case "ls":print(node===null?"ls: no such file or directory":typeof node==="string"?target:Object.keys(node).sort().join("   "));break;
 case "pwd":print(getPath());break;
 case "cd":{const path=normalize(args[1]||"/");const dest=nodeAt(path);if(dest&&typeof dest==="object"){cwd=path;updatePrompt()}else print("cd: not a directory");break;}
 case "cat":print(!args[1]?"cat: missing filename":node===null?"cat: file not found":typeof node==="object"?"cat: is a directory":node);break;
 case "echo":print(args.slice(1).join(" "));break;
 case "clear":output.replaceChildren();break;
 case "date":print(new Date().toString()+"");break;
 case "uname":print(args.includes("-r")?era.version:args.includes("-a")?"Linux "+era.prompt+" "+era.version+" i386 GNU/Linux":"Linux");break;
 case "whoami":print("visitor");break;
 case "history":print(history.map((item,index)=>(index+1)+"  "+item).join("\n"));break;
 case "about":print(era.intro);break;
 case "source":print("Original Linux 0.01 archive: https://www.kernel.org/pub/linux/kernel/Historic/");break;
 case "timeline":print(Object.entries(eras).map(([key,item])=>key+" — "+item.title).join("\n"));break;
 case "desktop":print(year==="1991"?"1991: Linux 0.01 did not include a graphical desktop.":year==="1993"?"1993: early distributions could run graphical X environments, but this era focuses on the shell.":"Desktop environment loaded above the terminal.");break;
 default:print(command+": command not found");
 }
}
function submit(value){print("visitor@"+eras[year].prompt+":"+getPath()+"$ "+value,"entered");if(value.trim()){history.push(value);historyIndex=history.length;}execute(value);input.value="";terminal.scrollTop=terminal.scrollHeight;}
function reset(){cwd=[];history=[];historyIndex=0;output.replaceChildren();input.value="";updatePrompt();input.focus();}
function renderDesktop(era){
 preview.replaceChildren();const label=document.createElement("div");label.className="preview-label";label.textContent=era.desktop;preview.append(label);
 if(year==="1991"||year==="1993"){const panel=document.createElement("div");panel.className="preview-text";panel.textContent=year==="1991"?"NO GRAPHICAL DESKTOP\nLinux 0.01 was a kernel release.":"EARLY DISTRIBUTION ERA\nA shell-first historical overview.";preview.append(panel);return;}
 const scene=document.createElement("div");scene.className="desktop-scene desktop-"+year;
 const bar=document.createElement("div");bar.className="desktop-bar";bar.textContent=year==="1998"?"K • File  Edit  View  Help":year==="2004"?"Applications    Places    System":"◈   Activities     Files     Terminal";
 const window=document.createElement("div");window.className="desktop-window";
 const title=document.createElement("div");title.className="desktop-window-title";title.textContent="Welcome — "+year+"  ◻ ×";
 const content=document.createElement("div");content.className="desktop-window-content";content.textContent=year==="1998"?"Graphical Linux enters a new era.":year==="2004"?"Linux becomes a desktop option for more people.":"Linux powers the modern world.";
 window.append(title,content);scene.append(bar,window);preview.append(scene);
}
function setEra(next){
 if(!Object.hasOwn(eras,next))return;
 year=next;reset();
 const era=eras[year];
 document.querySelectorAll(".era-card").forEach(button=>{const active=button.dataset.year===year;button.classList.toggle("active",active);button.setAttribute("aria-pressed",String(active));});
 $(".portal-year").textContent=year;
 $("#console-title").innerHTML="BOOT INTO <em>"+year+".</em>";
 $("#console-description").textContent=era.intro;
 $("#console-identifier").textContent="CHRONO_TERMINAL // "+era.title;
 $("#console-destination").textContent="DESTINATION: "+year;
 $("#boot-description").textContent="Destination: "+era.context+"\nSystem: "+era.title+"\n\nType help for available commands.\n\n";
 tips.replaceChildren();era.commands.forEach(([command,description])=>{const button=document.createElement("button");button.type="button";button.className="command-tip";const code=document.createElement("code");code.textContent=command;const detail=document.createElement("span");detail.textContent=description;button.append(code,detail);button.addEventListener("click",()=>{submit(command);input.focus()});tips.append(button);});
 facts.replaceChildren();era.facts.forEach(item=>{const li=document.createElement("li");li.textContent=item;facts.append(li);});
 renderDesktop(era);
}
shell.addEventListener("submit",event=>{event.preventDefault();submit(input.value);});
input.addEventListener("keydown",event=>{if(event.key==="ArrowUp"){event.preventDefault();historyIndex=Math.max(0,historyIndex-1);input.value=history[historyIndex]||"";}else if(event.key==="ArrowDown"){event.preventDefault();historyIndex=Math.min(history.length,historyIndex+1);input.value=history[historyIndex]||"";}});
$("#reset").addEventListener("click",reset);
terminal.addEventListener("click",()=>input.focus());
document.querySelectorAll(".era-card").forEach(button=>button.addEventListener("click",()=>{setEra(button.dataset.year);$("#terminal-section").scrollIntoView({behavior:matchMedia("(prefers-reduced-motion: reduce)").matches?"instant":"smooth"});}));
setEra("1991");
