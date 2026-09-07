/**
 * Pedagogical sketch — where the pieces meet the runtime.
 * Step 06: point at the real module; do not re-implement ThreadGC here.
 *
 * Live implementation:
 *   source/core/internal/gc/impl/tgc/gc.d
 * Public registration hook (DUB package):
 *   typically tgc.gcobj in the published package layout
 *
 * Enable with --DRT-gcopt=gc:tgc after linking the factory.
 */
module pathogenesis.step06;

enum liveImpl = "source/core/internal/gc/impl/tgc/gc.d";
enum runtimeName = "tgc";
