# MayaOS

Custom **Debian 13 (trixie)**-based desktop operating system for **x86-64** PCs.

MayaOS targets a clean installable live ISO, Chromebook-friendly development workflow checks, and a path from a temporary XFCE desktop toward a custom **Qt/QML Wayland** shell.

| Item | Value |
|------|--------|
| Base | Debian 13 (trixie) |
| Arch | amd64 (x86-64) |
| Temp desktop | XFCE |
| Future desktop | Qt/QML + Wayland compositor |
| Version | See `VERSION` |

## Status

**Initialization complete.** Project layout, live-build config, build/test scripts, Chromebook checks, docs, and CI are in place.

An ISO is **not** claimed bootable until it has been built and exercised under QEMU (or real hardware). This repo does **not** require downloading a prebuilt ZIP.

## Quick start

```bash
# 1. Environment checks (Chromebook / deps / disk)
./scripts/check-chromebook.sh
./scripts/check-deps.sh

# 2. Validate project scripts and config
./scripts/validate.sh

# 3. Build the live ISO (needs root, live-build, ~15+ GiB free)
sudo ./scripts/build-iso.sh

# 4. Smoke-test in QEMU (after an ISO exists under out/)
./scripts/test-qemu.sh
```

See [docs/BUILD.md](docs/BUILD.md) and [docs/TESTING.md](docs/TESTING.md).

## Layout

```
mayaos/
├── config/           # Debian live-build configuration
├── desktop/          # Future Qt/QML Wayland desktop scaffold
├── docs/             # Architecture, build, Chromebook, testing
├── scripts/          # Build, check, validate, QEMU helpers
├── tests/            # Test helpers / scratch
├── out/              # ISO and build outputs (gitignored)
├── cache/            # Optional local cache (gitignored contents)
└── .github/workflows # CI
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md) — layers, desktop roadmap, Wayland plan
- [Build](docs/BUILD.md) — live-build, packages, ISO production
- [Chromebook](docs/CHROMEBOOK.md) — Crostini limits, checks, workarounds
- [Desktop](docs/DESKTOP.md) — XFCE now, Qt/QML later
- [Testing](docs/TESTING.md) — QEMU, CI expectations
- [Limitations](docs/LIMITATIONS.md) — host/CI constraints (no bootable claim without tests)

## License

MIT — see [LICENSE](LICENSE).
