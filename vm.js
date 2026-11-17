/* Authentic Linux 0.01-compatible guest; screen output is produced by v86. */
(() => {
 "use strict";
 const start=document.getElementById("start"),stop=document.getElementById("stop"),status=document.getElementById("status");
 const paths={
  wasm:"/vendor/v86/v86.wasm",
  bios:"/vendor/v86/seabios.bin",
  vga:"/vendor/v86/vgabios.bin",
  floppy:"/images/linux-0.01-floppy.img",
  disk:"/images/linux-0.01-hda.img.gz"
 };
 let vm=null,starting=false;
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
  return new Uint8Array(buffer);
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
   report("Starting authentic x86 guest (8 MiB RAM, floppy boot, decompressed IDE disk)...");
   const Emulator=window.V86Starter||window.V86;
   vm=new Emulator({
    wasm_path:paths.wasm,memory_size:8*1024*1024,vga_memory_size:2*1024*1024,
    screen_container:document.getElementById("screen_container"),
    bios:{url:paths.bios},vga_bios:{url:paths.vga},
    fda:{url:paths.floppy},hda:{buffer:disk},boot_order:0x132,autostart:true
   });
   vm.add_listener("emulator-ready",()=>{report("x86 emulator running. Click the guest screen and use your keyboard.");stop.disabled=false;});
   vm.add_listener("emulator-stopped",()=>{report("PC powered off.");start.disabled=false;stop.disabled=true;vm=null;});
  }catch(error){
   report("Unable to start: "+error.message);start.disabled=false;
   if(vm){try{vm.destroy();}catch{}vm=null;}
  }finally{starting=false;}
 });
 stop.addEventListener("click",()=>{
  if(vm){try{vm.stop();vm.destroy();}catch{}vm=null;}
  stop.disabled=true;start.disabled=false;report("PC powered off.");
 });
})();
