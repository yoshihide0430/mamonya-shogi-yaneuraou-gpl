# Corresponding-source integration report — 2026-09-27

This package has been aligned to the exact source used for Astra's validated
plain-NEON NNUE repair.

- Upstream commit: `c1b80eaa09fe13d5f12b1599d1ae4d53c224de30`
- Production binary SHA-256: `28647dbf16571809dc4713950bd121b87c28b33436516ee2976a14f13d5dc6e7`
- Target: ARMv8-A generic NEON, no DOTPROD requirement
- `HASH_KEY_BITS=128`, `TT_CLUSTER_SIZE=4`
- Canonical patch: `patches/nnue-neon-layout.patch`
- Regression harness: `tests/nnue_layout_test.cpp`, `tools/test_nnue_layout.ps1`

The previous alternative `android-neon-nnue-sparse.patch` was removed because it
was not the source used to produce the Astra-validated production binary.
