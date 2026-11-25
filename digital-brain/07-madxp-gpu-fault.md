# madxp GPU Fault

**Date:** 2026-09-23
**Status:** Open. Leading hypothesis is **power delivery / hardware**, not a driver bug. Unconfirmed.
**Scope:** Corrects the fault recorded in `05-nixos-migration.md` as the "amdgpu S3-resume bug".
Two earlier notes attributed it to suspend and to memory pressure. The kernel log supports neither.

---

## 1. The evidence

One captured failure, `journalctl` on madxp, 2025-09-16 00:40:17. Abridged; the full sequence
repeats for `sdma0` after `sdma1`:

```
amdgpu 0000:03:00.0: ring sdma1 timeout, signaled seq=302879, emitted seq=302882
amdgpu 0000:03:00.0: Starting sdma1 ring reset
amdgpu 0000:03:00.0: reset sdma queue (1:0:0)
amdgpu 0000:03:00.0: Timeout waiting for VM flush ACK!
amdgpu 0000:03:00.0: [drm:amdgpu_ring_test_helper] *ERROR* ring sdma1 test failed (-110)
amdgpu 0000:03:00.0: Ring sdma1 reset failed
amdgpu 0000:03:00.0: GPU reset begin!. Source:  1
amdgpu 0000:03:00.0: device lost from bus!
amdgpu 0000:03:00.0: GPU reset end with ret = -19
amdgpu 0000:03:00.0: GPU Recovery Failed: -19
```

## 2. Reading it

| Line | Meaning |
|---|---|
| `ring sdma1 timeout`, 3 fences behind | A DMA engine stopped retiring work. Small backlog, so it stalled rather than drowned. |
| `ring sdma1 test failed (-110)` | `-110` = `ETIMEDOUT`. The targeted ring reset did not revive the engine. |
| `GPU reset begin!` | Escalation from ring reset to full device reset. |
| **`device lost from bus!`** | **The fault.** amdgpu read the card's PCI config space and got nothing back. |
| `ret = -19` | `-19` = `ENODEV`. There is no device left to reset. |

Everything after `device lost from bus!` is aftermath: `sdma0` times out because there is no device,
the VM flushes fail for the same reason, and the `VM memory stats … non-zero when fini` lines for
`ghostty` and `qs` are GL clients being torn down. Not causes.

**Once the card is off the bus, software cannot recover it.** Only a reboot does.

## 3. What this rules out

- **Not the VRAM-eviction ENOMEM bug.** No `ENOMEM`, no failed eviction, no memory pressure in the
  trace. That bug has a distinct signature and this is not it.
- **Therefore zram is not implicated.** `05-nixos-migration.md` tied the fault to zram-only 4G swap.
  That link is unsupported. Real swap is still wanted for hibernate and headroom — it is just not a
  fix for this.
- **Not established as suspend-related at all.** The excerpt contains no `PM: suspend entry` or
  `PM: suspend exit`. The "S3-resume" label may be inference from the outcome (dead display, reboot
  required) rather than from evidence. 00:40 is close enough to an idle timeout that hypridle is
  worth checking, but it has not been checked.

## 4. Why power is the leading hypothesis

`device lost from bus!` means the card stopped answering on PCIe. The causes that produce exactly
that, roughly in order of how cheaply they can be excluded:

1. **Power delivery** — transient load browns the card out and it drops off the link. Consistent
   with a stall under work rather than at idle, and with recovery being impossible in software.
2. **Physical link** — seating, slot, riser.
3. **A failing card.**
4. **Driver/firmware reset path** — a failed BACO or mode reset can also leave a card unenumerated,
   but that usually follows a reset the driver initiated, not one it escalated to after a hang.

(1)–(3) are hardware and testable this week. (4) is the only software cause, and it is the least
likely fit for this ordering.

## 5. Unknowns to close

- [ ] **The GPU model.** `lspci -nnk -s 03:00.0`. Recorded nowhere in this repo, and it gates every
      known-issue search. Do this first.
- [ ] **Is it suspend-path?** `journalctl -k --since '2025-09-16 00:35' --until '2025-09-16 00:45' | grep -iE 'PM:|suspend|resume'`
- [ ] **Does it correlate with load?** Note what was running at each failure. GPU-heavy work at the
      moment of the stall supports the power hypothesis; idle failures undercut it.
- [ ] **How often, and since when.** One captured instance is not a pattern.

## 6. Next actions

**Hardware first, because it is cheap and it gates the rest:** reseat the card, try the other PCIe
slot, and swap the PSU if a spare exists. Do not bisect kernels before this. Chasing a driver bug on
a card with a power fault costs months and finds nothing.

**Capture the next failure properly.** The log points at
`/sys/class/drm/card1/device/devcoredump/data`. The kernel deletes it on a timer, so copy it out
immediately or it is gone — September's is long gone. That dump is what makes an upstream report
actionable, if it turns out to be upstream.

**If and only if hardware is excluded**, the software fix space is kernel version, kernel parameters
(`amdgpu.runpm`, `amdgpu.reset_method`, `pcie_aspm`) and `linux-firmware` version. All three are
declarative on NixOS and each experiment is a boot-menu generation that can be abandoned for free.
That is a better bisection rig than Arch, and it is the honest version of the claim at
`05-nixos-migration.md` §3.2 — **NixOS is the platform to fix this from, not the fix.**

## 7. Why it matters now

madxp is the intended Sunshine host for couch game streaming (it has the GPU and the
`/mnt/storage` library). A host that can drop off the bus under load is a bad always-on streaming
target regardless of suspend behaviour, and a GPU fault during a stream is indistinguishable from a
network problem from the couch. Settle this before building on it.
