# Phase 3.2 — Codespaces desktop performance

The browser desktop runs QEMU without KVM on many Codespaces hosts. Software emulation is CPU intensive; these changes are best-effort and are not equivalent to native hardware acceleration.

## Test the optimized launcher

In Codespaces, stop the currently running launcher with Ctrl+C in its terminal. Then:

```bash
git pull origin feature/phase2-mayaos-desktop-shell
bash -n scripts/run-browser-desktop.sh
bash scripts/codespaces-desktop.sh
```

Keep the terminal open. Open the **private** forwarded port 6080, using `/vnc.html`. Do not expose VNC/noVNC publicly.

## Tuning

The launcher uses one virtual CPU for TCG and two for KVM. Override for experiments:

```bash
MAYAOS_VM_CPUS=2 MAYAOS_VM_MEMORY=2048 bash scripts/codespaces-desktop.sh
```

Compare launch time and responsiveness at 1 vs 2 virtual CPUs; more vCPUs can be slower under TCG. The default memory is 2048 MiB. Do not allocate more than the Codespace can support.

Within the guest, disable XFCE compositing at Settings > Window Manager Tweaks > Compositor. Try a 1280×720 guest resolution. In noVNC, use Local Scaling to fit the viewport (scaling affects presentation, not CPU emulation).

## Check actual bottleneck

```bash
ps -eo pid,%cpu,%mem,cmd | grep -E 'qemu-system|websockify' | grep -v grep
test -r /dev/kvm && test -w /dev/kvm && echo KVM-available || echo TCG-only
curl -I http://127.0.0.1:6080/vnc.html
```

Performance improvements are not validated until tested in Codespaces. For responsive long-term development, use a KVM-enabled Linux host or native installation.
