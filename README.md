# Legacy Xen Stub Domain for Qubes OS

This is the legacy Xen stub domain used by [Qubes OS](https://www.qubes-os.org).
A stub domain is a small, dedicated service VM that runs the QEMU device model
for a fully virtualized (HVM) qube, so the hardware emulation runs outside dom0
instead of inside it. This is the older MiniOS-based stub domain.

The repository builds the Xen stub domain from upstream Xen together with the
Qubes components it needs, including the GUI agent, the Xen vchan library, and a
small DHCP server, so an HVM qube's display reaches the Qubes GUI.

It is built as part of Qubes OS with [Qubes
Builder](https://www.qubes-os.org/doc/qubes-builder/). For background on how
Qubes isolates device emulation, see the [Qubes OS
documentation](https://www.qubes-os.org/doc/).
