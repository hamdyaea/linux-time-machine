// Linux 0.01 educational reconstruction. This is NOT a real shell or kernel.
const file = content => ({type:"file",content});
const dir = children => ({type:"dir",children});
const root=dir({
 README:file("Linux 0.01 — September 1991\n\nThis is an educational reconstruction, not a running Linux 0.01 kernel.\nOriginal sources: https://www.kernel.org/pub/linux/kernel/Historic/\n\nTry: ls, cd kernel, cat README, pwd, uname, help"),
 boot:dir({"boot.s":file("Historical source placeholder. Consult the original archive for authentic code.")}),
 fs:dir({README:file("Filesystem implementation sources (simplified representation).")}),
 include:dir({README:file("Header files (simplified representation).")}),
 init:dir({"main.c":file("Historical source placeholder. Consult the original archive.")}),
 kernel:dir({README:file("Kernel sources: scheduling, traps, and system calls."),"sched.c":file("Historical source placeholder. Consult the original archive.")}),
 lib:dir({}),mm:dir({}),tools:dir({})
});
let cwd=[],history=[],position=0;
const term=document.querySelector("#terminal"),output=document.querySelector("#output"),input=document.querySelector("#command"),prompt=document.querySelector("#prompt");
const path=()=>"/"+cwd.join("/");
const normalize=(p)=>{const result=p.startsWith("/")?[]:[...cwd];for(const part of p.split("/")){if(!part||part===".")continue;if(part==="..")result.pop();else result.push(part)}return result};
const get=(parts)=>{let node=root;for(const part of parts){if(node.type!=="dir")return null;node=node.children[part];if(!node)return null}return node};
const print=(message,cls="")=>{const element=document.createElement("div");element.className="line "+cls;element.textContent=message;output.append(element);term.scrollTop=term.scrollHeight};
const run=(line)=>{const args=line.trim().split(/\s+/),cmd=args[0],target=args[1]||".",node=get(normalize(target));switch(cmd){
case "":break;
case "help":print("Commands: help, ls, pwd, cd, cat, echo, clear, date, uname, whoami, history, about, source");break;
case "ls":print(!node?"ls: no such file or directory":node.type==="file"?target:Object.keys(node.children).sort().join("   "));break;
case "pwd":print(path());break;
case "cd":{const p=normalize(args[1]||"/"),n=get(p);if(n?.type==="dir")cwd=p;else print("cd: not a directory");break}
case "cat":print(!args[1]?"cat: missing filename":!node?"cat: file not found":node.type==="dir"?"cat: is a directory":node.content);break;
case "echo":print(args.slice(1).join(" "));break;
case "clear":output.replaceChildren();break;
case "date":print(new Date().toString()+" (visitor device clock)");break;
case "uname":print("Linux 0.01 (simulated — not a real kernel)");break;
case "whoami":print("visitor");break;
case "history":print(history.map((h,i)=>(i+1)+"  "+h).join("\n"));break;
case "about":print("Linux Time Machine: an independent, educational reconstruction of the 1991 Linux 0.01 era.");break;
case "source":print("https://www.kernel.org/pub/linux/kernel/Historic/");break;
default:print(cmd+": command not found (simulated shell)");
}};
document.querySelector("#shell").addEventListener("submit",event=>{event.preventDefault();const line=input.value;print("visitor@linux1991:"+path()+"$ "+line,"entered");if(line.trim()){history.push(line);position=history.length}run(line);input.value="";prompt.textContent="visitor@linux1991:"+path()+"$";term.scrollTop=term.scrollHeight});
input.addEventListener("keydown",event=>{if(event.key==="ArrowUp"){event.preventDefault();position=Math.max(0,position-1);input.value=history[position]||""}else if(event.key==="ArrowDown"){event.preventDefault();position=Math.min(history.length,position+1);input.value=history[position]||""}});
document.querySelector("#reset").addEventListener("click",()=>{cwd=[];history=[];position=0;output.replaceChildren();input.value="";prompt.textContent="visitor@linux1991:/$";input.focus()});
term.addEventListener("click",()=>input.focus());
