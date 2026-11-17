/* Capture failures during v86 library evaluation before the VM UI loads. */
(() => {
 const errors=[];
 window.__v86LoadErrors=errors;
 window.addEventListener("error",event=>{
  const message=event.message||("Failed resource: "+(event.target&&event.target.src||"unknown"));
  errors.push(message+(event.filename?" @ "+event.filename+":"+event.lineno:""));
 },true);
 window.addEventListener("unhandledrejection",event=>errors.push("Unhandled promise: "+String(event.reason)));
 window.addEventListener("securitypolicyviolation",event=>{
  errors.push("CSP violation: "+event.violatedDirective+" blocked "+event.blockedURI);
 });
})();
