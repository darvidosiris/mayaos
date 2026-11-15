# Phase 3.1 — GitHub Codespaces interactive MayaOS

This creates an on-demand, browser-based MayaOS test environment without registering for a separate cloud provider. GitHub Codespaces is not a permanent free host: it has usage quotas and the codespace stops when idle.

## One-click entry

Open **https://codespaces.new/darvidosiris/mayaos/tree/feature/phase2-mayaos-desktop-shell**.

Choose the `MayaOS Browser Desktop` dev container, a 2-core machine to start, then **Create codespace**. The environment installs QEMU, noVNC and GitHub CLI. A 2-core machine has limited resources and QEMU software emulation may be very slow.

## Get the ISO and launch the desktop

The ISO must have been built using **https://github.com/darvidosiris/mayaos/actions/workflows/build-iso.yml**, on branch `feature/phase2-mayaos-desktop-shell` with **Build ISO** enabled. A successful run must have the artifact named `mayaos-iso`.

In the Codespaces terminal:

```bash
bash scripts/codespaces-desktop.sh
```

This script uses GitHub CLI to find the latest successful manual workflow run on the feature branch, downloads its `mayaos-iso` artifact into `out/codespaces`, and starts QEMU and noVNC. If authentication is required for GitHub CLI, follow its interactive prompt or check `gh auth status`. If ISO download fails, check the build workflow and artifact retention (14 days).

In the **PORTS** tab, find port **6080** (MayaOS Desktop). Set its visibility to **Private**, then choose **Open in Browser**. If the URL opens only the web directory, append **/vnc.html** and click **Connect**.

GitHub Codespaces supplies a temporary HTTPS forwarded URL resembling `https://your-codespace-name-6080.app.github.dev/vnc.html`. The name changes per codespace; never guess the link. Do not change its visibility to public; VNC access is not password-protected in this development setup.

The existing Netlify site `https://mayamediaos.netlify.app/` is only a portal. The private Codespaces desktop link depends on GitHub account authentication and is available only while the Codespace session runs. The Netlify portal can open that link, but cannot host the VM or bypass authentication.

## Limitations

- Codespaces hosts a container; it does not provide nested hardware virtualization by default. QEMU uses slow software emulation if /dev/kvm is unavailable.
- The ISO runs as a live CD: changes made inside MayaOS will generally not persist.
- Codespaces has free usage limits depending on account and plan; monitor spending/usage and stop your codespace when done.
- GitHub Actions preview screenshots and Codespaces interactive testing serve separate purposes.
- For permanent, responsive access to MayaOS, use a dedicated host with KVM and authentication.
