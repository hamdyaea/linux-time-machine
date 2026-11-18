// Ubuntu 4.10 read-only R2 range gateway. No public R2 bucket access.
// Deploy only after configuring R2 and D1 bindings and reviewing Cloudflare limits.
const MAX_RANGE = 4 * 1024 * 1024;
const MONTH_LIMIT = 7_000_000; // Conservative application ceiling, not a billing hard cap.
const DAY_LIMIT = 30_000; // Below the typical Workers Free daily request allowance.
const headers = (origin, env) => ({
  "Access-Control-Allow-Origin": env.SITE_ORIGIN,
  "Access-Control-Allow-Methods": "GET, HEAD, OPTIONS",
  "Access-Control-Allow-Headers": "Range, X-Accept-Encoding",
  "Access-Control-Expose-Headers": "Accept-Ranges, Content-Range, Content-Length",
  "Vary": "Origin",
  "Cache-Control": "no-store",
  "X-Content-Type-Options": "nosniff",
});
function response(message, code, origin, env, extra = {}) {
  return new Response(message, { status: code, headers: { ...headers(origin, env), ...extra } });
}
function monthKey(date) { return date.toISOString().slice(0, 7); }
function dayKey(date) { return date.toISOString().slice(0, 10); }
function nextMonth(date) { return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth() + 1, 1)).toISOString(); }
async function count(env, key, ceiling) {
  // SQLite UPSERT is atomic: concurrent requests cannot overshoot the application ceiling.
  const result = await env.QUOTA.prepare(
    "INSERT INTO usage (key, requests) VALUES (?1, 1) ON CONFLICT(key) DO UPDATE SET requests = requests + 1 WHERE requests < ?2 RETURNING requests"
  ).bind(key, ceiling).first();
  return result?.requests ?? null;
}
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const origin = request.headers.get("Origin");
    if (!env.SITE_ORIGIN || !env.DISK_KEY || !env.DISK || !env.QUOTA)
      return new Response("Service not configured", { status: 503 });
    if (origin !== env.SITE_ORIGIN) return new Response("Forbidden", { status: 403 });
    if (request.method === "OPTIONS")
      return response(null, 204, origin, env);
    if (url.pathname !== "/disk" && url.pathname !== "/status")
      return response("Not found", 404, origin, env);
    if (request.method !== "GET" && request.method !== "HEAD")
      return response("Method not allowed", 405, origin, env);
    const now = new Date();
    try {
      if (url.pathname === "/status") {
        const row = await env.QUOTA.prepare("SELECT requests FROM usage WHERE key = ?1")
          .bind("month:" + monthKey(now)).first();
        const count = row?.requests || 0;
        return Response.json({
          available: count < MONTH_LIMIT,
          requests: count,
          limit: MONTH_LIMIT,
          resetAt: nextMonth(now),
        }, { headers: headers(origin, env) });
      }
      const meta = await env.DISK.head(env.DISK_KEY);
      if (!meta) return response("Disk not uploaded", 503, origin, env);
      if (request.method === "HEAD") {
        return response(null, 200, origin, env, {
          "Accept-Ranges": "bytes",
          "Content-Length": String(meta.size),
          "Content-Type": "application/octet-stream",
        });
      }
      const range = request.headers.get("Range");
      const match = /^bytes=(\d+)-(\d*)$/.exec(range || "");
      if (!match) return response("Byte range required", 416, origin, env);
      const start = Number(match[1]);
      const end = match[2] ? Number(match[2]) : Math.min(start + MAX_RANGE - 1, meta.size - 1);
      if (!Number.isSafeInteger(start) || !Number.isSafeInteger(end) || start > end ||
          start >= meta.size || end >= meta.size || end - start + 1 > MAX_RANGE)
        return response("Invalid or oversized range", 416, origin, env);
      // Two separate counters enforce monthly and daily budgets. These are application
      // guardrails, not a Cloudflare account-wide spending limit.
      if (await count(env, "month:" + monthKey(now), MONTH_LIMIT) === null ||
          await count(env, "day:" + dayKey(now), DAY_LIMIT) === null)
        return response("Ubuntu 2004 is temporarily unavailable due to free-tier limits.", 429, origin, env,
          { "Retry-After": "3600" });
      const object = await env.DISK.get(env.DISK_KEY, { range: { offset: start, length: end - start + 1 } });
      if (!object?.body) return response("Disk unavailable", 503, origin, env);
      return new Response(object.body, { status: 206, headers: {
        ...headers(origin, env),
        "Accept-Ranges": "bytes",
        "Content-Range": `bytes ${start}-${end}/${meta.size}`,
        "Content-Length": String(end - start + 1),
        "Content-Type": "application/octet-stream",
      } });
    } catch (error) {
      console.error("R2 gateway error", error);
      return response("Disk service temporarily unavailable", 503, origin, env);
    }
  },
};
