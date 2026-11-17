/* Authentic Linux 0.01-compatible guest; screen output is produced by v86. */
(() => {
 "use strict";
 const start=document.getElementById("start"),stop=document.getElementById("stop"),status=document.getElementById("status");
 const paths={
  wasm:"/vendor/v86/v86.wasm",
  bios:"/vendor/v86/seabios.bin",
  vga:"/vendor/v86/vgabios.bin",
  floppy:"/images/linux-0.01-floppy-1440k.img",
  disk:"/images/linux-0.01-hda.img.gz",
  master:"/images/linux-0.01-ide-master-placeholder.img"
 };
 let vm=null,starting=false,bootTimer=null,diskUrl=null;
 const releaseDisk=()=>{if(diskUrl){URL.revokeObjectURL(diskUrl);diskUrl=null;}};
 const clearBootTimer=()=>{if(bootTimer!==null){clearTimeout(bootTimer);bootTimer=null;}};
 const report=message=>{status.textContent=message;};
 async function verify(path){
  const response=await fetch(path,{method:"HEAD",cache:"no-store"});
  if(!response.ok)throw Error(path+" returned HTTP "+response.status);
  if((response.headers.get("content-type")||"").includes("text/html"))throw Error(path+" returned HTML, not an emulator asset");
 }
 async function loadDisk(){
  if(typeof DecompressionStream!=="function")throw Error("This browser does not support DecompressionStream('gzip'). Try an updated Chromium or Firefox.");
  report("Downloading compressed historical disk (4.4 MB)...");
  const response=await fetch(paths.disk,{cache:"no-store"});
  if(!response.ok||!response.body)throw Error("Disk download failed: HTTP "+response.status);
  if((response.headers.get("content-type")||"").includes("text/html"))throw Error("Disk URL returned HTML");
  report("Decompressing Linux 0.01 IDE disk in browser memory...");
  const decompressed=response.body.pipeThrough(new DecompressionStream("gzip"));
  const buffer=await new Response(decompressed).arrayBuffer();
  if(buffer.byteLength!==40*1024*1024 && buffer.byteLength!==40_000_000)
   throw Error("Unexpected disk image size: "+buffer.byteLength+" bytes");
  return buffer;
 }
 start.addEventListener("click",async()=>{
  if(starting||vm)return;
  starting=true;start.disabled=true;
  try{
   if(typeof window.V86Starter!=="function" && typeof window.V86!=="function"){
    const url="/vendor/v86/libv86.js";
    const response=await fetch(url,{cache:"no-store"});
    const type=response.headers.get("content-type")||"unknown";
    if(!response.ok)throw Error("v86 JavaScript HTTP "+response.status+" at "+url);
    if(type.includes("text/html"))throw Error("v86 JavaScript URL returned HTML instead of JS: "+url);
    const issues=(window.__v86LoadErrors||[]).slice(-4).join(" | ");
    throw Error("v86 JavaScript fetched (HTTP "+response.status+", "+type+") but neither V86Starter nor V86 is available."+(issues?" Browser errors: "+issues:" Check F12 Console and Network response for script content."));
   }
   report("Checking v86 emulator and Linux 0.01 boot assets...");
   await Promise.all(Object.values(paths).map(verify));
   const disk=await loadDisk();
   releaseDisk();
   diskUrl=URL.createObjectURL(new Blob([disk],{type:"application/octet-stream"}));
   report("Starting authentic x86 guest (8 MiB RAM, floppy boot, IDE master placeholder + historical slave disk)...");
   const Emulator=window.V86Starter||window.V86;
   const constructorName=typeof window.V86Starter==="function"?"V86Starter":"V86";
   vm=new Emulator({
    wasm_path:paths.wasm,memory_size:8*1024*1024,vga_memory_size:2*1024*1024,
    screen_container:document.getElementById("screen_container"),
    bios:{url:paths.bios},vga_bios:{url:paths.vga},
    fda:{url:paths.floppy},hda:{url:paths.master},hdb:{url:diskUrl},boot_order:0x213,autostart:true
   });
   bootTimer=setTimeout(()=>{
    bootTimer=null;
    const errors=(window.__v86LoadErrors||[]).slice(-3).join(" | ");
    report("Emulator did not become ready within 20 seconds. Constructor: "+constructorName+". State: "+(vm&&typeof vm.is_running==="function"?String(vm.is_running()):"unknown")+". "+(errors?"Errors: "+errors:"Check browser Console for v86 initialization failures."));
    start.disabled=false;
    stop.disabled=false;
   },20000);
   vm.add_listener("emulator-ready",()=>{clearBootTimer();report("x86 emulator running. Click the guest screen and use your keyboard.");stop.disabled=false;});
   vm.add_listener("emulator-stopped",()=>{clearBootTimer();report("PC powered off.");start.disabled=false;stop.disabled=true;vm=null;releaseDisk();});
  }catch(error){
   clearBootTimer();
   report("Unable to start: "+error.message);start.disabled=false;
   if(vm){try{vm.destroy();}catch{}vm=null;}
   releaseDisk();
  }finally{starting=false;}
 });
 if(new URLSearchParams(location.search).get("autostart")==="1") {
  window.addEventListener("load",()=>start.click(),{once:true});
 }
 stop.addEventListener("click",()=>{
  clearBootTimer();
  if(vm){try{vm.stop();vm.destroy();}catch{}vm=null;}
  releaseDisk();
  stop.disabled=true;start.disabled=false;report("PC powered off.");
 });
})();
