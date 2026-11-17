# Real Linux 0.01 boot track

Linux Time Machine aims to boot Linux 0.01 in an x86 browser emulator.

## Step 1 — Build and verify the guest

On a Linux workstation with Docker and Git:

```bash
bash scripts/build-linux-0.01.sh
cd .work/linux-0.01
make -f mvp.mk run
```

The script uses [joeangel/linux-0.01](https://github.com/joeangel/linux-0.01), whose documented build boots a compatibility-patched Linux 0.01 kernel into a shell in QEMU. The script copies its kernel `Image` to `images/linux-0.01-Image` and prints a checksum. Review the upstream source and build scripts before running third-party code.

## Step 2 — Convert the boot setup for v86

[v86](https://github.com/copy/v86) emulates i386 PC hardware in WebAssembly. It can boot a **bzImage** or boot from BIOS-recognized floppy/IDE media. The 1991 `Image` is not automatically a Linux boot-protocol bzImage. Therefore:

1. Inspect the upstream `mvp.mk` boot method and its disk/rootfs.
2. Package the kernel and root filesystem into a BIOS-bootable floppy/IDE image with the correct boot sector, or implement a compatible v86 loader.
3. Validate the media in QEMU **using a BIOS disk/floppy boot**, not just `-kernel`.
4. Validate in v86 with its `fda`, `hdb`, BIOS, VGA BIOS, and WASM files.
5. Only then ship the tested images with license and SHA-256 metadata.

v86 does not list Linux 0.01 as a supported target; its emulator may require changes to support 1991-specific CPU and device behavior. Linux 0.01 is an early kernel and depends on a compatible userland/root filesystem.

## Hosting

The front end can remain on Cloudflare Pages. Place verified boot media and v86 runtime files under static assets, or serve larger verified assets from a configured Cloudflare R2 bucket with correct CORS/range handling. Keep emulator dependencies pinned and locally hosted rather than loading executable JavaScript from untrusted third-party CDNs.

## Status

The **build workflow** is committed. No successful Linux 0.01 guest boot has been verified in the ChatGPT environment: this environment has neither a working network git clone nor QEMU/Docker. A browser VM must not be presented as running Linux 0.01 until the boot test actually succeeds.
