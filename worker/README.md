# Ubuntu 2004 — private R2 deployment (experimental)

This Worker is a **starting point**, not a billing hard cap. Do not publish until testing, account-level spending controls and Cloudflare Free-plan limits have been checked. It does not yet replace the site's 2004 gzip loader.

## 1. Create resources

Create an **R2 Standard** bucket named `linux-time-machine` (private, no public bucket URL) and a D1 database:

```sh
npx wrangler d1 create linux-time-machine-quota
```

The D1 database was created and `worker/wrangler.toml` is now committed with its ID. Confirm the bucket name and public website origin before deploying. The effective configuration is:

```toml
name = "linux-time-machine-disk"
main = "src/index.js"
compatibility_date = "2026-11-18"
workers_dev = true

[vars]
SITE_ORIGIN = "https://linuxtimemachine.org"
DISK_KEY = "ubuntu-4.10-2004.raw"

[[r2_buckets]]
binding = "DISK"
bucket_name = "linux-time-machine"

[[d1_databases]]
binding = "QUOTA"
database_name = "linux-time-machine-quota"
database_id = "5021046e-c696-4793-b804-3cb292a50537"
```

Verify the actual production origin and R2 bucket name before deployment.

## 2. Create database table

```sh
npx wrangler d1 execute linux-time-machine-quota --remote --file=worker/schema.sql
```

## 3. Convert and upload disk

Run from repository root on the machine holding the QCOW2 image:

```sh
mkdir -p .work/linux-2004
qemu-img convert -p -f qcow2 -O raw -S 4k .work/linux-2004/ubuntu-4.10.qcow2 .work/linux-2004/ubuntu-4.10-r2.raw
npx wrangler r2 object put linux-time-machine/ubuntu-4.10-2004.raw --file=.work/linux-2004/ubuntu-4.10-r2.raw --remote
```

R2 stores the RAW disk as a single object; the browser must **not** download it all. The new frontend v86 async-range integration still needs to be implemented and verified before publishing.

## 4. Worker test

```sh
cd worker
npx wrangler deploy
```

Test CORS and byte ranges using your own Worker URL and exact site origin:

```sh
curl -i -H 'Origin: https://linuxtimemachine.org' 'https://YOUR-WORKER.workers.dev/status'
curl -i -H 'Origin: https://linuxtimemachine.org' -H 'Range: bytes=0-511' 'https://YOUR-WORKER.workers.dev/disk' -o /tmp/ltm-boot-sector
```

Never enable public bucket access. Do not publish R2 API credentials or D1 secrets in GitHub.

## Limitations / safety

- R2 Class B, Worker, and D1 quotas are separate; D1 writes and R2 HEAD calls also count.
- This gateway limits successful ranged reads but cannot prevent all malicious requests from consuming Worker invocation quotas. Add Cloudflare account-level monitoring, request filtering and alerts before opening publicly.
- Application counters can differ from Cloudflare billing counts and cannot guarantee zero cost.
- Requests denied by the gateway still count toward Worker requests.
- Check the Worker Free daily reset and D1 free allowances before selecting production thresholds.
- The current UI must be adapted to use v86 asynchronous HTTP range reads; simply deploying this Worker will not fix the browser crash.
