/**
 * Standalone responsiveness demo (same logic as test/tgc_responsiveness.d).
 *
 * Build & run:
 *   dub run --config=responsiveness-demo
 * Or with runtime flag instead of Tgc_default:
 *   dub run --config=responsiveness-demo-rtflag -- --DRT-gcopt=gc:tgc
 */
module responsiveness.main;

import tgc.gcobj;
import core.atomic;
import core.thread;
import core.time;
import core.memory;
import std.stdio;

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

void main()
{
    enum tickSleepMsecs = 1;
    enum maxTickStall = 250.msecs;
    enum minTicks = 50;
    enum minWorkerCollections = stressRounds / 2;

    writeln("tgc responsiveness demo (import tgc.gcobj; select gc:tgc at link or runtime)");
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

    const cols = atomicLoad(workerCollections);
    writefln("ticks=%d workerCollections=%d worstTick=%s", ticks, cols, worst);

    if (cols < minWorkerCollections)
    {
        writeln("FAIL: worker stress too weak");
        return;
    }
    if (ticks < minTicks)
    {
        writeln("FAIL: main thread did not tick enough");
        return;
    }
    if (worst >= maxTickStall)
    {
        writefln("FAIL: worst tick %s >= threshold %s (not responsive; is gc:tgc active?)",
            worst, maxTickStall);
        return;
    }

    writefln("PASS: main-thread max tick stall %s < %s", worst, maxTickStall);
}
