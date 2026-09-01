# tgc

Opt-in **thread-local garbage collector** for D (`tgc`). Each attached thread owns a private heap arena; collection on one thread does not stop-the-world pause sibling threads or detached `@nogc` workers.

Informal name: realtime GC. Registered runtime name: `tgc`.

**DUB:** [tgc](https://code.dlang.org/packages/tgc) · **Repo:** [dlang-supplemental/tgc](https://github.com/dlang-supplemental/tgc)

Part of [dlang-supplemental](https://github.com/dlang-supplemental). Design write-up: [**Thread-local GC (tgc) for D »**](https://dlang-supplemental.github.io/docs/docs/blog/thread-local-gc-tgc.html)

## Install

```powershell
dub add tgc
```

## Enable

Import the hook module so the factory is linked, then select the collector:

```d
import tgc.gcobj;

// Option A — runtime flag
// ./app --DRT-gcopt=gc:tgc

// Option B — default at link time (add versions "Tgc_default" to your dub config)
extern(C) __gshared rt_options = ["gcopt=gc:tgc"];
```

## Requirements

- DMD 2.112+ or LDC with pluggable GC + `registerGCFactory` thread init hook (same era as SymGC integration).
- Prefer message passing / ownership transfer across threads; unrestricted shared mutable GC pointers are unsupported in v1.

Upstream prototype: [dlang/dmd#23514](https://github.com/dlang/dmd/pull/23514)

## Changelog

See [CHANGELOG.adoc](CHANGELOG.adoc).

## License

BSL-1.0 — see [LICENSE](LICENSE).
