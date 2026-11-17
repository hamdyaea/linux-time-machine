/* Browser x86 guest. No fake boot output: all screen output comes from v86. */
(() => {
 "use strict";
 const start=document.getElementById("start"),stop=document.getElementById("stop"),status=document.getElementById("status");
 let vm=null;
 const paths=[
  "/vendor/v86/v86.wasm",
  "/vendor/v86/seabios.bin",
  "/vendor/v86/vgabios.bin",
  "/images/linux-0.01-floppy.img",
  "/images/linux-0.01-hda.img"
 ];
 const report=message=>{status.textContent=message;};
 async function verify(path){
  const r=await fetch(path,{method:"HEAD",cache:"no-store"});
  if(!r.ok)throw Error(path+" returned HTTP "+r.status);
  const type=r.headers.get("content-type")||"";
  if(type.includes("text/html"))throw Error(path+" returned HTML, not a binary asset");
 }
 start.addEventListener("click",async()=>{
  start.disabled=true;report("Checking x86 emulator and disk images...");
  try{
   if(typeof window.V86Starter!=="function")throw Error("Missing /vendor/v86/libv86.js");
   await Promise.all(paths.map(verify));
   report("Starting x86 PC (8 MiB RAM, floppy boot, IDE hard disk)...");
   vm=new window.V86Starter({
    wasm_path:paths[0],
    memory_size:8*1024*1024,
    vga_memory_size:2*1024*1024,
    screen_container:document.getElementById("screen_container"),
    bios:{url:paths[1]},
    vga_bios:{url:paths[2]},
    fda:{url:paths[3]},
    hda:{url:paths[4]},
    boot_order:0x132,
    autostart:true
   });
   vm.add_listener("emulator-ready",()=>{report("PC running. Click the screen and use your keyboard.");stop.disabled=false;});
   vm.add_listener("emulator-stopped",()=>{report("PC powered off.");start.disabled=false;stop.disabled=true;});
  }catch(e){report("Unable to start: "+e.message);start.disabled=false;}
 });
 stop.addEventListener("click",()=>{if(vm){vm.stop();vm.destroy();vm=null;}stop.disabled=true;start.disabled=false;report("PC powered off.");});
})();
