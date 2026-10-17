/**
 * Responsiveness harness: main thread ticks while a worker allocates and
 * forces collection on its own heap under `gc:tgc`.
 *
 * Metric: worst elapsed time per tick (light alloc + 1 ms sleep) while the
 * worker runs. With stop-the-world GC, sibling threads are paused during the
 * worker's collections and this max stall typically blows past the threshold.
 * With thread-local `tgc`, only the worker pauses for its collections.
 *
 * Threshold: `maxTickStall` (250 ms) — generous for slow CI hosts; default GC
 * under the same load usually exceeds this by a wide margin.
 */
module tgc_responsiveness;

import tgc.gcobj;
import core.atomic;
import core.thread;
import core.time;
import core.memory;

shared bool workerStop;
shared size_t workerCollections;

enum stressRounds = 250;
enum allocsPerRound = 60;
enum blockInts = 512;

void workerStress()
{
    int[][] keep;
    foreach (round_; 0 .. stressRounds)
    {
        foreach (_; 0 .. allocsPerRound)
            keep ~= new int[blockInts];
        GC.collect();
        atomicOp!"+="(workerCollections, 1);
        if (keep.length > 20)
            keep = keep[$ - 10 .. $];
    }
    atomicStore(workerStop, true);
}

unittest
{
    enum tickSleepMsecs = 1;
    enum maxTickStall = 250.msecs;
    enum minTicks = 50;
    enum minWorkerCollections = stressRounds / 2;

    auto wt = new Thread(&workerStress);
    wt.start();

    Duration worst = Duration.zero;
    size_t ticks;

    while (!atomicLoad(workerStop))
    {
        MonoTime t0 = MonoTime.currTime();
        auto scratch = new int[16];
        scratch[0] = cast(int) ticks;
        Thread.sleep(tickSleepMsecs.msecs);
        auto stall = MonoTime.currTime() - t0;
        if (stall > worst)
            worst = stall;
        ticks++;
    }

    wt.join();

    assert(atomicLoad(workerCollections) >= minWorkerCollections,
        "worker did not run enough collections for a meaningful stress test");
    assert(ticks >= minTicks,
        "main thread did not make enough progress during worker stress");
    assert(worst < maxTickStall,
        "main-thread max tick stall " ~ worst.toString() ~
        " exceeds " ~ maxTickStall.toString() ~
        " (likely stop-the-world GC or host overload; need gc:tgc)");
}
