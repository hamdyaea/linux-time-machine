# Real Linux 0.01 boot track

Linux Time Machine includes a browser x86 boot integration for compatibility-patched historical Linux kernels. The original 1991 experiment grew into multiple guest configurations; this document preserves its reproducible build and diagnostic steps.

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

The **build workflow** and v86 guest integration are committed. The landing page and `vm.js` configure Linux 0.01 (1991), Linux 0.99.12/Slackware 1.01 (1993), Red Hat 5.2 (1998), and a 2004 Ubuntu-era recreation. Their VM assets are external to Git, so the public deployment must be tested in a real browser before any claim that a particular guest successfully boots. This documentation does not assert a new successful boot test.

## Browser proof of concept (added)

The dedicated test harness is `vm.html` + `vm.js`. It passes the **same boot floppy and IDE disk** from the upstream Docker QEMU runtime into v86 and uses 8 MiB RAM. It intentionally renders only the emulator's actual VGA output.

On your Linux workstation:

```bash
cd ~/Téléchargements/linux-time-machine
git pull --ff-only
bash scripts/prepare-browser-images.sh

# Clone and build the upstream browser emulator using its current documented build instructions:
git clone https://github.com/copy/v86.git .work/v86
cd .work/v86
# Follow https://github.com/copy/v86#build for required toolchain and build steps.
# The staging script requires build/libv86.js, build/v86.wasm,
# bios/seabios.bin and bios/vgabios.bin.
cd ../..
bash scripts/stage-v86.sh .work/v86
python3 -m http.server 8000
```

Open **http://localhost:8000/vm.html**. Press **POWER ON** and inspect actual VGA output.

If the VM fails to boot, inspect the developer console and compare QEMU's floppy and IDE configuration with v86 device support. Linux 0.01 may require v86 CPU/BIOS fixes. A successful QEMU boot is not proof of a successful v86 boot.

**Deployment:** the images and emulator binary are deliberately gitignored (the IDE disk may be large). They must be explicitly packaged with the Cloudflare Pages deployment output after a successful browser test. A plain Git checkout may report missing assets, even when a separately bundled production deployment works. Never replace a working Pages deployment with a source-only build.
