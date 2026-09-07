/**
 * Pedagogical sketch only — not linked into the tgc package.
 * Step 01: single heap, header + intrusive list, threshold trigger.
 */
module pathogenesis.step01;

struct BlkHeader
{
    size_t size;
    uint marked;
    BlkHeader* next;
    BlkHeader* prev;
}

struct Heap
{
    BlkHeader* head;
    size_t usedBytes;
    size_t collectThreshold = 256 * 1024;
}

__gshared Heap gHeap;

void* naiveAlloc(size_t size)
{
    if (gHeap.usedBytes >= gHeap.collectThreshold)
        naiveCollectAll(); // step 01: crude reclaim — later: mark then sweep

    import core.stdc.stdlib : malloc;
    auto raw = cast(BlkHeader*) malloc(BlkHeader.sizeof + size);
    raw.size = size;
    raw.marked = 0;
    raw.prev = null;
    raw.next = gHeap.head;
    if (gHeap.head)
        gHeap.head.prev = raw;
    gHeap.head = raw;
    gHeap.usedBytes += size;
    return cast(void*)(raw + 1);
}

void naiveCollectAll()
{
    import core.stdc.stdlib : free;
    auto cur = gHeap.head;
    while (cur)
    {
        auto n = cur.next;
        free(cur);
        cur = n;
    }
    gHeap.head = null;
    gHeap.usedBytes = 0;
}
