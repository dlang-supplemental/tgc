/**
 * Pedagogical sketch — sweep after mark.
 * Step 03: free unmarked blocks; keep marked ones.
 */
module pathogenesis.step03;

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
}

void sweep(Heap* h)
{
    import core.stdc.stdlib : free;
    auto cur = h.head;
    while (cur)
    {
        auto n = cur.next;
        if (!cur.marked)
        {
            if (cur.prev)
                cur.prev.next = cur.next;
            else
                h.head = cur.next;
            if (cur.next)
                cur.next.prev = cur.prev;
            if (h.usedBytes >= cur.size)
                h.usedBytes -= cur.size;
            free(cur);
        }
        cur = n;
    }
}
