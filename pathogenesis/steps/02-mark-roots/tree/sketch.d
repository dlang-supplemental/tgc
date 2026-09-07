/**
 * Pedagogical sketch — mark phase only.
 * Step 02: clear marks, scan a root range, mark reachable headers.
 */
module pathogenesis.step02;

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
}

void clearMarks(Heap* h)
{
    for (auto b = h.head; b; b = b.next)
        b.marked = 0;
}

BlkHeader* findBlock(Heap* h, void* p)
{
    for (auto b = h.head; b; b = b.next)
    {
        void* base = b + 1;
        if (p >= base && p < base + b.size)
            return b;
    }
    return null;
}

void markPtr(Heap* h, void* p)
{
    if (auto b = findBlock(h, p))
        b.marked = 1;
}

void markRange(Heap* h, void* bot, void* top)
{
    // Conservative: every pointer-sized word might be a heap pointer.
    for (auto p = cast(void**) bot; p < cast(void**) top; p++)
        markPtr(h, *p);
}

void markFromStack(Heap* h, void* stackBot, void* stackTop)
{
    clearMarks(h);
    markRange(h, stackBot, stackTop);
}
