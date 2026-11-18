/* Authentic Linux 0.01 (1991) Linux 0.99.12 (1993), and Red Hat 5.2 (1998) x86 guests. */
(() => {
 "use strict";
 const start=document.getElementById("start"),stop=document.getElementById("stop"),status=document.getElementById("status");
 if(!start||!stop||!status)return;
 const common={wasm:"/vendor/v86/v86.wasm",bios:"/vendor/v86/seabios.bin",vga:"/vendor/v86/vgabios.bin"};
 const guests={
  "1991":{floppy:"/images/linux-0.01-floppy-1440k.img",disk:"/images/linux-0.01-hda.img.gz",master:"/images/linux-0.01-ide-master-placeholder.img",size:40*1024*1024,memory:8*1024*1024},
  "1993":{floppy:"/images/linux-0.99.12-floppy.img",diskPartsPrefix:"/images/slackware-1.01-1993.raw.gz.part-",memory:16*1024*1024},
  "1998":{diskPartsPrefix:"/images/redhat-5.2-1998.raw.gz.part-",memory:64*1024*1024}
 };
 const home=document.getElementById("real-linux-home");
 const selected=()=>home?(home.dataset.guestYear||"1991"):(new URLSearchParams(location.search).["1991","1993","1998"].includes(new URLSearchParams(location.search).get("era"))?new URLSearchParams(location.search).get("era"):"1991");
 let vm=null,starting=false,bootTimer=null,diskUrl=null,runId=0,activeYear=null;
 const report=message=>{status.textContent=message;};
 const releaseDisk=()=>{if(diskUrl){URL.revokeObjectURL(diskUrl);diskUrl=null;}};
 const clearBootTimer=()=>{if(bootTimer!==null){clearTimeout(bootTimer);bootTimer=null;}};
 function shutdown(){runId++;clearBootTimer();if(vm){try{vm.stop();vm.destroy();}catch(e){console.warn(e);}vm=null;}releaseDisk();starting=false;activeYear=null;start.disabled=false;stop.disabled=true;}
 async function verify(path){
  const response=await fetch(path,{method:"HEAD",cache:"no-store"});
  if(!response.ok)throw Error(path+" returned HTTP "+response.status);
  if((response.headers.get("content-type")||"").includes("text/html"))throw Error(path+" returned HTML instead of an emulator asset");
 }
 async function loadDisk(config,year){
  if(typeof DecompressionStream!=="function")throw Error("Browser lacks gzip DecompressionStream");
  report("Downloading "+year+" historical disk...");
  let compressed;
  if(config.diskPartsPrefix){
   const chunks=[];
   for(let i=0;i<100;i++){
    const url=config.diskPartsPrefix+String(i).padStart(3,"0");
    const response=await fetch(url,{cache:"no-store"});
    if(response.status===404&&i>0)break;
    if(!response.ok)throw Error("Disk part "+i+" failed: HTTP "+response.status);
    if((response.headers.get("content-type")||"").includes("text/html")){
     if(i>0)break;
     throw Error("Disk part "+i+" returned HTML");
    }
    chunks.push(await response.arrayBuffer());
    report("Downloading "+year+" disk: "+chunks.length+" part(s)...");
   }
   if(!chunks.length)throw Error("No historical disk parts found");
   compressed=new Blob(chunks,{type:"application/gzip"}).stream();
  }else{
   const response=await fetch(config.disk,{cache:"no-store"});
   if(!response.ok||!response.body)throw Error("Disk download failed: HTTP "+response.status);
   if((response.headers.get("content-type")||"").includes("text/html"))throw Error("Disk URL returned HTML");
   compressed=response.body;
  }
  report("Decompressing "+year+" IDE disk in browser memory...");
  const buffer=await new Response(compressed.pipeThrough(new DecompressionStream("gzip"))).arrayBuffer();
  if(config.size&&buffer.byteLength!==config.size&&buffer.byteLength!==40000000)throw Error("Unexpected disk image size: "+buffer.byteLength);
  if(buffer.byteLength<1024*1024||buffer.byteLength%512!==0)throw Error("Invalid IDE disk size: "+buffer.byteLength);
  return buffer;
 }
 async function boot(){
  if(starting||vm)return;
  const year=selected(),config=guests[year];
  if(!config)return;
  const token=++runId;
  starting=true;start.disabled=true;activeYear=year;
  try{
   if(typeof window.V86Starter!=="function"&&typeof window.V86!=="function")throw Error("v86 JavaScript is not loaded");
   report("Checking Linux "+year+" boot assets...");
   await Promise.all([...Object.values(common),...Object.entries(config).filter(([key,v])=>typeof v==="string"&&key!=="diskPartsPrefix").map(([,v])=>v),...(config.diskPartsPrefix?[config.diskPartsPrefix+"000"]:[])].map(verify));
   if(token!==runId)return;
   const disk=await loadDisk(config,year);
   if(token!==runId)return;
   releaseDisk();
   diskUrl=URL.createObjectURL(new Blob([disk],{type:"application/octet-stream"}));
   report("Starting authentic Linux "+year+" x86 PC...");
   const Emulator=window.V86Starter||window.V86;
   const options={
    wasm_path:common.wasm,memory_size:config.memory,vga_memory_size:2*1024*1024,
    screen_container:document.getElementById("screen_container"),
    bios:{url:common.bios},vga_bios:{url:common.vga},
    hda:{url:year==="1991"?config.master:diskUrl},
    boot_order:year==="1998"?0x132:0x213,autostart:true
   };
   if(config.floppy)options.fda={url:config.floppy};
   if(year==="1991")options.hdb={url:diskUrl};
   vm=new Emulator(options);
   bootTimer=setTimeout(()=>{
    if(token!==runId)return;
    bootTimer=null;
    const errors=(window.__v86LoadErrors||[]).slice(-3).join(" | ");
    report("Linux "+year+" emulator startup timed out. "+(errors?"Errors: "+errors:"Inspect the browser console."));
    stop.disabled=false;
   },30000);
   vm.add_listener("emulator-ready",()=>{
    if(token!==runId)return;
    clearBootTimer();report("Linux "+year+" x86 emulator running. Click the screen to type.");stop.disabled=false;
   });
   vm.add_listener("emulator-stopped",()=>{
    if(token!==runId)return;
    shutdown();report("PC powered off.");
   });
  }catch(error){
   if(token===runId){shutdown();report("Unable to boot Linux "+year+": "+error.message);}
  }finally{if(token===runId)starting=false;}
 }
 start.addEventListener("click",boot);
 stop.addEventListener("click",()=>{shutdown();report("PC powered off.");});
 window.addEventListener("linux-time-machine-era-change",event=>{
  if(!home)return;
  const year=event.detail?.year;
  if(year!=="1991"&&year!=="1993"&&year!=="1998"){shutdown();return;}
  if(activeYear===year&&(vm||starting))return;
  shutdown();
  home.dataset.guestYear=year;
  report("Preparing Linux "+year+"...");
  void boot();
 });
 if(home||new URLSearchParams(location.search).get("autostart")==="1"){
  const initialBoot=()=>{if(!vm&&!starting)void boot();};
  if(document.readyState==="complete")queueMicrotask(initialBoot);
  else window.addEventListener("load",initialBoot,{once:true});
  // The page may have finished loading before this script registered its load handler.
  // DOMContentLoaded is an additional safe startup path; boot() is idempotent.
  if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",initialBoot,{once:true});
  else queueMicrotask(initialBoot);
 }
})();